//
//  SPTRouteStopsModel.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRouteStop.h"

@implementation SPTRouteStop

- (id) initWithDict:(NSDictionary*) dict {
    self = [super init];
    
    if(self) {
        _latitude = [[dict objectForKey:@"lat"] floatValue];
        _longitude = [[dict objectForKey:@"lng"] floatValue];
        _name = [dict objectForKey:@"label"];
        _order = [[dict objectForKey:@"html"] integerValue];
    }
    
    return self;
}


@end
