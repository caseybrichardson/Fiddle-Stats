//
//  MatchParticipant+Helpers.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "MatchParticipant.h"
#import "AppDelegate.h"
#import "MatchParticipantStats+Helpers.h"

@interface MatchParticipant (Helpers)

+ (MatchParticipant *)newParticipantWithAttributes:(NSDictionary *)attributes match:(Match *)match;
+ (MatchParticipant *)storedMatchParticipantForMatch:(Match *)match participantID:(NSInteger)participantID;

@end
