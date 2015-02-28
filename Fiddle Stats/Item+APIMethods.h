//
//  Item+APIMethods.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/26/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <DFImageManager/DFImageManager.h>

#import "Item.h"
#import "AppDelegate.h"
#import "CRFiddleAPIClient.h"
#import "CRDataManager.h"

@interface Item (APIMethods)

- (Item *)initWithAttributes:(NSDictionary *)attributes;

+ (Item *)storedItemWithID:(NSInteger)itemID;
+ (void)itemInformationFor:(NSInteger)itemID region:(NSString *)region withBlock:(void (^)(Item *item, NSError *error))block;
+ (void)downloadItemImageForItem:(Item *)item withBlock:(void (^)(UIImage *image, NSError *error))block;

@end
