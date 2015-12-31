//
//  MWGStoreParser.m
// Author:   Ranjan Patra
// Created:  23/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGStoreParser.h"
#import "MWGUtil.h"

@implementation MWGStoreParser

@synthesize delegate;

/**
 *  method to start parsing
 *
 *  @param data data to parse
 */
-(void)startParsingData:(NSData *)data
{
    arrStores = [[NSMutableArray alloc] init];
    parser = [[MWGParserEngine alloc] initParserEngineWithData:data
                                                   andDelegate:self];
}


#pragma mark Parser Engine Delegates

/**
 *  delegate method called by a parser engine when it encounters a start tag for a given element.
 *
 *  @param tag        xml tag name encountered.
 */
-(void)parserEngineFoundStartTag:(NSString *)tag
{
    if (isCurrentlyHourBeingParsed)
    {
        // check if tag has day name
        if (![tag isEqualToString:@"open"] &&
            ![tag isEqualToString:@"close"] &&
            ![tag isEqualToString:@"hours"])
        {
            dayHour = [[MWGDayHours alloc] init];
            dayHour.dayName = tag;
        }
    }
    else
    {
        if ([tag isEqualToString:@"store"])
        {
            // create a store object
            store = [[MWGStore alloc] init];
        }
        else if ([tag isEqualToString:@"hours"])
        {
            // create a store hours array
            arrHours = [[NSMutableArray alloc] init];
            isCurrentlyHourBeingParsed = YES;
        }
    }
}


/**
 *  Delegate method sent by a parser engine to its delegate when it encounters a fatal error.
 *
 *  @param parseError An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    // throw error
    if (delegate &&
        [delegate respondsToSelector:@selector(finishedGetStoresParsingWithError:)])
    {
        [delegate finishedGetStoresParsingWithError:error];
    }
}


/**
 *  Delegate method sent by a parser object to its delegate when it encounters an end tag for a specific element.
 *
 
 *  @param tag  A string that is the name of its end tag.
 *  @param string   string that contains data
 */
-(void)parserEngineFoundEndTag:(NSString *)tag withCharacters:(NSString *)string
{
    // handle empty string
    if (!string && [string isEqualToString:@""])
    {
        return;
    }
    // store id
    else if([tag isEqualToString:@"mid"])
    {
        store.storeId = string;
    }
    // store name
    else if([tag isEqualToString:@"mname"])
    {
        store.storeName = string;
    }
    // store image
    else if([tag isEqualToString:@"mimg"])
    {
        store.storeImage = [NSURL URLWithString:string];
    }
    // street1
    else if([tag isEqualToString:@"street1"])
    {
        store.street1 = string;
    }
    // street2
    else if([tag isEqualToString:@"street2"])
    {
        store.street2 = string;
    }
    // city
    else if([tag isEqualToString:@"city"])
    {
        store.city = string;
    }
    // state
    else if([tag isEqualToString:@"state"])
    {
        store.state = string;
    }
    // zip of store
    else if([tag isEqualToString:@"zip"])
    {
        store.zip = string;
    }
    // store country
    else if([tag isEqualToString:@"country"])
    {
        store.country = string;
    }
    // store phone number
    else if([tag isEqualToString:@"phone"])
    {
        store.phoneNumber = string;
    }
    // store latitude
    else if([tag isEqualToString:@"lat"])
    {
        store.storeLatitude = [string doubleValue];
    }
    // store longitude
    else if([tag isEqualToString:@"lon"])
    {
        store.storeLongitude = [string doubleValue];
    }
    // store
    else if([tag isEqualToString:@"store"])
    {
        [arrStores addObject:store];
        store = nil;
    }
    // store flags
    else if([tag isEqualToString:@"flags"])
    {
        store.storePreference = [MWGUtil arrayFromBits:string];
    }
    // stores hours
    else if([tag isEqualToString:@"hours"])
    {
        store.storeHours = arrHours;
        isCurrentlyHourBeingParsed = NO;
        arrHours = nil;
    }
    
    // for parsing open/close of store hours
    if (isCurrentlyHourBeingParsed)
    {
        if([tag isEqualToString:@"open"])
        {
            dayHour.openTime = string;
        }
        else if([tag isEqualToString:@"close"])
        {
            dayHour.closeTime = string;
        }
        else
        {
            [arrHours addObject:dayHour];
            dayHour = nil;
        }
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 */
-(void)parserEngineFinishParsing
{
    if (delegate &&
        [delegate respondsToSelector:@selector(finishedGetStoresParsingWithData:)])
    {
        [delegate finishedGetStoresParsingWithData:arrStores];
    }
}


@end
