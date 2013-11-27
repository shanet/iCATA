//
//  SPTCreateGroupViewController.m
//  iCATA
//
//  Created by shane on 11/21/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTCreateGroupViewController.h"

@interface SPTCreateGroupViewController ()
@property (strong, nonatomic) NSMutableArray *selectedRoutes;
@property (strong, nonatomic) SPTRoutesModel *routesModel;
@property (strong, nonatomic) DataSource *dataSource;

@property (strong, nonatomic) UIAlertView *groupNameAlert;
@property (strong, nonatomic) UIAlertView *noNameAlert;

- (IBAction)doneButtonPressed:(id)sender;
@end

@implementation SPTCreateGroupViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _routesModel = [[SPTRoutesModel alloc] init];
        _selectedRoutes = [[NSMutableArray alloc] init];
        
        _dataSource = [[DataSource alloc] initForEntity:@"Route" sortKeys:@[@"type", @"weight"] predicate:nil sectionNameKeyPath:@"type" dataManagerDelegate:_routesModel];
        _dataSource.delegate = self;
        
        _groupNameAlert = [[UIAlertView alloc] initWithTitle:@"Enter Group Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        _groupNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        _noNameAlert = [[UIAlertView alloc] initWithTitle:@"No Name entered" message:@"You must enter a group name" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    self.dataSource.tableView = self.tableView;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void) configureCell:(UITableViewCell*)cell withObject:(id)object {
    // Set the code and name of the route as the text on the cell and the route icon
    SPTRoute *route = (SPTRoute*) object;
    
    ((UILabel*)[cell viewWithTag:1]).text = route.code;
    ((UILabel*)[cell viewWithTag:2]).text = route.name;
    ((UIImageView*)[cell viewWithTag:3]).image = [UIImage imageWithData:route.icon];
    
    // If the route is selected, set the accessory type as a checkmark
    if([self.selectedRoutes containsObject:route]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(NSString *) cellIdentifierForObject:(id)object {
    return @"cell";
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    SPTRoute *selectedRoute = [self.dataSource objectAtIndexPath:indexPath];
    
    // If the cell is already selected (its accessory is a checkmark), remove it
    // Otherwise, set the accessory as a checkmark
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedRoutes removeObject:selectedRoute];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedRoutes addObject:selectedRoute];
    }
    
    [cell setSelected:NO animated:TRUE];
}


- (IBAction)doneButtonPressed:(id)sender {
    // Show the group name dialog if routes were selected
    if([self.selectedRoutes count] > 0) {
        [self.groupNameAlert show];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // If this dialog is the no group name alert dialog, show the group name dialog
    if(alertView == self.noNameAlert) {
        [self.groupNameAlert show];
        return;
    }
    
    // Create and insert the group if the save button was clicked
    if(buttonIndex == [alertView firstOtherButtonIndex]) {
        // Check that a name was provided
        NSString *name = [[alertView textFieldAtIndex:0] text];
        if([name length] == 0) {
            [self.noNameAlert show];
            return;
        }
        
        // Create a new group from the selected routes and insert it into the database
        [SPTRoutesModel addGroupToDatabase:@{@"name": name, @"routes":self.selectedRoutes}];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
