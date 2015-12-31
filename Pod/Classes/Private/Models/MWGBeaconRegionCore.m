//
//  MWGBeaconRegionCore.m
//
// Author:   Ranjan Patra
// Created:  30/8/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGBeaconRegionCore.h"
#import "MWGConstants.h"
#import <CoreLocation/CoreLocation.h>
#import "MWGError.h"
#import "MWGSDKMangerCore.h"


@implementation MWGBeaconRegionCore

- (id) initWithBeaconRegion:(MWGBeaconRegion *)region
{
    if (self = [super init ])
    {
        self.beaconUUID = region.beaconUUID;
        self.beaconMajor = region.beaconMajor;
        self.beaconMinor = region.beaconMinor;
    }
    
    return self;
}

- (void) initializeBeaconWithDetectionBlock:(MWGBeaconDetectionCompletion) block andTimeOut:(NSNumber *)timeoutVal
{
    if (block) {
        detectionCompletionBlock = block;
    }
    
    timeout = timeoutVal;
    
    [APP_NOTIFICATION addObserver:self
                         selector:@selector(beaconData:)
                             name:NOTIFICATION_NEAR_BEACON
                           object:nil];
    
    [self performSelector:@selector(beaconDetectionTimedOut)
               withObject:nil
               afterDelay:[timeout doubleValue]];
    
    [[MWGSDKMangerCore sharedInstance] retainBeaconRegion:self];
}

#pragma mark - Notification method

- (void) beaconData:(NSNotification *)notification
{
    CLBeaconRegion *region = (CLBeaconRegion *)notification.userInfo[@"beacon"];
    
    if ([self checkBeaconRegion:region])
    {
        if (detectionCompletionBlock)
        {
            detectionCompletionBlock(notification.userInfo[@"status"], [MWGError success]);
        }
    }
    
    [self releaseRegion];
}

#pragma mark - Private method

- (void) beaconDetectionTimedOut
{
    if (detectionCompletionBlock)
    {
        MWGSDKMangerCore *manager = [MWGSDKMangerCore sharedInstance];
        detectionCompletionBlock([manager isNearBeacon:self], [MWGError success]);
    }
    
    [self releaseRegion];
}

- (BOOL) checkBeaconRegion:(CLBeaconRegion *)beaconRegion
{
    // check uuid
    if (![[self.beaconUUID UUIDString] isEqualToString:[beaconRegion.proximityUUID UUIDString]])
    {
        return NO;
    }
    
    // check major
    if (self.beaconMajor)
    {
        if (![self.beaconMajor intValue] == [beaconRegion.major intValue])
        {
            return NO;
        }
    }
    
    //check minor
    if (self.beaconMinor)
    {
        if (![self.beaconMinor intValue] == [beaconRegion.minor intValue])
        {
            return NO;
        }
    }
    
    return YES;
}


- (void) releaseRegion
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [APP_NOTIFICATION removeObserver:self];
    [[MWGSDKMangerCore sharedInstance] releaseBeaconRegion:self];
}

@end
