//
//  SPTRouteBus.m
//  iCATA
//
//  Created by shane on 11/17/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRouteBus.h"

@implementation SPTRouteBus

- (id) initWithDict:(NSDictionary*) dict {
    self = [super init];
    
    if(self) {
        _latitude = [[dict objectForKey:@"Latitude"] floatValue];
        _longitude = [[dict objectForKey:@"Longitude"] floatValue];
        _heading = [[dict objectForKey:@"Heading"] integerValue];
        _speed = [[dict objectForKey:@"Speed"] integerValue];
        _riderCount = [[dict objectForKey:@"OnBoard"] integerValue];
        _status = [dict objectForKey:@"DisplayStatus"];
        _direction = [dict objectForKey:@"DirectionLong"];
    }
    
    return self;
}

@end
