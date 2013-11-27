//
//  SPTMapViewController.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTMapViewController.h"

#define kStateCollegeLatitude 40.7914
#define kStateCollegeLongitude -77.8586
#define kStateCollegeZoomLevel 13

#define kMapCameraPadding 20

#define kMapTypeRoads 0
#define kMapTypeSatellite 1

@interface SPTMapViewController ()
@property (strong, nonatomic) NSMutableArray *busMarkers;
@property (strong, nonatomic) NSMutableArray *stopMarkers;
@property (strong, nonatomic) NSMutableArray *routes;
@property BOOL isRefresh;
@property NSInteger numberOfInProgressDownloads;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIconView;

- (IBAction)refreshButtonPressed:(id)sender;
- (IBAction)mapTypeChanged:(id)sender;
@end

@implementation SPTMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _mapView = nil;
        _groupName = @"";
        _busMarkers = [[NSMutableArray alloc] init];
        _stopMarkers = [[NSMutableArray alloc] init];
        _routes = [[NSMutableArray alloc] init];
        _isRefresh = NO;
        _numberOfInProgressDownloads = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeDownloadCompleted) name:@"RouteDownloadCompleted" object:nil];
    
    [self refreshRoutes];
    [self setInitialMapState];
}

- (void) refreshRoutes {
    [self.loadingIconView startAnimating];
    self.numberOfInProgressDownloads = [self.routes count];
    
    for(SPTRoute *route in self.routes) {
        [route downloadRouteStops];
    }
}

- (void) addRoute:(SPTRoute*)route {
    [self.routes addObject:route];
}

- (void) setTitle {
    // If there is only one route, use that route as the title
    // Otherwise, use the given group name as the title
    if([self.routes count] == 1) {
        SPTRoute *route = [self.routes objectAtIndex:0];
        self.title = [NSString stringWithFormat:@"%@ - %@", route.code, route.name];
    } else {
        self.title = self.groupName;
    }
}

- (void) setInitialMapState {
    // Center the map on State College
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:kStateCollegeLatitude longitude:kStateCollegeLongitude zoom:kStateCollegeZoomLevel];
    self.mapView.delegate = self;
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
}

- (void) routeDownloadCompleted {
    // Only draw to the map when all the downloads finish
    self.numberOfInProgressDownloads--;
    if(self.numberOfInProgressDownloads != 0) {
        return;
    }
    
    [self.loadingIconView stopAnimating];

    // Only add the route stops and path if this is the first load (not a refresh)
    if(!self.isRefresh) {
        [self addRoutesStopsOverlays];
        [self addRoutesPathOverlay];
        [self fitRoutesOnMap];
    } else {
        // Remove the old bus overlays from the map if a refresh
        for(GMSMarker *marker in self.busMarkers) {
            marker.map = nil;
        }
        [self.busMarkers removeAllObjects];
    }

    [self addBusesOverlays];
}

- (void) fitRoutesOnMap {
    // This is really messy because we're passing around struct rather than objects
    
    // Keep an array of the min and max coordinates for each each
    CLLocationCoordinate2D *minCoords = calloc(sizeof(CLLocationCoordinate2D) * [self.routes count], sizeof(CLLocationCoordinate2D));
    CLLocationCoordinate2D *maxCoords = calloc(sizeof(CLLocationCoordinate2D) * [self.routes count], sizeof(CLLocationCoordinate2D));

    for(NSInteger i=0; i<[self.routes count]; i++) {
        CLLocationCoordinate2D *coords = [[self.routes objectAtIndex:i] getBoundingBoxPoints];
        minCoords[i] = coords[0];
        maxCoords[i] = coords[1];
    }
        
    // Find the min and max of the min/max coordinates arrays
    float minLatitude = minCoords[0].latitude;
    float maxLatitude = maxCoords[0].latitude;
    float minLongitude = minCoords[0].longitude;
    float maxLongitude = minCoords[0].longitude;
    
    for(NSInteger i=0; i<[self.routes count]; i++) {
        NSLog(@"%f | %f", maxCoords[i].latitude, maxCoords[i].longitude);
        if(minCoords[i].latitude < minLatitude) {
            minLatitude = minCoords[i].latitude;
        }
        if(maxCoords[i].latitude > maxLatitude) {
            maxLatitude = maxCoords[i].latitude;
        }
        
        if(minCoords[i].longitude < minLongitude) {
            minLongitude = minCoords[i].longitude;
        }
        if(maxCoords[i].longitude > maxLongitude) {
            maxLongitude = maxCoords[i].longitude;
        }
    }
    
    free(minCoords);
    free(maxCoords);
    
    // Set the bounding box of the map as the min/max coordinates
    GMSCoordinateBounds *routeBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(minLatitude, minLongitude)
                                                                            coordinate:CLLocationCoordinate2DMake(maxLatitude, maxLongitude)];
    
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:routeBounds withPadding:kMapCameraPadding];
    [self.mapView animateWithCameraUpdate:cameraUpdate];
}

- (void) addBusesOverlays {
    UIImage *busIcon = [self scaleImage:[UIImage imageNamed:@"tmp_icon.png"] toScaleFactor:.05];
    
    for(SPTRoute *route in self.routes) {
        for(SPTRouteBus *routeBus in route.buses) {
            GMSMarker *marker = [self makeGMSMarkerAtLatitude:routeBus.latitude Longitude:routeBus.longitude];

            marker.icon = busIcon;
            marker.infoWindowAnchor = CGPointMake(0.44, 0.45);
            
            [self.busMarkers addObject:marker];
        }
    }
}

- (void) addRoutesStopsOverlays {
    UIImage *stopIcon = [self scaleImage:[UIImage imageNamed:@"stopIcon.png"] toScaleFactor:.025];
    
    for(SPTRoute *route in self.routes) {
        for(SPTRouteStop *routeStop in route.stops) {
            GMSMarker *marker = [self makeGMSMarkerAtLatitude:routeStop.latitude Longitude:routeStop.longitude];
            marker.icon = stopIcon;
            marker.title = routeStop.name;
            
            [self.stopMarkers addObject:marker];
        }
    }
}

- (void) addRoutesPathOverlay {
    for(SPTRoute *route in self.routes) {
        for(KMLPlacemark *placemark in [route.routeKml placemarks]) {
            // If the placemark is a single line, draw it to the map
            if([placemark.geometry isKindOfClass:[KMLLineString class]]) {
                [self addKmlLineToMap:(KMLLineString*)placemark.geometry ForRoute:route];
                
            // If the placemark contains multiple geometries, draw each one to the map individually
            } else if([placemark.geometry isKindOfClass:[KMLMultiGeometry class]]) {
                KMLMultiGeometry *multiGeo = (KMLMultiGeometry*)[placemark geometry];
                
                for(KMLAbstractGeometry *geometry in multiGeo.geometries) {
                    [self addKmlLineToMap:(KMLLineString*)geometry ForRoute:route];
                }
            }
        }
    }
}

- (void) addKmlLineToMap:(KMLLineString*)kmlLine ForRoute:(SPTRoute*)route {
    // Convert the KML coordinates to a Google Maps Path
    GMSMutablePath *routePath = [[GMSMutablePath alloc] init];
    for(KMLCoordinate *coordinate in kmlLine.coordinates) {
        CLLocationCoordinate2D cllCoordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        [routePath addCoordinate:cllCoordinate];
    }
    
    // Convert the path to a line which can be displayed on the map as an overlay
    GMSPolyline *routeLine = [GMSPolyline polylineWithPath:routePath];
    routeLine.strokeWidth = 8;
    routeLine.strokeColor = route.color;
    routeLine.map = self.mapView;
}

- (GMSMarker*) makeGMSMarkerAtLatitude:(float)latitude Longitude:(float)longitude {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.map = self.mapView;
    
    // Only show the somewhat-annoying animation on the first load (not a refresh)
    if(!self.isRefresh) {
        marker.appearAnimation = kGMSMarkerAnimationPop;
    }
    
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

- (IBAction)refreshButtonPressed:(id)sender {
    self.isRefresh = YES;
    [self refreshRoutes];
}

- (IBAction)mapTypeChanged:(id)sender {
    UISegmentedControl *mapTypeButtons = sender;
    switch(mapTypeButtons.selectedSegmentIndex) {
        case kMapTypeRoads:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case kMapTypeSatellite:
            self.mapView.mapType = kGMSTypeHybrid;
        default:;
    }
}

- (UIImage*) scaleImage:(UIImage*)image toScaleFactor:(float)scaleFactor {
    return [UIImage imageWithCGImage:image.CGImage scale:(image.scale * 1/scaleFactor) orientation:image.imageOrientation];
}
@end
