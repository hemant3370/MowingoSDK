//
// MWGStoreParser.h
// Author:   Ranjan Patra
// Created:  23/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//


#import <Foundation/Foundation.h>
#import "MWGStore.h"
#import "MWGParserEngine.h"

/**
 *  protocol for get store parser
 */
@protocol MWGStoreParserDelegate <NSObject>

/**
 *  Delegate method called when get stores parser finishes successfully
 *
 *  @param stores stores processed
 */
-(void)finishedGetStoresParsingWithData:(NSMutableArray *)stores;

/**
 *  Delegate method called when get stores parser fails
 *
 *  @param error error object
 */
-(void)finishedGetStoresParsingWithError:(NSError *)error;

@end

/**
 *  Class used to parse stores xml
 */
@interface MWGStoreParser : NSObject <MWGParserEngineDelegate>
{
    NSMutableArray *arrStores; // stores store objects
    MWGStore *store; // store object
    
    MWGParserEngine *parser; // parser engine
    
    BOOL isCurrentlyHourBeingParsed; // if hours is currently being parsed
    NSMutableArray *arrHours; // stores weekly open hours for a store
    MWGDayHours *dayHour; // day hour object
    
    __weak id<MWGStoreParserDelegate> delegate;
}

/**
 *  delegate object for parser
 */
@property(weak) id<MWGStoreParserDelegate> delegate;

/**
 *  method to start parsing
 *
 *  @param data data to parse
 */
-(void)startParsingData:(NSData *)data;

@end
