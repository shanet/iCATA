//
//  SPTBuilding.m
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoute.h"

@interface SPTRoute ()
enum XmlType {
    STOPS = 1,
    BUSES = 2
};

@property NSInteger currentXml;
@property (strong, nonatomic) NSString *routeKmlUrl;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@end

@implementation SPTRoute

@dynamic name;
@dynamic code;
@dynamic type;
@dynamic weight;
@dynamic icon;

@synthesize stops;
@synthesize buses;
@synthesize downloadQueue;
@synthesize currentXml;
@synthesize routeKmlUrl;
@synthesize routeKml;

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    
    if(self) {
        self.stops = [[NSMutableArray alloc] init];
        self.buses = [[NSMutableArray alloc] init];
        self.downloadQueue = nil;
        self.currentXml = 0;
        self.routeKmlUrl = nil;
        self.routeKml = nil;
    }
    
    return self;
}

- (UIImage*) getIconImage {
    return [[UIImage alloc] initWithData:self.icon];
}

- (NSString*) getRouteTypeName {
    return ([self.type integerValue] == CAMPUS ? @"Campus" : @"Community");
}

- (void) downloadRouteStops {
    self.currentXml = STOPS;
    [self downloadXmlAtUrl:[NSString stringWithFormat:@"http://realtime.catabus.com/InfoPoint/map/GetRouteXml.ashx?RouteId=%@", self.code]];
}

- (void) downloadBusLocations {
    self.currentXml = BUSES;
    [self downloadXmlAtUrl:[NSString stringWithFormat:@"http://realtime.catabus.com/InfoPoint/map/GetVehicleXml.ashx?RouteId=%@", self.code]];
}

- (void) downloadXmlAtUrl:(NSString*) url {
    NSURL *_url = [NSURL URLWithString:url];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:_url];
    self.downloadQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.downloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            // TODO: handle errors
        } else {
            [self parseXml:data];
        }
    }];
}

- (void) parseXml:(NSData*) data {
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    xmlParser.delegate = self;
    [xmlParser parse];
}

- (void) notifyRouteStopsDownloadComplete {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RouteStopsDownloadCompleted" object:self];
}

- (void) notifyRouteBusesDownloadComplete {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RouteBusesDownloadCompleted" object:self];
}

- (void) parserDidStartDocument:(NSXMLParser *)parser {}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    // Send the notifcation that the requested XML has been downloaded and parsed
    if(self.currentXml == STOPS) {
        // Once the stops are downloaded and parsed, the route KML must be downloaded and parsed. Then when that's done
        // we can send the notification that the route stops are ready
        [self downloadAndParseRouteKml];
        
        [self performSelectorOnMainThread:@selector(notifyRouteStopsDownloadComplete) withObject:nil waitUntilDone:NO];
    } else if(self.currentXml == BUSES) {
        [self performSelectorOnMainThread:@selector(notifyRouteBusesDownloadComplete) withObject:nil waitUntilDone:NO];
    }
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // If the element is a stop or vehicle, add it to the stops or buses array
    if([elementName compare:@"stop"] == 0) {
        SPTRouteStop *routeStop = [[SPTRouteStop alloc] initWithDict:attributeDict];
        [self.stops addObject:routeStop];
    } else if([elementName compare:@"vehicle"] == 0) {
        SPTRouteBus *routeBus = [[SPTRouteBus alloc] initWithDict:attributeDict];
        [self.buses addObject:routeBus];
    } else if([elementName compare:@"info"] == 0) {
        self.routeKmlUrl = [attributeDict objectForKey:@"trace_kml_url"];
    }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {}

- (void) downloadAndParseRouteKml {
    self.routeKml = [KMLParser parseKMLAtURL:[NSURL URLWithString:self.routeKmlUrl]];
}

@end
