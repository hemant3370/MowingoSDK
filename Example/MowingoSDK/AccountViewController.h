//
//  AccountViewController.h
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

@interface AccountViewController : UITableViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    MWGUserData *user;// holds current userdata
    
    IBOutlet UIActivityIndicatorView *activity; // loader
    
    IBOutlet UIDatePicker *datepicker; // date picker for DOB

    IBOutlet UIToolbar *toolbarPhone; // toolbar for phone keyboard
    
    UIActionSheet *genderActionSheet; // action sheet/selector for gender
    UIActionSheet *languageActionSheet; // action sheet/selector for language
}

@end
