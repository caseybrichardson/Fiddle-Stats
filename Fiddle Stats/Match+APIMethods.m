//
//  Match+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/22/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Match+APIMethods.h"

@implementation Match (APIMethods)

- (Match *)initWithAttributes:(NSDictionary *)attributes {
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
    match.mPlayerChampID = attributes[@"participants"][0][@"championId"];
    match.mParticipantID = attributes[@"participantIdentities"][0][@"player"][@"summonerId"];
    NSLog(@"%@", match.mParticipantID);
    
    [del saveContext];
    
    return match;
}

+ (NSArray *)storedMatchesForSummoner:(Summoner *)summoner {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Match"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mParticipantID == %@", summoner.sID];
    
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

    NSString *summonerName = summoner.sName;
    summonerName = [summonerName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSArray *matches = dict[@"matches"];
        
        NSMutableArray *parsedData = [NSMutableArray array];
        
        for (NSDictionary *match in matches) {
            [parsedData addObject:[[Match alloc] initWithAttributes:match]];
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

@end