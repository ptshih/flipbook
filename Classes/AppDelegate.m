//
//  AppDelegate.m
//  OSnap
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "AppDelegate.h"
#import "PSReachabilityCenter.h"
#import "PSLocationCenter.h"
#import "CategoryListViewController.h"
#import "VenueDetailViewController.h"

#import "PSZoomView.h"

#import "BWHockeyManager.h"
#import "BWQuincyManager.h"

#import "FlurryAnalytics.h"
#import "FlurryAppCircle.h"

#import "TapjoyConnect.h"

@interface AppDelegate () <BWHockeyManagerDelegate, BWQuincyManagerDelegate>

@property (nonatomic, strong) UIImageView *splashImage;

+ (void)setupDefaults;

@end

@implementation AppDelegate

@synthesize
splashImage = _splashImage;

@synthesize
window = _window,
navigationController = _navigationController,
backgroundDate = _backgroundDate,
foregroundDate = _foregroundDate,
shouldReloadInterface = _shouldReloadInterface;

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
    }
}

#pragma mark - Global Statics

#pragma mark - Push Controller

- (void)pushVenueWithId:(NSString *)venueId {
    // Need to retrieve:
    // id, name, lat, lng, stats, tip, formattedAddress, contact, menu, url, reservations
    NSString *URLPath = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@", venueId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:FS_API_VERSION forKey:@"v"];
    [parameters setObject:@"2CPOOTGBGYH53Q2LV3AORUF1JO0XV0FZLU1ZSZ5VO0GSKELO" forKey:@"client_id"];
    [parameters setObject:@"W45013QS5ADELZMVZYIIH3KX44TZQXDN0KQN5XVRN1JPJVGB" forKey:@"client_secret"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
        } else {
            // Process 4sq response
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            if (!apiResponse) {
                [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            } else {
                NSDictionary *response = [apiResponse objectForKey:@"response"];
                
                // Venue Dict
                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                
                // Read out the API                                
                NSDictionary *venue = OBJ_NOT_NULL([response objectForKey:@"venue"]);
                
                if (!venueId) return;
                
                NSDictionary *tips = OBJ_NOT_NULL([venue objectForKey:@"tips"]);
                NSDictionary *stats = OBJ_NOT_NULL([venue objectForKey:@"stats"]);
                NSDictionary *menu = OBJ_NOT_NULL([venue objectForKey:@"menu"]);
                NSDictionary *reservations = OBJ_NOT_NULL([venue objectForKey:@"reservations"]);
                NSDictionary *location = OBJ_NOT_NULL([venue objectForKey:@"location"]);
                NSDictionary *category = OBJ_NOT_NULL([venue objectForKey:@"categories"]) ? [[venue objectForKey:@"categories"] lastObject] : nil;
                
                
                // Basic Info
                [item setObject:[venue objectForKey:@"id"] forKey:@"id"];
                [item setObject:[venue objectForKey:@"name"] forKey:@"name"];
                
                // Category
                if (category) {
                    [item setObject:[category objectForKey:@"name"] forKey:@"category"];
                }
                
                // Location
                if (NOT_NULL([location objectForKey:@"address"])) {
                    [item setObject:[location objectForKey:@"address"] forKey:@"address"];
                } else {
                    return;
                }
                
                if (NOT_NULL([location objectForKey:@"address"]) && NOT_NULL([location objectForKey:@"city"]) && NOT_NULL([location objectForKey:@"state"]) && NOT_NULL([location objectForKey:@"postalCode"])) {
                    [item setObject:[NSString stringWithFormat:@"%@ %@, %@ %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"], [location objectForKey:@"postalCode"]] forKey:@"formattedAddress"];
                } else if (NOT_NULL([location objectForKey:@"address"])) {
                    [item setObject:[location objectForKey:@"address"] forKey:@"formattedAddress"];
                } else {
                    return;
                }
                
                if (NOT_NULL([location objectForKey:@"distance"])) {
                    [item setObject:[location objectForKey:@"distance"] forKey:@"distance"];
                } else {
                    [item setObject:[NSNumber numberWithInteger:0] forKey:@"distance"];
                }
                
                if (NOT_NULL([location objectForKey:@"lat"]) && NOT_NULL([location objectForKey:@"lng"])) {
                    [item setObject:[location objectForKey:@"lat"] forKey:@"lat"];
                    [item setObject:[location objectForKey:@"lng"] forKey:@"lng"];
                } else {
                    return;
                }
                
                // Tip
                if (tips) {
                    NSArray *tipGroups = [tips objectForKey:@"groups"];
                    if (tipGroups && tipGroups.count > 0) {
                        NSArray *tipItems = [[tipGroups objectAtIndex:0] objectForKey:@"items"];
                        if (tipItems && tipItems.count > 0) {
                            [item setObject:[tipItems objectAtIndex:0] forKey:@"tip"];
                        }
                    }
                }
                
                // Contact
                if (NOT_NULL([venue objectForKey:@"contact"])) {
                    [item setObject:[venue objectForKey:@"contact"] forKey:@"contact"];
                }
                if (NOT_NULL([venue objectForKey:@"url"])) {
                    [item setObject:[venue objectForKey:@"url"] forKey:@"url"];
                }
                
                // Stats
                if (stats) {
                    [item setObject:stats forKey:@"stats"];
                }
                
                // Menu
                if (menu) {
                    [item setObject:menu forKey:@"menu"];
                }
                
                // Reservations
                if (reservations) {
                    [item setObject:reservations forKey:@"reservations"];
                }
                
                VenueDetailViewController *vc = [[VenueDetailViewController alloc] initWithDictionary:item];
                [blockSelf.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }];
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


- (BOOL)handleURL:(NSURL *)url {
    NSLog(@"app handle open URL: %@", url);
    
    // Intercept for FB deep linking
    NSString *scheme = url.scheme;
    if ([scheme isEqualToString:@"fb456420417705188live"] || [scheme isEqualToString:@"fb456420417705188beta"] || [scheme isEqualToString:@"fb456420417705188pro"]) {
        NSString *fragment = url.fragment;
        NSDictionary *params = [self parseURLParams:fragment];
        // Check if target URL exists
        NSString *targetURLString = [params valueForKey:@"target_url"];
        if (targetURLString) {
            NSURL *targetURL = [NSURL URLWithString:targetURLString];
            NSString *venueId = [targetURL lastPathComponent];
            if (venueId) {
                // Push venue
                [self pushVenueWithId:venueId];
                return YES;
            } else {
                return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
            }
        } else {
            return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
        }
    } else {
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleURL:url];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSLog(@"Fonts: %@", [UIFont familyNames]);
    
    self.shouldReloadInterface = NO;
    
    // HOCKEY
#ifdef RELEASE
    
#ifdef BETA
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"113eebcc5c0fdfb14a3508233c3d2a4b"];
#elif PRO
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"b238fc47fd27c516ed929710209f3f91"];
#else
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"4fda551a3f254b914082b05e2d8d76fd"];
#endif
    
    [[BWHockeyManager sharedHockeyManager] setAlwaysShowUpdateReminder:YES];
    [[BWHockeyManager sharedHockeyManager] setDelegate:self];
#endif
    
    // QUINCY
#ifdef BETA
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"113eebcc5c0fdfb14a3508233c3d2a4b"];
#elif PRO
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"b238fc47fd27c516ed929710209f3f91"];
#else
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"4fda551a3f254b914082b05e2d8d76fd"];
#endif
    
    // Vendor analytics
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"84958a8210d0dc2a5082943-09e67c0a-6273-11e1-1c6d-00a68a4c01fc"];
    
    [FlurryAppCircle setAppCircleEnabled:YES];
    [FlurryAnalytics startSession:@"UTWDBDPVIEUCJ9PNBI2H"];
    
    // TapJoy
    [TapjoyConnect requestTapjoyConnect:@"af5f1a49-b4bb-4f7f-8482-01489f1be53b" secretKey:@"1xRqieVumpivrDFdOHrF"];
    
    [Appirater appLaunched:YES];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // PSFacebookCenter
//    [PSFacebookCenter defaultCenter];
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Start Reachability
    [PSReachabilityCenter defaultCenter];
    
    // PSLocationCenter set default behavior
    [[PSLocationCenter defaultCenter] resumeUpdates]; // start it
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor blackColor];
//    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]];
    
    // Root view controller
    id controller = nil;
    controller = [[CategoryListViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navigationController = [[PSNavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = self.navigationController;
    
    // Splash Image
    NSString *splashImageName = nil;
    CGFloat splashTop = 0.0;
    if (isDeviceIPad()) {
        splashImageName = @"Default-Portrait";
        splashTop = 20.0;
    } else {
        splashImageName = @"Default";
        splashTop = 0.0;
    }
    self.splashImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashImageName]];
    self.splashImage.top = splashTop;
    [self.window addSubview:self.splashImage];
    
    BLOCK_SELF;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        blockSelf.splashImage.alpha = 0.0;
    } completion:^(BOOL finished) {
        [blockSelf.splashImage removeFromSuperview];
        blockSelf.splashImage = nil;
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.backgroundDate = [NSDate date];
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
    
    self.foregroundDate = [NSDate date];
    
    NSTimeInterval secondsBackgrounded = [self.foregroundDate timeIntervalSinceDate:self.backgroundDate];
    // 5 min threshold
    if (secondsBackgrounded > kSecondsBackgroundedUntilStale) {
        self.shouldReloadInterface = YES;
        
        // Purge session cache
        [[PSURLCache sharedCache] purgeCacheWithCacheType:PSURLCacheTypeSession];
    }
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {    
    if (self.shouldReloadInterface) {
        self.shouldReloadInterface = NO;
        
        if ([[PSZoomView sharedView] isZooming]) {
            [[PSZoomView sharedView] reset];
        }
        
//        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (NSString *)customDeviceIdentifier {
#ifndef DISTRIBUTION
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
