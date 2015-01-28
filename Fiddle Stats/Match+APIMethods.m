//
//  Match+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/22/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Match+APIMethods.h"

@implementation Match (APIMethods)

- (Match *)initWithAttributes:(NSDictionary *)attributes forSummoner:(Summoner *)summoner {
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
        MatchParticipant *p = [[MatchParticipant alloc] initWithAttributes:participant match:match];
        [participants setObject:p forKey:p.mpParticipantID];
    }
    
    for (NSDictionary *identities in attributes[@"participantIdentities"]) {
        MatchParticipant *participant = participants[identities[@"participantId"]];
        if(participant) {
            MatchParticipantIdentity *i = [[MatchParticipantIdentity alloc] initWithAttributes:identities participant:participant];
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
        MatchParticipant *p = [[MatchParticipant alloc] initWithAttributes:participant match:self];
        [participants setObject:p forKey:p.mpParticipantID];
    }
    
    for (NSDictionary *identities in attributes[@"participantIdentities"]) {
        MatchParticipant *participant = participants[identities[@"participantId"]];
        if(participant) {
            MatchParticipantIdentity *i = [[MatchParticipantIdentity alloc] initWithAttributes:identities participant:participant];
            [i setMpiParticipant:participant];
        }
    }
    
    [del saveContext];
}

- (MatchParticipant *)matchParticipantForSummoner:(Summoner *)summoner {
    static NSCache *_cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[NSCache alloc] init];
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

+ (void)matchesInformationFor:(Summoner *)summoner withBlock:(void (^)(NSArray *, NSError *))block {
    NSDictionary *requestParams = @{@"api_key": @"8ad21685-9e9f-4c18-9e72-30b8d598fce9"};
    NSString *url = [NSString stringWithFormat:@"/api/lol/%@/v2.2/matchhistory/%lld", summoner.sRegion, [summoner.sID longLongValue]];
    
    [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSArray *matches = dict[@"matches"];
        
        NSMutableArray *parsedData = [NSMutableArray array];
        
        for (NSDictionary *match in matches) {
            [parsedData addObject:[[Match alloc] initWithAttributes:match forSummoner:summoner]];
        }
    
        if(block) {
            block(parsedData, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@", task.taskDescription);
        if(block) {
            block(nil, error);
        }
    }];
}

+ (void)expandedMatchInformationFor:(Match *)match withBlock:(void (^)(Match *, NSError *))block {
    NSDictionary *requestParams = @{@"api_key": @"8ad21685-9e9f-4c18-9e72-30b8d598fce9"};
    NSString *url = [NSString stringWithFormat:@"/api/lol/%@/v2.2/match/%lld", [match.mRegion lowercaseString], [match.mMatchID longLongValue]];
    
    [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *details = (NSDictionary *)responseObject;
        
        [match updateWithExtendedInformation:details];
        
        if(block) {
            block(match, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@", error);
        if(block) {
            block(nil, error);
        }
    }];
}

@end