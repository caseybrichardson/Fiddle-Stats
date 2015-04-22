//
//  MatchParticipantStats+Helpers.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "MatchParticipantStats+Helpers.h"

@implementation MatchParticipantStats (Helpers)

+ (MatchParticipantStats *)newStatsWithAttributes:(NSDictionary *)attributes participant:(MatchParticipant *)participant {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    MatchParticipantStats *stats = [MatchParticipantStats storedMatchParticipantStatsForParticipant:participant];
    
    if(!stats) {
        stats = [NSEntityDescription insertNewObjectForEntityForName:@"MatchParticipantStats" inManagedObjectContext:del.managedObjectContext];
    }
    
    stats.mpsItem0 = attributes[@"item0"];
    stats.mpsItem1 = attributes[@"item1"];
    stats.mpsItem2 = attributes[@"item2"];
    stats.mpsItem3 = attributes[@"item3"];
    stats.mpsItem4 = attributes[@"item4"];
    stats.mpsItem5 = attributes[@"item5"];
    stats.mpsItem6 = attributes[@"item6"];
    stats.mpsWinner = attributes[@"winner"];
    stats.mpsKills = attributes[@"kills"];
    stats.mpsDeaths = attributes[@"deaths"];
    stats.mpsAssists = attributes[@"assists"];
    stats.mpsGoldEarned = attributes[@"goldEarned"];
    stats.mpsGoldSpent = attributes[@"goldSpent"];
    stats.mpsTotalHeal = attributes[@"totalHeal"];
    stats.mpsChampLevel = attributes[@"champLevel"];
    stats.mpsInhibKills = attributes[@"inhibitorKills"];
    stats.mpsTowerKills = attributes[@"towerKills"];
    stats.mpsDoubleKills = attributes[@"doubleKills"];
    stats.mpsTripleKills = attributes[@"tripleKills"];
    stats.mpsQuadraKills = attributes[@"quadraKills"];
    stats.mpsPentaKills = attributes[@"pentaKills"];
    stats.mpsUnrealKills = attributes[@"unrealKills"];
    stats.mpsTotalDamageDealt = attributes[@"totalDamageDealt"];
    stats.mpsTotalDamageDealtToChampions = attributes[@"totalDamageDealtToChampions"];
    stats.mpsMagicDamageDealt = attributes[@"magicDamage"];
    stats.mpsMagicDamageDealtToChampions = attributes[@"magicDamageDealtToChampions"];
    stats.mpsPhysicalDamageDealt = attributes[@"physicalDamageDealt"];
    stats.mpsPhysicalDamageDealtToChampions = attributes[@"physicalDamageDealtToChampions"];
    stats.mpsTrueDamageDealt = attributes[@"trueDamageDealt"];
    stats.mpsTrueDamageDealToChampions = attributes[@"trueDamageDealtToChampions"];
    stats.mpsKillingSprees = attributes[@"killingSprees"];
    stats.mpsWardsKilled = attributes[@"wardsKilled"];
    stats.mpsWardsPlaced = attributes[@"wardsPlaced"];
    stats.mpsMinionsKilled = attributes[@"minionsKilled"];
    stats.mpsFirstBloodKill = attributes[@"firstBloodKill"];
    stats.mpsFirstInhibKill = attributes[@"firstInhibitorKill"];
    stats.mpsFirstTowerKill = attributes[@"firstTowerKill"];
    stats.mpsLargestMultiKill = attributes[@"largestMultiKill"];
    stats.mpsNeutralMinionsKilled = attributes[@"neutralMinionsKilled"];
    stats.mpsVisionWardsBoughtInGame = attributes[@"visionWardsBoughtInGame"];
    
    stats.mpsParticipant = participant;
    
    return stats;
}

- (NSNumber *)mpsTotalMinionsKilled {
    return @([self.mpsMinionsKilled integerValue] + [self.mpsNeutralMinionsKilled integerValue]);
}

+ (MatchParticipantStats *)storedMatchParticipantStatsForParticipant:(MatchParticipant *)participant {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MatchParticipantStats"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mpsParticipant == %@", participant];
    
    [request setPredicate:predicate];
    
    NSArray *stats = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!stats) {
        return nil;
    }
    
    if([stats count] > 1) {
        for (int i = (int)[stats count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:stats[i]];
        }
    }
    
    return ([stats count] > 0 ? stats[0] : nil);
}

@end
