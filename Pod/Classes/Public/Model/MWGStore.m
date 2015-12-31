//
//  MWGStore.m
//
// Author:   Ranjan Patra
// Created:  18/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGStore.h"


/**
 *  keeps details of current store
 */
@implementation MWGStore

@synthesize state, storeImage, street1, street2,  storeId, storeName, city, country, storeLatitude, storeLongitude, zip, storeHours, storePreference, phoneNumber;

@end

/**
 *  stores open day hours
 */
@implementation MWGDayHours

@synthesize dayName, openTime, closeTime;

@end