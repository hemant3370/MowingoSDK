//
//  MWGLoginParser.h
// Author:   Ranjan Patra
// Created:  17/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGParserEngine.h"


/**
 *  Delegate method for login parser, called when parsing is completed
 */
@protocol MWGLoginParserDelegate <NSObject>
-(void)finishedLoginParsingWithData:(NSDictionary *)dict;
-(void)finishedLoginParsingWithError:(NSError *)error;
@end


@interface MWGLoginParser : NSObject <MWGParserEngineDelegate>
{
    __weak id<MWGLoginParserDelegate> delegate;    // Login parser delegate
    
    NSMutableDictionary *dictTemp;              // Temporary Dictionary
    
    MWGParserEngine *parser;
}

@property (weak) id<MWGLoginParserDelegate> delegate;
/**
 *  initiates the parsing of the xmlgetdeal.jsp response
 *
 *  @param data raw data of xmlli.jsp response
 */
-(void)startParsingData:(NSData *)data;

@end
