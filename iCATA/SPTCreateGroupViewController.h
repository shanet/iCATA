//
//  SPTCreateGroupViewController.h
//  iCATA
//
//  Created by shane on 11/21/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTRoutesModel.h"
#import "SPTRouteGroup.h"
#import "DataSource.h"
#import "DataSourceCellConfigurer.h"

@interface SPTCreateGroupViewController : UITableViewController <DataSourceCellConfigurer, UITextFieldDelegate, UIAlertViewDelegate>

@end
