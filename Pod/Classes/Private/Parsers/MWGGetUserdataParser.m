//
//  MWGGetUserdataParser.m
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGGetUserdataParser.h"
#import "MWGUtil.h"

@interface  MWGUserData ()

/**
 *  interpret user gender
 *
 *  @param gender gender string received from server
 *
 */
- (void) getuserGenderFromString:(NSString *)gender;

@end


/**
 *  Parser to parser response of xmlgetudata API
 */
@implementation MWGGetUserdataParser

@synthesize delegate;

/**
 *  method to start parsing
 *
 *  @param data data to parse
 */
-(void)startParsingData:(NSData *)data
{
    // start parser engine
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
    if ([tag isEqualToString:@"udata"])
    {
        // create a userdata object
        userData =[[MWGUserData alloc] init];
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
        [delegate respondsToSelector:@selector(finishedGetUserDataParsingWithError:)])
    {
        [delegate finishedGetUserDataParsingWithError:error];
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
    // first name
    else if([tag isEqualToString:@"fname"])
    {
        userData.firstName = string;
    }
    // family name
    else if([tag isEqualToString:@"lname"])
    {
        userData.familyname = string;
    }
    // user email
    else if([tag isEqualToString:@"email"])
    {
        userData.userEmail = string;
    }
    // phone number
    else if([tag isEqualToString:@"phone"])
    {
        userData.phoneNumber = string;
    }
    // zip value
    else if([tag isEqualToString:@"zip"])
    {
        userData.zip = string;
    }
    // user prefered language
    else if([tag isEqualToString:@"lang"])
    {
        userData.userLanguage = string;
    }
    // user gender
    else if([tag isEqualToString:@"gender"])
    {
        [userData getuserGenderFromString:string];
    }
    else if([tag isEqualToString:@"msgrefs"])
    {
        userData.messagePreferences = [MWGUtil arrayFromBits:string];
    }
    // product preferences
    else if([tag isEqualToString:@"prefs"])
    {
        userData.productPreferences = [MWGUtil arrayFromBits:string];
    }
    // dob
    else if([tag isEqualToString:@"dob"])
    {
        userData.dob = [MWGUtil getDateFromUnix:string];
    }
    // user group name
    else if([tag isEqualToString:@"groupname"])
    {
        userData.groupname = string;
    }
    // user prefered language
    else if([tag isEqualToString:@"currentbudget"])
    {
        float budget = [string floatValue];
        userData.currentbudget = [NSNumber numberWithFloat:budget];
    }
    // user prefered language
    else if([tag isEqualToString:@"totalbudget"])
    {
        float budget = [string floatValue];
        userData.totalbudget = [NSNumber numberWithFloat:budget];
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 */
-(void)parserEngineFinishParsing
{
    if (delegate &&
        [delegate respondsToSelector:@selector(finishedGetUserDataParsingWithData:)])
    {
        [delegate finishedGetUserDataParsingWithData:userData];
    }
}


@end
