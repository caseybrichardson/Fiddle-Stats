//
//  Match+APIMethods.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/22/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "Match.h"
#import "AppDelegate.h"
#import "Summoner+APIMethods.h"

@interface Match (APIMethods)

- (Match *)initWithAttributes:(NSDictionary *)attributes;

+ (Match *)storedMatchWithID:(NSInteger)matchID;
+ (void)matchesInformationFor:(Summoner *)summoner withBlock:(void (^)(NSArray *, NSError *))block;

@end
