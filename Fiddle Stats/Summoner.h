//
//  Summoner.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/9/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "AppDelegate.h"

@class Match, SummonerGroup;

@interface Summoner : NSManagedObject

@property (nonatomic, retain) NSDate * sAddedOn;
@property (nonatomic, retain) NSNumber * sFavorited;
@property (nonatomic, retain) NSNumber * sID;
@property (nonatomic, retain) NSDate * sLastUpdated;
@property (nonatomic, retain) NSString * sName;
@property (nonatomic, retain) NSNumber * sProfileIconID;
@property (nonatomic, retain) NSString * sRegion;
@property (nonatomic, retain) NSNumber * sRevisionDate;
@property (nonatomic, retain) NSNumber * sSummonerLevel;
@property (nonatomic, retain) NSDate * sLocallyUpdated;
@property (nonatomic, retain) SummonerGroup *sGroup;
@property (nonatomic, retain) NSSet *sMatches;
@end

@interface Summoner (CoreDataGeneratedAccessors)

- (void)addSMatchesObject:(Match *)value;
- (void)removeSMatchesObject:(Match *)value;
- (void)addSMatches:(NSSet *)values;
- (void)removeSMatches:(NSSet *)values;

@end
