//
//  FSCollectionViewCell.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSCollectionViewCell.h"

@interface FSCollectionViewCell()

@property (strong, nonatomic) UIColor *defaultColor;
@property (strong, nonatomic) UIColor *highlightColor;

@end

@implementation FSCollectionViewCell

- (void)awakeFromNib {
    self.contentView.layer.cornerRadius = 5.0f;
    self.contentView.clipsToBounds = YES;
    [self.contentView bringSubviewToFront:self.nameLabel];
    self.defaultColor = self.labelBackground.backgroundColor;
    self.highlightColor = [UIColor fiddlesticksSecondaryColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
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

- (void)setHighlighted:(BOOL)highlighted {
    if(highlighted) {
        [UIView animateWithDuration:0.15f animations:^{
            self.labelBackground.backgroundColor = self.highlightColor;
            self.nameLabel.textColor = [UIColor fiddlesticksMainColor];
        }];
    } else {
        [UIView animateWithDuration:0.15f animations:^{
            self.labelBackground.backgroundColor = self.defaultColor;
            self.nameLabel.textColor = [UIColor fiddlesticksSecondaryColor];
        }];
    }
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.nameLabel.text];
}

@end
