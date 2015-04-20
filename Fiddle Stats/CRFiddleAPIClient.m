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
NSString * const RiotAPIMatchEndpoint = @"/api/lol/%@/v2.2/matchhistory/%lld";
NSString * const RiotAPIStatsEndpoint = @"/api/lol/%@/v1.3/stats/by-summoner/%lld/ranked";
NSString * const RiotAPIChampionEndpoint = @"/api/lol/static-data/%@/v1.2/champion/%ld";
NSString * const RiotAPIItemEndpoint = @"/api/lol/static-data/%@/v1.2/item/%ld";

/* Private URLs */
NSString * const KeyURL = @"https://caseybrichardson.com/fiddle/getkey.php";

@interface CRFiddleAPIClient()

@property (strong, nonatomic) NSCache *versionCache;
@property (strong, nonatomic) NSString *apiKey;

@end

@implementation CRFiddleAPIClient

/* Private Init for Singleton */
- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        _versionCache = [NSCache new];
    }
    
    return self;
}

/* Singleton Accessor */
+ (instancetype)sharedInstance {
    static CRFiddleAPIClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CRFiddleAPIClient alloc] initWithBaseURL:[NSURL URLWithString:RiotAPIBaseURL]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [_sharedClient fetchAPIKey].then(^(NSString *apiKey) {
            _sharedClient.apiKey = apiKey;
        });
    });
    
    return _sharedClient;
}

/* Performs a request to Riot's API */
- (PMKPromise *)riotRequestForEndpoint:(NSString *)riotAPIEndpoint parameters:(NSDictionary *)params {
    NSMutableDictionary *fullParameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [fullParameters setObject:self.apiKey forKey:@"api_key"];
    
    return [self GET:riotAPIEndpoint parameters:fullParameters].then(^(id response){
        return response;
    }).catch(^(NSError *error){
        return error;
    });
}

/* Gets the API key from our server */
- (PMKPromise *)fetchAPIKey {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:KeyURL]];
    [request setValue:@"Some Value" forHTTPHeaderField:@"Fiddlestats-Keyrequest"];
    return [NSURLConnection promise:request].then(^(id response){
        NSDictionary *responseData = (NSDictionary *)response;
        NSString *apiKey = responseData[@"api_key"];
        
        if(apiKey) {
            return apiKey;
        } else {
            return @"Failure";
        }
    }).catch(^(NSError *error){
        return error;
    });
}

/* Gets the API version from Riot's API */
- (PMKPromise *)fetchVersion {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
    }];
}

/******************* LEGACY (GONNA GET DESTROYED) ***********************/
+ (NSString *)currentAPIVersionForRegion:(NSString *)region {
    NSString *version = [[[CRFiddleAPIClient sharedInstance].versionCache objectForKey:region] firstObject];
    if(version) {
        return version;
    } else {
        // TODO: Add last good version persistence to Info.plist
        return @"4.21.5";
    }
}

+ (void)currentAPIVersionForRegion:(NSString *)region block:(void (^)(NSArray *, NSError *))block {
    if(![[CRFiddleAPIClient sharedInstance].versionCache objectForKey:region]) {
        NSDictionary *requestParams = @{@"api_key": @"8ad21685-9e9f-4c18-9e72-30b8d598fce9"};
        
        NSString *url = [NSString stringWithFormat:@"/api/lol/static-data/%@/v1.2/versions", region];
        
        [[CRFiddleAPIClient sharedInstance] GET:url parameters:requestParams success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *versions = (NSArray *)responseObject;
            [[CRFiddleAPIClient sharedInstance].versionCache setObject:versions forKey:region];
            
            if(block) {
                block(versions, nil);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%ld", (long)((NSHTTPURLResponse *)task.response).statusCode);
            NSLog(@"Failing to fetch version data with error: %@", error.description);
            
            if(block) {
                block(nil, error);
            }
        }];
    } else {
        if(block) {
            block([[CRFiddleAPIClient sharedInstance].versionCache objectForKey:region], nil);
        }
    }
}

@end
