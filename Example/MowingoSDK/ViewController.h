//
//  ViewController.h
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

@interface ViewController : UIViewController
{
    // promotion button
    __weak IBOutlet UIButton *btnGetPromotions;

    //shows progress
    __weak IBOutlet UIActivityIndicatorView *activity;
    
    //bottom copyright text
    __weak IBOutlet UILabel *lblBottomText;
    
    //account button
    __weak IBOutlet UIButton *btnAccount;
    __weak IBOutlet UIButton *btnStores;
    __weak IBOutlet UIButton *btnMenu;
}

@end

