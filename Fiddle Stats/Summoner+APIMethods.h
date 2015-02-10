//
//  Summoner+APIMethods.h
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Summoner.h"
#import "CRFiddleAPIClient.h"
#import "SummonerGroup.h"

@interface Summoner (APIMethods)

- (instancetype)initWithAttributes:(NSDictionary *)attributes inRegion:(NSString *)region;
- (NSString *)groupName;
- (void)markSummonerUpdated;

+ (NSArray *)storedSummoners;
+ (void)summonerInformationFor:(NSString *)summonerName region:(NSString *)region withBlock:(void (^)(Summoner *summoner, NSError *error))block;

@end
