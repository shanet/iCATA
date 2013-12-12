//
//  SPTStopScheduleViewController.h
//  iCATA
//
//  Created by shane on 12/9/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTRouteStop.h"
#import "MBProgressHUD.h"

@interface SPTStopScheduleViewController : UITableViewController <SPTRouteStopDownloadDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) SPTRouteStop *stop;
@end
