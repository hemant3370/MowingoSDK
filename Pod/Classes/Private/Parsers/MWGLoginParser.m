//
//  MWGLoginParser.m
// Author:   Ranjan Patra
// Created:  17/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGLoginParser.h"

@implementation MWGLoginParser

@synthesize delegate;

#pragma mark Helper Methods

/**
 *  initiates the parsing of the xmlli.jsp response
 *
 *  @param data raw data of xmlli.jsp response
 */

-(void)startParsingData:(NSData *)data
{
    dictTemp = [[NSMutableDictionary alloc] init];
    parser = [[MWGParserEngine alloc] initParserEngineWithData:data
                                                   andDelegate:self];
}

#pragma mark
#pragma mark xmlparser


/**
 *  Delegate method sent by a parser object to its delegate when it encounters an end tag for a specific element.
 *
 *  @param tag  A string that is the name of an element (in its end tag).
 *  @param string  string that contains data
 */
-(void)parserEngineFoundEndTag:(NSString *)tag withCharacters:(NSString *)string
{
    if (![tag isEqualToString:@"msg"])
    {
        if (string &&
            ![string isEqualToString:@""])
        {
            dictTemp[tag] = [string copy];
        }
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 *
 */
-(void)parserEngineFinishParsing
{
    
    if (delegate && [delegate respondsToSelector:@selector(finishedLoginParsingWithData:)])
    {
        [delegate finishedLoginParsingWithData:dictTemp];
    }
}

/**
 *  Delegate method sent by a parser object to its delegate when it encounters a fatal error.
 *
 *  @param error An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (delegate && [delegate respondsToSelector:@selector(finishedLoginParsingWithError:)])
    {
        [delegate finishedLoginParsingWithError:error];
    }
}





@end
