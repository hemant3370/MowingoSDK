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

#import "MWGSDKManager.h"
#import "MWGSDKMangerCore.h"
#import "MWGAPI.h"
#import "MWGError.h"
#import "MWGBeaconRegion.h"
#import "MWGBeaconRegionCore.h"

@implementation MWGSDKManager

/**
 status of MWGInit method
 */
typedef enum : NSUInteger{
    
    MWGInitCompletedStatus,// if MWGInit is completed successfully
    MWGInitInProgressStatus, // if MWGInit is in progress but not completed
    MWGInitUnknownStatus, // if MWGInit is not initialized
    
} MWGInitStatus;


#pragma mark - PUBLIC METHODS

/**
 *  Method to start initializing SDK
 *
 *  @param userName    user unique id
 *  @param isBeacons   beacon flag for beacon functionality activation
 *  @param isGeoFences geofences flag for geofencing functionality activation
 *  @param result      completion block, calls when MWGInit finishes
 */
+ (void)MWGInitWithUniqueUserName:(NSString *)userName
                       beaconFlag:(BOOL)isBeacons
                    geofencesFlag:(BOOL)isGeoFences
                  completionBlock:(void(^)(NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    // check if userName is in valid format
    if (!userName ||
        [userName isEqualToString:@""] ||
        ![userName isKindOfClass:[NSString class]])
    {
        // throw error
        block([MWGError invalidFormatForData:@"userName"]);
        
        return;
    }
    
    // SDK Private Manager
    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
    
    // initialize MWGINIT
    [manager MWGInitWithUniqueUserName:userName
                            beaconFlag:isBeacons
                         geofencesFlag:isGeoFences
                       completionBlock:block];
}


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
                    completionBlock:(void(^)(NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    // check if username is in valid format
    if (!userName ||
        [userName isEqualToString:@""] ||
        ![userName isKindOfClass:[NSString class]])
    {
        // throw error
        block([MWGError invalidFormatForData:@"userName"]);
        
        return;
    }
    
    // check if password is in valid format
    if (!password ||
        [password isEqualToString:@""] ||
        ![password isKindOfClass:[NSString class]])
    {
        // throw error
        block([MWGError invalidFormatForData:@"password"]);
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //call login
    [api MWGLoginWithUser:userName
                 password:password
      withCompletionBlock:block];
}


/**
 *  Method to set device token
 *
 *  @param token token value
 */
+ (void)MWGSetAPNSDeviceToken:(NSData *)token
{
    // SDK Private Manager
    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
    
    // Set MWg APNS Device Token
    [manager MWGSetAPNSDeviceToken:token];
}


/**
 *  Retrieves promotion details for a promotion with given id (promotionId)
 *
 *  @param promotionId id of the promotion for which details need to be retrieved
 *  @param result      completion block that returns promotion details when
 */

+ (void) MWGGetPromotion:(NSString *)promotionId
     withCompletionBlock:(void(^)(MWGPromotion *promotion, NSError *result))block;
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    // check if promotionId is in valid format
    if (!promotionId)
    {
        // throw error
        block(nil, [MWGError invalidFormatForData:@"promotionId"]);
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            // call API
            [api MWGGetPromotion:promotionId
             withCompletionBlock:^(MWGPromotion *promotion, NSError *result) {
                 
                 //throw response
                 if (block)
                 {
                     block(promotion, result);
                 }
                 
             }];
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
//            SEL methodSel = @selector(MWGGetPromotion:withCompletionBlock:);
//            
//            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
//            
//            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//            [invocation setTarget:api];
//            [invocation setSelector:methodSel];
//            [invocation setArgument:&promotionId atIndex:2];
//            [invocation setArgument:&result atIndex:3];
//            [invocation retainArguments];
//            
//            [self addMethodToPendingTaskWithInvocation:invocation];
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}

/**
 *  request to redeem a promotion
 *
 *  @param promotionId id of the promotion to be redeemed
 *  @param pinCode     pin code
 *  @param result      completion block when redemption completes
 */
+ (void)MWGRedeemPromotion:(NSString *)promotionId
                forPinCode:(NSString *)pinCode
       withCompletionBlock:(void(^)(NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    // check if promotionId is in valid format
    if (!promotionId)
    {
        // throw error
        block([MWGError invalidFormatForData:@"promotionId"]);
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            // call API
            
            [api MWGRedeemPromotion:promotionId
                         forPinCode:pinCode
                withCompletionBlock:^(NSError *result) {
                    
                    //throw response
                    if (block)
                    {
                        block(result);
                    }
                    
                }];
            
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
//            SEL methodSel = @selector(MWGRedeemPromotion:forPinCode:withCompletionBlock:);
//            
//            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
//            
//            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//            [invocation setTarget:api];
//            [invocation setSelector:methodSel];
//            [invocation setArgument:&promotionId atIndex:2];
//            [invocation setArgument:&pinCode atIndex:2];
//            [invocation setArgument:&result atIndex:3];
//            [invocation retainArguments];
//            
//            [self addMethodToPendingTaskWithInvocation:invocation];
            
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block([MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block([MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}

/**
 *  request to retrieve the promotions of a merchant
 *
 *  @param merchantId merchantId
 *  @param result     completion block when list is retrieved
 */
+ (void)MWGGetPromotionListForMerchant:(NSString *)merchantId
                   withCompletionBlock:(void(^)(NSArray *promotions, NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            // call API
            [api MWGGetPromotionListForMerchant:merchantId
                            withCompletionBlock:^(NSDictionary *promotions, NSError *result) {
                                
                                //throw response
                                if (block)
                                {
                                    block(promotions[@"Promotions"], result);
                                }
                                
                            }];
            
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
//            SEL methodSel = @selector(MWGGetPromotionListForMerchant:withCompletionBlock:);
//            
//            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
//            
//            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//            [invocation setTarget:api];
//            [invocation setSelector:methodSel];
//            [invocation setArgument:&merchantId atIndex:2];
//            [invocation setArgument:&result atIndex:3];
//            [invocation retainArguments];
//            
//            [self addMethodToPendingTaskWithInvocation:invocation];
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}


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
                      completionBlock:(void(^)(NSArray *stores, NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            // call API
            
            [api MWGGetStoresWithSearchString:searchString
                                    maxStores:maxStores
                              completionBlock:^(NSArray *stores, NSError *result) {
                                  
                                  if (block)
                                  {
                                      block(stores, result);
                                  }
                                  
                              }];
            
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
            //            SEL methodSel = @selector(MWGGetPromotionListForMerchant:withCompletionBlock:);
            //
            //            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
            //
            //            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            //            [invocation setTarget:api];
            //            [invocation setSelector:methodSel];
            //            [invocation setArgument:&merchantId atIndex:2];
            //            [invocation setArgument:&result atIndex:3];
            //            [invocation retainArguments];
            //
            //            [self addMethodToPendingTaskWithInvocation:invocation];
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - USERDATA HANDLING

/**
 *  Sets userdata and store it into service
 *
 *  @param userData    users details
 *  @param result      completion block
 */
+ (void) MWGSetUserData:(MWGUserData *)userData
    withCompletionBlock:(void(^)(NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            // call API
            [api MWGSetUserData:userData
            withCompletionBlock:^(NSError *result) {
                
                //throw response
                if (block)
                {
                    block(result);
                }
                
            }];
            
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
            //            SEL methodSel = @selector(MWGGetPromotionListForMerchant:withCompletionBlock:);
            //
            //            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
            //
            //            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            //            [invocation setTarget:api];
            //            [invocation setSelector:methodSel];
            //            [invocation setArgument:&merchantId atIndex:2];
            //            [invocation setArgument:&result atIndex:3];
            //            [invocation retainArguments];
            //
            //            [self addMethodToPendingTaskWithInvocation:invocation];
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block([MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block([MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}


/**
 *  retreives user date from service
 *
 *  @param block completion block
 */
+ (void) MWGGetUserDataWithCompletionBlock:(void(^)(MWGUserData * userData, NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    //create API instance
    MWGAPI *api = [[MWGAPI alloc] init];
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            // call API
            [api MWGGetUserDataWithCompletionBlock:^(MWGUserData *userData, NSError *result) {
                
                //throw response
                if (block)
                {
                    block(userData, result);
                }
            }];
            
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
            //            SEL methodSel = @selector(MWGGetPromotionListForMerchant:withCompletionBlock:);
            //
            //            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
            //
            //            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            //            [invocation setTarget:api];
            //            [invocation setSelector:methodSel];
            //            [invocation setArgument:&merchantId atIndex:2];
            //            [invocation setArgument:&result atIndex:3];
            //            [invocation retainArguments];
            //
            //            [self addMethodToPendingTaskWithInvocation:invocation];
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}

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
     withCompletionBlock:(void(^)(NSNumber *beaconFlag, NSError *result))block
{
    // check if valid block is available
    if (!block)
    {
        // throw exception
        [self throwExceptionForInvalidBlock];
        
        return;
    }
    
    // check if beaconRegion is in valid format
    if (!beaconRegion)
    {
        // throw error
        block(nil, [MWGError invalidFormatForData:@"beaconRegion"]);
        
        return;
    }
    
    // check if beaconRegion is in valid format
    if (!timeout)
    {
        // throw error
        block(nil, [MWGError invalidFormatForData:@"timeout"]);
        
        return;
    }
    
    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
    
    if (!manager.beaconFlag) {
        block(nil, [MWGError beaconNotEnabled]);
    }
    
    // check if bluetooth is enabled
    if (!manager.bluetoothOnFlag) {
        block(nil, [MWGError bluetoothDisableError]);
    }
    
    //get MWGInit Status
    switch ([self getMWGInitStatus])
    {
        case MWGInitCompletedStatus:
        {
            // if MWGInit is completed successfully
            MWGBeaconRegionCore *region = [[MWGBeaconRegionCore alloc] initWithBeaconRegion:beaconRegion];;
            [region initializeBeaconWithDetectionBlock:block andTimeOut:timeout];
            
        }
            break;
        case MWGInitInProgressStatus:
        {
            // if MWGInit is in progress but not completed
            // delay the API call
            //            SEL methodSel = @selector(MWGGetPromotionListForMerchant:withCompletionBlock:);
            //
            //            NSMethodSignature *signature = [[api class] instanceMethodSignatureForSelector:methodSel];
            //
            //            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            //            [invocation setTarget:api];
            //            [invocation setSelector:methodSel];
            //            [invocation setArgument:&merchantId atIndex:2];
            //            [invocation setArgument:&result atIndex:3];
            //            [invocation retainArguments];
            //
            //            [self addMethodToPendingTaskWithInvocation:invocation];
            
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
        case MWGInitUnknownStatus:
        {
            // if MWGInit is not initialized
            // Throw an error
            if (block)
            {
                block(nil, [MWGError sdkNotInitialiseError]);
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - PRIVATE METHOD

/**
 *  returns current status of MWGInit method
 *
 *  @return current status of MWGInit method
 */
+ (MWGInitStatus)getMWGInitStatus
{
    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
    
    if (manager.isInitialized)
    {
        //if initialized
        return MWGInitCompletedStatus;
    }
    else
    {
        if (manager.isInitializationInProgress)
        {
            // if in progress
            return MWGInitInProgressStatus;
        }
        else
        {
            // if is in unknown state that covers
            // not initialized and error condition
            return MWGInitUnknownStatus;
        }
    }
}

/**
 *  throws exception when invalid block is passed
 */
+ (void) throwExceptionForInvalidBlock
{
    //error
    [NSException raise:@"Error Occurred"
                format:@"Completion block is invalid. Completion block cannot be nil."];
}





#pragma mark - Utility method

/**
 *  provide sdk parameters
 *
 *  @return sdk parameter object
 */
+ (MWGParam *) MWGGetParams
{
    // get singleton
    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
    
    // retreive sdk parameters
    if (!manager.sdkParameters) {
        manager.sdkParameters = [[MWGParam alloc] init];
    }
    
    return manager.sdkParameters;
}


/**
 *  Method that added a task (method call) into pending task when MWGSDKManger class is not initialized
 *
 *  @param invocation invocation object
 */
//+ (void)addMethodToPendingTaskWithInvocation:(NSInvocation *)invocation
//{
//    //retreive private SDKManager instance
//    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
//    
//    //check pending task array
//    if (!manager.pendingTasks)
//    {
//        manager.pendingTasks = [[NSMutableArray alloc] init];
//    }
//    
//    // add invocation to pending task
//    [manager.pendingTasks addObject:invocation];
//}




@end
