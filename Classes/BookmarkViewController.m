//
//  BookmarkViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkViewController.h"
#import "VenueDetailViewController.h"

#import "VenueMiniCell.h"

@interface BookmarkViewController ()

@end

@implementation BookmarkViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
        self.shouldPullRefresh = YES;
        self.tableViewStyle = UITableViewStylePlain;
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = [UIColor lightGrayColor];
        
        self.title = @"Bookmarks";
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Config Table
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
}

- (void)setupHeader {
    [super setupHeader];
    
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    //    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.rightButton.userInteractionEnabled = NO;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
}


#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)reloadDataSource {
    [super reloadDataSource];
        
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // FB
    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"];
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    NSString *fbName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbName"];
    [parameters setObject:fbAccessToken forKey:@"fbAccessToken"];
    [parameters setObject:fbId forKey:@"fbId"];
    [parameters setObject:fbName forKey:@"fbName"];
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/bookmarks", API_BASE_URL];
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:blockSelf];
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (res && [res isKindOfClass:[NSArray class]]) {
                [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:res] animated:NO];
                [self dataSourceDidLoad];
            } else {
                [self dataSourceDidError];
            }
        } else {
            [self dataSourceDidError];
        }
    }];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}


#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [VenueMiniCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeightForObject:object atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *venueId = [object objectForKey:@"venueId"];
    
    VenueDetailViewController *vc = [[VenueDetailViewController alloc] initWithVenueId:venueId];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    //    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
}

- (void)endRefresh {
    [super endRefresh];
    //    [SVProgressHUD dismiss];
}

@end
