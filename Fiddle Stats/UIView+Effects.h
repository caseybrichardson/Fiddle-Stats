//
//  UIView+Gradient.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/23/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Effects)

- (void)addGradientWithColors:(NSArray *)colors;
- (void)addHorizontalTilt:(CGFloat)x verticalTilt:(CGFloat)y;

@end
