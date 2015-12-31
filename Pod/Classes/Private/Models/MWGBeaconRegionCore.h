//
//  MWGBeaconRegionCore.h
//
// Author:   Ranjan Patra
// Created:  30/8/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <MowingoSDK/MowingoSDK.h>
/**
 *  Block for receiving detectin events
 *
 *  @param beaconFlag flag if beacon is detected
 *  @param result     error
 */
typedef void(^MWGBeaconDetectionCompletion)(NSNumber *beaconFlag, NSError *result);

/**
 *   SDK class for beacn region
 */
@interface MWGBeaconRegionCore : MWGBeaconRegion
{
    MWGBeaconDetectionCompletion detectionCompletionBlock;
    NSNumber *timeout;
}

/**
 *  initialize beacon detection with a time out
 *
 *  @param block completion block
 */
- (void) initializeBeaconWithDetectionBlock:(MWGBeaconDetectionCompletion) block andTimeOut:(NSNumber *)timeoutVal;


/**
 *  Initialize current class with a beacon region
 *
 *  @param region current beacon region
 *
 *  @return instance of current class
 */
- (id) initWithBeaconRegion:(MWGBeaconRegion *)region;

@end
