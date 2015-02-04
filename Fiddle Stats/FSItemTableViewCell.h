//
//  FSItemTableViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/29/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSItemTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemNumberLabel;

@end
