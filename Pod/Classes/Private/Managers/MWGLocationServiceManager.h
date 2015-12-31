//
//  MWGLocationServiceManager.h
//  MowingoSDK
//
//  Created by Bellurbis on 5/3/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MWGAPI.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>


@interface MWGLocationServiceManager : CLLocationManager<CLLocationManagerDelegate, CBCentralManagerDelegate>
{
    NSArray *arrBeacons;
    NSArray *arrGeofences;
    
    NSMutableArray * arrInBeacons;  //stores list of beacon under whose range the device is.
    NSMutableArray * arrInGeofences;  //stores list of geofence under whose range the device is.
    
    BOOL geofenceFlag; //geofence enabled flag
    BOOL isGeofenceInitiated; //if geofence detection is initialized
    
    BOOL beaconFlag; //beacon enabled flag
    BOOL isBeaconIntiated; //if beacon detection is initialized
    
    CBCentralManager *bluetoothManager;//for bluetooth status check
    
    CLLocation *deviceLocation; //stores updated location of device
    
    NSMutableArray *arrRangingBeacons; //stores current beacon ranging array
    
    UIBackgroundTaskIdentifier backgroundTask;
    
    BOOL isRangingActive; // flag to check if ranging for a beacon is needed.
    
    BOOL isBackgroundProcessActive; // flag to check if background processing is active
}

/**
 * gets singleton location service menager object.
 * @return location service menager singleton
 */
+ (MWGLocationServiceManager*)getLocationManager;

/**
 *  beacon detection enabled flag
 */
@property (nonatomic) BOOL beaconFlag;

/**
 *  geofencing enabled flag
 */
@property (nonatomic) BOOL geofenceFlag;

/**
 *  starts downloading new beacon list to monitor
 */
-(void)syncBeaconList;

/**
 *  starts downloading new geofence list to monitor
 */
-(void)syncGeofenceList;

/**
 *  returns a list of beacon inside whose vicinity the device is
 *
 *  @return list of in beacons
 */
- (NSArray *) getInBeaconList;

@end
