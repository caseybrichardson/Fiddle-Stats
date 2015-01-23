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
@property (nonatomic, retain) MatchParticipant *mpsParticipant;

@end
