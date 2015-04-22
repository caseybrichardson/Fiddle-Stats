//
//  SummonerGroup+Helpers.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/8/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "SummonerGroup.h"
#import "AppDelegate.h"

@interface SummonerGroup (Helpers)

+ (SummonerGroup *)newGroupWithTitle:(NSString *)title;
+ (SummonerGroup *)storedSummonerGroupWithTitle:(NSString *)title;

@end
