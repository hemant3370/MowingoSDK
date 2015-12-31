//
//  MWGGeofenceParser.h
//  MowingoSDK
//
//  Created by Bellurbis on 5/5/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWGParserEngine.h"
#import "MWGGeofence.h"

/**
 *  Protocols for geofence parsing events
 */
@protocol MWGGeofencesListParserDelegate <NSObject>

/**
 *  Calls when geofence parser finishes successfully
 *
 *  @param arrGeofence array of geofence object
 */
-(void)finishedGeofenceParsingWithData:(NSArray *)arrGeofence;

/**
 *  Calls when geofence parser finishes with failure
 *
 *  @param error error object
 */
-(void)finishedGeofenceParsingWithError:(NSError *)error;
@end

/**
 *  class that handles geofence data parsing
 */
@interface MWGGeofenceParser : NSObject<MWGParserEngineDelegate>
{
    NSMutableArray *arrGeofences;// array of geofence
    
    MWGGeofence *geofenceObj;//geofence object
    
    MWGParserEngine *parser;//parser engine object
    
    __weak id<MWGGeofencesListParserDelegate> delegate;//delegate object to handle parser's protocol
}

/**
 *  delegate object to handle parser's protocol
 */
@property(weak) id<MWGGeofencesListParserDelegate> delegate;

/**
 *  starts parsing data recieved
 *
 *  @param data data recieved from server
 */
-(void)startParsingData:(NSData *)data;

@end
