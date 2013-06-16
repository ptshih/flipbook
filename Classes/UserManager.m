//
//  UserManager.m
//  Vip
//
//  Created by Peter Shih on 9/17/12.
//
//

#import "UserManager.h"

@interface UserManager ()


@end

@implementation UserManager

+ (id)sharedManager {
    static id sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(NSError *error, NSDictionary *user))completionHandler {
    // Request
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"application/json" forKey:@"Content-Type"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@{@"email": email, @"password": password} forKey:@"user"];
//    [parameters setObject:email forKey:@"email"];
//    [parameters setObject:password forKey:@"password"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/users/authenticate", API_BASE_URL];
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:headers parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        NSDictionary *user = nil;
        
        if (error) {
            completionHandler(error, user);
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                user = [apiResponse objectForKey:@"user"];

                [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"id"] forKey:@"celeryUserId"];
                [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"access_token"] forKey:@"celeryAccessToken"];
                [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"secret"] forKey:@"celerySecret"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserManagerDidLoginNotification object:nil userInfo:user];
            }
            
            completionHandler(error, user);
        }
    }];
}

- (void)signupWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(NSError *error, NSDictionary *user))completionHandler {
    
    return;
    
    // Request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"email"];
    [parameters setObject:password forKey:@"password"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/signup", API_BASE_URL];
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        NSDictionary *user = nil;
        
        if (error) {
            completionHandler(error, user);
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                user = apiResponse;
                
                [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"token"] forKey:@"abAccessToken"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserManagerDidLoginNotification object:nil userInfo:user];
            }

            completionHandler(error, user);
        }
    }];
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"celeryUserId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"celeryAccessToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"celerySecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserManagerDidLogoutNotification object:nil userInfo:nil];
}

- (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"celeryUserId"];
}

- (NSString *)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"celeryAccessToken"];
}

- (NSString *)secret {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"celerySecret"];
}


@end
