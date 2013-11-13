//
//  DataSource.m
//
//  Created by John Hannan on 7/19/12.
//  Copyright (c) 2012, 2013 Penn State University. All rights reserved.
//

#import "DataSource.h"
#import "DataManager.h"
#import "DataManagerDelegate.h"
#import "DataSourceCellConfigurer.h"
#import <CoreData/CoreData.h>

@interface DataSource () <NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSFetchRequest *fetchRequest;

@end;

@implementation DataSource
@synthesize fetchedResultsController, fetchRequest;
@synthesize delegate;


-(id)initForEntity:(NSString *)name
          sortKeys:(NSArray*)sortKeys
         predicate:(NSPredicate*)predicate
sectionNameKeyPath:(NSString*)keyPath
dataManagerDelegate:(id<DataManagerDelegate>)dataManagerDelegate {
    self = [super init];
    if (self) {
        // get the Data Manager and set its delegate - only created once
        DataManager *dataManager = [DataManager sharedInstance];
        dataManager.delegate = dataManagerDelegate;
        
        // create array of sort descriptors from array of sort keys
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc]init];
        for (NSString *key in sortKeys) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                           ascending:YES];
            [sortDescriptors addObject:sortDescriptor];
        }
        
        // create the fetch request
        self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
        self.fetchRequest.sortDescriptors = sortDescriptors;
        self.fetchRequest.predicate = predicate;
        
        //cache name
        //NSString *cacheName = [NSString stringWithFormat:@"%@.cache", [dataManagerDelegate xcDataModelName]];
        
        // create the Fetched Results Controller
        NSManagedObjectContext *context = [dataManager managedObjectContext];
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:self.fetchRequest
                                         managedObjectContext:context
                                         sectionNameKeyPath:keyPath
                                         cacheName:nil];
        
        // Perform the fetch.  Just in case, check for errors
        NSError *error;
        BOOL result = [self.fetchedResultsController performFetch:&error];
        if (!result) {
            NSLog(@"Fetch failed: %@", [error description]);
        }
    }
    return self;
}



// if we set a tableView, then we want to support the delegate methods for
// the fetched results controller
-(void)setTableView:(UITableView *)atableView {
    _tableView = atableView;
    if (atableView) {
        self.fetchedResultsController.delegate = self;
    } else {
        self.fetchedResultsController.delegate = nil;
    }
}




#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get the object for this index path
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // ask delegate for the cell identifier for this object
    NSString *CellIdentifier = [self.delegate cellIdentifierForObject:managedObject];
    // get the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Just in case Storyboards not in use
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask delegate to configure the cell
    [self.delegate configureCell:cell withObject:managedObject];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


// support editing the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source & delegate will take care of the table View
        [self deleteRowAtIndexPath:indexPath];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        // Not supported yet!
    }
    
    
}



#pragma mark -  tableView Delegate might need these
-(id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return managedObject;
}

-(NSIndexPath*)indexPathForObject:(id)object {
    [self update];  // object was typically just added to managed context
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:object];
    return indexPath;
}

-(void)deleteRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
    [context deleteObject:managedObject];
    [context save:nil];  // really should error check here! // better to save lazily, when app terminates
}

-(void)update {
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Fetch update failed: %@", [error description]);
    }
}

-(void)updateWithPredicate:(NSPredicate*)predicate {
    self.fetchRequest.predicate = predicate;
    
    // Perform the fetch again.  Just in case, check for errors
    NSError *error;
    BOOL result = [self.fetchedResultsController performFetch:&error];
    if (!result) {
        NSLog(@"Fetch failed: %@", [error description]);
    }
}


#pragma mark - Fetched Results Controller delegate

/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.delegate configureCell:[tableView cellForRowAtIndexPath:indexPath] withObject:[self objectAtIndexPath:indexPath]];
            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
