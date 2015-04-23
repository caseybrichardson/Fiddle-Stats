//
//  Champion+APIMethods.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 12/3/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Champion.h"
#import "AppDelegate.h"
#import "CRFiddleAPIClient.h"

@interface Champion (APIMethods)

+ (Champion *)newChampionWithAttributes:(NSDictionary *)attributes;
+ (PMKPromise *)championInformationFor:(NSInteger)champID region:(NSString *)region;

@end
