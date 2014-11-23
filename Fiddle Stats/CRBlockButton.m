//
//  CRBlockButton.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/23/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "CRBlockButton.h"

@implementation CRBlockButton

@synthesize tapBlock = _tapBlock;

- (void)setTapBlock:(CRBlockButtonTap)tapBlock {
    _tapBlock = [tapBlock copy];
    
    if([[self actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] > 0) {
        [self removeTarget:self action:@selector(performTapBlock) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addTarget:self action:@selector(performTapBlock) forControlEvents:UIControlEventTouchUpInside];
}

- (void)performTapBlock {
    if(self.tapBlock) {
        self.tapBlock(self);
    }
}

@end
