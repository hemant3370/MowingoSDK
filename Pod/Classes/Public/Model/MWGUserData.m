//
//  MWGUserData.m
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGUserData.h"


/**
 *  Stores users details
 */
@implementation MWGUserData

@synthesize phoneNumber, productPreferences, dob, familyname, firstName, messagePreferences, userEmail, userGender, userLanguage, zip, groupname, currentbudget, totalbudget;


#pragma mark - user gender

/**
 *  interpret user gender
 *
 *  @param gender gender string received from server
 *
 */
- (void) getuserGenderFromString:(NSString *)gender
{
    if ([gender isEqualToString:@"1"])
    {
        // if string received is 1 then set Male
        self.userGender = MALE;
    }
    else if ([gender isEqualToString:@"2"])
    {
        // if string received is 2 then set female
        self.userGender = FEMALE;
    }
    else
    {
        self.userGender = -1;
    }
}

/**
 *  returns gender equivalent string
 *
 *  @return user gender equivalent string
 */
-(NSString *) stringforGender
{
    if(self.userGender == MALE)
    {
        return @"1";
    }
    else if(self.userGender == FEMALE)
    {
        return @"2";
    }
    else
    {
        return @"";
    }
}

#pragma mark - DOB

/**
 *  returns date without time
 *
 *  @return date object
 */
-(NSDate *)getDobValue
{
    if( self.dob == nil )
    {
        return nil;
    }
    
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:self.dob];
    [comps setHour:00];
    [comps setMinute:00];
    [comps setSecond:00];
    [comps setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
