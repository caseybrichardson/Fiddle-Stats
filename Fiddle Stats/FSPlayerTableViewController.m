//
//  FSPlayerTableViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSPlayerTableViewController.h"

@interface FSPlayerTableViewController ()

@property (strong, nonatomic) FSDataDelegate *dataDelegate;

@end

@implementation FSPlayerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[self.navigationController backViewController] conformsToProtocol:@protocol(FSSummonerDataSource)]) {
        [self setSummonerDataSource:((id<FSSummonerDataSource>)[self.navigationController backViewController])];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FSMatchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MatchCell"];
    
    Summoner *summoner = [self.summonerDataSource summoner];
    SummonerGroup *group = [self.summonerDataSource summoner].sGroup;
    [self.groupLabel setText:group.gGroupTitle];
    
    if(!summoner) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/profileicon/%d.png";
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:urlString, [summoner.sProfileIconID integerValue]]];
    UIImageView *view = self.champView;
    
    [self.nameLabel setText:summoner.sName];
    [self.summonerIcon setImageWithURL:imageURL];
    
    [self.gradientView addGradientWithColors:@[[UIColor blackColor], [UIColor clearColor]]];
    
    [Match matchesInformationFor:summoner withBlock:^(NSArray *m, NSError *e) {
        [self initializeDataDelegate];
        [self.tableView reloadData];
        
        if([m count] > 0) {
            [Champion championInformationFor:[((Match *)m[0]).mPlayerChampID integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
                
                NSString *champKey = champ.cKey;
                
                NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/img/champion/splash/%@_0.jpg", champKey];
                
                [self.champView setAlpha:0];
                [self.champView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [view setImage:image];
                    [UIView animateWithDuration:0.25 animations:^{
                        [view setAlpha:1];
                    }];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    
                }];
            }];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark - Helpers

- (void)initializeDataDelegate {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.dataDelegate = [[FSDataDelegate alloc] initWithType:FSDataDelegateTypeTableView forView:self.tableView entityName:@"Match" inContext:del.managedObjectContext];
    
    self.tableView.dataSource = self.dataDelegate;
    self.tableView.delegate = self.dataDelegate;
    
    FSDataPair *sort1 = [[FSDataPair alloc] initWithFirst:@"mMatchCreation" second:@YES];
    [self.dataDelegate setSortingKeyPaths:@[sort1]];
    [self.dataDelegate setReuseIdentifier:@"MatchCell"];
    [self.dataDelegate setPredicateValues:[[FSDataPair alloc] initWithFirst:@"mMatchOwner == %@" second:[self.summonerDataSource summoner]]];
    
    [self.dataDelegate setTableViewCellSource:^(UITableView *tableView, UITableViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        FSMatchTableViewCell *matchCell = (FSMatchTableViewCell *)cell;
        
        Match *m = [frc objectAtIndexPath:indexPath];
        [Champion championInformationFor:[[m mPlayerChampID] integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
            [matchCell.champNameLabelView setText:champ.cName];
            
            NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/champion/%@.png", champ.cKey];
            [matchCell.champImageView setImageWithURL:[NSURL URLWithString:url]];
        }];
        
        matchCell.matchOutcomeView.backgroundColor = [m.mPlayerWinner boolValue] ? [UIColor positiveColor] : [UIColor negativeColor];
    }];
    
    //__weak FSPlayerTableViewController *weakReference = self;
    [self.dataDelegate setItemSelectionHandler:^(id view, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        NSLog(@"HEY: %@", [frc objectAtIndexPath:indexPath]);
    }];
    
    [self.dataDelegate performFetch];
}

#pragma mark - IBActions

- (IBAction)optionsPressed:(id)sender
{
    //[self showOptionsDialog];
}

@end
