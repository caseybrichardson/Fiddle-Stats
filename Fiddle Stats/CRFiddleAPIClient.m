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

@interface CRFiddleAPIClient()

@property (strong, nonatomic) NSCache *versionCache;

@end

@implementation CRFiddleAPIClient

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if(self) {
        self.versionCache = [NSCache new];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static CRFiddleAPIClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CRFiddleAPIClient alloc] initWithBaseURL:[NSURL URLWithString:RiotAPIBaseURL]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

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
