//
//  SPTRouteParent.m
//  iCATA
//
//  Created by shane on 12/3/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRouteParent.h"

@implementation SPTRouteParent
@dynamic id;
@dynamic name;
@dynamic type;
@dynamic weight;

- (NSString*) getTypeName {
    switch([self.type integerValue]) {
        case GROUP:
            return @"Groups";
        case CAMPUS:
            return @"Campus";
        case COMMUNITY:
            return @"Community";
        default:
            return nil;
    }
}
@end
