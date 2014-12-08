//
//  FSPlayerTableViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSPlayerTableViewController.h"

@interface FSPlayerTableViewController ()

@property (strong, nonatomic) NSArray *matches;

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
    
    if(!summoner) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/profileicon/%d.png";
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:urlString, [summoner.sProfileIconID integerValue]]];
    UIImageView *view = self.champView;
    
    [self.nameLabel setText:summoner.sName];
    [self.summonerIcon setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"100x100"]];
    
    [self.gradientView addGradientWithColors:@[[UIColor blackColor], [UIColor clearColor]]];
    
    [Match matchesInformationFor:summoner withBlock:^(NSArray *m, NSError *e) {
        self.matches = [Match storedMatchesForSummoner:summoner];
        if([self.matches count] > 0) {
            [Champion championInformationFor:[((Match *)self.matches[0]).mPlayerChampID integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
                
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSMatchTableViewCell *cell = (FSMatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MatchCell"];

    Match *m = ((Match *)self.matches[indexPath.row]);
    [Champion championInformationFor:[[m mPlayerChampID] integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
        [cell.champNameLabelView setText:champ.cName];
        
        NSString *url = [NSString stringWithFormat:@"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/champion/%@.png", champ.cKey];
        [cell.champImageView setImageWithURL:[NSURL URLWithString:url]];
    }];
    
    cell.matchOutcomeView.backgroundColor = [m.mPlayerWinner boolValue] ? [UIColor positiveColor] : [UIColor negativeColor];
    
    return cell;
}

- (IBAction)optionsPressed:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Favorite", @"Share", nil];
    [sheet showInView:self.view];
}

@end
