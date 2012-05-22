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

@synthesize
contentView = _contentView;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
        
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
- (UIColor *)baseBackgroundColor {
    return [UIColor blackColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDate *showDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"showEventPopover"];
    
    if ([[showDate earlierDate:[NSDate date]] isEqualToDate:showDate] && ![[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:kTimeInterval1Day] forKey:@"showEventPopover"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        InfoPopoverView *pv = [[InfoPopoverView alloc] initWithFrame:self.view.bounds];
        pv.alpha = 0.0;
        
        [UIView animateWithDuration:0.4 animations:^{
            pv.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.view addSubview:pv];
        }];
    }
    
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [self updateNotifications];
    }
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
    
    UILabel *topLabel = [UILabel labelWithText:@"  Food and Restaurants  " style:@"h1Label"];
    [topView addSubview:topLabel];
    labelSize = [PSStyleSheet sizeForText:topLabel.text width:width style:@"h1Label"];
    topLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    topLabel.frame = CGRectMake(MARGIN, topView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
    
    UILabel *midLabel = [UILabel labelWithText:@"  Coffee and Tea  " style:@"h1Label"];
    [midView addSubview:midLabel];
    labelSize = [PSStyleSheet sizeForText:midLabel.text width:width style:@"h1Label"];
    midLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    midLabel.frame = CGRectMake(MARGIN, midView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
    
    UILabel *botLabel = [UILabel labelWithText:@"  Bars and Nightclubs  " style:@"h1Label"];
    [botView addSubview:botLabel];
    labelSize = [PSStyleSheet sizeForText:botLabel.text width:width style:@"h1Label"];
    botLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    botLabel.frame = CGRectMake(MARGIN, botView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
}


- (void)setupHeader {
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconBookmarkWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions

- (void)leftAction {
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

- (void)centerAction {
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        NotificationViewController *vc = [[NotificationViewController alloc] initWithNibName:nil bundle:nil];
        vc.view.frame = CGRectMake(0, 0, 288, 356);
        PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Notifications" contentController:vc];
        popoverView.tag = kPopoverNotifications;
        popoverView.delegate = self;
        [popoverView showWithSize:vc.view.bounds.size inView:self.view];
    } else {
        FBConnectViewController *vc = [[FBConnectViewController alloc] initWithNibName:nil bundle:nil];
        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionUp animated:YES];
    }
}

- (void)rightAction {
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        NotificationViewController *vc = [[NotificationViewController alloc] initWithNibName:nil bundle:nil];
        vc.view.frame = CGRectMake(0, 0, 288, 356);
        PSPopoverView *popoverView = [[PSPopoverView alloc] initWithTitle:@"Notifications" contentController:vc];
        popoverView.tag = kPopoverNotifications;
        popoverView.delegate = self;
        [popoverView showWithSize:vc.view.bounds.size inView:self.view];
    } else {
        FBConnectViewController *vc = [[FBConnectViewController alloc] initWithNibName:nil bundle:nil];
        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionUp animated:YES];
    }
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



#if 0
- (void)pushCategory:(UITapGestureRecognizer *)gestureRecognizer {
    NSString *category = nil;
    UIView *view = gestureRecognizer.view;
    switch (view.tag) {
        case kTopViewTag:
        {
            category = @"food";
            
            [PSAlertView showWithTitle:@"Groupon: " message:@"$10 for $20 Worth of Ice Cream, Cakes, and Frozen Treats" buttonTitles:[NSArray arrayWithObjects:@"Skip", @"View", nil] emailText:@"[ save for later ]" completionBlock:^(NSUInteger buttonIndex, NSString *textFieldValue) {
                if (!textFieldValue) {
                    // on demand
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://touch.groupon.com/deals/baskin-robbins-mountain-view"]];
                        return;
                    }
                } else {
                    // save for later
                }
                NSLog(@"alert finished: %d, %@", buttonIndex, textFieldValue);
                id vc = [[VenueListViewController alloc] initWithCategory:category];
                [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
            }]; 
            break;
        }
        case kMidViewTag:
        {
            category = @"coffee";
            
            [PSAlertView showWithTitle:@"Urban Outfitters Survey" message:@"Have you visited an Urban Outfitters retail store in the past month?" buttonTitles:[NSArray arrayWithObjects:@"No", @"Yes", nil] textFieldPlaceholder:nil completionBlock:^(NSUInteger buttonIndex, NSString *textFieldValue) {
                if (!textFieldValue) {
                } else {
                }
                NSLog(@"alert finished: %d, %@", buttonIndex, textFieldValue);
                id vc = [[VenueListViewController alloc] initWithCategory:category];
                [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
            }];
            break;
        }
        case kBotViewTag:
        {
            category = @"drinks";
            
            [PSAlertView showWithTitle:@"Kingdoms of Camelot" message:@"Unleash the power of the Throne! Download Now!" buttonTitles:[NSArray arrayWithObjects:@"Skip", @"Download", nil] emailText:@"[ save for later ]" completionBlock:^(NSUInteger buttonIndex, NSString *textFieldValue) {
                if (!textFieldValue) {
                    // on demand
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/kingdoms-camelot-battle-for/id476546099?mt=8"]];
                        return;
                    }
                } else {
                    // save for later
                }
                NSLog(@"alert finished: %d, %@", buttonIndex, textFieldValue);
                id vc = [[VenueListViewController alloc] initWithCategory:category];
                [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
            }];
            break;
        }
        default:
        {
            category = @"food";
            
            id vc = [[VenueListViewController alloc] initWithCategory:category];
            [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
            break;
        }
    }
}
#else
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
#endif

@end
