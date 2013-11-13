//
//  SPTRouteStopsModel.h
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPTRouteStopsModel : NSObject
@property (strong, nonatomic) NSString *data;

- (id) initWithRouteCode:(NSString*) routeCode;
- (void) downloadStopsForRoute;
@end
