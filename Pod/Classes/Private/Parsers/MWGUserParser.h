//
//  MWGUserParser.h
// Author:   Ranjan Patra
// Created:  13/5/2011
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGParserEngine.h"

/**
 *  Delegate to detect the end of User parsing
 */
@protocol MWGUserParserDelegate <NSObject>

/**
 *  delegate for Users xml parsing completion
 */
-(void)finishedUserParsing;

/**
 *  delegate for error while parsing user xml
 *
 *  @param error error object
 */
-(void)finishedUserParsingWithError:(NSError *)error;

@end

@interface MWGUserParser : NSObject <MWGParserEngineDelegate>
{
    BOOL comingFromNotif;               // Bool value to check if comming from notification
    
    __weak id<MWGUserParserDelegate> delegate; //User Parser Delegate
    
    MWGParserEngine *parser;
}

/**
 *  Method called to start parsing the document
 *
 *  @param usersData data received as a response
 */
- (void)parseData:(NSData *)usersData;

/**
 *  Method called to initiate Notification
 *
 *  @param shouldCall BOOL value to detect the calling status
 *
 *  @return return notification description
 */
- (id)initWithNotification:(BOOL)shouldCall;//created by ranjan.....10th oct


@property (weak) id<MWGUserParserDelegate> delegate;   //User Parser Delegate

@end
