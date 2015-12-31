//
//  MWGGeofence.h
// Author:   Ranjan Patra
// Created:  01/4/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>

/**
 *  Represents a geofence
 */

@interface MWGGeofence : NSObject
{
    NSString *gfid;          // Beacon Id
    NSString *gflat;        // Beacon latitute
    NSString *gflon;        // Beacon longitude
    NSString *radius;        // Beacon Radius
    NSString *type;         // Beacon Type
    NSString *intxt;        // Beacon IN Text
    NSString *outtxt;      // Beacon OUT Text
    NSString *did;          // Deal Id
    NSString *pid;          // Promotion Id
}

@property(nonatomic) NSString *gfid;          // Beacon Id
@property(nonatomic) NSString *gflat;        // Beacon latitute
@property(nonatomic) NSString *gflon;        // Beacon longitude
@property(nonatomic) NSString *radius;        // Beacon Radius
@property(nonatomic) NSString *type;         // Beacon Type
@property(nonatomic) NSString *intxt;        // Beacon IN Text
@property(nonatomic) NSString *outtxt;      // Beacon OUT Text
@property(nonatomic) NSString *did;          // Deal Id
@property(nonatomic) NSString *pid;          // Promotion Id

/**
 *  initialize class with geofence dictionary
 *
 *  @param geofence geofence dictionary
 *
 *  @return class instance
 */
-(id) initWithDictionary:(NSDictionary *)geofence;

/**
 *  converts Objects into geofence dictionary
 *
 *  @return equivalent geofence dictionary
 */
-(NSDictionary *)geofenceDictionary;

@end
