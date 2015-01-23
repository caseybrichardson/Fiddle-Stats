//
//  MatchParticipantStats.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchParticipant;

@interface MatchParticipantStats : NSManagedObject

@property (nonatomic, retain) NSNumber * mpsItem0;
@property (nonatomic, retain) NSNumber * mpsItem1;
@property (nonatomic, retain) NSNumber * mpsItem2;
@property (nonatomic, retain) NSNumber * mpsItem3;
@property (nonatomic, retain) NSNumber * mpsItem4;
@property (nonatomic, retain) NSNumber * mpsItem5;
@property (nonatomic, retain) NSNumber * mpsItem6;
@property (nonatomic, retain) NSNumber * mpsGoldEarned;
@property (nonatomic, retain) NSNumber * mpsGoldSpent;
@property (nonatomic, retain) NSNumber * mpsInhibKills;
@property (nonatomic, retain) NSNumber * mpsTowerKills;
@property (nonatomic, retain) NSNumber * mpsDoubleKills;
@property (nonatomic, retain) NSNumber * mpsTripleKills;
@property (nonatomic, retain) NSNumber * mpsWardsKilled;
@property (nonatomic, retain) NSNumber * mpsWardsPlaced;
@property (nonatomic, retain) NSNumber * mpsQuadraKills;
@property (nonatomic, retain) NSNumber * mpsPentaKills;
@property (nonatomic, retain) NSNumber * mpsUnrealKills;
@property (nonatomic, retain) NSNumber * mpsVisionWardsBoughtInGame;
@property (nonatomic, retain) NSNumber * mpsWinner;
@property (nonatomic, retain) NSNumber * mpsFirstBloodKill;
@property (nonatomic, retain) NSNumber * mpsChampLevel;
@property (nonatomic, retain) NSNumber * mpsAssists;
@property (nonatomic, retain) NSNumber * mpsKills;
@property (nonatomic, retain) NSNumber * mpsKillingSprees;
@property (nonatomic, retain) NSNumber * mpsLargestMultiKill;
@property (nonatomic, retain) NSNumber * mpsMinionsKilled;
@property (nonatomic, retain) NSNumber * mpsNeutralMinionsKilled;
@property (nonatomic, retain) NSNumber * mpsTotalDamageDealtToChampions;
@property (nonatomic, retain) NSNumber * mpsTotalDamageDealt;
@property (nonatomic, retain) NSNumber * mpsMagicDamageDealt;
@property (nonatomic, retain) NSNumber * mpsMagicDamageDealtToChampions;
@property (nonatomic, retain) NSNumber * mpsPhysicalDamageDealt;
@property (nonatomic, retain) NSNumber * mpsPhysicalDamageDealtToChampions;
@property (nonatomic, retain) NSNumber * mpsTotalHeal;
@property (nonatomic, retain) NSNumber * mpsDeaths;
@property (nonatomic, retain) NSNumber * mpsFirstTowerKill;
@property (nonatomic, retain) NSNumber * mpsFirstInhibKill;
@property (nonatomic, retain) NSNumber * mpsTrueDamageDealt;
@property (nonatomic, retain) NSNumber * mpsTrueDamageDealToChampions;
@property (nonatomic, retain) MatchParticipant *mpsParticipant;

@end
