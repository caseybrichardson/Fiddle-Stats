//
//  FSPlayerTableViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STKWebKitViewController/STKWebKitViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <DFImageManager/DFImageView.h>
#import <DFImageManager/DFImageRequest.h>
#import <iAd/iAd.h>

#import "FSDataPair.h"
#import "FSDataDelegate.h"
#import "FSSummonerDataSource.h"
#import "FSMatchTableViewCell.h"
#import "FSMatchDataSource.h"
#import "FSMatchCollectionViewController.h"

#import "Match+APIMethods.h"
#import "Champion+APIMethods.h"
#import "UINavigationController+Helpers.h"
#import "UIView+Effects.h"
#import "SummonerGroup+Helpers.h"

@interface FSPlayerTableViewController : UITableViewController <FSMatchDataSource, ADBannerViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet DFImageView *champView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupLabel;
@property (strong, nonatomic) IBOutlet DFImageView *summonerIcon;
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property (strong, nonatomic) IBOutlet ADBannerView *adView;

@property (strong, nonatomic) id<FSSummonerDataSource> summonerDataSource;

- (Match *)match;

- (IBAction)optionsPressed:(id)sender;
- (IBAction)modeChanged:(id)sender;

@end
