//
//  SPTMapViewController.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTMapViewController.h"

@interface SPTMapViewController ()
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation SPTMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _route = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - %@", [self.route code], [self.route name]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeStopsDownloadCompleted) name:@"RouteStopsDownloadCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeBusesDownloadCompleted) name:@"RouteBusesDownloadCompleted" object:nil];
    
    [self.route downloadRouteStops];
    
    [self centerMapOnRoute];
}

- (void) centerMapOnRoute {
    // Center the map on State College
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.7914 longitude:-77.8586 zoom:13];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
}

- (void) routeStopsDownloadCompleted {
    [self addRouteStopOverlays];
    [self addRoutePathOverlay];
}

- (void) addRouteStopOverlays {
    for (SPTRouteStop *routeStop in [self.route stops]) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(routeStop.latitude, routeStop.longitude);
        marker.title = routeStop.name;
        marker.map = self.mapView;
    }
}

- (void) addRoutePathOverlay {
    for(KMLPlacemark *placemark in [[self.route routeKml] placemarks]) {
        KMLAbstractGeometry *geo = placemark.geometry;
        KMLLineString *line = (KMLLineString*) geo;
        
        // Convert the KML coordinates to a Google Maps Path
        GMSMutablePath *routePath = [[GMSMutablePath alloc] init];
        for(KMLCoordinate *coordinate in line.coordinates) {
            CLLocationCoordinate2D cllCoordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
            [routePath addCoordinate:cllCoordinate];
        }
        
        // Convert the path to a line which can be displayed on the map as an overlay
        GMSPolyline *routeLine = [GMSPolyline polylineWithPath:routePath];
        routeLine.strokeWidth = 8;
        routeLine.map = self.mapView;
    }
}

- (void) routeBusesDownloadCompleted {
    
}

@end
