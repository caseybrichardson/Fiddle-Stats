//
//  SummonerGroup.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/8/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Summoner;

@interface SummonerGroup : NSManagedObject

@property (nonatomic, retain) NSString * gGroupTitle;
@property (nonatomic, retain) NSSet *gSummoners;

@end

@interface SummonerGroup (CoreDataGeneratedAccessors)

- (void)addGSummonersObject:(Summoner *)value;
- (void)removeGSummonersObject:(Summoner *)value;
- (void)addGSummoners:(NSSet *)values;
- (void)removeGSummoners:(NSSet *)values;

@end
