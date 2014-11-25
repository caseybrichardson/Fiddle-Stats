//
//  CRStarButton.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/24/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "CRStarView.h"

@implementation CRStarView

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.contentMode = UIViewContentModeRedraw;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(16, 0)];
    [bezierPath addLineToPoint: CGPointMake(11, 11)];
    [bezierPath addLineToPoint: CGPointMake(0, 11)];
    [bezierPath addLineToPoint: CGPointMake(9.5, 19)];
    [bezierPath addLineToPoint: CGPointMake(5, 32)];
    [bezierPath addLineToPoint: CGPointMake(16, 24)];
    [bezierPath addLineToPoint: CGPointMake(28, 32)];
    [bezierPath addLineToPoint: CGPointMake(23.5, 19)];
    [bezierPath addLineToPoint: CGPointMake(32, 11)];
    [bezierPath addLineToPoint: CGPointMake(21, 11)];
    [bezierPath addLineToPoint: CGPointMake(16, 0)];
    [bezierPath closePath];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    [_fillColor setFill];
    [bezierPath fill];
    [color setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
}

@end
