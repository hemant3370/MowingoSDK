//
//  MWGUrlConnection.h
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary: class for controlling request and response
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGUrlConnection.h"
#import "MWGConstants.h"

@interface MWGUrlConnection (Privates)
- (void)startDownloading;
@end


@implementation MWGUrlConnection
@synthesize urlString, requestId, postData;
@synthesize delegate;


- (id)init {
    
    self = [super init];
    if (self) {
        // Initialization code.
		
    }
    return self;
}

#pragma mark - PUBLIC METHOD

/**
 *  Causes the connection to begin loading data.
 *  The connection will be made by GET method
 *  The connection will cache data if cache data is available
 *
 *  @param url       url of request
 *  @param requestId unique id of request
 */
- (void)MWGCacheTypeRequestWithUrlString:(NSString *)theRequestString
                         andtheRequestId:(NSString *)theRequestId
{
	[self setUrlString:theRequestString];
	[self setRequestId:theRequestId];
	[self startCacheTypeDownloading];
}

/**
 *  Causes the connection to begin loading data.
 *  The connection will be made by GET method
 *  The connection will not cache data
 *
 *  @param url       url of request
 *  @param requestId unique id of request
 */
- (void)MWGRequestUrlString:(NSString *)theRequestString
            andtheRequestId:(NSString *)theRequestId
{
	[self setUrlString:theRequestString];
	[self setRequestId:theRequestId];
	[self startDownloading];
}

/**
 *  Causes the connection to begin loading data.
 *  The connection will be made by POST method
 *  The connection will not cache data
 *
 *  @param url       url of request
 *  @param postBody  post body of request
 *  @param header    header feild data for the request
 *  @param requestId unique id of request
 */
- (void)MWGPostRequestWithUrlString:(NSString *)url
                           postBody:(NSString *)post
                             header:(NSDictionary *)header
                       theRequestId:(NSString *)theRequestId
{
	[self setUrlString:url];
	[self setRequestId:theRequestId];
    [self setPostData:post];
    headerFeild = header;
	[self startDownloadingForPost];
}


/**
 *  Deletes cache of specified url request
 *
 *  @param theurlString url of request
 */
+ (void)deleteCacheforUrl:(NSString *) theUrlString
{
    MWGXMLDataCache *imgDataCache = [MWGXMLDataCache sharedCache];
    NSURL *url = [NSURL URLWithString: theUrlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [imgDataCache clearCachedDataForRequest:request];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
}

/**
 *  deletes all cache
 */
- (void)deleteCache
{
    MWGXMLDataCache *imgDataCache = [MWGXMLDataCache sharedCache];
    NSURL *url = [NSURL URLWithString: [self urlString]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [imgDataCache clearCachedDataForRequest:request];
}


#pragma mark - PRIVATE METHOD

/**
 *  starts downloading for cache type connection
 */
- (void)startCacheTypeDownloading
{
	MWGXMLCacheLoader *imageCacheLoader = [MWGXMLCacheLoader sharedDataCacheLoader];
	[imageCacheLoader addCacheTypeClientToDownloadQueue:self];
}

/**
 *  starts downloading for non-chahe type connection
 */
- (void)startDownloading
{
	MWGXMLCacheLoader *imageCacheLoader = [MWGXMLCacheLoader sharedDataCacheLoader];
	[imageCacheLoader addClientToDownloadQueue:self];
}

/**
 *  start downloading for post type non cache connection
 */
- (void)startDownloadingForPost
{
	MWGXMLCacheLoader *imageCacheLoader = [MWGXMLCacheLoader sharedDataCacheLoader];
	[imageCacheLoader addPostTypeClientToDownloadQueue:self];
}

#pragma mark -
#pragma mark - Imageview Delegate Methods

/**
 *  prepares cache type request object for connection
 *
 *  @return request object
 */
- (NSURLRequest *)getCacheTypeUrlRequestforData
{
	NSURL *url = [NSURL URLWithString: [self urlString]];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                            timeoutInterval:30.0];
	return request;
}


/**
 *  prepares non-cache type request object for connection
 *
 *  @return request object
 */
- (NSURLRequest *)getUrlRequestforData
{
	NSURL *url = [NSURL URLWithString: [self urlString]];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:30.0];
	return request;
}

/**
 *  prepares non-cache post type request object for connection
 *
 *  @return request object
 */
- (NSURLRequest *)postUrlRequestforData
{
 
    NSData *data = [postData dataUsingEncoding:APP_DATA_ENCODING
                          allowLossyConversion:YES];
    
	NSURL *url = [NSURL URLWithString: [self urlString]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:30.0];
    
    [request setHTTPMethod:@"POST"];
    
    if (headerFeild)
    {
        for (NSString *headerKey in headerFeild.allKeys)
        {
            [request addValue:headerFeild[headerKey] forHTTPHeaderField:headerKey];
        }
    }
    
    
    [request setHTTPBody:data];
    
	return request;
}


#pragma mark connection deletes

- (void)connectionFinishedWithData:(NSData *)theData
{
    if (self.delegate == nil)
    {
        return;
    }
    
	[self performSelectorOnMainThread:@selector(connectiondidfinishDelegate:)
                           withObject:theData
                        waitUntilDone:YES];
}


- (void)connectionFinishedWithError:(NSError *)error
{
    if (self.delegate == nil)
    {
        return;
    }
    
	[self performSelectorOnMainThread:@selector(connectiondidfinishWithErrorDelegate:)
                           withObject:error
                        waitUntilDone:YES];
}


- (void)connectiondidfinishDelegate:(NSData *)theData
{
	if ([NSThread isMainThread])
    {
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(updateDatafortheRequest:fortheRequest:)])
        {
			[self.delegate updateDatafortheRequest:theData fortheRequest:requestId];
        }
    }
	else
    {
		[self performSelectorOnMainThread:@selector(connectiondidfinishDelegate:)
                               withObject:theData
                            waitUntilDone:YES];
    }
}

- (void)connectiondidfinishWithErrorDelegate:(NSError *)error
{
	if ([NSThread isMainThread])
    {
		if (self.delegate && [self.delegate respondsToSelector:@selector(updateErrorfortheRequest:)])
        {
			[self.delegate updateErrorfortheRequest:requestId];
        }
    }
    else
    {
        [self performSelector:@selector(connectiondidfinishWithErrorDelegate:)
                   withObject:error
                   afterDelay:0];
    }

}

@end
