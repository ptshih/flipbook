//
//  VenueListViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueListViewController.h"
#import "VenueDetailViewController.h"

#import "VenueCollectionViewCell.h"
#import "LocationChooserView.h"

#define kPopoverLocation 7001
#define kPopoverCategory 7002

@interface VenueListViewController () <PSPopoverViewDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, strong) UILabel *queryLabel;

@property (nonatomic, assign) BOOL hasLoadedOnce;

@end

@implementation VenueListViewController

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
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldPullRefresh = YES;
        self.shouldPullLoadMore = YES;
        self.shouldShowNullView = YES;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.limit = 25;
        
        self.title = @"Locating...";
        
        // Location
        self.radius = 0;
        self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] latitude], [[PSLocationCenter defaultCenter] longitude]);
        self.hasLoadedOnce = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:kPSLocationCenterDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFail) name:kPSLocationCenterDidFail object:nil];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return BASE_BG_COLOR;
}


#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    if (isDeviceIPad()) {
        self.collectionView.numColsPortrait = 3;
        self.collectionView.numColsLandscape = 4;
    } else {
        self.collectionView.numColsPortrait = 2;
        self.collectionView.numColsLandscape = 3;
    }
    
    // 4sq attribution footer
    UIImageView *pb4sq = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByFoursquareBlack"]];
    pb4sq.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pb4sq.contentMode = UIViewContentModeCenter;
    pb4sq.frame = CGRectMake(0, 0, self.collectionView.width, pb4sq.height);
    
    self.collectionView.footerView = pb4sq;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

- (void)setupFooter {
    [super setupFooter];
}


#pragma mark - Actions

- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
    [self rightAction];
}

- (void)rightAction {
    CGFloat radius = self.radius > 0 ? self.radius : 400.0;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius * 2, radius * 2);
    LocationChooserView *cv = [[LocationChooserView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52) mapRegion:mapRegion];
    PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Searching in Map Area" contentView:cv];
    popoverView.tag = kPopoverLocation;
    popoverView.delegate = self;
    [popoverView showWithSize:cv.frame.size inView:self.view];
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

- (void)loadMoreDataSource {
    [super loadMoreDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

- (void)dataSourceDidLoadMore {
    [super dataSourceDidLoadMore];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    if (![[PSLocationCenter defaultCenter] hasAcquiredLocation]) {
        self.hasLoadedOnce = NO;
#warning location bug
        // TODO: Show an error saying location undetectable
        [self.centerButton setTitle:@"Unable to find your location" forState:UIControlStateNormal];
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
            
//            self.locationLabel.text = locString;
            [self.centerButton setTitle:locString forState:UIControlStateNormal];
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
    
    [parameters setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    [parameters setObject:[NSNumber numberWithInteger:self.offset] forKey:@"offset"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/v3/venues", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [self dataSourceDidError];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                // Suggested Radius
                id suggestedRadius = [apiResponse objectForKey:@"suggestedRadius"];
                self.radius = [suggestedRadius floatValue];
                
                // List of Venues
                id apiData = [apiResponse objectForKey:@"venues"];
                if (apiData && [apiData isKindOfClass:[NSArray class]]) {
                    if (self.loadingMore) {
                        [self.items addObjectsFromArray:apiData];
                        [self dataSourceDidLoadMore];
                    } else {
                        self.items = [NSMutableArray arrayWithArray:apiData];;
                        [self dataSourceDidLoad];
                    }
                } else {
                    [self dataSourceDidError];
                }
            } else {
                [self dataSourceDidError];
            }
        }
    }];
}

#pragma mark - PSCollectionViewDelegate
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueCollectionViewCell *v = (VenueCollectionViewCell *)[self.collectionView dequeueReusableViewForClass:[VenueCollectionViewCell class]];
    if (!v) {
        v = [[VenueCollectionViewCell alloc] initWithFrame:CGRectZero];
    }
    
    [v collectionView:collectionView fillCellWithObject:item atIndex:index];
    
    return v;
}

- (CGFloat)heightForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [VenueCollectionViewCell rowHeightForObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueDetailViewController *vc = [[VenueDetailViewController alloc] initWithVenueId:[item objectForKey:@"id"]];
    [self.navigationController pushViewController:vc animated:YES];
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
            
            NSString *query = (self.query && self.query.length > 0) ? self.query : self.category;
            self.queryLabel.text = [NSString stringWithFormat:@"Showing Results for \"%@\"", query];
            
            [self reloadDataSource];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    
    [Appirater rateApp];
}

@end
