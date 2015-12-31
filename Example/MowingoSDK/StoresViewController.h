//
//  StoresViewController.h
//  SDK_Sample_App
//
//  Created by Bellurbis on 6/23/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MowingoSDK/MowingoSDK.h>

@interface StoresViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    // store table view
    __weak IBOutlet UITableView *tblStores;
    
    NSArray *stores;

    
    __weak IBOutlet UIActivityIndicatorView *activity;
    
}

@end
