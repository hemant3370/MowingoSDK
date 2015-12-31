// MWGAPI.h
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
#import "MWGConstants.h"
#import "MWGBeaconCore.h"
#import "MWGUserData.h"

/**
 *  Handles general requests by the SDK
 */
@interface MWGAPI : NSObject <NSXMLParserDelegate>

#pragma mark - PROMOTION API
/**
 *  Retrieves promotion details for a promotion with given id (promotionId)
 *
 *  @param promotionId id of the promotion for which details need to be retrieved
 *  @param result      completion block that returns promotion details when
 */
- (void) MWGGetPromotion:(NSString *)promotionId
     withCompletionBlock:(void(^)(MWGPromotion *promotion, NSError *result))block;


/**
 *  request to retrieve the promotions of a merchant
 *
 *  @param merchantId merchantId
 *  @param result     completion block when list is retrieved
 */
- (void) MWGGetPromotionListForMerchant:(NSString *)merchantId
                    withCompletionBlock:(void(^)(NSDictionary *promotions, NSError *result))block;


/**
 *  request to redeem a promotion
 *
 *  @param promotionId id of the promotion to be redeemed
 *  @param pinCode     pin code
 *  @param result      completion block when redemption completes
 */
- (void)MWGRedeemPromotion:(NSString *)promotionId
                forPinCode:(NSString *)pinCode
       withCompletionBlock:(void(^)(NSError *result))block;


#pragma mark - AUTHENTICATION API

/**
 *  request for login to server
 *
 *  @param userName valid username
 *  @param password valid password
 *  @param block    completion block that provide login information
 */
-(void)MWGLoginWithUser:(NSString *)userName
               password:(NSString *)password
    withCompletionBlock:(void(^)(NSError *result))block;

/**
 *  Request for User
 *
 *  @param block block description
 */
-(void)MWGUserWithDeviceName:(NSString *)device
                      osType:(NSNumber *)os
                   osVersion:(NSString *)osver
                   emailFlag:(BOOL)email
                       email:(NSString *)emailaddr
                     smsFlag:(BOOL)sms
                       phone:(NSString *)phnr
            locationTracking:(BOOL)loc
                         zip:(NSString *)zip
                 deviceToken:(NSString *)devid
             applicationName:(NSString *)app
             completionBlock:(void(^)(NSNumber *isSuccess, NSError *result))block;


#pragma mark - USERDATA HANDLING

/**
 *  Sets userdata and store it into service
 *
 *  @param userData    users details
 *  @param result      completion block
 */
- (void) MWGSetUserData:(MWGUserData *)userData
    withCompletionBlock:(void(^)(NSError *result))block;


/**
 *  retreives user date from service
 *
 *  @param block completion block
 */
- (void) MWGGetUserDataWithCompletionBlock:(void(^)(MWGUserData * userData, NSError *result))block;



/**
 *  retreives list stores from service
 *
 *  @param searchString string to search for as ZIP code of the store, or city of the store. If empty, no search
 is being performed, and all stores are retrieved.
 *  @param maxStores max number of results needed. The stores returned are the closest to the current
 device location. If empty, all matching stores are retrieved.
 *  @param block completion block
 */
- (void) MWGGetStoresWithSearchString:(NSString *)searchString
                            maxStores:(NSNumber *)maxStores
                      completionBlock:(void(^)(NSArray *stores, NSError *result))block;


#pragma mark - BEACON API

/**
 *  request to retrieve becon list
 *
 *  @param block completion block that calls up when beacon list retrieval completes
 */
-(void)MWGGetBeaconListWithCompletionBlock:(void(^)(NSArray *beacons,
                                                    NSError *result))block;

/**
 *  request to inform beacon activity
 *
 *  @param beaconId   beacon id of current beacon
 *  @param state      state of current beacon
 */

-(void)MWGBeacon:(NSString *)beaconId
 withBeaconState:(MWGBeaconState)state;

/**
 *  Informs server about current ranging beacons with ranging data
 *
 *  @param beacons Ranging beacons data
 *  @param block   the Completion block
 */
-(void)MWGBeaconRangingWithBeacons:(NSArray *)beacons
               withCompletionBlock:(void(^)(NSError *result))block;


#pragma mark - GEOFENCE API

/**
 *  Request for Nearby Stores
 *
 *  @param merchantId merchantId
 *  @param block Completion block that provides
 */
-(void)MWGGetGeoFenceList:(NSString *)merchantId
      WithCompletionBlock:(void(^)(NSArray *arrGeofences,
                                NSError *result))block;

/**
 *  request to inform gefence activity
 *
 *  @param geofenceId   geofence id of current geofence
 *  @param state state of current geofence
 */

-(void)MWGGeofence:(NSString *)geofenceId
 withGeofenceState:(MWGGeofenceState)state;



@end
