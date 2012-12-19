//
//  BrandTileViewController.m
//  Mosaic
//
//  Created by Peter Shih on 12/4/12.
//
//

#import "BrandTileViewController.h"
#import "PSWebViewController.h"

#import "BrandTileViewCell.h"

@interface BrandTileViewController ()

@property (nonatomic, strong) NSString *brand;

@end

@implementation BrandTileViewController

#pragma mark - Init

- (id)initWithSlug:(NSString *)slug title:(NSString *)title {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.brand = slug;
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
    }
    return self;
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
                id apiData = [apiResponse objectForKey:@"items"];
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

#pragma mark - PSTileViewDelegate

- (NSMutableArray *)templateForTileView:(PSTileView *)tileView {
    NSArray *template;
    
    if(isDeviceIPad()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            NSArray *row1 = @[@"A", @"A", @"B"];
            NSArray *row2 = @[@"A", @"A", @"D"];
            NSArray *row3 = @[@"A", @"A", @"E"];
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
    
    id cell = [tileView dequeueReusableCellForClass:[BrandTileViewCell class]];
    if (!cell) {
        cell = [[[BrandTileViewCell class] alloc] initWithFrame:CGRectZero];
    }
    
    [cell tileView:tileView fillCellWithObject:item atIndex:index];
    
    return cell;
}

- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    NSString *_id = [item objectForKey:@"_id"];
    NSString *name = [item objectForKey:@"name"];
    //    NSString *url = [item objectForKey:@"url"];
    
    NSString *urlPath = [NSString stringWithFormat:@"http://cortex.airbrite.io/items/%@", _id];
    
    PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlPath title:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
