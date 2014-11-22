//
//  Summoner.h
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
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

@end
