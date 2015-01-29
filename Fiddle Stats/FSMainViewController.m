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

@property (strong, nonatomic) NSMutableSet *editingCells;

@property (strong, nonatomic) UIBarButtonItem *selectBarButton;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButton;

@end

@implementation FSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"FSCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PlayerCell"];
    
    self.selectBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(selectPressed:)];
    self.cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    self.navigationItem.rightBarButtonItem = self.selectBarButton;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *actionSheet = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionPressed:)];
    [self setToolbarItems:@[flexibleSpace, actionSheet, flexibleSpace]];

    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [self.playerCollectionView addGestureRecognizer:tgr];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.minimumPressDuration = 0.75f;
    [self.playerCollectionView addGestureRecognizer:lpgr];
    
    [self.inputHolderView addGradientWithColors:@[[UIColor clearColor], [UIColor blackColor]]];
    
    [self initializeDataDelegate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIEdgeInsets insets = self.playerCollectionView.contentInset;
    insets.bottom = self.inputHolderView.bounds.size.height;
    [self.playerCollectionView setContentInset:insets];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self.inputHolderView.layer sublayers][0] setFrame:self.inputHolderView.bounds];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.view endEditing:YES];
    
    if([segue.identifier isEqualToString:@"SummonerGroupAdd"]) {
        FSSummonerGroupViewController *sgvc = [segue destinationViewController];
        [sgvc setSummonerDataSource:self];
        [sgvc setCompletion:^(BOOL completedWithChanges) {
            
            if(completedWithChanges) {
                AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [del saveContext];
            }
            
            [self setEditing:!completedWithChanges];
        }];
    }
}

#pragma mark - Helpers

- (void)initializeDataDelegate {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.dataDelegate = [[FSDataDelegate alloc] initWithType:FSDataDelegateTypeCollectionView forView:self.playerCollectionView entityName:@"Summoner" inContext:del.managedObjectContext];
    
    self.playerCollectionView.dataSource = self.dataDelegate;
    self.playerCollectionView.delegate = self.dataDelegate;
    self.playerCollectionView.allowsSelection = YES;
    self.playerCollectionView.allowsMultipleSelection = YES;
    
    FSDataPair *sort1 = [[FSDataPair alloc] initWithFirst:@"sGroup.gGroupTitle" second:@YES];
    FSDataPair *sort2 = [[FSDataPair alloc] initWithFirst:@"sName" second:@NO];
    [self.dataDelegate setSortingKeyPaths:@[sort1, sort2]];
    [self.dataDelegate setReuseIdentifier:@"PlayerCell"];
    [self.dataDelegate setSectionNameKeyPath:@"groupName"];
    
    __weak FSMainViewController *mvc = self;
    [self.dataDelegate setCollectionViewCellSource:^(UICollectionView *collectionView, UICollectionViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        FSCollectionViewCell *playerCell = (FSCollectionViewCell *)cell;
        
        if([mvc.editingCells containsObject:indexPath]) {
            [playerCell setEditing:YES];
        } else {
            [playerCell setEditing:NO];
        }
        
        Summoner *summoner = ((Summoner *)[frc objectAtIndexPath:indexPath]);
        
        playerCell.nameLabel.text = summoner.sName;
        
        [CRFiddleAPIClient currentAPIVersionForRegion:@"na" block:^(NSArray *versions, NSError *error) {
            NSString *urlString = @"http://ddragon.leagueoflegends.com/cdn/%@/img/profileicon/%d.png";
            NSString *currentVersion = versions[0];
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:urlString, currentVersion, [summoner.sProfileIconID integerValue]]];
            [playerCell.backgroundImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"Missing"]];
        }];
    }];
    
    [self.dataDelegate setItemSelectionHandler:^(id view, NSFetchedResultsController *frc, NSIndexPath *path) {
        if(!mvc.editing) {
            Summoner *summoner = (Summoner *)[frc objectAtIndexPath:path];
            mvc.selectedSummoner = summoner;
            [mvc performSegueWithIdentifier:@"PlayerDetails" sender:mvc];
        }
    }];
    
    [self.dataDelegate performFetch];
}

- (void)beganEditingCellAtIndexPath:(NSIndexPath *)path {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[self.playerCollectionView cellForItemAtIndexPath:path];
    [cell setEditing:YES];
}

- (void)stopEditingCellAtIndexPath:(NSIndexPath *)path {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[self.playerCollectionView cellForItemAtIndexPath:path];
    [cell setEditing:NO];
}

- (void)showSummonerAddView {
    self.playerCollectionViewBottom.constant = 0;
    self.playerNameInputViewBottom.constant = 0;
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideSummonerAddView {
    self.playerCollectionViewBottom.constant = 0;
    self.playerNameInputViewBottom.constant = -self.inputHolderView.bounds.size.height * 2;
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)setEditing:(BOOL)editing {
    if(super.editing != editing) {
        [self.view endEditing:YES];
        super.editing = editing;
        if(editing) {
            [self hideSummonerAddView];
            [self.navigationController setToolbarHidden:NO animated:YES];
            self.navigationItem.rightBarButtonItem = self.cancelBarButton;
            
            self.editingCells = [NSMutableSet set];
        } else {
            [self showSummonerAddView];
            [self.navigationController setToolbarHidden:YES animated:YES];
            self.navigationItem.rightBarButtonItem = self.selectBarButton;
            
            [self.editingCells addObjectsFromArray:[self.playerCollectionView indexPathsForVisibleItems]];
            for (NSIndexPath *path in self.editingCells) {
                [self stopEditingCellAtIndexPath:path];
            }
            
            self.editingCells = nil;
        }
    }
}

#pragma mark - UIGestureRecognizer Handlers

- (void)handleTap:(UITapGestureRecognizer *)tgr {
    CGPoint point = [tgr locationInView:self.playerCollectionView];
    NSIndexPath *path = [self.playerCollectionView indexPathForItemAtPoint:point];
    
    if(path) {
        if([self.editingCells containsObject:path]) {
            [self.editingCells removeObject:path];
            [self stopEditingCellAtIndexPath:path];
        } else {
            [self.editingCells addObject:path];
            [self beganEditingCellAtIndexPath:path];
        }
        
        [((UIBarButtonItem *)self.toolbarItems[1]) setEnabled:([self.editingCells count] != 0)];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)lpgr {
    CGPoint point = [lpgr locationInView:self.playerCollectionView];
    NSIndexPath *path = [self.playerCollectionView indexPathForItemAtPoint:point];
    
    if(path) {
        UICollectionViewCell *cell = [self.playerCollectionView cellForItemAtIndexPath:path];
        [cell becomeFirstResponder];
        UIMenuController *controller = [UIMenuController sharedMenuController];
        [controller setTargetRect:cell.frame inView:self.playerCollectionView];
        [controller setMenuVisible:YES animated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([gestureRecognizer class] == [UITapGestureRecognizer class]) {
        return self.editing;
    } else if ([gestureRecognizer class] == [UILongPressGestureRecognizer class]) {
        return !self.editing;
    } else {
        return YES;
    }
}

#pragma mark - Notification Selectors

- (void)keyboardWillShow:(NSNotification *)notification {
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
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
    } completion:^(BOOL finished) {
        if(self.editing) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)summonPlayer:(id)sender {
    NSString *playerName = self.playerNameInputView.text;
    
    // TODO: implement a regex to check for nothing but whitespace
    if((![playerName isEqualToString:@""] && ![playerName isEqualToString:@" "])) {
        [Summoner summonerInformationFor:playerName region:@"na" withBlock:^(Summoner *summoner, NSError *error) {
            [self.playerCollectionView reloadData];
        }];
    }
    
    [self.playerNameInputView setText:@""];
    [self.playerNameInputView resignFirstResponder];
}

- (IBAction)drawerPressed:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)selectPressed:(id)sender {
    self.navigationItem.rightBarButtonItem = self.cancelBarButton;
    [((UIBarButtonItem *)self.toolbarItems[1]) setEnabled:NO];
    [self setEditing:YES];
}

- (void)cancelPressed:(id)sender {
    self.navigationItem.rightBarButtonItem = self.selectBarButton;
    
    for (NSIndexPath *path in self.editingCells) {
        [self stopEditingCellAtIndexPath:path];
    }
    
    [self setEditing:NO];
}

- (void)actionPressed:(id)sender {
    [self showOptionsDialog];
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

- (NSArray *)summoners {
    NSMutableArray *summoners = [NSMutableArray array];
    
    for (NSIndexPath *path in self.editingCells) {
        [summoners addObject:[self.dataDelegate objectInResultsAtIndexPath:path]];
    }
    
    return summoners;
}

#pragma mark - UIAlertController Helpers

- (void)showOptionsDialog {
    
    UIAlertController *optionsDialog = [UIAlertController alertControllerWithTitle:@"Actions" message:@"Choose an action to perform." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *groupDialogDisplayAction = [UIAlertAction actionWithTitle:@"Edit Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"SummonerGroupAdd" sender:self];
    }];
    
    UIAlertAction *groupRemoveAction = [UIAlertAction actionWithTitle:@"Remove From Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        for (NSIndexPath *path in self.editingCells) {
            [self stopEditingCellAtIndexPath:path];
            Summoner *summoner = [self.dataDelegate objectInResultsAtIndexPath:path];
            
            if(summoner) {
                if(summoner.sGroup) {
                    SummonerGroup *group = summoner.sGroup;
                    [summoner.sGroup removeGSummonersObject:summoner];
                    
                    if([group.gSummoners count] == 0) {
                        [del.managedObjectContext deleteObject:group];
                    }
                }
            }
        }
        
        [del saveContext];
        [self setEditing:NO];
        [self.playerCollectionView reloadData];
    }];
    
    NSString *deleteSummonerTitle = (self.editingCells.count > 1 ? @"Delete Summoners" : @"Delete Summoner");
    UIAlertAction *deleteSummonerAction = [UIAlertAction actionWithTitle:deleteSummonerTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        for (NSIndexPath *path in self.editingCells) {
            [del.managedObjectContext deleteObject:[self.dataDelegate objectInResultsAtIndexPath:path]];
        }
        
        [del saveContext];
        [self setEditing:NO];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [optionsDialog addAction:groupDialogDisplayAction];
    [optionsDialog addAction:groupRemoveAction];
    [optionsDialog addAction:deleteSummonerAction];
    [optionsDialog addAction:cancelAction];
    
    [self presentViewController:optionsDialog animated:YES completion:nil];
}

@end
