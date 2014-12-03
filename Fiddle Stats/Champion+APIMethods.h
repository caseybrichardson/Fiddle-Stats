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

- (Champion *)initWithAttributes:(NSDictionary *)attributes;

+ (void)championInformationFor:(NSInteger)champID region:(NSString *)region withBlock:(void (^)(Champion *, NSError *))block;

@end
