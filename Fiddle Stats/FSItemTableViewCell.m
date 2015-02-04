//
//  FSItemTableViewCell.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/29/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSItemTableViewCell.h"

@implementation FSItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.itemImage.image = [UIImage imageNamed:@"Missing"];
    self.itemNameLabel.text = @"";
    self.itemNumberLabel.text = @"Item ";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
