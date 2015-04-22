//
//  Match+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/22/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Match+APIMethods.h"

@implementation Match (APIMethods)

+ (Match *)newMatchWithAttributes:(NSDictionary *)attributes forSummoner:(Summoner *)summoner {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    Match *match = [Match storedMatchWithID:[attributes[@"matchId"] integerValue]];
    
    if(!match) {
        match = [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:del.managedObjectContext];
    }
    
    match.mMatchVersion = attributes[@"matchVersion"];
    match.mRegion = attributes[@"region"];
    match.mMapID = attributes[@"mapId"];
    match.mSeason = attributes[@"season"];
    match.mQueueType = attributes[@"queueType"];
    match.mMatchDuration = attributes[@"matchDuration"];
    match.mMatchCreation = attributes[@"matchCreation"];
    match.mMatchType = attributes[@"matchType"];
    match.mMatchID = attributes[@"matchId"];
    match.mMatchMode = attributes[@"matchMode"];
    match.mPlatformID = attributes[@"platformId"];
    
    [match addMMatchSummonersObject:summoner];
    [summoner addSMatchesObject:match];
    
    NSMutableDictionary *participants = [NSMutableDictionary dictionary];
    for (NSDictionary *participant in attributes[@"participants"]) {
        MatchParticipant *p = [MatchParticipant newParticipantWithAttributes:participant match:match];
        [participants setObject:p forKey:p.mpParticipantID];
    }
    
    for (NSDictionary *identities in attributes[@"participantIdentities"]) {
        MatchParticipant *participant = participants[identities[@"participantId"]];
        if(participant) {
            MatchParticipantIdentity *i = [MatchParticipantIdentity newIdentityWithAttributes:identities participant:participant];
            [i setMpiParticipant:participant];
        }
    }
    
    [del saveContext];
    
    return match;
}

- (void)updateWithExtendedInformation:(NSDictionary *)attributes {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableDictionary *participants = [NSMutableDictionary dictionary];
    for (NSDictionary *participant in attributes[@"participants"]) {
        MatchParticipant *p = [MatchParticipant newParticipantWithAttributes:participant match:self];
        [participants setObject:p forKey:p.mpParticipantID];
    }
    
    for (NSDictionary *identities in attributes[@"participantIdentities"]) {
        MatchParticipant *participant = participants[identities[@"participantId"]];
        if(participant) {
            MatchParticipantIdentity *i = [MatchParticipantIdentity newIdentityWithAttributes:identities participant:participant];
            [i setMpiParticipant:participant];
        }
    }
    
    self.mHasFullData = @YES;
    
    [del saveContext];
}

- (MatchParticipant *)matchParticipantForSummoner:(Summoner *)summoner {
    static NSCache *_cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [NSCache new];
    });
    
    NSString *key = [NSString stringWithFormat:@"%@+%@", self.mMatchID, summoner.sID];
    
    if(![_cache objectForKey:key]) {
        NSSet *participants = [self.mMatchParticipants objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return ((MatchParticipant *) obj).mpParticipantIdentity.mpiSummonerID == summoner.sID;
        }];
        
        id obj = [participants anyObject];
        
        if(obj) {
            [_cache setObject:obj forKey:key];
        }
        
        return obj;
    } else {
        return [_cache objectForKey:key];
    }
}

+ (NSArray *)storedMatchesForSummoner:(Summoner *)summoner {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Match"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mMatchSummoners CONTAINS %@", summoner];
    
    [request setPredicate:predicate];
    
    NSArray *matches = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!matches) {
        return nil;
    }
    
    return matches;
}

+ (Match *)storedMatchWithID:(NSInteger)matchID {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Match"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mMatchID == %lld", matchID];
    
    [request setPredicate:predicate];
    
    NSArray *matches = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!matches) {
        return nil;
    }
    
    if([matches count] > 1) {
        for (int i = (int)[matches count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:matches[i]];
        }
    }
    
    return ([matches count] > 0 ? matches[0] : nil);
}

+ (PMKPromise *)matchesInformationFor:(Summoner *)summoner {
    NSString *url = [NSString stringWithFormat:RiotAPIMatchesEndpoint, summoner.sRegion, [summoner.sID longLongValue]];
    return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:url parameters:@{}].then(^(id response){
        NSDictionary *responseData = (NSDictionary *)response;
        NSArray *matches = responseData[@"matches"];
        
        NSMutableArray *parsedData = [NSMutableArray array];
        
        for (NSDictionary *match in matches) {
            [parsedData addObject:[Match newMatchWithAttributes:match forSummoner:summoner]];
        }
        
        return parsedData;
    });
}

+ (PMKPromise *)expandedMatchInformationFor:(Match *)match {
    
    if([match.mHasFullData boolValue]) {
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            fulfill(match);
        }];
    } else {
        NSString *url = [NSString stringWithFormat:RiotAPIMatchEndpoint, [match.mRegion lowercaseString], [match.mMatchID longLongValue]];
        return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:url parameters:@{}].then(^(id response){
            NSDictionary *responseData = (NSDictionary *)response;
            [match updateWithExtendedInformation:responseData];
            return match;
        }).catch(^(NSError *error){
            return error;
        });
    }
}

@end