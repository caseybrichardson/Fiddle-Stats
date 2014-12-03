//
//  Champion.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/3/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Champion : NSManagedObject

@property (nonatomic, retain) NSNumber * cID;
@property (nonatomic, retain) NSString * cTitle;
@property (nonatomic, retain) NSString * cName;
@property (nonatomic, retain) NSString * cKey;

@end
