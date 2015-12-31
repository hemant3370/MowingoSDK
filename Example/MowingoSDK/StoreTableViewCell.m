//
//  StoreTableViewCell.m
//  SDK_Sample_App
//
//  Created by Bellurbis on 6/23/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "StoreTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"

@implementation StoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  renders cell using data from store
 *
 *  @param store store object
 */
-(void)renderCellForStore:(MWGStore *)store
{
    lblStoreName.text = store.storeName;
    
    lblStreet1.text = [self isValidString:store.street1] ? store.street1 : @"";
    lblStreet2.text = [self isValidString:store.street2] ? store.street2 : @"";
    lblCity.text = [self isValidString:store.city] ? store.city : @"";
    lblStateCountryZip.text = [self getAddressOfStore:store];
    
    lblPhone.text = [self isValidString:store.phoneNumber] ? store.phoneNumber : @"";
    
    lblStoreDistance.text = [self distanceFromLatitude:store.storeLatitude
                                          andLongitude:store.storeLongitude];
    
    lblHours.text = [self formatHours:store.storeHours];
    
    [imgStore sd_setImageWithURL:store.storeImage];
//    imgStore.layer.cornerRadius = imgStore.frame.size.height/2;
    
    [self renderFlagWithPreferences:store.storePreference];
}

/**
 *  calculates distance of store from current location
 *
 *  @param lat latitude of store
 *  @param lon longitude of store
 *
 *  @return calculated distance of store
 */
-(NSString *)distanceFromLatitude:(double)lat andLongitude:(double)lon
{
    // get given location
    CLLocation *location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    
    // retrieve current location
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    double tempLocation = [location distanceFromLocation:[manager location]];
    
    // get distance in miles
    return [NSString stringWithFormat:@"%0.2f miles", tempLocation/1609.344];
}

/**
 *  Checks if string has valid value
 *
 *  @param str string
 *
 *  @return YES if string has valid value otherwise NO
 */
-(BOOL)isValidString:(NSString *)str
{
    if (str && ![str isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark - Flag rendering


/**
 *  method that renders flags according to stores preferences
 *
 *  @param prefs preferences array
 */
- (void) renderFlagWithPreferences:(NSArray *)prefs
{
    for (int i = 0; i < 10; i++)
    {
        // get imageview for current itereation of flag
        UIImageView *img = (UIImageView *)[vwFlags viewWithTag:500 + i];
        
        
        if ([prefs[31-i] boolValue])
        {
            // if preference is true set on image
            [img setImage:[UIImage imageNamed:@"flagOn"]];
        }
        else
        {
            // if preference is false set off image
            [img setImage:[UIImage imageNamed:@"flagOff"]];
        }
    }
}

#pragma mark - Address Handling

/**
 *  returns state country and zip value
 *
 *  @param store store object
 *
 *  @return string having country state and zip
 */
- (NSString *) getAddressOfStore:(MWGStore *)store
{
    NSString *strAddress = [NSString stringWithFormat:@"%@%@%@",
                            [self isValidString:store.state] ? [NSString stringWithFormat:@"%@, ", store.state] : @"",
                            [self isValidString:store.country] ? [NSString stringWithFormat:@"%@, ", store.country] : @"",
                            [self isValidString:store.zip] ? [NSString stringWithFormat:@"%@", store.zip] : @""];
    
    if ([strAddress hasSuffix:@", "])
    {
        strAddress = [strAddress substringToIndex:strAddress.length - 2];
    }
    
    return strAddress;
}


#pragma mark - hours handling

- (NSString *) formatHours:(NSArray *)hours
{
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc]init];
    [currentFormatter setDateFormat:@"HH:mm"];
    
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc]init];
    [newFormatter setDateFormat:@"h:mm a"];
    
    
    NSMutableArray *group = [self getDayGroupArrayForHours:hours];
    
    NSString *strHours = @"";
    
    for (NSArray *arr in group)
    {
        NSString *strDays;
        
        MWGDayHours *day1 = (MWGDayHours *)[arr objectAtIndex:0];
        NSDate *date = [currentFormatter dateFromString:day1.closeTime];
        NSDate *date1 = [currentFormatter dateFromString:day1.openTime];
        
        if ([arr count] == 2)
        {
            MWGDayHours *day2 = (MWGDayHours *)[arr objectAtIndex:1];
            
            strDays = [NSString stringWithFormat:@"%@. - %@.", [day1.dayName capitalizedString], [day2.dayName capitalizedString]];
        }
        else if ([arr count] == 1)
        {
            MWGDayHours *day1 = (MWGDayHours *)[arr objectAtIndex:0];
            
            strDays = [NSString stringWithFormat:@"%@.", [day1.dayName capitalizedString]];
        }
        
        if (![day1.openTime isEqualToString:@""] &&
            ![day1.closeTime isEqualToString:@""])
        {
            if ([day1.openTime isEqualToString:@"00:00"] &&
                [day1.closeTime isEqualToString:@"23:59"])
            {
                strHours = [NSString stringWithFormat:@"%@%@ 12 am. - 12 am.\n",strHours, strDays] ;
            }
            else
            {
                strHours = [NSString stringWithFormat:@"%@%@ %@. - %@.\n",strHours, strDays, [[[newFormatter stringFromDate:date1] lowercaseString] stringByReplacingOccurrencesOfString:@":00" withString:@""], [[[newFormatter stringFromDate:date] lowercaseString] stringByReplacingOccurrencesOfString:@":00" withString:@""]] ;
            }
        }
        else
        {
            strHours = [NSString stringWithFormat:@"%@%@ Closed\n", strHours, strDays];
        }
    }
    
    return [strHours stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}


-(NSMutableArray *)getDayGroupArrayForHours:(NSArray *)hours
{
    NSArray *arrHours = [NSArray arrayWithArray:hours];
    
    NSMutableArray *arrGroups = [[NSMutableArray alloc] init]; //will contain different group of days.
    
    NSMutableArray *arrDays = [[NSMutableArray alloc] init]; //will contain different days having same opening and closing hours. This array will contain only two day object, a starting day to end day, when opening hours are same.
    
    //for today............................
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee"];
    
    NSString *strWeekDay = [[dateFormatter stringFromDate:[NSDate date]] lowercaseString];//current day value
    
    int currentDayGroupIndex = -1;
    
    for (MWGDayHours *dayObj in arrHours)
    {
        //for finding current day group.
        if([[dayObj.dayName lowercaseString] isEqualToString:strWeekDay])
        {
            currentDayGroupIndex = [arrGroups count];
        }
        
        if (arrDays && [arrDays count] > 0)
        {
            //condition - when array for days already contains 1 or more days objects
            
            MWGDayHours *dayTemp = (MWGDayHours *)[arrDays objectAtIndex:0];//retrieve day object in the array for day which will be used to find if the current day object has same opening hours as is contain by day in the current array for day.
            
            if([dayObj.openTime isEqualToString:dayTemp.openTime] &&
               [dayObj.closeTime isEqualToString:dayTemp.closeTime])
            {
                //Condition - if current array for day's opening hours matches with the opening hours of day in day array
                
                if ([arrDays count] >= 2)
                {
                    //condition - if array already contains two day than remove the last day object because the current day object is the new end day in the array of day.
                    
                    [arrDays removeLastObject];
                }
                
                [arrDays addObject:dayObj];//add the new end day.
            }
            else
            {
                //Condition - if current array for day's opening hours do not match with the opening hours of day in day array
                
                //call the current day array as complete group and play it in group array.
                [arrGroups addObject:arrDays];
                
                //create a new instance of day array and insert current day object.
                arrDays = [[NSMutableArray alloc]initWithObjects:dayObj, nil];
            }
        }
        else
        {
            //when the array for day is new and do not contain anyday object. This will happen only for firth object of arrHours.
            [arrDays addObject:dayObj];
        }
    }
    
    [arrGroups addObject:arrDays];
    
    NSMutableArray *arrResults;
    
    if ([arrGroups count] > 3)
    {
        arrResults = [[NSMutableArray alloc] initWithObjects:[arrGroups objectAtIndex:currentDayGroupIndex], nil];
        
        int nextIndex = currentDayGroupIndex + 1;
        
        if ([arrGroups count] < nextIndex + 1)
        {
            nextIndex = 0;
        }
        
        [arrResults addObject:[arrGroups objectAtIndex:nextIndex]];
        
        nextIndex++;
        
        if ([arrGroups count] < nextIndex + 1)
        {
            nextIndex = 0;
        }
        
        [arrResults addObject:[arrGroups objectAtIndex:nextIndex]];
    }
    else
    {
        arrResults = [[NSMutableArray alloc] initWithArray:arrGroups];
    }
    
    return arrResults;
}


@end
