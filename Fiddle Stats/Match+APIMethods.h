//
//  Match+APIMethods.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/22/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Match.h"
#import "AppDelegate.h"
#import "Summoner+APIMethods.h"
#import "MatchParticipantIdentity+Helpers.h"
#import "MatchParticipant+Helpers.h"

@interface Match (APIMethods)

+ (Match *)newMatchWithAttributes:(NSDictionary *)attributes forSummoner:(Summoner *)summoner;
- (MatchParticipant *)matchParticipantForSummoner:(Summoner *)summoner;


+ (NSArray *)storedMatchesForSummoner:(Summoner *)summoner;
+ (Match *)storedMatchWithID:(NSInteger)matchID;
+ (PMKPromise *)matchesInformationFor:(Summoner *)summoner;
+ (PMKPromise *)expandedMatchInformationFor:(Match *)match;

@end
