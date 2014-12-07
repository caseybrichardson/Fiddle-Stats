//
//  FSMatchTableViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/7/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+Gradient.h"

@interface FSMatchTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *champImageView;
@property (strong, nonatomic) IBOutlet UILabel *champNameLabelView;
@property (strong, nonatomic) IBOutlet UILabel *matchMapName;

@end
