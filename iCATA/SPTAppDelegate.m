//
//  SPTAppDelegate.m
//  iCATA
//
//  Created by shane on 10/25/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "SPTAppDelegate.h"
#import "Reachability.h"

@implementation SPTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set the Google Maps API key
    [GMSServices provideAPIKey:@"AIzaSyCe-p2VUD2DtwDF_cdITm4x5fO4SmOZPnc"];
    
    // Set the default prefs
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [prefs registerDefaults:defaultPreferences];
    
    // Check for an active internet connection even though Google Maps apparently crashes the app if there is no connection
    // At least a warning dialog will tell the user that something isn't right
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
                                                        message:@"An active internet connection is necessary to retrieve bus information, but none was found."
                                                       delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        
        [alert show];
    }        
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

@end
