//
//  UIColor+AppColors.m
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 11/17/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "UIColor+AppColors.h"

@implementation UIColor (AppColors)

+ (UIColor *)fiddlesticksMainColor {
    return [UIColor colorWithRed:26.0f/255.0f green:43.0f/255.0f blue:48.0f/255.0f alpha:1.0f];
}

+ (UIColor *)fiddlesticksSecondaryColor {
    return [UIColor colorWithRed:192.0f/255.0f green:182.0f/255.0f blue:138.0f/255.0f alpha:1.0f];
}

+ (UIColor *)fiddlesticksTertiaryColor {
    return [UIColor colorWithRed:42.0f/255.0f green:163.0f/255.0f blue:144.0f/255.0f alpha:1.0f];
}

@end