//
//  FSPlayerTableViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+AFNetworking.h>

#import "FSSummonerDataSource.h"
#import "FSMatchTableViewCell.h"

#import "Match+APIMethods.h"
#import "Champion+APIMethods.h"
#import "UINavigationController+Helpers.h"
#import "UIView+Gradient.h"

@interface FSPlayerTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *champView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *summonerIcon;
@property (strong, nonatomic) IBOutlet UIView *gradientView;

@property (strong, nonatomic) id<FSSummonerDataSource> summonerDataSource;

- (IBAction)optionsPressed:(id)sender;

@end
