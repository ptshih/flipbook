//
//  EventViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"

#import "VenueMiniView.h"

#define kEventWhenTag 8001
#define kEventReasonTag 8002

@interface EventViewController ()

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, copy) NSDictionary *eventDict;

@property (nonatomic, strong) VenueMiniView *miniView;

@end

@implementation EventViewController

@synthesize
venueDict = _venueDict,
eventDict = _eventDict;

@synthesize
miniView = _miniView;

- (id)initWithVenueDict:(NSDictionary *)venueDict eventDict:(NSDictionary *)eventDict {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = venueDict;
        self.eventDict = eventDict;
        
        self.title = [NSString stringWithFormat:@"View Event"];
    }
    return self;
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Venue Mini
    self.miniView = [[VenueMiniView alloc] initWithDictionary:self.venueDict];
    [self.view addSubview:self.miniView];
    
    // Load
    [self loadDataSource];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    UILabel *versionLabel = [UILabel labelWithText:[NSString stringWithFormat:@"Lunchbox Version %@", appVersion] style:@"metaLabel"];
    versionLabel.textAlignment = UITextAlignmentCenter;
    versionLabel.frame = CGRectMake(0, 0, self.tableView.width, 20.0);
    self.tableView.tableFooterView = versionLabel;
}

- (void)setupHeader {
    [super setupHeader];
    
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    //    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.rightButton.userInteractionEnabled = NO;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
}


- (void)leaveEvent:(UIButton *)button {
//    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Change your attendance?" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"Not going anymore", nil];
//    as.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [as showInView:self.view];
}


#pragma mark - Events
- (void)mutateEventWithAction:(NSString *)action {
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/events/%@/%@", API_BASE_URL, [self.eventDict objectForKey:@"_id"], action];
    
    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"];
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    NSString *fbName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbName"];
    BOOL shouldPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPostToFacebook"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fbAccessToken forKey:@"fbAccessToken"];
    [parameters setObject:fbId forKey:@"fbId"];
    [parameters setObject:fbName forKey:@"fbName"];
    [parameters setObject:[NSNumber numberWithBool:shouldPost] forKey:@"shouldPostToFacebook"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:blockSelf];
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //        NSLog(@"res: %@", res);
            self.eventDict = res;
            
            [[NotificationManager sharedManager] downloadNotificationsWithCompletionBlock:NULL];
        }
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
//    if (actionSheet.tag == kEventWhenTag) {
//        NSString *when = [actionSheet buttonTitleAtIndex:buttonIndex];
//        
//        //        [self createEventWithReason:when];
//    } else if (actionSheet.tag == kEventReasonTag) {
//        NSString *reason = [actionSheet buttonTitleAtIndex:buttonIndex];
//        
//        if ([reason isEqualToString:@"Not going anymore"]) {
//            [self mutateEventWithAction:@"leave"];
//        }
//    }
}

@end
