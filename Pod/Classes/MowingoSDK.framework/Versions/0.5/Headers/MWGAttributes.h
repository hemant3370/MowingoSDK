//
//  MWGAttributes.h
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#ifndef MowingoSDK_MWGAttributes_h
#define MowingoSDK_MWGAttributes_h


#endif

#pragma mark - MWGAPNSNotificationKey

/**
 *  Notification key
 */
static const NSString *MWGAPNSNotificationKey = @"promotionId";


#pragma mark - Error handling Domains

static NSString *MWGInitErrorDomain = @"MWGInitErrorDomain"; // error domains related to SDK initiliazation

static NSString *MWGNetworkErrorDomain = @"MWGNetworkErrorDomain"; //error domains related to server connection

static NSString *MWGSDKServiceResponseErrorDomain = @"MWGSDKServiceResponseErrorDomain";  //error domains related to response of server

static NSString *MWGOtherErrorDomain = @"MWGOtherErrorDomain";  //error domains for rest of errors in application


#pragma mark - Error handling Types

typedef enum : NSUInteger{
    
    //MWGInitErrorDomain
    MWG_INIT_ERROR = 1003,  //SDK initialization error 
    MWG_UNSUPPORTED_PROPERTY = 1005, // Unsupported property error i.e. property file is not included in app or  parameters are not added in property file
    MWG_BEACONS_NOT_SUPPORTED = 1006, // Beacon not supported error by the device OS or hardware i.e. due to device iOS version is less than 7.1
    MWG_SDK_NOT_INITIALIZED = 1007,  // SDK not initialized
    MWG_BEACONS_NOT_INITIALIZED = 1008,  // beacon not enabled
    MWG_GEOFENCING_NOT_INITIALIZED = 1009,  // geofencing not enabled
    
    
    //MWGConnectionErrorDomain
    MWG_NETWORK_ERROR = 2000,   // Data network availability error
    MWG_SERVICE_TIMEOUT = 2001,   // Timeout error – response not received from server
    
    
    //MWGResponseErrorDomain
    MWG_SERVICE_ERROR1 = 3000,  // Response error –empty response from server
    MWG_SERVICE_ERROR2 = 3001,  // Response encoding error. Problem in parsing server response
    MWG_SERVICE_ERROR3 = 3002,  // Response format error
    MWG_SERVICE_FAILED = 3003,  // Server returned error
    MWG_AUTH_ERROR = 3004, // Authentication error
    
    
    //MWGOtherErrorDomain
    MWG_SUCCESS = 0000,  //success
    MWG_BLUETOOTH_NOT_ENABLED = 4000, // Bluetooth disabled error
    MWG_SDK_CALL_ERROR = 4002,  // Incorrect argument error in calling an SDK call
    MWG_PUSH_NOTIFICATION_NOT_ENABLED = 4004,  // Push Notification disabled. APNS or GCM could not receive device key. This can happen due to connectivity or authorization issue with APNS, or if end user did not approve push notification. This prevents the SDK from properly handling beacon and geofences events.
    MWG_LOCATION_SERIVCES_NOT_ENABLED = 4005,  // Location services disabled error
    
} MWGErrorCode;