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

@interface NewListViewController () <UITextFieldDelegate, NewItemCellDelegate>

@property (nonatomic, strong) NSString *templateId;
@property (nonatomic, strong) NSMutableDictionary *templateDict;

@property (nonatomic, strong) PSTextField *tf;

@end

@implementation NewListViewController

#pragma mark - Init

- (id)initWithTemplateId:(NSString *)templateId {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.templateId = templateId;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = YES;
        self.shouldShowFooter = YES;
        self.shouldShowNullView = NO;
        self.shouldPullRefresh = NO;
        
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
    
    // SlidingViewController
    self.slidingViewController.underRightViewController = nil;
    
    [self.headerView addGestureRecognizer:self.slidingViewController.panGesture];
    self.view.layer.shadowOpacity = 0.75;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    // Load
    [self loadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.footerView.width, 44.0)];
    v.backgroundColor = TEXTURE_LIGHT_SKETCH;
    
    PSTextField *tf = [[PSTextField alloc] initWithFrame:CGRectInset(v.bounds, 4, 4) withMargins:CGSizeMake(4, 5)];
    //    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectInset(v.bounds, 4, 4)];
    tf.delegate = self;
    tf.placeholder = @"What needs to be done?";
    tf.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
    tf.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *cv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconComposeGray"]];
    cv.contentMode = UIViewContentModeCenter;
    cv.width = 30.0;
    cv.height = 26.0;
    tf.leftView = cv;
    //    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //        self.textField.adjustsFontSizeToFitWidth = YES;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.returnKeyType = UIReturnKeyGo;
    [PSStyleSheet applyStyle:@"h3DarkLabel" forTextField:tf];
    [v addSubview:tf];
    self.tf = tf;
    
    self.tableView.tableHeaderView = v;
    
    self.viewToAdjustForKeyboard = self.tableView;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = YES;
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconPlusWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.rightButton.userInteractionEnabled = YES;
}

- (void)setupFooter {
    [super setupFooter];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *title = textField.text;
    
    if (title.length > 0) {
        [[self.items objectAtIndex:0] addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title" : title, @"status": @"doing"}]];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        textField.text = nil;
    }
    
    return YES;
}

#pragma mark - Actions

- (void)leftAction {
    [self saveWithCompletionBlock:^(BOOL didSave) {
        [self.tf resignFirstResponder]; // BUG
        [self.slidingViewController anchorTopViewTo:ECRight];
    }];
}

- (void)centerAction {
    [UIAlertView alertViewWithTitle:@"Name Your Checklist" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex, NSString *textInput) {
        self.title = textInput;
        [self.centerButton setTitle:self.title forState:UIControlStateNormal];
        [self.templateDict setObject:self.title forKey:@"title"];
    } onCancel:NULL];
}

- (void)rightAction {
    [self saveWithCompletionBlock:^(BOOL didSave) {
        [self.tf resignFirstResponder];
        
        if (didSave) {
            [(PSNavigationController *)self.slidingViewController.underLeftViewController popToRootViewControllerAnimated:NO];
            
            [[PSDB sharedDatabase] saveDocument:self.templateDict forKey:nil inCollection:@"lists" completionBlock:^(NSMutableDictionary *savedDocument) {
                ListViewController *vc = [[ListViewController alloc] initWithListId:[savedDocument objectForKey:@"_id"]];
                
                [self.slidingViewController anchorTopViewTo:ECRight animations:nil onComplete:^{
                    CGRect frame = self.slidingViewController.topViewController.view.frame;
                    self.slidingViewController.topViewController = vc;
                    vc.slidingViewController.topViewController.view.frame = frame;
                    [vc.slidingViewController resetTopView];
                }];
            }];
        }
    }];
}

- (void)saveWithCompletionBlock:(void (^)(BOOL didSave))completionBlock {
    // Save
    if ([[self.templateDict objectForKey:@"items"] count] > 0) {
        [[PSDB sharedDatabase] saveDocument:self.templateDict forKey:self.templateId inCollection:@"templates" completionBlock:^(NSDictionary *document) {
            completionBlock(YES);
        }];
    } else {
        completionBlock(NO);
    }
}

- (void)cellModifiedWithText:(NSString *)text {
    NSLog(@"text: %@", text);
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
    [[PSDB sharedDatabase] findDocumentForKey:self.templateId inCollection:@"templates" completionBlock:^(NSMutableDictionary *document) {
        if (document) {
            self.templateDict = document;
        } else {
            self.templateDict = [NSMutableDictionary dictionary];
            [self.templateDict setObject:@"New Checklist" forKey:@"title"];
            [self.templateDict setObject:[NSMutableArray array] forKey:@"items"];
            [self.templateDict setObject:[[NSNumber numberWithDouble:[[NSDate date] millisecondsSince1970]] stringValue] forKey:@"timestamp"];
        }
        self.title = [self.templateDict objectForKey:@"title"];
        [self.centerButton setTitle:self.title forState:UIControlStateNormal];
        [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:[self.templateDict objectForKey:@"items"]] animated:YES];
        [self dataSourceDidLoad];
    }];
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
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 500, 0);
//    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    id item = [[s elf.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
}

- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView {

}

@end
