//
//  VenueDetailViewController.m
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueDetailViewController.h"
#import "PSWebViewController.h"
#import "TipListViewController.h"
#import "UserViewController.h"

#import "PSStarView.h"

#import "PhotoCollectionViewCell.h"
#import "PSZoomView.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

static NSNumberFormatter *__numberFormatter = nil;

@interface VenueDetailViewController () <MKMapViewDelegate>

@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, strong) NSDictionary *venueDict;
@property (nonatomic, strong) NSDictionary *yelpDict;
@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation VenueDetailViewController

+ (void)initialize {
    __numberFormatter = [[NSNumberFormatter alloc] init];
    [__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - Init

- (id)initWithVenueId:(NSString *)venueId {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueId = venueId;
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
        
        self.headerRightWidth = 0.0;
        
        self.title = @"Loading...";
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mapView.delegate = nil;
}

- (void)dealloc {
    self.mapView.delegate = nil;
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

- (void)setupVenueSubviews {
    [self updateHeader];
    
    CGFloat mapHeight;
    if (isDeviceIPad()) {
        mapHeight = 320;
    } else {
        mapHeight = 160;
    }
    
    // Setup collectionView header
    // 2 part collection header
    CGFloat top = 0.0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.width, 0.0)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Map    
    UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, headerView.width - 16, mapHeight - 8)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mapView.backgroundColor = [UIColor whiteColor];
    UIImage *mapShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    UIImageView *mapShadowView = [[UIImageView alloc] initWithImage:mapShadowImage];
    mapShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapShadowView.frame = CGRectInset(mapView.bounds, -1, -2);
    [mapView addSubview:mapShadowView];
    [headerView addSubview:mapView];
    
    CGFloat mapTop = 4.0;
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(4, mapTop, headerView.width - 24, mapHeight - 16)];
    self.mapView.layer.borderWidth = 0.5;
    self.mapView.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
    self.mapView.layer.masksToBounds = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]), 250, 250);
    [self.mapView setRegion:mapRegion animated:NO];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:self.venueDict];
    [self.mapView addAnnotation:annotation];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomMap:)];
    [self.mapView addGestureRecognizer:gr];
    [mapView addSubview:self.mapView];
    
    mapTop += self.mapView.height + 4.0;
    
    // Stats
    UILabel *statsLabel = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"stats"])) {
        UIImageView *peopleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPersonMiniBlack"]];
        [mapView addSubview:peopleIcon];
        peopleIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        statsLabel = [UILabel labelWithStyle:@"h6BoldDarkLabel"];
        [mapView addSubview:statsLabel];
        statsLabel.backgroundColor = mapView.backgroundColor;
        statsLabel.text = [NSString stringWithFormat:@"%@ people checked in here", [__numberFormatter stringFromNumber:[[self.venueDict objectForKey:@"stats"] objectForKey:@"checkinsCount"]]];
        
        CGSize statsLabelSize = [statsLabel sizeForLabelInWidth:(self.mapView.width - 16.0)];
        statsLabel.frame = CGRectMake(8 + 16, mapTop, statsLabelSize.width, 16.0);
        
        mapTop += statsLabel.height + 4.0;
    }
    
    // Address
    UIButton *addressButton = nil;
    NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"]];
    if ([location objectForKey:@"postalCode"]) {
        formattedAddress = [formattedAddress stringByAppendingFormat:@" %@", [location objectForKey:@"postalCode"]];
    }
    
    if (formattedAddress) {
        UIImageView *addressIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPinMiniBlack"]];
        [mapView addSubview:addressIcon];
        addressIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:addressButton];
        addressButton.backgroundColor = mapView.backgroundColor;
        [addressButton addTarget:self action:@selector(openAddress:) forControlEvents:UIControlEventTouchUpInside];
        [addressButton setTitle:formattedAddress forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:addressButton];
        
        // weird 1px border padding for buttons
        addressButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16 - 11, 16);
        
        mapTop += addressButton.height + 4.0;
    }
    
    // Phone
    UIButton *phoneButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"contact"]) && [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]) {
        UIImageView *phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPhoneBlack"]];
        [mapView addSubview:phoneIcon];
        phoneIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:phoneButton];
        phoneButton.backgroundColor = mapView.backgroundColor;
        [phoneButton addTarget:self action:@selector(openPhone:) forControlEvents:UIControlEventTouchUpInside];
        [phoneButton setTitle:[NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:phoneButton];
        
        phoneButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16 - 11, 16);
        
        mapTop += phoneButton.height + 4.0;
    }
    
    // Website
    UIButton *websiteButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"url"])) {
        UIImageView *websiteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPlanetBlack"]];
        [mapView addSubview:websiteIcon];
        websiteIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:websiteButton];
        websiteButton.backgroundColor = mapView.backgroundColor;
        [websiteButton addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
        [websiteButton setTitle:[NSString stringWithFormat:@"%@", [self.venueDict objectForKey:@"url"]] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:websiteButton];
        
        websiteButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16 - 11, 16);
        
        mapTop += websiteButton.height + 4.0;
    }
    
    // Menu
    UIButton *menuButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"menu"])) {
        UIImageView *menuIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFoodBlack"]];
        [mapView addSubview:menuIcon];
        menuIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:menuButton];
        menuButton.backgroundColor = mapView.backgroundColor;
        [menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setTitle:[NSString stringWithFormat:@"%@", @"See the menu"] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:menuButton];
        
        menuButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16 - 11, 16);
        
        mapTop += menuButton.height + 4.0;
    }
    
    // Reservations
    UIButton *reservationsButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"reservations"])) {
        UIImageView *reservationsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconReservationsBlack"]];
        [mapView addSubview:reservationsIcon];
        reservationsIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        reservationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:reservationsButton];
        reservationsButton.backgroundColor = mapView.backgroundColor;
        [reservationsButton addTarget:self action:@selector(openReservations:) forControlEvents:UIControlEventTouchUpInside];
        [reservationsButton setTitle:[NSString stringWithFormat:@"%@", @"Make reservations on OpenTable"] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:reservationsButton];
        
        reservationsButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16 - 11, 16);
        
        mapTop += reservationsButton.height + 4.0;
    }
    
    mapView.height = mapTop;
    
    top = mapView.bottom + 8.0;
    
    // Tip
    // Don't show if no tips
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"tips"]) && [[self.venueDict objectForKey:@"tips"] count] > 0) {
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(8, top, headerView.width - 16, 0.0)];
        tipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tipView.backgroundColor = [UIColor whiteColor];
        UIImage *tipShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *tipShadowView = [[UIImageView alloc] initWithImage:tipShadowImage];
        tipShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tipShadowView.frame = CGRectInset(tipView.bounds, -1, -2);
        [tipView addSubview:tipShadowView];
        UITapGestureRecognizer *tipGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushTips:)];
        [tipView addGestureRecognizer:tipGR];
        [headerView addSubview:tipView];
        
        UIImageView *divider = nil;
        CGSize labelSize = CGSizeZero;
        CGFloat tipWidth = tipView.width - 16 - 20;
        
        UILabel *tipUserLabel = [UILabel labelWithStyle:@"h6BoldDarkLabel"];
        tipUserLabel.backgroundColor = tipView.backgroundColor;
        [tipView addSubview:tipUserLabel];
        
        UILabel *tipLabel = [UILabel labelWithStyle:@"h6GeorgiaDarkLabel"];
        tipLabel.backgroundColor = tipView.backgroundColor;
        [tipView addSubview:tipLabel];
        
        // Tip
        NSDictionary *tip = [[self.venueDict objectForKey:@"tips"] objectAtIndexOrNil:0];
        NSString *tipUserName = [tip objectForKey:@"userName"];
        NSString *tipUserText = [NSString stringWithFormat:@"%@ says:", tipUserName];
        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
        
        tipUserLabel.text = tipUserText;
        labelSize = [tipUserLabel sizeForLabelInWidth:(tipView.width - 16.0)];
        tipUserLabel.frame = CGRectMake(8, 4, tipWidth, labelSize.height);
        
        tipLabel.text = tipText;
        labelSize = [tipLabel sizeForLabelInWidth:(tipView.width - 16.0)];
        tipLabel.frame = CGRectMake(8, tipUserLabel.bottom, tipWidth, labelSize.height);
        
        divider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        divider.frame = CGRectMake(8, tipLabel.bottom + 4, tipWidth, 1.0);
        [tipView addSubview:divider];
        
        // Stats
        NSDictionary *stats = [self.venueDict objectForKey:@"stats"];
        
        UILabel *countLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
        countLabel.backgroundColor = tipView.backgroundColor;
        countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        countLabel.text = [NSString stringWithFormat:@"View All %@ Tips", [stats objectForKey:@"tipCount"]];
        labelSize = [countLabel sizeForLabelInWidth:(tipView.width - 16.0)];
        countLabel.frame = CGRectMake(8, divider.bottom + 4, tipWidth, labelSize.height);
        [tipView addSubview:countLabel];
        
        CGFloat tipHeight = countLabel.bottom + 4.0;
        tipView.height = tipHeight;
        
        UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
        disclosure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosure.contentMode = UIViewContentModeCenter;
        disclosure.frame = CGRectMake(tipView.width - 20, 0, 20, tipView.height);
        [tipView addSubview:disclosure];
        
        
        top += tipView.height + 8.0;
    }
    
    headerView.height = top;
    
    self.collectionView.headerView = headerView;
}

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

    self.collectionView.footerView = pb4sq;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
}

- (void)setupFooter {
    [super setupFooter];
    
    self.footerView.top = self.view.height;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushYelp:)];
    [self.footerView addGestureRecognizer:gr];

}

- (void)updateHeader {
    // Call this when venueDict is ready to re-enable header actions
    self.title = [self.venueDict objectForKey:@"name"];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)updateFooter {
    if (self.yelpDict) {
//        NSString *ratingHref = [self.yelpDict objectForKey:@"rating_img_url_large"];
        CGFloat rating = [[self.yelpDict objectForKey:@"rating"] floatValue];
        
        CGFloat left = 8.0;
        CGFloat top = 6.0;
        CGFloat width = self.footerView.width - 16.0;
        
        // Left
        PSStarView *starView = [[PSStarView alloc] initWithRating:rating];
        starView.left = left;
        starView.top = top;
        [self.footerView addSubview:starView];
        
        left += starView.width + 8.0;
        width -= starView.width + 8.0;
        
        NSString *reviewCount = [NSString stringWithFormat:@"%@ Reviews on Yelp", [self.yelpDict objectForKey:@"review_count"]];
        UILabel *reviewCountLabel = [UILabel labelWithText:reviewCount style:@"h4CondLightLabel"];
        CGSize labelSize = [reviewCountLabel sizeForLabelInWidth:width];
        reviewCountLabel.frame = CGRectMake(left, top, labelSize.width, 20);
        [self.footerView addSubview:reviewCountLabel];
        
        UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
        disclosure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosure.contentMode = UIViewContentModeCenter;
        disclosure.frame = CGRectMake(self.footerView.width - 20.0, top, 20, 20);
        [self.footerView addSubview:disclosure];
        
        // animate show footer
        if (self.footerView.top == self.view.height) {
            [UIView animateWithDuration:0.4 animations:^{
                self.footerView.frame = CGRectMake(0, self.view.height - self.footerView.height, self.footerView.width, self.footerView.height);
                [self updateSubviews];
            } completion:^(BOOL finished) {
            }];
        }
    } else {
        // animate hide footer
//        if (self.footerView.top == self.view.height - self.footerView.height) {
//            [UIView animateWithDuration:0.4 animations:^{
//                self.footerView.frame = CGRectMake(0, self.view.height, self.footerView.width, self.footerView.height);
//                [self updateSubviews];                
//            } completion:^(BOOL finished) {
//            }];
//        }
    }
}

#pragma mark - Actions
- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
}

- (void)zoomMap:(UITapGestureRecognizer *)gr {
    if (![PSZoomView prepareToZoom]) {
        return;
    }
    
    MKMapView *v = (MKMapView *)gr.view;
    
    CGRect convertedFrame = [self.view.window convertRect:v.frame fromView:v.superview];
    [PSZoomView showMapView:v withFrame:convertedFrame inView:self.view.window fullscreen:YES];
    
    [self.mapView selectAnnotation:[[self.mapView annotations] lastObject] animated:YES];
}

- (void)pushTips:(UITapGestureRecognizer *)gr {
    TipListViewController *vc = [[TipListViewController alloc] initWithVenueDict:self.venueDict];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushYelp:(UITapGestureRecognizer *)gr {
    NSString *yelpUrlString = nil;
    if (isYelpInstalled()) {
        yelpUrlString = [NSString stringWithFormat:@"yelp:///biz/%@", [self.yelpDict objectForKey:@"id"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:yelpUrlString]];
    } else {
        yelpUrlString = [self.yelpDict objectForKey:@"mobile_url"];
        PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:yelpUrlString title:nil];
        [self.navigationController pushViewController:vc animated:YES];
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
    
    // Load Yelp
    [self loadYelp];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
    }
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (void)loadYelp {
    NSString *URLPath = [NSString stringWithFormat:@"%@/v3/venues/%@/yelp", API_BASE_URL, [self.venueDict objectForKey:@"id"]];
    
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    NSString *ll = [NSString stringWithFormat:@"%@,%@", [location objectForKey:@"lat"], [location objectForKey:@"lng"]];
    NSString *q = [self.venueDict objectForKey:@"name"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:ll forKey:@"ll"];
    [parameters setObject:q forKey:@"q"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                self.yelpDict = apiResponse;
            } else {
                self.yelpDict = nil;
            }
            
            [self updateFooter];
        }
    }];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSString *URLPath = [NSString stringWithFormat:@"%@/v3/venues/%@", API_BASE_URL, self.venueId];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [self dataSourceDidError];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                // Parse out venueDict
                self.venueDict = [apiResponse objectForKey:@"venue"];
                NSArray *photos = [apiResponse objectForKey:@"photos"];
                
                // load/setup the headers
                [self setupVenueSubviews];
                
                self.items = [NSMutableArray arrayWithArray:photos];
                [self dataSourceDidLoad];
            } else {
                // Error in apiResponse
                [self dataSourceDidError];
            }
        }
    }];
}

#pragma mark - PSCollectionViewDelegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [PhotoCollectionViewCell class];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    Class cellClass = [self collectionView:collectionView cellClassForRowAtIndex:index];
    
    id cell = [self.collectionView dequeueReusableViewForClass:[cellClass class]];
    if (!cell) {
        cell = [[cellClass alloc] initWithFrame:CGRectZero];
    }
    
    [cell collectionView:collectionView fillCellWithObject:item atIndex:index];
    
    return cell;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index {
    Class cellClass = [self collectionView:collectionView cellClassForRowAtIndex:index];
    
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [cellClass rowHeightForObject:item inColumnWidth:collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index {
//    Class cellClass = [self collectionView:collectionView cellClassForRowAtIndex:index];
    
    PhotoCollectionViewCell *v = (PhotoCollectionViewCell *)cell;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = v.imageView;
    if (!imageView.image) return;
    
    // make sure to zoom the full res image here
    NSURL *originalURL = imageView.originalURL;
    UIActivityIndicatorViewStyle oldStyle = imageView.loadingIndicator.activityIndicatorViewStyle;
    imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView.loadingIndicator startAnimating];
    
    [[PSURLCache sharedCache] loadURL:originalURL cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        [imageView.loadingIndicator stopAnimating];
        imageView.loadingIndicator.activityIndicatorViewStyle = oldStyle;
        
        if (!error) {
            UIImage *sourceImage = [UIImage imageWithData:cachedData];
            if (sourceImage) {
                CGRect convertedFrame = [self.view.window convertRect:imageView.frame fromView:imageView.superview];
                
                if ([PSZoomView prepareToZoom]) {
                    [PSZoomView showImage:imageView.image withFrame:convertedFrame inView:self.view.window];
                }
            }
        }
    }];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSString *reuseIdentifier = NSStringFromClass([VenueAnnotationView class]);
    VenueAnnotationView *v = (VenueAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (!v) {
        v = [[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        v.canShowCallout = YES;
        v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"View Directions" message:[NSString stringWithFormat:@"Open %@ in Google Maps?", [view.annotation title]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    av.tag = kAlertTagDirections;
    [av show];
}

#pragma mark - Button Actions
- (void)openAddress:(id)sender {
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"]];
    if ([location objectForKey:@"postalCode"]) {
        formattedAddress = [formattedAddress stringByAppendingFormat:@" %@", [location objectForKey:@"postalCode"]];
    }
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [formattedAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)openPhone:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"phone"]]]];
}

- (void)openWebsite:(id)sender {
    NSString *urlString = [self.venueDict objectForKey:@"url"];
    if (urlString) {
        PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlString title:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.venueDict objectForKey:@"url"]]];
}

- (void)openMenu:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"menu"] objectForKey:@"mobileUrl"]];
    
    PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlString title:@"Menu"];
    [self.navigationController pushViewController:vc animated:YES];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)openReservations:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"reservations"] objectForKey:@"url"]];
    
    PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlString title:@"OpenTable Reservations"];
    [self.navigationController pushViewController:vc animated:YES];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (isDeviceIPad()) {
        if ([[PSZoomView sharedView] isZooming]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
