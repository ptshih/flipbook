//
//  AppDelegate.m
//  Grid
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "AppDelegate.h"
#import "ECSlidingViewController.h"
#import "WelcomeViewController.h"
#import "MenuViewController.h"


@interface AppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

+ (void)setupDefaults;

@end


@implementation AppDelegate

+ (void)initialize {
    [self setupDefaults];
}

#pragma mark - Initial Defaults

+ (void)setupDefaults {
    if ([self class] == [AppDelegate class]) {
        // Setup initial defaults
        NSString *initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
        assert(initialDefaultsPath != nil);
        
        NSDictionary *initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
        assert(initialDefaults != nil);
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
        
        //
        // Perform any version migrations here
        //
        
        NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"appVersion"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        // Version changed
        if (![lastVersion isEqualToString:currentVersion]) {
            // Set new version
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"appVersion"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showTutorial"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Reset Database
            [[PSDB sharedDatabase] resetDatabase];
        }
        
        NSLog(@"Current Version: %@, Last Version: %@", currentVersion, lastVersion);
    }
}

- (void)purgeCacheIfNecessary:(BOOL)force {
    self.foregroundDate = [NSDate date];
    
    NSTimeInterval secondsBackgrounded = [self.foregroundDate timeIntervalSinceDate:self.backgroundDate];
    // 5 min threshold
    if (secondsBackgrounded > kSecondsBackgroundedUntilStale || force) {
        self.shouldReloadInterface = YES;
        
        // Purge session cache
        [[PSURLCache sharedCache] purgeCacheWithCacheType:PSURLCacheTypeSession];
    }
}

#pragma mark - Global Statics


#pragma mark - Push Controller


- (void)setupViewControllers {
    ECSlidingViewController *svc = [[ECSlidingViewController alloc] initWithNibName:nil bundle:nil];
    
    // Root view controller
    UIViewController *rvc = nil;
    rvc = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
    
    UIViewController *mvc = nil;
    mvc = [[MenuViewController alloc] initWithNibName:nil bundle:nil];
    
    PSNavigationController *mnvc = [[PSNavigationController alloc] initWithRootViewController:mvc];
    
    svc.topViewController = rvc;
    svc.underLeftViewController = mnvc;
    
    self.window.rootViewController = svc;
    
    // SVC config
    [svc setAnchorRightRevealAmount:276.0];
    [svc setAnchorLeftRevealAmount:276.0];
    [svc setUnderLeftWidthLayout:ECFixedRevealWidth];
    [svc setUnderRightWidthLayout:ECFixedRevealWidth];
    svc.shouldAllowPanningPastAnchor = NO;
    svc.shouldAddPanGestureRecognizerToTopViewSnapshot = YES;
}

#pragma mark - Application Lifecycle

- (NSDictionary *)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    } else if ([self igHandleURL:url]) {
        
        return YES;
    } else {
        return [FBSession.activeSession handleOpenURL:url];
    }
}

- (BOOL)igHandleURL:(NSURL *)url {
    // If the URL's structure doesn't match the structure used for Instagram authorization, abort.
    NSString *igRedirectUri = @"ig933e9c75ab0c432fbe152fd3d645c4e8://authorize";
    if (![[url absoluteString] hasPrefix:igRedirectUri]) {
        return NO;
    }
    
    NSString *query = [url fragment];
    if (!query) {
        query = [url query];
    }
    
    NSDictionary *params = [self parseURLParams:query];
    NSString *accessToken = [params valueForKey:@"access_token"];
    
    // If the URL doesn't contain the access token, an error has occurred.
    if (!accessToken) {
        //        NSString *error = [params valueForKey:@"error"];
        
        NSString *errorReason = [params valueForKey:@"error_reason"];
        
        BOOL userDidCancel = [errorReason isEqualToString:@"user_denied"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"igAccessToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}


//- (BOOL)handleURL:(NSURL *)url {
//    NSLog(@"app handle open URL: %@", url);
//    
//    // Intercept for FB deep linking
//    NSString *scheme = url.scheme;
//    if ([scheme isEqualToString:@"fb456420417705188live"] || [scheme isEqualToString:@"fb456420417705188beta"] || [scheme isEqualToString:@"fb456420417705188pro"]) {
//        NSString *fragment = url.fragment;
//        NSDictionary *params = [self parseURLParams:fragment];
//        // Check if target URL exists
//        NSString *targetURLString = [params valueForKey:@"target_url"];
//        if (targetURLString) {
//            NSURL *targetURL = [NSURL URLWithString:targetURLString];
//            NSString *venueId = [targetURL lastPathComponent];
//            if (venueId) {
//                // Push venue
//                [self pushVenueWithId:venueId];
//                return YES;
//            } else {
////                return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
//            }
//        } else {
////            return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
//        }
//    } else {
//        return NO;
//    }
//}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return [self handleURL:url];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [self handleURL:url];
//}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef RELEASE
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"d312b005df71483556a50d2e78fc81b4" liveIdentifier:@"d312b005df71483556a50d2e78fc81b4" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
    
//    NSLog(@"Fonts: %@", [UIFont familyNames]);
//    NSLog(@"Proxima Nova: %@", [UIFont fontNamesForFamilyName:@"Proxima Nova"]);
//    NSLog(@"Proxima Nova: %@", [UIFont fontNamesForFamilyName:@"Proxima Nova Condensed"]);
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Localytics
//    [[LocalyticsSession sharedLocalyticsSession] startSession:@"c6bd712b99b9eb8f537c9bd-faa3f0ba-3e7f-11e2-693d-00ef75f32667"];
    
    // PSURLCache
    [[PSURLCache sharedCache] setNoCache:NO]; // This force NO CACHE
    [self purgeCacheIfNecessary:YES];
    
    // Appirater
    [Appirater appLaunched:YES];
    
    // AFNetworking
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // PSFacebookCenter
//    [PSFacebookCenter defaultCenter];
    
    // Prime Notification Manager
//    [NotificationManager sharedManager];
    
    // Start Reachability
    [PSReachabilityCenter defaultCenter];
    
    // PSLocationCenter set default behavior
//    [[PSLocationCenter defaultCenter] resumeUpdates]; // start it
    
    // Dropbox
//    DBSession *dbSession = [[DBSession alloc] initWithAppKey:@"b6fbfbwvpvy6xnt" appSecret:@"lju0v49xrosbmcs" root:kDBRootDropbox];
//    [DBSession setSharedSession:dbSession];
    
    
    // Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = WINDOW_BG_COLOR;
    [self.window makeKeyAndVisible];
    
    // PSDB
//    NSArray *items1 = @[
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Hand Soap", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Toilet Paper", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Bananas", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Beer, Soju", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Black Beans", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Quinoa", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Grilled Chicken Breast", @"status" : @"doing"}],
//    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Canned Tuna", @"status" : @"doing"}]
//    ];
//    
//    [[PSDB sharedDatabase] saveDocument:[NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Grocery List", @"timestamp": [[NSNumber numberWithDouble:[[NSDate date] millisecondsSince1970]] stringValue], @"items" : items1}] forKey:[NSString stringWithFormat:@"%0.f", [[NSDate date] millisecondsSince1970]] inCollection:@"lists" completionBlock:^(NSDictionary *document) {
//        
//    }];
    
    [self setupViewControllers];
    
    [[PSDB sharedDatabase] syncDatabaseWithRemote];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [[PSDB sharedDatabase] syncDatabase];
    
    self.backgroundDate = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] resume];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [Appirater appEnteredForeground:YES];
    
    [self purgeCacheIfNecessary:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] resume];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    if (self.shouldReloadInterface) {
        self.shouldReloadInterface = NO;

    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PSDB sharedDatabase] syncDatabase];
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef DISTRIBUTION
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

- (NSString *)customDeviceIdentifier {
#ifndef DISTRIBUTION
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

@end
