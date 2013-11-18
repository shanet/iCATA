//
//  SPTAppDelegate.m
//  iCATA
//
//  Created by shane on 10/25/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation SPTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set the Google Maps API key
    [GMSServices provideAPIKey:@"AIzaSyCe-p2VUD2DtwDF_cdITm4x5fO4SmOZPnc"];
    
    // Set the default prefs
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [prefs registerDefaults:defaultPreferences];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

@end
