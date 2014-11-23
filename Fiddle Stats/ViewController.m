//
//  ViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/21/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *summoners;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.playerCollectionView registerNib:[UINib nibWithNibName:@"FSCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PlayerCell"];
    
    [self setSummoners:[Summoner storedSummoners]];
    [self.playerCollectionView reloadData];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:self.inputHolderView.bounds];
    [gradient setColors:@[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor]];
    [self.inputHolderView.layer insertSublayer:gradient atIndex:0];
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
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"sName" ascending:YES];
    
    [request setEntity:description];
    [request setSortDescriptors:@[descriptor]];
    [request setFetchBatchSize:100];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:del.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = controller;
    self.fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
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
            self.summoners = [Summoner storedSummoners];
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

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FSCollectionViewCell *cell = (FSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CGFloat navBarY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    CGFloat cardX = self.view.bounds.origin.x + 30;
    CGFloat cardY = navBarY + 10;
    CGFloat cardW = self.view.bounds.size.width - 60;
    CGFloat cardH = self.view.bounds.size.height - (navBarY * 2);
    
    RKCardView *cardView = [[RKCardView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    
    cardView.titleLabel.text = cell.nameLabel.text;
    
    cardView.coverImageView.image = [UIImage imageNamed:@"500x500"];
    cardView.profileImageView.image = cell.backgroundImage.image;
    [cardView addShadow];

    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(10, cardView.frame.origin.y + cardView.frame.size.height - cardView.frame.origin.y - 55, cardView.frame.size.width - 20, 45);
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 5;
    [button setTitle:@"Close" forState:UIControlStateNormal];
    [cardView addSubview:button];

    [cardView setAlpha:0];
    [UIView animateWithDuration:0.25f animations:^{
        cardView.alpha = 1.0f;
    }];

    [self.view addSubview:cardView];
}

@end
