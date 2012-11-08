//
//  AppDelegate.m
//  OSnap
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "AppDelegate.h"

#import "SectionsViewController.h"
#import "VenueViewController.h"

#import "PSZoomView.h"

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
        BOOL showTutorialFoursquare = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTutorialFoursquare"];
        
        // Version changed
        if (![lastVersion isEqualToString:currentVersion]) {
            // Set new version
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"appVersion"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showTutorialFoursquare"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showTutorialAirbrite"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSLog(@"Current Version: %@, Last Version: %@, Show Tutorial Search: %d", currentVersion, lastVersion, showTutorialFoursquare);
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

- (void)pushVenueWithId:(NSString *)venueId {
    VenueViewController *vc = [[VenueViewController alloc] initWithVenueId:venueId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupViewControllers {
    // Root view controller
    id controller = nil;
    controller = [[SectionsViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navigationController = [[PSNavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = self.navigationController;
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
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"4fda551a3f254b914082b05e2d8d76fd" liveIdentifier:@"4fda551a3f254b914082b05e2d8d76fd" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
    
    // Localytics
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"84958a8210d0dc2a5082943-09e67c0a-6273-11e1-1c6d-00a68a4c01fc"];
    // 84958a8210d0dc2a5082943-09e67c0a-6273-11e1-1c6d-00a68a4c01fc
    
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
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Start Reachability
    [PSReachabilityCenter defaultCenter];
    
    // PSLocationCenter set default behavior
    [[PSLocationCenter defaultCenter] resumeUpdates]; // start it
    
    // Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = WINDOW_BG_COLOR;
    [self.window makeKeyAndVisible];
    
    [self setupViewControllers];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    self.backgroundDate = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [Appirater appEnteredForeground:YES];
    
    [self purgeCacheIfNecessary:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    if (self.shouldReloadInterface) {
        self.shouldReloadInterface = NO;
        
        if ([[PSZoomView sharedView] isZooming]) {
            [[PSZoomView sharedView] reset];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
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
