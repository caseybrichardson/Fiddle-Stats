//
//  Tuple.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSDataPair.h"

@implementation FSDataPair

- (instancetype)initWithFirst:(id)first second:(id)second {
    self = [super init];
    
    if(self) {
        self.first = first;
        self.second = second;
    }
    
    return self;
}

- (NSArray *)pairAsArray {
    return @[self.first, self.second];
}

@end
