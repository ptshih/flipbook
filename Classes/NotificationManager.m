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
        [self downloadNotifications];
    }
    return self;
}

- (void)downloadNotifications {
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
        } else {
            // parse the json
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            if (!apiResponse) {
                // noop
            } else {
                if ([apiResponse isKindOfClass:[NSArray class]]) {
                    [blockSelf.notifications removeAllObjects];
                    [blockSelf.notifications addObjectsFromArray:apiResponse];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationManagerDidUpdate object:nil];
                } else {
                    // noop
                }
            }
        }
    }];
}

@end
