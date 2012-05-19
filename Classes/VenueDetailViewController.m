//
//  VenueDetailViewController.m
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueDetailViewController.h"
#import "TipListViewController.h"
#import "NewEventViewController.h"
#import "EventViewController.h"
//#import "CheckinViewController.h"
//#import "PhotoTagsViewController.h"
#import "PSWebViewController.h"

#import "PhotoView.h"
#import "PSZoomView.h"
#import "PSPopoverView.h"
#import "YelpPopoverView.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

#import "ActionSheetPicker.h"

static NSNumberFormatter *__numberFormatter = nil;

@interface VenueDetailViewController () <PSPopoverViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MKMapViewDelegate>

@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, strong) NSDictionary *venueDict;
@property (nonatomic, strong) NSDictionary *eventDict;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) UIView *eventView;
@property (nonatomic, strong) UILabel *eventLabel;

@end

@implementation VenueDetailViewController

@synthesize
venueId = _venueId,
eventId = _eventId,
venueDict = _venueDict,
eventDict = _eventDict,
mapView = _mapView;

@synthesize
eventView = _eventView,
eventLabel = _eventLabel;

+ (void)initialize {
    __numberFormatter = [[NSNumberFormatter alloc] init];
    [__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - Init
- (id)initWithVenueId:(NSString *)venueId eventId:(NSString *)eventId {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueId = venueId;
        self.eventId = eventId;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
        //        self.shouldPullRefresh = YES;
        
        self.title = @"Loading...";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventUpdated:) name:kEventUpdatedNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.mapView.delegate = nil;
}

- (void)dealloc {
    self.mapView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupVenueSubviews {
    [self updateHeader];
    
    // Empty Label
    UILabel *emptyLabel = [UILabel labelWithText:@"No Photos Found" style:@"emptyLabel"];
    emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.emptyView = emptyLabel;
    
    // 4sq attribution
    UIImageView *pb4sq = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByFoursquareBlack"]];
    pb4sq.contentMode = UIViewContentModeCenter;
    pb4sq.frame = CGRectMake(0, 0, self.collectionView.width, pb4sq.height);
    // Add gradient
    [pb4sq addGradientLayerWithFrame:CGRectMake(0, 0, pb4sq.width, 8.0) colors:[NSArray arrayWithObjects:(id)RGBACOLOR(0, 0, 0, 0.3).CGColor, (id)RGBACOLOR(0, 0, 0, 0.2).CGColor, (id)RGBACOLOR(0, 0, 0, 0.1).CGColor, (id)RGBACOLOR(0, 0, 0, 0.0).CGColor, nil] locations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil] startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
    self.collectionView.footerView = pb4sq;
    
    CGFloat mapHeight;
    if (isDeviceIPad()) {
        mapHeight = 320;
    } else {
        mapHeight = 160;
    }
    
    // Setup collectionView header
    // 2 part collection header
    CGFloat top = 0.0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.width, 0.0)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Map    
    UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, headerView.width - 16, mapHeight - 8)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mapView.backgroundColor = [UIColor whiteColor];
    UIImage *mapShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    UIImageView *mapShadowView = [[UIImageView alloc] initWithImage:mapShadowImage];
    mapShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapShadowView.frame = CGRectInset(mapView.bounds, -1, -2);
    [mapView addSubview:mapShadowView];
    [headerView addSubview:mapView];
    
    CGFloat mapTop = 4.0;
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(4, mapTop, headerView.width - 24, mapHeight - 16)];
    self.mapView.layer.borderWidth = 0.5;
    self.mapView.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
    self.mapView.layer.masksToBounds = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]), 250, 250);
    [self.mapView setRegion:mapRegion animated:NO];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:self.venueDict];
    [self.mapView addAnnotation:annotation];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomMap:)];
    [self.mapView addGestureRecognizer:gr];
    [mapView addSubview:self.mapView];
    
    mapTop += self.mapView.height + 4.0;
    
    // Stats
    UILabel *statsLabel = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"stats"])) {
        UIImageView *peopleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPersonMiniBlack"]];
        [mapView addSubview:peopleIcon];
        peopleIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        statsLabel = [UILabel labelWithStyle:@"h3Label"];
        [mapView addSubview:statsLabel];
        statsLabel.backgroundColor = mapView.backgroundColor;
        statsLabel.text = [NSString stringWithFormat:@"%@ people checked in here", [__numberFormatter stringFromNumber:[[self.venueDict objectForKey:@"stats"] objectForKey:@"checkinsCount"]]];
        
        CGSize statsLabelSize = [PSStyleSheet sizeForText:statsLabel.text width:self.mapView.width - 16 style:@"h3Label"];
        statsLabel.frame = CGRectMake(8 + 16, mapTop, statsLabelSize.width, 16.0);
        
        mapTop += statsLabel.height + 4.0;
    }
    
    // Address
    UIButton *addressButton = nil;
    NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"]];
    if ([location objectForKey:@"postalCode"]) {
        formattedAddress = [formattedAddress stringByAppendingFormat:@" %@", [location objectForKey:@"postalCode"]];
    }
    
    if (formattedAddress) {
        UIImageView *addressIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPinMiniBlack"]];
        [mapView addSubview:addressIcon];
        addressIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:addressButton];
        addressButton.backgroundColor = mapView.backgroundColor;
        [addressButton addTarget:self action:@selector(openAddress:) forControlEvents:UIControlEventTouchUpInside];
        [addressButton setTitle:formattedAddress forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:addressButton];
        
        addressButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16, 16);
        
        mapTop += addressButton.height + 4.0;
    }
    
    // Phone
    UIButton *phoneButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"contact"]) && [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]) {
        UIImageView *phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPhoneBlack"]];
        [mapView addSubview:phoneIcon];
        phoneIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:phoneButton];
        phoneButton.backgroundColor = mapView.backgroundColor;
        [phoneButton addTarget:self action:@selector(openPhone:) forControlEvents:UIControlEventTouchUpInside];
        [phoneButton setTitle:[NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:phoneButton];
        
        phoneButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16, 16);
        
        mapTop += phoneButton.height + 4.0;
    }
    
    // Website
    UIButton *websiteButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"url"])) {
        UIImageView *websiteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPlanetBlack"]];
        [mapView addSubview:websiteIcon];
        websiteIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:websiteButton];
        websiteButton.backgroundColor = mapView.backgroundColor;
        [websiteButton addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
        [websiteButton setTitle:[NSString stringWithFormat:@"%@", [self.venueDict objectForKey:@"url"]] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:websiteButton];
        
        websiteButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16, 16);
        
        mapTop += websiteButton.height + 4.0;
    }
    
    // Menu
    UIButton *menuButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"menu"])) {
        UIImageView *menuIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFoodBlack"]];
        [mapView addSubview:menuIcon];
        menuIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:menuButton];
        menuButton.backgroundColor = mapView.backgroundColor;
        [menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setTitle:[NSString stringWithFormat:@"%@", @"See the menu"] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:menuButton];
        
        menuButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16, 16);
        
        mapTop += menuButton.height + 4.0;
    }
    
    // Reservations
    UIButton *reservationsButton = nil;
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"reservations"])) {
        UIImageView *reservationsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconReservationsBlack"]];
        [mapView addSubview:reservationsIcon];
        reservationsIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        reservationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:reservationsButton];
        reservationsButton.backgroundColor = mapView.backgroundColor;
        [reservationsButton addTarget:self action:@selector(openReservations:) forControlEvents:UIControlEventTouchUpInside];
        [reservationsButton setTitle:[NSString stringWithFormat:@"%@", @"Make reservations on OpenTable"] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:reservationsButton];
        
        reservationsButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16, 16);
        
        mapTop += reservationsButton.height + 4.0;
    }
    
    mapView.height = mapTop;
    
    top = mapView.bottom + 8.0;
    
    // Tip
    // Don't show if no tips
    if (OBJ_NOT_NULL([self.venueDict objectForKey:@"tips"]) && [[self.venueDict objectForKey:@"tips"] count] > 0) {
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(8, top, headerView.width - 16, 0.0)];
        tipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tipView.backgroundColor = [UIColor whiteColor];
        UIImage *tipShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *tipShadowView = [[UIImageView alloc] initWithImage:tipShadowImage];
        tipShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tipShadowView.frame = CGRectInset(tipView.bounds, -1, -2);
        [tipView addSubview:tipShadowView];
        UITapGestureRecognizer *tipGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushTips:)];
        [tipView addGestureRecognizer:tipGR];
        [headerView addSubview:tipView];
        
        UIImageView *divider = nil;
        CGSize labelSize = CGSizeZero;
        CGFloat tipWidth = tipView.width - 16 - 20;
        
        UILabel *tipUserLabel = [UILabel labelWithStyle:@"boldLabel"];
        tipUserLabel.backgroundColor = tipView.backgroundColor;
        [tipView addSubview:tipUserLabel];
        
        UILabel *tipLabel = [UILabel labelWithStyle:@"textLabel"];
        tipLabel.backgroundColor = tipView.backgroundColor;
        [tipView addSubview:tipLabel];
        
        // Tip
        NSDictionary *tip = [[self.venueDict objectForKey:@"tips"] objectAtIndexOrNil:0];
        NSDictionary *tipUser = [tip objectForKey:@"user"];
        NSString *tipUserName = tipUser ? [tipUser objectForKey:@"firstName"] : nil;
        tipUserName = [tipUser objectForKey:@"lastName"] ? [tipUserName stringByAppendingFormat:@" %@", [tipUser objectForKey:@"lastName"]] : tipUserName;
        NSString *tipUserText = [NSString stringWithFormat:@"%@ says:", tipUserName];
        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
        
        tipUserLabel.text = tipUserText;
        labelSize = [PSStyleSheet sizeForText:tipUserLabel.text width:(tipView.width - 16.0) style:@"boldLabel"];
        tipUserLabel.frame = CGRectMake(8, 4, tipWidth, labelSize.height);
        
        tipLabel.text = tipText;
        labelSize = [PSStyleSheet sizeForText:tipLabel.text width:(tipView.width - 16.0) style:@"textLabel"];
        tipLabel.frame = CGRectMake(8, tipUserLabel.bottom, tipWidth, labelSize.height);
        
        divider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        divider.frame = CGRectMake(8, tipLabel.bottom + 4, tipWidth, 1.0);
        [tipView addSubview:divider];
        
        // Stats
        NSDictionary *stats = [self.venueDict objectForKey:@"stats"];
        
        UILabel *countLabel = [UILabel labelWithStyle:@"boldLabel"];
        countLabel.backgroundColor = tipView.backgroundColor;
        countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        countLabel.text = [NSString stringWithFormat:@"View All %@ Tips", [stats objectForKey:@"tipCount"]];
        labelSize = [PSStyleSheet sizeForText:countLabel.text width:(tipView.width - 16.0) style:@"boldLabel"];
        countLabel.frame = CGRectMake(8, divider.bottom + 4, tipWidth, labelSize.height);
        [tipView addSubview:countLabel];
        
        CGFloat tipHeight = countLabel.bottom + 4.0;
        tipView.height = tipHeight;
        
        UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
        disclosure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosure.contentMode = UIViewContentModeCenter;
        disclosure.frame = CGRectMake(tipView.width - 20, 0, 20, tipView.height);
        [tipView addSubview:disclosure];
        
        
        top += tipView.height + 8.0;
    }
    
    headerView.height = top;
    
    self.collectionView.headerView = headerView;
}

- (void)setupSubviews {
    [super setupSubviews];
}

- (void)setupHeader {
    [super setupHeader];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleLabel.minimumFontSize = 12.0;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCalendarWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.rightButton.userInteractionEnabled = NO;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

- (void)setupFooter {
    [super setupFooter];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 44)];
    self.footerView.backgroundColor = RGBCOLOR(33, 33, 33);
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.footerView];
    
    // Event
    self.eventView = [[UIView alloc] initWithFrame:CGRectInset(self.footerView.bounds, 8, 8)];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushEvent:)];
    [self.eventView addGestureRecognizer:gr];
    [self.footerView addSubview:self.eventView];
    
    self.eventLabel = [UILabel labelWithStyle:@"eventLabel"];
    self.eventLabel.frame = CGRectMake(0, 0, self.eventView.width - 20.0, self.eventView.height);
    [self.eventView addSubview:self.eventLabel];
    
    UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrow"]];
    disclosure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    disclosure.contentMode = UIViewContentModeCenter;
    disclosure.frame = CGRectMake(self.eventView.width - 20, 0, 20, self.eventView.height);
    [self.eventView addSubview:disclosure];
    
    // If no venueDict, don't setup the footer
    if (!self.venueDict) return;
    
    // Update footer
    [self updateFooter];
}

- (void)updateHeader {
    // Call this when venueDict is ready to re-enable header actions
    self.title = [self.venueDict objectForKey:@"name"];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = YES;
    self.rightButton.userInteractionEnabled = YES;
}

- (void)updateFooter {
    // animate footer
    if (self.footerView.top == self.view.bottom) {
        [UIView animateWithDuration:0.4 animations:^{
            self.footerView.top -= self.footerView.height;
        } completion:^(BOOL finished) {
            [self updateSubviews];
        }];
    }
    
    if (self.eventDict) {
        NSArray *attendees = [self.eventDict objectForKey:@"attendees"];
        NSMutableArray *fbNames = [NSMutableArray array];
        NSMutableArray *fbIds = [NSMutableArray array];
        for (NSDictionary *attendee in attendees) {
            [fbNames addObject:[attendee objectForKey:@"fbName"]];
            [fbIds addObject:[attendee objectForKey:@"fbId"]];
        }
        
        // Find out if user is attending
        BOOL isAttending = [fbIds containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"]];
        
        if (isAttending) {
            [fbNames removeObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbName"]];
            NSString *andFriends = (fbNames.count > 0) ? [NSString stringWithFormat:@" and %@ ", [fbNames componentsJoinedByString:@", "]] : @" ";
            self.eventLabel.text = [NSString stringWithFormat:@"You%@are part of an event on %@", andFriends, [NSDate stringFromDate:[NSDate dateWithMillisecondsSince1970:[[self.eventDict objectForKey:@"datetime"] doubleValue]] withFormat:@"EEE, MMM dd, yyyy @ HH:mm a z"]];
        } else {
            NSString *isOrAre = (fbNames.count > 1) ? @"are" : @"is";
            self.eventLabel.text = [NSString stringWithFormat:@"%@ %@ part of an event on %@", [fbNames componentsJoinedByString:@", "], isOrAre, [NSDate stringFromDate:[NSDate dateWithMillisecondsSince1970:[[self.eventDict objectForKey:@"datetime"] doubleValue]] withFormat:@"EEE, MMM dd, yyyy @ HH:mm a z"]];
        }
    } else {
        self.eventLabel.text = @"You and your friends are not part of an event here. Tap here to start one now!";
    }
}

//- (void)updateFooter {
//    [self.eventButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    
//    if (self.eventDict) {
//        NSString *title = nil;
//        NSString *subtitle = nil;
//        NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
//        
//        NSString *reason = [self.eventDict objectForKey:@"reason"];
//        NSArray *attendeeIds = [self.eventDict objectForKey:@"attendeeIds"];
//        NSArray *attendeeNames = [self.eventDict objectForKey:@"attendeeNames"];
//        NSArray *friendIds = [attendeeIds subarrayWithRange:NSMakeRange(1, attendeeIds.count - 1)];
//        NSString *ownerId = [attendeeIds objectAtIndexOrNil:0];
//        NSString *ownerName = [attendeeNames objectAtIndexOrNil:0];
//        
//        title = ([fbId isEqualToString:ownerId]) ? [NSString stringWithFormat:@"You are going for %@", reason] : [NSString stringWithFormat:@"%@ is going for %@", ownerName, reason];
//        
//        
//        if (friendIds.count > 0) {
//            NSString *friendText = nil;
//            NSInteger numFriends;
//            if ([friendIds containsObject:fbId]) {
//                numFriends = friendIds.count - 1;
//                if (numFriends > 0) {
//                    friendText = (numFriends == 1) ? [NSString stringWithFormat:@"%d friend is", numFriends] : [NSString stringWithFormat:@"%d friends are", numFriends];
//                    subtitle = [NSString stringWithFormat:@"You and %@ also going", friendText];
//                } else {
//                    subtitle = [NSString stringWithFormat:@"You are also going"];
//                }
//            } else {
//                numFriends = friendIds.count;
//                friendText = (numFriends == 1) ? [NSString stringWithFormat:@"%d friend is", numFriends] : [NSString stringWithFormat:@"%d friends are", numFriends];
//                subtitle = [NSString stringWithFormat:@"%@ also going", friendText];
//            }
//        } else {
//            subtitle = @"No one else is going yet";
//        }
//        
//        // Button
//        if ([attendeeIds containsObject:fbId]) {
//            [self.eventButton setTitle:@"Edit" forState:UIControlStateNormal];
//            [self.eventButton addTarget:self action:@selector(leaveEvent:) forControlEvents:UIControlEventTouchUpInside];
//        } else {
//            [self.eventButton setTitle:@"Join" forState:UIControlStateNormal];
//            [self.eventButton addTarget:self action:@selector(joinEvent:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        
//        self.eventLabel.text = [NSString stringWithFormat:@"%@\r\n%@", title, subtitle];
//    } else {
//        // Create new event
//        self.eventLabel.text = @"Tell your friends you plan to go here\r\nWe'll let them know on Facebook";
//        [self.eventButton setTitle:@"Go" forState:UIControlStateNormal];
//        [self.eventButton addTarget:self action:@selector(newEvent:) forControlEvents:UIControlEventTouchUpInside];
//    }
//}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
    YelpPopoverView *v = [[YelpPopoverView alloc] initWithDictionary:self.venueDict frame:CGRectMake(0, 0, 288, 154)]; // 218
    PSPopoverView *pv = [[PSPopoverView alloc] initWithTitle:@"Powered by Yelp" contentView:v];
    pv.delegate = self;
    [pv showWithSize:v.frame.size inView:self.view];
}

- (void)rightAction {
    [self pushEvent:nil];
    
    // Take a photo
//    PhotoTagsViewController *vc = [[PhotoTagsViewController alloc] initWithDictionary:self.venueDict];
//    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
    // Checkin
//    CheckinViewController *vc = [[CheckinViewController alloc] initWithDictionary:self.venueDict];
//    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
//    return;
    
    
    
    //    
    //    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Foursquare" message:[NSString stringWithFormat:@"Check in to %@ on Foursquare?", [self.venueDict objectForKey:@"name"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
    //    av.tag = kAlertTagFoursquare;
    //    [av show];
    //    
    //    return;
    //    
    //    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"foursquare:"]]) {
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", [self.venueDict objectForKey:@"id"]]]];
    //    } else {
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://foursquare.com/touch/v/%@", [self.venueDict objectForKey:@"id"]]]];
    //    }
}

- (void)pushEvent:(UITapGestureRecognizer *)gr {
    if (self.eventDict) {
        // If user is already part of an event here, edit mode otherwise create mode
        EventViewController *vc = [[EventViewController alloc] initWithVenueDict:self.venueDict eventDict:self.eventDict];
        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    } else {
        // If user is already part of an event here, edit mode otherwise create mode
        NewEventViewController *vc = [[NewEventViewController alloc] initWithDictionary:self.venueDict];
        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    }
}

- (void)zoomMap:(UITapGestureRecognizer *)gr {
    if (![PSZoomView prepareToZoom]) {
        return;
    }
    
    MKMapView *v = (MKMapView *)gr.view;
    
    CGRect convertedFrame = [self.view.window convertRect:v.frame fromView:v.superview];
    [PSZoomView showMapView:v withFrame:convertedFrame inView:self.view.window fullscreen:YES];
    
    [self.mapView selectAnnotation:[[self.mapView annotations] lastObject] animated:YES];
}

- (void)pushTips:(UITapGestureRecognizer *)gr {
    TipListViewController *vc = [[TipListViewController alloc] initWithDictionary:self.venueDict];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}


#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
}

//- (void)reloadDataSource {
//    [super reloadDataSource];
//    
//    [self loadDataSourceFromRemoteUsingCache:NO];
//}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
    }
    
    // Load event
    // Don't setup footer yet if an event was passed in
    // We need to download it to find out what messave to show
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        if (self.eventId) {
            // Delayed footer setup
            [self loadEventWithId:self.eventId];
        } else {
            // Ask server if I have an event here
            [self findEventForVenueId:self.venueId];
        }
    } else {
        // noop
    }
}

- (void)dataSourceDidError {
    DLog(@"remote data source did error");
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

- (void)findEventForVenueId:(NSString *)venueId {
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/venues/%@/events", API_BASE_URL, venueId];
    
    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"];
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    NSString *fbName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbName"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fbAccessToken forKey:@"fbAccessToken"];
    [parameters setObject:fbId forKey:@"fbId"];
    [parameters setObject:fbName forKey:@"fbName"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:blockSelf];
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //        NSLog(@"res: %@", res);
            if (res && [res isKindOfClass:[NSArray class]] && [res count] > 0) {
                self.eventDict = [res objectAtIndexOrNil:0];
            }
        }
        [self updateFooter]; // delayed footer setup
    }];
}

- (void)loadEventWithId:(NSString *)eventId {
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/events/%@", API_BASE_URL, eventId];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    BLOCK_SELF;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:blockSelf];
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //        NSLog(@"res: %@", res);
            self.eventDict = res;
            [self updateFooter]; // delayed footer setup
        }
    }];
    
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/venues/%@", API_BASE_URL, self.venueId];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    BLOCK_SELF;
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            blockSelf.venueDict = nil;
            [blockSelf.items removeAllObjects];
            [blockSelf dataSourceDidError];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                // Parse out venueDict
                
                NSMutableDictionary *venueDict = [NSMutableDictionary dictionary];
                
                // id and name
                [venueDict setObject:[apiResponse objectForKey:@"id"] forKey:@"id"];
                [venueDict setObject:[apiResponse objectForKey:@"name"] forKey:@"name"];
                
                // location
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"location"]) forKey:@"location"];
                
                // contact
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"contact"]) forKey:@"contact"];
                
                // url
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"url"]) forKey:@"url"];
                
                // categories
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"categories"]) forKey:@"categories"];
                
                // stats
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"stats"]) forKey:@"stats"];
                
                // menu
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"menu"]) forKey:@"menu"];
                
                // reservations
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"reservations"]) forKey:@"reservations"];
                
                // tips
                [venueDict setObject:OBJ_OR_NULL([apiResponse objectForKey:@"tips"]) forKey:@"tips"];
                
                blockSelf.venueDict = [NSDictionary dictionaryWithDictionary:venueDict];
                
                // load/setup the headers
                [blockSelf setupVenueSubviews];
                
                // Parse out the photos
                NSMutableArray *items = [NSMutableArray array];
                NSArray *photos = [apiResponse objectForKey:@"photos"];
                for (NSDictionary *photo in photos) {
                    NSDictionary *user = [photo objectForKey:@"user"];
                    NSString *firstName = [NSString stringWithFormat:@"%@", [user objectForKey:@"firstName"]];
                    NSString *name = ([user objectForKey:@"lastName"]) ? [firstName stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : firstName;
                    NSDictionary *sizes = [photo objectForKey:@"sizes"];
                    NSDictionary *fullSize = [[sizes objectForKey:@"items"] objectAtIndexOrNil:0];
                    
                    NSMutableDictionary *item = [NSMutableDictionary dictionary];
                    [item setObject:[fullSize objectForKey:@"url"] forKey:@"source"];
                    [item setObject:[fullSize objectForKey:@"width"] forKey:@"width"];
                    [item setObject:[fullSize objectForKey:@"height"] forKey:@"height"];
                    [item setObject:name forKey:@"name"];
                    [item setObject:[user objectForKey:@"homeCity"] forKey:@"homeCity"];
                    [items addObject:item];
                }
                
                // Pass photos to collectionView
                [blockSelf.items removeAllObjects];
                [blockSelf.items addObjectsFromArray:items];
                [blockSelf dataSourceDidLoad];
                
            } else {
                // Error in apiResponse
                blockSelf.venueDict = nil;
                [blockSelf.items removeAllObjects];
                [blockSelf dataSourceDidError];
            }
        }
    }];
}

#pragma mark - PSCollectionViewDelegate
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    PhotoView *v = (PhotoView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[PhotoView alloc] initWithFrame:CGRectZero];
    }
    
    [v fillViewWithObject:item];
    
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [PhotoView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    PhotoView *v = (PhotoView *)view;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = v.imageView;
    if (!imageView.image) return;
    
    // make sure to zoom the full res image here
    NSURL *originalURL = imageView.originalURL;
    UIActivityIndicatorViewStyle oldStyle = imageView.loadingIndicator.activityIndicatorViewStyle;
    imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView.loadingIndicator startAnimating];
    
    [[PSURLCache sharedCache] loadURL:originalURL cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        [imageView.loadingIndicator stopAnimating];
        imageView.loadingIndicator.activityIndicatorViewStyle = oldStyle;
        
        if (!error) {
            UIImage *sourceImage = [UIImage imageWithData:cachedData];
            if (sourceImage) {
                CGRect convertedFrame = [self.view.window convertRect:imageView.frame fromView:imageView.superview];
                
                if ([PSZoomView prepareToZoom]) {
                    [PSZoomView showImage:imageView.image withFrame:convertedFrame inView:self.view.window];
                }
            }
        }
    }];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSString *reuseIdentifier = NSStringFromClass([VenueAnnotationView class]);
    VenueAnnotationView *v = (VenueAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (!v) {
        v = [[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        v.canShowCallout = YES;
        v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"View Directions" message:[NSString stringWithFormat:@"Open %@ in Google Maps?", [view.annotation title]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    av.tag = kAlertTagDirections;
    [av show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    
    if (alertView.tag == kAlertTagDirections) {
        // Show directions
        CLLocationCoordinate2D currentLocation = [[PSLocationCenter defaultCenter] locationCoordinate];
        NSDictionary *location = [self.venueDict objectForKey:@"location"];
        NSString *lat = [location objectForKey:@"lat"];
        NSString *lng = [location objectForKey:@"lng"];
        
        if (lat && lng) {
            NSString *mapsUrl = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@", currentLocation.latitude, currentLocation.longitude, lat, lng];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsUrl]];
        }
    } else if (alertView.tag == kAlertTagFoursquare) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"foursquare:"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"foursquare://venues/%@", [self.venueDict objectForKey:@"id"]]]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://foursquare.com/touch/v/%@", [self.venueDict objectForKey:@"id"]]]];
        }
    }
}

#pragma mark - Button Actions
- (void)openAddress:(id)sender {
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"]];
    if ([location objectForKey:@"postalCode"]) {
        formattedAddress = [formattedAddress stringByAppendingFormat:@" %@", [location objectForKey:@"postalCode"]];
    }
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [formattedAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)openPhone:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"phone"]]]];
}

- (void)openWebsite:(id)sender {
    NSString *urlString = [self.venueDict objectForKey:@"url"];
    if (urlString) {
        PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlString title:nil];
        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    }
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.venueDict objectForKey:@"url"]]];
}

- (void)openMenu:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"menu"] objectForKey:@"mobileUrl"]];
    
    PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlString title:@"Menu"];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)openReservations:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"reservations"] objectForKey:@"url"]];
    
    PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:urlString title:@"OpenTable Reservations"];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - Notifications

- (void)eventUpdated:(NSNotification *)notification {
    NSDictionary *eventDict = notification.userInfo;
    self.eventDict = eventDict;
    [self updateFooter];
}

@end
