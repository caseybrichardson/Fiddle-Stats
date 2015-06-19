//
//  Item+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/26/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "Item+APIMethods.h"

@implementation Item (APIMethods)

+ (Item *)newItemWithAttributes:(NSDictionary *)attributes {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Item *item = [Item storedItemWithID:[attributes[@"id"] integerValue]];
    
    if(!item) {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:del.managedObjectContext];
    }
    
    item.iItemID = attributes[@"id"];
    item.iName = attributes[@"name"];
    item.iPlaintext = attributes[@"plaintext"];
    item.iDescription = attributes[@"description"];
    item.iImage = attributes[@"image"][@"full"];
    
    [del saveContext];
    
    return item;
}

+ (Item *)storedItemWithID:(NSInteger)itemID {
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iItemID == %d", itemID];
    
    [request setPredicate:predicate];
    
    NSArray *Items = [del.managedObjectContext executeFetchRequest:request error:&error];
    
    if(!Items) {
        return nil;
    }
    
    if([Items count] > 1) {
        for (int i = (int)[Items count] - 1; i > 0; i--)
        {
            [del.managedObjectContext deleteObject:Items[i]];
        }
    }
    
    return ([Items count] > 0 ? Items[0] : nil);
}

+ (PMKPromise *)itemInformationFor:(NSInteger)itemID region:(NSString *)region {
    
    /* Caching for accessing the item data */
    static NSCache *_itemCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _itemCache = [NSCache new];
    });
    
    Item *item = nil;
    
    /* Check if the item is an actual item (id != 0), if so, try and load from the cache */
    if(itemID != 0) {
        item = [_itemCache objectForKey:@(itemID)];
    } else {
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            reject([NSError errorWithDomain:@"com.caseybrichardon.fiddle.ItemNonExistent" code:0 userInfo:@{NSLocalizedDescriptionKey: @"ID Not An Item"}]);
        }];
    }
    
    /* If we still don't have the item, attempt to load from Core Data */
    if(!item) {
        item = [Item storedItemWithID:itemID];
    } else {
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            fulfill(item);
        }];
    }
    
    /* If we STILL don't have the item, make the Riot API request for it */
    if(!item) {
        NSDictionary *requestParameters = @{@"endpoint_item_id": @(itemID)};
        
        return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:RiotAPIItemEndpoint parameters:requestParameters].then(^(id response){
            NSDictionary *responseData = (NSDictionary *)response;
            
            Item *newItem = [Item newItemWithAttributes:responseData];
            [_itemCache setObject:newItem forKey:@(itemID)];
            
            return newItem;
        });
    } else {
        [_itemCache setObject:item forKey:@(itemID)];
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            fulfill(item);
        }];
    }
}

@end
