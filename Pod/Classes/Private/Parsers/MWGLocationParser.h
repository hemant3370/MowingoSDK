//
//  MWGLocationParser.h
//
// Author: Ranjan Patra
// Email: ranjan.patra@bellurbis.com
// Created: 4 mar 2014
// summary: location parser
// Copyright 2012 Mowingo. All rights reserved.

#import <Foundation/Foundation.h>
#import "MWGLocation.h"
#import "MWGParserEngine.h"

/**
 *  Completion block for restaurant parsing
 *
 *  @param NSArray array which contains restaurant list
 */
typedef void(^RestaurantsParsingCompletionBlock)(NSArray *, NSError *);

@interface MWGLocationParser : NSObject <MWGParserEngineDelegate>
{
    RestaurantsParsingCompletionBlock restaurantsBlock; // instance for restaurant parsing completion block
    
    MWGParserEngine *parser;
}


/**
 *  Method to parse data for restaurant details
 *
 *  @param locationData data of location
 *  @param block        Restaurant Parsing Completion Block
 */
- (void)parseData:(NSData *)locationData
   withCompletion:(RestaurantsParsingCompletionBlock)block;
@end
