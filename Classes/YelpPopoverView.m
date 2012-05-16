//
//  YelpPopoverView.m
//  Lunchbox
//
//  Created by Peter Shih on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YelpPopoverView.h"
#import "PSPopoverView.h"

@interface YelpPopoverView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, copy) NSDictionary *yelpDict;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *loadingLabel;

- (void)loadDataSource;
- (void)dataSourceDidLoad;
- (void)dataSourceDidError;

@end

@implementation YelpPopoverView

@synthesize
venueDict = _venueDict,
yelpDict = _yelpDict,
items = _items,
tableView = _tableView,
loadingLabel = _loadingLabel;

- (id)initWithDictionary:(NSDictionary *)dictionary frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
        
        self.venueDict = dictionary;
        
        self.items = [NSMutableArray array];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
        self.loadingLabel = [UILabel labelWithText:@"Loading Yelp Rating..." style:@"emptyLabel"];
        self.loadingLabel.frame = self.bounds;
        [self addSubview:self.loadingLabel];
        
        // Load remote data
        [self loadDataSource];
    }
    return self;
}

- (void)loadDataSource {
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/yelp", API_BASE_URL];
    
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    NSString *ll = [NSString stringWithFormat:@"%@,%@", [location objectForKey:@"lat"], [location objectForKey:@"lng"]];
    NSString *q = [self.venueDict objectForKey:@"name"];
    NSString *venueId = [self.venueDict objectForKey:@"id"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:ll forKey:@"ll"];
    [parameters setObject:q forKey:@"q"];
    [parameters setObject:venueId forKey:@"venueId"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [self dataSourceDidError];
        } else {
            // parse the json
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            if (!apiResponse) {
                [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
                [blockSelf dataSourceDidError];
            } else {
                if ([apiResponse objectForKey:@"data"] && [[apiResponse objectForKey:@"data"] isKindOfClass:[NSDictionary class]] && [[apiResponse objectForKey:@"data"] objectForKey:@"businesses"] && [[[apiResponse objectForKey:@"data"] objectForKey:@"businesses"] count] > 0) {
                    blockSelf.yelpDict = [[[apiResponse objectForKey:@"data"] objectForKey:@"businesses"] lastObject];
                    
                    [blockSelf dataSourceDidLoad];
                } else {
                    [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
                    [blockSelf dataSourceDidError];
                }
            }
        }
    }];
}

- (void)dataSourceDidLoad {
    self.loadingLabel.hidden = YES;
    
    NSDictionary *biz = self.yelpDict;
    
    // Load into dataSource
    
    // First section
    NSMutableArray *firstSection = [NSMutableArray array];
    
    // Rating
    NSDictionary *rating = [NSDictionary dictionaryWithObjectsAndKeys:
                            [biz objectForKey:@"rating_img_url_large"],
                            @"subtitle",
                            @"Rating",
                            @"title",
                            nil
                            ];
    [firstSection addObject:rating];
    
    // Rating
    NSDictionary *reviewCount = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [biz objectForKey:@"review_count"],
                                 @"subtitle",
                                 @"Reviews",
                                 @"title",
                                 nil
                                 ];
    [firstSection addObject:reviewCount];
    
    // Read Reviews
    NSString *readReviews = @"Read Reviews on Yelp";
    [firstSection addObject:readReviews];
    
    // Phone
//    if ([biz objectForKey:@"phone"]) {
//        NSDictionary *phone = [NSDictionary dictionaryWithObjectsAndKeys:
//                               [biz objectForKey:@"phone"],
//                               @"subtitle",
//                               @"Phone",
//                               @"title",
//                               nil
//                               ];
//        [firstSection addObject:phone];
//    }
    
    [self.items addObject:firstSection];
    
    // Second Section
//    NSMutableArray *secondSection = [NSMutableArray array];
//    
//    // Snippet
//    if ([biz objectForKey:@"snippet_text"]) {
//        NSString *snippet = [biz objectForKey:@"snippet_text"];
//        [secondSection addObject:snippet];
//    }
//    
//    [self.items addObject:secondSection];
    
    // Third Section
//     NSMutableArray *thirdSection = [NSMutableArray array];
//    
//    NSString *readReviews = @"Read Reviews on Yelp";
//    [thirdSection addObject:readReviews];
//    
//    [self.items addObject:thirdSection];
    
    [self.tableView reloadData];
}

- (void)dataSourceDidError {
    self.loadingLabel.text = [NSString stringWithFormat:@"Yelp didn't find any matches for %@", [self.venueDict objectForKey:@"name"]];
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.items objectAtIndex:section] count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Choose a start and end date for your Timeline.";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [UITableViewCell class];
    UITableViewCell *cell = nil;
    NSString *reuseIdentifier = @"UITableViewCellBase";
    
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil) { 
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    // Reset
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[NSDictionary class]]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[item objectForKey:@"title"] isEqualToString:@"Rating"]) {
            PSCachedImageView *iv = [[PSCachedImageView alloc] initWithFrame:CGRectMake(0, 0, 111, 20)];
            iv.backgroundColor = [UIColor clearColor];
            [iv loadImageWithURL:[NSURL URLWithString:[item objectForKey:@"subtitle"]] cacheType:PSURLCacheTypePermanent];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"title"]];
            cell.accessoryView = iv;
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"title"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"subtitle"]];
        }
    } else if ([item isKindOfClass:[NSString class]]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = item;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        NSString *yelpUrlString = nil;
        if (isYelpInstalled()) {
            yelpUrlString = [NSString stringWithFormat:@"yelp:///biz/%@", [self.yelpDict objectForKey:@"id"]];
        } else {
            yelpUrlString = [self.yelpDict objectForKey:@"mobile_url"];
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:yelpUrlString]];
        
        if ([self.nextResponder.nextResponder isKindOfClass:[PSPopoverView class]]) {
            [(PSPopoverView *)self.nextResponder.nextResponder dismiss];
        }
    }
}

@end
