//
//  MatchTeam.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Match;

@interface MatchTeam : NSManagedObject

@property (nonatomic, retain) NSNumber * mtBaronKills;
@property (nonatomic, retain) NSNumber * mtDragonKills;
@property (nonatomic, retain) NSNumber * mtFirstBaron;
@property (nonatomic, retain) NSNumber * mtFirstDragon;
@property (nonatomic, retain) NSNumber * mtFirstBlood;
@property (nonatomic, retain) NSNumber * mtFirstTower;
@property (nonatomic, retain) NSNumber * mtInhibNumber;
@property (nonatomic, retain) NSNumber * mtTeamID;
@property (nonatomic, retain) NSNumber * mtTowerNumber;
@property (nonatomic, retain) NSNumber * mtWinner;
@property (nonatomic, retain) Match *mtMatch;

@end
