//
//  DataSourceCellConfigurer.h
//
//  Created by John Hannan on 10/17/12.
//  Copyright (c) 2012, 2013 John Hannan. All rights reserved.
//
//
//  The DataSource class needs someone to provide application-specific information:
//    (1) the cell identifier for an object
//    (2) the appearance of a tableViewCell (set the title, subtitle, etc)
//    (3) whether a cell can be edited


@protocol DataSourceCellConfigurer <NSObject>

// customize the appearance of the tableview cell using the managed object's data
-(void)configureCell:(UITableViewCell*)cell withObject:(id)object;

// provide the cell identifier for the given managed object
-(NSString *)cellIdentifierForObject:(id)object;

// provide the method to see whether or not the user can edit the cell at the given index path
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
@end
