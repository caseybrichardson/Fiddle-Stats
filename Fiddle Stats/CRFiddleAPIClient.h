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
#import <UAObfuscatedString/UAObfuscatedString.h>

/* API URL Bases */
extern NSString * const RiotAPIBaseURL;
extern NSString * const RiotAPIIconURL;

/* API Endpoints */

/** Summoner Endpoint Format: Requires a region and a summoner name */
extern NSString * const RiotAPISummonerEndpoint;
/** Matches Endpoint Format: Requires a region and a summoner ID */
extern NSString * const RiotAPIMatchesEndpoint;
/** Match Endpoint Format: Requires a region and a match ID */
extern NSString * const RiotAPIMatchEndpoint;
/** Stats Endpoint Format: Requires a region and a summoner ID */
extern NSString * const RiotAPIStatsEndpoint;
/** Champion Endpoint Format: Requires a region and a champion ID */
extern NSString * const RiotAPIChampionEndpoint;
/** Item Endpoint Format: Requires a region and a item ID */
extern NSString * const RiotAPIItemEndpoint;
/** Version Endpoint Format: Requires a region */
extern NSString * const RiotAPIVersionEndpoint;

@interface CRFiddleAPIClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;
+ (NSString *)currentAPIVersionForRegion:(NSString *)region;
+ (void)currentAPIVersionForRegion:(NSString *)region block:(void (^)(NSArray *, NSError *))block;
- (PMKPromise *)riotRequestForEndpoint:(NSString *)riotAPIEndpoint parameters:(NSDictionary *)params;

@end
