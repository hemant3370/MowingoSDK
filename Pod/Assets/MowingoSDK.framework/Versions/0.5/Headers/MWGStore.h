//
//  MWGStore.h
//
// Author:   Ranjan Patra
// Created:  18/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>

@class MWGDayHours;

/**
 *  keeps details of current store
 */
@interface MWGStore : NSObject

/**
 *  unique id for store
 */
@property (nonatomic) NSString *storeId;

/**
 *  name of store
 */
@property (nonatomic) NSString *storeName;

/**
 *  image of store
 */
@property (nonatomic) NSURL *storeImage;

/**
 *  street1 of store
 */
@property (nonatomic) NSString *street1;

/**
 *  street2 of store
 */
@property (nonatomic) NSString *street2;

/**
 *  city of store
 */
@property (nonatomic) NSString *city;

/**
 *  state of store
 */
@property (nonatomic) NSString *state;

/**
 *  country of store
 */
@property (nonatomic) NSString *country;

/**
 *  zip value of staore
 */
@property (nonatomic) NSString *zip;

/**
 *  phone number of staore
 */
@property (nonatomic) NSString *phoneNumber;

/**
 *  latitude of store
 */
@property (nonatomic) double storeLatitude;

/**
 *  longitude of store
 */
@property (nonatomic) double storeLongitude;

/**
 *  weekly open hours for a store
 */
@property (nonatomic) NSArray *storeHours;

/**
 *  preference for store
 */
@property (nonatomic) NSArray *storePreference;


@end


#pragma mark ----------------------------------------------------
#pragma mark MWGDayHours
#pragma mark ---------------------------------------------------

/**
 *  stores open day hours
 */
@interface MWGDayHours : NSObject

/**
 *  day name
 */
@property (nonatomic) NSString *dayName;

/**
 *  stores open hours for the day
 */
@property (nonatomic) NSString *openTime;

/**
 *  store close hours for the day
 */
@property (nonatomic) NSString *closeTime;

@end

