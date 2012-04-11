//
//  VenueDetailViewController.m
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueDetailViewController.h"
#import "TipListViewController.h"
#import "CheckinViewController.h"
#import "PhotoView.h"
#import "PSZoomView.h"
#import "PSPopoverView.h"
#import "YelpPopoverView.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

static NSNumberFormatter *__numberFormatter = nil;

@interface VenueDetailViewController ()

@end

@implementation VenueDetailViewController

@synthesize
venueDict = _venueDict,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
mapView = _mapView;

+ (void)initialize {
    __numberFormatter = [[NSNumberFormatter alloc] init];
    [__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - Init
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary; 
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.venueDict = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self setupPullRefresh];
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupHeader];
    
    self.collectionView = [[[PSCollectionView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height)] autorelease];
    self.collectionView.delegate = self; // scrollViewDelegate
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
    
    UILabel *emptyLabel = [UILabel labelWithText:@"No Photos Found" style:@"emptyLabel"];
    emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.emptyView = emptyLabel;
    
    CGFloat mapHeight;
    if (isDeviceIPad()) {
        mapHeight = 320;
    } else {
        mapHeight = 160;
    }
    
    // Setup collectionView header
    // 2 part collection header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.width, mapHeight)] autorelease];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Map
    UIView *mapView = [[[UIView alloc] initWithFrame:CGRectMake(8, 0, headerView.width - 16, mapHeight - 8)] autorelease];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mapView.backgroundColor = [UIColor whiteColor];
    UIImage *mapShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    UIImageView *mapShadowView = [[[UIImageView alloc] initWithImage:mapShadowImage] autorelease];
    mapShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapShadowView.frame = CGRectInset(mapView.bounds, -1, -2);
    [mapView addSubview:mapShadowView];
    [headerView addSubview:mapView];
    
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(4, 4, headerView.width - 24, mapHeight - 16)] autorelease];
    self.mapView.layer.borderWidth = 0.5;
    self.mapView.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
    self.mapView.layer.masksToBounds = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[self.venueDict objectForKey:@"lat"] floatValue], [[self.venueDict objectForKey:@"lng"] floatValue]), 250, 250);
    [self.mapView setRegion:mapRegion animated:NO];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:self.venueDict];
    [self.mapView addAnnotation:annotation];
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomMap:)] autorelease];
    [self.mapView addGestureRecognizer:gr];
    [mapView addSubview:self.mapView];
    
    CGFloat top = self.mapView.bottom + 4.0;
    
    // Stats
    UILabel *statsLabel = nil;
    if ([self.venueDict objectForKey:@"stats"]) {
        UIImageView *peopleIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPersonMiniBlack"]] autorelease];
        [mapView addSubview:peopleIcon];
        peopleIcon.frame = CGRectMake(8, top + 2, 11, 11);
        
        statsLabel = [UILabel labelWithStyle:@"titleLabel"];
        [mapView addSubview:statsLabel];
        statsLabel.backgroundColor = mapView.backgroundColor;
        statsLabel.text = [NSString stringWithFormat:@"%@ people checked in here", [__numberFormatter stringFromNumber:[[self.venueDict objectForKey:@"stats"] objectForKey:@"checkinsCount"]]];
        
        CGSize statsLabelSize = [PSStyleSheet sizeForText:statsLabel.text width:self.mapView.width - 16 style:@"titleLabel"];
        statsLabel.frame = CGRectMake(8 + 16, top, statsLabelSize.width, 16.0);
        
        top += statsLabel.height + 2.0;
    }
    
    // Address
    UILabel *addressLabel = nil;
    if ([self.venueDict objectForKey:@"formattedAddress"]) {
        UIImageView *addressIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPinMiniBlack"]] autorelease];
        [mapView addSubview:addressIcon];
        addressIcon.frame = CGRectMake(8, top + 2, 11, 11);
        
        addressLabel = [UILabel labelWithStyle:@"attributedLabel"];
        [mapView addSubview:addressLabel];
        addressLabel.backgroundColor = mapView.backgroundColor;
        addressLabel.text = [self.venueDict objectForKey:@"formattedAddress"];
        
        CGSize addressLabelSize = [PSStyleSheet sizeForText:addressLabel.text width:self.mapView.width - 16 style:@"attributedLabel"];
        addressLabel.frame = CGRectMake(8 + 16, top, addressLabelSize.width, 16.0);
        
        top += addressLabel.height + 2.0;
    }
    
    // Phone
    UIButton *phoneButton = nil;
    if ([self.venueDict objectForKey:@"contact"] && [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]) {
        UIImageView *phoneIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPhoneBlack"]] autorelease];
        [mapView addSubview:phoneIcon];
        phoneIcon.frame = CGRectMake(8, top + 2, 11, 11);
        
        phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:phoneButton];
        phoneButton.backgroundColor = mapView.backgroundColor;
        [phoneButton addTarget:self action:@selector(openPhone:) forControlEvents:UIControlEventTouchUpInside];
        [phoneButton setTitle:[NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:phoneButton];
        
        phoneButton.frame = CGRectMake(8 + 16, top, self.mapView.width - 16, 16);
        
        top += phoneButton.height + 2.0;
    }
    
    // Website
    UIButton *websiteButton = nil;
    if ([self.venueDict objectForKey:@"url"]) {
        UIImageView *websiteIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPlanetBlack"]] autorelease];
        [mapView addSubview:websiteIcon];
        websiteIcon.frame = CGRectMake(8, top + 2, 11, 11);
        
        websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:websiteButton];
        websiteButton.backgroundColor = mapView.backgroundColor;
        [websiteButton addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
        [websiteButton setTitle:[NSString stringWithFormat:@"%@", [self.venueDict objectForKey:@"url"]] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:websiteButton];
        
        websiteButton.frame = CGRectMake(8 + 16, top, self.mapView.width - 16, 16);
        
        top += phoneButton.height + 2.0;
    }
    
    if (addressLabel || statsLabel || phoneButton || websiteButton) {
        mapView.height += top - self.mapView.bottom;
        headerView.height += top - self.mapView.bottom;
    }
    
    // Tip
    // Don't show if no tips
    if ([self.venueDict objectForKey:@"tip"]) {
        UIView *tipView = [[[UIView alloc] initWithFrame:CGRectMake(8, mapView.bottom + 8.0, headerView.width - 16, 148)] autorelease];
        tipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tipView.backgroundColor = [UIColor whiteColor];
        UIImage *tipShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *tipShadowView = [[[UIImageView alloc] initWithImage:tipShadowImage] autorelease];
        tipShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tipShadowView.frame = CGRectInset(tipView.bounds, -1, -2);
        [tipView addSubview:tipShadowView];
        UITapGestureRecognizer *tipGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushTips:)] autorelease];
        [tipView addGestureRecognizer:tipGR];
        [headerView addSubview:tipView];
        
        UIImageView *divider = nil;
        CGSize labelSize = CGSizeZero;
        CGFloat tipWidth = tipView.width - 16 - 20;
        
        UILabel *tipUserLabel = [UILabel labelWithStyle:@"attributedBoldLabel"];
        tipUserLabel.backgroundColor = tipView.backgroundColor;
        [tipView addSubview:tipUserLabel];
        
        UILabel *tipLabel = [UILabel labelWithStyle:@"attributedLabel"];
        tipLabel.backgroundColor = tipView.backgroundColor;
        [tipView addSubview:tipLabel];
        
        // Tip
        NSDictionary *tip = [self.venueDict objectForKey:@"tip"];
        NSDictionary *tipUser = [tip objectForKey:@"user"];
        NSString *tipUserName = tipUser ? [tipUser objectForKey:@"firstName"] : nil;
        tipUserName = [tipUser objectForKey:@"lastName"] ? [tipUserName stringByAppendingFormat:@" %@", [tipUser objectForKey:@"lastName"]] : tipUserName;
        NSString *tipUserText = [NSString stringWithFormat:@"%@ says:", tipUserName];
        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
        
        tipUserLabel.text = tipUserText;
        labelSize = [PSStyleSheet sizeForText:tipUserLabel.text width:(tipView.width - 16.0) style:@"attributedBoldLabel"];
        tipUserLabel.frame = CGRectMake(8, 4, tipWidth, labelSize.height);
        
        tipLabel.text = tipText;
        labelSize = [PSStyleSheet sizeForText:tipLabel.text width:(tipView.width - 16.0) style:@"attributedLabel"];
        tipLabel.frame = CGRectMake(8, tipUserLabel.bottom, tipWidth, labelSize.height);
        
        divider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        divider.frame = CGRectMake(8, tipLabel.bottom + 4, tipWidth, 1.0);
        [tipView addSubview:divider];
        
        // Stats
        NSDictionary *stats = [self.venueDict objectForKey:@"stats"];
        
        UILabel *countLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        countLabel.backgroundColor = tipView.backgroundColor;
        countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        countLabel.text = [NSString stringWithFormat:@"View All %@ Tips", [stats objectForKey:@"tipCount"]];
        labelSize = [PSStyleSheet sizeForText:countLabel.text width:(tipView.width - 16.0) style:@"subtitleLabel"];
        countLabel.frame = CGRectMake(8, divider.bottom + 4, tipWidth, labelSize.height);
        [tipView addSubview:countLabel];
        
        CGFloat tipHeight = countLabel.bottom + 4;
        tipView.height = tipHeight;
        
        UIImageView *disclosure = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicatorWhiteBordered"]] autorelease];
        disclosure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosure.contentMode = UIViewContentModeCenter;
        disclosure.frame = CGRectMake(tipView.width - 20, 0, 20, tipView.height);
        [tipView addSubview:disclosure];
        headerView.height += tipView.height;
    }
    
    
    self.collectionView.headerView = headerView;
    
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
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.centerButton setTitle:[self.venueDict objectForKey:@"name"] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleLabel.minimumFontSize = 12.0;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconFoursquare"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#yelp"];
    
    YelpPopoverView *v = [[[YelpPopoverView alloc] initWithDictionary:self.venueDict frame:CGRectMake(0, 0, 288, 154)] autorelease]; // 218
    PSPopoverView *pv = [[[PSPopoverView alloc] initWithTitle:@"Powered by Yelp" contentView:v] autorelease];
    pv.delegate = self;
    [pv showWithSize:v.frame.size inView:self.view];
}

- (void)rightAction {
    
    CheckinViewController *vc = [[[CheckinViewController alloc] initWithDictionary:self.venueDict] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
    return;
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#checkin"];
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Foursquare" message:[NSString stringWithFormat:@"Check in to %@ on Foursquare?", [self.venueDict objectForKey:@"name"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
    av.tag = kAlertTagFoursquare;
    [av show];
    
    return;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"foursquare:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", [self.venueDict objectForKey:@"id"]]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://foursquare.com/touch/v/%@", [self.venueDict objectForKey:@"id"]]]];
    }
}

- (void)zoomMap:(UITapGestureRecognizer *)gr {
    if (![PSZoomView prepareToZoom]) {
        return;
    }
    
    MKMapView *v = (MKMapView *)gr.view;

    CGRect convertedFrame = [self.view.window convertRect:v.frame fromView:v.superview];
    [PSZoomView showMapView:v withFrame:convertedFrame inView:self.view.window fullscreen:YES];
    
    [self.mapView selectAnnotation:[[self.mapView annotations] lastObject] animated:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#zoomMap"];
}

- (void)pushTips:(UITapGestureRecognizer *)gr {
    TipListViewController *vc = [[[TipListViewController alloc] initWithDictionary:self.venueDict] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#tips"];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#load"];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#reload"];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    DLog(@"remote data source did error");
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    [self.requestQueue addOperationWithBlock:^{
        NSString *URLPath = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos", [self.venueDict objectForKey:@"id"]];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:FS_API_VERSION forKey:@"v"];
        [parameters setObject:@"venue" forKey:@"group"];
        [parameters setObject:[NSNumber numberWithInteger:500] forKey:@"limit"];
        [parameters setObject:@"2CPOOTGBGYH53Q2LV3AORUF1JO0XV0FZLU1ZSZ5VO0GSKELO" forKey:@"client_id"];
        [parameters setObject:@"W45013QS5ADELZMVZYIIH3KX44TZQXDN0KQN5XVRN1JPJVGB" forKey:@"client_secret"];
        
        NSURL *URL = [NSURL URLWithString:URLPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
        
        [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypePermanent usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
            if (error) {
                [self dataSourceDidError];
            } else {
                [[[[NSOperationQueue alloc] init] autorelease] addOperationWithBlock:^{
                    id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                    if (!apiResponse) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self dataSourceDidError];
                        }];
                    } else {
                        // Process 4sq response
                        NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                        NSDictionary *response = [apiResponse objectForKey:@"response"];
                        NSArray *photos = [[response objectForKey:@"photos"] objectForKey:@"items"];
                        if (photos && [photos count] > 0) {
                            for (NSDictionary *photo in photos) {
                                NSDictionary *user = [photo objectForKey:@"user"];
                                NSString *firstName = [NSString stringWithFormat:@"%@", [user objectForKey:@"firstName"]];
                                NSString *name = ([user objectForKey:@"lastName"]) ? [firstName stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : firstName;
                                NSDictionary *sizes = [photo objectForKey:@"sizes"];
                                NSDictionary *fullSize = [[sizes objectForKey:@"items"] objectAtIndex:0];
                                
                                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                                [item setObject:[fullSize objectForKey:@"url"] forKey:@"source"];
                                [item setObject:[fullSize objectForKey:@"width"] forKey:@"width"];
                                [item setObject:[fullSize objectForKey:@"height"] forKey:@"height"];
                                [item setObject:name forKey:@"name"];
                                [item setObject:[user objectForKey:@"homeCity"] forKey:@"homeCity"];
                                [items addObject:item];
                            }
                        } else {
                            NSLog(@"No photos found");
                        }
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            self.contentOffset = self.collectionView.contentOffset.y > 0 ? self.collectionView.contentOffset : CGPointZero;
                            self.items = items;
                            [self dataSourceDidLoad];
                            
                            // If this is the first load and we loaded cached data, we should refreh from remote now
                            if (!self.hasLoadedOnce && isCached) {
                                self.hasLoadedOnce = YES;
                                [self reloadDataSource];
                                NSLog(@"first load, stale cache");
                            }
                        }];
                    }
                }];
            }
        }];
    }];
}

#pragma mark - PSCollectionViewDelegate
- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    PhotoView *v = (PhotoView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[[PhotoView alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    [v fillViewWithObject:item];
    
    return v;
    
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [PhotoView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(UIView *)view atIndex:(NSInteger)index {
    PhotoView *v = (PhotoView *)view;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = v.imageView;
    if (!imageView.image) return;
    
    // make sure to zoom the full res image here
    NSURL *originalURL = imageView.originalURL;
    UIActivityIndicatorViewStyle oldStyle = imageView.loadingIndicator.activityIndicatorViewStyle;
    imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView.loadingIndicator startAnimating];
    
    [[PSURLCache sharedCache] loadURL:originalURL cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        [imageView.loadingIndicator stopAnimating];
        imageView.loadingIndicator.activityIndicatorViewStyle = oldStyle;
        
        if (!error) {
            UIImage *sourceImage = [UIImage imageWithData:cachedData];
            if (sourceImage) {
                CGRect convertedFrame = [self.view.window convertRect:imageView.frame fromView:imageView.superview];
                
                if ([PSZoomView prepareToZoom]) {
                    [PSZoomView showImage:imageView.image withFrame:convertedFrame inView:self.view.window];
                    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"venueDetail#zoom"];
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
        v = [[[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
        v.canShowCallout = YES;
        v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"View Directions" message:[NSString stringWithFormat:@"Open %@ in Google Maps?", [view.annotation title]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
    av.tag = kAlertTagDirections;
    [av show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    
    if (alertView.tag == kAlertTagDirections) {
        // Show directions
        CLLocationCoordinate2D currentLocation = [[PSLocationCenter defaultCenter] locationCoordinate];
        NSString *lat = [self.venueDict objectForKey:@"lat"];
        NSString *lng = [self.venueDict objectForKey:@"lng"];
        
        if (lat && lng) {
            NSString *mapsUrl = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@", currentLocation.latitude, currentLocation.longitude, lat, lng];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsUrl]];
        }
    } else if (alertView.tag == kAlertTagFoursquare) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"foursquare:"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", [self.venueDict objectForKey:@"id"]]]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://foursquare.com/touch/v/%@", [self.venueDict objectForKey:@"id"]]]];
        }
    }
}

#pragma mark - Button Actions
- (void)openPhone:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"phone"]]]];
}

- (void)openWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.venueDict objectForKey:@"url"]]];
}

@end
