//
//  MWGError.h
//  MowingoSDK
//
//  Created by Bellurbis on 4/22/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWGError : NSObject


#pragma mark - MWGInitErrorDomain

/**
 *  Method to inform application do noit support beacon as iOS version is less than 7.1
 *
 *  @return an error object
 */
+(NSError *)beaconNotSupported;

/**
 *  Method to report error when authentication process(xmluser) throws error
 *
 *  @return an error object
 */
+(NSError *)sdkInitializationFailure;

/**
 *  Method to inform property file is not included properly
 *
 *  @return an error object
 */
+(NSError *)propertyListFileNotAvailable;

/**
 *  Method to report error when any api is called without MWGInit completion
 *
 *  @return an error object
 */
+(NSError *)sdkNotInitialiseError;

/**
 *  Method to report error when beacon flag is not enabled by developer
 *
 *  @return an error object
 */
+ (NSError *)beaconNotEnabled;

/**
 *  Method to report error when geofencing flag is not enabled by developer
 *
 *  @return an error object
 */
+ (NSError *)geofencingNotEnabled;


#pragma mark - MWGNetworkErrorDomain

/**
 *  Method to report error when there is no network available
 *
 *  @return an error object
 */
+(NSError *)noNetworkAvailable;


/**
 *  Method to report error when there is a server time out
 *
 *  @return an error object
 */
+(NSError *)connectionTimeOut;


#pragma mark - MWGResponseErrorDomain

/**
 *  Method use to inform error when no data is received from the server
 *
 *  @return an error object
 */
+(NSError *)noDataResponseError;

/**
 *  Method use to inform error when data received has invalid structure and hence it is unable to get parsed.
 *
 *  @return an error object
 */
+(NSError *)badResponseDataFormatWithParserError:(NSError *)error;


/**
 *  Method use to inform error when data received from the server has bad encoding
 *
 *  @return an error object
 */
+(NSError *)invalidEncodedDataError;


/**
 *  Method use to inform error when data received from server has failure status
 *
 *  @return an error object
 */
+(NSError *)serverStatusError;

#pragma mark - MWGOtherErrorDomain

/**
 *  Method to notify success
 *
 *  @return an error object
 */
+(NSError *)success;

/**
 *  Method use to inform error when location service activation fails
 *
 *  @return an error object
 */
+(NSError *)locationServiceError;


/**
 *  Method use to inform error when APNS activation fails
 *
 *  @return an error object
 */
+(NSError *)APNSError;


/**
 *  Method to reort authentication fail error
 *
 *  @return an error object
 */
+(NSError *)authenticationFailedError;

/**
 *  Method use to inform bluetooth is disabled from iphone settings
 *
 *  @return an error object
 */
+(NSError *)bluetoothDisableError;

/**
 *  Method use to inform error when developer passed an invalid argument
 *
 *  @return an error object
 */
+(NSError *)invalidFormatForData:(NSString *)val;


@end
