//
//  WelcomeViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "WelcomeViewController.h"
#import "ECSlidingViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Check";
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = YES;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
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

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    UILabel *l = [UILabel labelWithText:@"You better check yo self\r\nbefore you wreck yo self\r\n\r\nCause I'm bad for your health\r\nI come real stealth\r\n\r\nSo chickity-check yo self\r\nbefore you wreck yo self" style:@"h4LightLabel"];
    l.autoresizingMask = self.contentView.autoresizingMask;
    l.textAlignment = UITextAlignmentCenter;
    l.frame = CGRectInset(self.contentView.bounds, 16, 16);
    [self.contentView addSubview:l];
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconSmileyWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.rightButton.userInteractionEnabled = YES;
}

- (void)setupFooter {
    [super setupFooter];
}

#pragma mark - Actions

- (void)leftAction {
    [self.slidingViewController anchorTopViewTo:ECRight];
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
//    [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:[self.listDict objectForKey:@"items"]] animated:YES];
    [self dataSourceDidLoad];
}

@end
