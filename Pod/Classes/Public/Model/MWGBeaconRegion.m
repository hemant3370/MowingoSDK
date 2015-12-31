//
//  MWGBeaconRegion.m
//
// Author:   Ranjan Patra
// Created:  30/8/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGBeaconRegion.h"



@interface MWGBeaconRegion ()
{
    NSUUID *beaconUUID;
    NSNumber *beaconMajor;
    NSNumber *beaconMinor;
}

@end

@implementation MWGBeaconRegion

@synthesize beaconUUID;
@synthesize beaconMajor;
@synthesize beaconMinor;



@end
