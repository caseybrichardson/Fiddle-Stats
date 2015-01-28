//
//  FSMatchCollectionViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#import "FSGameOverviewCell.h"
#import "FSGamePlayerCell.h"
#import "FSMatchDataSource.h"
#import "CRDataManager.h"

#import "Champion+APIMethods.h"
#import "Item+APIMethods.h"

@interface FSMatchCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, FSGameOverviewCellDelegate>

@property (weak, nonatomic) id<FSMatchDataSource> dataSource;

@end
