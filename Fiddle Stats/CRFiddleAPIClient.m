//
//  CRFiddleAPIClient.m
//  Fiddle-ObjC
//
//  Created by Casey Richardson on 10/1/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "CRFiddleAPIClient.h"

/* API URL Bases */
NSString * const RiotAPIBaseURL = @"https://na.api.pvp.net";
NSString * const RiotAPIIconURL = @"https://avatar.leagueoflegends.com/";

/* API Endpoint Names */
NSString * const RiotAPISummonerEndpoint = @"Summoner-ByName";
NSString * const RiotAPISummonerUpdateEndpoint = @"Summoner-ByIDs";
NSString * const RiotAPIMatchesEndpoint = @"Match-List";
NSString * const RiotAPIMatchEndpoint = @"Match-Detail";
NSString * const RiotAPIStatsEndpoint = @"Stats-Summary";
NSString * const RiotAPIChampionEndpoint = @"Champion-Detail";
NSString * const RiotAPIItemEndpoint = @"Item-Detail";
NSString * const RiotAPIVersionEndpoint = @"Version";

/* Private URLs */
NSString * const MiddlemanURL = @"https://caseybrichardson.com";
NSString * const EndpointURL = @"/fiddle/api-middleman.php";

@interface CRFiddleAPIClient()

@property (strong, nonatomic) PMKPromise *apiVersionPromise;

@end

@implementation CRFiddleAPIClient

/* Private Init for Singleton */
- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        // Getting the api key from the server then fetching the version number
        self.apiVersionPromise = [self fetchVersionInRegion:@"na"];
    }
    
    return self;
}

/* Singleton Accessor */
+ (instancetype)sharedInstance {
    static CRFiddleAPIClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CRFiddleAPIClient alloc] initWithBaseURL:[NSURL URLWithString:MiddlemanURL]];
    });
    
    return _sharedClient;
}

- (PMKPromise *)currentVersion {
    return self.apiVersionPromise;
}

/* Performs a request to Riot's API */
- (PMKPromise *)riotRequestForEndpoint:(NSString *)riotAPIEndpoint parameters:(NSDictionary *)params {
    return [self riotRequestForEndpoint:riotAPIEndpoint region:@"na" parameters:params];
}

- (PMKPromise *)riotRequestForEndpoint:(NSString *)riotAPIEndpoint region:(NSString *)region parameters:(NSDictionary *)params {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableDictionary *fullParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [fullParameters setObject:riotAPIEndpoint forKey:@"endpoint_name"];
    [fullParameters setObject:region forKey:@"endpoint_region"];
    [fullParameters setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"app_version"];
    
    return [self GET:EndpointURL parameters:fullParameters].then(^(id response){
        return response;
    }).catch(^(AFHTTPRequestOperation *operation, NSError *error){
        return error;
    }).finally(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

/* Gets the API version from Riot's API */
- (PMKPromise *)fetchVersionInRegion:(NSString *)region {
    return [self riotRequestForEndpoint:RiotAPIVersionEndpoint parameters:@{}].then(^(id response) {
        NSArray *responseData = (NSArray *)response;
        return [responseData firstObject];
    }).catch(^(NSError *error){
        return error;
    });
}

@end
