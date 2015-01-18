//
//  FSSettingsTableViewController.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/1/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSSettingsTableViewController.h"

@interface FSSettingsTableViewController ()

@end

@implementation FSSettingsTableViewController

- (IBAction)closePressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)drawerPressed:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

@end
