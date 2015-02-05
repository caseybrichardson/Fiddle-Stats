//
//  NSObject+BlitMethodSwizzling.m
//  SecondScreen
//
//  Created by Alberto Denia Navarro on 22/07/13.
//  Copyright (c) 2013 edgar. All rights reserved.
//

#import "NSObject+BlitMethodSwizzling.h"

BOOL class_swizzleMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) {
    
    IMP imp = NULL;
    
    Method method = class_getInstanceMethod(class, original);
    
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(class, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    
    if (imp && store) {
        *store = imp;
    }
    
    return (imp != NULL);
}

@implementation NSObject (BlitMethodSwizzling)

+ (BOOL)swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store {
    return class_swizzleMethodAndStore(self, original, replacement, store);
}

@end
