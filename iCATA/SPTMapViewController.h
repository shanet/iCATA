//
//  SPTMapViewController.h
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <KML/KML.h>
#import "SPTRoute.h"
#import "SPTBusDetailView.h"

@interface SPTMapViewController : UIViewController <GMSMapViewDelegate>
@property (strong, nonatomic) NSString *groupName;

- (void) addRoute:(SPTRoute*)route;
@end
