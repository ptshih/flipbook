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
@property (nonatomic, strong) NSMutableArray *sortedItems;

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
        
        self.albumId = @"10150188075865565"; // DEBUG
        // 10152224225230652 // wedding
        // 10150888525010652
        // 10152256941535565
        // 10150188075865565 // Mobile
        
        self.sortedItems = [NSMutableArray array];

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
    
    NSString *accessToken = @"AAACEHeoZBHTABALMX2gNSN1apHGMfJtnsbYgfMl5MwJQ1mGXWEzAgE81NeZAgw2Ez6PAsxtji4AQuLGqZBY9hvQ1dFke5EZD";
    [parameters setObject:accessToken forKey:@"access_token"];
    [parameters setObject:@"U" forKey:@"date_format"];
    
    [parameters setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    [parameters setObject:[NSNumber numberWithInteger:self.offset] forKey:@"offset"];
    
    // Headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos", self.albumId];
    
//    NSString *URLPath = [NSString stringWithFormat:@"http://imgur.com/gallery/%@.json", @"hot"];
    
//    NSString *URLPath = [NSString stringWithFormat:@"http://localhost:3012/%@.json", @"articles"];
    
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
            NSArray *row2 = @[@"A", @"A", @"C"];
            NSArray *row3 = @[@"D", @"D", @"C"];
            NSArray *row4 = @[@"F", @"G", @"H"];
            NSArray *row5 = @[@"F", @"J", @"J"];
            NSArray *row6 = @[@"I", @"J", @"J"];
            NSArray *row7 = @[@"N", @"O", @"O"];
            NSArray *row8 = @[@"N", @"Q", @"R"];
            template = @[row1, row2, row3, row4, row5, row6, row7, row8];
        } else {
            NSArray *row1 = @[@"A", @"A", @"B", @"C"];
            NSArray *row2 = @[@"A", @"A", @"D", @"D"];
            NSArray *row3 = @[@"E", @"E", @"F", @"F"];
            NSArray *row4 = @[@"G", @"H", @"F", @"F"];
            NSArray *row5 = @[@"I", @"J", @"K", @"L"];
            NSArray *row6 = @[@"M", @"J", @"N", @"N"];
            NSArray *row7 = @[@"O", @"P", @"P", @"Q"];
            NSArray *row8 = @[@"R", @"S", @"T", @"Q"];
            template = @[row1, row2, row3, row4, row5, row6, row7, row8];
        }
    } else {
        NSArray *row1 = @[@"A", @"A"];
        NSArray *row2 = @[@"A", @"A"];
        NSArray *row3 = @[@"B", @"C"];
        NSArray *row4 = @[@"D", @"D"];
        NSArray *row5 = @[@"E", @"F"];
        NSArray *row6 = @[@"E", @"G"];
        NSArray *row7 = @[@"H", @"I"];
        NSArray *row8 = @[@"J", @"I"];
        template = @[row1, row2, row3, row4, row5, row6, row7, row8];
    }
    
    return template;
}

- (void)tileView:(PSTileView *)tileView didReloadTemplateWithMap:(NSMutableDictionary *)indexToRectMap {
    
    if (self.items.count == 0 || indexToRectMap.count == 0) return;
    
    NSInteger len = self.items.count - self.offset;
    if (len <= 0) {
        return;
    }
    
    NSMutableArray *subarray = [NSMutableArray array];
    [subarray addObjectsFromArray:[self.items subarrayWithRange:NSMakeRange(self.offset, len)]];
    
//    NSLog(@"%@", indexToRectMap);
    
    NSArray *sortedKeys = [[indexToRectMap allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    NSMutableArray *sortedItems = [NSMutableArray array];
    
    for (int i = 0; i < sortedKeys.count; i++) {
        NSString *rectString = [indexToRectMap objectForKey:[NSString stringWithFormat:@"%d", i]];
        CGRect rect = CGRectFromString(rectString);
        CGFloat w = rect.size.width;
        CGFloat h = rect.size.height;
        NSLog(@"w: %f, h: %f", rect.size.width, rect.size.height);
        
        // 0 - square
        // 1 - landscape
        // 2 - portrait
        NSInteger type = 0;
        if (w > h) {
            type = 1;
        } else if (w < h) {
            type = 2;
        } else {
            type = 0;
        }
        
        NSLog(@"type: %d", type);
        

        NSDictionary *pItem, *lItem, *sItem;
        
        for (int j = 0; j < subarray.count; j++) {
            NSDictionary *item = [subarray objectAtIndex:j];
            CGFloat iw = [[item objectForKey:@"width"] floatValue];
            CGFloat ih = [[item objectForKey:@"height"] floatValue];
            
            NSInteger itype = 0;
            if (iw > ih) {
                itype = 1;
            } else if (iw < ih) {
                itype = 2;
            } else {
                itype = 0;
            }
            
            if (!pItem && itype == 2) {
                pItem = item;
            }
            if (!lItem && itype == 2) {
                lItem = item;
            }
            if (!sItem && itype == 0) {
                sItem = item;
            }
            
            
            if (itype == type) {
                [sortedItems addObject:item];
                [subarray removeObject:item];
                break;
            } else if (j == subarray.count - 1) {
                // Pick best fit for type
                NSDictionary *chosenItem = nil;
                switch (itype) {
                    case 0:
                        if (sItem) {
                            chosenItem = sItem;
                        } else if (lItem) {
                            chosenItem = lItem;
                        } else if (pItem) {
                            chosenItem = pItem;
                        }
                        break;
                    case 1:
                        if (lItem) {
                            chosenItem = lItem;
                        } else if (sItem) {
                            chosenItem = sItem;
                        } else if (pItem) {
                            chosenItem = pItem;
                        }
                        break;
                    case 2:
                        if (pItem) {
                            chosenItem = pItem;
                        } else if (sItem) {
                            chosenItem = sItem;
                        } else if (lItem) {
                            chosenItem = lItem;
                        }
                        break;
                    default:
                        break;
                }
                if (chosenItem) {
                    [sortedItems addObject:chosenItem];
                    [subarray removeObject:chosenItem];
                }
                break;
            }
        }
    }
    
    if (self.loadingMore) {
        [self.sortedItems addObjectsFromArray:sortedItems];
    } else {
        self.sortedItems = [NSMutableArray arrayWithArray:sortedItems];
    }

    
//    NSLog(@"%@", self.items);
    
//    for(NSString *rectString in indexToRectMap) {
//        NSLog(@"%@", rectString);
//    }
}

- (PSTileViewCell *)tileView:(PSTileView *)tileView cellForItemAtIndex:(NSInteger)index {
    NSDictionary *item = [self.sortedItems objectAtIndex:index];
    
    id cell = [tileView dequeueReusableCellForClass:[PhotoTileViewCell class]];
    if (!cell) {
        cell = [[[PhotoTileViewCell class] alloc] initWithFrame:CGRectZero];
    }
    
    [cell tileView:tileView fillCellWithObject:item atIndex:index];
    
    return cell;
}

- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [self.sortedItems objectAtIndex:index];
}


@end
