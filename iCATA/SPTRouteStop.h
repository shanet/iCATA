//
//  SPTRouteStopsModel.h
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPTRouteStop : NSObject
@property float latitude;
@property float longitude;
@property (strong, nonatomic) NSString *name;
@property NSInteger order;

- (id) initWithDict:(NSDictionary*) dict;
@end
