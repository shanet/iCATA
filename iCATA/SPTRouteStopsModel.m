//
//  SPTRouteStopsModel.m
//  iCATA
//
//  Created by shane on 11/13/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRouteStopsModel.h"

@interface SPTRouteStopsModel ()
@property (strong, nonatomic) NSString *routeCode;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@end


@implementation SPTRouteStopsModel

- (id) initWithRouteCode:(NSString*) routeCode {
    self = [super init];
    
    if(self) {
        _routeCode = routeCode;
    }
    
    return self;
}

- (void) downloadStopsForRoute {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://realtime.catabus.com/InfoPoint/map/GetRouteXml.ashx?RouteId=%@", self.routeCode]];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    _downloadQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.downloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            // TODO: handle errors
        } else {
            // TODO: make a class for this
            [self parseXml:data];
        }
    }];
}

- (void) parseXml:(NSData*) data {
    self.data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
}

- (void) notify {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RouteStopsDownloadCompleted" object:self];
}

@end
