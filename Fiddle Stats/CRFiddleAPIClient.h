//
//  CRFiddleAPIClient.h
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface CRFiddleAPIClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@end