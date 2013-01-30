//
//  MenuViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "MenuViewController.h"
#import "ECSlidingViewController.h"
#import "MenuListViewController.h"
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
        self.shouldShowHeader = YES;
        self.shouldShowFooter = YES;
//        self.shouldPullRefresh = YES;
//        self.shouldPullLoadMore = YES;
        self.shouldShowNullView = NO;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 44.0;
        
        self.headerLeftWidth = 0.0;
        self.headerRightWidth = 0.0;
        
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = RGBACOLOR(0, 0, 0, 0.2);
        
        self.title = @"Recent Checklists";
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return TEXTURE_DARK_LINEN;
}

- (UIColor *)rowBackgroundColorForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    return TEXTURE_DARK_WOVEN;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadDataSource];
    
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
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
}

- (void)setupFooter {
    [super setupFooter];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.footerView.width, 44.0)];
    v.autoresizingMask = self.footerView.autoresizingMask;
    v.backgroundColor = TEXTURE_ALUMINUM;
    [v addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savedChecklists)]];
    
    UIImageView *d = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
    d.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    d.contentMode = UIViewContentModeCenter;
    d.height = v.height;
    d.left = v.width - d.width - 8.0;
    [v addSubview:d];
    
    UILabel *l = [UILabel labelWithText:@"Reusable Checklists" style:@"h3DarkLabel"];
    l.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    l.frame = CGRectInset(v.bounds, 8, 4);
    l.width -= d.width - 16.0;
    [v addSubview:l];
    
    [self.footerView addSubview:v];
}

#pragma mark - Actions

- (void)leftAction {
}

- (void)centerAction {
}

- (void)rightAction {
}

- (void)savedChecklists {
    MenuListViewController *vc = [[MenuListViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.psNavigationController pushViewController:vc animated:YES];
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
    //    NSArray *documents = [[PSDB sharedDatabase] documentsForCollection:@"lists"];
    
    [[PSDB sharedDatabase] findDocumentsInCollection:@"lists" completionBlock:^(NSMutableArray *documents) {
        NSMutableArray *sections = [NSMutableArray array];
        [sections addObject:documents];
        [self dataSourceShouldLoadObjects:sections animated:NO];
        [self dataSourceDidLoad];
    }];
}

#pragma mark - TableView

- (UIView *)accessoryViewAtIndexPath:(NSIndexPath *)indexPath {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    return [MenuCell class];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *keyToDelete = [[[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id"];
        [[PSDB sharedDatabase] deleteDocumentForKey:keyToDelete inCollection:@"lists" completionBlock:^{
            [[self.items objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
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
    
    ListViewController *vc = [[ListViewController alloc] initWithListId:[item objectForKey:@"id"]];
    
    [self.slidingViewController anchorTopViewTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = vc;
        vc.slidingViewController.topViewController.view.frame = frame;
        [vc.slidingViewController resetTopView];
    }];
}


@end
