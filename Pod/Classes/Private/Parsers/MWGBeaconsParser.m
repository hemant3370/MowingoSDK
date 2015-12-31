//
//  MWGBeaconsParser.m
// Author:   Ranjan Patra
// Created:  1/4/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGBeaconsParser.h"
#import "MWGConstants.h"


#define         BEACON_ROOT         @"beacon"



@implementation MWGBeaconsParser

@synthesize delegate;

#pragma mark Helper Methods

- (void)startParsingData:(NSData *)beaconData
{
    arrBeacons =[[NSMutableArray alloc] init];
    
    parser = [[MWGParserEngine alloc] initParserEngineWithData:beaconData
                                                   andDelegate:self];
    
    
}

#pragma mark Parser Engine Delegates

/**
 *  delegate method called by a parser engine when it encounters a start tag for a given element.
 *
 *  @param tag        xml tag name encountered.
 */
-(void)parserEngineFoundStartTag:(NSString *)tag
{
    if ([tag isEqualToString:BEACON_ROOT])
    {
        beaconObj =[[MWGBeaconCore alloc] init];
    }
}


/**
 *  Delegate method sent by a parser engine to its delegate when it encounters a fatal error.
 *
 *  @param parseError An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (delegate && [delegate respondsToSelector:@selector(finishedBeaconParsingWithError:)])
    {
        [delegate finishedBeaconParsingWithError:error];
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
    if (!string && [string isEqualToString:@""])
    {
        return;
    }
    
    if ([tag isEqualToString:BEACON_ROOT])
    {
        [arrBeacons addObject:beaconObj];
    }
    else if([tag isEqualToString:beacon_id])
    {
        beaconObj.bid = [string copy];
    }
    else if([tag isEqualToString:beacon_uuid])
    {
        beaconObj.budid = [string copy];
    }
    else if([tag isEqualToString:beacon_minor])
    {
        beaconObj.minor = [string copy];
    }
    else if([tag isEqualToString:beacon_major])
    {
        beaconObj.major = [string copy];
    }
    else if([tag isEqualToString:beacon_proximity])
    {
        beaconObj.proximity = [string copy];
    }
    else if([tag isEqualToString:beacon_type])
    {
        beaconObj.type = [string copy];
    }
    else if([tag isEqualToString:beacon_intxt])
    {
        beaconObj.inTxt = [string copy];
    }
    else if([tag isEqualToString:beacon_outtxt])
    {
        beaconObj.outText = [string copy];
    }
    else if([tag isEqualToString:beacon_did])
    {
        beaconObj.did = [string copy];
    }
    else if([tag isEqualToString:beacon_pid])
    {
        beaconObj.pid = [string copy];
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 */
-(void)parserEngineFinishParsing
{
    if (delegate && [delegate respondsToSelector:@selector(finishedBeaconParsingWithData:)])
    {
        [delegate finishedBeaconParsingWithData:arrBeacons];
    }
}


@end
