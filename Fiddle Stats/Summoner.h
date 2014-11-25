//
//  Summoner.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/23/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Summoner : NSManagedObject

@property (nonatomic, retain) NSNumber * sID;
@property (nonatomic, retain) NSString * sName;
@property (nonatomic, retain) NSNumber * sProfileIconID;
@property (nonatomic, retain) NSNumber * sRevisionDate;
@property (nonatomic, retain) NSNumber * sSummonerLevel;
@property (nonatomic, retain) NSString * sRegion;
@property (nonatomic, retain) NSDate * sAddedOn;
@property (nonatomic, retain) NSDate * sLastUpdated;
@property (nonatomic, retain) NSNumber * sFavorited;

@end
