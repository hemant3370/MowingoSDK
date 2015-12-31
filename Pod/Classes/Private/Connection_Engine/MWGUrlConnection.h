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

#import <UIKit/UIKit.h>
#import "MWGXMLCacheLoader.h"

/**
 *  Protocol for web service engine
 */
@protocol  MWGUrlConnectionDelegate <NSObject>

@optional

/**
 *  Delegate method that calls up when a web service request successfully responds with valid data
 *
 *  @param data         the data retreived as a response
 *  @param theRequestId a unique id used to identify the request
 */
- (void)updateDatafortheRequest:(NSData *)data fortheRequest:(NSString *)theRequestId;

/**
 *  Delegate method that calls up when a web service request fails
 *
 *  @param theRequestId a unique id used to identify the request
 */
- (void)updateErrorfortheRequest:(NSString *)theRequestId;

@end


/**
 *  Class that handles web service connection
 */
@interface MWGUrlConnection : NSObject <DataConsumer>
{
	NSString		*urlString;
	NSString		*requestId;
    NSString        *postData;
    NSDictionary    *headerFeild;
	
	__weak id<MWGUrlConnectionDelegate>	delegate;
}

/**
 *  web service url string
 */
@property(copy) NSString	 *urlString;

/**
 *  unique identifier for web service request
 */
@property(copy) NSString	 *requestId;

/**
 *  post body of POST type web service request
 */
@property(copy) NSString     *postData;

/**
 *  delegate for url connection
 */
@property(weak) id<MWGUrlConnectionDelegate>	delegate;


/**
 *  Causes the connection to begin loading data. 
 *  The connection will be made by GET method
 *  The connection will cache data if cache data is available
 *
 *  @param url       url of request
 *  @param requestId unique id of request
 */
- (void)MWGCacheTypeRequestWithUrlString:(NSString *)url
                         andtheRequestId:(NSString *)requestId;


/**
 *  Causes the connection to begin loading data. 
 *  The connection will be made by GET method
 *  The connection will not cache data
 *
 *  @param url       url of request
 *  @param requestId unique id of request
 */
- (void)MWGRequestUrlString:(NSString *)url
            andtheRequestId:(NSString *)requestId;


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
                       theRequestId:(NSString *)theRequestId;


/**
 *  deletes all cache
 */
- (void)deleteCache;


/**
 *  Deletes cache of specified url request
 *
 *  @param theurlString url of request
 */
+ (void)deleteCacheforUrl:(NSString *) theurlString;

@end
