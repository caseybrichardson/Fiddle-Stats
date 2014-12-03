//
//  Champion+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/3/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Champion+APIMethods.h"

@implementation Champion (APIMethods)

- (Champion *)initWithAttributes:(NSDictionary *)attributes {
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

+ (void)championInformationFor:(NSInteger)champID region:(NSString *)region withBlock:(void (^)(Champion *, NSError *))block {
    static NSMutableDictionary *_champCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _champCache = [NSMutableDictionary dictionary];
    });
    
    Champion *champion = _champCache[@(champID)];
    
    if(!champion) {
        
        champion = [Champion storedChampionWithID:champID];
        
        if(!champion) {
            NSDictionary *requestParams = @{@"api_key": @"8ad21685-9e9f-4c18-9e72-30b8d598fce9"};
            NSString *url = [NSString stringWithFormat:@"/api/lol/static-data/%@/v1.2/champion/%ld", region, ((long) champID)];
            
            [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *championDict = (NSDictionary *)responseObject;
                
                Champion *champ = [[Champion alloc] initWithAttributes:championDict];
                _champCache[@(champID)] = champ;
                block(champ, nil);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Fail: %@", task.taskDescription);
                block(nil, error);
            }];
        } else {
            _champCache[@(champID)] = champion;
            block(champion, nil);
        }
    } else {
        block(champion, nil);
    }
}

@end
