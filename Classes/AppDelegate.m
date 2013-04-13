//
//  AppDelegate.m
//  Grid
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "WelcomeViewController.h"
#import "DashboardViewController.h"

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

#pragma mark - User Login

- (void)userDidLogin:(NSNotification *)notification {
    [self setupViewControllers];
}

- (void)setupViewControllers {
    // Welcome or Already Logged In
    if ([[UserManager sharedManager] accessToken] && [[UserManager sharedManager] secret]) {
        ECSlidingViewController *svc = [[ECSlidingViewController alloc] initWithNibName:nil bundle:nil];
        MenuViewController *mvc = [[MenuViewController alloc] initWithNibName:nil bundle:nil];
        DashboardViewController *tvc = [[DashboardViewController alloc] initWithNibName:nil bundle:nil];
        
        svc.topViewController = [[PSNavigationController alloc] initWithRootViewController:tvc];
        svc.underLeftViewController = mvc;
        
        // SVC config
        [svc setAnchorRightRevealAmount:100.0];
        [svc setAnchorLeftRevealAmount:100.0];
        [svc setUnderLeftWidthLayout:ECFixedRevealWidth];
        [svc setUnderRightWidthLayout:ECFixedRevealWidth];
        svc.shouldAllowPanningPastAnchor = NO;
        svc.shouldAddPanGestureRecognizerToTopViewSnapshot = YES;
        
        self.window.rootViewController = svc;
    } else {
        WelcomeViewController *wvc = [[WelcomeViewController alloc] initWithNibName:nil bundle:nil];
        self.window.rootViewController = wvc;
    }
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef RELEASE
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"d3b6ecaff7e9c679047cf07fe8482241" liveIdentifier:@"d3b6ecaff7e9c679047cf07fe8482241" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
    
//    NSLog(@"Fonts: %@", [UIFont familyNames]);
    NSLog(@"Proxima Nova: %@", [UIFont fontNamesForFamilyName:@"Proxima Nova"]);
    NSLog(@"Proxima Nova: %@", [UIFont fontNamesForFamilyName:@"Proxima Nova Condensed"]);
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Localytics
//    [[LocalyticsSession sharedLocalyticsSession] startSession:@"c6bd712b99b9eb8f537c9bd-faa3f0ba-3e7f-11e2-693d-00ef75f32667"];
    
    // PSURLCache
    [[PSURLCache sharedCache] setNoCache:NO]; // This force NO CACHE
    [self purgeCacheIfNecessary:YES];
    
    // Appirater
//    [Appirater appLaunched:YES];
    
    // AFNetworking
    [[PSNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
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
    
    
    [self setupViewControllers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:kUserManagerDidLoginNotification object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] close];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    self.backgroundDate = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] resume];
//    [[LocalyticsSession sharedLocalyticsSession] upload];

//    [Appirater appEnteredForeground:YES];
    
    [self purgeCacheIfNecessary:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [[LocalyticsSession sharedLocalyticsSession] resume];
//    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
//    [FBSession.activeSession handleDidBecomeActive];
    
    if (self.shouldReloadInterface) {
        self.shouldReloadInterface = NO;

    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
