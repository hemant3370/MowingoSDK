//
//  MWGParserEngine.m
//  MowingoSDK
//
//  Created by Bellurbis on 4/23/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "MWGParserEngine.h"
#import "NSString+HTML.h"
#import "MWGError.h"
#import "MWGConstants.h"

#define kTagStatus @"status"

@interface MWGParserEngine()
{
    id<MWGParserEngineDelegate> parserDelegate;
    
    NSMutableString *strParsedString;// keeps parsed string for current xml tag
}
@end

@implementation MWGParserEngine


/**
 *  initialize parser engine class and starts xml parser
 *
 *  @param data     xml data to parse
 *  @param delegate delegate
 *
 *  @return parser engine object
 */
-(id)initParserEngineWithData:(NSData *)data
                  andDelegate:(__weak id<MWGParserEngineDelegate>)delegate
{
    if (self = [super init])
    {
        //set delegate
        parserDelegate = delegate;
        
        //decode data to utf-8
        NSData *dataToParse = [self formatXmlData:data];
        
        if (dataToParse && [dataToParse length] > 0)
        {
            //start parser
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:dataToParse];
            [xmlParser setDelegate:self];
            [xmlParser setShouldResolveExternalEntities:YES];
            [xmlParser parse];
        }
        else
        {
            //report data cannot be converted into utf-8
            if (parserDelegate && [parserDelegate respondsToSelector:@selector(parserEngineFailedWithError:)])
            {
                [parserDelegate parserEngineFailedWithError:[MWGError invalidEncodedDataError]];
            }
        }
    }
    
    return self;
}

#pragma mark XML Parser Delegates

/**
 *  Delegate method sent by the parser object to the delegate when it begins parsing a document.
 *
 *  @param parser current parser object.
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    if (!strParsedString)
    {
        strParsedString = [[NSMutableString alloc] init];
    }    
}


/**
 *  delegate method sent by a parser object to its delegate when it encounters a start tag for a given element.
 *
 *  @param parser        current parser object.
 *  @param elementName   A string that is the name of an element (in its start tag).
 *  @param namespaceURI  If namespace processing is turned on, contains the URI for the current namespace as a string object.
 *  @param qName         If namespace processing is turned on, contains the qualified name for the current namespace as a string object.
 *  @param attributeDict A dictionary that contains any attributes associated with the element. Keys are the names of attributes, and values are attribute values.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI  qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    if (![elementName isEqualToString:kTagStatus])
    {
        if (parserDelegate && [parserDelegate respondsToSelector:@selector(parserEngineFoundStartTag:)])
        {
            [parserDelegate parserEngineFoundStartTag:elementName];
        }
    }
}
/**
 *  delegate method sent by a parser object to provide its delegate with a string representing all or part of the characters of the current element.
 *
 *  @param parser current parser object.
 *  @param string A string representing the complete or partial textual content of the current element.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *tempStr = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    
    tempStr =	[tempStr stringByReplacingOccurrencesOfString:@"`_" withString:@"&"];
    tempStr =	[tempStr stringByReplacingOccurrencesOfString:@"`e" withString:@"\u00e9"];
    tempStr =	[tempStr stringByReplacingOccurrencesOfString:@"`d" withString:@"\u00e9e"];
    tempStr =	[tempStr stringByReplacingOccurrencesOfString:@"`r" withString:@"\u00ae"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"`br" withString:@"<br/>"];
    
    [strParsedString appendString:tempStr];
    
    //convert HTML string into plain text
    if (strParsedString && ![strParsedString isEqualToString:@""])
    {
        strParsedString = [[NSMutableString alloc] initWithString:[strParsedString stringByConvertingHTMLToPlainText]];
    }
}

/**
 *  Delegate method sent by a parser object to its delegate when it encounters a fatal error.
 *
 *  @param parser     current parser object
 *  @param parseError An NSError object describing the parsing error that occurred.
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (parserDelegate && [parserDelegate respondsToSelector:@selector(parserEngineFailedWithError:)])
    {
        [parserDelegate parserEngineFailedWithError:[MWGError badResponseDataFormatWithParserError:parseError]];
    }
}

/**
 *  Delegate method sent by a parser object to its delegate when it encounters an end tag for a specific element.
 *
 *  @param parser       current parser object
 *  @param elementName  A string that is the name of an element (in its end tag).
 *  @param namespaceURI If namespace processing is turned on, contains the URI for the current namespace as a string object.
 *  @param qName        If namespace processing is turned on, contains the qualified name for the current namespace as a string object.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (![elementName isEqualToString:kTagStatus])
    {
        if (parserDelegate && [parserDelegate respondsToSelector:@selector(parserEngineFoundEndTag:withCharacters:)])
        {
            [parserDelegate parserEngineFoundEndTag:elementName withCharacters:strParsedString];
        }
    }
    else
    {
        NSError *error;
        
        //check server status
        if ([strParsedString isEqualToString:@"-1"])
        {
            error = [MWGError serverStatusError];
        }
        else if ([strParsedString isEqualToString:@"-2"])
        {
            error = [MWGError authenticationFailedError];
        }
        
        if (error)
        {
            //throw error
            if (parserDelegate && [parserDelegate respondsToSelector:@selector(parserEngineFailedWithError:)])
            {
                [parserDelegate parserEngineFailedWithError:error];
            }
            
            //stop parser
            [parser abortParsing];
        }
    }
    
    // nullify parsed string
    strParsedString = [NSMutableString stringWithString:@""];
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 *
 *  @param parser current parser object
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (parserDelegate && [parserDelegate respondsToSelector:@selector(parserEngineFinishParsing)])
    {
        [parserDelegate parserEngineFinishParsing];
    }
}

#pragma mark - Misc

/**
 *  Method to format XML data received as a response and make it usable for parser
 *
 *  @param theData data received in response
 *
 *  @return formatted data
 */
- (NSData *)formatXmlData:(NSData *)theData
{
    NSData *retData;
    
    
    NSString *dealssString = [[NSString alloc] initWithData:theData encoding:APP_DATA_ENCODING] ;
    
    if (!dealssString) {
        dealssString = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
        
    }
    NSString *newDelasString = [dealssString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//[newStr substringFromIndex:2];
    if (newDelasString) {
        if ([newDelasString rangeOfString:@"&amp;"].length ) {
            newDelasString = [newDelasString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"`_"];
        }
        if ([newDelasString rangeOfString:@"\u00e9"].length) {
            newDelasString = [newDelasString stringByReplacingOccurrencesOfString:@"\u00e9" withString:@"`e"];
        }
        
        newDelasString = [newDelasString stringByReplacingOccurrencesOfString:@"\u00e9e" withString:@"`d"];
        newDelasString = [newDelasString stringByReplacingOccurrencesOfString:@"\u00ae" withString:@"`r"];
        newDelasString = [newDelasString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"`br"];
        newDelasString = [newDelasString stringByReplacingOccurrencesOfString:@"&" withString:@"`_"];
        
        newDelasString = [newDelasString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        retData = [newDelasString dataUsingEncoding:APP_DATA_ENCODING];
        
    }else {
        retData = theData;
    }
    return retData;
}

@end
