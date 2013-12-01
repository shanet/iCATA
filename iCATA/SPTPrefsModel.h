//
//  SPTPrefsModel.h
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNoDefaultRoute -1

@interface SPTPrefsModel : NSObject
FOUNDATION_EXPORT NSString* const kShowGroupsByDefaultKey;
FOUNDATION_EXPORT NSString* const kHighlightClosestStopKey;
FOUNDATION_EXPORT NSString* const kDefaultRouteIdKey;

- (BOOL) readBoolPrefForKey:(NSString*)key;
- (NSInteger) readIntPrefForKey:(NSString*)key;

- (void) writeBoolPref:(BOOL)pref ForKey:(NSString*)key;
- (void) writeIntPref:(NSInteger)pref ForKey:(NSString*)key;
@end
