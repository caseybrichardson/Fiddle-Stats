//
//  Item+APIMethods.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/26/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import "Item+APIMethods.h"

@implementation Item (APIMethods)

- (Item *)initWithAttributes:(NSDictionary *)attributes {
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

+ (void)itemInformationFor:(NSInteger)itemID region:(NSString *)region withBlock:(void (^)(Item *item, NSError *error))block {
    
    // Caching for accessing the item data
    static NSCache *_itemCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _itemCache = [NSCache new];
    });
    
    if(itemID != 0) {
        Item *item = [_itemCache objectForKey:@(itemID)];
        
        if(!item) {
            
            item = [Item storedItemWithID:itemID];
            
            if(!item) {
                NSDictionary *requestParams = @{@"api_key": @"8ad21685-9e9f-4c18-9e72-30b8d598fce9", @"itemData": @"image"};
                NSString *url = [NSString stringWithFormat:@"/api/lol/static-data/%@/v1.2/item/%ld", region, ((long) itemID)];
                
                [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
                    NSDictionary *ItemDict = (NSDictionary *)responseObject;
                    
                    Item *item = [[Item alloc] initWithAttributes:ItemDict];
                    [_itemCache setObject:item forKey:@(itemID)];
                    
                    if(block) {
                        block(item, nil);
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"Fail: %@", error);
                    if(block) {
                        block(nil, error);
                    }
                }];
            } else {
                [_itemCache setObject:item forKey:@(itemID)];
                
                if(block) {
                    block(item, nil);
                }
            }
        } else {
            if(block) {
                block(item, nil);
            }
        }
    } else {
        block(nil, nil);
    }
}

@end
