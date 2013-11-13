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
    [self setNavBarBackButtonText];
    self.tableView.dataSource = self.dataSource;
    self.dataSource.tableView = self.tableView;

    // Set the search options and provide the search controller with a data source
    self.searchDisplayController.searchBar.scopeButtonTitles = @[@"Contains", @"Exclude", @"Match"];
    self.searchDisplayController.searchResultsDataSource = self.dataSource;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) setNavBarBackButtonText {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Buildings";
    self.navigationItem.backBarButtonItem = backButton;
}


-(void) configureCell:(UITableViewCell*)cell withObject:(id)object {
    // Set the code and name of the route as the text on the cell and the route icon
    SPTRoute *route = (SPTRoute*) object;
    // TODO: change this so the route codes all line up (one letter vs. two letter codes)
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", route.code, route.name];
    cell.imageView.image = [route getIconImage];
}

-(NSString *) cellIdentifierForObject:(id)object {
    return @"cell";
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If a cell in the search results table was selected, fire a show building info segue
    /*if(tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"ShowBuildingInfoSegue" sender:nil];
    }*/
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //[self performSegueWithIdentifier:@"ShowBuildingMapSegue" sender:indexPath];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = nil;
    
    // Give the selected building to the building info/map controller
    /*if([segue.identifier isEqualToString:@"ShowBuildingInfoSegue"]) {
        indexPath = [self.tableView indexPathForSelectedRow];
    } else if([segue.identifier isEqualToString:@"ShowBuildingMapSegue"]) {
        indexPath = (NSIndexPath*)sender;
    } else {
        return;
    }
    
    SPTBuildingDetailViewController *buildingDetailController = segue.destinationViewController;
    buildingDetailController.building = [self.dataSource objectAtIndexPath:indexPath];*/
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
