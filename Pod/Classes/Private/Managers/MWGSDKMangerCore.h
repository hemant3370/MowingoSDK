//
//  MWGSDKMangerCore.h
//  MowingoSDK
//
//  Created by Bellurbis on 4/21/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MWGUser.h"
#import "MWGAPI.h"
#import "MWGParam.h"
#import "MWGBeaconRegionCore.h"


@interface MWGSDKMangerCore : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (MWGSDKMangerCore*)sharedInstance;


/**
 *  Method to start initializing SDK
 *
 *  @param userName    user unique id
 *  @param isBeacons   beacon flag for beacon functionality activation
 *  @param isGeoFences geofences flag for geofencing functionality activation
 *  @param block       completion block, calls when MWGInit finishes
 */
- (void) MWGInitWithUniqueUserName:(NSString *)userName
                        beaconFlag:(BOOL)isBeacons
                     geofencesFlag:(BOOL)isGeoFences
                   completionBlock:(void(^)(NSError *result))block;

/**
 *  Method to set User's Latitude & Longitude
 *
 *  @param latitude  User's Latitude
 *  @param longitude User's Longitude
 *  @param error an error object
 */
-(void) setUserLatitude:(double)latitude
           andLongitude:(double)longitude
                  error:(NSError *)error;


/**
 *  Method to set device token
 *
 *  @param token token value
 */
-(void)MWGSetAPNSDeviceToken:(NSData *)token;


/**
 *  Method to retrieve User's Latitude value
 *
 *  @return return value User's Latitude value
 */
-(double)retreiveUserLatitude;

/**
 *  Method to retrieve User's Longitude value
 *
 *  @return return value Longitude value
 */
-(double)retreiveUserLongitude;

/**
 *  Method to retrieve User's Device token
 *
 *  @return User's Device Token
 */
-(NSString *)retreiveAPNSDeviceToken;


/**
 *  Method to inform when beacon setup completed
 *
 *  @param error error object
 */
-(void)informBeaconSetupCompletionWithError:(NSError *)error;

/**
 *  Method to inform when geofences setup completed
 *
 *  @param error error object
 */
-(void)informGeofenceSetupCompletionWithError:(NSError *)error;

/**
 *  Method that retains api call and avoid getting dealloc
 */
-(void)retainApiCall:(MWGAPI *)api;

/**
 *  Method that release api call and save memory
 */
-(void)releaseApiCall:(MWGAPI *)api;

/**
 *  retrives base url
 *
 *  @return base url string
 */
-(NSString *)getBaseUrl;

/**
 *  check location server is enabled
 *
 *  @return Yes if location service is enabled otherwise NO
 */
-(BOOL)isLocationServiceEnabled;

/**
 *  Method to get Device UUID
 *
 *  @return returns device UUID
 */
- (NSString *)getDeviceUUId;

/**
 *  check if device is inside the vicinity of given beacon region.
 *
 *  @param beaconRegion beacon region
 *
 *  @return Flag, if Yes, the device is under the vicinity of given beacon region.
 */
- (NSNumber *) isNearBeacon:(MWGBeaconRegionCore *)beaconRegion;

- (void)retainBeaconRegion:(id)region;
- (void) releaseBeaconRegion:(id)region;

/**
 *  stores base url for SDK
 */
@property(nonatomic) NSString *baseUrl;

/**
 *  stores access token for sdk
 */
@property(nonatomic) NSString *sdkAccessToken;

/**
 *  flag if sdk is initialized completely
 */
@property(nonatomic) BOOL isInitialized;

/**
 *  flag if SDk initialization is in progress
 */
@property(nonatomic) BOOL isInitializationInProgress;

///**
// *  stores all pending task (i.e. API calls)
// */
//@property(atomic) NSMutableArray *pendingTasks;

@property (nonatomic) MWGParam *sdkParameters;

/**
 *  stores current user details
 */
@property(nonatomic) MWGUser *user;                            //User class object
@property(nonatomic) BOOL beaconFlag;
@property(nonatomic) BOOL geofenceFlag;
@property(nonatomic) BOOL bluetoothOnFlag;

@property(copy)NSString		*userEmailAddredd;              //User Email Address
@property(copy)NSString		*userPhoneNumber;               //User Phone Number
@property(copy)NSString		*userZipCode;                   //User Zip Code
@property(copy)NSString		*brandedStoreStr;               //
@property(copy)NSString		*userStatus;                    //

@property(assign)BOOL		notifyByEmail;                  // Notify by Email Flag
@property(assign)BOOL		notifyBySms;                    // Notify by SMS Flag
@property(assign)BOOL		notifyByLOC;                    // Notify by Location Flag

@property(copy) NSString	*deviceHashedUUIdStr;           // Device Hashed UUID
@property(copy) NSString    *userPupValue;                  //
@property(copy) NSString    *userPupText;                   //
@property(copy) NSString    *userPupUrl;                    //




@end
