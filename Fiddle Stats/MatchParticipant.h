//
//  MatchParticipant.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Match, MatchParticipantIdentity, MatchParticipantStats;

@interface MatchParticipant : NSManagedObject

@property (nonatomic, retain) NSNumber * mpChampionID;
@property (nonatomic, retain) NSNumber * mpParticipantID;
@property (nonatomic, retain) NSNumber * mpSpellID1;
@property (nonatomic, retain) NSNumber * mpSpellID2;
@property (nonatomic, retain) NSNumber * mpTeamID;
@property (nonatomic, retain) NSString * mpHighestAchievedSeasonTier;
@property (nonatomic, retain) MatchParticipantStats *mpParticipantStats;
@property (nonatomic, retain) Match *mpMatch;
@property (nonatomic, retain) MatchParticipantIdentity *mpParticipantIdentity;

@end
