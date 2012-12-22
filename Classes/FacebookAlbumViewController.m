//
//  FacebookAlbumViewController.m
//  Grid
//
//  Created by Peter Shih on 12/21/12.
//
//

#import "FacebookAlbumViewController.h"
#import "ImagePickerViewController.h"

#import "SliceCell.h"

@interface FacebookAlbumViewController ()

@end

@implementation FacebookAlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = YES;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.headerRightWidth = 0.0;
        
        self.title = @"Facebook Albums";
        
        self.nullBackgroundColor = [self baseBackgroundColor];
        self.nullLabelStyle = @"loadingLightLabel";
        self.nullIndicatorStyle = UIActivityIndicatorViewStyleWhite;
        
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

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    //    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)leftAction {
    // Dismiss
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

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    // Parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[FBSession activeSession].accessToken forKey:@"access_token"];
    
    // Headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"https://graph.facebook.com/me/albums"];
    
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
                    
                    NSMutableArray *albums = [NSMutableArray array];
                    for (NSDictionary *apiAlbum in apiData) {
                        
                        // https://graph.facebook.com/10152383880505565/picture?access_token=AAACEdEose0cBAEwgExuYkWlgEVLxk1Tu2U4Ra33zrB3hg7tkNY0QuIHIMjNY0aRnKZBk7wlJS1rMGhIVjWSUTIhJZAqkQc58d8BLsM9wZDZD
                        NSString *imagePath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [apiAlbum objectForKey:@"cover_photo"], [FBSession activeSession].accessToken];
                        NSDictionary *album = @{@"source" : @"facebook", @"albumId" : [apiAlbum objectForKey:@"id"], @"name" : [apiAlbum objectForKey:@"name"], @"image" : imagePath};
                        [albums addObject:album];
                    }
                    
                    [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:albums] animated:YES];
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
    
    ImagePickerViewController *vc = [[ImagePickerViewController alloc] initWithDictionary:item];
    vc.delegate = self.parentDelegate;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
