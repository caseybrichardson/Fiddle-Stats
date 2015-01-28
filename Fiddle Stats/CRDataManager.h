//
//  CRDataManager.h
//
//  Created by Casey Richardson on 8/1/13.
//  Copyright (c) 2013 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRDataManager : NSObject

+ (BOOL)saveImage:(UIImage *)image withFilename:(NSString *)filename;
+ (UIImage *)imageForImageNamed:(NSString *)filename;
+ (BOOL)imageExistsWithFilename:(NSString *)filename;
+ (void)deleteAllImages;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+ (BOOL)appIsDebug;
+ (NSDictionary *)appEnvirons;
+ (id)envVarForKey:(id)key;

@end
