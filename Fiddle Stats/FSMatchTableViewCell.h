//
//  FSMatchTableViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/7/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageView.h>

#import "UIView+Effects.h"
#import "UIColor+AppColors.h"

@interface FSMatchTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *matchOutcomeView;
@property (strong, nonatomic) IBOutlet DFImageView *champImageView;
@property (strong, nonatomic) IBOutlet UILabel *champNameLabelView;
@property (strong, nonatomic) IBOutlet UILabel *matchGameType;
@property (strong, nonatomic) IBOutlet UILabel *matchDate;
@property (strong, nonatomic) IBOutlet UILabel *kdaLabel;
@property (strong, nonatomic) IBOutlet UILabel *minionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchTime;

@end
