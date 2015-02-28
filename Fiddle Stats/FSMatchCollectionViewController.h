//
//  FSMatchCollectionViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequest.h>

#import "FSGameOverviewCell.h"
#import "FSGamePlayerCell.h"
#import "FSMatchPlayerCollectionViewCell.h"
#import "FSItemTableViewCell.h"
#import "FSMatchDataSource.h"
#import "CRDataManager.h"
#import "CRFiddleAPIClient.h"

#import "Champion+APIMethods.h"
#import "Item+APIMethods.h"
#import "UIColor+AppColors.h"

@interface FSMatchCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, UITableViewDataSource, FSGameOverviewCellDelegate>

@property (weak, nonatomic) id<FSMatchDataSource> dataSource;

@end
