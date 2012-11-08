//
//  BrandItemsViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 10/30/12.
//
//

#import "BrandItemsViewController.h"
#import "PSWebViewController.h"
#import "ItemCollectionViewCell.h"

#import "PSInfoPopoverView.h"

@interface BrandItemsViewController ()

@property (nonatomic, strong) NSString *brand;

@end

@implementation BrandItemsViewController

#pragma mark - Init

- (id)initWithBrand:(NSString *)brand title:(NSString *)title {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.brand = brand;
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
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.headerRightWidth = 0.0;
        
        self.limit = 25;
    }
    return self;
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
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTutorialAirbrite"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showTutorialAirbrite"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        PSInfoPopoverView *ipv = [[PSInfoPopoverView alloc] initWithMessage:@"Shop and browse popular brands and products from within the app.\r\n\r\nBuying is as simple as tapping on something you like!"];
        [ipv showInView:self.view];
    }
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
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
//    [self.rightButton setImage:[UIImage imageNamed:@"IconShareWhite"] forState:UIControlStateNormal];
//    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
//    self.rightButton.userInteractionEnabled = NO;
}

- (void)setupFooter {
    [super setupFooter];
}


#pragma mark - Actions

- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
}

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
    NSString *URLPath = [NSString stringWithFormat:@"%@/v3/brands/%@", API_BASE_URL, self.brand];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    [parameters setObject:[NSNumber numberWithInteger:self.offset] forKey:@"offset"];
    
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
                // List of Venues
                id apiData = [apiResponse objectForKey:@"products"];
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
                // Error in apiResponse
                [self dataSourceDidError];
            }
        }
    }];
}

#pragma mark - PSCollectionViewDelegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [ItemCollectionViewCell class];
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

    NSDictionary *item = [self.items objectAtIndex:index];
    NSString *_id = [item objectForKey:@"_id"];
    NSString *name = [item objectForKey:@"name"];
//    NSString *url = [item objectForKey:@"url"];
    
    NSString *urlPath = [NSString stringWithFormat:@"http://cortex.airbrite.io/items/%@", _id];
    
    PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlPath title:name];
    [self.navigationController pushViewController:vc animated:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Brand: Item clicked" attributes:[NSDictionary dictionaryWithObjectsAndKeys:_id, @"id", name, @"name", nil]];
}


@end
