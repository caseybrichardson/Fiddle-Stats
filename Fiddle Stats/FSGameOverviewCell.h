//
//  FSGameOverviewCell.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Summoner+APIMethods.h"
#import "Match+APIMethods.h"

@class FSGameOverviewCell;
@protocol FSGameOverviewCellDelegate

- (void)summonerPressed:(NSInteger)summonerAtPosition overviewCell:(FSGameOverviewCell *)cell;

@end

@protocol FSGameOverviewCellDataSource

- (Match *)matchForOverview;
- (Summoner *)summonerAtPosition:(NSInteger)position;

@end

@interface FSGameOverviewCell : UICollectionViewCell

@property (weak, nonatomic) id<FSGameOverviewCellDelegate> delegate;
@property (weak, nonatomic) id<FSGameOverviewCellDataSource> dataSource;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *summonerButtons;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *summonerImages;

- (IBAction)summonerPressed:(id)sender;

@end
