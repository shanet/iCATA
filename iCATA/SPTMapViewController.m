//
//  SPTMapViewController.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "SPTMapViewController.h"
#import "SPTRouteStopsModel.h"

@interface SPTMapViewController ()
@property (strong, nonatomic) SPTRouteStopsModel *routeStopsModel;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
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
    
    //[self showTestMap];
}

- (void) routeStopsDownloadCompleted {
    //self.textView.text = [self.routeStopsModel data];
}

- (void) showTestMap {
    // Center the map on State College
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.7914 longitude:-77.8586 zoom:10];
    self.mapView.camera = camera;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.7914, -77.8586);
    marker.title = @"State College";
    marker.snippet = @"United States";
    marker.map = self.mapView;
}

@end
