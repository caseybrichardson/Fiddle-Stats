//
//  CRFiddleAPIClient.m
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "CRFiddleAPIClient.h"

static NSString * const RiotAPIBaseURL = @"https://na.api.pvp.net";
static NSString * const RiotAPIIconURL = @"https://avatar.leagueoflegends.com/";

@implementation CRFiddleAPIClient

+ (instancetype)sharedInstance {
    static CRFiddleAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CRFiddleAPIClient alloc] initWithBaseURL:[NSURL URLWithString:RiotAPIBaseURL]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

@end
