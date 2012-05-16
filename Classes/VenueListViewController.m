//
//  VenueListViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueListViewController.h"
#import "VenueDetailViewController.h"
#import "EventViewController.h"
#import "FBConnectViewController.h"
#import "SettingsViewController.h"

#import "InfoPopoverView.h"
#import "PSPopoverView.h"
#import "VenueView.h"
#import "CategoryChooserView.h"
#import "LocationChooserView.h"

#define kPopoverLocation 7001
#define kPopoverCategory 7002
#define kPopoverEvent 7003

@interface VenueListViewController ()

@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, assign) BOOL hasLoadedOnce;

- (void)refreshOnAppear;

@end

@implementation VenueListViewController

@synthesize
shouldRefreshOnAppear = _shouldRefreshOnAppear;

@synthesize
category = _category,
centerCoordinate = _centerCoordinate,
radius = _radius,
query = _query,
locationLabel = _locationLabel;

@synthesize
hasLoadedOnce = _hasLoadedOnce;

#pragma mark - Init
- (id)initWithCategory:(NSString *)category {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.category = category;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
        self.shouldPullRefresh = NO;
        
        self.shouldRefreshOnAppear = NO;
        self.radius = 0;
        self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] latitude], [[PSLocationCenter defaultCenter] longitude]);
        self.hasLoadedOnce = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:kPSLocationCenterDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFail) name:kPSLocationCenterDidFail object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications) name:kNotificationManagerDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookDidLogin) name:kPSFacebookCenterDialogDidSucceed object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshOnAppear {
    self.shouldRefreshOnAppear = YES;
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [self updateNotifications];
    }
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldRefreshOnAppear) {
        self.shouldRefreshOnAppear = NO;
        [self reloadDataSource];
    }
    
    NSDate *showDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"showEventPopover"];
    
    if ([[showDate earlierDate:[NSDate date]] isEqualToDate:showDate] && ![[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:86400] forKey:@"showEventPopover"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        InfoPopoverView *pv = [[InfoPopoverView alloc] initWithFrame:self.view.bounds];
        pv.alpha = 0.0;
        
        [UIView animateWithDuration:0.4 animations:^{
            pv.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.view addSubview:pv];
        }];
    }
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    // Empty Label
    UILabel *emptyLabel = [UILabel labelWithText:@"No Places Found\r\nTry Searching Again" style:@"emptyLabel"];
    emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.emptyView = emptyLabel;
    
    // 4sq attribution
    UIImageView *pb4sq = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByFoursquareBlack"]];
    pb4sq.contentMode = UIViewContentModeCenter;
    pb4sq.frame = CGRectMake(0, 0, self.collectionView.width, pb4sq.height);
    // Add gradient
    [pb4sq addGradientLayerWithFrame:CGRectMake(0, 0, pb4sq.width, 8.0) colors:[NSArray arrayWithObjects:(id)RGBACOLOR(0, 0, 0, 0.3).CGColor, (id)RGBACOLOR(0, 0, 0, 0.2).CGColor, (id)RGBACOLOR(0, 0, 0, 0.1).CGColor, (id)RGBACOLOR(0, 0, 0, 0.0).CGColor, nil] locations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil] startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
    self.collectionView.footerView = pb4sq;
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:@"Lunchbox" forState:UIControlStateNormal];
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

- (void)setupFooter {
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 32, self.view.width, 32)];
    self.footerView.backgroundColor = RGBCOLOR(33, 33, 33);
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //    UIImageView *footerBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"BackgroundToolbar"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
    //    footerBg.autoresizingMask = self.footerView.autoresizingMask;
    //    [self.footerView addSubview:footerBg];
    
    UILabel *locationLabel = [UILabel labelWithText:@"Trying to locate you..." style:@"locationLabel"];
    self.locationLabel = locationLabel;
    locationLabel.frame = CGRectInset(self.footerView.bounds, 32, 0);
    locationLabel.autoresizingMask = self.footerView.autoresizingMask;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightAction)];
    [locationLabel addGestureRecognizer:gr];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(self.footerView.width - 20 - 8, 8, 16, 16);
    
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"IconGearWhite"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:settingsButton];
    
    // Add to subviews
    [self.footerView addSubview:locationLabel];
    [self.view addSubview:self.footerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
    
    //    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Send Love" message:@"Your love makes us work harder. Rate our app now?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"OK", nil] autorelease];
    //    [av show];
    
    //    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, self.radius * 2, self.radius * 2);
    //    LocationChooserView *cv = [[[LocationChooserView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52) mapRegion:mapRegion] autorelease];
    //    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Searching for Places in Map Area" contentView:cv] autorelease];
    //    popoverView.tag = kPopoverLocation;
    //    popoverView.delegate = self;
    //    [popoverView showWithSize:cv.frame.size inView:self.view];
}

- (void)centerAction {
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        EventViewController *vc = [[EventViewController alloc] initWithNibName:nil bundle:nil];
        vc.view.frame = CGRectMake(0, 0, 288, 356);
        PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Notifications" contentController:vc];
        popoverView.tag = kPopoverEvent;
        popoverView.delegate = self;
        [popoverView showWithSize:vc.view.bounds.size inView:self.view];
    } else {
        FBConnectViewController *vc = [[FBConnectViewController alloc] initWithNibName:nil bundle:nil];
        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionUp animated:YES];
    }
    
    return;
    
//        CGFloat radius = self.radius > 0 ? self.radius : 400.0;
//        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius * 2, radius * 2);
    //    PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Searching for Places in Map Area" contentView:cv];
    //    popoverView.tag = kPopoverLocation;
    //    popoverView.delegate = self;
    //    [popoverView showWithSize:cv.frame.size inView:self.view];
}

- (void)rightAction {
    CGFloat radius = self.radius > 0 ? self.radius : 400.0;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius * 2, radius * 2);
    LocationChooserView *cv = [[LocationChooserView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52) mapRegion:mapRegion];
    PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Searching for Places in Map Area" contentView:cv];
    popoverView.tag = kPopoverLocation;
    popoverView.delegate = self;
    [popoverView showWithSize:cv.frame.size inView:self.view];
    
    return;
    
    //    CategoryChooserView *cv = [[[CategoryChooserView alloc] initWithFrame:CGRectMake(0, 0, 288, 152)] autorelease];
    //    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Choose a Category" contentView:cv] autorelease];
    //    popoverView.tag = kPopoverCategory;
    //    popoverView.delegate = self;
    //    
    //    [popoverView showWithSize:cv.frame.size inView:self.view];
}

- (void)showSettings {
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

#pragma mark - Location Notification
- (void)locationDidUpdate {
    self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] latitude], [[PSLocationCenter defaultCenter] longitude]);
    
    if (!self.hasLoadedOnce) {
        [self loadDataSource];
    }
}

- (void)locationDidFail {
    if (!self.hasLoadedOnce) {
        [self dataSourceDidError];
    }
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    if (![[PSLocationCenter defaultCenter] hasAcquiredLocation]) {
        self.hasLoadedOnce = NO;
#warning location bug
        // TODO: Show an error saying location undetectable
        self.locationLabel.text = @"Unable to find your location";
        return;
    } else {
        self.hasLoadedOnce = YES;
    }
    
    // Cancel ongoing geocoding
    if ([[[PSLocationCenter defaultCenter] geocoder] isGeocoding]) {
        [[[PSLocationCenter defaultCenter] geocoder] cancelGeocode];
    }
    
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:self.centerCoordinate.latitude longitude:self.centerCoordinate.longitude];
    
    [[[PSLocationCenter defaultCenter] geocoder] reverseGeocodeLocation:centerLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0) {
            NSString *locString = nil;
            CLPlacemark *placemark = [placemarks lastObject];
            // Areas of Interest (UNUSED)
            //                    NSArray *areasOfInterest = [placemark areasOfInterest];
            //                    if (areasOfInterest && [areasOfInterest count] > 0) {
            //                        locString = [NSString stringWithFormat:@"%@ of %@", [NSString localizedStringForDistance:self.radius], [areasOfInterest objectAtIndex:0]];
            //                    } else {
            //                        locString = [NSString stringWithFormat:@"%@ of %@", [NSString localizedStringForDistance:self.radius], [placemark name]];
            //                    }
            
            if (self.radius == 0) {
                locString = [NSString stringWithFormat:@"Near %@", placemark.name];
            } else {
                locString = [NSString stringWithFormat:@"%@ of %@", [NSString localizedStringForDistance:self.radius], placemark.name];
            }
            
            self.locationLabel.text = locString;
            //            [self.centerButton setTitle:locString forState:UIControlStateNormal];
            //            NSLog(@"placemark: %@", placemark);
        }
    }];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.category forKey:@"section"];
    NSString *ll = [NSString stringWithFormat:@"%g,%g", self.centerCoordinate.latitude, self.centerCoordinate.longitude];
    [parameters setObject:ll forKey:@"ll"];
    NSNumber *radius = (self.radius > 0) ? [NSNumber numberWithFloat:self.radius] : nil;
    if (radius) {
        [parameters setObject:radius forKey:@"radius"];
    }
    if (self.query) {
        [parameters setObject:self.query forKey:@"query"];
    }
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/venues", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [blockSelf.items removeAllObjects];
            [blockSelf dataSourceDidError];
        } else {
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                NSNumber *suggestedRadius = [apiResponse objectForKey:@"suggestedRadius"];
                if (suggestedRadius) {
                    blockSelf.radius = [suggestedRadius floatValue];
                }
                NSArray *venues = [apiResponse objectForKey:@"venues"];
                NSMutableArray *items = [NSMutableArray array];
                for (NSDictionary *venueRec in venues) {
                    NSMutableDictionary *item = [NSMutableDictionary dictionary];
                    
                    NSDictionary *venue = [venueRec objectForKey:@"venue"];
                    NSArray *tips = [venueRec objectForKey:@"tips"];
                    
                    // Name
                    [item setObject:[venue objectForKey:@"id"] forKey:@"id"];
                    [item setObject:[venue objectForKey:@"name"] forKey:@"name"];
                    
                    // Location
                    if ([venue objectForKey:@"location"]) {
                        [item setObject:[venue objectForKey:@"location"] forKey:@"location"];
                    } else {
                        continue;
                    }
                    
                    // Categories
                    if ([venue objectForKey:@"categories"] && [[venue objectForKey:@"categories"] count] > 0) {
                        [item setObject:[[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"shortName"] forKey:@"primaryCategory"];
                    } else {
                        continue;
                    }
                    
                    // Stats
                    if ([venue objectForKey:@"stats"]) {
                        [item setObject:[venue objectForKey:@"stats"] forKey:@"stats"];
                    }
                    
                    // Photo
                    NSString *photoURLPath = nil;
                    NSNumber *photoWidth = nil;
                    NSNumber *photoHeight = nil;
                    if ([venue objectForKey:@"photos"]) {
                        photoURLPath = [[[[[[[[[venue objectForKey:@"photos"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"url"];
                        
                        photoWidth = [[[[[[[[[venue objectForKey:@"photos"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"width"];
                        
                        photoHeight = [[[[[[[[[venue objectForKey:@"photos"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"height"];
                    } else if ([venue objectForKey:@"categories"]) {
                        NSDictionary *icon = [[[venue objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"];
                        photoURLPath = [[icon objectForKey:@"prefix"] stringByAppendingFormat:@"%@%@", [[icon objectForKey:@"sizes"] lastObject], [icon objectForKey:@"name"]];
                        
                        photoWidth = [NSNumber numberWithInteger:256];
                        photoHeight = [NSNumber numberWithInteger:256];
                    } else {
                        // no photo, no category
                        continue;
                    }
                    
                    if (photoURLPath) {
                        [item setObject:photoURLPath forKey:@"photoURLPath"];
                        [item setObject:photoWidth forKey:@"photoWidth"];
                        [item setObject:photoHeight forKey:@"photoHeight"];
                    } else {
                        continue;
                    }
                    
                    // Tip
                    if (tips && tips.count > 0 && [tips notNull]) {
                        NSDictionary *tip = [tips objectAtIndex:0];
                        
                        NSDictionary *tipUser = [tip objectForKey:@"user"];
                        NSString *tipUserName = tipUser ? [tipUser objectForKey:@"firstName"] : nil;
                        tipUserName = [tipUser objectForKey:@"lastName"] ? [tipUserName stringByAppendingFormat:@" %@", [tipUser objectForKey:@"lastName"]] : tipUserName;
                        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
                        
                        [item setObject:tipUserName forKey:@"tipUserName"];
                        [item setObject:tipText forKey:@"tipText"];
                    }
                    
                    [items addObject:item];
                }
                
                [blockSelf.items removeAllObjects];
                [blockSelf.items addObjectsFromArray:items];
                [blockSelf dataSourceDidLoad];
            } else {
                [blockSelf.items removeAllObjects];
                [blockSelf dataSourceDidError];
            }
        }
    }];
}

#pragma mark - PSCollectionViewDelegate
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueView *v = (VenueView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[VenueView alloc] initWithFrame:CGRectZero];
    }
    
    [v fillViewWithObject:item];
    
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [VenueView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueDetailViewController *vc = [[VenueDetailViewController alloc] initWithVenueId:[item objectForKey:@"id"] eventId:nil];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

#pragma mark - PSErrorViewDelegate
- (void)errorViewDidDismiss:(PSErrorView *)errorView {
    [self reloadDataSource];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    //    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
}

- (void)endRefresh {
    [super endRefresh];
    //    [SVProgressHUD dismiss];
}

#pragma mark - PSPopoverViewDelegate
- (void)popoverViewDidDismiss:(PSPopoverView *)popoverView {
    if (popoverView.tag == kPopoverCategory) {
        //        NSInteger newCategoryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"categoryIndex"];
        //        if (newCategoryIndex != self.categoryIndex) {
        //            self.query = nil; // remove query term when changing categories
        //            self.categoryIndex = newCategoryIndex;
        //            [self reloadDataSource];
        //        }
    } else if (popoverView.tag == kPopoverLocation) {
        LocationChooserView *cv = (LocationChooserView *)popoverView.contentView;
        
        if (cv.locationDidChange) {
            MKMapView *mapView = cv.mapView;
            MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mapView.visibleMapRect), MKMapRectGetMidY(mapView.visibleMapRect));
            MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapView.visibleMapRect), MKMapRectGetMidY(mapView.visibleMapRect));
            
            CGFloat span = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
            
            self.radius = ceilf(span / 2.0);
            self.centerCoordinate = mapView.centerCoordinate;
            self.query = [cv query];
            
            [self reloadDataSource];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    
    [Appirater rateApp];
}

#pragma mark - Notifications

- (void)updateNotifications {
    NSArray *notifications = [[NotificationManager sharedManager] notifications];
    [self.centerButton setTitle:[NSString stringWithFormat:@"Lunchbox (%d)", notifications.count] forState:UIControlStateNormal];
}

- (void)facebookDidLogin {
    [[NotificationManager sharedManager] downloadNotifications];
}

@end
