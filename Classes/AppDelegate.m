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
#import "TimelineViewController.h"

#import "BWHockeyManager.h"
#import "BWQuincyManager.h"

static NSMutableDictionary *_captionsCache;

@interface AppDelegate (Private)

+ (void)setupDefaults;

@end

@implementation AppDelegate

@synthesize
window = _window,
navigationController = _navigationController;

+ (void)initialize {
    [self setupDefaults];
    _captionsCache = [[NSMutableDictionary alloc] init];
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
- (NSMutableDictionary *)captionsCache {
    return _captionsCache;
}

#pragma mark - Application Lifecycle
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"Fonts: %@", [UIFont familyNames]);
    
    [AirWomp startSession:@"4f4c00087ed8800008000003"];
    
#ifdef RELEASE
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"4fda551a3f254b914082b05e2d8d76fd"];
    [[BWHockeyManager sharedHockeyManager] setAlwaysShowUpdateReminder:YES];
#endif
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"4fda551a3f254b914082b05e2d8d76fd"];
    
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"34a9f3214a8fad66fc6fda1-e627441e-58cc-11e1-ab17-008545fe83d2"];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // PSFacebookCenter
//    [PSFacebookCenter defaultCenter];
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Start Reachability
    [PSReachabilityCenter defaultCenter];
    
    // PSLocationCenter set default behavior
    [[PSLocationCenter defaultCenter] updateMyLocation]; // start it
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]];
    
    // Root view controller
    id controller = nil;
    controller = [[[TimelineViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    self.navigationController = [[[PSNavigationController alloc] initWithRootViewController:controller] autorelease];
    self.window.rootViewController = self.navigationController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RELEASE_SAFELY(_navigationController);
    [_window release];
    [super dealloc];
}

@end
