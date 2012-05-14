//
//  VenueDetailViewController.m
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueDetailViewController.h"
#import "TipListViewController.h"
#import "CheckinViewController.h"
#import "PhotoTagsViewController.h"
#import "FBConnectViewController.h"

#import "PhotoView.h"
#import "PSZoomView.h"
#import "PSPopoverView.h"
#import "YelpPopoverView.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

#import "EventManager.h"

static NSNumberFormatter *__numberFormatter = nil;

@interface VenueDetailViewController () <PSPopoverViewDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, copy) NSDictionary *eventDict;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, weak) UIButton *eventButton;

// Event
- (void)createEventWithReason:(NSString *)reason;
- (void)updateEventButtonReason:(NSString *)reason;

@end

@implementation VenueDetailViewController

@synthesize
venueDict = _venueDict,
eventDict = _eventDict,
mapView = _mapView;

@synthesize
eventButton = _eventButton;

+ (void)initialize {
    __numberFormatter = [[NSNumberFormatter alloc] init];
    [__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - Init
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary;
        
        // Load event cache
        NSArray *events = [[EventManager sharedManager] events];
        
        // Find the event
        for (NSDictionary *event in events) {
            if ([[event objectForKey:@"venueId"] isEqualToString:[self.venueDict objectForKey:@"id"]]) {
                self.eventDict = event;
            }
        }
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary event:(NSDictionary *)event {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary; 
        self.eventDict = event;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
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
    CGFloat mapTop = 4.0;
    
    UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, headerView.width - 16, mapHeight - 8)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mapView.backgroundColor = [UIColor whiteColor];
    UIImage *mapShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    UIImageView *mapShadowView = [[UIImageView alloc] initWithImage:mapShadowImage];
    mapShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapShadowView.frame = CGRectInset(mapView.bounds, -1, -2);
    [mapView addSubview:mapShadowView];
    [headerView addSubview:mapView];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(4, mapTop, headerView.width - 24, mapHeight - 16)];
    self.mapView.layer.borderWidth = 0.5;
    self.mapView.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
    self.mapView.layer.masksToBounds = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[self.venueDict objectForKey:@"lat"] floatValue], [[self.venueDict objectForKey:@"lng"] floatValue]), 250, 250);
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
    if ([self.venueDict objectForKey:@"stats"]) {
        UIImageView *peopleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPersonMiniBlack"]];
        [mapView addSubview:peopleIcon];
        peopleIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        statsLabel = [UILabel labelWithStyle:@"h3Label"];
        [mapView addSubview:statsLabel];
        statsLabel.backgroundColor = mapView.backgroundColor;
        statsLabel.text = [NSString stringWithFormat:@"%@ people checked in here", [__numberFormatter stringFromNumber:[[self.venueDict objectForKey:@"stats"] objectForKey:@"checkinsCount"]]];
        
        CGSize statsLabelSize = [PSStyleSheet sizeForText:statsLabel.text width:self.mapView.width - 16 style:@"h3Label"];
        statsLabel.frame = CGRectMake(8 + 16, mapTop, statsLabelSize.width, 16.0);
        
        mapTop += statsLabel.height + 2.0;
    }
    
    // Address
    UIButton *addressButton = nil;
    if ([self.venueDict objectForKey:@"formattedAddress"]) {
        UIImageView *addressIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPinMiniBlack"]];
        [mapView addSubview:addressIcon];
        addressIcon.frame = CGRectMake(8, mapTop + 2, 11, 11);
        
        addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapView addSubview:addressButton];
        addressButton.backgroundColor = mapView.backgroundColor;
        [addressButton addTarget:self action:@selector(openAddress:) forControlEvents:UIControlEventTouchUpInside];
        [addressButton setTitle:[self.venueDict objectForKey:@"formattedAddress"] forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"linkButton" forButton:addressButton];
        
        addressButton.frame = CGRectMake(8 + 16, mapTop, self.mapView.width - 16, 16);
        
        mapTop += addressButton.height + 2.0;
    }
    
    // Phone
    UIButton *phoneButton = nil;
    if ([self.venueDict objectForKey:@"contact"] && [[self.venueDict objectForKey:@"contact"] objectForKey:@"formattedPhone"]) {
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
        
        mapTop += phoneButton.height + 2.0;
    }
    
    // Website
    UIButton *websiteButton = nil;
    if ([self.venueDict objectForKey:@"url"]) {
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
        
        mapTop += websiteButton.height + 2.0;
    }
    
    // Menu
    UIButton *menuButton = nil;
    if ([self.venueDict objectForKey:@"menu"]) {
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
        
        mapTop += menuButton.height + 2.0;
    }
    
    // Reservations
    UIButton *reservationsButton = nil;
    if ([self.venueDict objectForKey:@"reservations"]) {
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
        
        mapTop += reservationsButton.height + 2.0;
    }
    
    mapView.height = mapTop + 4.0;
    
    top += mapView.height + 8.0;
    
    // Event
    UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(8, top, headerView.width - 16, 0.0)];
    eventView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    eventView.backgroundColor = [UIColor whiteColor];
    UIImage *eventShadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    UIImageView *eventShadowView = [[UIImageView alloc] initWithImage:eventShadowImage];
    eventShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    eventShadowView.frame = CGRectInset(eventView.bounds, -1, -2);
    [eventView addSubview:eventShadowView];
    [headerView addSubview:eventView];
    
    UIButton *eventButton = [UIButton buttonWithFrame:CGRectMake(8, 4, eventView.width - 16, 44) andStyle:@"checkinButton" target:nil action:nil];
    self.eventButton = eventButton;
    [eventView addSubview:eventButton];
    [eventButton setBackgroundImage:[[UIImage imageNamed:@"ButtonBlue"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    
    if (self.eventDict) {
        // Join existing event OR if creator, show message
        
        if (0) {
            eventButton.enabled = NO;
            [eventButton setTitle:[NSString stringWithFormat:@"I'm going here for %@", [self.eventDict objectForKey:@"reason"]] forState:UIControlStateNormal];
        } else {
            [eventButton setTitle:[NSString stringWithFormat:@"Join %@ for %@", [self.eventDict objectForKey:@"fbName"], [self.eventDict objectForKey:@"reason"]] forState:UIControlStateNormal];
            [eventButton addTarget:self action:@selector(joinEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
    } else {
        // Create new event
        [eventButton setTitle:@"Tell my friends I'm going here for..." forState:UIControlStateNormal];
        [eventButton addTarget:self action:@selector(newEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    eventView.height += eventButton.height + 8.0;
    
    top += eventView.height + 8.0;
    
    // Tip
    // Don't show if no tips
    if ([self.venueDict objectForKey:@"tip"]) {
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
        NSDictionary *tip = [self.venueDict objectForKey:@"tip"];
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
        
        CGFloat tipHeight = countLabel.bottom + 4;
        tipView.height = tipHeight;
        
        UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureIndicatorWhiteBordered"]];
        disclosure.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        disclosure.contentMode = UIViewContentModeCenter;
        disclosure.frame = CGRectMake(tipView.width - 20, 0, 20, tipView.height);
        [tipView addSubview:disclosure];

        
        top += tipView.height;
    }
    
    headerView.height = top;
    
    self.collectionView.headerView = headerView;
}

- (void)setupHeader {
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
    [self.centerButton setTitle:[self.venueDict objectForKey:@"name"] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleLabel.minimumFontSize = 12.0;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
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
    YelpPopoverView *v = [[YelpPopoverView alloc] initWithDictionary:self.venueDict frame:CGRectMake(0, 0, 288, 154)]; // 218
    PSPopoverView *pv = [[PSPopoverView alloc] initWithTitle:@"Powered by Yelp" contentView:v];
    pv.delegate = self;
    [pv showWithSize:v.frame.size inView:self.view];
}

- (void)rightAction {
    // Take a photo
//    PhotoTagsViewController *vc = [[PhotoTagsViewController alloc] initWithDictionary:self.venueDict];
//    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];

    // Checkin
    CheckinViewController *vc = [[CheckinViewController alloc] initWithDictionary:self.venueDict];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
    return;
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

- (void)newEvent:(UIButton *)button {
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"I'm going here for..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Coffee/Tea", @"Lunch", @"Dinner", @"Dessert", @"Drinks", nil];
        [as showInView:self.view];
    } else {
        FBConnectViewController *vc = [[FBConnectViewController alloc] initWithNibName:nil bundle:nil];
        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionUp animated:YES];
    }
}

- (void)joinEvent:(UIButton *)button {
    // Send request to server, update EventManager cache on response
    NSString *reason = [self.eventDict objectForKey:@"reason"];
    [self updateEventButtonReason:reason];
}

- (void)createEventWithReason:(NSString *)reason {
    self.eventButton.enabled = NO;
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/events", API_BASE_URL];

    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"];
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    NSString *fbName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbName"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fbAccessToken forKey:@"fbAccessToken"];
    [parameters setObject:fbId forKey:@"fbId"];
    [parameters setObject:fbName forKey:@"fbName"];
    [parameters setObject:[self.venueDict objectForKey:@"id"] forKey:@"venueId"];
    [parameters setObject:[self.venueDict objectForKey:@"name"] forKey:@"venueName"];
    [parameters setObject:reason forKey:@"reason"];
    
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
            
            self.eventDict = (NSDictionary *)res;
            if (self.eventDict) {
                [self updateEventButtonReason:[self.eventDict objectForKey:@"reason"]];
            }
        } else {
            self.eventButton.enabled = YES;
        }
    }];
}

- (void)updateEventButtonReason:(NSString *)reason {
    // TODO: move this to an updateWithReason method
    if (self.eventButton) {
        self.eventButton.enabled = NO;
        [self.eventButton setTitle:[NSString stringWithFormat:@"I'm going here for %@", reason] forState:UIControlStateNormal];
    }
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    DLog(@"remote data source did error");
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSString *URLPath = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos", [self.venueDict objectForKey:@"id"]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:FS_API_VERSION forKey:@"v"];
    [parameters setObject:@"venue" forKey:@"group"];
    [parameters setObject:[NSNumber numberWithInteger:500] forKey:@"limit"];
    [parameters setObject:@"2CPOOTGBGYH53Q2LV3AORUF1JO0XV0FZLU1ZSZ5VO0GSKELO" forKey:@"client_id"];
    [parameters setObject:@"W45013QS5ADELZMVZYIIH3KX44TZQXDN0KQN5XVRN1JPJVGB" forKey:@"client_secret"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [blockSelf.items removeAllObjects];
            [blockSelf dataSourceDidError];
        } else {
            [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                if (!apiResponse) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [blockSelf.items removeAllObjects];
                        [blockSelf dataSourceDidError];
                    }];
                } else {
                    // Process 4sq response
                    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                    NSDictionary *response = [apiResponse objectForKey:@"response"];
                    NSArray *photos = [[response objectForKey:@"photos"] objectForKey:@"items"];
                    if (photos && [photos count] > 0) {
                        for (NSDictionary *photo in photos) {
                            NSDictionary *user = [photo objectForKey:@"user"];
                            NSString *firstName = [NSString stringWithFormat:@"%@", [user objectForKey:@"firstName"]];
                            NSString *name = ([user objectForKey:@"lastName"]) ? [firstName stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : firstName;
                            NSDictionary *sizes = [photo objectForKey:@"sizes"];
                            NSDictionary *fullSize = [[sizes objectForKey:@"items"] objectAtIndex:0];
                            
                            NSMutableDictionary *item = [NSMutableDictionary dictionary];
                            [item setObject:[fullSize objectForKey:@"url"] forKey:@"source"];
                            [item setObject:[fullSize objectForKey:@"width"] forKey:@"width"];
                            [item setObject:[fullSize objectForKey:@"height"] forKey:@"height"];
                            [item setObject:name forKey:@"name"];
                            [item setObject:[user objectForKey:@"homeCity"] forKey:@"homeCity"];
                            [items addObject:item];
                        }
                    } else {
                        // No photos found
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [blockSelf.items removeAllObjects];
                            [blockSelf dataSourceDidError];
                        }];
                    }
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [blockSelf.items removeAllObjects];
                        [blockSelf.items addObjectsFromArray:items];
                        [blockSelf dataSourceDidLoad];
                    }];
                }
            }];
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
        NSString *lat = [self.venueDict objectForKey:@"lat"];
        NSString *lng = [self.venueDict objectForKey:@"lng"];
        
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
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [[self.venueDict objectForKey:@"formattedAddress"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)openPhone:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[self.venueDict objectForKey:@"contact"] objectForKey:@"phone"]]]];
}

- (void)openWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.venueDict objectForKey:@"url"]]];
}

- (void)openMenu:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"menu"] objectForKey:@"mobileUrl"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)openReservations:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@", [[self.venueDict objectForKey:@"reservations"] objectForKey:@"url"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    NSString *reason = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    [self createEventWithReason:reason];
}

@end
