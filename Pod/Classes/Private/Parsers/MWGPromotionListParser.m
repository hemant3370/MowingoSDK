//
// IMGXMLParser.m
// Author:   Ranjan Patra
// Created:  5/9/2011
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGPromotionListParser.h"
#import "MWGUtil.h"


#define kLocName                                @"locname"      // Constant for Location Name

@implementation MWGPromotionListParser

- (id)init{
	self = [super init];
	if (self){
		
	}
	return self;
}


/**
 *  Method to parse deal data with promotion completion block
 *
 *  @param dealsData deal data
 *  @param block     Promotions Completion Block
 */
- (void)parseData:(NSData *)dealsData withCompletion:(PromotionsParsingCompletionBlock)block
{
    
    if (block)
    {
        promotionBlock = block;
    }
    
    parser = [[MWGParserEngine alloc] initParserEngineWithData:dealsData
                                                   andDelegate:self];
}

#pragma mark XML Parser Delegates

/**
 *  delegate method sent by a parser object to its delegate when it encounters a start tag for a given element.
 *
 *  @param tag   A string that is the name of an element (in its start tag).
 */
-(void)parserEngineFoundStartTag:(NSString *)tag
{
	if([tag isEqualToString:@"deals"])
	{
		objList = [[NSMutableArray alloc] initWithCapacity:0];
	}
	else if([tag isEqualToString:@"deal"])
	{
		promotionData = [[MWGPromotion alloc] init];
	}
}



/**
 *  Delegate method sent by a parser object to its delegate when it encounters a fatal error.
 *
 *  @param error An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (promotionBlock)
    {
        promotionBlock(nil, nil, nil, error);
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
	if([tag isEqualToString:@"deals"])
		return;
	
	else if([tag isEqualToString:@"deal"]) 
	{
		[objList addObject:promotionData];
	    promotionData = nil;
	}
    // unique identifier for promotion
    else if ([tag isEqualToString:@"did"])
    {
        promotionData.promotionId = string;
	}
    // image url for promotion
	else if ([tag isEqualToString:@"image"])
	{
		promotionData.promotionImageUrl = [NSURL URLWithString:string];
	}
    // merchant name of promotion
	else if ([tag isEqualToString:@"mname"])
	{
        
		promotionData.merchantName= [string copy];
	}
    // description of merchant
	else if ([tag isEqualToString:@"ddesc"])
	{
		promotionData.promotionTitle = [string copy];
	}
    // activity flag of promotion
	else if ([tag isEqualToString:@"act"])
	{
        promotionData.promotionActivity = [MWGUtil promotionActivityType:string];
    }
    // start date time of promotion
    else if ([tag isEqualToString:@"start"] || [tag isEqualToString:@"startdt"])
    {
        if(string && ![string isEqualToString:@""])
        {
            promotionData.promotionStartDateTime = [MWGUtil getDateFromUnix:string];
        }
        else
        {
            promotionData.promotionStartDateTime = nil;
        }
        
        
    }
    // end date time of promotion
    else if ([tag isEqualToString:@"expdt"] || [tag isEqualToString:@"end"])
    {
        if(string && ![string isEqualToString:@""])
        {
            promotionData.promotionEndDateTime = [MWGUtil getDateFromUnix:string];
        }
        else
        {
            promotionData.promotionEndDateTime = nil;
        }
    }
    else if([tag isEqualToString:@"locname" ])
    {
        promotionData.merchantPlaceName = [string copy];
    }
    else if([tag isEqualToString:@"type"])
    {
        promotionData.promotionType = [string copy];
    }
    else if([tag isEqualToString:@"pcurl"])
    {
        strPcUrlValue = [string copy];
    }
    else if ([tag isEqualToString:@"terms"])
    {
        promotionData.promotionDescription = [string copy];
    }
    else if([tag isEqualToString:@"link" ])
    {
        promotionData.promotionUrl = [NSURL URLWithString:string];
    }
}

/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 *
 */
-(void)parserEngineFinishParsing
{
    promotionBlock(objList, nil, nil, nil);
}

@end
