//
//  RootViewController.m
//  Mosaic
//
//  Created by Peter Shih on 10/26/12.
//
//

#import "RootViewController.h"
#import "PhotoTileViewCell.h"

@interface RootViewController ()

@property (nonatomic, strong) NSString *albumId;

@end

@implementation RootViewController

#pragma mark - Init

- (id)initWithAlbumId:(NSString *)albumId {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.albumId = albumId;
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
        
        self.headerHeight = 0.0;
        self.footerHeight = 0.0;
        
        self.headerRightWidth = 0.0;
        
        self.limit = 50;
        
        self.albumId = @"10152224225230652"; // DEBUG
        // 10152224225230652 // wedding
        // 10150888525010652
        // 10152256941535565
        // 10150188075865565 // Mobile

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appForegrounded:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBackgrounded:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appForegrounded:(NSNotification *)notification {
    [self reloadDataSource];
}

- (void)appBackgrounded:(NSNotification *)notification {
    
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
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
}

#pragma mark - Data Source

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
    // Parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *accessToken = @"AAACEHeoZBHTABAA7OIhzAcovNH3PmBBCgcQ005c1VkZC06zCaZAm1ZAQ5snXYg2VedPsiIfdi2kfpZADRbZCGR5iymMFDIBLHGrGE5tdSP3gZDZD";
    [parameters setObject:accessToken forKey:@"access_token"];
    [parameters setObject:@"U" forKey:@"date_format"];
    
    [parameters setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    [parameters setObject:[NSNumber numberWithInteger:self.offset] forKey:@"offset"];
    
    // Headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos", self.albumId];
    
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
                id apiData = [apiResponse objectForKey:@"data"];
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

- (NSArray *)templateForTileView:(PSTileView *)tileView {
    NSArray *template;
    
    if(isDeviceIPad()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            NSArray *row1 = @[@"A", @"A", @"B"];
            NSArray *row2 = @[@"A", @"A", @"D"];
            NSArray *row3 = @[@"V", @"V", @"E"];
            NSArray *row4 = @[@"G", @"H", @"E"];
            NSArray *row5 = @[@"A", @"B", @"B"];
            NSArray *row6 = @[@"A", @"M", @"Z"];
            NSArray *row7 = @[@"Y", @"U", @"U"];
            NSArray *row8 = @[@"T", @"B", @"Z"];
            template = @[row1, row2, row3, row4, row5, row6, row7, row8];
        } else {
            NSArray *row1 = @[@"A", @"A", @"B", @"C"];
            NSArray *row2 = @[@"A", @"A", @"D", @"D"];
            NSArray *row3 = @[@"A", @"A", @"E", @"E"];
            NSArray *row4 = @[@"G", @"H", @"E", @"E"];
            NSArray *row5 = @[@"A", @"B", @"C", @"D"];
            NSArray *row6 = @[@"A", @"B", @"Z", @"Z"];
            NSArray *row7 = @[@"Y", @"U", @"U", @"V"];
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
    
    id cell = [tileView dequeueReusableCellForClass:[PhotoTileViewCell class]];
    if (!cell) {
        cell = [[[PhotoTileViewCell class] alloc] initWithFrame:CGRectZero];
    }
    
    [cell tileView:tileView fillCellWithObject:item atIndex:index];
    
    return cell;
}

- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
}


@end
