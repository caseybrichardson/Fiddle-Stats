//
//  FSCollectionViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+Effects.h"

@interface FSCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

- (void)startQuivering;
- (void)stopQuivering;

@end
