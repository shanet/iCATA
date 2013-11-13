//
//  DataSource.h
//
//  Created by John Hannan on 7/19/12.
//  Copyright (c) 2012, 2013 Penn State University. All rights reserved.
//
//  This class can be used as is, as the Data Source for a TableViewController.  The TableViewController
//  should be its delegate, implementing the DataSourceCellConfigurer protocol.  This protocol
//  provides information about TableViewCells.  This class uses an NSFetchedResultsController to
//  manage and provide the data to the tableViewController, including sectioning info.  Use the
//  designated initializer to create an instance in a TableViewController, set the TableViewController
//  as the delegate (implementing the required methods), and when the TableView is available, set
//  this class' tableView property to point to it.  (This last step enables the NSFetchedResultsController
//  delegate methods.)


@protocol DataSourceCellConfigurer;
@protocol DataManagerDelegate;

@interface DataSource : NSObject <UITableViewDataSource>

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,weak) id<DataSourceCellConfigurer>delegate;

-(id)initForEntity:(NSString *)name
          sortKeys:(NSArray*)sortKeys
         predicate:(NSPredicate*)predicate
sectionNameKeyPath:(NSString*)keyPath
dataManagerDelegate:(id<DataManagerDelegate>)dataManagerDelegate;

-(id)objectAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath*)indexPathForObject:(id)object;
-(void)deleteRowAtIndexPath:(NSIndexPath *)indexPath;

// peform fetch again due to changes in managed object context (objects added/deleted)
-(void)update;
-(void)updateWithPredicate:(NSPredicate*)predicate;

@end
