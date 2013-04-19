//
//  MenuViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "MenuViewController.h"
#import "MenuCell.h"

#import "DashboardViewController.h"
#import "OrdersViewController.h"
#import "LeadsViewController.h"
#import "ProductsViewController.h"


@interface MenuViewController ()

@end

@implementation MenuViewController

#pragma mark - Init

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {

    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = NO;
        
        self.headerHeight = 0.0;
        self.footerHeight = 0.0;
        
        self.headerLeftWidth = 0.0;
        self.headerRightWidth = 0.0;
        
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = RGBACOLOR(0, 0, 0, 0.2);
        
        self.title = @"Menu";
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
    
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *items = [NSMutableArray array];

    [items addObject:@{@"title": @"Dashboard", @"icon": @"IconSmileyWhite"}];
    [items addObject:@{@"title": @"Orders", @"icon": @"IconCartWhite"}];
    [items addObject:@{@"title": @"Leads", @"icon": @"IconHeartWhite"}];
    [items addObject:@{@"title": @"Products", @"icon": @"IconHeartWhite"}];
    [items addObject:@{@"title": @"Logout", @"icon": @"IconGroupWhite"}];
    
    [sections addObject:items];
    [self dataSourceShouldLoadObjects:sections animated:NO];
    [self dataSourceDidLoad];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

#pragma mark - TableView

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
//    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    id vc = nil;
    switch (indexPath.row) {
        case 0:
            vc = [[DashboardViewController alloc] initWithNibName:nil bundle:nil];
            break;
        case 1:
            vc = [[OrdersViewController alloc] initWithNibName:nil bundle:nil];
            break;
        case 2:
            vc = [[LeadsViewController alloc] initWithNibName:nil bundle:nil];
            break;
        case 3:
            vc = [[ProductsViewController alloc] initWithNibName:nil bundle:nil];
            break;
        case 4:
            [self.slidingViewController anchorTopViewTo:ECLeft animations:nil onComplete:^{
                [[UserManager sharedManager] logout];
            }];
            return;
            break;
        default:
            return;
            break;
    }
    
    PSNavigationController *nc = [[PSNavigationController alloc] initWithRootViewController:vc];
    
    [self.slidingViewController anchorTopViewTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = nc;
        [[vc slidingViewController] topViewController].view.frame = frame;
        [[vc slidingViewController] resetTopView];
    }];
}


@end
