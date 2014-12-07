//
//  Summoner+APIMethods.m
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Summoner+APIMethods.h"

@implementation Summoner (APIMethods)

- (Summoner *)initWithAttributes:(NSDictionary *)attributes inRegion:(NSString *)region {
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
    
    [del saveContext];
    
    NSLog(@"%@", attributes);
    
    return summoner;
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

+ (NSArray *)storedSummoners {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    NSArray *summoners = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!summoners) {
        return nil;
    }
    
    return summoners;
}

#pragma mark - Summoner API Calls

+ (void)summonerInformationFor:(NSString *)summonerName region:(NSString *)region withBlock:(void (^)(Summoner *, NSError *))block {
    NSDictionary *requestParams = @{@"api_key": @"8ad21685-9e9f-4c18-9e72-30b8d598fce9"};
    
    NSString *sanitizedName = [summonerName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"/api/lol/%@/v1.4/summoner/by-name/%@", region, sanitizedName];
    
    [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        Summoner *summoner = [[Summoner alloc] initWithAttributes:(NSDictionary *)[dict allValues].firstObject inRegion:region];
        
        if(block) {
            block(summoner, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", task.taskDescription);
        
        if(block) {
            block(nil, error);
        }
    }];
}

@end
