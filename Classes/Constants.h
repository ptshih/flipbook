#import <MapKit/MapKit.h>

#import "PSConstants.h"
#import "PSNavigationController.h"
#import "PSReachabilityCenter.h"

// Vendor imports
#import "PSFacebookCenter.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Appirater.h"
#import "LocalyticsSession.h"
#import "PSLocationCenter.h"
#import "AirWomp.h"
#import "SVGeocoder.h"
#import "TTTAttributedLabel.h"

#define CORE_DATA_MOM @"Lunchbox"
#define CORE_DATA_SQL_FILE @"Lunchbox.sqlite"

#define FB_APP_ID @"262079367168011"
#define FB_APP_SUFFIX @"lunchbox"
#define FS_ACCESS_TOKEN @"BIHQ3R0JVGSQ4R2BIPMTMTWEHAFICRUF54KQJ0WKTJ404KB3"
#define FS_CLIENT_ID @"2CPOOTGBGYH53Q2LV3AORUF1JO0XV0FZLU1ZSZ5VO0GSKELO"
#define FS_CALLBACK_URL @"http://www.petershih.com/fscallback"

/**
 Constants
 */
#ifndef DISTRIBUTION
    #define kSecondsBackgroundedUntilStale 1
#else
    #define kSecondsBackgroundedUntilStale 300
#endif

#define kMapRegionRadius 1000

/**
 Notifications
 */
#define kShouldRecenterCurrentLocation @"kShouldRecenterCurrentLocation"

/**
 Alert Tags
 */
#define kAlertTagDirections 7001
#define kAlertTagFoursquare 7002

// Convenience
#define APP_DRAWER [APP_DELEGATE drawerController]

// Colors
#define CELL_WHITE_COLOR [UIColor whiteColor]
#define CELL_BLACK_COLOR [UIColor blackColor]
#define CELL_BLUE_COLOR RGBCOLOR(45.0,147.0,204.0)

// Custom Colors
#define CELL_BACKGROUND_COLOR CELL_BLACK_COLOR
#define CELL_SELECTED_COLOR CELL_BLUE_COLOR

#if TARGET_IPHONE_SIMULATOR
  #define USE_LOCALHOST
#endif

#define API_LOCALHOST @"http://localhost:5000"
#define API_REMOTE @"http://whiskey.herokuapp.com"

#ifdef USE_LOCALHOST
  #define API_BASE_URL [NSString stringWithFormat:API_LOCALHOST]
#else
  #define API_BASE_URL [NSString stringWithFormat:API_REMOTE]
#endif
