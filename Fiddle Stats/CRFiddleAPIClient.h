//
//  CRFiddleAPIClient.h
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <PromiseKit/PromiseKit.h>
#import <AFNetworking/AFNetworking.h>
#import <PromiseKit-AFNetworking/AFNetworking+PromiseKit.h>
#import <PromiseKit/NSURLConnection+PromiseKit.h>

/* API URL Bases */
extern NSString * const RiotAPIBaseURL;
extern NSString * const RiotAPIIconURL;

/* API Endpoints */
extern NSString * const RiotAPISummonerEndpoint;
extern NSString * const RiotAPIMatchEndpoint;
extern NSString * const RiotAPIStatsEndpoint;
extern NSString * const RiotAPIChampionEndpoint;
extern NSString * const RiotAPIItemEndpoint;

@interface CRFiddleAPIClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;
+ (NSString *)currentAPIVersionForRegion:(NSString *)region;
+ (void)currentAPIVersionForRegion:(NSString *)region block:(void (^)(NSArray *, NSError *))block;
- (PMKPromise *)riotRequestForEndpoint:(NSString *)riotAPIEndpoint parameters:(NSDictionary *)params;

@end
