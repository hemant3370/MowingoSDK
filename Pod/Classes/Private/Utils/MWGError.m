//
//  MWGError.m
//  MowingoSDK
//
//  Created by Bellurbis on 4/22/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "MWGError.h"
#import "MWGAttributes.h"

@implementation MWGError


/**
 *  Method use to inform error when location service activation fails
 *
 *  @return an error object
 */
+(NSError *)locationServiceError
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_LOCATION_SERIVCES_NOT_ENABLED
                           userInfo:@{NSLocalizedDescriptionKey : @"Location services disabled error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method use to inform error when APNS activation fails
 *
 *  @return an error object
 */
+(NSError *)APNSError
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_PUSH_NOTIFICATION_NOT_ENABLED
                           userInfo:@{NSLocalizedDescriptionKey : @"Push Notification disabled.\nAPNS or GCM could not receive device key. This can happen due to connectivity or authorization issue with APNS, or if end user did not approve push notification. This prevents the SDK from properly handling beacon and geo-fences events ",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method to reort authentication fail error
 *
 *  @return an error object
 */
+(NSError *)authenticationFailedError
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_AUTH_ERROR
                           userInfo:@{NSLocalizedDescriptionKey : @"Authentication error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

/**
 *  Method to report error when authentication fails
 *
 *  @return an error object
 */
+(NSError *)sdkInitializationFailure
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_INIT_ERROR
                           userInfo:@{NSLocalizedDescriptionKey : @"SDK initialization error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

/**
 *  Method to report error when any api is called without MWGInit completion
 *
 *  @return an error object
 */
+(NSError *)sdkNotInitialiseError
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_SDK_NOT_INITIALIZED
                           userInfo:@{NSLocalizedDescriptionKey : @"SDK not initialized",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

/**
 *  Method to report error when beacon flag is not enabled by developer
 *
 *  @return an error object
 */
+ (NSError *)beaconNotEnabled
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_BEACONS_NOT_INITIALIZED
                           userInfo:@{NSLocalizedDescriptionKey : @"Used when other methods ask for beacons while not initialized.",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

/**
 *  Method to report error when geofencing flag is not enabled by developer
 *
 *  @return an error object
 */
+ (NSError *)geofencingNotEnabled
{
    return [NSError errorWithDomain:MWGInitErrorDomain
                               code:MWG_GEOFENCING_NOT_INITIALIZED
                           userInfo:@{NSLocalizedDescriptionKey : @"Used when other methods ask for geofencings while not initialized.",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


#pragma mark - MWGConnectionErrorDomain

/**
 *  Method to report error when there is no network available
 *
 *  @return an error object
 */
+(NSError *)noNetworkAvailable
{
    return [NSError errorWithDomain:MWGNetworkErrorDomain
                               code:MWG_NETWORK_ERROR
                           userInfo:@{NSLocalizedDescriptionKey : @"Data network availability error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method to report error when there is a server time out
 *
 *  @return an error object
 */
+(NSError *)connectionTimeOut
{
    return [NSError errorWithDomain:MWGNetworkErrorDomain
                               code:MWG_SERVICE_TIMEOUT
                           userInfo:@{NSLocalizedDescriptionKey : @"Timeout error – response not received from server",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


#pragma mark - MWGResponseErrorDomain

/**
 *  Method use to inform error when no data is received from the server
 *
 *  @return an error object
 */
+(NSError *)noDataResponseError
{
    return [NSError errorWithDomain:MWGSDKServiceResponseErrorDomain
                               code:MWG_SERVICE_ERROR1
                           userInfo:@{NSLocalizedDescriptionKey : @"Response error –empty response from server",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

/**
 *  Method use to inform error when data received has invalid structure and hence it is unable to get parsed.
 *
 *  @return an error object
 */
+(NSError *)badResponseDataFormatWithParserError:(NSError *)error
{
    return [NSError errorWithDomain:MWGSDKServiceResponseErrorDomain
                               code:MWG_SERVICE_ERROR3
                           userInfo:@{NSLocalizedDescriptionKey : @"Response format error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method use to inform error when data received from the server has bad encoding
 *
 *  @return an error object
 */
+(NSError *)invalidEncodedDataError
{
    return [NSError errorWithDomain:MWGSDKServiceResponseErrorDomain
                               code:MWG_SERVICE_ERROR2
                           userInfo:@{NSLocalizedDescriptionKey : @"Response encoding error. Problem in parsing server response",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method use to inform error when data received from server has failure status
 *
 *  @return an error object
 */
+(NSError *)serverStatusError
{
    return [NSError errorWithDomain:MWGSDKServiceResponseErrorDomain
                               code:MWG_SERVICE_FAILED
                           userInfo:@{NSLocalizedDescriptionKey : @"Service returned error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

#pragma mark - MWGOtherErrorDomain

/**
 *  Method to notify success
 *
 *  @return an error object
 */
+(NSError *)success
{
    return [NSError errorWithDomain:MWGOtherErrorDomain
                               code:MWG_SUCCESS
                           userInfo:@{NSLocalizedDescriptionKey : @"Success",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method use to inform bluetooth is disabled from iphone settings
 *
 *  @return an error object
 */
+(NSError *)bluetoothDisableError
{
    return [NSError errorWithDomain:MWGOtherErrorDomain
                               code:MWG_BLUETOOTH_NOT_ENABLED
                           userInfo:@{NSLocalizedDescriptionKey : @"Bluetooth disabled error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}

/**
 *  Method to inform property file is not included properly
 *
 *  @return an error object
 */
+(NSError *)propertyListFileNotAvailable
{
    return [NSError errorWithDomain:MWGOtherErrorDomain
                               code:MWG_UNSUPPORTED_PROPERTY
                           userInfo:@{NSLocalizedDescriptionKey : @"Unsupported property error",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method to inform application do noit support beacon as iOS version is less than 7.1
 *
 *  @return an error object
 */
+(NSError *)beaconNotSupported
{
    return [NSError errorWithDomain:MWGOtherErrorDomain
                               code:MWG_BEACONS_NOT_SUPPORTED
                           userInfo:@{NSLocalizedDescriptionKey : @"Beacon not supported error by the device OS or hardware",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}


/**
 *  Method use to inform error when developer passed an invalid argument
 *
 *  @return an error object
 */
+(NSError *)invalidFormatForData:(NSString *)val
{
    return [NSError errorWithDomain:MWGOtherErrorDomain
                               code:MWG_SDK_CALL_ERROR
                           userInfo:@{NSLocalizedDescriptionKey : @"Incorrect argument error in calling an SDK call",
                                      NSLocalizedFailureReasonErrorKey : @"",
                                      NSLocalizedRecoverySuggestionErrorKey : @""}];
}




@end
