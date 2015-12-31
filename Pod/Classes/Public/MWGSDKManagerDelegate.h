//
//  MWGSDKManagerDelegate.h
//  MowingoSDK
//
//  Created by Bellurbis on 4/22/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#ifndef MowingoSDK_MWGSDKManagerDelegate_h
#define MowingoSDK_MWGSDKManagerDelegate_h


#endif


#import <Foundation/Foundation.h>

/**
 Protocol for diffenrent events in MWGSDK initialization
 */
@protocol MWGSDKManagerDelegate <NSObject>
@optional

/**
 *  Delegate called when SDk completes authentification while initializing.
 *
 *  @param error error object if SDK initialization encounters any error
 */
-(void)MWGSDKManagerFinishedAuthenticationWithErrorObject:(NSError *)error;

/**
 *  Delegate called when SDk completes beacon mechanism setup while initializing.
 *
 *  @param error error object if SDK initialization encounters any error
 */
-(void)MWGSDKManagerFinishedBeaconSetupWithErrorObject:(NSError *)error;

/**
 *  Delegate called when SDk completes geofencing mechanism setup while initializing.
 *
 *  @param error error object if SDK initialization encounters any error
 */
-(void)MWGSDKManagerFinishedGeofencingSetupWithErrorObject:(NSError *)error;

/**
 *  Delegate called when SDk completes location serive setup while initializing.
 *
 *  @param error error object if SDK initialization encounters any error
 */
-(void)MWGSDKManagerFinishedLocationActivationWithErrorObject:(NSError *)error;

@end