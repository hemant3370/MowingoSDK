//
//  MWGXMLDataCache.m
//  Mowingo
//
//  Created by ram's on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWGXMLDataCache.h"

const NSUInteger kMaxDiskCacheSizeforXML			= 8e7;

static MWGXMLDataCache *sharedInstance;

@interface MWGXMLDataCache (Privates)
- (void)trimDiskCacheFilesToMaxSize:(NSUInteger)targetBytes;
@end


@implementation MWGXMLDataCache
@dynamic sizeOfCache, cacheDir;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}


- (NSString *)cacheDir {
	if (_cacheDir == nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		_cacheDir = [[NSString alloc] initWithString:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"DataCacheDir"]];
		
		
        /* check for existence of cache directory */
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheDir]) {
			
            /* create a new cache directory */
            if (![[NSFileManager defaultManager] createDirectoryAtPath:_cacheDir 
                                           withIntermediateDirectories:NO
                                                            attributes:nil 
                                                                 error:nil]) {
//                NSLog(@"Error creating cache directory");
//						 [IMGSharedObject logInfo:[NSString stringWithFormat:@"Error creating cache directory"]];					
				
                //[_cacheDir release];//ARC Converted by GRR
                _cacheDir = nil;
            }
        }
    }
	return _cacheDir;
}


- (NSString *)localPathForURL:(NSURL *)url {
	
	
	NSString *filename = [[[url absoluteString] componentsSeparatedByString:@"/"] lastObject];
//	[IMGSharedObject logInfo:[NSString stringWithFormat:@" [ Cache filename %@ ] ",filename]];					
	
	return [[self cacheDir] stringByAppendingPathComponent:filename];
}



- (NSData *)dataInCacheForURLString:(NSString *)urlString {
	NSString *localPath = [self localPathForURL:[NSURL URLWithString:urlString]];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
		// "touch" the file so we know when it was last used
		[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil] 
										 ofItemAtPath:localPath 
												error:nil];
		return [[NSFileManager defaultManager] contentsAtPath:localPath];
	}
	
	return nil;
}


- (void)cacheData:(NSData *)theData   
			   request:(NSURLRequest *)request
			  response:(NSURLResponse *)response {
	if (request != nil && 
		response != nil && 
		theData != nil) {
		NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:theData];
		[[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse 
											  forRequest:request];
		
		/*if ([self sizeOfCache] >= kMaxDiskCacheSize) {
			[self trimDiskCacheFilesToMaxSize:kMaxDiskCacheSize * 0.75];
		}*/
		
		NSString *localPath = [self localPathForURL:[request URL]];
		
		[[NSFileManager defaultManager] createFileAtPath:localPath 
												contents:theData 
											  attributes:nil];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
//			NSLog(@"ERROR: Could not create file at path: %@", localPath);
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"ERROR: Could not create file at path: %@",localPath]];					
		} else {
			_cacheSize += [theData length];
		}
		
        //[cachedResponse release];//ARC Converted by GRR
	}
}


- (void)clearCachedDataForRequest:(NSURLRequest *)request {
	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
	NSData *data = [self dataInCacheForURLString:[[request URL] path]];
	_cacheSize -= [data length];
	
	if (_cacheSize > 0 ) {
		NSError *err;
		
		NSString *lclPath =[self localPathForURL:[request URL]];
		
		NSFileManager *fileManger = [NSFileManager defaultManager];
		[fileManger setDelegate:self];
		BOOL status = [fileManger removeItemAtPath:lclPath error:&err];
		
		if (!status) {
			
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Cache local path ----  %@",lclPath]];
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Cache size ----  %d",_cacheSize]];
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Delete chache faild for the request %@",request]];

		}else {
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Cache size ----  %d",_cacheSize]];
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Delete chache succeeded for the request %@",request]];
		}

	
		
//		while (!status) {
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Delete chache faild for the request %@",request]];
//			status = [[NSFileManager defaultManager] removeItemAtPath:[self localPathForURL:[request URL]] error:&err];
//		}
		
	}
//	if (!status) {
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"Delete chache faild for the request %@",request]];
//			[IMGSharedObject logInfo:[NSString stringWithFormat:@"\n\n %@ \n\n",err.localizedFailureReason]];
//		[IMGSharedObject logInfo:[NSString stringWithFormat:@"\n\n %@ \n\n",err.code]];
//		
//		NSCocoaErrorDomain
//		
//		
//		
//	}else {
//		[IMGSharedObject logInfo:[NSString stringWithFormat:@"Delete chache succeeded for the request %@",request]];
//	}

	

}
//commented by ranjan............. jira 462(1).............28 jan 2014
//- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path{
//	
//	[IMGSharedObject logInfo:[NSString stringWithFormat:@"File manager Delegate bfore removing the item %@",path]];
//}
- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path{
	return YES;
}


- (NSUInteger)sizeOfCache {
	NSString *cacheDir = [self cacheDir];
	NSError *error = nil;
	if (_cacheSize <= 0 && cacheDir != nil) {
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDir error:&error];
		NSString *file;
		NSDictionary *attributesPath;
		NSNumber *fileSize;
		NSUInteger totalSize = 0;
		
		for (file in dirContents) {
			if ([[file pathExtension] isEqualToString:@"xml"]) {
				attributesPath = [[NSFileManager defaultManager] attributesOfItemAtPath:[cacheDir stringByAppendingPathComponent:file] error:&error];				
				fileSize = [attributesPath objectForKey:NSFileSize];
				totalSize += [fileSize integerValue];
			}
		}
		_cacheSize = totalSize;
		//NSLog(@"cache size is: %d", _cacheSize);
		

//		[IMGSharedObject logInfo:[NSString stringWithFormat:@"cache size is: %d",_cacheSize]];					
	}
	return _cacheSize;
}


NSInteger dateModifiedSortXML(id file1, id file2, void *reverse) {
	NSDictionary *attrs1 = [[NSFileManager defaultManager] attributesOfItemAtPath:file1 error:nil];
	NSDictionary *attrs2 = [[NSFileManager defaultManager] attributesOfItemAtPath:file2 error:nil];
	
	if ((NSInteger *)reverse == NO) {
		return [[attrs2 objectForKey:NSFileModificationDate] compare:[attrs1 objectForKey:NSFileModificationDate]];
	}
	
	return [[attrs1 objectForKey:NSFileModificationDate] compare:[attrs2 objectForKey:NSFileModificationDate]];
}


- (void)trimDiskCacheFilesToMaxSize:(NSUInteger)targetBytes {
	NSError *error = nil;
	targetBytes = MIN(kMaxDiskCacheSizeforXML, MAX(0, targetBytes));
	if ([self sizeOfCache] > targetBytes)
    {
		
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cacheDir] error:&error];
		NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
		for (NSString *file in dirContents) {
			if ([[file pathExtension] isEqualToString:@"xml"]) {
				[filteredArray addObject:[[self cacheDir] stringByAppendingPathComponent:file]];
			}
		}
		
		int reverse = YES;
		NSMutableArray *sortedDirContents = [NSMutableArray arrayWithArray:[filteredArray sortedArrayUsingFunction:dateModifiedSortXML context:&reverse]];
		while (_cacheSize > targetBytes && [sortedDirContents count] > 0) {
			_cacheSize -= [[[[NSFileManager defaultManager] attributesOfItemAtPath:[sortedDirContents lastObject] error:nil] objectForKey:NSFileSize] integerValue];
			[[NSFileManager defaultManager] removeItemAtPath:[sortedDirContents lastObject] error:nil];
			[sortedDirContents removeLastObject];
		}
	}
}



#pragma mark
#pragma mark ---- singleton implementation ----

+ (MWGXMLDataCache *)sharedCache
{
    @synchronized (sharedInstance)
    {
        if (sharedInstance == nil)
        {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

@end
