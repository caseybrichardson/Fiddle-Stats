//
//  UIView+Gradient.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/23/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "UIView+Effects.h"

@implementation UIView (Effects)

- (void)addGradientWithColors:(NSArray *)colors {
    NSMutableArray *colorArray = [NSMutableArray array];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    for(UIColor *color in colors) {
        [colorArray addObject:((id)color.CGColor)];
    }
    
    [gradient setFrame:self.bounds];
    [gradient setColors:colorArray];
    [self.layer insertSublayer:gradient atIndex:0];
}

- (void)addHorizontalTilt:(CGFloat)x verticalTilt:(CGFloat)y
{
    UIInterpolatingMotionEffect *xAxis = nil;
    UIInterpolatingMotionEffect *yAxis = nil;
    
    if (x != 0.0)
    {
        xAxis = [[UIInterpolatingMotionEffect alloc]
                 initWithKeyPath:@"center.x"
                 type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-x];
        xAxis.maximumRelativeValue = [NSNumber numberWithFloat:x];
    }
    
    if (y != 0.0)
    {
        yAxis = [[UIInterpolatingMotionEffect alloc]
                 initWithKeyPath:@"center.y"
                 type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-y];
        yAxis.maximumRelativeValue = [NSNumber numberWithFloat:y];
    }
    
    if (xAxis || yAxis)
    {
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        NSMutableArray *effects = [NSMutableArray new];
        if (xAxis)
        {
            [effects addObject:xAxis];
        }
        
        if (yAxis)
        {
            [effects addObject:yAxis];
        }
        group.motionEffects = effects;
        [self addMotionEffect:group];
    }
}

@end
