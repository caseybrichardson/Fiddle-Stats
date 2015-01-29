//
//  MatchParticipantStats+Helpers.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "MatchParticipantStats.h"
#import "AppDelegate.h"

@interface MatchParticipantStats (Helpers)

- (MatchParticipantStats *)initWithAttributes:(NSDictionary *)attributes participant:(MatchParticipant *)participant;
- (NSNumber *)mpsTotalMinionsKilled;

+ (MatchParticipantStats *)storedMatchParticipantStatsForParticipant:(MatchParticipant *)participant;


@end
