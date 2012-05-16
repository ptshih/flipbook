//
//  NotificationManager.m
//  Lunchbox
//
//  Created by Peter Shih on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

@synthesize
notifications = _notifications;

+ (id)sharedManager {
    static id sharedManager;
    if (!sharedManager) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.notifications = [NSMutableArray array];
        
        // attempt to download new notifications
        [self downloadNotificationsWithCompletionBlock:NULL];
    }
    return self;
}

- (void)downloadNotificationsWithCompletionBlock:(NotificationManagerCompletionBlock)completionBlock {
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    
    // Only download if user has logged in already
    if (!fbId) return;
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/events", API_BASE_URL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fbId forKey:@"fbId"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            // noop
            if (completionBlock) {
                completionBlock(nil, error);
            }
        } else {
            // parse the json
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            if (!apiResponse) {
                // noop
                if (completionBlock) {
                    NSError *error = [NSError errorWithDomain:kErrorNotificationManager code:500 userInfo:nil];
                    completionBlock(nil, error);
                }
            } else {
                if ([apiResponse isKindOfClass:[NSArray class]]) {
                    [blockSelf.notifications removeAllObjects];
                    [blockSelf.notifications addObjectsFromArray:apiResponse];
                    if (completionBlock) {
                        completionBlock(blockSelf.notifications, nil);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationManagerDidUpdate object:nil];
                } else {
                    // noop
                    if (completionBlock) {
                        NSError *error = [NSError errorWithDomain:kErrorNotificationManager code:500 userInfo:nil];
                        completionBlock(nil, error);
                    }
                }
            }
        }
    }];
}

@end
