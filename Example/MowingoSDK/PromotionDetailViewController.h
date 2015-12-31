//
//  PromotionDetailViewController.h
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <UIKit/UIKit.h>
#import <MowingoSDK/MowingoSDK.h>

@interface PromotionDetailViewController : UIViewController
{
    __weak IBOutlet UIButton *btnRedeem;
    __weak IBOutlet UIImageView *imgOfferView;
    
    __weak IBOutlet UILabel *lblOffer;
    __weak IBOutlet UILabel *lblOfferDetails;
    __weak IBOutlet UILabel *lblExpiration;
    
    __weak IBOutlet UIActivityIndicatorView *activity;
    MWGPromotion *promotionObj;
}

@property(nonatomic) NSString *promotionId;

@end
