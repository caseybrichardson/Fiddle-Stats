//
//  FSSummonerGroupTableViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/25/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView-Letters/UIImageView+Letters.h>

#import "FSSummonerDataSource.h"
#import "FSDataPair.h"
#import "FSDataDelegate.h"
#import "SummonerGroup+Helpers.h"

typedef void(^FSModalCompleted)(BOOL completedWithChanges);

@interface FSSummonerGroupViewController : UIViewController <UIBarPositioningDelegate>

@property (strong, nonatomic) IBOutlet UITableView *summonerGroupTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (copy, nonatomic, readonly) FSModalCompleted completion;
@property (strong, nonatomic) id<FSSummonerDataSource> summonerDataSource;

- (IBAction)cancelPressed:(id)sender;

- (void)setCompletion:(FSModalCompleted)completion;

@end
