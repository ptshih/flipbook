//
//  MenuViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "MenuViewController.h"
#import "RootViewController.h"
#import "OrdersViewController.h"
#import "MenuCell.h"

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
    
}

#pragma mark - TableView

- (UIView *)accessoryViewAtIndexPath:(NSIndexPath *)indexPath {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    return [MenuCell class];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

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
}


@end
