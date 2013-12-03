//
//  SPTRouteGroup.h
//  iCATA
//
//  Created by shane on 11/21/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SPTRouteParent.h"

@interface SPTRouteGroup : SPTRouteParent
@property (strong, nonatomic) NSMutableArray *routes;
@end
