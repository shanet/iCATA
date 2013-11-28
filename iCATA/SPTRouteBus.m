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
        
        // Translate the direction to a human-readable direction
        NSString *direction = [dict objectForKey:@"Direction"];
        if([direction compare:@"L"] == 0) {
            _direction = @"Loop";
        } else if([direction compare:@"O"] == 0) {
            _direction = @"Outbound";
        } else if([direction compare:@"I"] == 0) {
            _direction = @"Inbound";
        } else {
            _direction = @"Link";
        }
    }
    
    return self;
}

@end
