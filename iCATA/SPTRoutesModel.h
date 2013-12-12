//
//  SPTBuildingsModel.h
//  PSU Directory Search
//
//  Created by shane on 10/5/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTRoute.h"
#import "SPTRouteGroup.h"
#import "SPTImageUtils.h"
#import "DataManager.h"
#import "DataManagerDelegate.h"

@interface SPTRoutesModel : NSObject <DataManagerDelegate>
- (SPTRoute*) getRouteWithId:(NSNumber*)routeId;

+ (void) addGroupToDatabase:(NSDictionary*)dict;
@end
