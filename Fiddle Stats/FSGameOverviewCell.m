//
//  FSGameOverviewCell.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "FSGameOverviewCell.h"

@implementation FSGameOverviewCell

- (IBAction)summonerPressed:(id)sender {
    if(self.delegate) {
        [self.delegate summonerPressed:((UIButton *) sender).tag overviewCell:self];
    }
}

@end
