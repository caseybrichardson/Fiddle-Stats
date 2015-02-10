//
//  FSMatchPlayerCollectionViewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/28/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSMatchPlayerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *championImage;
@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *statisticsTableView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@end
