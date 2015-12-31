//
//  PromotionTableViewCell.h
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import <UIKit/UIKit.h>

@interface PromotionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgOfferView;  //offer image view
@property (weak, nonatomic) IBOutlet UILabel *lblExpiration; //label for expiration date
@property (weak, nonatomic) IBOutlet UILabel *lblOffer;  //label for offer name
@property (weak, nonatomic) IBOutlet UILabel *lblOfferDetails;  //label for offer description
@property (weak, nonatomic) IBOutlet UIButton *btnFinePrint;  //button for fineprint

@end
