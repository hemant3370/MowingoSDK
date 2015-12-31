//
//  MWGParserEngine.h
//  MowingoSDK
//
//  Created by Bellurbis on 4/23/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  Protocol for parser engine
 */
@protocol MWGParserEngineDelegate <NSObject>

@optional

/**
 *  delegate method called when parser engine encounters a start tag
 *
 *  @param tag tag value that is encountered while parsing
 */
-(void)parserEngineFoundStartTag:(NSString *)tag;

/**
 *  delagate method called when parser engine encounters a end tag
 *
 *  @param tag    the ending tag value
 *  @param string the string data for the tag
 */
-(void)parserEngineFoundEndTag:(NSString *)tag withCharacters:(NSString *)string;

/**
 *  delegate method called when parser engine finish parsing xml
 */
-(void)parserEngineFinishParsing;

/**
 *  delegate method called when parser engine fails
 *
 *  @param error error object
 */
-(void)parserEngineFailedWithError:(NSError *)error;

@end


/**
    class that handles xml parsing mechanism for sdk
 */

@interface MWGParserEngine : NSObject<NSXMLParserDelegate>

/**
 *  initialize parser engine class and starts xml parser
 *
 *  @param data     xml data to parse
 *  @param delegate delegate
 *
 *  @return parser engine object
 */
-(id)initParserEngineWithData:(NSData *)data
                  andDelegate:(id<MWGParserEngineDelegate>)delegate;


@end
