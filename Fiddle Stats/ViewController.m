//
//  ViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray *summoners;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"FSCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PlayerCell"];
    
    self.summoners = [NSArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Notification Selectors

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    id keyboardFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    id animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    
    self.playerCollectionViewBottom.constant = keyboardFrame.size.height;
    self.playerNameInputViewBottom.constant = keyboardFrame.size.height + self.playerNameInputViewBottom.constant;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    id animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    
    self.playerCollectionViewBottom.constant = 0;
    self.playerNameInputViewBottom.constant = 20;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - IBActions

- (IBAction)summonPlayer:(id)sender {
    NSString *playerName = self.playerNameInputView.text;
    
    [Summoner summonerInformationFor:playerName region:@"na" withBlock:^(Summoner *summoner, NSError *error) {
        NSLog(@"%@", summoner);
        self.summoners = [Summoner storedSummoners];
        [self.playerCollectionView reloadData];
    }];
    
    [self.playerNameInputView resignFirstResponder];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.summoners count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    Summoner *summoner = ((Summoner *)[self.summoners objectAtIndex:indexPath.row]);
    
    cell.nameLabel.text = summoner.sName;
    
    NSString *name = [summoner.sName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://avatar.leagueoflegends.com/na/%@.png", name]];
    [cell.backgroundImage setImageWithURL:imageURL];
    
    return cell;
}

@end
