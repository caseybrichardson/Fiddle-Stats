//
//  FSMatchDataSource.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/23/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Match.h"

@protocol FSMatchDataSource <NSObject>

@required
- (Match *)match;

@end
