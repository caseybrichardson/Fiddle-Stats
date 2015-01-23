//
//  FSMatchCollectionViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSMatchCollectionViewController.h"

@interface FSMatchCollectionViewController ()

@end

@implementation FSMatchCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *overviewCell = [UINib nibWithNibName:@"FSGameOverviewCell" bundle:[NSBundle mainBundle]];
    UINib *playerCell = [UINib nibWithNibName:@"FSGamePlayerCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:overviewCell forCellWithReuseIdentifier:@"FSGameOverviewCell"];
    [self.collectionView registerNib:playerCell forCellWithReuseIdentifier:@"FSGamePlayerCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Helpers

- (void)screenDidChangeOrientation:(NSNotification *)notification {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView setNeedsLayout];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

#pragma mark - FSGameOverviewCellDelegate

- (void)summonerPressed:(NSInteger)summonerAtPosition overviewCell:(FSGameOverviewCell *)cell {
    NSLog(@"TEST");
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:summonerAtPosition inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 11;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    if(indexPath.row == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FSGameOverviewCell" forIndexPath:indexPath];
        ((FSGameOverviewCell *) cell).delegate = self;
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FSGamePlayerCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(screenSize.width, screenSize.height - 84);
    } else {
        if(indexPath.row == 0) {
            return CGSizeMake(screenSize.width, screenSize.height - 44);
        } else {
            return CGSizeMake(screenSize.width / 2, screenSize.height - 44);
        }
    }
}

@end
