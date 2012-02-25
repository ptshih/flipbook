//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "PSZoomView.h"
#import "TimelineView.h"

@interface TimelineViewController (Private)

- (void)refreshOnAppear;

@end

@implementation TimelineViewController

@synthesize
items = _items,
collectionView = _collectionView,
pullRefreshView = _pullRefreshView,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
shouldRefreshOnAppear = _shouldRefreshOnAppear;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldRefreshOnAppear = NO;
        
        self.items = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:kPSLocationCenterDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnAppear) name:kTimelineShouldRefreshOnAppear object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    // Views
    self.pullRefreshView = nil;
    self.collectionView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.items = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSLocationCenterDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefreshOnAppear object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Views
    self.pullRefreshView = nil;
    self.collectionView = nil;
    [super dealloc];
}

- (void)refreshOnAppear {
    self.shouldRefreshOnAppear = YES;
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

//- (UIView *)baseBackgroundView {
//  UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCloth.jpg"]] autorelease];
//  return bgView;
//}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup Views
    [self setupSubviews];
//    [self setupPullRefresh];
    
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
    [self.view addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease]];
    
    [self setupHeader];
    
    self.collectionView = [[[PSCollectionView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height)] autorelease];
    self.collectionView.delegate = self; // scrollViewDelegate
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.numCols = 2;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
    
    [self.view addSubview:self.collectionView];
    
    if (self.pullRefreshView == nil) {
        self.pullRefreshView = [[[PSPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0 - 48.0, self.view.frame.size.width, 48.0) style:PSPullRefreshStyleBlack] autorelease];
        self.pullRefreshView.scrollView = self.collectionView;
        self.pullRefreshView.delegate = self;
        [self.collectionView addSubview:self.pullRefreshView];		
    }
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockLeft" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"timelineTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockCenter" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockRight" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconClockBlack"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
}

- (void)centerAction {
}

- (void)rightAction {
}

- (void)locationDidUpdate {
    [self reloadDataSource];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#load"];
}

- (void)reloadDataSource {
    [super reloadDataSource];

    [self loadDataSourceFromRemoteUsingCache:NO];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#reload"];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    [self.collectionView reloadViews];
    
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
    BLOCK_SELF;
    
    if (![[PSLocationCenter defaultCenter] hasAcquiredAccurateLocation]) {
        return;
    }
    
    NSString *ll = [NSString stringWithFormat:@"%@", [[PSLocationCenter defaultCenter] locationString]];
    
    NSString *URLPath = @"https://api.foursquare.com/v2/venues/explore";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:ll forKey:@"ll"];
//    [parameters setObject:[NSNumber numberWithInteger:800] forKey:@"radius"];
    [parameters setObject:@"20120222" forKey:@"v"];
    [parameters setObject:[NSNumber numberWithInteger:1] forKey:@"venuePhotos"];
    [parameters setObject:@"food" forKey:@"section"];
    [parameters setObject:[NSNumber numberWithInteger:50] forKey:@"limit"];
    [parameters setObject:@"2CPOOTGBGYH53Q2LV3AORUF1JO0XV0FZLU1ZSZ5VO0GSKELO" forKey:@"client_id"];
    [parameters setObject:@"W45013QS5ADELZMVZYIIH3KX44TZQXDN0KQN5XVRN1JPJVGB" forKey:@"client_secret"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypePermanent usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        if (error) {
            [blockSelf dataSourceDidError];
        } else {
            [[[[NSOperationQueue alloc] init] autorelease] addOperationWithBlock:^{
                id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                if (!JSON) {
                    // invalid json
                    [blockSelf dataSourceDidError];
                } else {
                    // Process 4sq response
                    NSDictionary *response = [JSON objectForKey:@"response"];
                    NSArray *groups = [response objectForKey:@"groups"];
                    if (groups && [groups count] > 0) {
                        // Format the response for our consumption
                        NSMutableArray *items = [NSMutableArray array];
                        for (NSDictionary *dict in [[groups objectAtIndex:0] objectForKey:@"items"]) {
                            NSDictionary *venue = [dict objectForKey:@"venue"];
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
                            [item setObject:[location objectForKey:@"address"] forKey:@"address"];
                            [item setObject:[location objectForKey:@"distance"] forKey:@"distance"];
                            [item setObject:[featuredPhotoItem objectForKey:@"width"] forKey:@"width"];
                            [item setObject:[featuredPhotoItem objectForKey:@"height"] forKey:@"height"];
                            [item setObject:[featuredPhotoItem objectForKey:@"url"] forKey:@"source"];
                            
                            [items addObject:item];
                        }
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            blockSelf.items = items;
                            [blockSelf dataSourceDidLoad];
                            
                            // If this is the first load and we loaded cached data, we should refreh from remote now
                            if (!blockSelf.hasLoadedOnce && isCached) {
                                blockSelf.hasLoadedOnce = YES;
                                [blockSelf reloadDataSource];
                                NSLog(@"first load, stale cache");
                            }
                        }];
                    } else {
                        // error
                        [blockSelf dataSourceDidError];
                    }
                }
            }];
        }
    }];
}

#pragma mark - PSCollectionViewDelegate
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [self.items count];
}

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
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"foursquare:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", [item objectForKey:@"id"]]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://foursquare.com/touch/v/%@", [item objectForKey:@"id"]]]];
    }
    
    return;
    
    // ZOOM
    static BOOL isZooming;
    
    TimelineView *timelineView = (TimelineView *)view;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = timelineView.imageView;
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
                PSZoomView *zoomView = [[[PSZoomView alloc] initWithImage:sourceImage contentMode:contentMode] autorelease];
                CGRect imageRect = [timelineView convertRect:imageView.frame toView:collectionView];
                [zoomView showInRect:[collectionView convertRect:imageRect toView:nil]];
            }
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidEndDragging:scrollView
                                                   willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    [[PSURLCache sharedCache] suspend];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidScroll:scrollView];
    }
}

#pragma mark - PSPullRefreshViewDelegate
- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView {
    [self reloadDataSource];
}

#pragma mark - PSPopoverViewDelegate
- (void)popoverViewDidDismiss:(PSPopoverView *)popoverView {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dateRangeDidChange"]) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dateRangeDidChange"];
//        [self setDateRange];
//        [self reloadDataSource];
//    }
}

#pragma mark - PSErrorViewDelegate
- (void)errorViewDidDismiss:(PSErrorView *)errorView {
    [self reloadDataSource];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateRefreshing];
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
}

- (void)endRefresh {
    [super endRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateIdle];
    [SVProgressHUD dismiss];
}

@end
