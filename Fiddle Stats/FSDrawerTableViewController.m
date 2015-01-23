//
//  FSDrawerTableViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/18/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSDrawerTableViewController.h"

@interface FSDrawerTableViewController ()

@end

@implementation FSDrawerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc;
    
    switch (indexPath.row) {
        case 0:
            vc = [[AppDelegate globalDelegate] summonersViewController];
            break;
        case 1:
            vc = nil;
            break;
        case 2:
            vc = nil;
            break;
        case 3:
            vc = nil;
            break;
        case 4:
            vc = [[AppDelegate globalDelegate] settingsViewController];
            break;
        default:
            break;
    }
    
    if(vc) {
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:vc];
    }
    
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

@end
