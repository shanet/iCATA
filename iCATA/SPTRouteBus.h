//
//  SPTRouteBus.h
//  iCATA
//
//  Created by shane on 11/17/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPTRouteBus : NSObject
@property float latitude;
@property float longitude;

- (id) initWithDict:(NSDictionary*) dict;
@end
