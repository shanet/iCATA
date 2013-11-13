//
//  SPTBuilding.m
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoute.h"

@implementation SPTRoute

@dynamic name;
@dynamic code;
@dynamic type;
@dynamic weight;
@dynamic icon;

- (UIImage*) getIconImage {
    return [[UIImage alloc] initWithData:self.icon];
}

- (NSString*) getRouteTypeName {
    return ([self.type integerValue] == CAMPUS ? @"Campus" : @"Community");
}

@end
