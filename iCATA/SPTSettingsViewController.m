//
//  SPTSettingsViewController.m
//  iCATA
//
//  Created by shane on 11/28/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTSettingsViewController.h"

@interface SPTSettingsViewController ()
@property (strong, nonatomic) SPTPrefsModel *prefsModel;

@property (weak, nonatomic) IBOutlet UILabel *defaultRouteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showGroupsByDefaultSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *highlightClosestStopSwitch;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)closestStopSwitchToggled:(id)sender;
- (IBAction)showGroupsSwitchToggled:(id)sender;
@end

@implementation SPTSettingsViewController
NSString* const kNoDefaultRouteText = @"None set";

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _prefsModel = [[SPTPrefsModel alloc] init];
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the show groups by default switch to the right state
    [self.showGroupsByDefaultSwitch setOn:[self.prefsModel readBoolPrefForKey:kShowGroupsByDefaultKey] animated:NO];

    // Set the highlight closest stop switch to the right state
    [self.highlightClosestStopSwitch setOn:[self.prefsModel readBoolPrefForKey:kHighlightClosestStopKey] animated:NO];

    // Set the default route label
    NSInteger defaultRouteId = [self.prefsModel readIntPrefForKey:kDefaultRouteIdKey];
    
    if(defaultRouteId == kNoDefaultRoute) {
        self.defaultRouteLabel.text = kNoDefaultRouteText;
    } else {
        // Fetch the route with the given route ID from the database and set its name as the default route label text
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeId == %d", defaultRouteId];
        NSArray *routes = [[DataManager sharedInstance] fetchManagedObjectsForEntity:@"Route" sortKeys:nil predicate:predicate];
        
        if([routes count] == 1) {
            SPTRoute *selectedRoute = [routes objectAtIndex:0];
            self.defaultRouteLabel.text = [NSString stringWithFormat:@"%@ - %@", selectedRoute.code, selectedRoute.name];
        }
    }
}

- (IBAction) doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) closestStopSwitchToggled:(id)sender {
    [self.prefsModel writeBoolPref:[(UISwitch*)sender isOn] ForKey:kHighlightClosestStopKey];
}

- (IBAction)showGroupsSwitchToggled:(id)sender {
    // Since a group can't be set as default, remove the default route when selecting to show the groups by default
    [self.prefsModel writeBoolPref:[(UISwitch*)sender isOn] ForKey:kShowGroupsByDefaultKey];
    [self.prefsModel writeIntPref:kNoDefaultRoute ForKey:kDefaultRouteIdKey];
    self.defaultRouteLabel.text = kNoDefaultRouteText;
}

@end
