//
//  FSSummonerDataSource.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/2/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Summoner.h"

@protocol FSSummonerDataSource <NSObject>

@required
- (Summoner *)summoner;

@optional
- (NSArray *)summoners;

@end
