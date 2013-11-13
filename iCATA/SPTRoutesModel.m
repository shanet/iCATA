//
//  SPTBuildingsModel.m
//  PSU Directory Search
//
//  Created by shane on 10/5/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoutesModel.h"

@implementation SPTRoutesModel

- (NSString*) xcDataModelName {
    return @"Routes";
}

- (void) createDatabaseFor:(DataManager *)dataManager {
    NSString *routesPlistPath = [[NSBundle mainBundle]pathForResource:@"routes" ofType:@"plist"];
    NSArray *routes = [NSArray arrayWithContentsOfFile:routesPlistPath];
    
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
    for (NSDictionary *dict in routes) {
        SPTRoute *route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:managedObjectContext];
        
        route.name = [dict objectForKey:@"name"];
        route.code = [dict objectForKey:@"code"];
        route.type = [dict objectForKey:@"type"];
        route.weight = [dict objectForKey:@"weight"];
                
        //UIImage *routeIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [dict objectForKey:@"icon"]]];
        UIImage *routeIcon = [UIImage imageNamed:@"tmp_icon.png"];
        route.icon = UIImagePNGRepresentation(routeIcon);
    }
    
    [dataManager saveContext];
}

@end
