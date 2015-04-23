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
@property (strong, nonatomic) Match *selectedMatch;

@end

@implementation FSPlayerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIViewController *back = [self.navigationController backViewController];
    
    // Get our data source ready
    if([back conformsToProtocol:@protocol(FSSummonerDataSource)]) {
        id<FSSummonerDataSource> dataSource = (id<FSSummonerDataSource>)back;
        self.summonerDataSource = dataSource;
    } else {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    Summoner *summoner = [self.summonerDataSource summoner];
    SummonerGroup *summonerGroup = summoner.sGroup;
    
    // Setup refresh control
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.tintColor = [UIColor fiddlesticksSecondaryColor];
    [refreshControl addTarget:self action:@selector(refreshViews:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
    self.tableView.backgroundColor = [UIColor neutralColor];
    self.tableView.separatorColor = [UIColor fiddlesticksSecondaryColor];
    self.modeControl.tintColor = [UIColor fiddlesticksSecondaryColor];
    
    UINib *matchCell = [UINib nibWithNibName:@"FSMatchTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:matchCell forCellReuseIdentifier:@"MatchCell"];
    
    // Setup a date formatter for use
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateFormatter = dateFormatter;
    
    // Setup some UI stuff
    self.groupLabel.text = summonerGroup.gGroupTitle;
    self.nameLabel.text = summoner.sName;
    
    NSArray *colors = @[[UIColor blackColor], [UIColor clearColor]];
    [self.gradientView addGradientWithColors:colors];
    
    [SVProgressHUD show];
    
    // Get our current version number
    [CRFiddleAPIClient currentAPIVersionForRegion:@"na" block:^(NSArray *versions, NSError *error) {
        NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/%@/img/profileicon/%d.png";
        NSString *currentVersion = versions[0];
        NSInteger iconID = [summoner.sProfileIconID integerValue];
        NSString *formattedURL = [NSString stringWithFormat:urlString, currentVersion, iconID];
        NSURL *imageURL = [NSURL URLWithString:formattedURL];
        DFImageRequest *req = [[DFImageRequest alloc] initWithResource:imageURL];
        [self.summonerIcon setImageWithRequest:req];
    }];
    
    // Grab our new matches
    [Match matchesInformationFor:summoner].then(^(NSArray *matches) {
        [self initializeDataDelegate];
        
        if(matches.count > 0) {
            MatchParticipant *participant = [[matches lastObject] matchParticipantForSummoner:summoner];
            
            [Champion championInformationFor:[participant.mpChampionID integerValue] region:@"na"].then(^(Champion *champ){
                NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/img/champion/splash/%@_0.jpg";
                NSString *champKey = champ.cKey;
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlString, champKey]];
                DFImageRequest *req = [[DFImageRequest alloc] initWithResource:url];
                [self.champView setImageWithRequest:req];
            });
        }
        
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self.gradientView.layer sublayers][0] setFrame:self.gradientView.bounds];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.view endEditing:YES];
    
    if([segue.identifier isEqualToString:@"MatchDetails"]) {
        FSMatchCollectionViewController *mcvc = [segue destinationViewController];
        mcvc.dataSource = self;
    }
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
        
        [Champion championInformationFor:[participant.mpChampionID integerValue] region:@"na"].then(^(Champion *champ){
            [matchCell.champNameLabelView setText:champ.cName];
            
            [CRFiddleAPIClient currentAPIVersionForRegion:@"na" block:^(NSArray *versions, NSError *error1) {
                NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/%@/img/champion/%@.png", versions[0], champ.cKey];
                DFImageRequest *req = [[DFImageRequest alloc] initWithResource:[NSURL URLWithString:url]];
                [matchCell.champImageView setImageWithRequest:req];
            }];
        });
        
        MatchParticipantStats *stats = participant.mpParticipantStats;
        matchCell.matchGameType.text = m.mMatchType;
        matchCell.matchOutcomeView.backgroundColor = [stats.mpsWinner boolValue] ? [UIColor positiveColor] : [UIColor negativeColor];
        matchCell.kdaLabel.text = [NSString stringWithFormat:@"%@/%@/%@", stats.mpsKills, stats.mpsDeaths, stats.mpsAssists];
        matchCell.minionsLabel.text = [stats.mpsTotalMinionsKilled stringValue];
        
        NSUInteger duration = [m.mMatchDuration unsignedIntegerValue];
        NSUInteger hours = duration / 3600;
        NSUInteger minutes = (duration / 60) % 60;
        NSUInteger seconds = duration % 60;
        
        if(hours > 0) {
            matchCell.matchTime.text = [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)hours, (unsigned long)minutes, (unsigned long)seconds];
        } else {
            matchCell.matchTime.text = [NSString stringWithFormat:@"%lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
        }
    }];
    
    [self.dataDelegate setItemSelectionHandler:^(id view, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        Match *m = [frc objectAtIndexPath:indexPath];
        
        bool showHUD = [m.mHasFullData boolValue];
        if(!showHUD) { [SVProgressHUD show]; }
        [Match expandedMatchInformationFor:m].then(^(Match *match) {
            if(!showHUD) { [SVProgressHUD dismiss]; }
            ptvc.selectedMatch = match;
            [ptvc performSegueWithIdentifier:@"MatchDetails" sender:ptvc];
        });
    }];
    
    [self.dataDelegate performFetch];
}

- (void)refreshViews:(id)sender {
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
    DFImageRequest *req = [[DFImageRequest alloc] initWithResource:imageURL];
    [self.summonerIcon setImageWithRequest:req];
    
    [Match matchesInformationFor:summoner].then(^(NSArray *matches) {
        [self.dataDelegate performFetch];
        
        if([matches count] > 0) {
            MatchParticipant *participant = [[matches lastObject] matchParticipantForSummoner:[self.summonerDataSource summoner]];
            [Champion championInformationFor:[participant.mpChampionID integerValue] region:@"na"].then(^(Champion *champ) {
                
                NSString *champKey = champ.cKey;
                NSString *urlString = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/img/champion/splash/%@_0.jpg", champKey];
                NSURL *url = [NSURL URLWithString:urlString];
                DFImageRequest *req = [[DFImageRequest alloc] initWithResource:url];
                [self.champView setImageWithRequest:req];
            });
        }
        
        [self.tableView reloadData];
    });
    
    [((UIRefreshControl *)sender) endRefreshing];
}

#pragma mark - FSMatchDataSource

- (Match *)match {
    return self.selectedMatch;
}

#pragma mark - IBActions

- (IBAction)optionsPressed:(id)sender
{
    [self showExternalServicesDialog];
}

- (IBAction)modeChanged:(id)sender {
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
