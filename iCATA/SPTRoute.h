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
#import "SPTImageUtils.h"
#import "SPTRouteParent.h"
 
@interface SPTRoute : SPTRouteParent
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *hexColor;
@property (strong, nonatomic) NSData *icon;

@property (strong, nonatomic) NSMutableArray *stops;
@property (strong, nonatomic) NSMutableArray *buses;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) KMLRoot *routeKml;

@property (strong, nonatomic) NSError *downloadError;

- (void) downloadRouteData;
- (CLLocationCoordinate2D*) getBoundingBoxPoints;
- (SPTRouteStop*) getClosestStopToCoordinate:(CLLocationCoordinate2D)coordinate;
@end
