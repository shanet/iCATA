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
        _latitude = [[dict objectForKey:@"Latitude"] floatValue];
        _longitude = [[dict objectForKey:@"Longitude"] floatValue];
        _name = [dict objectForKey:@"Name"];
        _stopId = [[dict objectForKey:@"StopId"] integerValue];
    }
    
    return self;
}


@end
