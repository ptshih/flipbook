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
#import "NewListViewController.h"
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
        self.shouldShowNullView = NO;
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
    
    [self reloadDataSource];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.width-= 40.0;
    
    UIButton *b = [UIButton buttonWithFrame:CGRectMake(0, 0, self.tableView.width, 44.0) andStyle:@"darkButton" target:self action:@selector(newList)];
//    [b setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [b setTitle:@"+ New List" forState:UIControlStateNormal];
    self.tableView.tableHeaderView = b;
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

- (void)newList {
    NewListViewController *vc = [[NewListViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = vc;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
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
    
    NSArray *documents = [[PSDB sharedDatabase] documentsForCollection:@"lists"];
    
//    [documents enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableDictionary *document, BOOL *stop) {
//        
//    }];
    
    [sections addObject:documents];
    [self dataSourceShouldLoadObjects:sections animated:NO];
    [self dataSourceDidLoad];
    
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Recent Checklists";
            break;
        case 1:
            return @"Saved Checklists";
            break;
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *keyToDelete = [[[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"_id"];
        [[PSDB sharedDatabase] deleteDocumentForKey:keyToDelete inCollection:@"lists" completionBlock:^{
            [[self.items objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
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
    
    ListViewController *vc = [[ListViewController alloc] initWithListId:[item objectForKey:@"_id"]];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = vc;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}


@end
