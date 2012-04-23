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

#import "PSZoomView.h"

#import "BWHockeyManager.h"
#import "BWQuincyManager.h"

#import "FlurryAnalytics.h"
#import "FlurryAppCircle.h"

@interface AppDelegate () <BWHockeyManagerDelegate, BWQuincyManagerDelegate>

@property (nonatomic, retain) UIImageView *splashImage;

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
    
    self.shouldReloadInterface = NO;
    
#ifdef RELEASE
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"4fda551a3f254b914082b05e2d8d76fd"];
    [[BWHockeyManager sharedHockeyManager] setAlwaysShowUpdateReminder:YES];
    [[BWHockeyManager sharedHockeyManager] setDelegate:self];
#endif
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"4fda551a3f254b914082b05e2d8d76fd"];
    
    // Vendor analytics
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"84958a8210d0dc2a5082943-09e67c0a-6273-11e1-1c6d-00a68a4c01fc"];
    
    [FlurryAppCircle setAppCircleEnabled:YES];
    [FlurryAnalytics startSession:@"UTWDBDPVIEUCJ9PNBI2H"];
    
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
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor blackColor];
//    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]];
    
    // Root view controller
    id controller = nil;
    controller = [[[CategoryListViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    self.navigationController = [[[PSNavigationController alloc] initWithRootViewController:controller] autorelease];
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
    self.splashImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:splashImageName]] autorelease];
    self.splashImage.top = splashTop;
    [self.window addSubview:self.splashImage];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.splashImage.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.splashImage removeFromSuperview];
        self.splashImage = nil;
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
        
        [self.navigationController popToRootViewControllerAnimated:NO];
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
    self.splashImage = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.backgroundDate = nil;
    self.foregroundDate = nil;
    self.navigationController = nil;
    [_window release];
    [super dealloc];
}

@end
