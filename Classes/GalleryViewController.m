//
//  GalleryViewController.m
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"
#import "TipListViewController.h"
#import "GalleryView.h"
#import "PSZoomView.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

@implementation GalleryViewController

@synthesize
venueDict = _venueDict,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
mapView = _mapView;

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
    self.mapView.delegate = nil;
    self.mapView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.venueDict = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
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
    [self.view addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease]];
    
    [self setupHeader];
    
    self.collectionView = [[[PSCollectionView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height)] autorelease];
    self.collectionView.delegate = self; // scrollViewDelegate
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.numCols = 2;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
    
    // Setup collectionView header
    // 2 part collection header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.width, 160)] autorelease];
    
    // Map
    UIView *mapView = [[[UIView alloc] initWithFrame:CGRectMake(8, 8, headerView.width - 16, 148)] autorelease];
    mapView.backgroundColor = [UIColor whiteColor];
    UIImage *mapShadowImage = [[UIImage imageNamed:@"Shadow"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    UIImageView *mapShadowView = [[[UIImageView alloc] initWithImage:mapShadowImage] autorelease];
    mapShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapShadowView.frame = CGRectInset(mapView.bounds, -1, -2);
    [mapView addSubview:mapShadowView];
    [headerView addSubview:mapView];
    
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(4, 4, 296, 140)] autorelease];
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
    
    // Tip
    // Don't show if no tips
    if ([self.venueDict objectForKey:@"tip"]) {
        UIView *tipView = [[[UIView alloc] initWithFrame:CGRectMake(8, mapView.bottom + 8.0, headerView.width - 16, 148)] autorelease];
        tipView.backgroundColor = [UIColor whiteColor];
        UIImage *tipShadowImage = [[UIImage imageNamed:@"Shadow"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
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
        
        UILabel *tipLabel = [UILabel labelWithStyle:@"bodyLabel"];
        
        tipLabel.text = [NSString stringWithFormat:@"\"%@\"", [[self.venueDict objectForKey:@"tip"] objectForKey:@"text"]];
        labelSize = [PSStyleSheet sizeForText:tipLabel.text width:(tipView.width - 16.0) style:@"bodyLabel"];
        tipLabel.frame = CGRectMake(8, 4, tipWidth, labelSize.height);
        [tipView addSubview:tipLabel];
        
        divider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        divider.frame = CGRectMake(4, tipLabel.bottom + 4, tipWidth, 1.0);
        [tipView addSubview:divider];
        
        UILabel *countLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        countLabel.text = [NSString stringWithFormat:@"View All %@ Tips", [self.venueDict objectForKey:@"tipCount"]];
        labelSize = [PSStyleSheet sizeForText:countLabel.text width:(tipView.width - 16.0) style:@"subtitleLabel"];
        countLabel.frame = CGRectMake(8, divider.bottom + 4, tipWidth, labelSize.height);
        [tipView addSubview:countLabel];
        
        CGFloat tipHeight = countLabel.bottom + 4;
        tipView.height = tipHeight;
        
        UIImageView *disclosure = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicatorWhiteBordered"]] autorelease];
        disclosure.contentMode = UIViewContentModeCenter;
        disclosure.frame = CGRectMake(tipView.width - 20, 0, 20, tipView.height);
        [tipView addSubview:disclosure];
        headerView.height += tipView.height + 12;
    } else {
        headerView.height += 4;
    }
    
    self.collectionView.headerView = headerView;
    
    [self.view addSubview:self.collectionView];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockLeft" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"timelineTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockCenter" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.centerButton setTitle:[self.venueDict objectForKey:@"name"] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockRight" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconPinBlack"] forState:UIControlStateNormal];
    
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
    
}

- (void)rightAction {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gallery#checkin"];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"foursquare:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", [self.venueDict objectForKey:@"id"]]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://foursquare.com/touch/v/%@", [self.venueDict objectForKey:@"id"]]]];
    }
}

- (void)zoomMap:(UITapGestureRecognizer *)gr {
    MKMapView *v = (MKMapView *)gr.view;
    
    NSLog(@"frame: %@", NSStringFromCGRect(v.frame));
    CGRect convertedRect = [v.superview convertRect:v.frame toView:nil];
    PSZoomView *zoomView = [[[PSZoomView alloc] initWithMapView:v mapRegion:v.region superView:v.superview] autorelease];
    [zoomView removeFromSuperview];
    [zoomView showInRect:convertedRect];
}

- (void)pushTips:(UITapGestureRecognizer *)gr {
    TipListViewController *vc = [[[TipListViewController alloc] initWithDictionary:self.venueDict] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gallery#tips"];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gallery#load"];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gallery#reload"];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    [self.collectionView reloadViews];
    
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
    NSString *URLPath = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos", [self.venueDict objectForKey:@"id"]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"20120222" forKey:@"v"];
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
                id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                if (!JSON) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self dataSourceDidError];
                    }];
                } else {
                    // Process 4sq response
                    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                    NSDictionary *response = [JSON objectForKey:@"response"];
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
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            self.items = items;
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
                            NSLog(@"# ERROR with JSON: %@", JSON);
                            [self dataSourceDidError];
                        }];
                    }
                }
            }];
        }
    }];
}

#pragma mark - PSCollectionViewDelegate
- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    GalleryView *v = (GalleryView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[[GalleryView alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    [v fillViewWithObject:item];
    
    return v;
    
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [GalleryView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(UIView *)view atIndex:(NSInteger)index {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"gallery#zoom"];
    // ZOOM
    static BOOL isZooming;
    
    GalleryView *v = (GalleryView *)view;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = v.imageView;
    if (!imageView.image) return;
    
    // If already zooming, don't rezoom
    if (isZooming) return;
    else isZooming = YES;
    
    // make sure to zoom the full res image here
    NSURL *originalURL = imageView.originalURL;
    UIActivityIndicatorViewStyle oldStyle = imageView.loadingIndicator.activityIndicatorViewStyle;
    imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView.loadingIndicator startAnimating];
    
    [[PSURLCache sharedCache] loadURL:originalURL cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        [imageView.loadingIndicator stopAnimating];
        imageView.loadingIndicator.activityIndicatorViewStyle = oldStyle;
        isZooming = NO;
        
        if (!error) {
            UIImage *sourceImage = [UIImage imageWithData:cachedData];
            if (sourceImage) {
                UIViewContentMode contentMode = imageView.contentMode;
                CGRect convertedRect = [imageView.superview convertRect:imageView.frame toView:nil];
                PSZoomView *zoomView = [[[PSZoomView alloc] initWithImage:sourceImage contentMode:contentMode] autorelease];
                [zoomView showInRect:convertedRect];
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
        v.canShowCallout = NO;
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    [mapView selectAnnotation:[[mapView annotations] lastObject] animated:NO];
}

@end
