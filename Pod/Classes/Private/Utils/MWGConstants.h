//
//  MWGConstants.h
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

/**
 *  File which contains all the constants needed in the project
 */
#ifndef GAAF_MWGConstants_h
#define GAAF_MWGConstants_h


#endif


#import <Foundation/Foundation.h>


#define         SDK_VERSION         @"1.21" //Mowingo SDK version value

#define         VERSION             @"0.5" //app current version

#define         SYS                 @"11"  //sys

#define         USER_INFO_FILE_NAME	@"UserDefaults.dat" //User info file name

#define         OS_TYPE             @1   // iOS = 1 and Android = 2

#define         APP_NAME            @"gaaf"  // Application identifier

#define         IS_OS_7_1_OR_LATER  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.1) // checks device version is greater than 7.1

#define         IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)  // check device version is greater than 8.0

#define         APP_DATA_ENCODING    NSUTF8StringEncoding


#pragma mark -
#pragma mark - BASE URLS

#define         BASE_URL_TEST       @"http://sdktest.mowingo.com/sdk" // Base url for Test Environment

#define         BASE_URL_PROD       @"http://sdk.mowingo.com/sdk" // Base url for Production Environment



#pragma mark
#pragma mark User Default

#define         USER_DEFAULT         [NSUserDefaults standardUserDefaults]

#define         ACCESS_TOKEN         @"accesstoken"  //constant for Access Token Value

#define         LOGIN_AUTH_TOKEN     @"mwgloginauthtoken"  // saves login auth token

#define         kUserDefaultUserName @"authenticatedUserName"  //constant for User Name

#define         kDefaultInBeacons    @"inBeacons"  //constant for detecting beacon IN state

#define         kDefaultInGeofence   @"inGeofences"  //constant for detecting geofence IN state




#pragma mark
#pragma mark Beacon

#define         beacon_master       @"beacons"  //constant for beacons list

#define         beacon_id           @"bid"  //constant for beacon id

#define         beacon_uuid         @"budid"  //constant for beacon UUID

#define         beacon_major        @"major"  //constant for beacon Major value

#define         beacon_minor        @"minor"  //constant for beacon Minor value

#define         beacon_intxt        @"intxt"  //constant for beacon INText

#define         beacon_outtxt       @"outtxt"  //constant for beacon OUTText

#define         beacon_proximity    @"proximity"  //beacon proximity value

#define         beacon_type         @"type"   //beacon type

#define         beacon_pid          @"pid"    //product linked with beacon

#define         beacon_did          @"did"   //deal linked with beacon

#define         BEACON_LIST_FILE    @"beacon.json"     //file saved in document directory that contains beacon list retreived from server




#pragma mark 
#pragma mark Geofence

#define         geofence_master       @"geofences"

#define         geofence_id           @"gfid"  //constant for geofence id

#define         geofence_lat          @"gflat"  //constant for geofence latitute

#define         geofence_long         @"gflon"  //constant for geofence longitute

#define         geofence_radius       @"radius"  //constant for geofence radius

#define         geofence_intxt        @"intxt"  //constant for geofence INText

#define         geofence_outtxt       @"outtxt"  //constant for geofence OUTText

#define         geofence_type         @"type"   //geofence type

#define         geofence_pid          @"pid"    //product linked with geofence

#define         geofence_did          @"did"   //deal linked with geofence

#define         GEOFENCE_LIST_FILE    @"geofence.json"   //file saved in document directory that contains geofence list retreived from server



#pragma mark - Notifications

#define         APP_NOTIFICATION            [NSNotificationCenter defaultCenter]

#define         NOTIFICATION_NEAR_BEACON    @"NearbyBeacon"


/********************************************************
 *************************************************************/

#pragma mark 
#pragma mark ENUMS

/**
 determines state of device for a beacon
 */
typedef enum : NSUInteger {
    MWGBeaconIn, //device is under the range of Beacon
    MWGBeaconOut, //device is outside the range of beacon
} MWGBeaconState;



/**
 determines state of device for a Geofence
 */
typedef enum : NSUInteger {
    MWGGeofenceIn, //device is under the range of Geofence
    MWGGeofenceOut, //device is outside the range of Geofence
} MWGGeofenceState;







