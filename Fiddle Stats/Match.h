//
//  Match.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 2/19/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchParticipant, MatchTeam, Summoner;

@interface Match : NSManagedObject

@property (nonatomic, retain) NSNumber * mMapID;
@property (nonatomic, retain) NSNumber * mMatchCreation;
@property (nonatomic, retain) NSNumber * mMatchDuration;
@property (nonatomic, retain) NSNumber * mMatchID;
@property (nonatomic, retain) NSString * mMatchMode;
@property (nonatomic, retain) NSString * mMatchType;
@property (nonatomic, retain) NSString * mMatchVersion;
@property (nonatomic, retain) NSNumber * mParticipantID;
@property (nonatomic, retain) NSString * mPlatformID;
@property (nonatomic, retain) NSNumber * mPlayerChampID;
@property (nonatomic, retain) NSNumber * mPlayerWinner;
@property (nonatomic, retain) NSString * mQueueType;
@property (nonatomic, retain) NSString * mRegion;
@property (nonatomic, retain) NSString * mSeason;
@property (nonatomic, retain) NSNumber * mHasFullData;
@property (nonatomic, retain) NSSet *mMatchParticipants;
@property (nonatomic, retain) NSSet *mMatchSummoners;
@property (nonatomic, retain) NSSet *mMatchTeams;
@end

@interface Match (CoreDataGeneratedAccessors)

- (void)addMMatchParticipantsObject:(MatchParticipant *)value;
- (void)removeMMatchParticipantsObject:(MatchParticipant *)value;
- (void)addMMatchParticipants:(NSSet *)values;
- (void)removeMMatchParticipants:(NSSet *)values;

- (void)addMMatchSummonersObject:(Summoner *)value;
- (void)removeMMatchSummonersObject:(Summoner *)value;
- (void)addMMatchSummoners:(NSSet *)values;
- (void)removeMMatchSummoners:(NSSet *)values;

- (void)addMMatchTeamsObject:(MatchTeam *)value;
- (void)removeMMatchTeamsObject:(MatchTeam *)value;
- (void)addMMatchTeams:(NSSet *)values;
- (void)removeMMatchTeams:(NSSet *)values;

@end
