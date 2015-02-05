//
//  NSObject+BlitMethodSwizzling.h
//  SecondScreen
//
//  Created by Alberto Denia Navarro on 22/07/13.
//  Copyright (c) 2013 edgar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef IMP *IMPPointer;

@interface NSObject (BlitMethodSwizzling)

+ (BOOL)swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store;

@end
