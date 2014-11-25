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

@property (strong, nonatomic) RKCardView *presentedCardView;

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

#pragma mark - Helpers

- (RKCardView *)createCardViewForSummoner:(Summoner *)summoner {
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    
    CGFloat navBarY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    CGFloat cardX = self.playerNameInputView.frame.origin.x;
    CGFloat cardY = navBarY + 5;
    CGFloat cardW = self.playerSummonButton.frame.origin.x + self.playerSummonButton.frame.size.width - self.playerNameInputView.frame.origin.x;
    CGFloat cardH = self.inputHolderView.frame.origin.y + self.playerNameInputView.frame.origin.y + self.playerNameInputView.frame.size.height - navBarY;
    
    RKCardView *cardView = self.presentedCardView = [[RKCardView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    
    cardView.titleLabel.text = summoner.sName;
    
    cardView.coverImageView.image = [UIImage imageNamed:@"500x200"];
    cardView.profileImageView.image = [UIImage imageNamed:@"100x100"];
    
    CRBlockButton *closeButton = [[CRBlockButton alloc] init];
    closeButton.frame = CGRectMake(10, cardView.frame.origin.y + cardView.frame.size.height - cardView.frame.origin.y - 55, cardView.frame.size.width - 20, 45);
    closeButton.backgroundColor = [UIColor redColor];
    closeButton.layer.cornerRadius = 5;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTapBlock:^(CRBlockButton *button) {
        [self hidePresentedCardView];
    }];
    
    CRBlockButton *favoriteButton = [[CRBlockButton alloc] init];
    favoriteButton.frame = CGRectMake(10, cardView.titleLabel.bounds.origin.y, cardView.frame.size.width - 20, 45);
    favoriteButton.backgroundColor = [UIColor greenColor];
    favoriteButton.layer.cornerRadius = 5;
    [favoriteButton setTitle:([summoner.sFavorited boolValue] ? @"★" : @"☆") forState:UIControlStateNormal];
    [favoriteButton setTapBlock:^(CRBlockButton *button) {
        [self toggleFavoriteForSummoner:summoner];
        [button setTitle:([summoner.sFavorited boolValue] ? @"★" : @"☆") forState:UIControlStateNormal];
        [self.playerCollectionView reloadData];
    }];
    
    [cardView addSubview:closeButton];
    [cardView addSubview:favoriteButton];
    [cardView setAlpha:0];
    [UIView animateWithDuration:0.25f animations:^{
        cardView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [cardView addShadow];
    }];
    
    return cardView;
}

- (void)hidePresentedCardView {
    if(self.presentedCardView) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.presentedCardView setAlpha:0];
        } completion:^(BOOL finished) {
            [self.presentedCardView removeFromSuperview];
            self.presentedCardView = nil;
        }];
    }
}

- (void)toggleFavoriteForSummoner:(Summoner *)summoner {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    summoner.sFavorited = @(![summoner.sFavorited boolValue]);
    [del saveContext];
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
    
    NSString *name = [summoner.sName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://avatar.leagueoflegends.com/na/%@.png", name]];
    [cell.backgroundImage setImageWithURL:imageURL];
    
    if([summoner.sFavorited boolValue]) {
        [cell.favoriteView setFillColor:[UIColor yellowColor]];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Summoner *summoner = (Summoner *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [Match matchesInformationFor:summoner withBlock:^(NSArray *matches, NSError *error) {
        if([matches count] > 0)
            NSLog(@"Match[0] is: %@", matches[0]);
    }];

    [self.view addSubview:[self createCardViewForSummoner:summoner]];
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

@end
