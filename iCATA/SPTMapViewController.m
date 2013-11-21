//
//  SPTMapViewController.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTMapViewController.h"

@interface SPTMapViewController ()
@property (strong, nonatomic) NSMutableArray *busMarkers;
@property (strong, nonatomic) NSMutableArray *stopMarkers;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation SPTMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _mapView = nil;
        _route = nil;
        _busMarkers = [[NSMutableArray alloc] init];
        _stopMarkers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - %@", [self.route code], [self.route name]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeDownloadCompleted) name:@"RouteDownloadCompleted" object:nil];
    
    [self.route downloadRouteStops];
    
    [self centerMapOnRoute];
}

- (void) centerMapOnRoute {
    // Center the map on State College
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.7914 longitude:-77.8586 zoom:13];
    self.mapView.delegate = self;
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
}

- (void) routeDownloadCompleted {
    [self addBusesOverlays];
    [self addRouteStopOverlays];
    [self addRoutePathOverlay];
}

- (void) addBusesOverlays {
    UIImage *busIcon = [UIImage imageNamed:@"tmp_icon.png"];
    
    for(SPTRouteBus *routeBus in [self.route buses]) {
        GMSMarker *marker = [self makeGMSMarkerAtLatitude:routeBus.latitude Longitude:routeBus.longitude];
        
        UIColor *color = [[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:1];
        marker.icon = [GMSMarker markerImageWithColor:color];
        marker.infoWindowAnchor = CGPointMake(0.44, 0.45);
        
        [self.busMarkers addObject:marker];
    }
}

- (void) addRouteStopOverlays {
    UIImage *stopIcon = [UIImage imageNamed:@"stopIcon.png"];
    
    for(SPTRouteStop *routeStop in [self.route stops]) {
        GMSMarker *marker = [self makeGMSMarkerAtLatitude:routeStop.latitude Longitude:routeStop.longitude];
        //marker.icon = stopIcon;
        marker.title = routeStop.name;
        
        [self.stopMarkers addObject:marker];
    }
}

- (void) addRoutePathOverlay {
    for(KMLPlacemark *placemark in [[self.route routeKml] placemarks]) {
        if([placemark.geometry isKindOfClass:[KMLLineString class]]) {
            [self addKmlLineToMap:(KMLLineString*)placemark.geometry];
        } else if([placemark.geometry isKindOfClass:[KMLMultiGeometry class]]) {
            KMLMultiGeometry *multiGeo = (KMLMultiGeometry*)[placemark geometry];
            for(KMLAbstractGeometry *geometry in multiGeo.geometries) {
                [self addKmlLineToMap:(KMLLineString*)geometry];
            }
        }
    }
}

- (void) addKmlLineToMap:(KMLLineString*)kmlLine {
    // Convert the KML coordinates to a Google Maps Path
    GMSMutablePath *routePath = [[GMSMutablePath alloc] init];
    for(KMLCoordinate *coordinate in kmlLine.coordinates) {
        CLLocationCoordinate2D cllCoordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        [routePath addCoordinate:cllCoordinate];
    }
    
    // Convert the path to a line which can be displayed on the map as an overlay
    GMSPolyline *routeLine = [GMSPolyline polylineWithPath:routePath];
    routeLine.strokeWidth = 8;
    routeLine.strokeColor = [self.route color];
    routeLine.map = self.mapView;
}

- (GMSMarker*) makeGMSMarkerAtLatitude:(float)latitude Longitude:(float)longitude {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    return marker;
}

- (UIView*) mapView:(GMSMapView*)mapView markerInfoWindow:(GMSMarker *)marker {
    if([self.busMarkers containsObject:marker]) {
        SPTBusDetailView *busDetailView = [[[NSBundle mainBundle] loadNibNamed:@"BusDetailView" owner:self options:nil] objectAtIndex:0];
        busDetailView.statusLabel.text = @"Hello, bus!";
        return busDetailView;
    } else {
        return nil;
    }
}

@end
