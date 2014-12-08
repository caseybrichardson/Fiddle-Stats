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
    self.contentView.backgroundColor = [UIColor neutralColor];
    self.accessoryView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

@end
