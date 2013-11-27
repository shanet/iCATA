//
//  SPTBuilding.m
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoute.h"

// This is the new API currently in testing. This IP is expected to change to a domain sometime in the future.
// This constant will need updated at that time.
#define kDataUrl "http://50.203.43.19"

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SPTRoute ()
enum XmlType {
    STOPS = 1,
    BUSES = 2
};

@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@end

@implementation SPTRoute

@dynamic name;
@dynamic code;
@dynamic routeId;
@dynamic hexColor;
@dynamic type;
@dynamic weight;
@dynamic icon;

@synthesize stops;
@synthesize buses;
@synthesize color;
@synthesize downloadQueue;
@synthesize routeKml;

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    
    if(self) {
        self.stops = [[NSMutableArray alloc] init];
        self.buses = [[NSMutableArray alloc] init];
        self.color = nil;
        self.downloadQueue = nil;
        self.routeKml = nil;
    }
    
    return self;
}

- (NSString*) getRouteTypeName {
    return ([self.type integerValue] == CAMPUS ? @"Campus" : @"Community");
}

- (void) downloadRouteStops {
    [self downloadJsonAtUrl:[NSString stringWithFormat:@"%s/InfoPoint/rest/RouteDetails/Get/%d", kDataUrl, [self.routeId integerValue]]];
}

- (void) downloadBusLocations {
    [self downloadJsonAtUrl:[NSString stringWithFormat:@"%s/InfoPoint/map/GetVehicleXml.ashx?RouteId=%@", kDataUrl, self.code]];
}

- (void) downloadJsonAtUrl:(NSString*) url {
    NSURL *_url = [NSURL URLWithString:url];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:_url];
    self.downloadQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.downloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            // TODO: handle errors
        } else {
            [self parseJson:data];
        }
    }];
}

- (void) parseJson:(NSData*) data {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    [self parseJsonColor:[json objectForKey:@"Color"]];
    [self parseJsonStops:[json objectForKey:@"Stops"]];
    [self parseJsonBuses:[json objectForKey:@"Vehicles"]];
    
    [self downloadAndParseRouteKmlAtUrl:[json objectForKey:@"RouteTraceFilename"]];
    
    [self performSelectorOnMainThread:@selector(notifyRouteDownloadComplete) withObject:nil waitUntilDone:NO];
}

- (void) parseJsonColor:(NSString*) colorString {
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    NSUInteger _hexColor;
    [scanner scanHexInt:&_hexColor];
    self.color = UIColorFromRGB(_hexColor);
}

- (void) parseJsonStops:(NSArray*) jsonStops {
    for(NSDictionary *stop in jsonStops) {
        SPTRouteStop *routeStop = [[SPTRouteStop alloc] initWithDict:stop];
        [self.stops addObject:routeStop];
    }
}

- (void) parseJsonBuses:(NSArray*) jsonBuses {
    for(NSDictionary *bus in jsonBuses) {
        SPTRouteBus *routeBus = [[SPTRouteBus alloc] initWithDict:bus];
        [self.buses addObject:routeBus];
    }
}

- (void) downloadAndParseRouteKmlAtUrl:(NSString*) url {
    NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:@"%s/InfoPoint/Resources/Traces/%@", kDataUrl, url]];
    self.routeKml = [KMLParser parseKMLAtURL:_url];
}

- (void) notifyRouteDownloadComplete {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RouteDownloadCompleted" object:self];
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

@end
