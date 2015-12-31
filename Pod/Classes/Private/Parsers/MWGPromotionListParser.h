//
//  IMGXMLParser.h
// Author:   Ranjan Patra
// Created:  5/9/2011
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

/**
 *  Parser for parsing Deal Data
 */
#import <Foundation/Foundation.h>
#import "MWGPromotion.h"
#import "MWGParserEngine.h"

//Completion block for promotion
typedef void(^PromotionsParsingCompletionBlock)(NSArray *, NSString*, NSString *, NSError *);

@interface MWGPromotionListParser : NSObject <MWGParserEngineDelegate>
{

	NSMutableArray *objList;            // Array to store deal objects
	MWGPromotion *promotionData;           // Deal Data Object Class instance
    
    //added by ranjan..........jira 974.........17 Jul 2014
    NSString *strPcUrlValue;            //
    
    //added by ranjan..............Mcd app Requirements Doc 170001......1 April 2014
    NSString *strLocName;               // Location Name
    
    //Promotion completion Block
    PromotionsParsingCompletionBlock promotionBlock;
    
    MWGParserEngine *parser;
}

/**
 *  Method to parse deal data with promotion completion block
 *
 *  @param dealsData deal data
 *  @param block     Promotions Completion Block
 */
- (void)parseData:(NSData *)dealsData
   withCompletion:(PromotionsParsingCompletionBlock)block;
@end
