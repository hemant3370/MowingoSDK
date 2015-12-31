//
//  MWGLocationServiceManager.m
//  MowingoSDK
//
//  Created by Bellurbis on 5/3/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "MWGLocationServiceManager.h"
#import "MWGSDKMangerCore.h"
#import "MWGGeofence.h"
#import "MWGError.h"
#import "MWGAttributes.h"

#define BEACON_RANGING_ON       0

#define BEACON_RANGING_CALL_TIMEOUT     5.0


@implementation MWGLocationServiceManager

static MWGLocationServiceManager *SINGLETON = nil;

static bool isFirstAccess = YES;

@synthesize beaconFlag, geofenceFlag;

#pragma mark - Public Method

/**
 * gets singleton location service menager object.
 * @return location service menager singleton
 */
+ (id)getLocationManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

// constructor for MWGLocationServiceManager class
+ (id) allocWithZone:(NSZone *)zone
{
    return [self getLocationManager];
}

// constructor for MWGLocationServiceManager class
+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self getLocationManager];
}

// constructor for MWGLocationServiceManager class
+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self getLocationManager];
}

// constructor for MWGLocationServiceManager class
- (id)copy
{
    return [[MWGLocationServiceManager alloc] init];
}

// constructor for MWGLocationServiceManager class
- (id)mutableCopy
{
    return [[MWGLocationServiceManager alloc] init];
}

// constructor for MWGLocationServiceManager class
- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    if (self = [super init])
    {
        [self initialization];//initialization started
    }
    
    return self;
}


/**
 *  configure and initialize location manager class
 */
-(void)initialization
{
    self.pausesLocationUpdatesAutomatically = YES; //A Boolean value indicating whether the location manager object may pause location updates.
    self.delegate = self;
    self.desiredAccuracy = kCLLocationAccuracyBest;  //setting best accuracy of the location data
//    [self setLocationDisabled:NO];
    
    //retreovong beacon and geofence enabled flag
    beaconFlag = [[MWGSDKMangerCore sharedInstance] beaconFlag];
    geofenceFlag = [[MWGSDKMangerCore sharedInstance] geofenceFlag];
    
    
    /**
     *  Requests permission to use location services whenever the app is running.
     */
    if (beaconFlag || geofenceFlag)
    {
        if ([self respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self requestAlwaysAuthorization];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self requestWhenInUseAuthorization];
        }
    }
    
    //observes when app comes to foreground from background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appComesToForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //observes when app goes to background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoesToBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


#pragma mark - Beacon 

/**
 *  beacon detection initialization and configuration
 */
-(void)initialiseBeacon
{
    if (!isBeaconIntiated)
    {
        // reads beacon file and fill arrBeacon varible with beacons object
        [self readBeaconJsonFile];
        
        // load in beacon from user default
        NSArray *arr =[self loadInBeacons];
        
        if (arr && [arr count] > 0)
        {
            arrInBeacons = [[NSMutableArray alloc] initWithArray:arr];
            
            if (BEACON_RANGING_ON)
            {
                if (arrInBeacons && [arrInBeacons count] > 0)
                {
                    // start beacon ranging mechanism
                    [self activateBeaconRanging];
                    
                    //start ranging for in beacons
                    for (MWGBeaconCore *beacon in arrInBeacons)
                    {
                        [self startRangingForBeacon:beacon];
                    }
                }
            }
        }
        
        // start mnitoring for beacons
        for (MWGBeaconCore *beaconTemp in arrBeacons)
        {
            [self startMontoringBeacon:beaconTemp];
        }
        
        // update beacon initialize flag
        if(!isBeaconIntiated)
            isBeaconIntiated = YES;
    }
}

/**
 *  start beacon monitoring for specified beacon object
 *
 *  @param beacon a beacon object
 */
-(void)startMontoringBeacon:(MWGBeaconCore *)beacon
{
    CLBeaconRegion *beaconRegion = [self getBeaconRegionFromBeacon:beacon];
    
    if (!beaconRegion)
    {
        return;
    }
    
    NSLog(@"\n\nBeacon monitoring started UUID: %@, Major: %@, Minor: %@\n\n", [beaconRegion.proximityUUID UUIDString],
          beaconRegion.major,
          beaconRegion.minor);
    
    // now start monitoring for beacon
    beaconRegion.notifyOnExit = YES;
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self startMonitoringForRegion:beaconRegion];
}

-(void) startRangingForBeacon: (MWGBeaconCore *)beacon
{
    CLBeaconRegion *beaconRegion = [self getBeaconRegionFromBeacon:beacon];
    
    if (!beaconRegion)
    {
        return;
    }
    
    // start ranging for beacon
    [self startRangingBeaconsInRegion:beaconRegion];
}

/**
 *  starts beacon ranging
 */
- (void) activateBeaconRanging
{
    if (!isRangingActive)
    {
        isRangingActive = YES;
        
        // start beacon ranging
        [self performSelector:@selector(callRangingWebService)
                   withObject:nil
                   afterDelay:BEACON_RANGING_CALL_TIMEOUT];
    }
}

/**
 *  stops beacon ranging mechanism
 */
- (void) deactivateBeaconRanging
{
    if (isRangingActive)
    {
        isRangingActive = NO;
        
        // stop beacon ranging
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(callRangingWebService)
                                                   object:nil];
    }
}

/**
 *  stops beacon detection monitoring for specified beacon object
 *
 *  @param beacon beacon object
 */
-(void)stopMontoringBeacon:(MWGBeaconCore *)beacon
{
    CLBeaconRegion *beaconRegion = [self getBeaconRegionFromBeacon:beacon];
    
    if (!beaconRegion)
    {
        return;
    }
    
    //now stop monitring for beacon
    [self stopMonitoringForRegion:beaconRegion];
}

/**
 *  constructs beacon region with given beacon object
 *
 *  @param beacon beacon object
 *
 *  @return beacon region
 */
-(CLBeaconRegion *)getBeaconRegionFromBeacon:(MWGBeaconCore *)beacon
{
    BOOL isMajor;
    BOOL isMinor;
    
    // validate uuid of beacon
    NSString *strUUID = beacon.budid;
    int major = -1;
    int minor = -1;
    
    NSString *strBid = beacon.bid;
    
    // checking UUID
    if (strUUID && ![strUUID isEqualToString:@""])
    {
        if (![self isUUID:strUUID])
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
    
    //checking beacon id -->  bid
    if (!strBid ||
        [strBid isEqualToString:@""])
    {
        return nil;
    }
    
    // validate major of beacon
    if (beacon.major &&
        ![beacon.major isEqualToString:@""] &&
        ![beacon.major isEqualToString:@"0"])
    {
        major = [[beacon.major stringByReplacingOccurrencesOfString:@" " withString:@""] intValue];
        
        if (major < 1 || major > 65536)
        {
            isMajor = NO;
        }
        else
        {
            isMajor = YES;
        }
        
    }
    else
    {
        isMajor = NO;
    }
    
    //validate minor of beacon
    if (beacon.minor &&
        ![beacon.minor isEqualToString:@""] &&
        ![beacon.minor isEqualToString:@"0"])
    {
        minor = [[beacon.minor stringByReplacingOccurrencesOfString:@" " withString:@""] intValue];
        
        if (minor < 1 || minor > 65536)
        {
            isMinor = NO;
        }
        else
        {
            isMinor = YES;
        }
    }
    else
    {
        isMinor = NO;
    }
    
    // convert uuis string into uuid object
    NSUUID *uuidBeacon = [[NSUUID alloc] initWithUUIDString:strUUID];
    
    
    if (uuidBeacon)
    {
        // create a new beacon identifier
        NSString *beaconIdentifier = [NSString stringWithFormat:@"%@.%@.%@.%@",
                                      strBid,
                                      strUUID,
                                      beacon.major,
                                      beacon.minor];
        
        if (isMinor && isMajor)
        {
            // get beacon region object for specified beacon object having uuid, major, minor, and bid
            return [[CLBeaconRegion alloc] initWithProximityUUID:uuidBeacon
                                                           major:major
                                                           minor:minor
                                                      identifier:beaconIdentifier];
        }
        else if (isMajor && !isMinor)
        {
            return [[CLBeaconRegion alloc] initWithProximityUUID:uuidBeacon
                                                           major:major
                                                      identifier:beaconIdentifier];
        }
        else if (!isMajor && !isMinor)
        {
            return [[CLBeaconRegion alloc] initWithProximityUUID:uuidBeacon
                                                      identifier:beaconIdentifier];
        }
        
    }
    
    return nil;
}

/**
 *  Reads beacon json file, that contains list of beacon
 */
-(void)readBeaconJsonFile
{
    //get raw beacon list data from beacon json file
    NSData *beaconData = [NSData dataWithContentsOfFile:[self getJsonFile:BEACON_LIST_FILE]];
    
    if (beaconData)
    {
        // convert beacon json data to equivalent beacon dictionary
        NSDictionary *dictBeacon = [NSJSONSerialization JSONObjectWithData:beaconData options:kNilOptions error:nil];
        
        // convert beacon dictionary to beacon bject and load arrBeacons
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dictTemp in [dictBeacon objectForKey:beacon_master])
        {
            [arrTemp addObject:[[MWGBeaconCore alloc] initWithDictionary:dictTemp]];
        }
        
        arrBeacons = [NSArray arrayWithArray:arrTemp];
    }
}

// saves in-beacon list to user defaults
-(void)saveInBeacons:(NSArray *)arrayInBeacons
{
    NSData *encodedBeacon = [NSKeyedArchiver archivedDataWithRootObject:arrayInBeacons];
    [USER_DEFAULT setObject:encodedBeacon forKey:kDefaultInBeacons];
    [USER_DEFAULT synchronize];
}

// loads in-beacon list from user defaults
-(NSArray *)loadInBeacons
{
    NSData *encodedBeacon = [USER_DEFAULT objectForKey:kDefaultInBeacons];
    return [NSKeyedUnarchiver unarchiveObjectWithData: encodedBeacon];
}

/**
 *  download new list of beacon
 */
-(void)syncBeaconList
{
    MWGAPI *apiBeacon = [[MWGAPI alloc] init];
    
    //start downloading beacon list
    [apiBeacon MWGGetBeaconListWithCompletionBlock:^(NSArray *beacons, NSError *result) {
        
        if (result)
        {
            if (result.code == MWG_SUCCESS)
            {
                // save list to disk and start monitoring new beacon
                [self saveAndStartMonitoringForBeacon:beacons];
            }
        }
        
        // notify beacon sync is complete
        [[MWGSDKMangerCore sharedInstance] informBeaconSetupCompletionWithError:result];
    }];
}

/**
 *  save and start monitoring fr new list of beacon
 *
 *  @param arrBeaconList downloaded list of beacon
 */
-(void)saveAndStartMonitoringForBeacon:(NSArray *)arrBeaconList
{
    if (!arrBeaconList || [arrBeaconList count] < 1)
    {
        return;
    }
    
    //converts beacon object to beacon dictionary
    NSMutableArray *arr =  [[NSMutableArray alloc] init];
    for (MWGBeaconCore *beacon in arrBeaconList)
    {
        [arr addObject:[beacon beaconDictionary]];
    }
    
    //convert beacon dictionary list into json data
    NSMutableDictionary *dictBeacon = [[NSMutableDictionary alloc] init];
    
    [dictBeacon setValue:arr forKey:beacon_master];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictBeacon
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    
    //get beacon file path and save new beacon list into file
    NSString *beaconFilePath = [self getJsonFile:BEACON_LIST_FILE];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if ([filemanager fileExistsAtPath:beaconFilePath])
    {
        [filemanager removeItemAtPath:beaconFilePath error:nil];
    }
    
    //write to beacon file
    BOOL val = [jsonData writeToFile:beaconFilePath atomically:NO];
    
    if (val)
    {
        /**
         *  stop monitoring for old beacons
         */
        for (MWGBeaconCore *beacon in arrBeacons)
        {
            [self stopMontoringBeacon:beacon];
        }
        
        //refresh beacon array
        if(isBeaconIntiated)
            isBeaconIntiated = NO;
        
        [self detectBluetooth];
    }
}

/**
 *  get beacon id for detected region and informs server for the beacon detected
 *
 *  @param beaconRegion beacon regin detected
 *  @param status       device status for beacon region specified
 */
-(void)getBeaconIdForRegion:(CLBeaconRegion *)beaconRegion andInformServerForStatus:(MWGBeaconState)status
{
    //get beacon element index in arrBeacon for beacon region
    int index = (int)[arrBeacons indexOfObjectPassingTest:^(MWGBeaconCore* obj, NSUInteger idx, BOOL *stop){
        
        // checks if current beacon is related to specified beacon region
        return [self checkBeaconRegion:beaconRegion isEqualToBeacon:obj];
    }];
    
    if (index > -1 && index < [arrBeacons count])
    {
        if (index < arrBeacons.count)
        {
            //get beacon object for specified beacon region
            MWGBeaconCore *beaconObj = arrBeacons[index];
            
            if (beaconObj)
            {
                if (status == MWGBeaconIn)
                {
                    //for in
                    if (!arrInBeacons)
                    {
                        arrInBeacons = [[NSMutableArray alloc] init];
                    }
                    
                    // check beacon is already in in-beacon list
                    if ([self beaconArray:arrInBeacons containsBeacon:beaconObj] == -1)
                    {
                        // if beacon is not in in-beacon list, add the beacon into list
                        [arrInBeacons addObject:beaconObj];
                        
                        //save new in-beacon list into user default
                        [self saveInBeacons:arrInBeacons];
                        
                        if (BEACON_RANGING_ON)
                        {
                            //start ranging for beacon region
                            [self startRangingBeaconsInRegion:beaconRegion];
                            
                            if (arrInBeacons && [arrInBeacons count] > 0)
                            {
                                // start beacon ranging mechanism
                                [self activateBeaconRanging];
                            }
                        }
                        
                        // if beacon bject has inTxt then fire local notificatin
                        NSString *strMsg = beaconObj.inTxt;
                        
                        if (strMsg && ![strMsg isEqualToString:@""])
                        {
                            [self fireLocalNotificationWithMessage:strMsg];
                        }
                        
                        //inform server for detected beacon region
                        [self callBeaconInfoWebServiceForBeacon:beaconObj forInOut:status];
                    }
                }
                else
                {
                    //for out
                    if (arrInBeacons && [arrInBeacons count] > 0)
                    {
                        int indexBeacon = [self beaconArray:arrInBeacons containsBeacon:beaconObj];
                        
                        // check beacon is in in-beacon list
                        if (indexBeacon != -1)
                        {
                            // if beacon is in in-beacon list, remove beacon from list
                            [arrInBeacons removeObjectAtIndex:indexBeacon];
                            
                            //save new in-beacon list into user default
                            [self saveInBeacons:arrInBeacons];
                            
                            if (BEACON_RANGING_ON)
                            {
                                //stop ranging for beacon region
                                [self stopRangingBeaconsInRegion:beaconRegion];
                                
                                if (!arrInBeacons || [arrInBeacons count] < 1)
                                {
                                    // stop beacon ranging mechanism
                                    [self deactivateBeaconRanging];
                                }
                            }
                            
                            // if beacon bject has outTxt then fire local notificatin
                            NSString *strMsg = beaconObj.outText;
                            
                            if (strMsg && ![strMsg isEqualToString:@""])
                            {
                                [self fireLocalNotificationWithMessage:strMsg];
                            }
                            
                            //inform server for detected beacon region
                            [self callBeaconInfoWebServiceForBeacon:beaconObj forInOut:status];
                        }
                    }
                }
            }
        }
    }
}

/**
 *  checks if specified beacon region is linked to specied beacon object
 *
 *  @param region    beacon region
 *  @param beaconObj beacon object
 *
 *  @return returns YES if beacon region is linked to beacon object otherwise returns NO
 */
-(BOOL)checkBeaconRegion:(CLBeaconRegion *)region isEqualToBeacon:(MWGBeaconCore *)beaconObj
{
    //check if beacon region  uuid is equal to beacon object uuid
    if (![[beaconObj.budid lowercaseString] isEqualToString:[[[region proximityUUID] UUIDString] lowercaseString] ])
    {
        return NO;
    }
    
    if (beaconObj.major && ![beaconObj.major isEqualToString:@""])
    {
        //check if beacon region  major is equal to beacon object major
        if (![beaconObj.major isEqualToString:[NSString stringWithFormat:@"%@", region.major]])
        {
            return NO;
        }
    }
    
    if (beaconObj.minor && ![beaconObj.minor isEqualToString:@""])
    {
        //check if beacon region  minor is equal to beacon object minor
        if (![beaconObj.minor isEqualToString:[NSString stringWithFormat:@"%@", region.minor]])
        {
            return NO;
        }
    }
    
    return YES;
}

/**
 *  checks if specified beacon is linked to specied beacon object
 *
 *  @param beaconNative    beacon
 *  @param beaconNative1 beacon
 *
 *  @return returns YES if beacon is linked to beacon object otherwise returns NO
 */
-(BOOL)checkBeacon:(CLBeacon *)beaconNative1 isEqualToBeacon:(CLBeacon *)beaconNative2
{
    //check if beacon region  uuid is equal to beacon object uuid
    if (![[[beaconNative1.proximityUUID UUIDString] lowercaseString] isEqualToString:[[[beaconNative2 proximityUUID] UUIDString] lowercaseString] ])
    {
        return NO;
    }
    
    if (beaconNative1.major)
    {
        //check if beacon region  major is equal to beacon object major
        if ([beaconNative1.major intValue] != [beaconNative2.major intValue])
        {
            return NO;
        }
    }
    
    if (beaconNative1.minor)
    {
        //check if beacon region  minor is equal to beacon object minor
        if ([beaconNative1.minor intValue] != [beaconNative2.minor intValue])
        {
            return NO;
        }
    }
    
    return YES;
}


/**
 *  call xmlbeacon api to inform server for specified beacon with its state
 *
 *  @param beaconObj beacon object
 *  @param inOut     state of device with respect to beacon object's region
 */
-(void)callBeaconInfoWebServiceForBeacon:(MWGBeaconCore *)beaconObj forInOut:(MWGBeaconState)inOut
{
    
    MWGAPI *apiBeacon = [[MWGAPI alloc] init];
    [apiBeacon MWGBeacon:beaconObj.bid withBeaconState:inOut];
}


/**
 *  checks if beacon array contains specified beacon object
 *
 *  @param arr      array of beacons
 *  @param geofence beacon
 *
 *  @return index of beacon in geofence array
 */
-(int)beaconArray:(NSArray *)arr containsBeacon:(MWGBeaconCore *)beacon
{
    int count=-1;
    
    //iterate all geofence in array
    for (MWGBeaconCore *beaconTemp in arr)
    {
        count++;
        
        //if specified geofence's id is equal to current geofence 's id
        if ([beacon.bid isEqualToString:beaconTemp.bid])
        {
            //ok
            return count;
        }
    }
    
    //geofence not found
    return -1;
}

-(void)callRangingWebService
{
    if (arrRangingBeacons && [arrRangingBeacons count] > 0)
    {
        MWGAPI *apiRange = [[MWGAPI alloc] init];
        
        // call ranging beacon API
        [apiRange MWGBeaconRangingWithBeacons:arrRangingBeacons
                          withCompletionBlock:^(NSError *result) {
                              
                              if (result)
                              {
                                  if (result.code != MWG_SUCCESS)
                                  {
                                      
                                  }
                              }
                              
                              
                          }];
        
        // reset ranging beacon array and ranging service calls
        arrRangingBeacons = [[NSMutableArray alloc] init];
        
        // start beacon ranging
        [self performSelector:@selector(callRangingWebService)
                   withObject:nil
                   afterDelay:BEACON_RANGING_CALL_TIMEOUT];
    }
}


#pragma mark - Geofence

/**
 *  geofencing initialization and configuration
 */
-(void)initialiseGeofence
{
    if (!isGeofenceInitiated)
    {
        // reads geofence file and fill arrGeofence varible with geofence object
        [self readGeofenceJsonFile];
        
        // load in geofence from user default
        NSArray *arr =[self loadInGeofence];
        
        if (arr && [arr count] > 0)
        {
            arrInGeofences = [[NSMutableArray alloc] initWithArray:arr];
        }
        
        //start monitoring of geofence object
        for (MWGGeofence *geofenceTemp in arrGeofences)
        {
            [self startMontoringGeofence:geofenceTemp];
        }
        
        // updete geofence initialization flag
        if (!isGeofenceInitiated)
            isGeofenceInitiated = YES;
    }
}


/**
 *  start geofence monitoring for specified geofence object
 *
 *  @param geofence geofence object
 */
-(void)startMontoringGeofence:(MWGGeofence *)geofence
{
    NSString *strId = geofence.gfid;  //geofence id
    CLLocationDegrees latitude = [geofence.gflat doubleValue];  //geofence latitute
    CLLocationDegrees longitude =[geofence.gflon doubleValue];  //geofence longitude
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);  //geofence centre coordinates
    CLLocationDistance regionRadius = [geofence.radius doubleValue];  //geofence actual radius
    
    // if actual geofence radius is greater than maximum allowed radius and set maximum allowed radius
    if(regionRadius > self.maximumRegionMonitoringDistance)
    {
        regionRadius = self.maximumRegionMonitoringDistance;
    }
    
    //create reagon for geofence
    CLRegion * geofenceRegion =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                                   radius:regionRadius
                                                               identifier:strId];
    
    if (!geofenceRegion)
    {
        return;
    }
    
    //start monitoring for geofence region
    geofenceRegion.notifyOnExit = YES;
    geofenceRegion.notifyOnEntry = YES;
    
    [self startMonitoringForRegion:geofenceRegion];
    
    NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:[deviceLocation coordinate]
                                                                              coord:centerCoordinate];
    
    if([currentLocationDistance floatValue] < regionRadius)
    {
        //stop Monitoring Region temporarily
        [self stopMonitoringForRegion:geofenceRegion];
        
        [self locationManager:self didEnterRegion:geofenceRegion];
        
        //start Monitoing Region again.
        [self startMonitoringForRegion:geofenceRegion];
    }
}


/**
 *  stop geofence monitoring for specified geofence object
 *
 *  @param geofence geofence object
 */
-(void)stopMontoringGeofence:(MWGGeofence *)geofence
{
    NSString *strId = geofence.gfid;  //geofence id
    CLLocationDegrees latitude = [geofence.gflat doubleValue];  //geofence latitute
    CLLocationDegrees longitude =[geofence.gflon doubleValue];  //geofence longitude
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);  //geofence centre coordinates
    CLLocationDistance regionRadius = [geofence.radius doubleValue];  //geofence actual radius
    
    
    // if actual geofence radius is greater than maximum allowed radius and set maximum allowed radius
    if(regionRadius > self.maximumRegionMonitoringDistance)
    {
        regionRadius = self.maximumRegionMonitoringDistance;
    }
    
    //create reagon for geofence
    CLRegion * geofenceRegion =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                                   radius:regionRadius
                                                               identifier:strId];
    
    if (!geofenceRegion)
    {
        return;
    }
    
    //stop monitoring for region
    [self stopMonitoringForRegion:geofenceRegion];
}


/**
 *  Reads geofence json file, that contains list of geofence
 */
-(void)readGeofenceJsonFile
{
    //get raw geofence list data from geofence json file
    NSData *geofenceData = [NSData dataWithContentsOfFile:[self getJsonFile:GEOFENCE_LIST_FILE]];
    
    if (geofenceData)
    {
        // convert geofence json data to equivalent geofence dictionary
        NSDictionary *dictGeofence = [NSJSONSerialization JSONObjectWithData:geofenceData options:kNilOptions error:nil];
        
        // convert geofence dictionary to geofence bject and load arrGeofence
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dictTemp in [dictGeofence objectForKey:geofence_master])
        {
            [arrTemp addObject:[[MWGGeofence alloc] initWithDictionary:dictTemp]];
        }
        
        arrGeofences = [NSArray arrayWithArray:arrTemp];
    }
}


// saves in-geofence list to user defaults
-(void)saveInGeofence:(NSArray *)arrayInGeofence
{
    NSData *encodedGeofence = [NSKeyedArchiver archivedDataWithRootObject:arrayInGeofence];
    [USER_DEFAULT setObject:encodedGeofence forKey:kDefaultInGeofence];
    [USER_DEFAULT synchronize];
}

// loads in-Geofence list from user defaults
-(NSArray *)loadInGeofence
{
    NSData *encodedGeofence = [USER_DEFAULT objectForKey:kDefaultInGeofence];
    return [NSKeyedUnarchiver unarchiveObjectWithData: encodedGeofence];
}


/**
 *  download new list of geofence
 */
-(void)syncGeofenceList
{
    if ([self checkGeofenceAvailability])
    {
        MWGAPI *apiGeofences = [[MWGAPI alloc] init];
        
        //start downloading geofence list
        [apiGeofences MWGGetGeoFenceList:nil
                     WithCompletionBlock:^(NSArray *geofences, NSError *result) {
                      
                         if (result)
                         {
                             if (result.code == MWG_SUCCESS)
                             {
                                 // save list to disk and start monitoring new geofence
                                 [self saveAndStartMonitoringForGeofence:geofences];
                             }                             
                         }
                         
                         // notify geofence sync is complete
                         [[MWGSDKMangerCore sharedInstance] informGeofenceSetupCompletionWithError:result];
                  }];
    }
}


/**
 *  save and start monitoring fr new list of geofence
 *
 *  @param geofenceArray downloaded list of geofence
 */
-(void)saveAndStartMonitoringForGeofence:(NSArray *)geofenceArray
{
    if (!geofenceArray || [geofenceArray count] < 1)
    {
        return;
    }
    
    //converts beacon object to beacon dictionary
    NSMutableArray *arr =  [[NSMutableArray alloc] init];
    for (MWGGeofence *geofenceTemp in geofenceArray)
    {
        [arr addObject:[geofenceTemp geofenceDictionary]];
    }
    
    //convert beacon dictionary list into json data
    NSMutableDictionary *dictGeofence = [[NSMutableDictionary alloc]init];
    
    [dictGeofence setValue:arr forKey:geofence_master];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictGeofence
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    //get beacon file path and save new beacon list into file
    NSString *geofenceFilePath = [self getJsonFile:GEOFENCE_LIST_FILE];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if ([filemanager fileExistsAtPath:geofenceFilePath])
    {
        [filemanager removeItemAtPath:geofenceFilePath error:nil];
    }
    
    BOOL val = [jsonData writeToFile:geofenceFilePath atomically:NO];
    
    if (val)
    {
        /**
         *  stop monitoring for current beacon
         */
        for (MWGGeofence *geofence in arrGeofences)
        {
            [self stopMontoringGeofence:geofence];
        }
        
        //refresh geofence array
        if(isGeofenceInitiated)
            isGeofenceInitiated = NO;
        
        [self initialiseGeofence];
    }
}

/**
 *  get geofence id for detected region and informs server for the geofence detected
 *
 *  @param geofenceRegion geofence region detected
 *  @param status         device status for geofence region specified
 */
-(void)getGeofenceIdForRegion:(CLCircularRegion *)geofenceRegion
     andInformServerForStatus:(MWGGeofenceState)status
{
    //get geofence element index in arrGeofence for geofence region
    int index = (int)[arrGeofences indexOfObjectPassingTest:^(MWGGeofence* obj, NSUInteger idx, BOOL *stop){
        
        // checks if current geofence is related to specified geofence region
        return [self checkGeofenceRegion:geofenceRegion isEqualToGeofence:obj];
    }];
    
    if (index > -1 && index < [arrGeofences count])
    {
        //get beacon object for specified beacon region
        MWGGeofence *geofenceObj = arrGeofences[index];
        
        if (geofenceObj)
        {
            if (status == MWGGeofenceIn)
            {
                //for in
                if (!arrInGeofences)
                {
                    arrInGeofences = [[NSMutableArray alloc] init];
                }
                
                // check beacon is already in in-beacon list
                if ([self geofenceArray:arrInGeofences containsGeofence:geofenceObj] == -1)
                {
                    // if beacon is not in in-beacon list, add the beacon into list
                    [arrInGeofences addObject:geofenceObj];
                    
                    //save new in-beacon list into user default
                    [self saveInGeofence:arrInGeofences];
                    
                    // if Geofence object has inTxt then fire local notificatin
                    NSString *strMsg = geofenceObj.intxt;
                    
                    if (strMsg && ![strMsg isEqualToString:@""])
                    {
                        [self fireLocalNotificationWithMessage:strMsg];
                    }
                    
                    //inform server for detected beacon region
                    [self callGeofenceInfoWebServiceForGeofence:geofenceObj
                                                       forInOut:status];
                }
            }
            else
            {
                //for out
                if (arrInGeofences && [arrInGeofences count] > 0)
                {
                    int indexGeofence = [self geofenceArray:arrInGeofences containsGeofence:geofenceObj];
                    
                    // check beacon is in in-beacon list
                    if ( indexGeofence != -1)
                    {
                        // if beacon is in in-beacon list, remove beacon from list
                        [arrInGeofences removeObjectAtIndex:indexGeofence];
                        
                        //save new in-beacon list into user default
                        [self saveInGeofence:arrInGeofences];
                        
                        // if beacon bject has outTxt then fire local notificatin
                        NSString *strMsg = geofenceObj.outtxt;
                        
                        if (strMsg && ![strMsg isEqualToString:@""])
                        {
                            [self fireLocalNotificationWithMessage:strMsg];
                        }
                        
                        //inform server for detected beacon region
                        [self callGeofenceInfoWebServiceForGeofence:geofenceObj
                                                           forInOut:status];
                    }
                }
            }
        }
    }
}


/**
 *  checks if specified geofence region is linked to specied geofence object
 *
 *  @param region      geofence region
 *  @param geofenceObj geofence object
 *
 *  @return returns YES if geofence region is linked to geofence object otherwise returns NO
 */
-(BOOL)checkGeofenceRegion:(CLCircularRegion *)region isEqualToGeofence:(MWGGeofence *)geofenceObj
{
    CLLocationCoordinate2D geofenceCentre = region.center;
    
    // check if latitute of centre of geofence region is equal to geofence object's latitute
    if (geofenceCentre.latitude != [geofenceObj.gflat doubleValue])
    {
        return NO;
    }
    
    // check if longitude of centre of geofence region is equal to geofence object's longitude
    if (geofenceCentre.longitude != [geofenceObj.gflon doubleValue])
    {
        return NO;
    }
    
    return YES;
}

/**
 *  call xmlgeofence api to inform server for specified geofence with its state
 *
 *  @param geofencenObj geofence object
 *  @param inOut     state of device with respect to geofence object's region
 */
-(void)callGeofenceInfoWebServiceForGeofence:(MWGGeofence *)geofenceObj forInOut:(MWGGeofenceState)inOut
{
    MWGAPI *apiBeacon = [[MWGAPI alloc] init];
    [apiBeacon MWGGeofence:geofenceObj.gfid
         withGeofenceState:inOut];
}


/**
 *  checks if geofence array contains specified geofence object
 *
 *  @param arr      array of geofences
 *  @param geofence geofence
 *
 *  @return index of geofence in geofence array
 */
-(int)geofenceArray:(NSArray *)arr containsGeofence:(MWGGeofence *)geofence
{
    int count = -1;
    
    //iterate all geofence in array
    for (MWGGeofence *geofenceTemp in arr)
    {
        count++;
        
        //if specified geofence's id is equal to current geofence 's id
        if ([geofence.gfid isEqualToString:geofenceTemp.gfid])
        {
            //ok
            return count;
        }
    }
    
    //geofence not found
    return -1;
}


#pragma mark - Location service delegate

/**
 *  Invoked when new locations are available.  Required for delivery of
 *    deferred locations.
 *
 *  @param manager   location manager object
 *  @param locations array of CLLocation objects in chronological order.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if (locations && [locations count] > 0)
    {
        deviceLocation = [locations[0] copy]; //update device location
        
        //inform sdk manager new location
        [[MWGSDKMangerCore sharedInstance] setUserLatitude:deviceLocation.coordinate.latitude
                                              andLongitude:deviceLocation.coordinate.longitude
                                                     error:nil];
    }    
}


/**
 *  Tells the delegate that the location manager was unable to retrieve a location value.
 *
 *  @param manager location manager object
 *  @param error   error object
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    deviceLocation = nil;  //no deice location
    
    //inform sdk manager new location
    [[MWGSDKMangerCore sharedInstance] setUserLatitude:0.0
                                          andLongitude:0.0
                                                 error:[MWGError locationServiceError]];
    
}

/**
 *  Tells the delegate that the user entered the specified region.
 *
 *  @param manager location manager object
 *  @param region  region entered
 */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    // check if region is beacon region
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        if (beaconFlag)
        {
            //retrive beacon region
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            
            NSLog(@"\n\nBeacon region entered UUID: %@, Major: %@, Minor: %@\n\n", [beaconRegion.proximityUUID UUIDString],
                  beaconRegion.major,
                  beaconRegion.minor);
            
            // get beacon id for beacon and inform server to perform action
            [self getBeaconIdForRegion:beaconRegion
              andInformServerForStatus:MWGBeaconIn];
            
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
            {
                if (!isBackgroundProcessActive)
                {
                    [self extendBackgroundRunningTime];
                }
            }
            
            [APP_NOTIFICATION postNotificationName:NOTIFICATION_NEAR_BEACON
                                            object:nil
                                          userInfo:@{@"status" : @YES,
                                                     @"beacon" : beaconRegion}];
        }
    }
    else
    {
        if (geofenceFlag)
        {
            // retrieve geofence region
            CLCircularRegion *geofenceRegion = (CLCircularRegion *)region;
            
            // get geofence id for geofence and inform server to perform action
            [self getGeofenceIdForRegion:geofenceRegion
                andInformServerForStatus:MWGGeofenceIn];
        }
    }
}


/**
 *  Tells the delegate that the user left the specified region.
 *
 *  @param manager location manager object
 *  @param region  region exited
 */
-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region
{
    // check if region is beacon region
    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        if (beaconFlag)
        {
            //retrive beacon region
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            
            NSLog(@"\n\nBeacon region exited UUID: %@, Major: %@, Minor: %@\n\n", [beaconRegion.proximityUUID UUIDString],
                  beaconRegion.major,
                  beaconRegion.minor);
            
            // get beacon id for beacon and inform server to perform action
            [self getBeaconIdForRegion:beaconRegion andInformServerForStatus:MWGBeaconOut];
            
            [APP_NOTIFICATION postNotificationName:NOTIFICATION_NEAR_BEACON
                                            object:nil
                                          userInfo:@{@"status" : @NO,
                                                     @"beacon" : beaconRegion}];
        }
    }
    else
    {
        if (geofenceFlag)
        {
            // retrieve geofence region
            CLCircularRegion *geofenceRegion = (CLCircularRegion *)region;
            
            // get geofence id for geofence and inform server to perform action
            [self getGeofenceIdForRegion:geofenceRegion
                andInformServerForStatus:MWGGeofenceOut];
        }
    }
}

/**
 *  Tells the delegate that one or more beacons are in range.
 *
 *  @param manager location manager object
 *  @param beacons list of beacon
 *  @param region  region
 */
-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] < 1)
    {
        return;
    }
    
    // refresh list of current ranging beacon with new list of beacons
    [self resetBeaconRangingArray:beacons];
}

/**
 *  Tells the delegate about the state of the specified region.
 *
 *  @param manager location manager object
 *  @param state   device state according to regin
 *  @param region  region specified
 */
-(void)locationManager:(CLLocationManager *)manager
     didDetermineState:(CLRegionState)state
             forRegion:(CLRegion *)region
{
    // check if region is beacon region
    if ([region isKindOfClass: [CLBeaconRegion class]])
    {
        if (beaconFlag)
        {
            //retrive beacon region
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            
            
            // get beacon id for beacon and inform server to perform action
            if(state == CLRegionStateInside)
            {
                [self getBeaconIdForRegion:beaconRegion andInformServerForStatus:MWGBeaconIn];
                
            }
            else if(state == CLRegionStateOutside)
            {
                [self getBeaconIdForRegion:beaconRegion andInformServerForStatus:MWGBeaconOut];
                
            }
            else
            {
                
            }
        }
    }
}


#pragma mark - Bluetooth delegate

/**
 *  check bluetooth state
 */
- (void)detectBluetooth
{
    if(!bluetoothManager)
    {
        bluetoothManager = nil;
    }
    
    bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                            queue:dispatch_get_main_queue()];
    
}

/**
 *  Invoked when the central manager’s state is updated.
 *
 *  @param central blutooth manager
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (bluetoothManager.state == CBCentralManagerStatePoweredOn)
    {
        [MWGSDKMangerCore sharedInstance].bluetoothOnFlag = YES;
        
        //if bluetooth is on
        if (beaconFlag)
        {
            if (!isBeaconIntiated)
            {
                [self initialiseBeacon];
            }
        }
    }
    else
    {
        [MWGSDKMangerCore sharedInstance].bluetoothOnFlag = NO;
        
        //if bluetooth is off, fire an error
        [[MWGSDKMangerCore sharedInstance] informBeaconSetupCompletionWithError:[MWGError bluetoothDisableError]];
    }
}


#pragma mark - Misc

/**
 *  Method to extend background processing
 */
- (void)extendBackgroundRunningTime
{
    if (backgroundTask != UIBackgroundTaskInvalid) {
        // if we are in here, that means the background task is already running.
        // don't restart it.
        return;
    }
    __block Boolean self_terminate = YES;
    
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"DummyTask" expirationHandler:^{
        
        if (self_terminate) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
            
            if (isBackgroundProcessActive)
            {
                isBackgroundProcessActive = NO;
            }
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            [NSThread sleepForTimeInterval:1];
        }
        
    });
    
    if (!isBackgroundProcessActive)
    {
        isBackgroundProcessActive = YES;
    }
}


///**
// *  generates list of items that not in arrItem 1 with respect to arrItem 2
// *
// *  @param arrItem1 item array 1
// *  @param arrItem2 item array 2
// *
// *  @return item difference array
// */
//-(NSArray *)getExcludedItemListIn:(NSArray *)arrItems1
//                             from:(NSArray *)arrItems2
//                         usingKey:(NSString *)strKey
//{
//    //convert arrays into sets
//    NSSet *setItems1 = [NSSet setWithArray:arrItems1];
//    NSSet *setItems2 = [NSSet setWithArray:arrItems2];
//    
//    //collects all set keys value
//    NSSet* setItemIds = [setItems2 valueForKey:strKey];
//    
//    //retreives the excluded set
//    NSSet* setDiffernces = [setItems1 filteredSetUsingPredicate:
//                            [NSPredicate predicateWithFormat:@"NOT SELF.%@ IN %@",strKey, setItemIds]];
//    
//    //return excluded array
//    return [setDiffernces allObjects];
//}
//
//
///**
// *  generates list of items that not in arrItem 1 with respect to arrItem 2
// *
// *  @param arrItem1 item array 1
// *  @param arrItem2 item array 2
// *
// *  @return item difference array
// */
//-(NSArray *)getBeaconExcludedItemListIn:(NSArray *)arrSavedBeacons
//                                   from:(NSArray *)arrNewBeacons
//{
//   
//}

/**
 *  calculate distance between two co-ordinates.
 *
 *  @param coord1 first coordinate
 *  @param coord2 second coordinate
 *
 *  @return distance between two coordinates
 */
- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2
{
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}

/**
 *  called when app goes to background
 */
-(void)appGoesToBackground
{
    //stop location updates
    [self stopUpdatingLocation];
    
    // start background process if beacon ranging is active
    if (isRangingActive)
    {
        if (!isBackgroundProcessActive)
        {
            [self extendBackgroundRunningTime];
        }
    }
}

/**
 *  called when app comes to foreground
 */
-(void)appComesToForeground
{
    //start downloading beacon list if beacon flag is enabled
    if (beaconFlag)
    {
        [self syncBeaconList];
    }
    
    //start downloading geofence list if geofence flag is enabled
    if (geofenceFlag)
    {
        [self syncGeofenceList];
    }
    
    // check if location service is enable
    if ([[MWGSDKMangerCore sharedInstance] isLocationServiceEnabled])
    {
        // start location updates
        [self startUpdatingLocation];
    }
    
    // stop background process
    if (isBackgroundProcessActive)
    {
        isBackgroundProcessActive = NO;
        
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
}


/**
 *  checks if geofence can be enabled for app
 *
 *  @return returns YES if app can enable geofence else returns NO
 */
-(BOOL)checkGeofenceAvailability
{
    if(![CLLocationManager locationServicesEnabled])
    {
        //You need to enable Location Services
        return NO;
    }
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        //Region monitoring is not available for this Class;
        return NO;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        //You need to authorize Location Services for the APP
        return NO;
    }
    
    return YES;
}

/**
 *  Validates specified UUID
 *
 *  @param inputStr a uuis string
 *
 *  @return returns YES if uuid is valid otherwise returns NO
 */
- (BOOL)isUUID:(NSString *)inputStr
{
    BOOL isUUID = FALSE;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" options:NSRegularExpressionCaseInsensitive error:nil];
    int matches = (int)[regex numberOfMatchesInString:inputStr options:0 range:NSMakeRange(0, [inputStr length])];
    if(matches == 1)
    {
        isUUID = TRUE;
    }
    return isUUID;
}

/**
 *  return full path of specified file
 *
 *  @param file file name
 *
 *  @return full path of file
 */
-(NSString *)getJsonFile:(NSString *)file
{
    // retreive document directry path
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //append file name with document directory path
     return [documentsPath stringByAppendingPathComponent:file];
}

/**
 *  fires a local notification with specified message string
 *
 *  @param msg message for local notification
 */
-(void)fireLocalNotificationWithMessage:(NSString *)msg
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = msg;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

/**
 *  refresh ranging beacon array with given array
 *
 *  @param beaconArray current ranging beacons list
 */
-(void)resetBeaconRangingArray:(NSArray *)beaconArray
{
    // if current ranging beacon do not have any data, add all new ranging beacons into it
    if (!arrRangingBeacons || [arrRangingBeacons count] < 1)
    {
        arrRangingBeacons = [[NSMutableArray alloc] init];
    }
    
    [arrRangingBeacons addObjectsFromArray:beaconArray];
}


/**
 *  returns a list of beacon inside whose vicinity the device is
 *
 *  @return list of in beacons
 */
- (NSArray *) getInBeaconList
{
    if (arrInBeacons && [arrInBeacons count] > 0) {
        return arrInBeacons;
    } else {
        return nil;
    }
}

- (void) dumpBeaconRanging:(NSArray *)beacons {
    
    NSMutableString *strBeaconXML = [[NSMutableString alloc] init];
    
    for (CLBeacon *beaconObj in beacons) {
        [strBeaconXML appendString:@"<beacon>"]; // start a beacon xml object
        [strBeaconXML appendFormat:@"<udid>%@</udid>", [beaconObj.proximityUUID UUIDString]]; // add beacon UUID
        [strBeaconXML appendFormat:@"<major>%@</major>", beaconObj.major]; // add beacon major
        [strBeaconXML appendFormat:@"<minor>%@</minor>", beaconObj.minor]; // add beacon minor
        [strBeaconXML appendFormat:@"<rssi>%ld</rssi>", (long)beaconObj.rssi]; // add average of beacon rssi from beacon data
        [strBeaconXML appendFormat:@"<proximity>%ld</proximity>", (long)(4 - beaconObj.proximity)]; // add beacon proximity
        [strBeaconXML appendFormat:@"<accuracy>%f</accuracy>", beaconObj.accuracy]; // add average beacon accuracy
        [strBeaconXML appendString:@"</beacon>"];
    }
    
    NSLog(@"\n\n Ranging data :%@ \n\n", strBeaconXML);
}


@end
