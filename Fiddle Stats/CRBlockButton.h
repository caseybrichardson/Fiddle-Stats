//
//  CRBlockButton.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/23/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRBlockButton;

typedef void(^CRBlockButtonTap)(CRBlockButton *);

@interface CRBlockButton : UIButton

@property (copy, nonatomic) CRBlockButtonTap tapBlock;

- (void)setTapBlock:(CRBlockButtonTap)tapBlock;
- (void)performTapBlock;

@end
