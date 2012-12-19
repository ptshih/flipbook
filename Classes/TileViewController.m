//
//  TileViewController.m
//  Mosaic
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "TileViewController.h"

#import "VenueTileViewCell.h"

#import "VenueViewController.h"
#import "BrandViewController.h"

#import "PSPopoverView.h"
#import "LocationChooserView.h"

#define kPopoverLocation 7001
#define kPopoverCategory 7002

@interface TileViewController () <PSPopoverViewDelegate>

@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, copy) NSString *query;

@property (nonatomic, assign) BOOL hasLoadedOnce;

@end

@implementation TileViewController

#pragma mark - Init

- (id)initWithCategory:(NSString *)category query:(NSString *)query title:(NSString *)title {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.category = category;
        self.query = query;
        self.title = title;
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
        self.pullRefreshStyle = PSPullRefreshStyleWhite;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.headerRightWidth = 0.0;
        
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
    return TEXTURE_DARK_LINEN;
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
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    //    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    //    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

- (void)setupFooter {
    [super setupFooter];
}


#pragma mark - Actions

- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
    CGFloat radius = self.radius > 0 ? self.radius : 400.0;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius * 2, radius * 2);
    LocationChooserView *cv = [[LocationChooserView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52) mapRegion:mapRegion];
    cv.query = self.query;
    cv.queryField.text = self.query;
    PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Searching in Map Area" contentView:cv];
    popoverView.tag = kPopoverLocation;
    popoverView.delegate = self;
    [popoverView showWithSize:cv.frame.size inView:self.view];
}

- (void)rightAction {
}


#pragma mark - State Machine

- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
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
        
        // TODO: Show an error saying location undetectable
        [self.centerButton setTitle:@"Trying to find your location" forState:UIControlStateNormal];
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
    NSString *ll = [NSString stringWithFormat:@"%g,%g", self.centerCoordinate.latitude, self.centerCoordinate.longitude];
    [parameters setObject:ll forKey:@"ll"];
    NSNumber *radius = (self.radius > 0) ? [NSNumber numberWithFloat:self.radius] : nil;
    if (radius) {
        [parameters setObject:radius forKey:@"radius"];
    }
    if (self.category) {
        [parameters setObject:self.category forKey:@"section"];
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
                        self.items = [NSMutableArray arrayWithArray:apiData];
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

#pragma mark - PSTileViewDelegate

- (NSMutableArray *)templateForTileView:(PSTileView *)tileView {
    NSArray *template;
    
    if(isDeviceIPad()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            NSArray *row1 = @[@"A", @"A", @"B"];
            NSArray *row2 = @[@"A", @"A", @"D"];
            NSArray *row3 = @[@"F", @"E", @"E"];
            NSArray *row4 = @[@"G", @"H", @"W"];
            NSArray *row5 = @[@"B", @"B", @"Q"];
            NSArray *row6 = @[@"A", @"M", @"Z"];
            NSArray *row7 = @[@"Y", @"U", @"U"];
            NSArray *row8 = @[@"T", @"B", @"Z"];
            template = @[row1, row2, row3, row4, row5, row6, row7, row8];
        } else {
            NSArray *row1 = @[@"A", @"A", @"A", @"C"];
            NSArray *row2 = @[@"A", @"A", @"A", @"D"];
            NSArray *row3 = @[@"F", @"W", @"E", @"E"];
            NSArray *row4 = @[@"G", @"G", @"E", @"E"];
            NSArray *row5 = @[@"G", @"G", @"C", @"D"];
            NSArray *row6 = @[@"A", @"B", @"Z", @"Z"];
            NSArray *row7 = @[@"Y", @"Y", @"U", @"V"];
            NSArray *row8 = @[@"T", @"B", @"Z", @"X"];
            template = @[row1, row2, row3, row4, row5, row6, row7, row8];
        }
    } else {
        NSArray *row1 = @[@"A", @"A"];
        NSArray *row2 = @[@"A", @"A"];
        NSArray *row3 = @[@"B", @"C"];
        NSArray *row4 = @[@"G", @"G"];
        NSArray *row5 = @[@"A", @"C"];
        NSArray *row6 = @[@"A", @"B"];
        NSArray *row7 = @[@"Y", @"Z"];
        NSArray *row8 = @[@"X", @"Z"];
        template = @[row1, row2, row3, row4, row5, row6, row7, row8];
    }
    
    return template;
}

- (PSTileViewCell *)tileView:(PSTileView *)tileView cellForItemAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    id cell = [tileView dequeueReusableCellForClass:[VenueTileViewCell class]];
    if (!cell) {
        cell = [[[VenueTileViewCell class] alloc] initWithFrame:CGRectZero];
    }
    
    [cell tileView:tileView fillCellWithObject:item atIndex:index];
    
    return cell;
}

- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    NSString *type = [item objectForKey:@"type"];
    
    if ([type isEqualToString:@"foursquare"]) {
        VenueViewController *vc = [[VenueViewController alloc] initWithVenueId:[item objectForKey:@"id"]];
        [self.navigationController pushViewController:vc animated:YES];
        
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Stream: Venue Selected" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"id"], @"id", [item objectForKey:@"name"], @"name", nil]];
    } else if ([type isEqualToString:@"airbrite"]) {
        NSString *slug = [item objectForKey:@"slug"];
        NSString *title = [item objectForKey:@"name"];
        BrandViewController *vc = [[BrandViewController alloc] initWithSlug:slug title:title];
        [self.navigationController pushViewController:vc animated:YES];
        
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Stream: Brand Selected" attributes:[NSDictionary dictionaryWithObjectsAndKeys:title, @"name", nil]];
    }
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

@end
