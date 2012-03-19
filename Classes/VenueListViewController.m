//
//  VenueListViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueListViewController.h"
#import "VenueDetailViewController.h"
#import "PSZoomView.h"
#import "PSPopoverView.h"
#import "TimelineView.h"
#import "CategoryChooserView.h"
#import "LocationChooserView.h"

#define kPopoverLocation 7001
#define kPopoverCategory 7002

@interface VenueListViewController ()

@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, copy) NSString *query;

- (void)refreshOnAppear;

@end

@implementation VenueListViewController

@synthesize
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
shouldRefreshOnAppear = _shouldRefreshOnAppear,
categoryIndex = _categoryIndex,
centerCoordinate = _centerCoordinate,
radius = _radius,
query = _query;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldRefreshOnAppear = NO;
        self.categoryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"categoryIndex"];
        self.radius = 0;
        self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] latitude], [[PSLocationCenter defaultCenter] longitude]);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:kPSLocationCenterDidUpdate object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSLocationCenterDidUpdate object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    self.query = nil;
    [super dealloc];
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
    
    // Setup Views
    [self setupSubviews];
    [self setupPullRefresh];
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldRefreshOnAppear) {
        self.shouldRefreshOnAppear = NO;
        [self reloadDataSource];
    }
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupHeader];
    
    self.collectionView = [[[PSCollectionView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height)] autorelease];
    self.collectionView.delegate = self;
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
    if (isDeviceIPad()) {
        self.collectionView.numColsPortrait = 4;
        self.collectionView.numColsLandscape = 5;
    } else {
        self.collectionView.numColsPortrait = 2;
        self.collectionView.numColsLandscape = 3;
    }
    
    // 4sq attribution
    UIImageView *pb4sq = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByFoursquareBlack"]] autorelease];
    pb4sq.contentMode = UIViewContentModeCenter;
    pb4sq.frame = CGRectMake(0, 0, self.collectionView.width, pb4sq.height);
    // Add gradient
    [pb4sq addGradientLayerWithFrame:CGRectMake(0, 0, pb4sq.width, 8.0) colors:[NSArray arrayWithObjects:(id)RGBACOLOR(0, 0, 0, 0.3).CGColor, (id)RGBACOLOR(0, 0, 0, 0.2).CGColor, (id)RGBACOLOR(0, 0, 0, 0.1).CGColor, (id)RGBACOLOR(0, 0, 0, 0.0).CGColor, nil] locations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil] startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
    self.collectionView.footerView = pb4sq;
    
    UILabel *emptyLabel = [UILabel labelWithText:@"No Venues Found\r\nTry a Different Location" style:@"emptyLabel"];
    emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.emptyView = emptyLabel;
    
    [self.view addSubview:self.collectionView];
    
    [self addRoundedCorners];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconHeartWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:@"Lunchbox" forState:UIControlStateNormal];
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconSliderWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Send Love" message:@"Your love makes us work harder. Rate our app now?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Okay", nil] autorelease];
    [av show];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueList#sendLove"];
}

- (void)centerAction {
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, self.radius * 2, self.radius * 2);
    LocationChooserView *cv = [[[LocationChooserView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52) mapRegion:mapRegion] autorelease];
    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Choose a Location" contentView:cv] autorelease];
    popoverView.tag = kPopoverLocation;
    popoverView.delegate = self;
    [popoverView showWithSize:cv.frame.size inView:self.view];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueList#locationChooser"];
}

- (void)rightAction {
    CategoryChooserView *cv = [[[CategoryChooserView alloc] initWithFrame:CGRectMake(0, 0, 288, 152)] autorelease];
    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Choose a Category" contentView:cv] autorelease];
    popoverView.tag = kPopoverCategory;
    popoverView.delegate = self;
    
    [popoverView showWithSize:cv.frame.size inView:self.view];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueList#categoryChooser"];
}

- (void)locationDidUpdate {
    self.radius = kMapRegionRadius;
    self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] latitude], [[PSLocationCenter defaultCenter] longitude]);
    
    [self reloadDataSource];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueList#load"];
}

- (void)reloadDataSource {
    [super reloadDataSource];

    [self loadDataSourceFromRemoteUsingCache:NO];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueList#reload"];
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
    [self.requestQueue addOperationWithBlock:^{
        if (![[PSLocationCenter defaultCenter] hasAcquiredAccurateLocation]) {
            return;
        } else {        
            [SVGeocoder reverseGeocode:self.centerCoordinate completion:^(NSArray *placemarks, NSError *error) {
                if (!error && [placemarks count] > 0) {
                    SVPlacemark *placemark = [placemarks objectAtIndex:0];
                    NSString *street = [placemark.addressDictionary objectForKey:@"Street"];
                    NSString *locString = [NSString stringWithFormat:@"%@ of %@",[NSString localizedStringForDistance:self.radius] , street];
                    [self.centerButton setTitle:locString forState:UIControlStateNormal];
                }
            }];
        }
        
        NSString *ll = [NSString stringWithFormat:@"%g,%g", self.centerCoordinate.latitude, self.centerCoordinate.longitude];
        NSNumber *radius = (self.radius > 0) ? [NSNumber numberWithFloat:self.radius] : nil;
        
        NSString *URLPath = @"https://api.foursquare.com/v2/venues/explore";
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:ll forKey:@"ll"];
        if (radius) {
            [parameters setObject:radius forKey:@"radius"];
        }
        if (self.query) {
            [parameters setObject:self.query forKey:@"query"];
        }
        [parameters setObject:@"20120222" forKey:@"v"];
        [parameters setObject:[NSNumber numberWithInteger:1] forKey:@"venuePhotos"];
        [parameters setObject:[NSNumber numberWithInteger:50] forKey:@"limit"];
        [parameters setObject:@"2CPOOTGBGYH53Q2LV3AORUF1JO0XV0FZLU1ZSZ5VO0GSKELO" forKey:@"client_id"];
        [parameters setObject:@"W45013QS5ADELZMVZYIIH3KX44TZQXDN0KQN5XVRN1JPJVGB" forKey:@"client_secret"];
        NSString *section = nil;
        switch (self.categoryIndex) {
            case 0:
                section = @"food";
                break;
            case 1:
                section = @"coffee";
                break;
            case 2:
                section = @"drinks";
                break;
            default:
                section = @"food";
                break;
        }
        [parameters setObject:section forKey:@"section"];
        
        NSURL *URL = [NSURL URLWithString:URLPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
        
        [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypePermanent usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
            if (error) {
                [self dataSourceDidError];
            } else {
                [[[[NSOperationQueue alloc] init] autorelease] addOperationWithBlock:^{
                    id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                    if (!JSON) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self dataSourceDidError];
                        }];
                    } else {
                        // Process 4sq response
                        NSDictionary *response = [JSON objectForKey:@"response"];
                        NSArray *groups = [response objectForKey:@"groups"];
                        if (groups && [groups count] > 0) {
                            // Format the response for our consumption
                            NSMutableArray *items = [NSMutableArray array];
                            for (NSDictionary *dict in [[groups objectAtIndex:0] objectForKey:@"items"]) {
                                NSDictionary *venue = [dict objectForKey:@"venue"];
                                NSArray *tips = [dict objectForKey:@"tips"];
                                NSDictionary *stats = [venue objectForKey:@"stats"];
                                NSDictionary *location = [venue objectForKey:@"location"];
                                NSDictionary *category = [[venue objectForKey:@"categories"] lastObject];
                                NSDictionary *featuredPhoto = [[[venue objectForKey:@"featuredPhotos"] objectForKey:@"items"] lastObject];
                                
                                if (!featuredPhoto) {
                                    // skip if there is no photo
                                    continue;
                                }
                                
                                NSDictionary *featuredPhotoItem = [[[featuredPhoto objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndex:0];
                                
                                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                                [item setObject:[venue objectForKey:@"id"] forKey:@"id"];
                                [item setObject:[venue objectForKey:@"name"] forKey:@"name"];
                                [item setObject:[category objectForKey:@"name"] forKey:@"category"];
                                if ([location objectForKey:@"address"]) {
                                    [item setObject:[location objectForKey:@"address"] forKey:@"address"];
                                }
                                [item setObject:[location objectForKey:@"distance"] forKey:@"distance"];
                                if ([location objectForKey:@"lat"] && [location objectForKey:@"lng"]) {
                                    [item setObject:[location objectForKey:@"lat"] forKey:@"lat"];
                                    [item setObject:[location objectForKey:@"lng"] forKey:@"lng"];
                                }
                                [item setObject:[featuredPhotoItem objectForKey:@"width"] forKey:@"width"];
                                [item setObject:[featuredPhotoItem objectForKey:@"height"] forKey:@"height"];
                                [item setObject:[featuredPhotoItem objectForKey:@"url"] forKey:@"source"];
                                if (tips && [tips count] > 0) {
                                    [item setObject:[tips objectAtIndex:0] forKey:@"tip"];
                                }
                                [item setObject:[stats objectForKey:@"tipCount"] forKey:@"tipCount"];
                                [item setObject:[stats objectForKey:@"photoCount"] forKey:@"photoCount"];
                                
                                
                                [items addObject:item];
                            }
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                if (!self.isReload) {
                                    self.contentOffset = self.collectionView.contentOffset.y > 0 ? self.collectionView.contentOffset : CGPointZero;
                                }
                                self.items = items;
                                [self.collectionView reloadViews];
                                [self dataSourceDidLoad];
                                
                                // If this is the first load and we loaded cached data, we should refreh from remote now
                                if (!self.hasLoadedOnce && isCached) {
                                    self.hasLoadedOnce = YES;
                                    [self reloadDataSource];
                                    NSLog(@"first load, stale cache");
                                }
                            }];
                        } else {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self dataSourceDidError];
                            }];
                        }
                    }
                }];
            }
        }];
    }];
}

#pragma mark - PSCollectionViewDelegate
- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    TimelineView *v = (TimelineView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[[TimelineView alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    [v fillViewWithObject:item];
    
    return v;

}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];

    return [TimelineView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(UIView *)view atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueDetailViewController *vc = [[[VenueDetailViewController alloc] initWithDictionary:item] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
//    [AirWomp presentAlertViewWithBlock:^{
//        VenueDetailViewController *vc = [[[VenueDetailViewController alloc] initWithDictionary:item] autorelease];
//        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
//    }];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueList#venue"];
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
        NSInteger newCategoryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"categoryIndex"];
        if (newCategoryIndex != self.categoryIndex) {
            self.query = nil; // remove query term when changing categories
            self.categoryIndex = newCategoryIndex;
            [self reloadDataSource];
        }
    } else if (popoverView.tag = kPopoverLocation) {
        MKMapView *mapView = [(LocationChooserView *)popoverView.contentView mapView];
        MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mapView.visibleMapRect), MKMapRectGetMidY(mapView.visibleMapRect));
        MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapView.visibleMapRect), MKMapRectGetMidY(mapView.visibleMapRect));
        
        CGFloat span = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
        
        self.radius = ceilf(span / 2.0);
        self.centerCoordinate = mapView.centerCoordinate;
        self.query = [(LocationChooserView *)popoverView.contentView query];
        
        [self reloadDataSource];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timelineConfig#loveSent"];
    
    [Appirater rateApp];
}

@end
