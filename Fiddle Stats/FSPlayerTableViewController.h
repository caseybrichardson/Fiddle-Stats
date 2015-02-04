//
//  FSPlayerTableViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <STKWebKitViewController/STKWebKitViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>

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

@interface FSPlayerTableViewController : UITableViewController <FSMatchDataSource>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *champView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupLabel;
@property (strong, nonatomic) IBOutlet UIImageView *summonerIcon;
@property (strong, nonatomic) IBOutlet UIView *gradientView;

@property (strong, nonatomic) id<FSSummonerDataSource> summonerDataSource;

- (Match *)match;

- (IBAction)optionsPressed:(id)sender;

@end
