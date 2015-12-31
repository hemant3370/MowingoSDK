// MWGPromotion.h
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//


#import <Foundation/Foundation.h>

/**
 enumeration for promotion activity types
 */
typedef enum : NSUInteger {
    
    MWG_REDEEM = 1, // promotion is redeemable
    MWG_HISTORY = 2, // promotion already redeemed
    
}MWGPromotionActivityType;

/**
 *   Model class for promotion related objects
 */
@interface MWGPromotion : NSObject

/**
 *  Unique id for promotion
 */
@property(nonatomic) NSString *promotionId;

/**
 *  Type of promotion
 */
@property(nonatomic) NSString *promotionType;

/**
 *  Title for promotion
 */
@property(nonatomic) NSString *promotionTitle;

/**
 *  Description for promotion
 */
@property(nonatomic) NSString *promotionDescription;

/**
 *  Image of promotion
 */
@property(nonatomic) NSURL *promotionImageUrl;

/**
 *  Activity flag for promotion
 */
@property(nonatomic) MWGPromotionActivityType promotionActivity;

/**
 *  Start date-time of promotion
 */
@property(nonatomic) NSDate *promotionStartDateTime;

/**
 *  End date-time of promotion
 */
@property(nonatomic) NSDate *promotionEndDateTime;

/**
 *  If this value is not empty/null the
 app should use this web page as
 the content of the promotion.
 */
@property (nonatomic) NSURL *promotionUrl;

/**
 *  Current punch count of promotion
 */
@property(nonatomic) NSNumber *promotionPunchCount;

/**
 *  Total punches in promotion
 */
@property(nonatomic) NSNumber *promotionPunchTotal;

/**
 *  Promotion's merchant name
 */
@property(nonatomic) NSString *merchantName;

/**
 *  Name of Place for Promotion's merchant
 */
@property(nonatomic) NSString *merchantPlaceName;

/**
 *  Image url of promotion's merchant
 */
@property(nonatomic) NSURL *merchantImageUrl;

/**
 *  Street name of promotions's merchant
 */
@property(nonatomic) NSString *merchantStreet;

/**
 *  City name of promotions's merchant
 */
@property(nonatomic) NSString *merchantCity;

/**
 *  State name of promotions's merchant
 */
@property(nonatomic) NSString *merchantState;

/**
 *  Country name of promotions's merchant
 */
@property(nonatomic) NSString *merchantCountry;

/**
 *  Latitude value of promotions's merchant
 */
@property(nonatomic) double merchantLatitude;

/**
 *  Longitude value of promotions's merchant
 */
@property(nonatomic) double merchantLongitude;

/**
 *  Phone number of promotions's merchant
 */
@property(nonatomic) NSString *merchantPhone;

/**
 *  Website of promotions's merchant
 */
@property(nonatomic) NSString *merchantWebsite;

/**
 *  Barcode type for promotion
 */
@property(nonatomic) NSString *barcodeType;

/**
 *  Barcode value for promotion
 */
@property(nonatomic) NSString *barcodeValue;

@end
