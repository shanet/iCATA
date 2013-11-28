//
//  SPTSettingsViewController.m
//  iCATA
//
//  Created by shane on 11/28/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTSettingsViewController.h"

@interface SPTSettingsViewController ()
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)closedStopSwitchToggled:(id)sender;

@end

@implementation SPTSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {}
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closedStopSwitchToggled:(id)sender {
}
@end
