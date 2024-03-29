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
@property (strong, nonatomic) NSMutableDictionary *scrollPositions;

@end

@implementation FSMatchCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *overviewCell = [UINib nibWithNibName:@"FSGameOverviewCell" bundle:[NSBundle mainBundle]];
    UINib *matchPlayerCell = [UINib nibWithNibName:@"FSMatchPlayerCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:overviewCell forCellWithReuseIdentifier:@"FSGameOverviewCell"];
    [self.collectionView registerNib:matchPlayerCell forCellWithReuseIdentifier:@"MatchPlayerCell"];
    
    self.participants = [NSMutableDictionary new];
    self.scrollPositions = [NSMutableDictionary new];
    for (MatchParticipant *p in [self.dataSource match].mMatchParticipants) {
        [self.participants setObject:p forKey:p.mpParticipantID];
        [self.scrollPositions setObject:[NSValue valueWithCGPoint:CGPointZero] forKey:p.mpParticipantID];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Helpers

- (void)screenDidChangeOrientation:(NSNotification *)notification {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setupItemTableViewCell:(FSItemTableViewCell *)cell atIndexPath:(NSIndexPath *)path participant:(MatchParticipant *)participant {
    NSInteger item = 0;
    
    switch (path.row) {
        case 0:
            item = [participant.mpParticipantStats.mpsItem0 integerValue];
            break;
        case 1:
            item = [participant.mpParticipantStats.mpsItem1 integerValue];
            break;
        case 2:
            item = [participant.mpParticipantStats.mpsItem2 integerValue];
            break;
        case 3:
            item = [participant.mpParticipantStats.mpsItem3 integerValue];
            break;
        case 4:
            item = [participant.mpParticipantStats.mpsItem4 integerValue];
            break;
        case 5:
            item = [participant.mpParticipantStats.mpsItem5 integerValue];
            break;
        case 6:
            item = [participant.mpParticipantStats.mpsItem6 integerValue];
            break;
        default:
            break;
    }
    
    [Item itemInformationFor:item region:@"na"].then(^(Item *item) {
        cell.itemNameLabel.text = item.iName;
        
        NSString *urlString = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/%@/img/item/%@", [[CRFiddleAPIClient sharedInstance] currentVersion].value, item.iImage];
        NSURL *url = [NSURL URLWithString:urlString];
        DFImageRequest *req = [[DFImageRequest alloc] initWithResource:url];
        [cell.itemImage setImageWithRequest:req];
    }).catch(^(NSError *error) {
        cell.itemNameLabel.text = @"None";
        [cell.itemImage setImage:[UIImage imageNamed:@"Missing"]];
    });
    cell.itemNumberLabel.text = [NSString stringWithFormat:@"Item %ld", (long)path.row + 1];
    
    UIColor *col = [UIColor colorWithWhite:0.65f alpha:0.5f];
    
    cell.backgroundColor = col;
    cell.itemNameLabel.textColor = [UIColor fiddlesticksSecondaryColor];
    cell.itemNumberLabel.textColor = [UIColor fiddlesticksMainColor];
}

#pragma mark - FSGameOverviewCellDelegate

- (void)summonerPressed:(NSInteger)summonerAtPosition overviewCell:(FSGameOverviewCell *)cell {
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:summonerAtPosition inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    } else {
        NSInteger column = (summonerAtPosition < [self.collectionView numberOfItemsInSection:0] - 1 ? summonerAtPosition + 1 : summonerAtPosition);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:column inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource match].mMatchParticipants.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    if(indexPath.row == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FSGameOverviewCell" forIndexPath:indexPath];
        FSGameOverviewCell *overviewCell = ((FSGameOverviewCell *) cell);
        overviewCell.delegate = self;
        
        // Set the names for all the buttons.
        for (UIButton *summonerButton in overviewCell.summonerButtons) {
            MatchParticipant *p = [self.participants objectForKey:@(summonerButton.tag)];
            if(p) {
                [summonerButton setTitle:p.mpParticipantIdentity.mpiSummonerName forState:UIControlStateNormal];
            }
        }
        
        // Set all the champion images.
        for(DFImageView *championImage in overviewCell.summonerImages) {
            MatchParticipant *p = [self.participants objectForKey:@(championImage.tag - 10)];
            if(p) {
                [Champion championInformationFor:[p.mpChampionID integerValue] region:@"na"].then(^(Champion *champ) {
                    [CRFiddleAPIClient sharedInstance].currentVersion.then(^(NSString *version){
                        NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/%@/img/champion/%@.png", version, champ.cKey];
                        DFImageRequest *req = [[DFImageRequest alloc] initWithResource:[NSURL URLWithString:url]];
                        [championImage setImageWithRequest:req];
                    });
                });
            }
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MatchPlayerCell" forIndexPath:indexPath];
        FSMatchPlayerCollectionViewCell *playerCell = ((FSMatchPlayerCollectionViewCell *)cell);
        playerCell.statisticsTableView.dataSource = self;
        playerCell.statisticsTableView.delegate = self;
        [playerCell.statisticsTableView reloadData];
        MatchParticipant *p = [self.participants objectForKey:@(indexPath.row)];
        
        [Champion championInformationFor:[p.mpChampionID integerValue] region:@"na"].then(^(Champion *champ) {
            [CRFiddleAPIClient sharedInstance].currentVersion.then(^(NSString *version){
                NSString *url1 = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/%@/img/champion/%@.png", version, champ.cKey];
                NSString *url2 = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/img/champion/loading/%@_0.jpg", champ.cKey];
                DFImageRequest *req1 = [[DFImageRequest alloc] initWithResource:[NSURL URLWithString:url1]];
                DFImageRequest *req2 = [[DFImageRequest alloc] initWithResource:[NSURL URLWithString:url2]];
                [playerCell.championImage setImageWithRequest:req1];
                [playerCell.backgroundImage setImageWithRequest:req2];
            });
        });
        
        playerCell.playerNameLabel.text = p.mpParticipantIdentity.mpiSummonerName;
        playerCell.playerHighestRank.text = p.mpHighestAchievedSeasonTier;
        NSValue *offset = [self.scrollPositions objectForKey:@(indexPath.row)];
        playerCell.statisticsTableView.contentOffset = [offset CGPointValue];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(screenSize.width, screenSize.height - 64);
    } else {
        UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)collectionViewLayout;
        if(indexPath.row == 0) {
            return CGSizeMake(screenSize.width, screenSize.height - (flow.sectionInset.top + flow.sectionInset.bottom) - 44);
        } else {
            return CGSizeMake(screenSize.width / 2, screenSize.height - (flow.sectionInset.top + flow.sectionInset.bottom) - 44);
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row != 0) {
        FSMatchPlayerCollectionViewCell *matchCell = (FSMatchPlayerCollectionViewCell *)cell;
        CGPoint offset = matchCell.statisticsTableView.contentOffset;
        [self.scrollPositions setObject:[NSValue valueWithCGPoint:offset] forKey:@(indexPath.row)];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 5;
            break;
        case 1:
            return 7;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *c;
    
    UICollectionViewCell *collectionViewCell = (UICollectionViewCell *)[[[tableView superview] superview] superview];
    NSIndexPath *path = [self.collectionView indexPathForCell:collectionViewCell];
    
    MatchParticipant *p = [self.participants objectForKey:@(path.row)];
    
    switch(indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatsCell"];
            
            if(!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"StatsCell"];
            }
            
            c = cell;
            
            cell.imageView.image = nil;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [p.mpParticipantStats.mpsKills stringValue];
                    cell.detailTextLabel.text = @"Kills";
                    break;
                case 1:
                    cell.textLabel.text = [p.mpParticipantStats.mpsDeaths stringValue];
                    cell.detailTextLabel.text = @"Deaths";
                    break;
                case 2:
                    cell.textLabel.text = [p.mpParticipantStats.mpsAssists stringValue];
                    cell.detailTextLabel.text = @"Assists";
                    break;
                case 3:
                    cell.textLabel.text = [p.mpParticipantStats.mpsTotalMinionsKilled stringValue];
                    cell.detailTextLabel.text = @"Minions";
                    break;
                case 4:
                    cell.textLabel.text = [p.mpParticipantStats.mpsGoldEarned stringValue];
                    cell.detailTextLabel.text = @"Gold";
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: {
            FSItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
            c = cell;
            [self setupItemTableViewCell:cell atIndexPath:indexPath participant:p];
            break;
        }
        default:
            break;
    }
    
    UIColor *col = [UIColor colorWithWhite:0.65f alpha:0.5f];
    
    c.backgroundColor = col;
    c.textLabel.textColor = [UIColor fiddlesticksSecondaryColor];
    c.detailTextLabel.textColor = [UIColor fiddlesticksMainColor];
    
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        return 65;
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Stats";
            break;
        case 1:
            return @"Items";
            break;
        case 2:
            return @"Achievements";
            break;
        default:
            return @"";
            break;
    }
}

@end
