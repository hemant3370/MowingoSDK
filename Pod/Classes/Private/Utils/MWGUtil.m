//
//  MWGUtil.m
//
// Author:   Ranjan Patra
// Created:  22/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGUtil.h"
#import <CoreLocation/CoreLocation.h>
#import "MWGConstants.h"

@implementation MWGUtil


/**
 *  converts unix date string into equivalent date object
 *
 *  @param unix unix date string
 *
 *  @return date object
 */
+ (NSDate *) getDateFromUnix:(NSString *)unix
{
    // if unix string is empty
    if (!unix || [unix isEqualToString:@""])
    {
        return nil;
    }
    else
    {
        // get seconds from unix string
        NSTimeInterval unixSeconds = [unix doubleValue];
        
        return [NSDate dateWithTimeIntervalSince1970:unixSeconds];
    }
}


/**
 *  converts date object into equivalent unix string
 *
 *  @param date date object
 *
 *  @return unix string
 */
+ (NSString *) getUnixFromDate:(NSDate *)date
{
    // if date is invalid
    if (!date)
    {
        return @"";
    }
    else
    {
        // retreive unix seconds from given date
        int unixSeconds = (int)[date timeIntervalSince1970];
        
        return [NSString stringWithFormat:@"%d", unixSeconds];
    }
}


#pragma mark - BITS HANDLING

/**
 *  returns equivalent array from given bits strings
 *
 *  @param bits bits string
 *
 *  @return array of flags retreived frm bit string
 */
+ (NSMutableArray *)arrayFromBits:(NSString *)bits
{
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
    
    // set default bit array
    for (int i=0; i < 32; i++)
    {
        arrTemp[i] = @NO;
    }
    
    // if bit string is valid 32 bit value
    if (bits && ![bits isEqualToString:@""])
    {
        for (int i=0; i < bits.length; i++)
        {
            NSString *strTemp = [bits substringWithRange:NSMakeRange(i, 1)];
            
            // if current bit is 1
            if ([strTemp isEqualToString:@"1"])
            {
                // replace array element with yes
                arrTemp[i] = @YES;
            }
        }
    }
    
    return arrTemp;
}

/**
 *  retruns equivalent bit string for given bit array
 *
 *  @param arr bit array
 *
 *  @return bit string
 */
+ (NSString *) getBitFromArray:(NSArray *)arr
{
    // check if array is valid
    if (!arr || [arr count] < 32)
    {
        // return default value
        return @"00000000000000000000000000000000";
    }
    else
    {
        // create a empty bit string
        NSMutableString *bits = [NSMutableString stringWithString:@""];
        
        // iterate array
        for (NSNumber *flag in arr)
        {
            // set bit value according to element value in array
            if ([flag boolValue])
            {
                [bits appendString:@"1"];
            }
            else
            {
                [bits appendString:@"0"];
            }
        }
        
        return bits;
    }
}

/**
 *  returns equivalent xml from given ranging data
 *
 *  @param  arrRangingData  ranging data collected
 *
 *  @return xml equivalent to given ranging data
 */
+ (NSString *) getXMLOfRangingData:(NSArray *)arrRangingData
{
    return [MWGUtil calculateXmlFromRangingingData:arrRangingData];
}

#pragma mark - ranging data calculations

/**
 *  returns equivalent xml from given ranging data
 *
 *  @param  arrRangingData  ranging data collected
 *
 *  @return xml equivalent to given ranging data
 */
+ (NSString *) calculateXmlFromRangingingData:(NSArray *)arrRangingData
{
    NSMutableString *strBeaconXML = [[NSMutableString alloc] init];
    
    // get array of groups of beacon data
    NSArray *arrGroups = [self getBeaconDataGroupsFromRangingData:arrRangingData];
    
    // start writing xml with root tag i.e. <beacons>
    [strBeaconXML appendFormat:@"<%@>", beacon_master];
    
    // iterate all group of beacon data to generate their equivalent xml
    for (NSArray *arrBeacons in arrGroups)
    {
        /**
         *  Need to add xml of current beacon array group by calculating 
         *  average of all current beacon data's rssi and accuracy.
         */
        
        long rssiVal = 0.0;
        float accuracyVal = 0.0;
        
        // calculate total rssi value and accuracy value
        for (CLBeacon *beaconObj in arrBeacons)
        {
            rssiVal += beaconObj.rssi;
            accuracyVal += beaconObj.accuracy;
        }
        
        CLBeacon *beaconObj = arrBeacons[0];
        [strBeaconXML appendString:@"<beacon>"]; // start a beacon xml object
        
        [strBeaconXML appendFormat:@"<udid>%@</udid>", [beaconObj.proximityUUID UUIDString]]; // add beacon UUID
        [strBeaconXML appendFormat:@"<major>%@</major>", beaconObj.major]; // add beacon major
        [strBeaconXML appendFormat:@"<minor>%@</minor>", beaconObj.minor]; // add beacon minor
        [strBeaconXML appendFormat:@"<rssi>%f</rssi>", (float)rssiVal/(arrBeacons.count)]; // add average of beacon rssi from beacon data
        [strBeaconXML appendFormat:@"<proximity>%ld</proximity>", (long)(4 - beaconObj.proximity)]; // add beacon proximity
        [strBeaconXML appendFormat:@"<accuracy>%f</accuracy>", accuracyVal/(arrBeacons.count)]; // add average beacon accuracy
        
        [strBeaconXML appendString:@"</beacon>"]; // end a beacon xml object
    }
    
    // end writing xml with root end tag i.e. </beacons>
    [strBeaconXML appendFormat:@"</%@>", beacon_master];
    
//    NSLog(@"beacon ranging ..........\n\n%@\n\n", strBeaconXML);
    
    return strBeaconXML;
}

/**
 *  creates beacon array groupfrom ranging data. 
 *  Each group contains beacon data of same beacon
 *
 *  @param arrRangingData beacon raning data
 *
 *  @return beacon data groups
 */
+ (NSArray *) getBeaconDataGroupsFromRangingData:(NSArray *)arrRangingData
{
    NSMutableArray *arrGroups = [[NSMutableArray alloc] init];
    
    // iterate beacon data one by one and add beacon data into a group.
    for (CLBeacon *beacon in arrRangingData)
    {
        BOOL groupFoundFlag;
        
        // iterate arrgroups to find the group for current beacon data
        for (int i = 0; i< arrGroups.count; i++)
        {
            // get group from arrgroup having current iteration index
            NSMutableArray *group = arrGroups[i];
            
            // check if beacon belongs to current group.
            // If YES, add the beacon in current group and stop group iteration
            if ([self checkBeacon:beacon belongsToGroup:group])
            {
                [group addObject:beacon];
                groupFoundFlag = YES;
                break;
            }
        }
        
        // check if current beacon data is able to find the group.
        // if not, create another group and add the currenrt beacon data into new group.
        if (!groupFoundFlag)
        {
            [arrGroups addObject:[[NSMutableArray alloc] initWithObjects:beacon, nil]];
        }
    }
    
    return arrGroups;
}

+ (BOOL) checkBeacon:(CLBeacon *)beacon belongsToGroup:(NSMutableArray *)group
{
    // check if target beacon is equal to any member(first member) of group.
    return [self checkTargetBeacon:beacon isEqualToBeacon:group[0]];
}

+ (BOOL) checkTargetBeacon:(CLBeacon *)targetBeacon isEqualToBeacon:(CLBeacon *)beacon
{
    // check if uuid, major and minor of target beacon is equal to beacon's uuid,major and minor
    return ([[targetBeacon.proximityUUID UUIDString] isEqualToString:[beacon.proximityUUID UUIDString]] &&
            [targetBeacon.major intValue] == [beacon.major intValue] &&
            [targetBeacon.minor intValue] == [beacon.minor intValue]);
}

#pragma mark - Promotion Handling

/**
 *  Generates promotion activity type from the activity string received from server
 *
 *  @param act activity string received from server
 *
 *  @return Promotion activity type
 */
+ (MWGPromotionActivityType) promotionActivityType:(NSString *)act
{
    if ([act isEqualToString:@"r"]) {
        return MWG_REDEEM;
    } else {
        return MWG_HISTORY;
    }
}


@end
