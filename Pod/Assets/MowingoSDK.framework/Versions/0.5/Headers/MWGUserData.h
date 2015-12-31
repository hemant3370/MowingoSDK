//
//  MWGUserData.h
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//


#import <Foundation/Foundation.h>

/**
 determines values for user gender
 */
typedef enum : NSUInteger {
    MALE = 1,  // male
    FEMALE = 2, // female
} MWGUserGender;


/**
 *  Stores users details
 */
@interface MWGUserData : NSObject

/**
 * Messaging prefrences of user
 */
@property (nonatomic) NSMutableArray *messagePreferences;


/**
 * Product prefrences of user
 */
@property (nonatomic) NSMutableArray *productPreferences;

/**
 * First Name of User
 */

@property (nonatomic) NSString *firstName;

/**
 * Family name of user
 */

@property (nonatomic) NSString *familyname;

/**
 * Email of user
 */

@property (nonatomic) NSString *userEmail;

/**
 * Phone Number of user
 */
@property (nonatomic) NSString *phoneNumber;

/**
 * Zip code of user
 */

@property (nonatomic) NSString *zip;

/**
 * Language prefrence of user
 */

@property (nonatomic) NSString *userLanguage;

/**
 * Date of birth of user
 */
@property (nonatomic) NSDate *dob;

/**
 * enum for user gender
 */
@property (nonatomic) MWGUserGender userGender;

/**
 *  group name
 */
@property (nonatomic) NSString * groupname;

/**
 *  current value of budget
 */
@property (nonatomic) NSNumber *currentbudget;


/**
 *  total value of budget
 */
@property (nonatomic) NSNumber *totalbudget;

@end
