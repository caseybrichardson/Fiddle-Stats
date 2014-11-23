//
//  UIView+Gradient.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/23/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "UIView+Gradient.h"

@implementation UIView (Gradient)

- (void)addGradientWithColors:(NSArray *)colors {
    NSMutableArray *colorArray = [NSMutableArray array];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    for(UIColor *color in colorArray) {
        [colorArray addObject:(id)color.CGColor];
    }
    
    [gradient setFrame:self.bounds];
    [gradient setColors:colorArray];
    [self.layer insertSublayer:gradient atIndex:0];
}

@end
