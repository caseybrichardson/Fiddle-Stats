//
//  MatchParticipantIdentity+Helpers.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/22/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "MatchParticipantIdentity+Helpers.h"

@implementation MatchParticipantIdentity (Helpers)

+ (MatchParticipantIdentity *)newIdentityWithAttributes:(NSDictionary *)attributes participant:(MatchParticipant *)participant {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    MatchParticipantIdentity *identity = [MatchParticipantIdentity storedMatchParticipantIdentityForMatchParticipant:participant];
    
    if(!identity) {
        identity = [NSEntityDescription insertNewObjectForEntityForName:@"MatchParticipantIdentity" inManagedObjectContext:del.managedObjectContext];
    }
    
    identity.mpiParticipantID = attributes[@"participantId"];
    identity.mpiProfileIconID = attributes[@"player"][@"profileIcon"];
    identity.mpiSummonerID = attributes[@"player"][@"summonerId"];
    identity.mpiSummonerName = attributes[@"player"][@"summonerName"];
    
    return identity;
}

+ (MatchParticipantIdentity *)storedMatchParticipantIdentityForMatchParticipant:(MatchParticipant *)participant {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MatchParticipantIdentity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mpiParticipant == %@", participant];
    
    [request setPredicate:predicate];
    
    NSArray *identities = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!identities) {
        return nil;
    }
    
    if([identities count] > 1) {
        for (int i = (int)[identities count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:identities[i]];
        }
    }
    
    return ([identities count] > 0 ? identities[0] : nil);
}

@end
