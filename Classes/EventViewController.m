//
//  EventViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"

#import "VenueMiniView.h"
#import "PSFacepileView.h"

#define kEventWhenTag 8001
#define kEventReasonTag 8002

@interface EventViewController ()

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, copy) NSDictionary *eventDict;

@property (nonatomic, strong) VenueMiniView *venueMiniView;
@property (nonatomic, strong) PSFacepileView *facepileView;

@property (nonatomic, strong) UIButton *actionButton;

@end

@implementation EventViewController

@synthesize
venueDict = _venueDict,
eventDict = _eventDict;

@synthesize
venueMiniView = _venueMiniView,
facepileView = _facepileView;

@synthesize
actionButton = _actionButton;

- (id)initWithVenueDict:(NSDictionary *)venueDict eventDict:(NSDictionary *)eventDict {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = venueDict;
        self.eventDict = eventDict;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
        self.tableViewStyle = UITableViewStylePlain;
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = [UIColor lightGrayColor];
        
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
    
    // Load
    [self loadDataSource];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    // Table Header
    CGFloat height = 0.0;
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 0)];
    
    // Venue Mini
    self.venueMiniView = [[VenueMiniView alloc] initWithDictionary:self.venueDict frame:CGRectMake(0, 0, self.view.width, 80.0)];
    self.venueMiniView.backgroundColor = [UIColor whiteColor];
    [tableHeaderView addSubview:self.venueMiniView];
    
    height += self.venueMiniView.height;
    
    // Date/Time
    PSTextField *dateField = [[PSTextField alloc] initWithFrame:CGRectMake(0, self.venueMiniView.bottom, tableHeaderView.width, 44) withInset:UIEdgeInsetsMake(12, 8, 12, 8)];
    [PSStyleSheet applyStyle:@"eventField" forTextField:dateField];
    dateField.leftViewMode = UITextFieldViewModeAlways;
    dateField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconClockBlack"]];
    dateField.text = [NSDate stringFromDate:[NSDate dateWithMillisecondsSince1970:[[self.eventDict objectForKey:@"datetime"] doubleValue]] withFormat:@"EEE, MMM dd, yyyy @ HH:mm a z"];
    [tableHeaderView addSubview:[[UIImageView alloc] initWithFrame:dateField.frame image:[UIImage stretchableImageNamed:@"BackgroundTextFieldTop" withLeftCapWidth:0 topCapWidth:1]]];
    [tableHeaderView addSubview:dateField];
    
    height += dateField.height;
    
    // bg behind facepile
    [tableHeaderView addSubview:[[UIImageView alloc] initWithFrame:CGRectMake(0, dateField.bottom, tableHeaderView.width, 44) image:[UIImage stretchableImageNamed:@"BackgroundTextField" withLeftCapWidth:0 topCapWidth:1]]];
    
    // Attendees
    NSArray *attendees = [self.eventDict objectForKey:@"attendees"];
    NSMutableArray *fbNames = [NSMutableArray array];
    NSMutableArray *fbIds = [NSMutableArray array];
    NSMutableArray *fbUrls = [NSMutableArray array];
    for (NSDictionary *attendee in attendees) {
        [fbNames addObject:[attendee objectForKey:@"fbName"]];
        [fbIds addObject:[attendee objectForKey:@"fbId"]];
        [fbUrls addObject:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [attendee objectForKey:@"fbId"]] forKey:@"url"]];
    }
//    NSString *creatorId = [[attendees objectAtIndexOrNil:0] objectForKey:@"fbId"];
    
    self.facepileView = [[PSFacepileView alloc] initWithFrame:CGRectMake(8, dateField.bottom + 8, [PSFacepileView widthWithFaces:fbUrls], [PSFacepileView heightWithFaces:fbUrls])];
    [self.facepileView loadWithFaces:fbUrls];
    [tableHeaderView addSubview:self.facepileView];
    
    height += self.facepileView.height;
    
    
    tableHeaderView.height = height;
    self.tableView.tableHeaderView = tableHeaderView;
    
    
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
//    UILabel *versionLabel = [UILabel labelWithText:[NSString stringWithFormat:@"Lunchbox Version %@", appVersion] style:@"metaLabel"];
//    versionLabel.textAlignment = UITextAlignmentCenter;
//    versionLabel.frame = CGRectMake(0, 0, self.tableView.width, 20.0);
//    self.tableView.tableFooterView = versionLabel;
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

- (void)setupFooter {
    [super setupFooter];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    self.footerView.backgroundColor = RGBCOLOR(33, 33, 33);
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.footerView];
    
    CGFloat width = floorf((self.footerView.width - 8. * 4.) / 3.);
    
    UIButton *commentButton = [UIButton buttonWithFrame:CGRectMake(8, 7, width, 31.0) andStyle:@"popoverSearchLabel" target:self action:nil];
    [commentButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    [self.footerView addSubview:commentButton];
    
    UIButton *editButton = [UIButton buttonWithFrame:CGRectMake(16 + width, 7, width, 31.0) andStyle:@"popoverSearchLabel" target:self action:nil];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.footerView addSubview:editButton];
    
    // Join/leave
    self.actionButton = [UIButton buttonWithFrame:CGRectMake(24 + width * 2, 7, width, 31.0) andStyle:@"popoverSearchLabel" target:self action:nil];
    [self.actionButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [self.footerView addSubview:self.actionButton];
    
    [self updateFooter];
}

- (void)updateFooter {
    [self.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    // Check if user is an attendee
    NSArray *attendees = [self.eventDict objectForKey:@"attendees"];
    NSMutableArray *fbNames = [NSMutableArray array];
    NSMutableArray *fbIds = [NSMutableArray array];
    for (NSDictionary *attendee in attendees) {
        [fbNames addObject:[attendee objectForKey:@"fbName"]];
        [fbIds addObject:[attendee objectForKey:@"fbId"]];
    }
    
    BOOL isAttending = [fbIds containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"]];
    
    if (isAttending) {
        [self.actionButton setTitle:@"Leave" forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(leaveEvent) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.actionButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(joinEvent) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)updateFacepile {
    // Attendees
    NSArray *attendees = [self.eventDict objectForKey:@"attendees"];
    NSMutableArray *fbNames = [NSMutableArray array];
    NSMutableArray *fbIds = [NSMutableArray array];
    NSMutableArray *fbUrls = [NSMutableArray array];
    for (NSDictionary *attendee in attendees) {
        [fbNames addObject:[attendee objectForKey:@"fbName"]];
        [fbIds addObject:[attendee objectForKey:@"fbId"]];
        [fbUrls addObject:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [attendee objectForKey:@"fbId"]] forKey:@"url"]];
    }
    //    NSString *creatorId = [[attendees objectAtIndexOrNil:0] objectForKey:@"fbId"];
    
    [self.facepileView prepareForReuse];
    self.facepileView.width = [PSFacepileView widthWithFaces:fbUrls];
    self.facepileView.height = [PSFacepileView heightWithFaces:fbUrls];
    [self.facepileView loadWithFaces:fbUrls];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
}

- (void)joinEvent {
    [self mutateEventWithAction:@"join"];
}

- (void)leaveEvent {
    [self mutateEventWithAction:@"leave"];
}


#pragma mark - Events
- (void)mutateEventWithAction:(NSString *)action {
    // action: join or leave
    
    [SVProgressHUD showWithStatus:@"Updating Event..." maskType:SVProgressHUDMaskTypeGradient];
    
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
            
            if (res && [res isKindOfClass:[NSDictionary class]]) {
                [[NotificationManager sharedManager] downloadNotificationsWithCompletionBlock:NULL];
                
                [SVProgressHUD dismissWithSuccess:@"Event Updated"];
                
                if ([res count] > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEventUpdatedNotification object:nil userInfo:res];
                    self.eventDict = res;
                    [self updateFooter];
                    [self updateFacepile];
                } else {
                    // Event was deleted, no attendees left
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEventUpdatedNotification object:nil userInfo:nil];
                    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
                }
            } else {
                [SVProgressHUD dismissWithError:@"Event Update Failed"];
            }
            
        } else {
            [SVProgressHUD dismissWithError:@"Event Update Failed"];
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
