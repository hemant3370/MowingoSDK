//
//  MWGLocationParser.m
//
// Author: Ranjan Patra
// Email: ranjan.patra@bellurbis.com
// Created: 4 mar 2014
// summary: location parser
// Copyright 2012 Mowingo. All rights reserved.

/*
 
  <mid>78</mid>
                        <mname>Ehud's</mname>
                        <street>
                        <city>
                        <lat>37.8346</lat>
                        <lon>-122.19829</lon>
                        <mcdflg>N</mcdflg>
                        <ocflag>T</ocflag>
 */

//modified by ranjan.........MYB-122.......29 sep 2014
#define kStoreId                                @"mid"      //Merchant id
#define kStoreNameElement                       @"store"    //Store Name
#define kMerchantNameElement                    @"mname"    //Merchant Name
#define kLatitudeElement                        @"lat"      //Latitude
#define kLongitudeElement                       @"lon"      //Longitude
//#define kStoremaddress                          @"maddress"
//#define kStorefilter                            @"filter"
#define kStorecity                              @"city"     //Store Location
//#define kStoreType                              @"type"
#define kStoreFlag                              @"pinflg"   // Store Flag
#define kStoreStatus                            @"ocflag"   // Store Status
#define kStoreStreet                            @"street"   // Store Street
#define kOC                                     @"oc"//added by ranjan...........jira 842.........28 may 2014
#define kStoreState                                  @"state"   // Store State
#define kStoreZip                                    @"zip"     // Store Zip
#define kStoreCountry                                @"country" // Store Country
//added by ranjan.........BTB-14.........19 Feb 2015
#define kRestaurantDescription                  @"mdesc"        // Merchant Description
#define kRestaurantLogo                         @"mimg"         // Merchant Image

#import "MWGLocationParser.h"


@implementation MWGLocationParser
{
    MWGLocation *locationObject;
    NSMutableArray *locatiosArray;
}

#pragma mark Helper Methods
/**
 *  Method to parse data for restaurant details
 *
 *  @param locationData data of location
 *  @param block        Restaurant Parsing Completion Block
 */
- (void)parseData:(NSData *)locationData
   withCompletion:(RestaurantsParsingCompletionBlock)block
{
    if (block)
    {
        restaurantsBlock = block;
    }
    
    locatiosArray =[[NSMutableArray alloc] init];
    
    parser = [[MWGParserEngine alloc] initParserEngineWithData:locationData
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
    
    if ([tag isEqualToString:kStoreNameElement])
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
    if (restaurantsBlock)
    {
        restaurantsBlock(nil, error);
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
    
    if ([tag isEqualToString:kMerchantNameElement])
    {
        //NSLog(@"MerchantName-xmlnearby.jsp? is:%@",string);
        [locationObject setLocationId:string];
        
    }
    else if([tag isEqualToString:kLatitudeElement])
    {
        
        double value ;
        
        NSScanner *aScanner = [NSScanner scannerWithString:string];
        [aScanner scanDouble:&value];
        [locationObject setLatitude:value];        
    }
    else if([tag isEqualToString:kLongitudeElement])
    {
        
        double value ;
        
        NSScanner *aScanner = [NSScanner scannerWithString:string];
        [aScanner scanDouble:&value];

        [locationObject setLongitude:value];        
    }
    else if( [tag isEqualToString:kStoreNameElement])
    {
        //added by ranjan..............jira 419..............4 march 2014
//        IMGSharedObject *sharedObj = [IMGSharedObject getIMGSharedObject];
//        
//        CLLocation *location = [[CLLocation alloc]initWithLatitude:sharedObj.userLatitude longitude:sharedObj.userLongitude];
//        [locationObject getDistanceForCurrentLocation:location];
        
        [locatiosArray addObject:locationObject];
    }
    else if( [tag isEqualToString:kStorecity])
    {
        if(string && ![string isEqualToString:@""])
        {
            [locationObject setCity:string];
        }
        else
        {
            locationObject.city = @"";
        }
    }
    //commented by ranjan.........MYB-122.......29 sep 2014
//    else if( [tag isEqualToString:kStorefilter])
//    {
//        if(string && ![string isEqualToString:@""])
//        {
//            locationObject.filter = string;
//        }
//        else
//        {
//            locationObject.filter = @"";
//        }
//    }
//    else if( [tag isEqualToString:kStoremaddress])
//    {
//        if(string && ![string isEqualToString:@""])
//        {
//            locationObject.address = string;
//        }
//        else
//        {
//            locationObject.address = @"";
//        }
//    }
    else if( [tag isEqualToString:kStoreId])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.storeId = string;
        }
        else
        {
            locationObject.storeId = @"";
        }
    }
    
    //commented by ranjan.........MYB-122.......29 sep 2014
//    else if( [tag isEqualToString:kStoreType])
//    {
//        if(string && ![string isEqualToString:@""])
//        {
//            locationObject.type = string;
//        }
//        else
//        {
//            locationObject.type = @"";
//        }
//    }
    else if( [tag isEqualToString:kStoreStatus])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.status = string;
        }
        else
        {
            locationObject.status = @"";
        }
    }
    else if( [tag isEqualToString:kStoreFlag])
    {
        if(string && [string isEqualToString:@"Y"])
        {
            locationObject.mcdFlag = @"T";
        }
        else if(string && [string isEqualToString:@"N"])
        {
            locationObject.mcdFlag = @"F";
        }
        else
        {
            locationObject.mcdFlag = @"";
        }
    }
    else if( [tag isEqualToString:kStoreStreet])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.street = string;
        }
        else
        {
            locationObject.street = @"";
        }
    }
    
    //added by ranjan.........MYB-122.......29 sep 2014
    else if( [tag isEqualToString:kStoreState])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.state = string;
        }
        else
        {
            locationObject.state = @"";
        }
    }
    else if( [tag isEqualToString:kStoreCountry])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.country = string;
        }
        else
        {
            locationObject.country = @"";
        }
    }
    else if( [tag isEqualToString:kStoreZip])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.zip = string;
        }
        else
        {
            locationObject.zip = @"";
        }
    }
    //added by ranjan............jira 842...........28 May 2014
    else if( [tag isEqualToString:kOC])
    {
        if(string && [string isEqualToString:@"T"])
        {
//            [[IMGSharedObject getIMGSharedObject] setIsOCEnabled:YES];    To fix
        }
        else
        {
//            [[IMGSharedObject getIMGSharedObject] setIsOCEnabled:NO];     To fix
        }
        
    }
    //added by ranjan.........BTB-14.........19 Feb 2015
    else if ([tag isEqualToString:kRestaurantDescription])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.mdesc = string;
        }
        else
        {
            locationObject.mdesc = @"";
        }
    }
    else if ([tag isEqualToString:kRestaurantLogo])
    {
        if(string && ![string isEqualToString:@""])
        {
            locationObject.mimg = string;
        }
        else
        {
            locationObject.mimg = @"";
        }
    }
}


/**
 *  Delegate method sent by the parser object to the delegate when it has successfully completed parsing.
 *
 */
-(void)parserEngineFinishParsing
{
    restaurantsBlock(locatiosArray, nil);
}

@end
