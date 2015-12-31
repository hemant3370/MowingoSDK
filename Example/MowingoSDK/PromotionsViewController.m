//
//  PromotionsViewController.m
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "PromotionsViewController.h"
#import "PromotionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "PromotionDetailViewController.h"

@interface PromotionsViewController ()

@end

@implementation PromotionsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // call promotion list api and then open promotion list screen
    [MWGSDKManager MWGGetPromotionListForMerchant:nil
                              withCompletionBlock:^(NSArray *promotions, NSError *result) {
                                  
                                  if (result)
                                  {
                                      switch (result.code)
                                      {
                                          case MWG_SUCCESS:
                                          {
                                              // successful
                                              arrPromotions = promotions;
                                              
                                              if (arrPromotions && [arrPromotions count] > 0)
                                              {
                                                  [tblPromotion reloadData];//load table with array data
                                                  tblPromotion.hidden = NO;// display list
                                              }
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
    self.navigationItem.title = @"Promotion List";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark TableView delegates

//Asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//Tells the data source to return the number of rows in a given section of a table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblPromotion)
    {
        if (arrPromotions && [arrPromotions count] >0)
        {
            return arrPromotions.count;
        }
        
        return 1;
    }
    
    return 0;
}

//Asks the delegate for the height to use for the footer of a particular section.
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

//Asks the delegate for the height to use for a row in a specified location.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblPromotion)
    {
        return 212.0;
    }
    return 0.0;
}

//Asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblPromotion)
    {
        static NSString *cellIdentifier = @"offer_cell";
        
        //create cell from OfferCollectionTableViewCell
        PromotionTableViewCell *cell = (PromotionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        return cell;
    }
    return nil;
}

//Tells the delegate the table view is about to draw a cell for a particular row.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   if (tableView == tblPromotion)
    {
        if(arrPromotions && [arrPromotions count] > 0)
        {
            MWGPromotion *obj = (MWGPromotion *)arrPromotions[indexPath.row];
            
            //cast cell into OfferCollectionTableViewCell type cell
            PromotionTableViewCell *customcell = (PromotionTableViewCell *)cell;

            //render offer image
            [customcell.imgOfferView sd_setImageWithURL:obj.promotionImageUrl placeholderImage:nil];
            
            //add title
            NSString *strTitle = obj.promotionTitle;
            [customcell.lblOffer setText:strTitle];

            //add details
            NSString *strDetails = obj.promotionDescription;
            [customcell.lblOfferDetails setText:strDetails];

            //retreive start and end date
            NSString *strStartDate = [self getStringForDate:obj.promotionStartDateTime];
            NSString *strExpDate = [self getStringForDate:obj.promotionEndDateTime];

            //add expiry date if available
            if (strStartDate && strExpDate)
            {
                NSString *strValidity = [NSString stringWithFormat:@"Valid between %@ - %@", strStartDate, strExpDate];
                [customcell.lblExpiration setText:strValidity];
            }
            else if (strStartDate && !strExpDate)
            {
                [customcell.lblExpiration setText:[NSString stringWithFormat:@"Valid from %@", strStartDate]];
            }
            else
            {
                [customcell.lblExpiration setText:@""];
            }
        }
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"listToDetail" sender:nil];
}


//calls when back button clicks
-(IBAction)btnBack_OnClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"listToDetail"])
    {
        PromotionDetailViewController *promotionDetail = (PromotionDetailViewController *)[segue destinationViewController];
        
        MWGPromotion *promotion = arrPromotions[[[tblPromotion indexPathForSelectedRow] row]];
        promotionDetail.promotionId = promotion.promotionId;
        
        [tblPromotion deselectRowAtIndexPath:[tblPromotion indexPathForSelectedRow] animated:YES];
    }
}


@end
