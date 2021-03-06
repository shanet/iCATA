//
//  SPTBuildingsModel.m
//  PSU Directory Search
//
//  Created by shane on 10/5/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoutesModel.h"

#define kGroupsStartingId 1000

@interface SPTRoutesModel()
@property (strong, nonatomic) NSMutableArray *routes;
@end

@implementation SPTRoutesModel

- (id) init {
    self = [super init];
    
    if(self) {
        _routes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString*) xcDataModelName {
    return @"Routes";
}

- (void) createDatabaseFor:(DataManager*)dataManager {
    // Inflate the routes and groups plist's into objects to be inserted into the database
    [self inflateRoutesPlistWithDataManager:dataManager];
    [self inflateRouteGroupsPlistWithDataManager:dataManager];
    
    [dataManager saveContext];
}

- (void) inflateRoutesPlistWithDataManager:(DataManager*)dataManager {
    NSString *routesPlistPath = [[NSBundle mainBundle]pathForResource:@"routes" ofType:@"plist"];
    NSArray *routesPlist = [NSArray arrayWithContentsOfFile:routesPlistPath];
        
    for(NSDictionary *dict in routesPlist) {
        SPTRoute *route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:dataManager.managedObjectContext];
        
        route.name = [dict objectForKey:@"name"];
        route.code = [dict objectForKey:@"code"];
        route.id = [dict objectForKey:@"routeId"];
        route.hexColor = [dict objectForKey:@"color"];
        route.type = [dict objectForKey:@"type"];
        route.weight = [dict objectForKey:@"weight"];
        
        // Tint the icon according to the color of the route
        UIColor *tintColor = [SPTImageUtils UIColorFromHexString:[dict objectForKey:@"color"]];
        UIImage *routeIcon = [UIImage imageNamed:@"routeIcon@2x.png"];
        route.icon = UIImagePNGRepresentation([SPTImageUtils tintImage:routeIcon withColor:tintColor]);
        
        [self.routes addObject:route];
    }
}

- (void) inflateRouteGroupsPlistWithDataManager:(DataManager*)dataManager {
    NSString *groupsPlistPath = [[NSBundle mainBundle]pathForResource:@"groups" ofType:@"plist"];
    NSArray *groupsPlist = [NSArray arrayWithContentsOfFile:groupsPlistPath];
    
    NSInteger currentId = kGroupsStartingId;
    for(NSDictionary *dict in groupsPlist) {
        SPTRouteGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:dataManager.managedObjectContext];
        
        group.name = [dict objectForKey:@"name"];
        group.id = [NSNumber numberWithInteger:currentId];
        group.type = GROUP;
        group.weight = [dict objectForKey:@"weight"];
        
        for(NSNumber *routeId in [dict objectForKey:@"routes"]) {
            SPTRoute *route = [self getRouteWithId:routeId];
            if(route != nil) {
                [group.routes addObject:route];
            }
        }
        
        currentId++;
    }
}

- (SPTRoute*) getRouteWithId:(NSNumber*)routeId {
    for(SPTRoute *route in self.routes) {
        if([routeId isEqualToNumber:route.id]) {
            return route;
        }
    }
    
    return nil;
}

+ (void) addGroupToDatabase:(NSDictionary*)dict {
    DataManager *dataManager = [DataManager sharedInstance];
    
    // Find the heaviest weight already being used
    NSArray *routeGroups = [dataManager fetchManagedObjectsForEntity:@"Group" sortKeys:nil predicate:nil];
    NSNumber *heaviestWeight = ((SPTRouteGroup*)[routeGroups objectAtIndex:[routeGroups count]-1]).weight;
    
    SPTRouteGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:dataManager.managedObjectContext];
    
    group.name = [dict objectForKey:@"name"];
    group.weight = [NSNumber numberWithInteger:[heaviestWeight integerValue] +1];
    
    for(SPTRoute *route in [dict objectForKey:@"routes"]) {
        [group.routes addObject:route];
    }
    
    [dataManager saveContext];
}

@end
