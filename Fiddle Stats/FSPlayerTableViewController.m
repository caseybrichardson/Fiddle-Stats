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
    [self.champView setAlpha:0];
    [self.champView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ddragon.leagueoflegends.com/cdn/img/champion/splash/FiddleSticks_0.jpg"]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [view setImage:image];
        [UIView animateWithDuration:0.25 animations:^{
            [view setAlpha:1];
        }];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
    [Match matchesInformationFor:summoner withBlock:^(NSArray *matches, NSError *error) {
        if(error) {
            NSLog(@"%@", [error description]);
        }
        self.matches = matches;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    Match *m = ((Match *)self.matches[indexPath.row]);
    [Champion championInformationFor:[[m mPlayerChampID] integerValue] region:@"na" withBlock:^(Champion *champ, NSError *error) {
        [[cell textLabel] setText:champ.cName];
    }];
    
    return cell;
}

@end
