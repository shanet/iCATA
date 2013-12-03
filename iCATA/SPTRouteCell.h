//
//  SPTRouteCell.h
//  iCATA
//
//  Created by shane on 12/2/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTRouteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *routeCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@end
