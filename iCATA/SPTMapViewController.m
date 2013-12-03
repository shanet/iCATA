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

#define kStopIconScaleFactor 0.025
#define kBusIconOffset 0.5
#define kBusIconScaleFactor 0.6
#define kHeadingIconScaleFactor 0.1
#define kHeadingFactor 3

// The max rider count is estimated from the given specs of the new Flyer Xcelsior buses according to the manufacturer
// This number may not be accurate for older buses, but should provided a good upper bound at least
#define kBusMaxRiderCount 90

#define kMapTypeRoads 0
#define kMapTypeSatellite 1

#define kToastDuration 2
#define kAutoRefreshTime 10.0
#define kShowLoadingViewTime 1

@interface SPTMapViewController ()
@property (strong, nonatomic) NSMutableArray *busMarkers;
@property (strong, nonatomic) NSMutableArray *stopMarkers;
@property (strong, nonatomic) NSMutableArray *routes;

@property (strong, nonatomic) SPTPrefsModel *prefsModel;

@property BOOL isRefresh;
@property NSInteger numberOfInProgressDownloads;

@property (strong, nonatomic) NSTimer *refreshTimer;
@property (strong, nonatomic) NSTimer *loadingViewTimer;

@property (strong, nonatomic) MBProgressHUD *loadingView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

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
        
        _prefsModel = [[SPTPrefsModel alloc] init];
        
        _isRefresh = NO;
        _numberOfInProgressDownloads = 0;
        _loadingView = nil;
        
        _refreshTimer = nil;
        _loadingViewTimer = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeDownloadCompleted) name:@"RouteDownloadCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeDownloadError) name:@"RouteDownloadError" object:nil];
    
    // Ensure that the routes are sorted by weight
    [self sortRoutesArray];
}

- (void) sortRoutesArray {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weight" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.routes sortUsingDescriptors:sortDescriptors];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [self downloadRouteInfo];
    [self setInitialMapState];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelRefreshTimer];
}

- (void) refreshRoutes {
    self.isRefresh = YES;
    
    // Cancel the refresh timer (to be restarted when done downloading route info)
    [self cancelRefreshTimer];
    
    [self downloadRouteInfo];
}

- (void) downloadRouteInfo {
    [self startLoadingViewTimer];
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
    
    // Only add the route stops and path if this is the first load (not a refresh)
    if(!self.isRefresh) {
        [self addRoutesStopsOverlays];
        [self highlightClosestStop];
        [self addRoutesPathOverlay];
        [self fitRoutesOnMap];
    } else {
        // Remove the old bus overlays from the map if a refresh
        for(NSDictionary *dict in self.busMarkers) {
            ((GMSMarker*)[dict objectForKey:@"marker"]).map = nil;
        }
        [self.busMarkers removeAllObjects];
    }

    [self addBusesOverlays];
    
    [self hideLoadingView];
    [self startRefreshTimer];
}

- (void) fitRoutesOnMap {
    // This is really messy because we're passing around arrays of structs rather than objects
    
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
    for(SPTRoute *route in self.routes) {
        // Show a toast if there are no buses running (and this is the first load)
        if([route.buses count] == 0 && !self.isRefresh) {
            [self.view makeToast:[NSString stringWithFormat:@"There are no %@ buses running", route.name] duration:kToastDuration position:@"bottom"];
        }
        
        for(SPTRouteBus *routeBus in route.buses) {
            GMSMarker *busMarker = [self makeGMSMarkerAtLatitude:routeBus.latitude Longitude:routeBus.longitude];
            
            // Round the heading to the nearest factor of kHeadingFactor
            NSInteger roundedHeading = [SPTMapViewController getNearestMultipleOfNumber:routeBus.heading ToFactor:kHeadingFactor];
            
            // Scale and tint the bus icon to use as the marker icon
            UIImage *busIcon = [UIImage imageNamed:[NSString stringWithFormat:@"bus_icons/busIcon-%d.png", roundedHeading]];
            busIcon = [SPTImageUtils tintImage:busIcon withColor:route.color];
            busIcon = [SPTImageUtils scaleImage:busIcon toScaleFactor:kBusIconScaleFactor];
            busMarker.icon = busIcon;

            // Keep track of which markers belong to which buses so the marker detail views can be populated with info about the bus
            [self.busMarkers addObject:@{@"marker": busMarker, @"bus": routeBus, @"route": route}];
        }
    }
}

- (void) addRoutesStopsOverlays {
    UIImage *stopIcon = [SPTImageUtils scaleImage:[UIImage imageNamed:@"stopIcon.png"] toScaleFactor:kStopIconScaleFactor];
    
    for(SPTRoute *route in self.routes) {
        for(SPTRouteStop *routeStop in route.stops) {
            GMSMarker *stopMarker = [self makeGMSMarkerAtLatitude:routeStop.latitude Longitude:routeStop.longitude];
            stopMarker.icon = stopIcon;
            stopMarker.title = routeStop.name;
            
            // Keep track of which markers belong to which routes so the closest stop on the route can be updated as the user's location changes
            [self.stopMarkers addObject:@{@"marker": stopMarker, @"stop": routeStop}];
        }
    }
}

- (void) highlightClosestStop {
    // Don't do anything if the highlight closest stop pref is set to false
    if(![self.prefsModel readBoolPrefForKey:kHighlightClosestStopKey]) {
        return;
    }
    
    CLLocationCoordinate2D currentLocation = self.mapView.myLocation.coordinate;
    
    for(SPTRoute *route in self.routes) {
        SPTRouteStop *closestStop = [route getClosestStopToCoordinate:currentLocation];
        
        // Replace the icon on the closest stop's marker with the closest stop icon
        for(NSDictionary *dict in self.stopMarkers) {
            if([dict objectForKey:@"stop"] == closestStop) {
                GMSMarker *stopMarker = [dict objectForKey:@"marker"];
                stopMarker.icon = [GMSMarker markerImageWithColor:nil];
            }
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
    for(NSDictionary *dict in self.busMarkers) {
        if([dict objectForKey:@"marker"] == marker) {
            SPTBusDetailView *busDetailView = [[[NSBundle mainBundle] loadNibNamed:@"BusDetailView" owner:self options:nil] objectAtIndex:0];
            
            SPTRouteBus *bus = [dict objectForKey:@"bus"];
            SPTRoute *route = [dict objectForKey:@"route"];
            
            busDetailView.routeNameLabel.text = [NSString stringWithFormat:@"%@ - %@", route.code, route.name];
            busDetailView.statusLabel.text = bus.status;
            
            // Change the color of the status label to green for on time and red for late
            if([bus.status compare:@"ON TIME"] == 0) {
                busDetailView.statusLabel.textColor = [UIColor colorWithRed:.25 green:1 blue:.25 alpha:1];
            } else if([bus.status compare:@"LATE"] == 0) {
                busDetailView.statusLabel.textColor = [UIColor colorWithRed:1 green:.25 blue:.25 alpha:1];
            }
            
            busDetailView.onBoardLabel.text = [NSString stringWithFormat:@"%d / %d", bus.riderCount, kBusMaxRiderCount];
            busDetailView.directionLabel.text = [NSString stringWithFormat:@"%@ @ %dmph", bus.direction, bus.speed];
            return busDetailView;
        }
    }
    
    return nil;
}

- (void) routeDownloadError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Getting Bus Info"
                                                        message:@"An error occured while fetching bus location info. Try again later."
                                                       delegate:nil cancelButtonTitle:@"Okay :(" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (IBAction) refreshButtonPressed:(id)sender {
    [self refreshRoutes];
}

- (IBAction) mapTypeChanged:(id)sender {
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

- (void) startRefreshTimer {
    // Refresh automatically every few seconds
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoRefreshTime target:self selector:@selector(refreshRoutes) userInfo:nil repeats:YES];
}

- (void) cancelRefreshTimer {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void) startLoadingViewTimer {
    // Show the loading view after a given time. Normally getting route data from the server is pretty fast, but in the event of a slow network
    // connection, show a loading icon to let the user know something is happening
    self.loadingViewTimer = [NSTimer scheduledTimerWithTimeInterval:kShowLoadingViewTime target:self selector:@selector(showLoadingView) userInfo:nil repeats:NO];
}

- (void) hideLoadingView {
    [self.loadingView hide:YES];
    [self.loadingViewTimer invalidate];
    self.loadingViewTimer = nil;
}

- (void) showLoadingView {
    self.loadingView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

+ (NSInteger) getNearestMultipleOfNumber:(NSInteger)number ToFactor:(NSInteger)factor {
    NSInteger roundUp = (factor - (number % factor)) + number;
    NSInteger roundDown = number - (number %factor);
    return (roundUp - number < number - roundDown) ? roundUp : roundDown;
}

@end
