//
//  IMGImageCache.m
//  Mowingo
//
//  Created by ram's on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWGXMLCacheLoader.h"
#import "MWGConstants.h"

const NSInteger kMaxDataDownloadConnections		= 1;

static MWGXMLCacheLoader *sharedInstance;


@interface MWGXMLCacheLoader (Privates)
- (void)loadDataForClient:(id<DataConsumer>)client;
- (BOOL)loadDataRemotelyForClient:(id<DataConsumer>)request;
@end


@implementation MWGXMLCacheLoader

- (id)init
{
	if (self = [super init])
    {
		_dataDownloadQueue = [[NSOperationQueue alloc] init];
		[_dataDownloadQueue setMaxConcurrentOperationCount:kMaxDataDownloadConnections];
	}
	return self;
}


- (void)addCacheTypeClientToDownloadQueue:(id<DataConsumer>)client
{
	[_dataDownloadQueue setSuspended:NO];
    
	NSOperation *dataDownloadOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                       selector:@selector(loadDataForClient:)
                                                                         object:client];
    
	[_dataDownloadQueue addOperation:dataDownloadOp];
}

- (void)loadDataForClient:(id<DataConsumer>)client
{
	NSData *cachedData = [self cachedDataForClient: client];	
	
	if (cachedData)
    {
        [client connectionFinishedWithData:cachedData];
    }
    else if (![self loadDataRemotelyForClient:client])
    {
		[self addCacheTypeClientToDownloadQueue:client];
	}
}




- (void)addClientToDownloadQueue:(id<DataConsumer>)client
{
	[_dataDownloadQueue setSuspended:NO];
	NSOperation *dataDownloadOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                       selector:@selector(loadLoginDataForClient:)
                                                                         object:client];
	[_dataDownloadQueue addOperation:dataDownloadOp];
}

- (void)loadLoginDataForClient:(id<DataConsumer>)client
{
	@autoreleasepool {
    
        if (![self loadLoginDataRemotelyForClient:client])
        {
            [self addClientToDownloadQueue:client];
        }
    }
}


- (void)addPostTypeClientToDownloadQueue:(id<DataConsumer>)client
{
	[_dataDownloadQueue setSuspended:NO];
	NSOperation *dataDownloadOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                       selector:@selector(loadPostLoginDataRemotelyForClient:)
                                                                         object:client];
	[_dataDownloadQueue addOperation:dataDownloadOp];
}


- (void)suspendDataDownloads
{
	[_dataDownloadQueue setSuspended:YES];
}


- (void)resumeDataDownloads
{
	[_dataDownloadQueue setSuspended:NO];
}


- (void)cancelDataDownloads
{
	[_dataDownloadQueue cancelAllOperations];
}


- (NSData *)cachedDataForClient:(id<DataConsumer>)client
{
	NSData *data = nil;
	NSURLRequest *request = [client getCacheTypeUrlRequestforData];
	
	NSString *urlStr = [[request URL] absoluteString];
    NSArray *temp =[urlStr componentsSeparatedByString:@"xmlgetdeals15"];
    
    if(temp)
    {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        return nil;
    }
	
	NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
	if (cachedResponse)
    {
		return [cachedResponse data];
	}
    
	return data;
}


- (BOOL)loadDataRemotelyForClient:(id<DataConsumer>)client
{
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSURLRequest *request = [client getCacheTypeUrlRequestforData];
    
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										 returningResponse:&response 
													 error:&error];
	int statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
	if (error != nil || statusCode != 200)
    {
		//Todo: Handel the error if needed
        
        data = [[MWGXMLDataCache sharedCache] dataInCacheForURLString:[[request URL] absoluteString]];
        
        if(data)
        {
			NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL]
                                                                MIMEType:@"text/xml"
                                                   expectedContentLength:[data length]
                                                        textEncodingName:nil];
            
			[[MWGXMLDataCache sharedCache] cacheData:data 
											 request:request 
											response:response];
            
            [client connectionFinishedWithData:data];
            
			return YES;
		}
        else
        {
			[client connectionFinishedWithError:error];
			return YES;
		}
        
	}
    else if (data != nil && response != nil && statusCode == 200)
    {
        if ([data length] == 0)
			data = [[NSString stringWithFormat:@"Null"] dataUsingEncoding:APP_DATA_ENCODING];
		
		[[MWGXMLDataCache sharedCache] cacheData:data 
										 request:request
										response:response];
		[client connectionFinishedWithData:data];
		return YES;
	}
    else
    {
		//Todo: call delegate for the error Message
		[client connectionFinishedWithError:error];
		return YES;
	}
    
	return NO;
}


- (BOOL)loadLoginDataRemotelyForClient:(id<DataConsumer>)client
{
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSURLRequest *request = [client getCacheTypeUrlRequestforData];
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeCachedResponseForRequest:request];
    
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										 returningResponse:&response
													 error:&error];
	int statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
    
    
	if (data != nil && response != nil && statusCode == 200)
    {
		
		if ([data length] == 0)
			data = [[NSString stringWithFormat:@"Null"] dataUsingEncoding:APP_DATA_ENCODING];
        
		[client connectionFinishedWithData:data];
		return YES;
	}
    else
    {
		//Todo: call delegate for the error Message
		[client connectionFinishedWithError:error];
		return YES;
	}
	return NO;
}

- (BOOL)loadPostLoginDataRemotelyForClient:(id<DataConsumer>)client
{
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSURLRequest *request = [client postUrlRequestforData];
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeCachedResponseForRequest:request];
    
	NSData *data = [NSURLConnection sendSynchronousRequest:request
										 returningResponse:&response
													 error:&error];
	int statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
    
    
	if (data != nil && response != nil && statusCode == 200)
    {
		
		if ([data length] == 0)
			data = [[NSString stringWithFormat:@"Null"] dataUsingEncoding:APP_DATA_ENCODING];
		
		[client connectionFinishedWithData:data];
		return YES;
	}
    else
    {
		//Todo: call delegate for the error Message
		[client connectionFinishedWithError:error];
		return YES;
	}
	return NO;
}

#pragma mark
#pragma mark ---- singleton implementation ----

+ (MWGXMLCacheLoader *)sharedDataCacheLoader {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


@end
