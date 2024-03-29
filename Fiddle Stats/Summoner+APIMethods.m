//
//  Summoner+APIMethods.m
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Summoner+APIMethods.h"

@implementation Summoner (APIMethods)

+ (Summoner *)newWithAttributes:(NSDictionary *)attributes inRegion:(NSString *)region {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    Summoner *summoner = [Summoner storedSummonerWithID:[attributes[@"id"] integerValue]];
    
    if(!summoner) {
        summoner = [NSEntityDescription insertNewObjectForEntityForName:@"Summoner" inManagedObjectContext:del.managedObjectContext];
    }
    
    summoner.sID = attributes[@"id"];
    summoner.sName = attributes[@"name"];
    summoner.sProfileIconID = attributes[@"profileIconId"];
    summoner.sRevisionDate = attributes[@"revisionDate"];
    summoner.sSummonerLevel = attributes[@"summonerLevel"];
    
    summoner.sRegion = region;
    summoner.sAddedOn = [NSDate date];
    summoner.sLastUpdated = [NSDate date];
    summoner.sLocallyUpdated = [NSDate date];
    
    [del saveContext];
    
    return summoner;
}

- (NSString *)groupName {
    return (self.sGroup ? self.sGroup.gGroupTitle : @"No Group");
}

- (void)markSummonerUpdated {
    self.sLocallyUpdated = [NSDate date];
}

#pragma mark - Core Data Retrieval

+ (Summoner *)storedSummonerWithID:(NSInteger)summonerID {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sID == %d", summonerID];
    
    [request setPredicate:predicate];
    
    NSArray *summoners = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!summoners) {
        return nil;
    }
    
    if([summoners count] > 1) {
        for (int i = (int)[summoners count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:summoners[i]];
        }
    }
    
    return ([summoners count] > 0 ? summoners[0] : nil);
}

#pragma mark - Summoner API Calls

+ (PMKPromise *)summonerWithName:(NSString *)summonerName region:(NSString *)region {
    NSString *sanitizedName = [summonerName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSDictionary *params = @{@"endpoint_summoner_name": sanitizedName};
    
    return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:RiotAPISummonerEndpoint parameters:params].then(^(id response){
        NSDictionary *responseData = (NSDictionary *)response;
        return [Summoner newWithAttributes:[[responseData allValues] firstObject] inRegion:region];
    }).catch(^(NSError *error){
        return error;
    });
}

+ (PMKPromise *)updateSummonersIn:(NSArray *)summoners {
    NSString *sanitizedIDs = [[[summoners valueForKey:@"sID"] componentsJoinedByString:@","] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *region = ((Summoner *)[summoners firstObject]).sRegion;
    NSDictionary *params = @{@"endpoint_summoner_ids": sanitizedIDs};
    
    return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:RiotAPISummonerUpdateEndpoint parameters:params].then(^(id response){
        NSDictionary *responseData = (NSDictionary *)response;
        
        for(NSString *summoner in responseData) {
            [Summoner newWithAttributes:responseData[summoner] inRegion:region];
        }
        
        return;
    }).catch(^(NSError *error){
        return error;
    });
}

@end
