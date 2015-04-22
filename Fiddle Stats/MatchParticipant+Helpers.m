//
//  MatchParticipant+Helpers.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "MatchParticipant+Helpers.h"

@implementation MatchParticipant (Helpers)

+ (MatchParticipant *)newParticipantWithAttributes:(NSDictionary *)attributes match:(Match *)match {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    MatchParticipant *participant = [MatchParticipant storedMatchParticipantForMatch:match participantID:[attributes[@"participantId"] integerValue]];
    
    if(!participant) {
        participant = [NSEntityDescription insertNewObjectForEntityForName:@"MatchParticipant" inManagedObjectContext:del.managedObjectContext];
    }
    
    participant.mpChampionID = attributes[@"championId"];
    participant.mpHighestAchievedSeasonTier = attributes[@"highestAchievedSeasonTier"];
    participant.mpParticipantID = attributes[@"participantId"];
    participant.mpSpellID1 = attributes[@"championId"];
    participant.mpSpellID2 = attributes[@"championId"];
    participant.mpTeamID = attributes[@"teamId"];
    
    participant.mpMatch = match;
    participant.mpParticipantStats = [MatchParticipantStats newStatsWithAttributes:attributes[@"stats"] participant:participant];
    
    return participant;
}

+ (MatchParticipant *)storedMatchParticipantForMatch:(Match *)match participantID:(NSInteger)participantID {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MatchParticipant"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mpMatch == %@ AND mpParticipantID == %ld", match, (long)participantID];
    
    [request setPredicate:predicate];
    
    NSArray *participants = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!participants) {
        return nil;
    }
    
    if([participants count] > 1) {
        for (int i = (int)[participants count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:participants[i]];
        }
    }
    
    return ([participants count] > 0 ? participants[0] : nil);
}

@end
