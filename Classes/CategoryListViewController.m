//
//  CategoryListViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryListViewController.h"
#import "VenueListViewController.h"
#import "NotificationViewController.h"
#import "FBConnectViewController.h"
#import "SettingsViewController.h"
#import "BookmarkViewController.h"

#import "PSPopoverView.h"
#import "InfoPopoverView.h"

#define MARGIN 8.0
#define LABEL_HEIGHT 40.0
#define kTopViewTag 9001
#define kMidViewTag 9002
#define kBotViewTag 9003

#define kPopoverNotifications 7003

@interface CategoryListViewController () <PSPopoverViewDelegate>

@property (nonatomic, strong) UIView *contentView;

@end

@implementation CategoryListViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = NO;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.title = @"Lunchbox";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications) name:kNotificationManagerDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookDidLogin) name:kFacebookLoginSucceeded object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Config
//- (UIColor *)baseBackgroundColor {
//    return [UIColor blackColor];
//}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupSubviews {
    [super setupSubviews];
    
    // Content View
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height - self.footerView.height)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentView];
    
    // Images
    UIImageView *topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryFood.jpg"]];
    [self.contentView addSubview:topView];
    topView.tag = kTopViewTag;
    topView.contentScaleFactor = [UIScreen mainScreen].scale;
    topView.contentMode = UIViewContentModeScaleAspectFill;
    topView.clipsToBounds = YES;
    topView.userInteractionEnabled = YES;
    [topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushCategory:)]];
    
    UIImageView *midView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryCafe.jpg"]];
    [self.contentView addSubview:midView];
    midView.tag = kMidViewTag;
    midView.contentScaleFactor = [UIScreen mainScreen].scale;
    midView.contentMode = UIViewContentModeScaleAspectFill;
    midView.clipsToBounds = YES;
    midView.userInteractionEnabled = YES;
    [midView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushCategory:)]];
    
    UIImageView *botView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryNightlife.jpg"]];
    [self.contentView addSubview:botView];
    botView.tag = kBotViewTag;
    botView.contentScaleFactor = [UIScreen mainScreen].scale;
    botView.contentMode = UIViewContentModeScaleAspectFill;
    botView.clipsToBounds = YES;
    botView.userInteractionEnabled = YES;
    [botView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushCategory:)]];
    
    CGFloat height = ceilf(self.contentView.height / 3.0);
    CGFloat botHeight = self.contentView.height - (height * 2.0);
    
    topView.frame = CGRectMake(0, 0, self.contentView.width, height);
    midView.frame = CGRectMake(0, topView.bottom, self.contentView.width, height);
    botView.frame = CGRectMake(0, midView.bottom, self.contentView.width, botHeight);
    
    // Labels
    CGSize labelSize = CGSizeZero;
    CGFloat width = topView.width - MARGIN * 2;
    
    UILabel *topLabel = [UILabel labelWithText:@"  Food and Restaurants  " style:@"h1DarkLabel"];
    [topView addSubview:topLabel];
    labelSize = [PSStyleSheet sizeForText:topLabel.text width:width style:@"h1DarkLabel"];
    topLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    topLabel.frame = CGRectMake(MARGIN, topView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
    
    UILabel *midLabel = [UILabel labelWithText:@"  Coffee and Tea  " style:@"h1DarkLabel"];
    [midView addSubview:midLabel];
    labelSize = [PSStyleSheet sizeForText:midLabel.text width:width style:@"h1DarkLabel"];
    midLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    midLabel.frame = CGRectMake(MARGIN, midView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
    
    UILabel *botLabel = [UILabel labelWithText:@"  Bars and Nightclubs  " style:@"h1DarkLabel"];
    [botView addSubview:botLabel];
    labelSize = [PSStyleSheet sizeForText:botLabel.text width:width style:@"h1DarkLabel"];
    botLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    botLabel.frame = CGRectMake(MARGIN, botView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
}


- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)leftAction {
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

- (void)centerAction {
//    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
//        NotificationViewController *vc = [[NotificationViewController alloc] initWithNibName:nil bundle:nil];
//        vc.view.frame = CGRectMake(0, 0, 288, 356);
//        PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Notifications" contentController:vc];
//        popoverView.tag = kPopoverNotifications;
//        popoverView.delegate = self;
//        [popoverView showWithSize:vc.view.bounds.size inView:self.view];
//    } else {
//        FBConnectViewController *vc = [[FBConnectViewController alloc] initWithNibName:nil bundle:nil];
//        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionUp animated:YES];
//    }
}

- (void)rightAction {
//    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
//        BookmarkViewController *vc = [[BookmarkViewController alloc] initWithNibName:nil bundle:nil];
//        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
//    } else {
//        FBConnectViewController *vc = [[FBConnectViewController alloc] initWithNibName:nil bundle:nil];
//        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionUp animated:YES];
//    }
}

#pragma mark - Notifications

- (void)updateNotifications {
    NSArray *notifications = [[NotificationManager sharedManager] notifications];
    self.title = [NSString stringWithFormat:@"Lunchbox (%d)", notifications.count];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)facebookDidLogin {
    [[NotificationManager sharedManager] downloadNotificationsWithCompletionBlock:NULL];
}

- (void)pushCategory:(UITapGestureRecognizer *)gestureRecognizer {
    NSString *category = nil;
    UIView *view = gestureRecognizer.view;
    switch (view.tag) {
        case kTopViewTag:
            category = @"food";
            break;
        case kMidViewTag:
            category = @"coffee";
            break;
        case kBotViewTag:
            category = @"drinks";
            break;
        default:
            category = @"food";
            break;
    }
    
    id vc = [[VenueListViewController alloc] initWithCategory:category];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

@end
