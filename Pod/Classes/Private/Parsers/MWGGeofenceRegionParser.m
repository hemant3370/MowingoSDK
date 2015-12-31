//
//  MDStoreLocationParser.m
// Author:   Ranjan Patra
// Created:  11/6/2012
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

 
 



#import "MWGGeofenceRegionParser.h"
#import "MWGConstants.h"


#define         kLocationElementName           @"loc"

@implementation MWGGeofenceRegionParser
{
    MWGLocation *locationObject;
    NSMutableArray *locatiosArray;
}

@synthesize delegate;

#pragma mark Helper Methods

/**
 *  Parse the data received
 *
 *  @param data data received from the webservice to be parsed
 */
-(void)parseData:(NSData *)data
{
    locatiosArray =[[NSMutableArray alloc] init];
    parser = [[MWGParserEngine alloc] initParserEngineWithData:data
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
        
    if ([tag isEqualToString:kLocationElementName])
    {
        locationObject =[[MWGLocation alloc] init];
    }

}


/**
 *  Delegate method sent by a parser object to its delegate when it encounters a fatal error.
 *
 *  @param error An NSError object describing the parsing error that occurred.
 */
-(void)parserEngineFailedWithError:(NSError *)error
{
    if (delegate && [delegate respondsToSelector:@selector(finishedRegionParsingWithError:)])
    {
        [delegate finishedRegionParsingWithError:error];
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
    
    if ([tag isEqualToString:geofence_id]) 
    {
        [locationObject setLocationId:string];
    }
    else if([tag isEqualToString:geofence_latitute])
    {
        [locationObject setLatitude:[string doubleValue]];        
    }
    else if([tag isEqualToString:geofence_longitude])
    {
        [locationObject setLongitude:[string doubleValue]];        
    }
    else if([tag isEqualToString:geofence_radius])
    {
        [locationObject setRadius:[string doubleValue]];
    }
    else if( [tag isEqualToString:kLocationElementName])
    {
        [locatiosArray addObject:locationObject];
    }
}



/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 *
 */
-(void)parserEngineFinishParsing
{
    if (delegate && [delegate respondsToSelector:@selector(finishedRegionParsingWithData:)])
    {
        [delegate finishedRegionParsingWithData:locatiosArray];
    }
}

@end
