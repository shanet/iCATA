//
//  SPTStopScheduleViewController.m
//  iCATA
//
//  Created by shane on 12/9/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTStopScheduleViewController.h"

#define kShowLoadingViewTime 1.5

@interface SPTStopScheduleViewController ()
@property (strong, nonatomic) MBProgressHUD *loadingView;
@property (strong, nonatomic) NSTimer *loadingViewTimer;
@end

@implementation SPTStopScheduleViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _stop = nil;
        _loadingView = nil;
        _loadingViewTimer = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startLoadingViewTimer];
    
    // Download the stop's schedule
    self.stop.delegate = self;
    [self.stop downloadStopSchedule];
}

- (void) stopScheduleDownloadComplete {
    [self hideLoadingView];

    // Show an error if there are no departures at this stop
    if([self.stop getNumberOfRoutesDepartingFromStop] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No departures"
                                                        message:@"There are no upcoming departures at this stop."
                                                       delegate:self cancelButtonTitle:@"Noted" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    [self.tableView reloadData];
}

- (void) stopScheduleDownloadError:(NSError*)error {
    [self hideLoadingView];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Getting Bus Schedule"
                                                    message:@"An error occured while fetching bus schedule info. Try again later."
                                                   delegate:self cancelButtonTitle:@"Okay :(" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.stop getNumberOfRoutesDepartingFromStop];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stop getNumberOfDeparturesForRouteNumber:section];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *departures = [self.stop getDepaturesForRouteNumber:section];
    if([departures count] > 0) {
        SPTStopDeparture *departure = [departures objectAtIndex:0];
        return departure.route.name;
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath indexAtPosition:0];
    NSInteger sectionIndex = [indexPath indexAtPosition:1];
    
    // Get the stop departure for this cell
    NSArray *departures = [self.stop getDepaturesForRouteNumber:section];
    SPTStopDeparture *departure = [departures objectAtIndex:sectionIndex];
    
    NSString *cellIdentifer = (departure.isLoop) ? @"loopDepartureCell" : @"departureCell";
    
    // Create the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    ((UIImageView*)[cell viewWithTag:1]).image = [UIImage imageWithData:departure.route.icon];
    
    // Configure the cell in varying ways depending if it is a loop or not
    if(departure.isLoop) {
        [self configureLoopDepartureCell:cell ForDeparture:departure];
    } else {
        [self configureDepartureCell:cell ForDeparture:departure];
    }
    
    return cell;
}

- (void) configureDepartureCell:(UITableViewCell*)cell ForDeparture:(SPTStopDeparture*)departure {
    NSString *estimatedDepartureTime = [SPTStopScheduleViewController formatDepartureTime:(NSDate*)departure.estimatedDepartureTime];
    NSString *scheduledDepartureTime = [SPTStopScheduleViewController formatDepartureTime:(NSDate*)departure.scheduledDepartureTime];
    
    ((UILabel*)[cell viewWithTag:2]).text = estimatedDepartureTime;
    ((UILabel*)[cell viewWithTag:3]).text = scheduledDepartureTime;
    ((UILabel*)[cell viewWithTag:4]).text = [SPTStopScheduleViewController getTimeUntilDeparture:departure.scheduledDepartureTime];
    cell = nil;
}

- (void) configureLoopDepartureCell:(UITableViewCell*)cell ForDeparture:(SPTStopDeparture*)departure {
    // Try to put the estimated departure time into an NSDate object so we can calculate the time until departure. If it isn't a time, so the time until
    // departure as whatever the string is
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *estimatedDepatureTime = [dateFormatter dateFromString:(NSString*)departure.estimatedDepartureTime];
    
    NSString *estimatedDepartureTimeString;
    if(estimatedDepatureTime != nil) {
        // <rant>
        // Of course, we're not done yet because this is an incredibly idiotic way to present data from an API. Thanks InfoPoint.
        // In order to calculate the correct time until departure, the date needs set to the current day since it only has the departure time now.
        // Setting the day to the current day will cause an issue if the departure time cross midnight, but since this app won't actually be used
        // by anything, the time spent handling this doesn't seem worth it.
        //
        // Also, NSDate and friends is easily the worst date API I've ever worked with. Seriously Apple, I have to do all this to change the day of the
        // month? Fix your framework.
        // </rant>
        NSDate *now = [[NSDate alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *nowComponents = [calendar components:NSUIntegerMax fromDate:now];
        NSDateComponents *departureComponents = [calendar components:NSUIntegerMax fromDate:estimatedDepatureTime];
        [nowComponents setHour:[departureComponents hour]];
        [nowComponents setMinute:[departureComponents minute]];
        [nowComponents setSecond:0];
        
        estimatedDepatureTime = [calendar dateFromComponents:nowComponents];

        estimatedDepartureTimeString = [SPTStopScheduleViewController getTimeUntilDeparture:estimatedDepatureTime];
    } else {
        estimatedDepartureTimeString = (NSString*)departure.estimatedDepartureTime;
    }
    
    ((UILabel*)[cell viewWithTag:2]).text = (NSString*)departure.estimatedDepartureTime;
    ((UILabel*)[cell viewWithTag:4]).text = estimatedDepartureTimeString;
}

+ (NSString*) formatDepartureTime:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString*) getTimeUntilDeparture:(NSDate*)estimatedDepartureTime {
    NSDate *now = [[NSDate alloc] init];
    
    // Subtract the estimate departure time from the current time in Unix time to get the difference between the two in seconds
    // Sometimes this may be negative if the bus has just left or the server likes to send incorrect departure times every once and a while
    NSInteger differenceInSeconds = [estimatedDepartureTime timeIntervalSince1970] - [now timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%d mins", (NSInteger)differenceInSeconds/60];
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

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
