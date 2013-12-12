//
//  SPTRouteStopsModel.h
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTStopDeparture.h"
#import "SPTServerApiModel.h"
#import "SPTRoute.h"

@protocol SPTRouteStopDownloadDelegate <NSObject>
- (void) stopScheduleDownloadComplete;
- (void) stopScheduleDownloadError:(NSError*)error;
@end

@interface SPTRouteStop : NSObject <SPTDownloadDelegate>
@property float latitude;
@property float longitude;
@property (strong, nonatomic) NSString *name;
@property NSInteger stopId;

@property (strong, nonatomic) NSMutableArray *departures;
@property (strong, nonatomic) id<SPTRouteStopDownloadDelegate> delegate;

- (id) initWithDict:(NSDictionary*) dict;
- (void) downloadStopSchedule;
- (NSInteger) getNumberOfRoutesDepartingFromStop;
- (NSInteger) getNumberOfDeparturesForRouteNumber:(NSInteger)num;
- (NSArray*) getDepaturesForRouteNumber:(NSInteger)num;
@end
