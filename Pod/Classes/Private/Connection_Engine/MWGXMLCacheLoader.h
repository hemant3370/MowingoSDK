//
//  IMGImageCache.h
//  Mowingo
//
//  Created by ram's on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWGXMLDataCache.h"


@protocol DataConsumer <NSObject>

@optional
- (NSURLRequest *)getCacheTypeUrlRequestforData;
- (NSURLRequest *)getUrlRequestforData;
- (NSURLRequest *)postUrlRequestforData;

- (void)connectionFinishedWithData:(NSData *)theData;
- (void)connectionFinishedWithError:(NSError *) error;

@end


@interface MWGXMLCacheLoader : NSObject {
@private
	NSOperationQueue *_dataDownloadQueue;
}


+ (MWGXMLCacheLoader *)sharedDataCacheLoader;


- (void)addCacheTypeClientToDownloadQueue:(id<DataConsumer>)client;
- (void)addClientToDownloadQueue:(id<DataConsumer>)client;
- (void)addPostTypeClientToDownloadQueue:(id<DataConsumer>)client;

- (NSData *)cachedDataForClient:(id<DataConsumer>)client;

- (void)suspendDataDownloads;
- (void)resumeDataDownloads;
- (void)cancelDataDownloads;


@end
