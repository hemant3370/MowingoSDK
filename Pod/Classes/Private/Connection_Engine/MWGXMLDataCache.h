//
//  MWGXMLDataCache.h
//  Mowingo
//
//  Created by ram's on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MWGXMLDataCache : NSObject<NSFileManagerDelegate> {
@private
	NSString *_cacheDir;
	NSUInteger _cacheSize;
}

@property (nonatomic, readonly) NSUInteger sizeOfCache;
@property (weak, nonatomic, readonly) NSString *cacheDir;

+ (MWGXMLDataCache *)sharedCache;

- (NSData *)dataInCacheForURLString:(NSString *)urlString;
- (void)cacheData:(NSData *)data
			   request:(NSURLRequest *)request
			  response:(NSURLResponse *)response;
- (void)clearCachedDataForRequest:(NSURLRequest *)request;


@end