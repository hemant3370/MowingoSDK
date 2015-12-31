//
//  MWGUserParser.m
// Author:   Ranjan Patra
// Created:  13/5/2011
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGUserParser.h"
#import "MWGSDKMangerCore.h"
#import "MWGError.h"


@implementation MWGUserParser
@synthesize delegate;

#pragma mark Helper Methods


/**
 *  Method called to initiate Notification
 *
 *  @param shouldCall BOOL value to detect the calling status
 *
 *  @return return notification description
 */
- (id)initWithNotification:(BOOL)shouldCall
{
	self = [super init];
	if (self)
    {
        
        comingFromNotif = shouldCall;
		
	}
	return self;
}

/**
 *  Method to initiate the parser class
 *
 *  @return returns self
 */

- (id)init{
	self = [super init];
	if (self){
		
	}
	return self;
}


/**
 *  Method called to start parsing the document
 *
 *  @param usersData data received as a response
 */
- (void)parseData:(NSData *)usersData
{
    parser = [[MWGParserEngine alloc] initParserEngineWithData:usersData
                                                   andDelegate:self];
}

#pragma mark XML Parser Delegates


/**
 *  Delegate method sent by a parser object to its delegate when it encounters a fatal error.
 *
 *  @param error An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (delegate && [delegate respondsToSelector:@selector(finishedUserParsingWithError:)])
    {
        [delegate finishedUserParsingWithError:error];
    }
}


/**
 *  Delegate method sent by a parser object to its delegate when it encounters an end tag for a specific element.
 *
 *  @param tag  A string that is the name of an element (in its end tag).
 *  @param string  string that contains data
 */
-(void)parserEngineFoundEndTag:(NSString *)tag withCharacters:(NSString *)string
{
    if ([tag isEqualToString:@"email"])
	{
		if ([string isEqualToString:@"y"] || [string isEqualToString:@"Y"])
			[[MWGSDKMangerCore sharedInstance] setNotifyByEmail:1];
		else 
			[[MWGSDKMangerCore sharedInstance] setNotifyByEmail:0];
		
	}
	else if ([tag isEqualToString:@"sms"])
	{
		if ([string isEqualToString:@"y"] || [string isEqualToString:@"Y"])
			[[MWGSDKMangerCore sharedInstance] setNotifyBySms:1];
		else 
			[[MWGSDKMangerCore sharedInstance] setNotifyBySms:0];
		
	}
	else if ([tag isEqualToString:@"loc"])
	{
		if ([string isEqualToString:@"y"] || [string isEqualToString:@"Y"])
			[[MWGSDKMangerCore sharedInstance] setNotifyByLOC:1];
		else 
			[[MWGSDKMangerCore sharedInstance] setNotifyByLOC:0];
	
	}
	else if ([tag isEqualToString:@"zip"])
	{
		[[MWGSDKMangerCore sharedInstance] setUserZipCode:string];
	}
	else if ([tag isEqualToString:@"emaddr"])
	{
		[[MWGSDKMangerCore sharedInstance] setUserEmailAddredd:string];
	}
	else if ([tag isEqualToString:@"phone"])
	{
		[[MWGSDKMangerCore sharedInstance] setUserPhoneNumber:string];
	}
	else if ([tag isEqualToString:@"bstore"])
	{
		[[MWGSDKMangerCore sharedInstance] setBrandedStoreStr:string];
		
		//[sharedObject setBrandedStoreStr:@"0"]; // for avoid branded store
	}
	else if ([tag isEqualToString:@"status"])
	{
		[[MWGSDKMangerCore sharedInstance] setUserStatus:string];
	}
    else if ([tag isEqualToString:@"ukey"])
	{
		[[MWGSDKMangerCore sharedInstance] setDeviceHashedUUIdStr:string];
	}
    else if ([tag isEqualToString:@"pup"])
    {
        [[MWGSDKMangerCore sharedInstance] setUserPupValue:string];
        
    }
    else if ([tag isEqualToString:@"puptxt"])
    {
        [[MWGSDKMangerCore sharedInstance] setUserPupText:string];
    }
    else if ([tag isEqualToString:@"puplnk"])
    {
        [[MWGSDKMangerCore sharedInstance] setUserPupUrl:string];
    }
	
}

/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 *
 */
-(void)parserEngineFinishParsing
{
    
    if (delegate && [delegate respondsToSelector:@selector(finishedUserParsing)])
    {
        [delegate finishedUserParsing];
    }
}

@end
