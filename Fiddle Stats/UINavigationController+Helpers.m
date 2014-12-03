//
//  UINavigationController+Helpers.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/2/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "UINavigationController+Helpers.h"

@implementation UINavigationController (Helpers)

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

@end
