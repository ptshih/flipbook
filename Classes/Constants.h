// Core Data
#define CORE_DATA_MOM @"Grid"
#define CORE_DATA_SQL_FILE @"Grid.sqlite"

#ifdef BETA
    #define FB_APP_SUFFIX @"beta"
#elif PRO
    #define FB_APP_SUFFIX @"pro"
#else
    #define FB_APP_SUFFIX @"live"
#endif

#define FB_PERMISSIONS_PUBLISH @"publish_stream"
#define FB_BASIC_PERMISISONS [NSArray arrayWithObjects:@"offline_access", nil]
#define FB_PERMISSIONS [NSArray arrayWithObjects:@"offline_access", @"publish_stream", nil]

/**
 Constants
 */
#ifdef DEBUG
    #define kSecondsBackgroundedUntilStale 5
#else
    #define kSecondsBackgroundedUntilStale 600

#endif

#define kMapRegionRadius 1000

/**
 Notifications
 */

/**
 Alert Tags
 */
#define kAlertTagDirections 7001

/**
 Error domains
 */
#define kErrorNotificationManager @"com.petershih.lunchbox.notifications"

// Date formats
#define kEventDateFormat @"EEE, MMM dd, yyyy @ h:mm a z"

// Colors
#define CELL_WHITE_COLOR [UIColor whiteColor]
#define CELL_BLACK_COLOR [UIColor blackColor]
#define CELL_BLUE_COLOR RGBCOLOR(45.0,147.0,204.0)

#define KUPO_LIGHT_GREEN_COLOR RGBCOLOR(205,225,200)
#define KUPO_BLUE_COLOR RGBCOLOR(45.0,147.0,204.0)
#define KUPO_LIGHT_BLUE_COLOR RGBCOLOR(0,179,249)

#define FB_BLUE_COLOR RGBCOLOR(59.0,89.0,152.0)
#define FB_COLOR_DARK_GRAY_BLUE RGBCOLOR(79.0,92.0,117.0)
#define FB_COLOR_VERY_LIGHT_BLUE RGBCOLOR(220.0,225.0,235.0)
#define FB_COLOR_LIGHT_BLUE RGBCOLOR(161.0,176.0,206.0)
#define FB_COLOR_DARK_BLUE RGBCOLOR(51.0,78.0,141.0)
#define LIGHT_GRAY RGBCOLOR(247.0,247.0,247.0)
#define VERY_LIGHT_GRAY RGBCOLOR(226.0,231.0,237.0)
#define GRAY_COLOR RGBCOLOR(87.0,108.0,137.0)

// APP COLORS
#define TABLE_BG_COLOR [UIColor clearColor]
#define HEADER_BG_COLOR [UIColor blackColor]
#define FOOTER_BG_COLOR RGBCOLOR(33.0,33.0,33.0)
#define WINDOW_BG_COLOR [UIColor blackColor]
#define BASE_BG_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"TextureAluminum"]]
#define CELL_BG_COLOR RGBACOLOR(240,240,240,1)

// API
#if TARGET_IPHONE_SIMULATOR
  #define USE_LOCALHOST
#endif

#define API_LOCALHOST @"http://localhost:3000/v1"
#define API_REMOTE @"https://api.trycelery.com/v1"

#ifdef USE_LOCALHOST
  #define API_BASE_URL [NSString stringWithFormat:API_LOCALHOST]
#else
  #define API_BASE_URL [NSString stringWithFormat:API_REMOTE]
#endif

// Apple Frameworks
#import <MapKit/MapKit.h>

// Vendor Frameworks
#import <HockeySDK/HockeySDK.h>
#import <FacebookSDK/FacebookSDK.h>
#import <DropboxSDK/DropboxSDK.h>

// PSConstants
#import "PSConstants.h"

// Notification manager
#import "NotificationManager.h"

// Vendor imports
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Appirater.h"
#import "PSLocationCenter.h"
#import "LocalyticsSession.h"
#import "ECSlidingViewController.h"
#import "PSPDFAlertView.h"
#import "PSPDFActionSheet.h"

#import "UserManager.h"
