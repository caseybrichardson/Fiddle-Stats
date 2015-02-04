//
//  FSMatchPlayerCollectionViewCell.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/28/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSMatchPlayerCollectionViewCell.h"

@implementation FSMatchPlayerCollectionViewCell

- (void)awakeFromNib {
    self.statisticsTableView.separatorColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    
    UINib *itemCell = [UINib nibWithNibName:@"FSItemTableViewCell" bundle:[NSBundle mainBundle]];
    [self.statisticsTableView registerNib:itemCell forCellReuseIdentifier:@"ItemCell"];
    self.statisticsTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.playerNameLabel.text = @"";
    self.championImage.image = [UIImage imageNamed:@"Missing"];
}

- (void)setSelected:(BOOL)selected {
    
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

@end
