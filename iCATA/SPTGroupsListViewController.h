//
//  SPTGroupsListViewController.h
//  iCATA
//
//  Created by shane on 11/21/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTRouteGroup.h"
#import "SPTRoutesModel.h"
#import "SPTMapViewController.h"
#import "DataSource.h"
#import "DataSourceCellConfigurer.h"

@interface SPTGroupsListViewController : UITableViewController <DataSourceCellConfigurer>
@end
