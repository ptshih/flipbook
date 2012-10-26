//
//  VenueListViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueListViewController.h"
#import "VenueDetailViewController.h"

#import "PSPopoverView.h"
#import "VenueView.h"
#import "CategoryChooserView.h"
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
        self.shouldShowFooter = YES;
        self.shouldPullRefresh = YES;
        self.shouldShowNullView = YES;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 32.0;
        
        self.radius = 0;
        self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] latitude], [[PSLocationCenter defaultCenter] longitude]);
        self.hasLoadedOnce = NO;
        
        self.title = @"Locating...";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:kPSLocationCenterDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFail) name:kPSLocationCenterDidFail object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    // 4sq attribution
    UIImageView *pb4sq = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByFoursquareBlack"]];
    pb4sq.contentMode = UIViewContentModeCenter;
    pb4sq.frame = CGRectMake(0, 0, self.collectionView.width, pb4sq.height);
    // Add gradient
    [pb4sq addGradientLayerWithFrame:CGRectMake(0, 0, pb4sq.width, 8.0) colors:[NSArray arrayWithObjects:(id)RGBACOLOR(0, 0, 0, 0.3).CGColor, (id)RGBACOLOR(0, 0, 0, 0.2).CGColor, (id)RGBACOLOR(0, 0, 0, 0.1).CGColor, (id)RGBACOLOR(0, 0, 0, 0.0).CGColor, nil] locations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil] startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
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
    
    self.footerView.backgroundColor = RGBCOLOR(33, 33, 33);
    
    UILabel *queryLabel = [UILabel labelWithText:[NSString stringWithFormat:@"Showing Results for \"%@\"", self.category] style:@"h4LightLabel"];
    self.queryLabel = queryLabel;
    queryLabel.frame = CGRectInset(self.footerView.bounds, 32, 0);
    queryLabel.autoresizingMask = self.footerView.autoresizingMask;
    
    // Add to subviews
    [self.footerView addSubview:queryLabel];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
    CGFloat radius = self.radius > 0 ? self.radius : 400.0;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius * 2, radius * 2);
    LocationChooserView *cv = [[LocationChooserView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52) mapRegion:mapRegion];
    PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Searching for Places in Map Area" contentView:cv];
    popoverView.tag = kPopoverLocation;
    popoverView.delegate = self;
    [popoverView showWithSize:cv.frame.size inView:self.view];
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
                    NSDictionary *location = [venue objectForKey:@"location"];
                    if (location) {
                        // If bad address, skip
                        if (!NOT_NULL([location objectForKey:@"address"]) || !NOT_NULL([location objectForKey:@"city"]) || !NOT_NULL([location objectForKey:@"state"])) {
                            continue;
                        }
                        
                        [item setObject:location forKey:@"location"];
                    } else {
                        continue;
                    }
                    
                    // Categories
                    if ([venue objectForKey:@"categories"] && [[venue objectForKey:@"categories"] count] > 0) {
                        [item setObject:[[[venue objectForKey:@"categories"] objectAtIndexOrNil:0] objectForKey:@"shortName"] forKey:@"primaryCategory"];
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
                    BOOL hasPhoto = NO;
                    if ([venue objectForKey:@"photos"]) {
                        hasPhoto = YES;
                        
                        photoURLPath = [[[[[[[[[venue objectForKey:@"photos"] objectForKey:@"groups"] objectAtIndexOrNil:0] objectForKey:@"items"] objectAtIndexOrNil:0] objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndexOrNil:0] objectForKey:@"url"];
                        
                        photoWidth = [[[[[[[[[venue objectForKey:@"photos"] objectForKey:@"groups"] objectAtIndexOrNil:0] objectForKey:@"items"] objectAtIndexOrNil:0] objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndexOrNil:0] objectForKey:@"width"];
                        
                        photoHeight = [[[[[[[[[venue objectForKey:@"photos"] objectForKey:@"groups"] objectAtIndexOrNil:0] objectForKey:@"items"] objectAtIndexOrNil:0] objectForKey:@"sizes"] objectForKey:@"items"] objectAtIndexOrNil:0] objectForKey:@"height"];
                    } else if ([venue objectForKey:@"categories"]) {
                        NSDictionary *icon = [[[venue objectForKey:@"categories"] objectAtIndexOrNil:0] objectForKey:@"icon"];
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
                    BOOL hasTip = NO;
                    if (tips && tips.count > 0 && [tips notNull]) {
                        hasTip = YES;
                        
                        NSDictionary *tip = [tips objectAtIndexOrNil:0];
                        
                        NSDictionary *tipUser = [tip objectForKey:@"user"];
                        NSString *tipUserName = tipUser ? [tipUser objectForKey:@"firstName"] : nil;
                        tipUserName = [tipUser objectForKey:@"lastName"] ? [tipUserName stringByAppendingFormat:@" %@", [tipUser objectForKey:@"lastName"]] : tipUserName;
                        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
                        
                        [item setObject:tipUserName forKey:@"tipUserName"];
                        [item setObject:tipText forKey:@"tipText"];
                    }
                    
                    // If no photo AND no tip, skip
                    if (!hasTip && !hasPhoto) {
                        continue;
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
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueView *v = (VenueView *)[self.collectionView dequeueReusableViewForClass:[VenueView class]];
    if (!v) {
        v = [[VenueView alloc] initWithFrame:CGRectZero];
    }
    
    [v collectionView:collectionView fillCellWithObject:item atIndex:index];
    
    return v;
}

- (CGFloat)heightForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [VenueView rowHeightForObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    VenueDetailViewController *vc = [[VenueDetailViewController alloc] initWithVenueId:[item objectForKey:@"id"]];
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
