//
//  MWGUtil.h
//
// Author:   Ranjan Patra
// Created:  22/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGPromotion.h"

/**
 *  contains utility methods
 */
@interface MWGUtil : NSObject

/**
 *  converts unix date string into equivalent date object
 *
 *  @param unix unix date string
 *
 *  @return date object
 */
+ (NSDate *) getDateFromUnix:(NSString *)unix;


/**
 *  converts date object into equivalent unix string
 *
 *  @param date date object
 *
 *  @return unix string
 */
+ (NSString *) getUnixFromDate:(NSDate *)date;


#pragma mark - BITS HANDLING

/**
 *  returns equivalent array from given bits strings
 *
 *  @param bits bits string
 *
 *  @return array of flags retreived frm bit string
 */
+ (NSMutableArray *) arrayFromBits:(NSString *)bits;


/**
 *  retruns equivalent bit string for given bit array
 *
 *  @param arr bit array
 *
 *  @return bit string
 */
+ (NSString *) getBitFromArray:(NSArray *)arr;


#pragma mark - beacon handling
/**
 *  returns equivalent xml from given ranging data
 *
 *  @param  arrRangingData  ranging data collected
 *
 *  @return xml equivalent to given ranging data
 */
+ (NSString *) getXMLOfRangingData:(NSArray *)arrRangingData;


#pragma mark - Promotion Handling

/**
 *  Generates promotion activity type from the activity string received from server
 *
 *  @param act activity string received from server
 *
 *  @return Promotion activity type
 */
+ (MWGPromotionActivityType) promotionActivityType:(NSString *)act;

@end
