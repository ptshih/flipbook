//
//  ImagePickerViewController.m
//  Grid
//
//  Created by Peter Shih on 12/21/12.
//
//

#import "ImagePickerViewController.h"

#import "ImagePickerCollectionViewCell.h"
#import "InstagramPickerViewCell.h"
#import "LibraryPickerViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface ImagePickerViewController ()

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation ImagePickerViewController


- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.dictionary = dictionary;
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        
        if (![[self.dictionary objectForKey:@"source"] isEqualToString:@"library"]) {
            self.shouldPullRefresh = YES;
            self.shouldPullLoadMore = YES;
        }
        
        self.shouldShowNullView = YES;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.headerRightWidth = 0.0;
        
        self.title = @"Loading...";
        
        self.limit = 50;
        
        self.library = [[ALAssetsLibrary alloc] init];
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
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    if (isDeviceIPad()) {
        self.collectionView.numColsPortrait = 2;
        self.collectionView.numColsLandscape = 2;
    } else {
        self.collectionView.numColsPortrait = 2;
        self.collectionView.numColsLandscape = 2;
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
    
    NSString *title = nil;
    NSString *source = [self.dictionary objectForKey:@"source"];
    if ([source isEqualToString:@"instagram"]) {
        title = @"Instagram";
    } else if ([source isEqualToString:@"facebook"]) {
        title = [self.dictionary objectForKey:@"name"];
    } else {
        title = @"Photo Library";
    }
    self.title = title;
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)dataSourceDidLoadMore {
    [super dataSourceDidLoadMore];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSString *source = [self.dictionary objectForKey:@"source"];
    if ([source isEqualToString:@"instagram"]) {
        [self loadDataSourceFromInstagramUsingCache:usingCache];
    } else if ([source isEqualToString:@"facebook"]) {
        [self loadDataSourceFromFacebookUsingCache:usingCache];
    } else {
        [self loadDataSourceFromAssetsLibrary];
    }
}

- (void)loadDataSourceFromFacebookUsingCache:(BOOL)usingCache {
    // Parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *accessToken = [FBSession activeSession].accessToken;
    [parameters setObject:accessToken forKey:@"access_token"];
    [parameters setObject:@"U" forKey:@"date_format"];
    
    [parameters setObject:[NSNumber numberWithInteger:self.limit] forKey:@"limit"];
    [parameters setObject:[NSNumber numberWithInteger:self.offset] forKey:@"offset"];
    
    // Headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos", [self.dictionary objectForKey:@"albumId"]];
    
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

- (void)loadDataSourceFromInstagramUsingCache:(BOOL)usingCache {
//    https://api.instagram.com/v1/users/3/media/recent/?access_token=2275353.f59def8.40572794d9de40ccb360b6c54fa865dd
    
    // Parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"igAccessToken"];
    [parameters setObject:accessToken forKey:@"access_token"];
    
    [parameters setObject:[NSNumber numberWithInteger:self.limit] forKey:@"count"];
    if (self.minId) {
        [parameters setObject:self.minId forKey:@"min_id"];
    }
    if (self.maxId) {
        [parameters setObject:self.maxId forKey:@"max_id"];
    }
    
    // Headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent"];
    
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
                id apiPagination = [apiResponse objectForKey:@"pagination"];
                if (apiPagination) {
                    NSString *newMaxId = [apiPagination objectForKey:@"next_max_id"];
                    if (newMaxId) {
                        self.maxId = newMaxId;
                    } else {
                        self.minId = self.maxId;
                    }
                }
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

- (void)loadDataSourceFromAssetsLibrary {
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    ALAssetRepresentation *rep = result.defaultRepresentation;
                    NSDictionary *photo = @{@"asset" : result, @"width" : [NSNumber numberWithFloat:rep.dimensions.width], @"height" : [NSNumber numberWithFloat:rep.dimensions.height]};
                    [self.items addObject:photo];
                }
            }];
            [self performSelectorOnMainThread:@selector(dataSourceDidLoad) withObject:nil waitUntilDone:NO];
        }
    } failureBlock:^(NSError *error) {
    }];
}

#pragma mark - PSCollectionViewDelegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    NSString *source = [self.dictionary objectForKey:@"source"];
    if ([source isEqualToString:@"instagram"]) {
        return [InstagramPickerViewCell class];
    } else if ([source isEqualToString:@"facebook"]) {
        return [ImagePickerCollectionViewCell class];
    } else {
        return [LibraryPickerViewCell class];
    }
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
    NSDictionary *item = [self.items objectAtIndex:index];
    
    NSString *origUrl = nil;
    
    NSString *source = [self.dictionary objectForKey:@"source"];
    if ([source isEqualToString:@"instagram"]) {
        NSDictionary *image = [[item objectForKey:@"images"] objectForKey:@"standard_resolution"];
        origUrl = [image objectForKey:@"url"];
    } else if ([source isEqualToString:@"facebook"]) {
        origUrl = [item objectForKey:@"source"];
    }
    
    if ([source isEqualToString:@"library"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didPickImage:)]) {
            ALAsset *asset = [item objectForKey:@"asset"];
            ALAssetRepresentation *rep = asset.defaultRepresentation;
            UIImage *image = [UIImage imageWithCGImage:rep.fullScreenImage];
            [self.delegate imagePicker:self didPickImage:image];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didPickImageWithURLPath:)]) {
            [self.delegate imagePicker:self didPickImageWithURLPath:origUrl];
        }
    }
}

@end
