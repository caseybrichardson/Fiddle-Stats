//
//  Item.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 1/26/15.
//  Copyright (c) 2015 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSNumber * iItemID;
@property (nonatomic, retain) NSString * iName;
@property (nonatomic, retain) NSString * iPlaintext;
@property (nonatomic, retain) NSString * iDescription;
@property (nonatomic, retain) NSString * iImage;

@end
