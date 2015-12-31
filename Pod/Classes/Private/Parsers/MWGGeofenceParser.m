//
//  MWGGeofenceParser.m
//  MowingoSDK
//
//  Created by Bellurbis on 5/5/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "MWGGeofenceParser.h"
#import "MWGConstants.h"


#define         GEOFENCE_ROOT         @"geofence" //geofence elements root tag


/**
 *  class that handles geofence data parsing
 */
@implementation MWGGeofenceParser


@synthesize delegate;

#pragma mark Helper Methods

- (void)startParsingData:(NSData *)geofenceData
{
    arrGeofences =[[NSMutableArray alloc] init];
    
    //start parer engine
    parser = [[MWGParserEngine alloc] initParserEngineWithData:geofenceData
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
    if ([tag isEqualToString:GEOFENCE_ROOT])
    {
        geofenceObj =[[MWGGeofence alloc] init];
    }
}


/**
 *  Delegate method sent by a parser engine to its delegate when it encounters a fatal error.
 *
 *  @param parseError An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (delegate && [delegate respondsToSelector:@selector(finishedGeofenceParsingWithError:)])
    {
        [delegate finishedGeofenceParsingWithError:error];
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
    
    if ([tag isEqualToString:GEOFENCE_ROOT])
    {
        [arrGeofences addObject:geofenceObj];
    }
    else if([tag isEqualToString:geofence_id])
    {
        geofenceObj.gfid = [string copy];
    }
    else if([tag isEqualToString:geofence_lat])
    {
        geofenceObj.gflat = [string copy];
    }
    else if([tag isEqualToString:geofence_long])
    {
        geofenceObj.gflon = [string copy];
    }
    else if([tag isEqualToString:geofence_radius])
    {
        geofenceObj.radius = [string copy];
    }
    else if([tag isEqualToString:geofence_type])
    {
        geofenceObj.type = [string copy];
    }
    else if([tag isEqualToString:geofence_intxt])
    {
        geofenceObj.intxt = [string copy];
    }
    else if([tag isEqualToString:geofence_outtxt])
    {
        geofenceObj.outtxt = [string copy];
    }
    else if([tag isEqualToString:geofence_did])
    {
        geofenceObj.did = [string copy];
    }
    else if([tag isEqualToString:geofence_pid])
    {
        geofenceObj.pid = [string copy];
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 */
-(void)parserEngineFinishParsing
{
    if (delegate && [delegate respondsToSelector:@selector(finishedGeofenceParsingWithData:)])
    {
        [delegate finishedGeofenceParsingWithData:arrGeofences];
    }
}




@end
