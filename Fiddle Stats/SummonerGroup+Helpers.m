//
//  SummonerGroup+Helpers.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/8/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "SummonerGroup+Helpers.h"

@implementation SummonerGroup (Helpers)

- (SummonerGroup *)initWithTitle:(NSString *)title {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    SummonerGroup *group = [SummonerGroup storedSummonerGroupWithTitle:title];
    
    if(!group) {
        group = [NSEntityDescription insertNewObjectForEntityForName:@"SummonerGroup" inManagedObjectContext:del.managedObjectContext];
    }
    
    group.gGroupTitle = title;
    
    [del saveContext];
    
    return group;
}

+ (SummonerGroup *)storedSummonerGroupWithTitle:(NSString *)title {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SummonerGroup"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gGroupTitle == %@", title];
    
    [request setPredicate:predicate];
    
    NSArray *summonerGroups = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!summonerGroups) {
        return nil;
    }
    
    if([summonerGroups count] > 1) {
        for (int i = (int)[summonerGroups count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:summonerGroups[i]];
        }
    }
    
    return ([summonerGroups count] > 0 ? summonerGroups[0] : nil);
}

@end
