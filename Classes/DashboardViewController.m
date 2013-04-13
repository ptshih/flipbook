//
//  DashboardViewController.m
//  Celery
//
//  Created by Peter Shih on 4/12/13.
//
//

#import "DashboardViewController.h"

@interface DashboardViewController ()

// Models
@property (nonatomic, copy) NSMutableArray *orders;

// Views
@property (nonatomic, strong) UILabel *ordersCounter;
@property (nonatomic, strong) UILabel *revenueCounter;

@end

@implementation DashboardViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Dashboard";
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = NO;
        
        self.headerHeight = 44.0;
        
        self.orders = [NSMutableArray array];
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
    
    UIView *o = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 40.0)];
    [self.contentView addSubview:o];
    
    // Order count
    self.ordersCounter = [UILabel labelWithStyle:@"h6DarkLabel"];
    self.ordersCounter.textAlignment = UITextAlignmentCenter;
    self.ordersCounter.frame = CGRectMake(0, 0, o.width, 20.0);
    [o addSubview:self.ordersCounter];

    // Revenue count
    self.revenueCounter = [UILabel labelWithStyle:@"h6DarkLabel"];
    self.revenueCounter.textAlignment = UITextAlignmentCenter;
    self.revenueCounter.frame = CGRectMake(0, 20.0, o.width, 20.0);
    [o addSubview:self.revenueCounter];
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
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
    PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Coming Soon"];
    [av setCancelButtonWithTitle:@"Ok" block:NULL];
    [av show];
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
    [self loadOrders];
    
    
    [self dataSourceDidLoad];
}

- (void)loadOrders {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@", [[UserManager sharedManager] accessToken], [[UserManager sharedManager] secret]];
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:authValue forKey:@"Authorization"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/orders", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:headers parameters:parameters];
    
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [self ordersDidError];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                NSArray *orders = [apiResponse objectForKey:@"orders"];
                self.orders = [NSMutableArray arrayWithArray:orders];
                [self ordersDidLoad];
            } else {
                [self ordersDidError];
            }
        }
    }];
}

- (void)ordersDidLoad {
    self.ordersCounter.text = [NSString stringWithFormat:@"Number of Orders: %d", [self.orders count]];
    
    NSInteger sum = 0;
    for (NSDictionary *order in self.orders) {
        if ([[order objectForKey:@"status"] isEqualToString:@"cancelled"] || [[order objectForKey:@"status"] isEqualToString:@"refunded_deposit"] || [[order objectForKey:@"status"] isEqualToString:@"refunded_balance"]) {
            continue;
        }
        sum += [[order objectForKey:@"total"] integerValue];
    }
    NSDecimalNumber *cents = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:sum] decimalValue]];
    NSDecimalNumber *dollars = [cents decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *revenue = [NSString stringWithFormat:@"Total Revenue: %@", [numberFormatter stringFromNumber:dollars]];
    self.revenueCounter.text = [NSString stringWithFormat:@"%@", revenue];
}

- (void)ordersDidError {
    
}

@end
