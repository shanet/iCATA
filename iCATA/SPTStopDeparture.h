//
//  SPTStopDeparture.h
//  iCATA
//
//  Created by shane on 12/9/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"

@class SPTRoute;

@interface SPTStopDeparture : NSObject
@property (strong, nonatomic) SPTRoute *route;
@property (strong, nonatomic) NSDate *scheduledDepartureTime;
@property (strong, nonatomic) NSObject *estimatedDepartureTime;
@property bool isLoop;

- (id) initWithDict:(NSDictionary*)dict;
@end
