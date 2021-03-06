//
//  SPTGroupsListViewController.m
//  iCATA
//
//  Created by shane on 11/21/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTGroupsListViewController.h"

#define kSearchOptionContains 0
#define kSearchOptionExclude  1
#define kSearchOptionMatch    2

@interface SPTGroupsListViewController ()
@property (strong, nonatomic) SPTRoutesModel *routesModel;
@property (strong, nonatomic) DataSource *dataSource;

@property (strong, nonatomic) NSString *searchString;
@property NSInteger searchOption;
@end

@implementation SPTGroupsListViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _routesModel = [[SPTRoutesModel alloc] init];
        
        _dataSource = [[DataSource alloc] initForEntity:@"Group" sortKeys:@[@"weight", @"name"] predicate:nil sectionNameKeyPath:nil dataManagerDelegate:_routesModel];
        _dataSource.delegate = self;
        
        _searchString = nil;
        _searchOption = 0;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    self.dataSource.tableView = self.tableView;
    
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, self.editButtonItem];
    
    // Set the search options and provide the search controller with a data source
    self.searchDisplayController.searchBar.scopeButtonTitles = @[@"Contains", @"Exclude", @"Match"];
    self.searchDisplayController.searchResultsDataSource = self.dataSource;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(UITableViewCell*) configureCell:(UITableViewCell*)cell withObject:(id)object {
    // Set the text of the cell as the group name
    SPTRouteGroup *group = (SPTRouteGroup*) object;
    cell.textLabel.text = group.name;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(NSString *) cellIdentifierForObject:(id)object {
    return @"cell";
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    SPTRouteGroup *source = [self.dataSource objectAtIndexPath:sourceIndexPath];
    SPTRouteGroup *destination = [self.dataSource objectAtIndexPath:destinationIndexPath];
    
    NSNumber *tmpWeight = source.weight;
    source.weight = destination.weight;
    destination.weight = tmpWeight;
    
    [self.tableView reloadData];
    [[DataManager sharedInstance] saveContext];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If a cell in the search results table was selected, fire a show map info segue
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"ShowMapSegue" sender:indexPath];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Give each route in the selected group to the map controller
    if([segue.identifier isEqualToString:@"ShowMapSegue"]) {
        NSIndexPath *indexPath;
        if([sender isKindOfClass:[NSIndexPath class]]) {
            indexPath = (NSIndexPath*)sender;
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        SPTRouteGroup *group = [self.dataSource objectAtIndexPath:indexPath];
        
        SPTMapViewController *mapController = segue.destinationViewController;
        mapController.groupName = group.name;
        for(SPTRoute *route in group.routes) {
            [mapController addRoute:route];
        }
    }
}

- (BOOL) searchDisplayController:(UISearchDisplayController*) searchController shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchString = searchString;
    [self applySearchFilter];
    return YES;
}

- (BOOL) searchDisplayController:(UISearchDisplayController*)searchController shouldReloadTableForSearchScope:(NSInteger)searchOption {
    self.searchOption = searchOption;
    [self applySearchFilter];
    return YES;
}

- (void) applySearchFilter {
    NSString *predicateSearchFormat;
    switch(self.searchOption) {
        case kSearchOptionContains:
            predicateSearchFormat = [NSString stringWithFormat:@"ANY name CONTAINS[c] '%@'", self.searchString];
            break;
        case kSearchOptionExclude:
            predicateSearchFormat = [NSString stringWithFormat:@"!(ANY name CONTAINS[c] '%@')", self.searchString];
            break;
        case kSearchOptionMatch:
            predicateSearchFormat = [NSString stringWithFormat: @"ANY name LIKE[c] '%@'", self.searchString];
            break;
        default:
            return;
    }
    
    [self.dataSource updateWithPredicate:[NSPredicate predicateWithFormat:predicateSearchFormat]];
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController*)searchController {
    // When the search beings, swap the datasource tableview with the search tableview
    self.dataSource.tableView = searchController.searchResultsTableView;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController*)searchController {
    // When the search is done, change the datasource tableview back to the full tableview
    [self removeDataSourcePredicate];
    self.dataSource.tableView = self.tableView;
}

- (void) searchBarCancelButtonClicked:(UISearchBar*)searchBar {
    // If the search was cancelled, remove the datasource predicate
    [self removeDataSourcePredicate];
}

- (void) removeDataSourcePredicate {
    [self.dataSource updateWithPredicate:nil];
    [self.tableView reloadData];
}
@end
