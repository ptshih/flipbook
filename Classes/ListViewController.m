//
//  ListViewController.m
//  Grid
//
//  Created by Peter Shih on 10/26/12.
//
//

#import "ListViewController.h"
#import "ECSlidingViewController.h"
#import "ItemCell.h"

@interface ListViewController ()

@property (nonatomic, strong) NSString *listId;
@property (nonatomic, copy) NSMutableDictionary *listDict;

@end

@implementation ListViewController

#pragma mark - Init

- (id)initWithListId:(NSString *)listId {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.listId = listId;
        self.listDict = [NSMutableDictionary dictionary];
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        //        self.shouldPullRefresh = YES;
        //        self.shouldPullLoadMore = YES;
        self.shouldShowNullView = YES;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // SlidingViewController
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.view.layer.shadowOpacity = 0.75;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconShareWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.rightButton.userInteractionEnabled = YES;
}

- (void)setupFooter {
    [super setupFooter];
    
//    UIButton *b = [UIButton buttonWithFrame:CGRectInset(self.footerView.bounds, 8, 6) andStyle:@"lightButton" target:self action:nil];
//    [b setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
//    [b setTitle:@"I'm Done" forState:UIControlStateNormal];
//    [self.footerView addSubview:b];
}

#pragma mark - Actions

- (void)leftAction {
    [self.slidingViewController anchorTopViewTo:ECRight];
//    [self.navigationController popViewControllerAnimated:YES];
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
    [[PSDB sharedDatabase] findDocumentForKey:self.listId inCollection:@"lists" completionBlock:^(NSMutableDictionary *document) {
        self.listDict = document;
        self.title = [self.listDict objectForKey:@"title"];
        [self.centerButton setTitle:self.title forState:UIControlStateNormal];
        [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:[self.listDict objectForKey:@"items"]] animated:YES];
        [self dataSourceDidLoad];
    }];
}

#pragma mark - TableView

- (UITableViewCellSelectionStyle)selectionStyleAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellSelectionStyleBlue;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    return [ItemCell class];
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
    
    // Switch status
    NSString *status = [item objectForKey:@"status"];
    if ([status isEqualToString:@"done"]) {
        [item setObject:@"doing" forKey:@"status"];
    } else {
        [item setObject:@"done" forKey:@"status"];
    }
    
    // Every action should Save up to the cloud
    [[PSDB sharedDatabase] saveDocument:self.listDict forKey:self.listId inCollection:@"lists" completionBlock:^(NSMutableDictionary *savedDocument) {
        [[tableView cellForRowAtIndexPath:indexPath] performSelector:@selector(toggleStatus)];
    }];
}

@end
