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

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.champImageView.image = [UIImage imageNamed:@"Missing"];
    self.champNameLabelView.text = @"";
    self.matchGameType.text = @"";
    self.matchDate.text = @"";
    self.kdaLabel.text = @"";
    self.minionsLabel.text = @"";
    self.matchTime.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if(highlighted) {
        [UIView animateWithDuration:0.1f animations:^{
            self.contentView.backgroundColor = [UIColor lightGrayColor];
        }];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            self.contentView.backgroundColor = [UIColor neutralColor];
        }];
    }
}

@end
