//
//  FSMatchPlayerCollectionViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/28/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageView.h>

@interface FSMatchPlayerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet DFImageView *championImage;
@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerHighestRank;
@property (strong, nonatomic) IBOutlet UITableView *statisticsTableView;
@property (strong, nonatomic) IBOutlet DFImageView *backgroundImage;

@end
