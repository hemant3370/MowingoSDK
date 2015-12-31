//
//  MWGBeaconRegion.h
//
// Author:   Ranjan Patra
// Created:  30/8/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>

/**
 *  Creates a beacon region
 */
@interface MWGBeaconRegion : NSObject

/**
 *  UUID linked with beacon
 */
@property (nonatomic) NSUUID *beaconUUID;

/**
 *  Major linked with beacon
 */
@property (nonatomic) NSNumber *beaconMajor;

/**
 *  Minor linked with beacon
 */
@property (nonatomic) NSNumber *beaconMinor;

@end
