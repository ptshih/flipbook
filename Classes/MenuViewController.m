//
//  MenuViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "MenuViewController.h"
#import "ECSlidingViewController.h"
#import "ListViewController.h"
#import "MenuCell.h"
#import "ListCell.h"

@interface MenuViewController ()

@property (nonatomic, strong) NSMutableDictionary *listsDict;

@end

@implementation MenuViewController

#pragma mark - Init

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.listsDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        //        self.shouldPullRefresh = YES;
        //        self.shouldPullLoadMore = YES;
        self.shouldShowNullView = YES;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 0.0;
        self.footerHeight = 0.0;
        
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = RGBACOLOR(0, 0, 0, 0.25);
    }
    return self;
}

- (void)dealloc {
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
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
}

- (void)setupHeader {
    [super setupHeader];
    
}

- (void)setupFooter {
    [super setupFooter];

}

#pragma mark - Actions

- (void)leftAction {
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
    NSMutableArray *sections = [NSMutableArray array];
    
    NSArray *items = @[
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Hand Soap", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Toilet Paper", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Bananas", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Beer, Soju", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Black Beans", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Quinoa", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Grilled Chicken Breast", @"status" : @"doing"}],
    [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Canned Tuna", @"status" : @"doing"}]
    ];
    
    NSArray *row = @[@{@"title" : @"Grocery List", @"items" : items}];
    [sections addObject:row];
    
    [self dataSourceShouldLoadObjects:sections animated:YES];
    [self dataSourceDidLoad];
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Checklists";
            break;
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCellSelectionStyle)selectionStyleAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellSelectionStyleBlue;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    return [MenuCell class];
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
    
    ListViewController *vc = [[ListViewController alloc] initWithList:item];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = vc;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}


@end
