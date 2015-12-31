//
//  MWGPromotionDetailParser.h
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGPromotion.h"
#import "MWGParserEngine.h"


@protocol MWGPromotionDetailParserDelegate <NSObject>
-(void)finishedDealDetailParsingWithObject:(MWGPromotion *)deal;
-(void)finishedDealDetailParsingWithError:(NSError *)error;
@end

@interface MWGPromotionDetailParser : NSObject<MWGParserEngineDelegate>
{
    MWGPromotion *promotion;
    
    MWGParserEngine *parser;
}

@property(weak) id<MWGPromotionDetailParserDelegate> delegate;

-(void)startParsingData:(NSData *)data;

@end
