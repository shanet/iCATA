//
//  SPTBuilding.h
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <KML/KML.h>
#import "SPTRouteStop.h"
#import "SPTRouteBus.h"

enum RouteType {
  CAMPUS = 1,
  COMMUNITY = 2
};
    
@interface SPTRoute : NSManagedObject <NSXMLParserDelegate>
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSNumber *routeId;
@property (strong, nonatomic) NSString *hexColor;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *weight;
@property (strong, nonatomic) NSData *icon;

@property (strong, nonatomic) NSMutableArray *stops;
@property (strong, nonatomic) NSMutableArray *buses;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) KMLRoot *routeKml;

- (UIImage*) getIconImage;
- (NSString*) getRouteTypeName;
- (void) downloadRouteStops;
- (void) downloadBusLocations;
@end
