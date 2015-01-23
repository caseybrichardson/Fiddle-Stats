//
//  MatchParticipantIdentity.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchParticipant;

@interface MatchParticipantIdentity : NSManagedObject

@property (nonatomic, retain) NSNumber * mpiParticipantID;
@property (nonatomic, retain) NSNumber * mpiSummonerID;
@property (nonatomic, retain) NSString * mpiSummonerName;
@property (nonatomic, retain) NSNumber * mpiProfileIconID;
@property (nonatomic, retain) MatchParticipant *mpiParticipant;

@end
