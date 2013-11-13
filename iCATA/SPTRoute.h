//
//  SPTBuilding.h
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum RouteType {
  CAMPUS = 1,
  COMMUNITY = 2
};
    
@interface SPTRoute : NSManagedObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *weight;
@property (strong, nonatomic) NSData *icon;

- (UIImage*) getIconImage;
- (NSString*) getRouteTypeName;
@end
