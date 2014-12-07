//
//  Tuple.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDataPair : NSObject

@property (strong, nonatomic) id first;
@property (strong, nonatomic) id second;

- (instancetype)initWithFirst:(id)first second:(id)second;

- (NSArray *)pairAsArray;

@end
