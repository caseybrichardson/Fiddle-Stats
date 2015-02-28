//
//  FSGamePlayerCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageView.h>

@interface FSGamePlayerCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet DFImageView *champImage;
@property (strong, nonatomic) IBOutlet UILabel *playerName;
@property (strong, nonatomic) IBOutletCollection(DFImageView) NSArray *itemImages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *itemNames;

@end
