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
        _latitude = [[dict objectForKey:@"lat"] floatValue];
        _longitude = [[dict objectForKey:@"lng"] floatValue];
    }
    
    return self;
}

@end
