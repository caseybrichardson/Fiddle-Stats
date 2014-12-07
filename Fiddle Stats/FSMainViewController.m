//
//  ViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSMainViewController.h"

@interface FSMainViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *sectionChanges;
@property (strong, nonatomic) NSMutableArray *itemChanges;

@property (strong, nonatomic) Summoner *selectedSummoner;

@end

@implementation FSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"FSCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PlayerCell"];
    
    [self.inputHolderView addGradientWithColors:@[[UIColor clearColor], [UIColor blackColor]]];
    
    NSError *error;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"%@ %@", error, [error userInfo]);
    } else {
        [self.playerCollectionView reloadData];
    }
    
    //AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //FSDataDelegate *dataDelegate = [[FSDataDelegate alloc] initWithType:FSDataDelegateTypeCollectionView entityName:@"Summoner" inContext:del.managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Summoner" inManagedObjectContext:del.managedObjectContext];
    NSSortDescriptor *favoriteDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sFavorited" ascending:NO];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sName" ascending:YES];
    
    [request setEntity:description];
    [request setSortDescriptors:@[favoriteDescriptor, nameDescriptor]];
    [request setFetchBatchSize:100];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:del.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = controller;
    self.fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.view endEditing:YES];
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
    
    [self.playerNameInputView resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    Summoner *summoner = ((Summoner *)[[self fetchedResultsController] objectAtIndexPath:indexPath]);
    
    cell.nameLabel.text = summoner.sName;
    
    NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/4.20.1/img/profileicon/%d.png";
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:urlString, [summoner.sProfileIconID integerValue]]];
    [cell.backgroundImage setImageWithURL:imageURL];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Summoner *summoner = (Summoner *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.selectedSummoner = summoner;
    [self performSegueWithIdentifier:@"playerDetails" sender:self];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.sectionChanges = [NSMutableArray array];
    self.itemChanges = [NSMutableArray array];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.playerCollectionView performBatchUpdates:^{
        for (NSDictionary *dict in self.sectionChanges) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        [self.playerCollectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.playerCollectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        break;
                    case NSFetchedResultsChangeMove:
                        break;
                }
            }];
        }
        
        for (NSDictionary *dict in self.itemChanges) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        [self.playerCollectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.playerCollectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.playerCollectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.playerCollectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        self.sectionChanges = nil;
        self.itemChanges = nil;
    }];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    change[@(type)] = @(sectionIndex);
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.itemChanges addObject:change];
}

#pragma mark - FSSummonerDataSource

- (Summoner *)summoner {
    return self.selectedSummoner;
}

@end
