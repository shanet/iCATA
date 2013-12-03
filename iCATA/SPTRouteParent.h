//
//  SPTRouteParent.h
//  iCATA
//
//  Created by shane on 12/3/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SPTRouteParent : NSManagedObject

enum Type {
    GROUP = 0,
    CAMPUS = 1,
    COMMUNITY = 2
};

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *weight;

- (NSString*) getTypeName;
@end
