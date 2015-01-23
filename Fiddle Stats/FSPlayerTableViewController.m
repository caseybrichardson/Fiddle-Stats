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
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UINib *statsView;

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
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    self.statsView = [UINib nibWithNibName:@"FSParticipantStatsView" bundle:[NSBundle mainBundle]];
    
    Summoner *summoner = [self.summonerDataSource summoner];
    SummonerGroup *group = [self.summonerDataSource summoner].sGroup;
    [self.groupLabel setText:group.gGroupTitle];
    
    if(!summoner) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/%@/img/profileicon/%d.png";
    NSString *currentVersion = [CRFiddleAPIClient currentAPIVersionForRegion:summoner.sRegion];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:urlString, currentVersion, [summoner.sProfileIconID integerValue]]];
    UIImageView *view = self.champView;
    
    [self.nameLabel setText:summoner.sName];
    [self.summonerIcon setImageWithURL:imageURL];
    
    [self.gradientView addGradientWithColors:@[[UIColor blackColor], [UIColor clearColor]]];
    
    [Match matchesInformationFor:summoner withBlock:^(NSArray *matches, NSError *e) {
        [self initializeDataDelegate];
        [self.tableView reloadData];
        
        if([matches count] > 0) {
            MatchParticipant *participant = [matches[0] matchParticipantForSummoner:[self.summonerDataSource summoner]];
            [Champion championInformationFor:[participant.mpChampionID integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
                
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self.gradientView.layer sublayers][0] setFrame:self.gradientView.bounds];
}

#pragma mark - Helpers

- (void)initializeDataDelegate {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.dataDelegate = [[FSDataDelegate alloc] initWithType:FSDataDelegateTypeTableView forView:self.tableView entityName:@"Match" inContext:del.managedObjectContext];
    
    self.tableView.dataSource = self.dataDelegate;
    self.tableView.delegate = self.dataDelegate;
    
    FSDataPair *sort1 = [[FSDataPair alloc] initWithFirst:@"mMatchCreation" second:@NO];
    [self.dataDelegate setSortingKeyPaths:@[sort1]];
    [self.dataDelegate setReuseIdentifier:@"MatchCell"];
    [self.dataDelegate setPredicateValues:[[FSDataPair alloc] initWithFirst:@"mMatchSummoners CONTAINS %@" second:[self.summonerDataSource summoner]]];
    
    __weak FSPlayerTableViewController *ptvc = self;
    [self.dataDelegate setTableViewCellSource:^(UITableView *tableView, UITableViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        FSMatchTableViewCell *matchCell = (FSMatchTableViewCell *)cell;
        Match *m = [frc objectAtIndexPath:indexPath];
        
        [matchCell.matchDate setText:[ptvc.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[m.mMatchCreation longLongValue]/1000]]];
        
        MatchParticipant *participant = [m matchParticipantForSummoner:[ptvc.summonerDataSource summoner]];
        
        [Champion championInformationFor:[participant.mpChampionID integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
            [matchCell.champNameLabelView setText:champ.cName];
            
            NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/champion/%@.png", champ.cKey];
            [matchCell.champImageView setImageWithURL:[NSURL URLWithString:url]];
        }];
        
        matchCell.matchOutcomeView.backgroundColor = [m.mPlayerWinner boolValue] ? [UIColor positiveColor] : [UIColor negativeColor];
    }];
    
    [self.dataDelegate setItemSelectionHandler:^(id view, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        [ptvc performSegueWithIdentifier:@"MatchDetails" sender:ptvc];
    }];
    
    [self.dataDelegate performFetch];
}

#pragma mark - IBActions

- (IBAction)optionsPressed:(id)sender
{
    [self showExternalServicesDialog];
}

- (void)showExternalServicesDialog {
    UIAlertController *optionsDialog = [UIAlertController alertControllerWithTitle:@"External Services" message:@"Choose an external service to view this player on." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *lolNexusAction = [UIAlertAction actionWithTitle:@"LoLNexus" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        Summoner *summoner = [self.summonerDataSource summoner];
        NSString *name = [summoner.sName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *urlString = [NSString stringWithFormat:@"http://www.lolnexus.com/NA/search?name=%@&region=na", name];
        NSURL *nexusURL = [NSURL URLWithString:urlString];
        STKWebKitModalViewController *wv = [[STKWebKitModalViewController alloc] initWithURL:nexusURL];
        wv.webKitViewController.newTabOpenMode = OpenNewTabInternal;
        [self presentViewController:wv animated:YES completion:nil];
    }];
    
    UIAlertAction *lolKingAction = [UIAlertAction actionWithTitle:@"LoLKing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        Summoner *summoner = [self.summonerDataSource summoner];
        NSString *urlString = [NSString stringWithFormat:@"http://www.lolking.net/summoner/na/%lld", [summoner.sID longLongValue]];
        NSURL *kingURL = [NSURL URLWithString:urlString];
        STKWebKitModalViewController *wv = [[STKWebKitModalViewController alloc] initWithURL:kingURL];
        wv.webKitViewController.newTabOpenMode = OpenNewTabInternal;
        [self presentViewController:wv animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [optionsDialog addAction:lolNexusAction];
    [optionsDialog addAction:lolKingAction];
    [optionsDialog addAction:cancelAction];
    
    [self presentViewController:optionsDialog animated:YES completion:nil];
}

@end
