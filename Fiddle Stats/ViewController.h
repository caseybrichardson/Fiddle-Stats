//
//  ViewController.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+AFNetworking.h>

#import "FSCollectionViewCell.h"
#import "Summoner+APIMethods.h"
#import "UIColor+AppColors.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *playerCollectionView;
@property (strong, nonatomic) IBOutlet UITextField *playerNameInputView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerNameInputViewBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playerCollectionViewBottom;

- (IBAction)summonPlayer:(id)sender;

@end

