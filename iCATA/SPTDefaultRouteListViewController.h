//
//  SPTDefaultRouteListViewController.h
//  iCATA
//
//  Created by shane on 11/28/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTRoutesModel.h"
#import "SPTPrefsModel.h"
#import "DataSource.h"
#import "DataSourceCellConfigurer.h"

@interface SPTDefaultRouteListViewController : UITableViewController <DataSourceCellConfigurer>

@end
