//
//  SPTPrefsModel.m
//  PSU Directory Search
//
//  Created by shane on 10/11/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTPrefsModel.h"

@interface SPTPrefsModel ()
@property (strong, nonatomic) NSUserDefaults *prefs;
@end

@implementation SPTPrefsModel
NSString* const kShowGroupsByDefaultKey = @"showGroupsByDefault";
NSString* const kHighlightClosestStopKey = @"highlightClosestStop";
NSString* const kDefaultRouteIdKey = @"defaultRouteId";

-(id) init {
    self = [super init];
    
    if(self) {
        _prefs = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (BOOL) readBoolPrefForKey:(NSString*)key {
    return [self.prefs boolForKey:key];
}

- (NSInteger) readIntPrefForKey:(NSString*)key {
    return [self.prefs integerForKey:key];
}

- (void) writeBoolPref:(BOOL)pref ForKey:(NSString*)key {
    [self.prefs setBool:pref forKey:key];
    [self.prefs synchronize];
}

- (void) writeIntPref:(NSInteger)pref ForKey:(NSString*)key {
    [self.prefs setInteger:pref forKey:key];
    [self.prefs synchronize];
}

@end
