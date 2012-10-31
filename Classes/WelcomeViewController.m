//
//  WelcomeViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 10/26/12.
//
//

#import "WelcomeViewController.h"

#import "VenueListViewController.h"
#import "BrandViewController.h"

#import "ChannelCell.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

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
        
        // Table
        self.tableViewStyle = UITableViewStylePlain;
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = [UIColor lightGrayColor];
    }
    return self;
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
    
    [self loadDataSourceFromRemoteUsingCache:NO];
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
    NSString *URLPath = [NSString stringWithFormat:@"%@/v3/channels", API_BASE_URL];
    
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
                id apiData = [apiResponse objectForKey:@"channels"];
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
            return [ChannelCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeightForObject:item atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:item atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *slug = [item objectForKey:@"slug"];
    NSString *type = [item objectForKey:@"type"];
    NSString *name = [item objectForKey:@"name"];
    
    id vc = nil;
    if ([type isEqualToString:@"foursquare"]) {
        vc = [[VenueListViewController alloc] initWithCategory:slug];
    } else if ([type isEqualToString:@"airbrite"]) {
        vc = [[BrandViewController alloc] initWithChannel:slug title:name];
    }
    [self.navigationController pushViewController:vc animated:YES];
}


@end
