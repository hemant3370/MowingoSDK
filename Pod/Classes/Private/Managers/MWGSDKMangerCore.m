//
//  MWGSDKMangerCore.m
//  MowingoSDK
//
//  Created by Bellurbis on 4/21/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "MWGSDKMangerCore.h"
#import "MWGLocationServiceManager.h"
#import <sys/utsname.h>
#import "MWGConstants.h"
#import "MWGError.h"
#import "MWGAttributes.h"

@interface MWGSDKMangerCore ()
{
    /**
     *  Application version
     */
    NSString *strAppVersion;
    
    /**
     *  useer device token
     */
    NSString *apns_device_token;
    
    /**
     *  user latitude
     */
    double userLatitude;
    
    /**
     *  user longitude
     */
    double userLongitude;
    
    /**
     *  flag that sets when location is devived
     */
    BOOL isLocationDerived;
    
    /**
     *  flag that sets when APNS Device token is derived
     */
    BOOL isDeviceTokenDerived;
    
    /**
     *  property attributes
     */
    NSDictionary *property;
    
    /**
     *  stores access token for sdk
     */
    NSString *sdkAccessToken;
    
    /**
     *  flag if sdk is initialized completely
     */
    BOOL isInitialized;
    
    /**
     *  flag if SDk initialization is in progress
     */
    BOOL isInitializationInProgress;
    
    /**
     *  keeps instance of location service class
     */
    MWGLocationServiceManager *locationManager;
    
    /**
     *  Block for MWGInit method
     */
    typeof (void(^)(NSError *result)) completionBlock;
    
    NSMutableArray *arrRequestedNearBeaconRegion;
}

/**
 *  array of live API class instance
 */
@property(atomic) NSMutableArray *arrAPI;

@end


@implementation MWGSDKMangerCore

@synthesize user, beaconFlag, geofenceFlag, userPupUrl, userStatus, userPupText, userZipCode, userPupValue, userPhoneNumber, userEmailAddredd, deviceHashedUUIdStr, brandedStoreStr, notifyByLOC, notifyBySms, notifyByEmail;

@synthesize isInitialized, arrAPI, sdkAccessToken, baseUrl, isInitializationInProgress, sdkParameters, bluetoothOnFlag;

static MWGSDKMangerCore *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

/**
 * gets singleton object.
 * @return singleton
 */
+ (MWGSDKMangerCore*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[MWGSDKMangerCore alloc] init];
}

- (id)mutableCopy
{
    return [[MWGSDKMangerCore alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    //get app version
    strAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return self;
}

/**
 *  Method that initializes manager
 *
 *  @param userId   user id (device id)
 *  @param userName user name
 */
- (void)MWGSetUserWithUserId:(NSString *)userId
                 andUsername:(NSString*)userName
{
    self.user = [[MWGUser alloc] init];
    
    self.user.userId = userId;
    self.user.userName = userName;
}


#pragma mark - PUBLIC METHOD

/**
 *  Method to start initializing SDK
 *
 *  @param userName    user unique id
 *  @param isBeacons   beacon flag for beacon functionality activation
 *  @param isGeoFences geofences flag for geofencing functionality activation
 *  @param result      completion block, calls when MWGInit finishes
 */
- (void) MWGInitWithUniqueUserName:(NSString *)userName
                        beaconFlag:(BOOL)isBeacons
                     geofencesFlag:(BOOL)isGeoFences
                   completionBlock:(void(^)(NSError *result))block
{
    //start
    [self startInit];
    
    //observes when app comes to foreground from background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appComesToForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    //save beacon and geofence flag
    self.beaconFlag = isBeacons;
    self.geofenceFlag = isGeoFences;
    
    //save delegate
    completionBlock = block;
    
    
    // retreive access token(auth token) from user default
    // this auth token was saved during login cycle
    sdkAccessToken = [USER_DEFAULT objectForKey:LOGIN_AUTH_TOKEN];
    
    
    // check for property list file and configuration variables
    if (![self checkAndRetreiveConfigurationsFromPropertyFile])
    {
        //property file error
        if (completionBlock)
        {
            completionBlock([MWGError propertyListFileNotAvailable]);
        }
        
        //stop init with error
        [self finalizeInitWithError:YES];
        
        return;
    }
    
    //check iOS version is less than 7.1
    if (!IS_OS_7_1_OR_LATER)
    {
        //  raise error
        if (completionBlock)
        {
            completionBlock([MWGError beaconNotSupported]);
        }
        
        //stop init with error
        [self finalizeInitWithError:YES];
        
        return;
    }
    
    //set user id and user name
    [self MWGSetUserWithUserId:[self getDeviceUUId]
                   andUsername:userName];
    
    //start location service
    [self startLocationService];
}

/**
 *  Method to set device token
 *
 *  @param token token value
 */
-(void)MWGSetAPNSDeviceToken:(NSData *)token
{
    if (!token)
    {
        //if token is not there, error
        if (completionBlock)
        {
            completionBlock([MWGError APNSError]);
        }
        
    }
    else
    {
        //remove <> from device token data if exists
        apns_device_token = [[[[token description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];;
        
        
        //update Device token to service using xmluser web service
        MWGAPI *apiUserForNotification = [[MWGAPI alloc]init];
        
        [apiUserForNotification MWGUserWithDeviceName:machineName()
                                               osType:OS_TYPE
                                            osVersion:[[UIDevice currentDevice] systemVersion]
                                            emailFlag:NO
                                                email:@""
                                              smsFlag:NO
                                                phone:@""
                                     locationTracking:NO
                                                  zip:@""
                                          deviceToken:apns_device_token
                                      applicationName:APP_NAME
                                      completionBlock:^(NSNumber *isSuccess, NSError *result) {
                                          
                                          
                                      }];
        
        
        //set Yes to device token flaf
        if (!isDeviceTokenDerived)
        {
            isDeviceTokenDerived = YES;
        }
    }
}

/**
 *  Method to set User's Latitude & Longitude
 *
 *  @param latitude  User's Latitude
 *  @param longitude User's Longitude
 *  @param error an error object
 */
-(void)setUserLatitude:(double)latitude
          andLongitude:(double)longitude
                 error:(NSError *)error
{
    /*****************************************************
     
     Waiting for final decision over xmllin-xmluser issue
     
     ********************************************************/
    
    // set lat and long
    userLatitude = latitude;
    userLongitude = longitude;
    
    //check for error
    if (error)
    {
        // set location is derived
        if (isLocationDerived)
        {
            isLocationDerived = NO;
        }
        
        if (isInitializationInProgress)
        {
            //throw error
            if (completionBlock)
            {
                completionBlock(error);
            }
            
            //stop Init method with error
            [self finalizeInitWithError:YES];
        }
    }
    else
    {
        if (!isLocationDerived)
        {
            if (![self isInitialized])
            {
                // start authenticating user
                [self authenticateUserAndStartMonitoring];
            }
            
            isLocationDerived = YES;
        }
    }
    
}

/**
 *  Method to retrieve User's Latitude value
 *
 *  @return return value User's Latitude value
 */
-(double)retreiveUserLatitude
{
    return userLatitude;
}

/**
 *  Method to retrieve User's Longitude value
 *
 *  @return return value Longitude value
 */
-(double)retreiveUserLongitude
{
    return userLongitude;
}

/**
 *  Method to retrieve User's Device token
 *
 *  @return User's Device Token
 */
-(NSString *)retreiveAPNSDeviceToken
{
    if (apns_device_token && ![apns_device_token isEqualToString:@""])
    {
        // if valid device token
        return apns_device_token;
    }
    else
    {
        // if invalid device token
        return @"";
    }
}


/**
 *  Method to inform when beacon setup completed
 *
 *  @param error error object
 */
-(void)informBeaconSetupCompletionWithError:(NSError *)error
{
    if (error.code != MWG_SUCCESS)
    {
        if (isInitializationInProgress)
        {
            //throw error
            if (completionBlock)
            {
                completionBlock(error);
            }
            
            /*********************************************************
             *  MYB-31 If error is "bluetooth not enable" error
             *         show it as warning and let MWGInit continue
             ***********************************************************/
            
            if (error.code != MWG_BLUETOOTH_NOT_ENABLED)
            {
                //stop Init method with error
                [self finalizeInitWithError:YES];
                return;
            }
        }
    }
    
    // if geofencing is available
    if (geofenceFlag)
    {
        //start syncing geofences
        [[MWGLocationServiceManager getLocationManager] syncGeofenceList];
    }
    else
    {
        // initialization completed successfully
        [self finalizeInitWithError:NO];
    }
}


/**
 *  Method to inform when geofences setup completed
 *
 *  @param error error object
 */
-(void)informGeofenceSetupCompletionWithError:(NSError *)error
{
    if (error.code != MWG_SUCCESS)
    {
        if (isInitializationInProgress)
        {
            //throw error
            if (completionBlock)
            {
                completionBlock(error);
            }
            
            //stop Init method with error
            [self finalizeInitWithError:YES];
        }
    }
    else
    {
        // initialization completed successfully
        [self finalizeInitWithError:NO];
    }
}


/**
 *  Method that retains api call and avoid getting dealloc
 */
-(void)retainApiCall:(MWGAPI *)api
{
    // check if API array is alloced
    if (!self.arrAPI)
    {
        self.arrAPI = [[NSMutableArray alloc] init];
    }
    
    //check if API instance is already there in the API array
    if (![self.arrAPI containsObject:api])
    {
        [self.arrAPI addObject:api];
    }
}

/**
 *  Method that release api call and save memory
 */
-(void)releaseApiCall:(MWGAPI *)api
{
    // check if API array is alloced
    if (!self.arrAPI)
    {
        self.arrAPI = [[NSMutableArray alloc] init];
    }
    
    //check if API instance is already there in the API array
    if ([self.arrAPI containsObject:api])
    {
        [self.arrAPI removeObject:api];
    }
}


/**
 *  retrives base url
 *
 *  @return base url string
 */
-(NSString *)getBaseUrl
{
    NSString *strUrl;
    
    //check if base url is provided from property file
    if (baseUrl && ![baseUrl isEqualToString:@""])
    {
        //set property file as base url
        strUrl = baseUrl;
    }
    else
    {
        if (!property) {
            // get properfile data
            property = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MWGSDK"
                                                                                                    ofType:@"plist"]];
        }        
        
        // check environment configuration is available in property file
        NSString *strEnvironmentConfig = property[@"ENVIRONMENT"];
        
        if (strEnvironmentConfig && ![strEnvironmentConfig isEqualToString:@""])
        {
            // check if environment configuration has value TEST
            if ([property[@"ENVIRONMENT"] isEqualToString:@"TEST"])
            {
                // set default test url
                strUrl = BASE_URL_TEST;
            }
            // check if environment configuration has value PRODUCTION
            else if ([property[@"ENVIRONMENT"] isEqualToString:@"PRODUCTION"])
            {
                // set default production url
                strUrl = BASE_URL_PROD;
            }
            else
            {
                // return empty
                return nil;
            }
        }
        else
        {
            // check if SERVER_URL configuration is available
            NSString *strServerUrl = property[@"SERVER_URL"];
            
            if (strServerUrl && ![strServerUrl isEqualToString:@""])
            {
                // reteive server url value
                strUrl = strServerUrl;
            }
            else
            {
                // return empty
                return nil;
            }
        }
    }
    
    //check if url contains "/" at the end, if not add / at end
    if (![strUrl hasSuffix:@"/"])
    {
        return [NSString stringWithFormat:@"%@/", strUrl];
    }
    
    //return base url
    return strUrl;
}



#pragma mark - PRIVATE METHODS

// authethenticates use and start beacon/geofencing monitoring
-(void)authenticateUserAndStartMonitoring
{
    MWGAPI *apiUser = [[MWGAPI alloc] init];
    
    // autheticate user
    [apiUser MWGUserWithDeviceName:machineName()
                            osType:OS_TYPE
                         osVersion:[[UIDevice currentDevice] systemVersion]
                         emailFlag:NO
                             email:@""
                           smsFlag:NO
                             phone:@""
                  locationTracking:NO
                               zip:@""
                       deviceToken:apns_device_token
                   applicationName:APP_NAME
                   completionBlock:^(NSNumber *isSuccess, NSError *result) {
                       
                       if (result)
                       {
                           if (isInitializationInProgress)
                           {
                               //throw error
                               if (completionBlock)
                               {
                                   completionBlock([MWGError sdkInitializationFailure]);
                               }
                               
                               //stop Init method with error
                               [self finalizeInitWithError:YES];
                           }
                       }
                       else
                       {
                           if ([isSuccess boolValue])
                           {
                               /********************************************************
                                ###note
                                Retreive setting was there in McD App. currently keeping it
                                commented
                                *********************************************************/
//                               [self retriveSettings];
                               
                               //register for APNS
                               [self registerForAPNS];
                               
                               // if beacon is available
                               if (beaconFlag)
                               {
                                   //start syncing beacons
                                   [[MWGLocationServiceManager getLocationManager] syncBeaconList];
                               }
                               else
                               {
                                   // if geofencing is available
                                   if (geofenceFlag)
                                   {
                                       //start syncing geofences
                                       [[MWGLocationServiceManager getLocationManager] syncGeofenceList];
                                   }
                                   else
                                   {
                                       // initialization completed successfully
                                       [self finalizeInitWithError:NO];
                                   }
                               }
                               
                               //                                           //execute any pending task
                               //                                           if (pendingTasks && [pendingTasks count] > 0)
                               //                                           {
                               //                                               for (NSInvocation *invocation in pendingTasks)
                               //                                               {
                               //                                                   [invocation invoke];
                               //                                               }
                               //                                           }
                           }
                           else
                           {
                               if (isInitializationInProgress)
                               {
                                   // authentication failed
                                   [self finalizeInitWithError:YES];
                                   
                                   // throw error
                                   if (completionBlock)
                                   {
                                       completionBlock([MWGError sdkInitializationFailure]);
                                   }
                               }
                           }
                       }
                   }];
}

/**
 *  method to start location service
 */
-(void)startLocationService
{
    //start location service
    locationManager = [MWGLocationServiceManager getLocationManager];
    [locationManager startUpdatingLocation];
}

/**
 *  method calls when app comes to foreground
 */
-(void)appComesToForeground
{
    /*********************************************
     *  LOCATION SERVICE CHECK
     ************************************************/
    
    //check location server is enabled
    if (![self isLocationServiceEnabled])
    {
        if (isInitialized)
        {
            //location service not enabled by user
            if (completionBlock)
            {
                completionBlock([MWGError locationServiceError]);
            }
        }
        
        //set location derived flag
        if (isLocationDerived)
        {
            isLocationDerived = NO;
        }
    }
    else
    {
        //set location derived flag
        if (!isLocationDerived)
        {
            isLocationDerived = YES;
        }
    }
    
    
    /*********************************************
     *  APNS CHECK
     ************************************************/
    
    //check if APNS is enabled for app
    if (![self isAPNSEnabled])
    {
        //APNS is not enabled
        if (isInitialized)
        {
            if (completionBlock)
            {
                completionBlock([MWGError APNSError]);
            }
        }
        
        //set APNS flag
        if (isDeviceTokenDerived)
        {
            isDeviceTokenDerived = NO;
        }
    }
    else
    {
        //APNS is already enable
        if (!isDeviceTokenDerived)
        {
            isDeviceTokenDerived = YES;
        }
    }
}

/**
 *  check location server is enabled
 *
 *  @return Yes if location service is enabled otherwise NO
 */
-(BOOL)isLocationServiceEnabled
{
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        //if enabled
        return YES;
    }
    else
    {
        //not enable
        return NO;
    }
}

/**
 *  check if APNS is enabled for app
 *
 *  @return Yes if APNS is enabled otherwise NO
 */
-(BOOL)isAPNSEnabled
{
    //check for device token
    if (apns_device_token)
    {
        //for iOS 8
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
        {
            if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
            {
                //APNS is enabled
                return YES;
            }
            else
            {
                //not enabled
                return NO;
            }
            
        }
        else
        {
            //for ios 7
            UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
            if (types == UIRemoteNotificationTypeNone)
            {
                //not enabled
                return NO;
            }
            else
            {
                //APNS is enabled
                return YES;
            }
        }
    }
    else
    {
        return NO;
    }
}

/**
 *  Method to retrieve User's Settings
 */
- (void)retriveSettings
{
    NSDictionary *dictionary = [self retriveUserDetails];
    
    NSNumber *emailNotification = [dictionary objectForKey:@"EMAIL_NOTIFICATION"];
    NSNumber *smsNotification = [dictionary objectForKey:@"SMS_NOTIFICATION"];
    NSNumber *locNotification = [dictionary objectForKey:@"LOC_NOTIFICATION"];
    
    [self setUserEmailAddredd:[dictionary objectForKey:@"USER_EMAIL"]];
    [self setUserPhoneNumber:[dictionary objectForKey:@"USER_PHONE_NUMBER"]];
    [self setUserZipCode:[dictionary objectForKey:@"USER_ZIPCODE"]];
    [self setUserStatus:[dictionary objectForKey:@"USER_STATUS"]];
    [self setBrandedStoreStr:[dictionary objectForKey:@"BRANDED_STORE_STR"]];
    
    [self setNotifyByEmail:[emailNotification boolValue]];
    [self setNotifyBySms:[smsNotification boolValue]];
    [self setNotifyByLOC:[locNotification boolValue]];
}


/**
 *  Retrieve User's Details
 *
 *  @return returns Dictionary of User's Details
 */
- (NSDictionary *)retriveUserDetails
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dataCacheDirPath = [docsPath stringByAppendingPathComponent:@"UserDefaultsDir"];
    
    NSString *dataFileName = [NSString stringWithFormat:@"%@",USER_INFO_FILE_NAME];
    
    NSString *dataCachePath = [dataCacheDirPath stringByAppendingPathComponent:dataFileName];
    
    NSDictionary *theUserDict =[[NSDictionary alloc] initWithContentsOfFile:dataCachePath];
    return theUserDict;
}

/**
 *  Method to get Device UUID
 *
 *  @return returns device UUID
 */
- (NSString *)getDeviceUUId
{
    NSString *idForVendor = [[NSUserDefaults standardUserDefaults] objectForKey:@"unique identifier stored for app"];
    
    
    if (!idForVendor || [idForVendor isEqualToString:@""] || [idForVendor isEqualToString:@"(null)"])
    {
        //if idForVendor string is not allocated or idForVendor is allocated but contains String '(null)'.
        //This happens in case of userDefaults that sometimes if value is not present for the specified key, it returns a string value (null) and gets allocated
        
        idForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//retrieve the uuid value of device.
        
        //set the retrieved uuid value to user default for specified key(unique identifier stored for app)
        [[NSUserDefaults standardUserDefaults] setObject:idForVendor forKey:@"unique identifier stored for app"];
        
        //now force the user default to accept the change immediately.
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Vendor Id is::2nd:%@",idForVendor);
        return  idForVendor;
    }
    
    //if we already have a valid uuid
    
    NSLog(@"Vendor Id is::1st:%@",idForVendor);
    return idForVendor;
}

/**
 *  Checks and loads property file's configuration values
 *
 *  @return Yes, if configuration values are successfully retreived otherwise NO
 */
-(BOOL)checkAndRetreiveConfigurationsFromPropertyFile
{
    // get properfile data
    property = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MWGSDK"
                                                                                            ofType:@"plist"]];
    
    //check property file is available
    if (!property)
    {
        return NO;
    }
    
    // check if SDK already have access token (auth token) in user-default, saved while login
    if (!sdkAccessToken || [sdkAccessToken isEqualToString:@""])
    {
        //retreive access token from property file
        sdkAccessToken = property[@"MWG_SDK_ACCESS_TOKEN"];
        
        //check access token
        if (sdkAccessToken && [sdkAccessToken isEqualToString:@""])
        {
            return NO;
        }
    }

    //set base URL
    baseUrl = [self getBaseUrl];
    
    // error in retreiving base url
    if (!baseUrl || [baseUrl isEqualToString:@""])
    {
        return NO;
    }
    
    return YES;
}


/**
 *  Finalize flags for MWGInit
 *
 *  @param iserror Yes if MWGInit finishes with error otherwise No
 */
-(void)finalizeInitWithError:(BOOL)iserror
{
    // set NO to Init in progress flag
    if (isInitializationInProgress)
    {
        isInitializationInProgress = NO;
    }
    
    //set isInitialized Flag
    if (iserror)
    {
        //if MWGInit stopped due to some error
        if (isInitialized)
        {
            isInitialized = NO;
        }
        
        // disable beacon and geofence
        self.beaconFlag = NO;
        self.geofenceFlag = NO;
        
        baseUrl = nil;
        completionBlock = nil;
        
    }
    else
    {
        // if MWGINIT finishes successfully
        if (!isInitialized)
        {
            isInitialized = YES;
            
            //call completion block
            if (completionBlock)
            {
                completionBlock([MWGError success]);
            }
        }
    }
}


/**
 *  start MWGINit and set flags
 */
-(void)startInit
{
    // set NO to Init in progress flag
    if (!isInitializationInProgress)
    {
        isInitializationInProgress = YES;
    }
    
    //if MWGInit stopped due to some error
    if (isInitialized)
    {
        isInitialized = NO;
    }
}

/**
 *  starts application APNS registeration process
 */
-(void) registerForAPNS
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}


// retreive device name
NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:APP_DATA_ENCODING];
}

/**
 *  check if device is inside the vicinity of given beacon region.
 *
 *  @param beaconRegion beacon region
 *
 *  @return Flag, if Yes, the device is under the vicinity of given beacon region.
 */
- (NSNumber *) isNearBeacon:(MWGBeaconRegionCore *)beaconRegion
{
    // get list of in beacons
    NSArray *arrInBeacon = [locationManager getInBeaconList];
    
    for (MWGBeaconCore *beaconObject in arrInBeacon) {
        if ([self checkBeaconRegion:beaconRegion isEqualToBeaconRegion:beaconObject]) {
            return @YES;
        }
    }
    
    return @NO;
}


- (BOOL) checkBeaconRegion:(MWGBeaconRegionCore *)region1
     isEqualToBeaconRegion:(MWGBeaconCore *)region2
{
    if (region1 && region2) {
        
        // UUID of beacon
        if (region1.beaconUUID &&
            region2.budid)
        {
            if (![[region1.beaconUUID UUIDString] isEqualToString:region2.budid]) {
                return NO;
            }
        }
        else
        {
            return NO;
        }
        
        // major of beacon
        if (region1.beaconMajor &&
            region2.major)
        {
            if ([region1.beaconMajor intValue] != [region2.major intValue]) {
                return NO;
            }
        }
        
        // minor of beacon
        if (region1.beaconMinor &&
            region2.minor)
        {
            if ([region1.beaconMinor intValue] != [region2.minor intValue]) {
                return NO;
            }
        }
        
    } else {
        return NO;
    }
    
    return YES;
}


- (void)retainBeaconRegion:(id)region
{
    if (!arrRequestedNearBeaconRegion) {
        arrRequestedNearBeaconRegion = [[NSMutableArray alloc] init];
    }
    
    [arrRequestedNearBeaconRegion addObject:region];
}

- (void) releaseBeaconRegion:(id)region
{
    if (arrRequestedNearBeaconRegion)
    {
        [arrRequestedNearBeaconRegion removeObject:region];
    }
}

@end
