//
//  ProductsViewController.m
//  Celery
//
//  Created by Peter Shih on 4/12/13.
//
//

#import "ProductsViewController.h"
#import "ProductCollectionViewCell.h"

@interface ProductsViewController ()

@end

@implementation ProductsViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = YES;
        self.shouldPullRefresh = YES;
        
        self.headerHeight = 44.0;

        self.title = @"Products";
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return TEXTURE_LIGHT_SKETCH;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load
    [self loadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.slidingViewController.underRightViewController = nil;
    
    [self.headerView addGestureRecognizer:self.slidingViewController.panGesture];
    self.view.layer.shadowOpacity = 0.75;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
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
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconPlusWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

- (void)setupFooter {
    [super setupFooter];
}

#pragma mark - Actions

- (void)leftAction {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)centerAction {
}

- (void)rightAction {
}

#pragma mark - Data Source

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
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@", [[UserManager sharedManager] accessToken], [[UserManager sharedManager] secret]];
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:authValue forKey:@"Authorization"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/products", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:headers parameters:parameters];
    
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [self dataSourceDidError];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                NSArray *products = [apiResponse objectForKey:@"products"];
                self.items = [NSMutableArray arrayWithArray:products];
                [self dataSourceDidLoad];
            } else {
                [self dataSourceDidError];
            }
        }
    }];
}

#pragma mark - PSCollectionViewDelegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [ProductCollectionViewCell class];
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
}


@end
