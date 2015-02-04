//
//  FSCollectionViewCell.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSCollectionViewCell.h"

@implementation FSCollectionViewCell

- (void)awakeFromNib {
    self.contentView.layer.cornerRadius = 5.0f;
    self.contentView.clipsToBounds = YES;
    [self.contentView bringSubviewToFront:self.nameLabel];
}

- (void)prepareForReuse {
    self.nameLabel.text = @"";
    self.backgroundImage.image = [UIImage imageNamed:@"Missing"];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)setEditing:(BOOL)editing {
    self.checkMark.checked = editing;
    
    if(editing) {
        [self.selectView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25f]];
    } else {
        [self.selectView setBackgroundColor:[UIColor clearColor]];
    }
    
    [self setNeedsDisplay];
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.nameLabel.text];
}

@end
