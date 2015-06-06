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

/* API Endpoints */
NSString * const RiotAPISummonerEndpoint = @"/api/lol/%@/v1.4/summoner/by-name/%@";
NSString * const RiotAPISummonerUpdateEndpoint = @"/api/lol/%@/v1.4/summoner/%@";
NSString * const RiotAPIMatchesEndpoint = @"/api/lol/%@/v2.2/matchhistory/%lld";
NSString * const RiotAPIMatchEndpoint = @"/api/lol/%@/v2.2/match/%lld";
NSString * const RiotAPIStatsEndpoint = @"/api/lol/%@/v1.3/stats/by-summoner/%lld/ranked";
NSString * const RiotAPIChampionEndpoint = @"/api/lol/static-data/%@/v1.2/champion/%ld";
NSString * const RiotAPIItemEndpoint = @"/api/lol/static-data/%@/v1.2/item/%ld";
NSString * const RiotAPIVersionEndpoint = @"/api/lol/static-data/%@/v1.2/versions";

/* Private URLs */
NSString * const KeyURL = @"https://caseybrichardson.com/fiddle/getkey.php";

@interface CRFiddleAPIClient()

@property (strong, nonatomic) PMKPromise *apiKeyPromise;
@property (strong, nonatomic) PMKPromise *apiVersionPromise;

@end

@implementation CRFiddleAPIClient

/* Private Init for Singleton */
- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        // Getting the api key from the server then fetching the version number
        self.apiKeyPromise = [self fetchAPIKey];
        self.apiVersionPromise = [self fetchVersionInRegion:@"na"];
    }
    
    return self;
}

/* Singleton Accessor */
+ (instancetype)sharedInstance {
    static CRFiddleAPIClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CRFiddleAPIClient alloc] initWithBaseURL:[NSURL URLWithString:RiotAPIBaseURL]];
    });
    
    return _sharedClient;
}

- (PMKPromise *)currentVersion {
    return self.apiVersionPromise;
}

/* Performs a request to Riot's API */
- (PMKPromise *)riotRequestForEndpoint:(NSString *)riotAPIEndpoint parameters:(NSDictionary *)params{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableDictionary *fullParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    return self.apiKeyPromise.then(^(NSString *key){
        [fullParameters setObject:key forKey:@"api_key"];
    }).then(^{
        return [self GET:riotAPIEndpoint parameters:fullParameters].then(^(id response){
            return response;
        }).catch(^(NSError *error){
            return error;
        }).finally(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

/* Gets the API key from our server */
- (PMKPromise *)fetchAPIKey {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:KeyURL]];
    NSString *secret = Obfuscate.f.i.d.d.a.r.i.n.o._.i.s._.t.h.e._.b.e.s.t._._0._4.forward_slash._2._1.forward_slash._1._5;
    [request setValue:secret forHTTPHeaderField:@"Fiddlestats-Keyrequest"];
    
    return [NSURLConnection promise:request].then(^id(id response){
        NSDictionary *responseData = (NSDictionary *)response;
        NSString *apiKey = responseData[@"api_key"];
        
        if(apiKey) {
            return apiKey;
        } else {
            return [NSError errorWithDomain:@"com.caseybrichardson.fiddle.KeyFail" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Could not obtain API key"}];
        }
    }).catch(^(NSError *error){
        return error;
    }).finally(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

/* Gets the API version from Riot's API */
- (PMKPromise *)fetchVersionInRegion:(NSString *)region {
    NSString *url = [NSString stringWithFormat:RiotAPIVersionEndpoint, region];
    return self.apiKeyPromise.then(^{
        return [[CRFiddleAPIClient sharedInstance] riotRequestForEndpoint:url parameters:@{}].then(^(id response) {
            NSArray *responseData = (NSArray *)response;
            return [responseData firstObject];
        });
    });
}

@end
