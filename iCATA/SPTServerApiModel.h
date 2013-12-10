//
//  SPTServerApiModel.h
//  iCATA
//
//  Created by shane on 12/9/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>

// This is the new API currently in testing. This IP is expected to change to a domain sometime in the future.
// This constant will need updated at that time.
#define kServerHostname "http://50.203.43.19"

@protocol SPTDownloadDelegate <NSObject>
- (void) downloadCompletedWithData:(NSData*)data;
- (void) downloadCompletedWithError:(NSError*)error;
@end

@interface SPTServerApiModel : NSObject
@property (strong, nonatomic) id<SPTDownloadDelegate> delegate;
@property (strong, nonatomic) NSData *downloadedData;
@property (strong, nonatomic) NSError *downloadError;

- (void) downloadDataForRoute:(NSInteger)routeId;
@end
