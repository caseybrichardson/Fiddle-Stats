//
//  ViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSMainViewController.h"

@interface FSMainViewController ()

@property (strong, nonatomic) Summoner *selectedSummoner;

@property (strong, nonatomic) FSDataDelegate *dataDelegate;

@end

@implementation FSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"FSCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PlayerCell"];
    
    [self.inputHolderView addGradientWithColors:@[[UIColor clearColor], [UIColor blackColor]]];
    
    [self initializeDataDelegate];
    
    [self.playerCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Helpers

- (void)initializeDataDelegate {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.dataDelegate = [[FSDataDelegate alloc] initWithType:FSDataDelegateTypeCollectionView forView:self.playerCollectionView entityName:@"Summoner" inContext:del.managedObjectContext];
    
    self.playerCollectionView.dataSource = self.dataDelegate;
    self.playerCollectionView.delegate = self.dataDelegate;
    
    FSDataPair *sort1 = [[FSDataPair alloc] initWithFirst:@"sFavorited" second:@NO];
    FSDataPair *sort2 = [[FSDataPair alloc] initWithFirst:@"sName" second:@YES];
    [self.dataDelegate setSortingKeyPaths:@[sort1, sort2]];
    [self.dataDelegate setReuseIdentifier:@"PlayerCell"];
    
    [self.dataDelegate setCollectionViewCellSource:^(UICollectionView *collectionView, UICollectionViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        FSCollectionViewCell *playerCell = (FSCollectionViewCell *)cell;
        Summoner *summoner = ((Summoner *)[frc objectAtIndexPath:indexPath]);
        
        playerCell.nameLabel.text = summoner.sName;
        
        NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/profileicon/%d.png";
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:urlString, [summoner.sProfileIconID integerValue]]];
        [playerCell.backgroundImage setImageWithURL:imageURL];
    }];
    
    __weak FSMainViewController *weakReference = self;
    [self.dataDelegate setItemSelectionHandler:^(id view, NSFetchedResultsController *frc, NSIndexPath *path) {
        Summoner *summoner = (Summoner *)[frc objectAtIndexPath:path];
        weakReference.selectedSummoner = summoner;
        [weakReference performSegueWithIdentifier:@"playerDetails" sender:weakReference];
    }];
    
    [self.dataDelegate performFetch];
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
    self.playerNameInputViewBottom.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - IBActions

- (IBAction)summonPlayer:(id)sender {
    NSString *playerName = self.playerNameInputView.text;
    
    if((![playerName isEqualToString:@""] && ![playerName isEqualToString:@" "])) {
        [Summoner summonerInformationFor:playerName region:@"na" withBlock:^(Summoner *summoner, NSError *error) {
            [self.playerCollectionView reloadData];
        }];
    }
    
    [self.playerNameInputView setText:@""];
    [self.playerNameInputView resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - FSSummonerDataSource

- (Summoner *)summoner {
    return self.selectedSummoner;
}

@end
