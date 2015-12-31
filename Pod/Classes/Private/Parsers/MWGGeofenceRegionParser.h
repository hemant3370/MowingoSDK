//
//  MDStoreLocationParser.h
// Author:   Ranjan Patra
// Created:  11/6/2012
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGLocation.h"
#import "MWGParserEngine.h"

/**
 *  Delegate for parsing regions
 */
@protocol MWGGeofenceRegionParserDelegate <NSObject>
-(void)finishedRegionParsingWithData:(NSArray *)arrRegions;
-(void)finishedRegionParsingWithError:(NSError *)error;
@end

@interface MWGGeofenceRegionParser : NSObject<MWGParserEngineDelegate>
{
    __weak id<MWGGeofenceRegionParserDelegate> delegate;       // Region Parser Delegate
    
    MWGParserEngine *parser;
}

/**
 *  Parse the data received
 *
 *  @param data data received from the webservice to be parsed
 */
-(void)parseData:(NSData *)data;

@property (weak) id<MWGGeofenceRegionParserDelegate> delegate;     // Region parser delegate

@end
