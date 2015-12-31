//
//  MWGGetUserdataParser.h
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGParserEngine.h"
#import "MWGUserData.h"

/**
 *  protocol for get userdata parser
 */
@protocol MWGGetUserDataParserDelegate <NSObject>

/**
 *  Delegate method called when get userdata parser finishes successfully
 *
 *  @param userData userdata processed
 */
-(void)finishedGetUserDataParsingWithData:(MWGUserData *)userData;

/**
 *  Delegate method called when get userdata parser fails
 *
 *  @param error error object
 */
-(void)finishedGetUserDataParsingWithError:(NSError *)error;

@end


/**
 *  Parser to parser response of xmlgetudata API
 */
@interface MWGGetUserdataParser : NSObject<MWGParserEngineDelegate>
{
    MWGUserData *userData;
    
    MWGParserEngine *parser;
    
    __weak id<MWGGetUserDataParserDelegate> delegate;
}

/**
 *  delegate object for parser
 */
@property(weak) id<MWGGetUserDataParserDelegate> delegate;

/**
 *  method to start parsing
 *
 *  @param data data to parse
 */
-(void)startParsingData:(NSData *)data;

@end
