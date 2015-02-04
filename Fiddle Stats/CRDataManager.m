
//
//  CRDataManager.m
//
//  Created by Casey Richardson on 8/1/13.
//  Copyright (c) 2013 Casey Richardson. All rights reserved.
//

#import "CRDataManager.h"

@interface CRDataManager()

+ (NSURL *)pathToTmp;

@end

@implementation CRDataManager

+ (NSURL *)pathToTmp {
    return [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
}

+ (BOOL)saveImage:(UIImage *)image withFilename:(NSString *)filename {
    if(![CRDataManager imageExistsWithFilename:filename])
        return [UIImagePNGRepresentation(image) writeToFile:[[[CRDataManager pathToTmp] URLByAppendingPathComponent:filename] path] atomically:YES];
    else
        return YES;
}

+ (UIImage *)imageForImageNamed:(NSString *)filename {
    static NSCache *cache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
        [cache setCountLimit:50];
    });
    
    if([cache objectForKey:filename])
    {
        return [cache objectForKey:filename];
    }
    else
    {
        UIImage *image = [UIImage imageWithContentsOfFile:[[[CRDataManager pathToTmp] URLByAppendingPathComponent:filename] path]];
        
        if(image)
        {
            [cache setObject:image forKey:filename];
            return [cache objectForKey:filename];
        }
        else
        {
            return nil;
        }
    }
}

+ (BOOL)imageExistsWithFilename:(NSString *)filename {
    static NSCache *cache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
    });
    
    if(filename) {
        NSString *url = [[[CRDataManager pathToTmp] URLByAppendingPathComponent:filename] path];
        
        if([cache objectForKey:url]) {
            BOOL value = [[cache objectForKey:url] boolValue];
            
            if(value) {
                return value;
            } else {
                BOOL newValue = [[NSFileManager defaultManager] fileExistsAtPath:url];
                [cache setObject:@(newValue) forKey:url];
                return newValue;
            }
        } else {
            BOOL newValue = [[NSFileManager defaultManager] fileExistsAtPath:url];
            [cache setObject:@(newValue) forKey:url];
            return newValue;
        }
    } else {
        return NO;
    }
}

+ (void)deleteAllImages {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    
    for(NSString *file in [manager contentsOfDirectoryAtPath:[[CRDataManager pathToTmp] path] error:&error]) {
        BOOL success = [manager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [[CRDataManager pathToTmp] path], file] error:&error];
        
        if(!success || error) {
            continue;
        }
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 15, 80);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (BOOL)appIsDebug {
    return [[[NSProcessInfo processInfo] environment][@"debug"] boolValue];
}

+ (NSDictionary *)appEnvirons {
    return [[NSProcessInfo processInfo] environment];
}

+ (id)envVarForKey:(id)key {
    return [[[NSProcessInfo processInfo] environment] objectForKey:key];
}

@end
