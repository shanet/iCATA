//
//  SPTStopDeparture.m
//  iCATA
//
//  Created by shane on 12/9/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTStopDeparture.h"

#define kJsonDateSubstringStartIndex 6
#define kJsonDateSubstringLength 10

@implementation SPTStopDeparture

- (id) initWithDict:(NSDictionary*)dict {
    self = [super init];
    
    if(self) {
        // Get the route with the given route ID from the database
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [dict objectForKey:@"routeId"]];
        NSArray *routes = [[DataManager sharedInstance] fetchManagedObjectsForEntity:@"Route" sortKeys:nil predicate:predicate];
        _route = [routes objectAtIndex:0];
        
        // Estimated and scheduled times are for all routes except loops
        NSObject *scheduledDepartureTime = [dict objectForKey:@"scheduledDepartureTime"];
        NSObject *estimatedDepartureTime = [dict objectForKey:@"estimatedDepartureTime"];
        NSObject *loopNextDeparture = [dict objectForKey:@"loopNextDeparture"];
        
        if(![scheduledDepartureTime isKindOfClass:[NSNull class]] && ![estimatedDepartureTime isKindOfClass:[NSNull class]]) {
            // Parse the JSON dates to NSDate objects
            _scheduledDepartureTime = [SPTStopDeparture JSONDateToNSDate:(NSString*)scheduledDepartureTime];
            _estimatedDepartureTime = [SPTStopDeparture JSONDateToNSDate:(NSString*)estimatedDepartureTime];
            _isLoop = NO;
        } else if(![loopNextDeparture isKindOfClass:[NSNull class]]) {
            // The loops are already in a human-readable format and change to "Due" when a bus is approaching so don't try to convert it to an NSDate object
            _estimatedDepartureTime = loopNextDeparture;
            _isLoop = YES;
        }
    }
    
    return self;
}

+ (NSDate*) JSONDateToNSDate:(NSString*)jsonDate {
    long long unixTime = [[jsonDate substringWithRange:NSMakeRange(kJsonDateSubstringStartIndex, kJsonDateSubstringLength)] longLongValue];
    return [NSDate dateWithTimeIntervalSince1970:unixTime];
}
@end
