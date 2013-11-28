//
//  SPTBusDetailView.h
//  iCATA
//
//  Created by shane on 11/20/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTBusDetailView : UIView
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *onBoardLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@end
