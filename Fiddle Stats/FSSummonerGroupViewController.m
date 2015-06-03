//
//  FSSummonerGroupTableViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/25/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSSummonerGroupViewController.h"

@interface FSSummonerGroupViewController ()

@property (strong, nonatomic) FSDataDelegate *dataDelegate;
@property (strong, nonatomic) NSCache *groupImageCache;
@property (strong, nonatomic) NSArray *editingSummoners;

@end

@implementation FSSummonerGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editingSummoners = [self.summonerDataSource summoners];
    self.groupImageCache = [NSCache new];
    [self initializeDataDelegate];
}

- (void)initializeDataDelegate {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.dataDelegate = [[FSDataDelegate alloc] initWithType:FSDataDelegateTypeTableView forView:self.summonerGroupTableView entityName:@"SummonerGroup" inContext:del.managedObjectContext];
    
    self.summonerGroupTableView.dataSource = self.dataDelegate;
    self.summonerGroupTableView.delegate = self.dataDelegate;
    self.summonerGroupTableView.allowsSelection = YES;
    self.summonerGroupTableView.allowsMultipleSelection = YES;
    
    FSDataPair *sort1 = [[FSDataPair alloc] initWithFirst:@"gGroupTitle" second:@YES];
    [self.dataDelegate setSortingKeyPaths:@[sort1]];
    [self.dataDelegate setReuseIdentifier:@"GroupCell"];
    [self.dataDelegate setStaticCellCount:1];
    
    __weak FSSummonerGroupViewController *sgvc = self;
    [self.dataDelegate setTableViewCellSource:^(UITableView *tableView, UITableViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        if(cell) {
            if(indexPath.row < [frc.fetchedObjects count]) {
                SummonerGroup *group = ((SummonerGroup *)[frc objectAtIndexPath:indexPath]);
                NSString *groupName = group.gGroupTitle;
                [cell.textLabel setText:groupName];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"Players: %lu", (unsigned long)[group.gSummoners count]]];
                [cell.imageView setFrame:CGRectMake(0, 0, 60, 60)];
                
                UIImage *image = [sgvc.groupImageCache objectForKey:groupName];
                if(image) {
                    [cell.imageView setImage:image];
                } else {
                    [cell.imageView setImageWithString:groupName];
                    [sgvc.groupImageCache setObject:cell.imageView.image forKey:groupName];
                }
            } else {
                [cell.textLabel setText:@"New Group..."];
                [cell.detailTextLabel setText:@""];
                [cell.imageView setFrame:CGRectMake(0, 0, 60, 60)];
                UIImage *image = [UIImage imageNamed:@"Plus"];
                [cell.imageView setImage:image];
            }
        }
    }];
    
    [self.dataDelegate setItemSelectionHandler:^(id view, NSFetchedResultsController *frc, NSIndexPath *indexPath) {
        UITableViewCell *cell = [((UITableView *)view) cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
        
        if(indexPath.row < [frc.fetchedObjects count]) {
            AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSMutableArray *groups = [NSMutableArray array];
            for (Summoner *s in [sgvc.summonerDataSource summoners]) {
                if(s.sGroup) {
                    [groups addObject:s.sGroup];
                }
                
                s.sGroup = [frc objectAtIndexPath:indexPath];
            }
            
            for(SummonerGroup *g in groups) {
                if([g.gSummoners count] == 0) {
                    [del.managedObjectContext deleteObject:g];
                }
            }
            
            sgvc.completion(YES);
            [sgvc dismissViewControllerAnimated:YES completion:nil];
        } else {
            [sgvc showGroupDialog];
        }
    }];
    
    [self.dataDelegate performFetch];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setCompletion:(FSModalCompleted)completion {
    _completion = completion;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (IBAction)cancelPressed:(id)sender {
    self.completion(NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showGroupDialog {
    UIAlertController *groupDialog = [UIAlertController alertControllerWithTitle:@"Group" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *groupAddAction = [UIAlertAction actionWithTitle:@"Set Group" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        SummonerGroup *group = [SummonerGroup newGroupWithTitle:((UITextField *)groupDialog.textFields[0]).text];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [imageView setImageWithString:group.gGroupTitle];
        [self.groupImageCache setObject:imageView.image forKey:group.gGroupTitle];
        
        for(Summoner *summoner in self.editingSummoners) {
            [group addGSummonersObject:summoner];
        }
        
        self.completion(YES);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [groupDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Group Name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [groupDialog addAction:groupAddAction];
    [groupDialog addAction:cancelAction];
    
    [self presentViewController:groupDialog animated:YES completion:nil];
}

@end
