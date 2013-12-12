//
//  SPTRouteStopsModel.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRouteStop.h"

@interface SPTRouteStop()
@property (strong, nonatomic) SPTServerApiModel *serverApiModel;
@end

@implementation SPTRouteStop


- (id) init {
    self = [super init];
    
    if(self) {
        _serverApiModel = [[SPTServerApiModel alloc] init];
        _serverApiModel.delegate = self;
        
        _departures = [[NSMutableArray alloc] init];
        _delegate = nil;
    }
    
    return self;
}

- (id) initWithDict:(NSDictionary*) dict {
    self = [self init];
    
    if(self) {
        _latitude = [[dict objectForKey:@"Latitude"] floatValue];
        _longitude = [[dict objectForKey:@"Longitude"] floatValue];
        _name = [dict objectForKey:@"Name"];
        _stopId = [[dict objectForKey:@"StopId"] integerValue];
    }
    
    return self;
}

- (void) downloadStopSchedule {
    [self.serverApiModel downloadScheduleForStop:self.stopId];
}

- (void) downloadCompletedWithData:(NSData*)data {
    [self parseJson:data];
    [self.delegate stopScheduleDownloadComplete];
}

- (void) downloadCompletedWithError:(NSError*)error {
    [self.delegate stopScheduleDownloadError:error];
}

- (void) parseJson:(NSData*)data {
    NSError *error;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // If there are no departures, the json array will be empty
    if([json count] == 0) {
        return;
    }
    
    NSArray *routeDirections = [[json objectAtIndex:0] objectForKey:@"RouteDirections"];
    
    NSMutableArray *tmpDepartures = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in routeDirections) {
        NSArray *departures = nil;
        
        // Loops don't run on exact schedules so they must be treated differently
        if([[dict objectForKey:@"IsHeadway"] integerValue]) {
            departures = [dict objectForKey:@"HeadwayDepartures"];
        } else {
            departures = [dict objectForKey:@"Departures"];
        }
        
        // Create a new departure object for each departure in the list
        for(NSDictionary *departureDict in departures) {
            NSObject *scheduledDepartureTime = [departureDict objectForKey:@"SDT"];
            NSObject *estimatedDepartureTime = [departureDict objectForKey:@"EDT"];
            NSObject *loopNextDeparture = [departureDict objectForKey:@"NextDeparture"];
            
            // Can't insert nil objects into a dictionary
            if(scheduledDepartureTime == nil) {
                scheduledDepartureTime = [NSNull null];
            }
            if(estimatedDepartureTime == nil) {
                estimatedDepartureTime = [NSNull null];
            }
            if(loopNextDeparture == nil) {
                loopNextDeparture = [NSNull null];
            }
            
            SPTStopDeparture *departure = [[SPTStopDeparture alloc] initWithDict:@{@"routeId": [dict objectForKey:@"RouteId"],
                                                                    @"scheduledDepartureTime": scheduledDepartureTime,
                                                                    @"estimatedDepartureTime": estimatedDepartureTime,
                                                                         @"loopNextDeparture": loopNextDeparture}];
            // Find the dict in the tmp departures array for the given route ID
            bool wasFound = NO;
            for(NSDictionary *tmpDict in tmpDepartures) {
                if([[tmpDict objectForKey:@"routeId"] integerValue] == [[dict objectForKey:@"RouteId"] integerValue]) {
                    [[tmpDict objectForKey:@"departures"] addObject:departure];
                    wasFound = YES;
                    break;
                }
            }
            
            // If the route ID was not found in the tmp departures array, add it
            if(!wasFound) {
                [tmpDepartures addObject:@{@"routeId": [dict objectForKey:@"RouteId"], @"departures": [[NSMutableArray alloc] initWithObjects:departure, nil]}];
            }
        }
    }
    
    // Add the depatures list for each route to the departures array
    for(NSDictionary *dict in tmpDepartures) {
        [self.departures addObject:[dict objectForKey:@"departures"]];
    }
}

- (NSInteger) getNumberOfRoutesDepartingFromStop {
    return [self.departures count];
}

- (NSInteger) getNumberOfDeparturesForRouteNumber:(NSInteger)num {
    return [[self.departures objectAtIndex:num] count];
}

- (NSArray*) getDepaturesForRouteNumber:(NSInteger)num {
    return [self.departures objectAtIndex:num];
}

@end
