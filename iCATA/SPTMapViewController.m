//
//  SPTMapViewController.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTMapViewController.h"
#import "SPTRouteStopsModel.h"

@interface SPTMapViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) SPTRouteStopsModel *routeStopsModel;
@end

@implementation SPTMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _route = nil;
        _routeStopsModel = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - %@", [self.route code], [self.route name]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeStopsDownloadCompleted) name:@"RouteStopsDownloadCompleted" object:nil];
    
    self.routeStopsModel = [[SPTRouteStopsModel alloc] initWithRouteCode:[self.route code]];
    [self.routeStopsModel downloadStopsForRoute];
}

- (void) routeStopsDownloadCompleted {
    self.textView.text = [self.routeStopsModel data];
}

@end
