//
//  Champion+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/3/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Champion+APIMethods.h"

@implementation Champion (APIMethods)

+ (Champion *)newChampionWithAttributes:(NSDictionary *)attributes {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Champion *champ = [Champion storedChampionWithID:[attributes[@"id"] integerValue]];
    
    if(!champ) {
        champ = [NSEntityDescription insertNewObjectForEntityForName:@"Champion" inManagedObjectContext:del.managedObjectContext];
    }
    
    champ.cID = attributes[@"id"];
    champ.cTitle = attributes[@"title"];
    champ.cKey = attributes[@"key"];
    champ.cName = attributes[@"name"];
    
    [del saveContext];
    
    return champ;
}

+ (Champion *)storedChampionWithID:(NSInteger)championID {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Champion"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cID == %d", championID];
    
    [request setPredicate:predicate];
    
    NSArray *champions = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!champions) {
        return nil;
    }
    
    if([champions count] > 1) {
        for (int i = (int)[champions count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:champions[i]];
        }
    }
    
    return ([champions count] > 0 ? champions[0] : nil);
}

+ (PMKPromise *)championInformationFor:(NSInteger)champID region:(NSString *)region{
    
    // Caching for accessing the champ data
    static NSMutableDictionary *_champCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _champCache = [NSMutableDictionary new];
    });
    
    Champion *champ = nil;
    
    /* Check if the champ is an actual champion (id != 0), if so, try and load from the cache */
    if(champID != 0) {
        champ = [_champCache objectForKey:@(champID)];
    } else {
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            reject([NSError errorWithDomain:@"com.caseybrichardon.fiddle.ChampNonExistent" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Champ Not Real"}]);
        }];
    }
    
    /* If we still don't have the champ, attempt to load from Core Data */
    if(!champ) {
        champ = [Champion storedChampionWithID:champID];
    } else {
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            fulfill(champ);
        }];
    }
    
    /* If we STILL don't have the champ, make the Riot API request for it */
    if(!champ) {
        NSString *url = [NSString stringWithFormat:RiotAPIChampionEndpoint, region, ((long) champID)];
        
        return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:url parameters:@{}].then(^(id response){
            NSDictionary *responseData = (NSDictionary *)response;
            
            Champion *newChamp = [Champion newChampionWithAttributes:responseData];
            [_champCache setObject:newChamp forKey:@(champID)];
            
            return newChamp;
        });
    } else {
        [_champCache setObject:champ forKey:@(champID)];
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            fulfill(champ);
        }];
    }
}

@end
