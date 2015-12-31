//
//  MWGBeaconsParser.h
// Author:   Ranjan Patra
// Created:  1/4/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <Foundation/Foundation.h>
#import "MWGBeaconCore.h"
#import "MWGParserEngine.h"

@protocol MWGBeaconsListParserDelegate <NSObject>
-(void)finishedBeaconParsingWithData:(NSArray *)arrBeacon;
-(void)finishedBeaconParsingWithError:(NSError *)error;
@end

@interface MWGBeaconsParser : NSObject<MWGParserEngineDelegate>
{
    NSMutableArray *arrBeacons;
    
    MWGBeaconCore *beaconObj;
    
    MWGParserEngine *parser;
    
    __weak id<MWGBeaconsListParserDelegate> delegate;
}

@property(weak) id<MWGBeaconsListParserDelegate> delegate;

-(void)startParsingData:(NSData *)data;

@end
