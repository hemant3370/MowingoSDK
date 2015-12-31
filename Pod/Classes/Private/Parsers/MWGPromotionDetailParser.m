//
//  MWGPromotionDetailParser.m
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGPromotionDetailParser.h"
#import "MWGUtil.h"


@interface MWGPromotionDetailParser()


@end

@implementation MWGPromotionDetailParser

@synthesize delegate;

#pragma mark Helper Methods

// starts parser
-(void)startParsingData:(NSData *)data
{
    promotion = [[MWGPromotion alloc]init];
    
    parser = [[MWGParserEngine alloc] initParserEngineWithData:data
                                                   andDelegate:self];
}

#pragma mark
#pragma mark PARSER DELEGATE


/**
 *  Delegate method sent by a parser engine to its delegate when it encounters a fatal error.
 *
 *  @param parseError An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishedDealDetailParsingWithError:)])
    {
        [self.delegate finishedDealDetailParsingWithError:error];
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
    // unique identifier for promotion
    if ([tag isEqualToString:@"did"])
    {
        promotion.promotionId = string;
    }
    // image url for promotion
    else if ([tag isEqualToString:@"image"])
    {
        promotion.promotionImageUrl = [NSURL URLWithString:string];
    }
    // merchant name of promotion
    else if ([tag isEqualToString:@"mname"])
    {
        promotion.merchantName= [string copy];
    }
    // description of merchant
    else if ([tag isEqualToString:@"ddesc"])
    {
        promotion.promotionTitle = [string copy];
    }
    // activity flag of promotion
    else if ([tag isEqualToString:@"act"])
    {
        promotion.promotionActivity = [MWGUtil promotionActivityType:string];
    }
    // start date time of promotion
    else if ([tag isEqualToString:@"start"] || [tag isEqualToString:@"startdt"])
    {
        if(string && ![string isEqualToString:@""])
        {
            promotion.promotionStartDateTime = [MWGUtil getDateFromUnix:string];
        }
        else
        {
            promotion.promotionStartDateTime = nil;
        }
            
        
    }
    // end date time of promotion
    else if ([tag isEqualToString:@"expdt"] || [tag isEqualToString:@"end"])
    {
        if(string && ![string isEqualToString:@""])
        {
            promotion.promotionEndDateTime = [MWGUtil getDateFromUnix:string];
        }
        else
        {
            promotion.promotionEndDateTime = nil;
        }
    }
    else if([tag isEqualToString:@"type"])
    {
        promotion.promotionType = [string copy];
    }
    else if ([tag isEqualToString:@"terms"])
    {
        promotion.promotionDescription = [string copy];
    }
    else if([tag isEqualToString:@"locname" ])
    {
        promotion.merchantPlaceName = [string copy];
    }
    else if([tag isEqualToString:@"phone" ])
    {
        promotion.merchantPhone = [string copy];
    }
    else if([tag isEqualToString:@"link" ])
    {
        promotion.promotionUrl = [NSURL URLWithString:string];
    }
    else if([tag isEqualToString:@"bctype" ])
    {
        promotion.barcodeType = [string copy];
    }
    else if([tag isEqualToString:@"bcval" ])
    {
        promotion.barcodeValue = [string copy];
    }
    else if([tag isEqualToString:@"street" ])
    {
        promotion.merchantStreet = [string copy];
    }
    else if([tag isEqualToString:@"city" ])
    {
        promotion.merchantCity = [string copy];
    }
    else if([tag isEqualToString:@"website" ])
    {
        promotion.merchantWebsite = [string copy];
    }
    else if([tag isEqualToString:@"mlat" ])
    {
        if (string && ![string isEqualToString:@""])
        {
            promotion.merchantLatitude = [string doubleValue];
        }
        else
        {
            promotion.merchantLatitude = 0.0;
        }
    }
    else if([tag isEqualToString:@"mlong" ])
    {
        if (string && ![string isEqualToString:@""])
        {
            promotion.merchantLongitude = [string doubleValue];
        }
        else
        {
            promotion.merchantLongitude = 0.0;
        }
    }
    else if([tag isEqualToString:@"ccount" ])
    {
        if (string && ![string isEqualToString:@""])
        {
            promotion.promotionPunchCount = [NSNumber numberWithInt:[string intValue]];
        }
        else
        {
            promotion.promotionPunchCount = 0;
        }
    }
    else if([tag isEqualToString:@"ctotal" ])
    {
        if (string && ![string isEqualToString:@""])
        {
            promotion.promotionPunchTotal = [NSNumber numberWithInt:[string intValue]];
        }
        else
        {
            promotion.promotionPunchTotal = 0;
        }
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 */
-(void)parserEngineFinishParsing
{
    // call delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishedDealDetailParsingWithObject:)])
    {
        [self.delegate finishedDealDetailParsingWithObject:promotion];
    }
}

@end
