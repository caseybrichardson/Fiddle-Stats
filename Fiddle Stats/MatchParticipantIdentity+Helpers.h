//
//  MatchParticipantIdentity+Helpers.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "MatchParticipantIdentity.h"
#import "AppDelegate.h"

@interface MatchParticipantIdentity (Helpers)

- (MatchParticipantIdentity *)initWithAttributes:(NSDictionary *)attributes participant:(MatchParticipant *)participant;
+ (MatchParticipantIdentity *)storedMatchParticipantIdentityForMatchParticipant:(MatchParticipant *)participant;

@end
