//
//  SectionsViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 10/26/12.
//
//

#import "SectionsViewController.h"

#import "VenuesViewController.h"
#import "ChannelsViewController.h"
#import "BrandItemsViewController.h"

#import "SliceCell.h"

@interface SectionsViewController ()

@end

@implementation SectionsViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = YES;
        
        self.headerHeight = 0.0;
        self.footerHeight = 0.0;
        
        self.title = @"Channels";
        
        self.nullBackgroundColor = [self baseBackgroundColor];
        self.nullLabelStyle = @"loadingLightLabel";
        self.nullIndicatorStyle = UIActivityIndicatorViewStyleWhite;
        
        // Table
        self.tableViewStyle = UITableViewStylePlain;
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = [UIColor lightGrayColor];
        
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
    return TEXTURE_DARK_WOOD;
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

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
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

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    // Parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"%@/v3/sections", API_BASE_URL];
    
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
                id apiData = [apiResponse objectForKey:@"sections"];
                if (apiData && [apiData isKindOfClass:[NSArray class]]) {
                    
                    [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:apiData] animated:NO];
                    [self dataSourceDidLoad];
                } else {
                    [self dataSourceDidError];
                }
            } else {
                [self dataSourceDidError];
            }
        }
    }];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

#pragma mark - TableView

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [SliceCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Special override to fit screen heights
    if (isDeviceIPad()) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            return 260.0;
        } else {
            return 350.0;
        }
    } else {
        if (isDeviceIPhone5() ) {
            return 137.0;
        } else {
            return 115.0;
        }
    }
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:item atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *slug = [item objectForKey:@"slug"];
    NSString *query = [item objectForKey:@"query"];
    NSString *type = [item objectForKey:@"type"];
    NSString *name = [item objectForKey:@"name"];
    
    id vc = nil;
    if ([type isEqualToString:@"foursquare"]) {
        vc = [[VenuesViewController alloc] initWithCategory:slug query:query title:name];
    } else if ([type isEqualToString:@"brand"]) {
        vc = [[BrandItemsViewController alloc] initWithBrand:slug title:name];
    } else if ([type isEqualToString:@"subsection"]) {
        vc = [[ChannelsViewController alloc] initWithSection:slug title:name];
    }
    [self.navigationController pushViewController:vc animated:YES];
}


@end
