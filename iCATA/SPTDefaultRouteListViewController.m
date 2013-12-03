//
//  SPTDefaultRouteListViewController.m
//  iCATA
//
//  Created by shane on 11/28/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTDefaultRouteListViewController.h"

@interface SPTDefaultRouteListViewController ()
@property (strong, nonatomic) SPTRoutesModel *routesModel;
@property (strong, nonatomic) SPTPrefsModel *prefsModel;
@property (strong, nonatomic) DataSource *dataSource;

- (IBAction) cancelButtonPressed:(id)sender;
- (IBAction) deletedButtonPressed:(id)sender;
@end

@implementation SPTDefaultRouteListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _routesModel = [[SPTRoutesModel alloc] init];
        _prefsModel = [[ SPTPrefsModel alloc] init];
        
        _dataSource = [[DataSource alloc] initForEntity:@"Route" sortKeys:@[@"type", @"weight"] predicate:nil sectionNameKeyPath:@"type" dataManagerDelegate:_routesModel];
        _dataSource.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    self.dataSource.tableView = self.tableView;
}


-(UITableViewCell*) configureCell:(UITableViewCell*)cell withObject:(id)object {
    // Set the code and name of the route as the text on the cell and the route icon
    SPTRoute *route = (SPTRoute*) object;
    
    ((UILabel*)[cell viewWithTag:1]).text = route.code;
    ((UILabel*)[cell viewWithTag:2]).text = route.name;
    ((UIImageView*)[cell viewWithTag:3]).image = [UIImage imageWithData:route.icon];
    
    return cell;
}

-(NSString *) cellIdentifierForObject:(id)object {
    return @"cell";
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Save the route ID in the prefs on cell selection
    SPTRoute *selectedRoute = [self.dataSource objectAtIndexPath:indexPath];
    [self.prefsModel writeIntPref:[selectedRoute.routeId integerValue] ForKey:kDefaultRouteIdKey];
    
    // Since a group cannot be selected as default, when a route is selected as default, turn off the show groups by default pref
    [self.prefsModel writeBoolPref:NO ForKey:kShowGroupsByDefaultKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) deletedButtonPressed:(id)sender {
    // Clear the default route by setting the route Id pref as the code for no default route
    [self.prefsModel writeIntPref:kNoDefaultRoute ForKey:kDefaultRouteIdKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
