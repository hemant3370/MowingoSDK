//
//  MWGBeacon.h
// Author:   Ranjan Patra
// Created:  01/4/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>

@interface MWGBeaconCore : NSObject
{
    NSString *bid;          // Beacon Id
    NSString *budid;        // Beacon UUID
    NSString *major;        // Beacon Major
    NSString *minor;        // Beacon Minor
    NSString *proximity;    // Beacon Proximity
    NSString *type;         // Beacon Type
    NSString *inTxt;        // Beacon IN Text
    NSString *outText;      // Beacon OUT Text
    NSString *did;          // Deal Id
    NSString *pid;          // Promotion Id
}

@property(nonatomic) NSString *bid;          // Beacon Id
@property(nonatomic) NSString *budid;        // Beacon UUID
@property(nonatomic) NSString *major;        // Beacon Major
@property(nonatomic) NSString *minor;        // Beacon Minor
@property(nonatomic) NSString *proximity;    // Beacon Proximity
@property(nonatomic) NSString *type;         // Beacon Type
@property(nonatomic) NSString *inTxt;        // Beacon IN Text
@property(nonatomic) NSString *outText;      // Beacon OUT Text
@property(nonatomic) NSString *did;          // Deal Id
@property(nonatomic) NSString *pid;          // Promotion Id

-(id) initWithDictionary:(NSDictionary *)beacon;
-(NSDictionary *)beaconDictionary;

@end
