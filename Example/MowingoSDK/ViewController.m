//
//  ViewController.m
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "ViewController.h"
#import "PromotionsViewController.h"
#import <MowingoSDK/MowingoSDK.h>

#define kBeaconUUID     @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
#define kBeaconMajor    @1
#define kBeaconMinor    @1

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    btnGetPromotions.enabled = NO;
    btnGetPromotions.layer.cornerRadius = 10.0;// make button slightly rounded at corners
    
    btnAccount.enabled = NO;
    btnAccount.layer.cornerRadius = 10.0;// make button slightly rounded at corners
    
    btnStores.enabled = NO;
    btnStores.layer.cornerRadius = 10.0;// make button slightly rounded at corners
    
    // get sdk parameter
    MWGParam *param = [MWGSDKManager MWGGetParams];
    
    //set bottom text to bottom label
    lblBottomText.text = [NSString stringWithFormat:@"SDK version %@\n© Mowingo, Inc.", param.SDKVersion];
    
    //initialize SDK
    [MWGSDKManager MWGInitWithUniqueUserName:[self getDeviceUUId]
                                  beaconFlag:YES
                               geofencesFlag:YES
                             completionBlock:^(NSError *result) {
                                 
                                 if (result)
                                 {
                                     switch (result.code)
                                     {
                                         case MWG_SUCCESS:
                                         {
                                             // successful
                                             btnGetPromotions.enabled = YES;
                                             btnAccount.enabled = YES;
                                             btnStores.enabled = YES;
                                         }
                                             break;
                                         case MWG_BEACONS_NOT_SUPPORTED:
                                         {
                                             NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                         }
                                             break;
                                         case MWG_SDK_CALL_ERROR:
                                         {
                                             NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                         }
                                             break;
                                         default:
                                         {
                                             NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                         }
                                             break;
                                     }
                                 }
                                 else
                                 {
                                     NSLog(@"Some error occurred");
                                 }
                                 
                                 //stop progress
                                 if (activity && [activity isAnimating])
                                 {
                                     [activity stopAnimating];
                                 }
                             }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set header title
    self.navigationItem.title = @"Mowingo SDK Sample App";
}


/**
 *  Method to get Device UUID
 *
 *  @return returns device UUID
 */
- (NSString *)getDeviceUUId
{
    NSString *idForVendor = [[NSUserDefaults standardUserDefaults] objectForKey:@"unique identifier stored for app"];
    
    
    if (!idForVendor || [idForVendor isEqualToString:@""] || [idForVendor isEqualToString:@"(null)"])
    {
        //if idForVendor string is not allocated or idForVendor is allocated but contains String '(null)'.
        //This happens in case of userDefaults that sometimes if value is not present for the specified key, it returns a string value (null) and gets allocated
        
        idForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];//retrieve the uuid value of device.
        
        //set the retrieved uuid value to user default for specified key(unique identifier stored for app)
        [[NSUserDefaults standardUserDefaults] setObject:idForVendor forKey:@"unique identifier stored for app"];
        
        //now force the user default to accept the change immediately.
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Vendor Id is::2nd:%@",idForVendor);
        return  idForVendor;
    }
    
    //if we already have a valid uuid
    
    NSLog(@"Vendor Id is::1st:%@",idForVendor);
    return idForVendor;
}

@end
