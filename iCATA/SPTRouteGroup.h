//
//  SPTRouteGroup.h
//  iCATA
//
//  Created by shane on 11/21/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SPTRouteGroup : NSManagedObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *routes;
@end
