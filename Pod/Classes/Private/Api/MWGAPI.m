// MWGAPI.m
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//


/**
 *  Handles general requests of SDK
 */

#import "MWGAPI.h"
#import "MWGSDKMangerCore.h"
#import "MWGPromotionDetailParser.h"
#import "MWGUrlConnection.h"
#import "MWGPromotionListParser.h"
#import "MWGLocationParser.h"
#import "MWGBeaconsParser.h"
#import "MWGLoginParser.h"
#import "MWGUserParser.h"
#import "MWGGeofenceParser.h"
#import "MWGError.h"
#import "MWGGetUserdataParser.h"
#import "MWGUtil.h"
#import "MWGStoreParser.h"


#pragma mark - REQUEST IDs

#define kXMLGetPromotionrequest              @"GetDeal" //Request Id for Promotion Detail
#define kXMLRedeemConfirmationRequest        @"RedeemConfirmation" //Request Id for redemption
#define kXMLGetPromotionsrequest             @"getdeals" //Request Id for Promotion List
#define kXMLBeaconRequest                    @"beaconrequest" //request id to identify beacon connection
#define kXMLGeofenceRequest                  @"geofencerequest" //request id to identify geofence connection
#define kXMLBeaconListRequest                @"BeaconlistRequest"  //request id to identify beacon list connection
#define kXMLLoginRequest                     @"LoginRequest"    //request id for Login status
#define kXMLUserRequest                      @"User"    //request id for user
#define kXMLGetGeofenceRequest               @"GetGeofenceRequest"   //request id for geogence
#define kXMLBeaconRanging                    @"beaconrangingrequest" //request id to send beacon ranging request
#define kXMLSetUserDataRequest               @"setUserDatarequest" //request id for userdata request
#define kXMLGetUserDataRequest               @"getUserDatarequest" //request id for retreiving userdata
#define kXMLGetStoreListRequest              @"getStoreListrequest" //request id for retreiving store list


#pragma mark - REQUEST METHODS

/**
 *  Method for retreiving promotion detail
 */
static NSString *GET_PROMOTION_WEB_METHOD = @"xmlgetdeal.jsp";

/**
 *  Method for redeeming promotion
 */
static NSString *PROMOTION_REDEMPTION_WEB_METHOD = @"xmlrdm.jsp";

/**
 *  Method for retrieving promotions of a particular merchant
 */
static NSString *GET_PROMOTIONS_LIST_WEB_METHOD = @"xmlgetdeals.jsp";


/**
 *  Method to inform server that device is now under the range of specified beacon
 */
static NSString *BEACON_INFO_WEB_METHOD = @"xmlbeacon.jsp";


/**
 *  Method to inform server that device is now under the range of specified geofence
 */
static NSString *GEOFENCE_INFO_WEB_METHOD = @"xmlgeofence.jsp";

/**
 *  Method to retrieve list of available beacons
 */
static NSString *GET_BEACON_LIST_WEB_METHOD = @"xmlgetbeacons.jsp";

/**
 *  Method to retrieve Login status
 */
static NSString *GET_LOGIN_STATUS_METHOD = @"xmllin.jsp";

/**
 *  Method to retrieve User
 */
static NSString *GET_USER_WEB_METHOD = @"xmluser.jsp";

/**
 *  Method to retrieve geofences
 */
static NSString *GET_GEOFENCES_LIST_WEB_METHOD = @"xmlgetgeofences.jsp";

/**
 *  Method to retrieve beacon ranging details
 */
static NSString *SEND_BEACON_RANGE_DATA_WEB_METHOD = @"xmlbeaconranging.jsp";

/**
 *  Method to send userdata to service
 */
static NSString *SET_USER_DATA_WEB_METHOD = @"xmlsetudata.jsp";

/**
 *  Method to retrieve userdata
 */
static NSString *GET_USER_DATA_WEB_METHOD = @"xmlgetuinfo.jsp";

/**
 *  Method to retrieve store list
 */
static NSString *GET_STORE_LIST_WEB_METHOD = @"xmlnearby.jsp";


#pragma mark - Completion Block

/**
 *  Completion block for general request that contaqins message dat and error
 *
 *  @param id      response retrieved
 *  @param NSError error
 */
typedef void(^RequestCompletionMessageBlock)(id, NSError *);

/**
 *  Completion block for request that contains only status as error
 *
 *  @param NSError error
 */
typedef void(^RequestCompletionStatusBlock)(NSError *);



@interface MWGUserData ()

/**
 *  returns gender equivalent string
 *
 *  @return user gender equivalent string
 */
-(NSString *) stringforGender;

/**
 *  returns date without time
 *
 *  @return date object
 */
-(NSDate *)getDobValue;

@end



@interface MWGAPI ()<MWGPromotionDetailParserDelegate, MWGUrlConnectionDelegate, MWGBeaconsListParserDelegate, MWGLoginParserDelegate, MWGUserParserDelegate, MWGGetUserDataParserDelegate, MWGStoreParserDelegate, MWGGeofencesListParserDelegate>
{
    /**
     *  ivar for request connection
     */
    MWGUrlConnection *connection;
    
    /**
     *  Message type request completion block
     */
    RequestCompletionMessageBlock messageCompletionBlock;
    
    /**
     *  status type request completion block
     */
    RequestCompletionStatusBlock statusCompletionBlock;
    
    /**
     *  keeps instance of xml parsers
     */
    id xmlParser;
}


@end

@implementation MWGAPI

#pragma mark - PUBLIC METHODS

/**
 *  Retrieves promotion details for a promotion with given id (promotionId)
 *
 *  @param promotionId id of the promotion for which details need to be retrieved
 *  @param result      completion block that returns promotion details when
 */
- (void) MWGGetPromotion:(NSString *)promotionId
     withCompletionBlock:(void(^)(MWGPromotion *promotion, NSError *result))block
{
    // set completion block
    if (messageCompletionBlock)
    {
        messageCompletionBlock = nil;
    }
    messageCompletionBlock = block;
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createGetPromotionReqWithDeal:[NSString stringWithFormat:@"%@", promotionId]];
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_PROMOTION_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLGetPromotionrequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

/**
 *  request to redeem a promotion
 *
 *  @param promotionId id of the promotion to be redeemed
 *  @param pinCode     pin code
 *  @param result      completion block when redemption completes
 */
- (void)MWGRedeemPromotion:(NSString *)promotionId
                forPinCode:(NSString *)pinCode
       withCompletionBlock:(void(^)(NSError *result))block
{
    /**
     *  set redeem completion block
     */
    if (statusCompletionBlock)
    {
        statusCompletionBlock = nil;
    }
    statusCompletionBlock = block;
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createGetPromotionReqWithDeal:[NSString stringWithFormat:@"%@", promotionId] andPinCode:pinCode];
    
    /**
     *  call promotion redeem web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], PROMOTION_REDEMPTION_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLRedeemConfirmationRequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

/**
 *  request to retrieve the promotions of a merchant
 *
 *  @param merchantId merchantId
 *  @param result     completion block when list is retrieved
 */
- (void) MWGGetPromotionListForMerchant:(NSString *)merchantId
                    withCompletionBlock:(void(^)(NSDictionary *promotions, NSError *result))block
{
    // set completion block
    if (messageCompletionBlock)
    {
        messageCompletionBlock = nil;
    }
    
    messageCompletionBlock = block;
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createGetPromotionsReqWithMerchant:merchantId];
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_PROMOTIONS_LIST_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLGetPromotionsrequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

/**
 *  request to inform beacon activity
 *
 *  @param bid   beacon id of current beacon
 *  @param state state of current beacon
 */

-(void)MWGBeacon:(NSString *)bid withBeaconState:(MWGBeaconState)state
{
    //check if beacon id(bid) is valid
    
    if (!bid ||
        [bid isEqualToString:@""] ||
        ![bid isKindOfClass:[NSString class]])
    {
        //error
        messageCompletionBlock(nil, [MWGError invalidFormatForData:@"beaconId"]);
        
        /*******************************************************
         No need to retain, as response is not required
         **********************************************************/
        
        //
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
    }
    
    /**
     *  create beacon request body for post
     */
    NSString *strRequestBody = [self createBeaconReqWithBeaconId:bid
                                                     beaconState:state];
    
    /**
     *  call beacon request
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], BEACON_INFO_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLBeaconRequest];
    
    /*******************************************************
     No need to retain, as response is not required
     **********************************************************/
    
    //    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

/**
 *  request to retrieve becon list
 *
 *  @param block completion block that calls up when beacon list retrieval completes
 */

-(void)MWGGetBeaconListWithCompletionBlock:(void(^)(NSArray *beacons, NSError *result))block
{
    //check if completion block is valid
    if (!block)
    {
        //error
        
        [NSException raise:@"Error Occurred"
                    format:@"Completion block is invalid"];
        
        return;
    }
    else
    {
        messageCompletionBlock = block;
    }
    
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createBeaconListReq];
    
    /**
     *  call beacon list web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_BEACON_LIST_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLBeaconListRequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

/**
 *  request for login to server
 *
 *  @param userName valid username
 *  @param password valid password
 *  @param block    completion block that provide login information
 */

-(void)MWGLoginWithUser:(NSString *)userName
               password:(NSString *)password
    withCompletionBlock:(void(^)(NSError *result))block
{
    //check if completion block is valid
    if (block)
    {
        statusCompletionBlock = block;
    }
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createGetLoginReqWithUsername:userName
                                                          password:password];
    
    // get base url
    NSString *baseUrl = [[MWGSDKMangerCore sharedInstance] getBaseUrl];
    
    if (!baseUrl || [baseUrl isEqualToString:@""])
    {
        statusCompletionBlock([MWGError propertyListFileNotAvailable]);
    }
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", baseUrl, GET_LOGIN_STATUS_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLLoginRequest
                     needHeader:NO];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}


/**
 *  Request for User
 *
 *  @param block block description
 */
-(void)MWGUserWithDeviceName:(NSString *)device
                      osType:(NSNumber*)os
                   osVersion:(NSString *)osver
                   emailFlag:(BOOL)email
                       email:(NSString *)emailaddr
                     smsFlag:(BOOL)sms
                       phone:(NSString *)phnr
            locationTracking:(BOOL)loc
                         zip:(NSString *)zip
                 deviceToken:(NSString *)devid
             applicationName:(NSString *)app
             completionBlock:(void(^)(NSNumber *isSuccess, NSError *result))block
{
    //check if completion block is valid
    if (!block)
    {
        //error
        [NSException raise:@"Error Occurred"
                    format:@"Completion block is invalid"];
        
        return;
    }
    else
    {
        messageCompletionBlock = block;
    }
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createUserRequestWithDeviceName:device
                                                              osType:os
                                                           osVersion:osver
                                                           emailFlag:email
                                                               email:emailaddr
                                                             smsFlag:sms
                                                               phone:phnr
                                                    locationTracking:loc
                                                                 zip:zip
                                                         deviceToken:devid
                                                     applicationName:app];
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_USER_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLUserRequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

/**
 *  Request for Nearby Stores
 *
 *  @param block Completion block that provides
 */
-(void)MWGGetGeoFenceList:(NSString *)merchantId
      WithCompletionBlock:(void(^)(NSArray *arrGeofences, NSError *result))block
{
    //check if completion block is valid
    if (!block)
    {
        //error
        [NSException raise:@"Error Occurred"
                    format:@"Completion block is invalid"];
        
        return;
    }
    else
    {
        messageCompletionBlock = block;
    }
    
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createGeofencingStoresRequest];
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_GEOFENCES_LIST_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLGetGeofenceRequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
    
}



/**
 *  request to inform gefence activity
 *
 *  @param geofenceId   geofence id of current geofence
 *  @param state state of current geofence
 */

-(void)MWGGeofence:(NSString *)geofenceId
 withGeofenceState:(MWGGeofenceState)state
{
    //check if beacon id(bid) is valid
    
    if (!geofenceId ||
        [geofenceId isEqualToString:@""] ||
        ![geofenceId isKindOfClass:[NSString class]])
    {
        //error
        messageCompletionBlock(nil, [MWGError invalidFormatForData:@"geofenceId"]);
        
        /*******************************************************
         No need to release, as response is not required
         **********************************************************/
        
        //
        // release MWGAPI Object
//        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
    }
    
    /**
     *  create beacon request body for post
     */
    NSString *strRequestBody = [self createGeofenceReqWithGeofenceId:geofenceId
                                                       geofenceState:state];
    
    /**
     *  call beacon request
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GEOFENCE_INFO_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLGeofenceRequest];
    
    
    /*******************************************************
     No need to retain, as response is not required
     **********************************************************/
    
    //    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}


/**
 *  Informs server about current ranging beacons with ranging data
 *
 *  @param beacons Ranging beacons data
 *  @param block   the Completion block
 */
-(void)MWGBeaconRangingWithBeacons:(NSArray *)beacons
               withCompletionBlock:(void(^)(NSError *result))block
{
    statusCompletionBlock = block;
    
    //check beacons list
    if (!beacons || [beacons count] < 1)
    {
        statusCompletionBlock([MWGError invalidFormatForData:@"beacon dictionary"]);
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
    }
    
    /**
     *  create beacon request body for post
     */
    NSString *strRequestBody = [self createBeaconRangingReqForBeacons:beacons];
    
    /**
     *  call beacon request
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], SEND_BEACON_RANGE_DATA_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLBeaconRanging];
    
    /**
     *  retain request
     */
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
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
- (void) MWGGetStoresWithSearchString:(NSString *)searchString
                            maxStores:(NSNumber *)maxStores
                      completionBlock:(void(^)(NSArray *stores, NSError *result))block
{
    messageCompletionBlock = block;
    
    /**
     *  create beacon request body for post
     */
    NSString *strRequestBody = [self createStoreListRequestWithSearchString:searchString
                                                                  maxStores:maxStores];
    
    /**
     *  call beacon request
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_STORE_LIST_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLGetStoreListRequest];
    
    /**
     *  retain request
     */
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}


#pragma mark - USERDATA HANDLING

/**
 *  Sets userdata and store it into service
 *
 *  @param userData    users details
 *  @param result      completion block
 */
- (void) MWGSetUserData:(MWGUserData *)userData
    withCompletionBlock:(void(^)(NSError *result))block
{
    /**
     *  set completion block
     */
    if (statusCompletionBlock)
    {
        statusCompletionBlock = nil;
    }
    statusCompletionBlock = block;
    
    /**
     *  check user data is valid
     */
    if (!userData ||
        ![userData isKindOfClass:[MWGUserData class]])
    {
        //error
        messageCompletionBlock(nil, [MWGError invalidFormatForData:@"userData"]);
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
        
    }
    
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createSetUserdataReqWithuserData:userData];
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], SET_USER_DATA_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLSetUserDataRequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}


/**
 *  retreives user date from service
 *
 *  @param block completion block
 */
- (void) MWGGetUserDataWithCompletionBlock:(void(^)(MWGUserData * userData, NSError *result))block
{
    /**
     *  set completion block
     */
    if (messageCompletionBlock)
    {
        messageCompletionBlock = nil;
    }
    messageCompletionBlock = block;
    
    
    /**
     *  create request body for post
     */
    NSString *strRequestBody = [self createGetUserdataRequest];
    
    /**
     *  call promotion detail web service
     */
    [self callWebServiceWithUrl:[NSString stringWithFormat:@"%@%@", [[MWGSDKMangerCore sharedInstance] getBaseUrl], GET_USER_DATA_WEB_METHOD]
                    requestBody:strRequestBody
                   andRequestId:kXMLGetUserDataRequest];
    
    [[MWGSDKMangerCore sharedInstance] retainApiCall:self];
}

#pragma mark - Parse Response

/**
 *  starts parsing of response from promotion detail request
 *
 *  @param data response data received from promotion detail request
 */

-(void)parseGetPromotionRsp:(NSData *)data
{
    MWGPromotionDetailParser *parser = [[MWGPromotionDetailParser alloc] init];
    parser.delegate = self;
    [parser startParsingData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = parser;
}

/**
 *  parse redeemption response
 *
 *  @param data redemption response data
 */
-(void)parseRedeemResponse:(NSData *)data
{
    //Retrieve redemption data
    NSString *strData =[[NSString alloc] initWithData:data encoding:APP_DATA_ENCODING];
    NSArray *arrResponse =[strData componentsSeparatedByString:@">"];
    NSString *strResponse = [arrResponse objectAtIndex:3];
    strResponse =[strResponse substringToIndex:1];
    
    /**
     *  Stores redemption data
     */
    NSString *strRedemptionFlag = [strResponse copy];
    
    if (!strRedemptionFlag || [strRedemptionFlag isEqualToString:@""])
    {
        /**
         *  Failure
         */
        if (statusCompletionBlock)
        {
            statusCompletionBlock([MWGError noDataResponseError]);
        }
        
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
    }
    else
    {
        /**
         *  Success
         */
        if ([strRedemptionFlag isEqualToString:@"Y"] || [strRedemptionFlag isEqualToString:@"y"])
        {
            if (statusCompletionBlock)
            {
                statusCompletionBlock([MWGError success]);
            }
            
            // release MWGAPI Object
            [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        }
        /**
         *  Failure
         */
        else if ([strRedemptionFlag isEqualToString:@"N"] || [strRedemptionFlag isEqualToString:@"n"])
        {
            if (statusCompletionBlock)
            {
                statusCompletionBlock(nil);
            }
            
            // release MWGAPI Object
            [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        }
    }
}

/**
 *  Parse promotions list response
 *
 *  @param data data promotions list response
 */
-(void)parsePromotionsListRsp:(NSData *)data
{
    // Parse promotion list
    MWGPromotionListParser *xmlDealParser = [[MWGPromotionListParser alloc] init];
    [xmlDealParser parseData:data withCompletion:^(NSArray *arrPromotions, NSString *locName, NSString *pcUrl, NSError *error) {
        
        if (!error)
        {
            if (!arrPromotions && [arrPromotions count] == 0)
            {
                arrPromotions = [[NSArray alloc] init];
            }
            if(!locName)
            {
                locName = @"";
            }
            if (!pcUrl)
            {
                pcUrl = @"";
            }
            
            [self performSelectorInBackground:@selector(startParsingRestaurantListWithPromotions:) withObject:@{@"data" : data, @"array" : arrPromotions, @"locName" : locName, @"pcurl" : pcUrl}];
        }
        else
        {
            messageCompletionBlock(nil, error);
        }
    }];
}

/**
 *  Parse Restaurant List
 *
 *  @param dictData dictionary which contains formatted data, array of promotions, locName & pcUrl
 */
-(void)startParsingRestaurantListWithPromotions:(NSDictionary*)dictData
{
    //Parse restaurant list
    MWGLocationParser *xmlStoreParser = [[MWGLocationParser alloc] init];
    [xmlStoreParser parseData:dictData[@"data"] withCompletion:^(NSArray *arrRestaurants, NSError *error){
        
        if (!error)
        {
            //Storing the array values of promotion and stores in dictionary
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:dictData[@"array"], @"Promotions", arrRestaurants, @"Stores", dictData[@"locName"], @"locname", dictData[@"pcurl"], @"pcurl",nil];
            
            messageCompletionBlock(dict, [MWGError success]);
            
            // release MWGAPI Object
            [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        }
        else
        {
            messageCompletionBlock(nil, error);
        }
    }];
}

/**
 *  Parse beacon List Response
 *
 *  @param data data beacon list response
 */
-(void)parseBeaconListRsp:(NSData *)data
{
    //start beacon list parser
    MWGBeaconsParser *parser = [[MWGBeaconsParser alloc] init];
    parser.delegate = self;
    [parser startParsingData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = parser;
}

/**
 *  Parse Login response
 *
 *  @param data data login response
 */
-(void)parseLoginRsp:(NSData *)data
{
    //start login parser
    MWGLoginParser *parser = [[MWGLoginParser alloc] init];
    parser.delegate = self;
    [parser startParsingData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = parser;
}

/**
 *  Parse user response
 *
 *  @param data data user's response
 */
-(void)parseUserRsp:(NSData *)data
{
    //start user parsing
    MWGUserParser *parser = [[MWGUserParser alloc] init];
    parser.delegate = self;
    [parser parseData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = parser;
    
}

/**
 *  Parse geofence Response
 *
 *  @param data data geofence response
 */
-(void)parseGeofenceRsp:(NSData *)data
{
    //start user parsing
    MWGGeofenceParser *geofenceParser =[[MWGGeofenceParser alloc] init];
    geofenceParser.delegate = self;
    [geofenceParser startParsingData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = geofenceParser;
}


/**
 *  Parse setuserdata Response
 *
 *  @param data userdata
 */
-(void)parseSetUserdataRsp:(NSData *)data
{
    // converts bnary data into string
    NSString *strData = [[NSString alloc] initWithData:data
                                              encoding:APP_DATA_ENCODING] ;
    
    // check for server status
    if (!strData)
    {
        statusCompletionBlock([MWGError noDataResponseError]);
    }
    else
    {
        if ([strData containsString:@"<status>1</status>"])
        {
            statusCompletionBlock([MWGError success]);
        }
        else if ([strData containsString:@"<status>-1</status>"])
        {
            statusCompletionBlock([MWGError serverStatusError]);
        }
        else if ([strData containsString:@"<status>-2</status>"])
        {
            statusCompletionBlock([MWGError authenticationFailedError]);
        }
        else
        {
            statusCompletionBlock([MWGError badResponseDataFormatWithParserError:nil]);
        }
    }
    
}

/**
 *  Parse getuserdata Response
 *
 *  @param data userdata
 */
-(void)parseGetUserdataRsp:(NSData *)data
{
    //start user parsing
    MWGGetUserdataParser *userdataParser =[[MWGGetUserdataParser alloc] init];
    userdataParser.delegate = self;
    [userdataParser startParsingData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = userdataParser;
}


/**
 *  Parse stores API Response
 *
 *  @param data userdata
 */
-(void)parseGetStoresRsp:(NSData *)data
{
    MWGStoreParser *storeParser = [[MWGStoreParser alloc] init];
    storeParser.delegate = self;
    [storeParser startParsingData:data];
    
    if (xmlParser)
    {
        xmlParser = nil;
    }
    
    xmlParser = storeParser;
}


#pragma mark - Web Service Call

/**
 *  creates common parameters of request body
 *
 *  @return returns request body common parameters
 */
+(NSString *)createMessageEnvelope
{
    MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
    
    /*************************************************************************
     
     NOTE: Two longitude is passed with differnet parameters (lon and long)
     as different web service is currently using different parameters
     
     **************************************************************************/
    
    return [NSString stringWithFormat:@"uuid=%@&un=%@&lat=%f&long=%f&lon=%f&ver=%@&sys=%@",
            manager.user.userId ,//user id (device id)
            manager.user.userName, //user name (registered user name)
            [[MWGSDKMangerCore sharedInstance] retreiveUserLatitude], //current latitude of device
            [[MWGSDKMangerCore sharedInstance] retreiveUserLongitude], //current longitude of device
            [[MWGSDKMangerCore sharedInstance] retreiveUserLongitude], //current longitude of device
            VERSION, //app version
            SYS]; //sys
}

/**
 *  General method to make a request with service
 *
 *  @param url  url of the request
 *  @param body post body of request
 */
-(void)callWebServiceWithUrl:(NSString *)url
                 requestBody:(NSString *)body
                andRequestId:(NSString *)requestId
{
    [self callWebServiceWithUrl:url
                    requestBody:body
                   andRequestId:requestId
                     needHeader:YES];
}

/**
 *  General method to make a request with service
 *
 *  @param url  url of the request
 *  @param body post body of request
 */
-(void)callWebServiceWithUrl:(NSString *)url
                 requestBody:(NSString *)body
                andRequestId:(NSString *)requestId
                  needHeader:(BOOL)headerFlag
{
    if (connection)
    {
        connection = nil;
    }
    
    /**
     creates custom url connection object
     
     :returns: custom url connection object
     */
    connection = [[MWGUrlConnection alloc] init];
    [connection setDelegate:self];
    
    // get header feild
    NSDictionary *headerFeild;
    
    if (headerFlag)
    {
        headerFeild = @{@"authorization" : [[MWGSDKMangerCore sharedInstance] sdkAccessToken] };
    }
    else
    {
        headerFeild = nil;
    }
    
    /**
     *  start post request
     */
    [connection MWGPostRequestWithUrlString:url
                                   postBody:body
                                     header:headerFeild
                               theRequestId:requestId];
}


/**
 *  Delegate method that calls up when request completes successfully
 *
 *  @param data         data recived from request
 *  @param theRequestId request id to identify the request
 */

- (void)updateDatafortheRequest:(NSData *)data fortheRequest:(NSString *)theRequestId
{
    /**
     *  Validate Data received from server
     */
    if (!data)
    {
        if (messageCompletionBlock)
        {
            messageCompletionBlock(nil, [MWGError noDataResponseError]);
        }
        else
        {
            statusCompletionBlock([MWGError noDataResponseError]);
        }
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        return;
    }
    
    if ([theRequestId isEqualToString:kXMLGetPromotionrequest])
    {
        /**
         *  start parsing data
         */
        [self parseGetPromotionRsp:data];
    }
    
    else if ([theRequestId isEqualToString:kXMLRedeemConfirmationRequest])
    {
        /**
         *  start parsing data
         */
        [self parseRedeemResponse:data];
    }
    
    else if ([theRequestId isEqualToString:kXMLGetPromotionsrequest])
    {
        /**
         *  start parsing data
         */
        [self parsePromotionsListRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLBeaconListRequest])
    {
        /**
         *  start parsing data
         */
        [self parseBeaconListRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLLoginRequest])
    {
        /**
         *  start parsing data
         */
        [self parseLoginRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLUserRequest])
    {
        /**
         *  start parsing data
         */
        [self parseUserRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLGetGeofenceRequest])
    {
        /**
         *  start parsing data
         */
        [self parseGeofenceRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLBeaconRanging])
    {
        /**
         *  start parsing data
         */
    }
    else if ([theRequestId isEqualToString:kXMLSetUserDataRequest])
    {
        /**
         *  start parsing data
         */
        [self parseSetUserdataRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLGetUserDataRequest])
    {
        /**
         *  start parsing data
         */
        [self parseGetUserdataRsp:data];
    }
    else if ([theRequestId isEqualToString:kXMLGetStoreListRequest])
    {
        /**
         *  start parsing data
         */
        [self parseGetStoresRsp:data];
    }
}



/**
 *  delegate method that calls up when request fails
 *
 *  @param theRequestId request id to identify the request
 */
- (void)updateErrorfortheRequest:(NSString *)theRequestId
{
    if (messageCompletionBlock)
    {
        messageCompletionBlock(nil, [MWGError connectionTimeOut]);
    }
    
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
    
    NSLog(@"Failure case from Server");
    
}

#pragma mark - Logics

/**
 *  creates request body for promotion redeemption request
 *
 *  @param dealId  promotion id
 *  @param pinCode pincode
 *
 *  @return request body for promotion detail request
 */
-(NSString *)createGetPromotionReqWithDeal:(NSString *)dealId
                                andPinCode:(NSString *)pinCode
{
    NSString *strRequestUrl;
    
    if (pinCode && ![pinCode isEqualToString:@""])
    {
        //with pincode
        strRequestUrl = @"did=%@&pincode=%@&%@";
    }
    else
    {
        // no pincode
        strRequestUrl = @"did=%@&%@";
    }
    
    return [NSString stringWithFormat:strRequestUrl, dealId, [MWGAPI createMessageEnvelope]];
}

/**
 *  creates request body for promotion details request
 *
 *  @param dealId promotion id
 *
 *  @return request body for promotion detail request
 */
-(NSString *)createGetPromotionReqWithDeal:(NSString *)dealId
{
    return [NSString stringWithFormat:@"did=%@&%@", dealId, [MWGAPI createMessageEnvelope]];
}


/**
 *  creates request body for merchant detail request
 *
 *  @param merchantId merchantId
 *
 *  @return request body for promotions detail request corresponding to merchant
 */
-(NSString *)createGetPromotionsReqWithMerchant:(NSString *)merchantId
{
    if (merchantId && ![merchantId isEqualToString:@""])
    {
        // if merchant id is available add mid
        return [NSString stringWithFormat:@"mid=%@&%@", merchantId, [MWGAPI createMessageEnvelope]];
    }
    else
    {
        // if no merchant id
        return [MWGAPI createMessageEnvelope];
    }
    
}



/**
 *  creates request body for login request
 *
 *  @param userName username
 *  @param password password
 *
 *  @return request body for login
 */
-(NSString *)createGetLoginReqWithUsername:(NSString *)userName
                                  password:(NSString *)password
{
    return [NSString stringWithFormat:@"uuid=%@&un=%@&pw=%@&ver=%@&sys=%@",
            [[MWGSDKMangerCore sharedInstance] getDeviceUUId],
            userName,
            password,
            VERSION,
            SYS];
}

/**
 *  creates request body for User
 *
 *  @return request body for User
 */
-(NSString *)createUserRequestWithDeviceName:(NSString *)device
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
{
    return [NSString stringWithFormat:@"email=%@&emaddr=%@&sms=%@&phnr=%@&loc=%@&zip=%@&devid=%@&device=%@&osver=%@&%@&app=%@&os=%@",
            (email ? @"Y" : @"N"),
            (emailaddr ? emailaddr : @""),
            (sms ? @"Y" : @"N"),
            (phnr ? phnr : @""),
            (loc ? @"Y" : @"N"),
            (zip ? zip : @""),
            [[MWGSDKMangerCore sharedInstance] retreiveAPNSDeviceToken],
            (device ? device : @""),
            (osver ? osver : @""),
            [MWGAPI createMessageEnvelope],
            (app ? app : @""),
            (os ? [NSString stringWithFormat:@"%@", os] : @"")];
}



/**
 *  creates request body for beacon info request
 *
 *  @param bid   beacon id of current beacon
 *  @param state state of beacon
 *
 *  @return request body for beacon request
 */

-(NSString *)createBeaconReqWithBeaconId:(NSString *)bid
                             beaconState:(MWGBeaconState)state
{
    return [NSString stringWithFormat:@"bid=%@&inout=%@&%@",
            bid,
            ((state == MWGBeaconIn) ? @"in" : @"out"),
            [MWGAPI createMessageEnvelope]];
}

/**
 *  creates request body for beacon info request
 *
 *  @param bid   beacon id of current beacon
 *  @param state state of beacon
 *
 *  @return request body for beacon request
 */

-(NSString *)createGeofenceReqWithGeofenceId:(NSString *)gfid
                               geofenceState:(MWGGeofenceState)state
{
    return [NSString stringWithFormat:@"gfid=%@&inout=%@&%@",
            gfid,
            ((state == MWGGeofenceIn) ? @"in" : @"out"),
            [MWGAPI createMessageEnvelope]];
}

/**
 *  creates request body for beacon list request
 *
 *  @return request body for beacon list request
 */
-(NSString *)createBeaconListReq
{
    return [MWGAPI createMessageEnvelope];
}

/**
 *  creates request body for geofencing list request
 *
 *  @return request body for geofencing list request
 */
-(NSString *)createGeofencingStoresRequest
{
    return [MWGAPI createMessageEnvelope];
}


/**
 *  creates request body for store list request
 *
 *  @return request body for store list request
 */
-(NSString *)createStoreListRequestWithSearchString:(NSString *)searchString
                                          maxStores:(NSNumber *)maxStores
{
    return [NSString stringWithFormat:@"maxstores=%@&search=%@&%@",
            maxStores ? maxStores : @"",
            searchString ? searchString : @"",
            [MWGAPI createMessageEnvelope]];
}


/**
 *  creates request body for beacon ranging
 *
 *  @param beacons list of beacons
 *
 *  @return request body for beacon ranging
 */
-(NSString *)createBeaconRangingReqForBeacons:(NSArray *)beacons
{
    return [NSString stringWithFormat:@"data=%@&%@",
            [MWGUtil getXMLOfRangingData:beacons],
            [MWGAPI createMessageEnvelope]];
}


/**
 *  creates request body for set user data
 *
 *  @param userData user data
 *
 *  @return request body for set user data
 */
-(NSString *)createSetUserdataReqWithuserData:(MWGUserData *)userData
{
    
    return [NSString stringWithFormat:@"msgrefs=%@&prefs=%@&fname=%@&lname=%@&email=%@&phone=%@&zip=%@&dob=%@&gender=%@&lang=%@&groupname=%@&currentbudget=%@&totalbudget=%@&%@",
            [MWGUtil getBitFromArray:userData.messagePreferences],
            [MWGUtil getBitFromArray:userData.productPreferences],
            userData.firstName ? userData.firstName : @"",
            userData.familyname ? userData.familyname : @"",
            userData.userEmail ? userData.userEmail : @"",
            userData.phoneNumber ? userData.phoneNumber : @"",
            userData.zip ? userData.zip : @"",
            userData.dob ? [MWGUtil getUnixFromDate:[userData getDobValue]] : @"",
            [userData stringforGender],
            userData.userLanguage ? userData.userLanguage : @"",
            userData.groupname ? userData.groupname : @"",
            userData.currentbudget ? userData.currentbudget : @"",
            userData.totalbudget ? userData.totalbudget : @"",
            [MWGAPI createMessageEnvelope]];
}

/**
 *  creates request body for retreiving userdata
 *
 *  @return request body for retreiving userdata
 */
-(NSString *)createGetUserdataRequest
{
    return [MWGAPI createMessageEnvelope];
}

#pragma mark - CUSTOM DELEGATE

/**
 *  delegate method that calls up when parsing of promotion detail response completes
 *
 *  @param deal deal object of promotion
 */

-(void)finishedDealDetailParsingWithObject:(MWGPromotion *)deal
{
    if (!deal)
    {
        //error
        messageCompletionBlock(nil, [MWGError noDataResponseError]);
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
    }
    
    /**
     *  promotion detail request completed successfully
     */
    messageCompletionBlock(deal, [MWGError success]);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  delegate method that calls up when Deal Detail parser encouncounters an error
 *
 *  @param error error object
 */
-(void)finishedDealDetailParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

/**
 *  delegate method that calls up when parsing of Beacon list response completes
 *
 *  @param arrBeacon array of beacon list
 */
-(void)finishedBeaconParsingWithData:(NSArray *)arrBeacon
{
    //successful
    messageCompletionBlock(arrBeacon, [MWGError success]);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  delegate method that calls up when beacon parser encouncounters an error
 *
 *  @param error error object
 */
-(void)finishedBeaconParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

/**
 *  delegate method that calls up when parsing of login is completed
 *
 *  @param dict dictionary which contains the login related details like token value, status...
 */
-(void)finishedLoginParsingWithData:(NSDictionary *)dict
{
    // validate response
    if (!dict)
    {
        statusCompletionBlock([MWGError noDataResponseError]);
    }
    else
    {
        //check for server response
        NSString *strResponse = dict[@"res"];
        
        if (!strResponse)
        {
            statusCompletionBlock([MWGError noDataResponseError]);
        }
        else
        {
            if ([strResponse isEqualToString:@"1"] )
            {
                NSString *strToken = dict[@"token"];
                
                //check for access token
                if (strToken && ![strToken isEqualToString:@""])
                {
                    [USER_DEFAULT setObject:strToken forKey:LOGIN_AUTH_TOKEN];
                }
                else
                {
                    /*************************************
                     Need to discuss
                     *************************************/
                    // throw error
                }
                
                NSLog(@"User Logged in successfully.............");
                statusCompletionBlock([MWGError success]);
            }
            else
            {
                //fail
                NSLog(@"User login failed.............");
                
                statusCompletionBlock([MWGError authenticationFailedError]);
            }
        }
    }
    
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  delegate method that calls up when login parser encouncounters an error
 *
 *  @param error error object
 */
-(void)finishedLoginParsingWithError:(NSError *)error
{
    statusCompletionBlock(error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

/**
 *  delegate method that calls up when parsing of region is completed
 *
 *  @param arrRegions array of regions retrieved
 */
-(void)finishedRegionParsingWithData:(NSArray *)arrRegions
{
    //successful
    messageCompletionBlock(arrRegions, [MWGError success]);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  delegate method that calls up when region parser encounters an error
 *
 *  @param error error object
 */
-(void)finishedRegionParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

/**
 *  delegate method that calls up when parsing of User data is completed
 *
 *  @param arrUser array of user which contains all the user details
 */
-(void)finishedUserParsing
{
    //successful
    messageCompletionBlock(@YES, nil);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
    
}

/**
 *  delegate method that calls up when user parser encounters an error
 *
 *  @param error error object
 */
-(void)finishedUserParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

/**
 *  delegate method that calls up when parsing of promotion detail response completes
 *
 *  @param deal deal object of promotion
 */

-(void)finishedGeofenceParsingWithData:(NSArray *)arrGeofence
{
    /**
     *  request completed successfully
     */
    messageCompletionBlock(arrGeofence, [MWGError success]);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  delegate method that calls up when Deal Detail parser encouncounters an error
 *
 *  @param error error object
 */
-(void)finishedGeofenceParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  Delegate method called when get userdata parser finishes successfully
 *
 *  @param userData userdata processed
 */
-(void)finishedGetUserDataParsingWithData:(MWGUserData *)userData
{
    if (!userData)
    {
        /**
         *  error
         */
        messageCompletionBlock(nil, [MWGError noDataResponseError]);
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
    }
    
    /**
     *  request completed successfully
     */
    messageCompletionBlock(userData, [MWGError success]);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  Delegate method called when get userdata parser fails
 *
 *  @param error error object
 */
-(void)finishedGetUserDataParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}


/**
 *  Delegate method called when get stores parser finishes successfully
 *
 *  @param stores stores processed
 */
-(void)finishedGetStoresParsingWithData:(NSMutableArray *)stores
{
    if (!stores)
    {
        /**
         *  error
         */
        messageCompletionBlock(nil, [MWGError noDataResponseError]);
        
        // release MWGAPI Object
        [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
        
        return;
    }
    
    /**
     *  request completed successfully
     */
    messageCompletionBlock(stores, [MWGError success]);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

/**
 *  Delegate method called when get stores parser fails
 *
 *  @param error error object
 */
-(void)finishedGetStoresParsingWithError:(NSError *)error
{
    messageCompletionBlock(nil, error);
    
    // release MWGAPI Object
    [[MWGSDKMangerCore sharedInstance] releaseApiCall:self];
}

@end
