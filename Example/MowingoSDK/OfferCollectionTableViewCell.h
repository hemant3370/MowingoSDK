//
//  OfferCollectionTableViewCell.h
//  SDK_Sample_App
//
//  Created by Bellurbis on 4/24/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfferCollectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgOfferView;  //offer image view
@property (weak, nonatomic) IBOutlet UILabel *lblExpiration; //label for expiration date
@property (weak, nonatomic) IBOutlet UILabel *lblOffer;  //label for offer name
@property (weak, nonatomic) IBOutlet UILabel *lblOfferDetails;  //label for offer description
@property (weak, nonatomic) IBOutlet UIButton *btnFinePrint;  //button for fineprint

@end
