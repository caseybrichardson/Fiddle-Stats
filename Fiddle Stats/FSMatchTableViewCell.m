//
//  FSMatchTableViewCell.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/7/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSMatchTableViewCell.h"

@implementation FSMatchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView addGradientWithColors:@[[UIColor grayColor], [UIColor whiteColor]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
