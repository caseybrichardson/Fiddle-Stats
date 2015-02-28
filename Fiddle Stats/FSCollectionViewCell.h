//
//  FSCollectionViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageView.h>

#import "UIView+Effects.h"
#import "UIColor+AppColors.h"

#import "CRCheckMark.h"

@interface FSCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet DFImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet CRCheckMark *checkMark;
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIView *labelBackground;

- (void)setEditing:(BOOL)editing;

@end
