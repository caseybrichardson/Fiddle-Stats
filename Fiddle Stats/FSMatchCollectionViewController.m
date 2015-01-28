//
//  FSMatchCollectionViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSMatchCollectionViewController.h"

@interface FSMatchCollectionViewController ()

@property (strong, nonatomic) NSMutableDictionary *participants;

@end

@implementation FSMatchCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *overviewCell = [UINib nibWithNibName:@"FSGameOverviewCell" bundle:[NSBundle mainBundle]];
    UINib *playerCell = [UINib nibWithNibName:@"FSGamePlayerCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:overviewCell forCellWithReuseIdentifier:@"FSGameOverviewCell"];
    [self.collectionView registerNib:playerCell forCellWithReuseIdentifier:@"FSGamePlayerCell"];
    
    self.participants = [NSMutableDictionary dictionary];
    for (MatchParticipant *p in [self.dataSource match].mMatchParticipants) {
        self.participants[p.mpParticipantID] = p;
    }

    
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
        FSGameOverviewCell *overviewCell = ((FSGameOverviewCell *) cell);
        overviewCell.delegate = self;
        
        
        for (UIButton *summonerButton in overviewCell.summonerButtons) {
            MatchParticipant *p = [self.participants objectForKey:@(summonerButton.tag)];
            if(p) {
                [summonerButton setTitle:p.mpParticipantIdentity.mpiSummonerName forState:UIControlStateNormal];
            }
        }
        
        for(UIImageView *summonerImage in overviewCell.summonerImages) {
            MatchParticipant *p = [self.participants objectForKey:@(summonerImage.tag - 10)];
            [Champion championInformationFor:[p.mpChampionID integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
                NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/champion/%@.png", champ.cKey];
                [summonerImage setImageWithURL:[NSURL URLWithString:url]];
            }];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FSGamePlayerCell" forIndexPath:indexPath];
        FSGamePlayerCell *playerCell = ((FSGamePlayerCell *) cell);
        MatchParticipant *p = [self.participants objectForKey:@(indexPath.row)];
        
        playerCell.playerName.text = p.mpParticipantIdentity.mpiSummonerName;
        [Champion championInformationFor:[p.mpChampionID integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
            NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/champion/%@.png", champ.cKey];
            [playerCell.champImage setImageWithURL:[NSURL URLWithString:url]];
        }];
        
        for (UIImageView *itemImage in playerCell.itemImages) {
            NSInteger item = [[p.mpParticipantStats valueForKeyPath:[NSString stringWithFormat:@"mpsItem%ld", (long)(itemImage.tag - 1)]] integerValue];
            if(item != 0) {
                [Item itemInformationFor:item region:@"na" withBlock:^(Item *i, NSError *e) {
                    bool haveImage = [CRDataManager imageExistsWithFilename:i.iImage];
                    if(haveImage) {
                        NSLog(@"Have Image");
                        [itemImage setImage:[CRDataManager imageForImageNamed:i.iImage]];
                    } else {
                        if(!e) {
                            NSString *urlString = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/%@/img/item/%@", [CRFiddleAPIClient currentAPIVersionForRegion:@"na"], i.iImage];
                            NSURL *url = [NSURL URLWithString:urlString];
                            [itemImage setImageWithURL:url];
                            
//                            [Item downloadItemImageForItem:i withBlock:^(UIImage *image, NSError *error) {
//                                NSLog(@"ALL GOOD");
//                                [itemImage setImage:image];
//                            }];
                        } else {
                            [itemImage setImage:[UIImage imageNamed:@"Missing"]];
                        }
                    }
                }];
            }
        }
        
        for (UILabel *itemLabel in playerCell.itemNames) {
            NSInteger item = [[p.mpParticipantStats valueForKeyPath:[NSString stringWithFormat:@"mpsItem%ld", (long)(itemLabel.tag - 11)]] integerValue];
            if(item != 0) {
                [Item itemInformationFor:item region:@"na" withBlock:^(Item *i, NSError *e) {
                    itemLabel.text = (!e ? i.iName : @"None");
                }];
            }
        }
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
