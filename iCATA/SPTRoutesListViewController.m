//
//  SPTBuildingsListViewController.m
//  PSU Directory Search
//
//  Created by shane on 10/5/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoutesListViewController.h"

#define kSearchOptionContains 0
#define kSearchOptionExclude  1
#define kSearchOptionMatch    2

@interface SPTRoutesListViewController ()
@property (strong, nonatomic) SPTRoutesModel *routesModel;
//@property (strong, nonatomic) SPTPrefsModel *prefsModel;
@property (strong, nonatomic) DataSource *dataSource;

@property (strong, nonatomic) NSString *searchString;
@property NSInteger searchOption;
@end

@implementation SPTRoutesListViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _routesModel = [[SPTRoutesModel alloc] init];
        //_prefsModel = [[SPTPrefsModel alloc] init];
        
        _dataSource = [[DataSource alloc] initForEntity:@"Route" sortKeys:@[@"type", @"weight"] predicate:nil sectionNameKeyPath:@"type" dataManagerDelegate:_routesModel];
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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Set the search options and provide the search controller with a data source
    self.searchDisplayController.searchBar.scopeButtonTitles = @[@"Contains", @"Exclude", @"Match"];
    self.searchDisplayController.searchResultsDataSource = self.dataSource;
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
    
    cell.showsReorderControl = YES;
}

-(NSString *) cellIdentifierForObject:(id)object {
    return @"cell";
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    SPTRoute *source = [self.dataSource objectAtIndexPath:sourceIndexPath];
    SPTRoute *destination = [self.dataSource objectAtIndexPath:destinationIndexPath];
    
    NSNumber *tmpWeight = source.weight;
    source.weight = destination.weight;
    destination.weight = tmpWeight;
    
    [self.tableView reloadData];
    [[DataManager sharedInstance] saveContext];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If a cell in the search results table was selected, fire a show map info segue
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"ShowMapSegue" sender:nil];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    // Give the selected route to the map controller
    if([segue.identifier isEqualToString:@"ShowMapSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        SPTMapViewController *mapController = segue.destinationViewController;
        [mapController addRoute:[self.dataSource objectAtIndexPath:indexPath]];
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
            predicateSearchFormat = [NSString stringWithFormat:@"ANY name CONTAINS[c] '%@' OR ANY code CONTAINS[c] '%@'", self.searchString, self.searchString];
            break;
        case kSearchOptionExclude:
            predicateSearchFormat = [NSString stringWithFormat:@"!(ANY name CONTAINS[c] '%@' OR ANY code CONTAINS[c] '%@')", self.searchString, self.searchString];
            break;
        case kSearchOptionMatch:
            predicateSearchFormat = [NSString stringWithFormat: @"ANY name LIKE[c] '%@' OR ANY code CONTAINS[c] '%@'", self.searchString, self.searchString];
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
