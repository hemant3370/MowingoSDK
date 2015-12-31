//
//  StoreTableViewCell.h
//  SDK_Sample_App
//
//  Created by Bellurbis on 6/23/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MowingoSDK/MowingoSDK.h>

@interface StoreTableViewCell : UITableViewCell
{
    __weak IBOutlet UILabel *lblStoreName;// store name
    
    /// addresss
    __weak IBOutlet UILabel *lblStreet1;// street 1
    __weak IBOutlet UILabel *lblStreet2; // street 2
    __weak IBOutlet UILabel *lblCity; // city
    __weak IBOutlet UILabel *lblStateCountryZip; // state, country and zip
    
    __weak IBOutlet UILabel *lblPhone;// phone
    
    __weak IBOutlet UILabel *lblStoreDistance; // store distance
    
    __weak IBOutlet UILabel *lblHours; // opening hours
    
    __weak IBOutlet UIView *vwFlags;// flags container
    __weak IBOutlet UIImageView *imgStore; // store image
}

/**
 *  renders cell using data from store
 *
 *  @param store store object
 */
-(void)renderCellForStore:(MWGStore *)store;

@end
