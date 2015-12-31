//
//  MWGLocation.h
//
// Author: Ranjan Patra
// Email: ranjan.patra@bellurbis.com
// Created: 4 mar 2014
// summary: location model
// Copyright 2012 Mowingo. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MWGLocation : NSObject

@property(nonatomic,strong) NSString *mname;                        // Merchant Name
@property(nonatomic,strong) NSString *locationId;                   // Location Id
@property(readwrite,assign)  CLLocationDegrees latitude;            // Latitude
@property(readwrite,assign)  CLLocationDegrees longitude;           // Longitude
@property(readwrite,assign)  CLLocationDistance  radius;           // Radius
@property(readwrite,assign) CLLocationDistance  distance;           // Distance
@property(nonatomic) NSString *  storeId;                             // Store Id
@property(nonatomic) NSString *  address;                           // Store Address
@property(nonatomic) NSString *  city;                              // Store City
@property(nonatomic) NSString *  filter;                            //
@property(nonatomic) NSString *  type;                              //
@property(nonatomic) NSString *  mcdFlag;                           //
@property(nonatomic) NSString *  status;                            //
@property(nonatomic) NSString *  street;                            // Store Street
@property(nonatomic) NSString *  state;                             // Store State
@property(nonatomic) NSString *  zip;                               // Store Zip
@property(nonatomic) NSString *  country;                           // Store Country
@property(nonatomic) NSString *  mdesc;                             // Merchant Description
@property(nonatomic) NSString *  mimg;                              // Merchant Image


@end
