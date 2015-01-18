//
//  ViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+AFNetworking.h>

#import "FSSummonerDataSource.h"
#import "FSCollectionViewCell.h"
#import "FSDataDelegate.h"
#import "FSDataPair.h"
#import "FSSummonerGroupViewController.h"

#import "Summoner+APIMethods.h"
#import "Match+APIMethods.h"
#import "UIColor+AppColors.h"
#import "UIView+Effects.h"

@interface FSMainViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, FSSummonerDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *playerCollectionView;
@property (strong, nonatomic) IBOutlet UITextField *playerNameInputView;
@property (strong, nonatomic) IBOutlet UIButton *playerSummonButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerNameInputViewBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerCollectionViewBottom;
@property (strong, nonatomic) IBOutlet UIView *inputHolderView;

- (IBAction)summonPlayer:(id)sender;
- (IBAction)drawerPressed:(id)sender;

- (Summoner *)summoner;
- (NSArray *)summoners;

@end

