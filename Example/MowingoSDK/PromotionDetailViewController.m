//
//  PromotionDetailViewController.m
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "PromotionDetailViewController.h"
#import "UIImageView+WebCache.h"
#import <MowingoSDK/MowingoSDK.h>
@interface PromotionDetailViewController ()

@end

@implementation PromotionDetailViewController

@synthesize promotionId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MWGSDKManager MWGGetPromotion:promotionId
               withCompletionBlock:^(MWGPromotion *promotion, NSError *result) {
                   
                   if (result)
                   {
                       switch (result.code)
                       {
                           case MWG_SUCCESS:
                           {
                               // successful
                               //set promotions
                               promotionObj = promotion;
                               
                               //render data into screen
                               [self render];
                           }
                               break;
                           case MWG_SDK_CALL_ERROR:
                           {
                               NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                           }
                               break;
                           case MWG_NETWORK_ERROR:
                           {
                               NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                           }
                               break;
                           case MWG_AUTH_ERROR:
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
    self.navigationItem.title = @"Promotion Details";
}


-(void)render
{
    //render offer image
    [imgOfferView sd_setImageWithURL:promotionObj.promotionImageUrl];
    
    //add title
    NSString *strTitle = promotionObj.promotionTitle;
    [lblOffer setText:strTitle];
    
    //add details
    NSString *strDetails = promotionObj.promotionDescription;
    [lblOfferDetails setText:strDetails];
    
    //retreive start and end date
    NSString *strStartDate = [self getStringForDate:promotionObj.promotionStartDateTime];
    NSString *strExpDate = [self getStringForDate:promotionObj.promotionEndDateTime];
    
    //add expiry date if available
    if (strStartDate && strExpDate)
    {
        NSString *strValidity = [NSString stringWithFormat:@"Valid between %@ - %@", strStartDate, strExpDate];
        [lblExpiration setText:strValidity];
    }
    else if (strStartDate && !strExpDate)
    {
        [lblExpiration setText:[NSString stringWithFormat:@"Valid from %@", strStartDate]];
    }
    else
    {
        [lblExpiration setText:@""];
    }
    
    if (promotionObj.promotionActivity == MWG_REDEEM)
    {
        [btnRedeem setHidden: NO];
        btnRedeem.layer.cornerRadius = 10.0;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//converts UTC time to string with current time zone
- (NSString *)getStringForDate:(NSDate *)date
{
    if (date)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        
        return  [formatter stringFromDate:date];
    }
    else
    {
        return nil;
    }
}

//calls when back button clicks
-(IBAction)btnBack_OnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//action method for redeem button
- (IBAction)btnRedeem_onClick:(id)sender
{
    //start progress
    if (![activity isAnimating])
    {
        [activity startAnimating];
    }
    
    //disable redeem button
    [btnRedeem setUserInteractionEnabled:NO];
    
    //call redemption service
    [MWGSDKManager MWGRedeemPromotion:promotionId
                           forPinCode:nil
                  withCompletionBlock:^(NSError *result) {
                      
                      
                      if (result)
                      {
                          switch (result.code)
                          {
                              case MWG_SUCCESS:
                              {
                                  // successful
                                  //is redeemed
                                  [btnRedeem setBackgroundColor:[UIColor grayColor]];
                                  [btnRedeem setTitle:@"Redeemed"
                                             forState:UIControlStateNormal];
                              }
                                  break;
                              case MWG_SDK_CALL_ERROR:
                              {
                                  NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                  
                                  //enable redeem button
                                  [btnRedeem setUserInteractionEnabled:YES];
                              }
                                  break;
                              case MWG_NETWORK_ERROR:
                              {
                                  NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                  
                                  //enable redeem button
                                  [btnRedeem setUserInteractionEnabled:YES];
                              }
                                  break;
                              case MWG_AUTH_ERROR:
                              {
                                  NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                  
                                  //enable redeem button
                                  [btnRedeem setUserInteractionEnabled:YES];
                              }
                                  break;
                              default:
                              {
                                  NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                  
                                  //enable redeem button
                                  [btnRedeem setUserInteractionEnabled:YES];
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

@end
