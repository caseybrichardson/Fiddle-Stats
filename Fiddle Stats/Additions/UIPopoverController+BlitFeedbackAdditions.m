//
//  UIPopoverController+BlitFeedbackAdditions.m
//  SecondScreen
//
//  Created by Alberto Denia Navarro on 22/07/13.
//  Copyright (c) 2013 edgar. All rights reserved.
//

#import "UIPopoverController+BlitFeedbackAdditions.h"
#import "NSObject+BlitMethodSwizzling.h"
#import "BlitFeedback.h"

@implementation UIPopoverController (BlitFeedbackAdditions)

static void (*PresentPopoverFromRectPermittedArrowDirectionsAnimatedIMP)(id self, SEL _cmd, CGRect rect, UIView *view, UIPopoverArrowDirection arrowDirections, BOOL animated);
static void (*PresentPopoverFromBarButtonItemPermittedArrowDirectionsAnimatedIMP)(id self, SEL _cmd, UIBarButtonItem *barButtonItem, UIPopoverArrowDirection arrowDirections, BOOL animated);

static void BlitPresentPopoverFromRectPermittedArrowDirectionsAnimated(id self, SEL _cmd, CGRect rect, UIView *view, UIPopoverArrowDirection arrowDirections, BOOL animated) {
    
    // Call original implementation
    PresentPopoverFromRectPermittedArrowDirectionsAnimatedIMP(self, _cmd, rect, view, arrowDirections, animated);
    
    // Re-attach BlitFeedback to the key window
//    [[BlitFeedback sharedInstance] attach];
}

static void BlitPresentPopoverFromBarButtonItemPermittedArrowDirectionsAnimated(id self, SEL _cmd, UIBarButtonItem *barButtonItem, UIPopoverArrowDirection arrowDirections, BOOL animated) {
    
    // Call original implementation
    PresentPopoverFromBarButtonItemPermittedArrowDirectionsAnimatedIMP(self, _cmd, barButtonItem, arrowDirections, animated);
    
    // Re-attach BlitFeedback to the key window
//    [[BlitFeedback sharedInstance] attach];
}

+ (void)load {
    [self swizzle:@selector(presentPopoverFromRect:inView:permittedArrowDirections:animated:) with:(IMP)BlitPresentPopoverFromRectPermittedArrowDirectionsAnimated store:(IMP *)&PresentPopoverFromRectPermittedArrowDirectionsAnimatedIMP];
    [self swizzle:@selector(presentPopoverFromBarButtonItem:permittedArrowDirections:animated:) with:(IMP)BlitPresentPopoverFromBarButtonItemPermittedArrowDirectionsAnimated store:(IMP *)&PresentPopoverFromBarButtonItemPermittedArrowDirectionsAnimatedIMP];
}

@end
