//
//  Summoner+APIMethods.h
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <PromiseKit/PromiseKit.h>
#import <PromiseKit-AFNetworking/AFNetworking+PromiseKit.h>

#import "Summoner.h"
#import "CRFiddleAPIClient.h"
#import "SummonerGroup.h"

@interface Summoner (APIMethods)

+ (instancetype)newWithAttributes:(NSDictionary *)attributes inRegion:(NSString *)region;

- (NSString *)groupName;

- (void)markSummonerUpdated;

- (NSURL *)summonerIconURL;

+ (PMKPromise *)summonerWithName:(NSString *)summonerName region:(NSString *)region;

+ (PMKPromise *)updateSummonersIn:(NSArray *)summoners;

@end
