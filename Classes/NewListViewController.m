//
//  NewListViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "NewListViewController.h"
#import "ECSlidingViewController.h"
#import "NewItemCell.h"
#import "ListViewController.h"

@interface NewListViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSMutableDictionary *listDict;

@property (nonatomic, strong) PSTextField *tf;

@end

@implementation NewListViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.listDict = [NSMutableDictionary dictionary];
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = YES;
        self.shouldShowNullView = NO;
        self.shouldAdjustViewForKeyboard = YES;
        
        self.headerHeight = 44.0;
        self.footerHeight = 44.0;
        
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.title = @"Name Your Checklist";
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
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.view.layer.shadowOpacity = 0.75;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tableView.editing = YES;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = YES;
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconCheckWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.rightButton.userInteractionEnabled = YES;
}

- (void)setupFooter {
    [super setupFooter];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.footerView.width, 44.0)];
    v.backgroundColor = TEXTURE_LIGHT_SKETCH;
    
    PSTextField *tf = [[PSTextField alloc] initWithFrame:CGRectInset(v.bounds, 4, 4) withMargins:CGSizeMake(4, 6)];
//    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectInset(v.bounds, 4, 4)];
    tf.delegate = self;
    tf.placeholder = @"What needs to be done?";
    tf.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
//    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //        self.textField.adjustsFontSizeToFitWidth = YES;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.returnKeyType = UIReturnKeyGo;
    [PSStyleSheet applyStyle:@"leadDarkField" forTextField:tf];
    [v addSubview:tf];
    self.tf = tf;
    
    [self.footerView addSubview:v];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *title = textField.text;
    
    if (title.length > 0) {
    
        [[self.items objectAtIndex:0] addObject:@{@"title" : title, @"status": @"doing"}];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    return YES;
}

#pragma mark - Actions

- (void)leftAction {
    [self.tf resignFirstResponder]; // BUG
    [self.slidingViewController anchorTopViewTo:ECRight];
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
    [UIAlertView alertViewWithTitle:@"Name Your Checklist" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex, NSString *textInput) {
        self.title = textInput;
        [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    } onCancel:NULL];
}

- (void)rightAction {
    // Save
    [[PSDB sharedDatabase] saveDocument:[NSMutableDictionary dictionaryWithDictionary:@{@"title" : self.title, @"items" : [self.items objectAtIndex:0]}] forKey:[NSString stringWithFormat:@"%0.f", [[NSDate date] millisecondsSince1970]] inCollection:@"lists" completionBlock:^(NSDictionary *document) {
        ListViewController *vc = [[ListViewController alloc] initWithListId:[document objectForKey:@"_id"]];

        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = vc;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
        
        return;
        
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = vc;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];
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
    
    NSMutableArray *row = [NSMutableArray array];
    [row addObject:@{@"title" : @"test", @"status": @"doing"}];
    [row addObject:@{@"title" : @"test 2", @"status": @"doing"}];
    
    [sections addObject:row];
    
    [self dataSourceShouldLoadObjects:sections animated:YES];
    [self dataSourceDidLoad];
}

#pragma mark - TableView

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSInteger fromSection = sourceIndexPath.section;
    NSInteger toSection = destinationIndexPath.section;
    NSInteger fromRow = sourceIndexPath.row;
    NSInteger toRow = destinationIndexPath.row;
    
    id srcObj = [[self.items objectAtIndex:fromSection] objectAtIndex:fromRow];
    id dstObj = [[self.items objectAtIndex:toSection] objectAtIndex:toRow];
    [[self.items objectAtIndex:fromSection] replaceObjectAtIndex:fromRow withObject:dstObj];
    [[self.items objectAtIndex:toSection] replaceObjectAtIndex:toRow withObject:srcObj];
    
//    [[self.items objectAtIndex:fromSection] exchangeObjectAtIndex:fromRow withObjectAtIndex:toRow];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.items objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellSelectionStyle)selectionStyleAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellSelectionStyleBlue;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    return [NewItemCell class];
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
//    id item = [[s elf.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
}

@end
