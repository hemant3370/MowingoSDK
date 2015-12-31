//
// MWGSDKManager.h
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//


#import <Foundation/Foundation.h>
#import "MWGPromotion.h"
#import "MWGUserData.h"
#import "MWGParam.h"
#import "MWGBeaconRegion.h"

@interface MWGSDKManager : NSObject


#pragma mark - SDK INITIALIZER

/**
 *  Method to start initializing SDK
 *
 *  @param userName    user unique id
 *  @param isBeacons   beacon flag for beacon functionality activation
 *  @param isGeoFences geofences flag for geofencing functionality activation
 *  @param result      completion block, calls when MWGInit finishes
 */
+ (void) MWGInitWithUniqueUserName:(NSString *)userName
                        beaconFlag:(BOOL)isBeacons
                     geofencesFlag:(BOOL)isGeoFences
                   completionBlock:(void(^)(NSError *result))block;



#pragma mark - AUTHENTICATION API

/**
 *  Method to authenticate user by login
 *
 *  @param userName    user unique id
 *  @param password    user password
 *  @param result      completion block, calls when MWGLogin finishes
 */
+ (void) MWGLoginWithUniqueUserName:(NSString *)userName
                           password:(NSString *)password
                    completionBlock:(void(^)(NSError *result))block;


#pragma mark - PROMOTIONS API

/**
 *  request to retrieve the promotions of a merchant
 *
 *  @param merchantId merchantId
 *  @param result     completion block when list is retrieved
 */
+ (void) MWGGetPromotionListForMerchant:(NSString *)merchantId
                    withCompletionBlock:(void(^)(NSArray *promotions, NSError *result))block;

/**
 *  Retrieves promotion details for a promotion with given id (promotionId)
 *
 *  @param promotionId id of the promotion for which details need to be retrieved
 *  @param result      completion block that returns promotion details when
 */
+ (void) MWGGetPromotion:(NSString *)promotionId
     withCompletionBlock:(void(^)(MWGPromotion *promotion, NSError *result))block;

/**
 *  request to redeem a promotion
 *
 *  @param promotionId id of the promotion to be redeemed
 *  @param pinCode     pin code
 *  @param result      completion block when redemption completes
 */
+ (void) MWGRedeemPromotion:(NSString *)promotionId
                forPinCode:(NSString *)pinCode
       withCompletionBlock:(void(^)(NSError *result))block;


#pragma mark - USERDATA API

/**
 *  Sets userdata and store it into service
 *
 *  @param userData    users details
 *  @param result      completion block
 */
+ (void) MWGSetUserData:(MWGUserData *)userData
    withCompletionBlock:(void(^)(NSError *result))block;


/**
 *  retreives user date from service
 *
 *  @param block completion block
 */
+ (void) MWGGetUserDataWithCompletionBlock:(void(^)(MWGUserData * userData, NSError *result))block;



#pragma mark - STORES API
/**
 *  retreives list stores from service
 *
 *  @param searchString string to search for as ZIP code of the store, or city of the store. If empty, no search
 is being performed, and all stores are retrieved.
 *  @param maxStores max number of results needed. The stores returned are the closest to the current
 device location. If empty, all matching stores are retrieved.
 *  @param block completion block
 */

+ (void) MWGGetStoresWithSearchString:(NSString *)searchString
                            maxStores:(NSNumber *)maxStores
                      completionBlock:(void(^)(NSArray *stores, NSError *result))block;



#pragma mark - Beacons

/**
 *  Checks if specified beacon is under the range of device. If it is, then it returns beacon object with details.
 *
 *  @param beaconRegion Specified beacon region
 *  @param timeout      time to check for beacon
 *  @param block        completion block
 */
+ (void) MWGIsNearBeacon:(MWGBeaconRegion *)beaconRegion
                 timeout:(NSNumber *)timeout
     withCompletionBlock:(void(^)(NSNumber *beaconFlag, NSError *result))block;


#pragma mark - APNS NOTIFICATIONS

/**
 *  Method to set device token
 *
 *  @param token token value
 */
+ (void)MWGSetAPNSDeviceToken:(NSData *)token;

#pragma mark - UTILITY

/**
 *  provide sdk parameters
 *
 *  @return sdk parameter object
 */
+ (MWGParam *) MWGGetParams;

@end
