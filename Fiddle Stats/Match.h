//
//  Match.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/8/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Summoner;

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
@property (nonatomic, retain) NSSet * mMatchParticipants;
@end

@interface Match (CoreDataGeneratedAccessors)

- (void)addMMatchParticipantsObject:(Summoner *)value;
- (void)removeMMatchParticipantsObject:(Summoner *)value;
- (void)addMMatchParticipants:(NSSet *)values;
- (void)removeMMatchParticipants:(NSSet *)values;

@end
