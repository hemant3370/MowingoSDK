//
//  PromotionsViewController.h
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

@interface PromotionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *tblPromotion;//promotion list table
    __weak IBOutlet UIButton *btnBack; //back button
    
    __weak IBOutlet UIActivityIndicatorView *activity;
    NSArray *arrPromotions;  //list of promotions
}

@end
