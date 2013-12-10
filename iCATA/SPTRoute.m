//
//  SPTBuilding.m
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoute.h"

@interface SPTRoute()
@property enum DownloadType downloadType;
@end

@implementation SPTRoute

@dynamic name;
@dynamic code;
@dynamic hexColor;
@dynamic type;
@dynamic weight;
@dynamic icon;

@synthesize stops;
@synthesize buses;
@synthesize color;
@synthesize routeKml;
@synthesize serverApiModel;
@synthesize delegate;

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    
    if(self) {
        self.stops = [[NSMutableArray alloc] init];
        self.buses = [[NSMutableArray alloc] init];
        self.color = nil;
        self.routeKml = nil;
        
        self.serverApiModel = [[SPTServerApiModel alloc] init];
        self.serverApiModel.delegate = self;
        self.delegate = nil;
    }
    
    return self;
}

- (void) downloadRouteData {
    [self.serverApiModel downloadDataForRoute:[self.id integerValue]];
}

- (void) downloadCompletedWithData:(NSData*)data {
    [self parseJson:[self.serverApiModel downloadedData]];
    [self.delegate routeDownloadComplete];
}

- (void) downloadCompletedWithError:(NSError*)error {
    [self.delegate routeDownloadError:error];
}

- (void) parseJson:(NSData*) data {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    [self parseJsonColor:[json objectForKey:@"Color"]];
    [self parseJsonStops:[json objectForKey:@"Stops"]];
    [self parseJsonBuses:[json objectForKey:@"Vehicles"]];
    
    [self downloadAndParseRouteKmlForFile:[json objectForKey:@"RouteTraceFilename"]];
}

- (void) downloadAndParseRouteKmlForFile:(NSString*)filename {
    // It would be nice to download the KML file with the server API model, but the KML parser doesn't like it when it isn't responsible for
    // pulling the KML file from the server
    self.routeKml = [KMLParser parseKMLAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/InfoPoint/Resources/Traces/%@", kServerHostname, filename]]];
}

- (void) parseJsonColor:(NSString*) colorString {
    self.color = [SPTImageUtils UIColorFromHexString:colorString];
}

- (void) parseJsonStops:(NSArray*) jsonStops {
    [self.stops removeAllObjects];
    
    for(NSDictionary *stop in jsonStops) {
        SPTRouteStop *routeStop = [[SPTRouteStop alloc] initWithDict:stop];
        [self.stops addObject:routeStop];
    }
}

- (void) parseJsonBuses:(NSArray*) jsonBuses {
    [self.buses removeAllObjects];
    
    for(NSDictionary *bus in jsonBuses) {
        SPTRouteBus *routeBus = [[SPTRouteBus alloc] initWithDict:bus];
        [self.buses addObject:routeBus];
    }
}

- (CLLocationCoordinate2D*) getBoundingBoxPoints {
    SPTRouteStop *firstStop = [self.stops objectAtIndex:0];
    
    CLLocationCoordinate2D *boundingBox = malloc(sizeof(CLLocationCoordinate2D) * 2);
    boundingBox[0] = CLLocationCoordinate2DMake(firstStop.latitude, firstStop.longitude);
    boundingBox[1] = CLLocationCoordinate2DMake(firstStop.latitude, firstStop.longitude);

    for(KMLPlacemark *placemark in [self.routeKml placemarks]) {
        // If the placemark is a single line, check if for min/max coordinates
        if([placemark.geometry isKindOfClass:[KMLLineString class]]) {
            for(KMLCoordinate *coordinate in ((KMLLineString*)placemark.geometry).coordinates) {
                [self checkBoundingBoxCoordinates:boundingBox ForCoordinate:coordinate];
            }
            
        // If the placemark contains multiple geometries, check each one for min/max coordinates individually
        } else if([placemark.geometry isKindOfClass:[KMLMultiGeometry class]]) {
            KMLMultiGeometry *multiGeo = (KMLMultiGeometry*)[placemark geometry];
            
            for(KMLAbstractGeometry *geometry in multiGeo.geometries) {
                for(KMLCoordinate *coordinate in ((KMLLineString*)geometry).coordinates) {
                    [self checkBoundingBoxCoordinates:boundingBox ForCoordinate:coordinate];
                }
            }
        }
    }

    return boundingBox;
}

- (void) checkBoundingBoxCoordinates:(CLLocationCoordinate2D*)boundingBox ForCoordinate:(KMLCoordinate*)coordinate {
    // Max latitude
    if(coordinate.latitude > boundingBox[1].latitude) {
        boundingBox[1].latitude = coordinate.latitude;
    // Min latitude
    } else if(coordinate.latitude < boundingBox[0].latitude) {
        boundingBox[0].latitude = coordinate.latitude;
    }
    
    // Max longitude
    if(coordinate.longitude > boundingBox[1].longitude) {
        boundingBox[1].longitude = coordinate.longitude;
    // Min longitude
    } else if(coordinate.longitude < boundingBox[0].longitude) {
        boundingBox[0].longitude = coordinate.longitude;
    }
}

- (void) addKmlLineToMap:(KMLLineString*)kmlLine {
    for(KMLCoordinate *coordinate in kmlLine.coordinates) {
        //coordinate.latitude, coordinate.longitude
    }
}

- (SPTRouteStop*) getClosestStopToCoordinate:(CLLocationCoordinate2D)coordinate {
    float minDistance = FLT_MAX;
    SPTRouteStop *closestStop = [self.stops objectAtIndex:0];
    
    for(SPTRouteStop *stop in self.stops) {
        // Find the distance between the current stop and the given coordinate via the distance formula
        float distance = sqrtf(powf(stop.latitude - coordinate.latitude, 2) + powf(stop.longitude - coordinate.longitude, 2));

        if(distance < minDistance) {
            minDistance = distance;
            closestStop = stop;
        }
    }
    
    return closestStop;
}

@end
