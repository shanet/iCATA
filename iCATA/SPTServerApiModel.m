//
//  SPTServerApiModel.m
//  iCATA
//
//  Created by shane on 12/9/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTServerApiModel.h"

#define kHttpOk 200

@interface SPTServerApiModel ()
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@end

@implementation SPTServerApiModel

- (id) init {
    self = [super init];
    
    if(self) {
        _delegate = nil;
        _downloadedData = nil;
        _downloadQueue = nil;
    }
    
    return self;
}

- (void) downloadDataForRoute:(NSInteger)routeId {
    [self downloadDataAtUrl:[NSString stringWithFormat:@"%s/InfoPoint/rest/RouteDetails/Get/%d", kServerHostname, routeId]];
}

- (void) downloadDataAtUrl:(NSString*) url {
    NSURL *_url = [NSURL URLWithString:url];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:_url];
    self.downloadQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.downloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error || ((NSHTTPURLResponse*)response).statusCode != kHttpOk) {
            self.downloadError = error;
            [self performSelectorOnMainThread:@selector(notifyDownloadError) withObject:nil waitUntilDone:NO];
        } else {
            self.downloadedData = data;
            [self performSelectorOnMainThread:@selector(notifyDownloadComplete) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void) notifyDownloadComplete {
    [self.delegate downloadCompletedWithData:self.downloadedData];
}

- (void) notifyDownloadError {
    [self.delegate downloadCompletedWithError:self.downloadError];
}

@end
