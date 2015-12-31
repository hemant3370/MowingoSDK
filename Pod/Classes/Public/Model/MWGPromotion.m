//  Deal.m
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

/**
 *  Model class for promotion related objects
 */

#import "MWGPromotion.h"

/**
 *   Model class for promotion related objects
 */
@interface MWGPromotion ()

@end

/**
 *   Model class for promotion related objects
 */
@implementation MWGPromotion

/**
 *  synthesizing all properties to automatically create
 *  their setter and getter methods
 */

@synthesize promotionId;
@synthesize promotionTitle;
@synthesize promotionDescription;
@synthesize promotionImageUrl;
@synthesize promotionActivity;
@synthesize promotionStartDateTime;
@synthesize promotionEndDateTime;
@synthesize promotionPunchCount;
@synthesize promotionPunchTotal;
@synthesize merchantName;
@synthesize merchantStreet;
@synthesize merchantCity;
@synthesize merchantState;
@synthesize merchantCountry;
@synthesize merchantLatitude;
@synthesize merchantLongitude;
@synthesize merchantPhone;
@synthesize merchantWebsite;
@synthesize barcodeType;
@synthesize barcodeValue;
@synthesize merchantImageUrl;
@synthesize merchantPlaceName;
@synthesize promotionUrl;
@synthesize promotionType;

@end
