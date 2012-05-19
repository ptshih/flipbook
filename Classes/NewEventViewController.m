//
//  NewEventViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewEventViewController.h"
#import "EventViewController.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

@interface NewEventViewController () <MKMapViewDelegate>

@property (nonatomic, strong) NSDictionary *venueDict;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSString *notes;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) PSTextField *dateField;
@property (nonatomic, strong) PSTextField *notesField;

@end

@implementation NewEventViewController

@synthesize
venueDict = _venueDict,
selectedDate = _selectedDate,
notes = _notes;

@synthesize
contentView = _contentView,
mapView = _mapView,
dateField = _dateField,
notesField = _notesField;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary;
        
        self.title = @"Add Event";
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.mapView.delegate = nil;
    
    self.contentView = nil;
    self.mapView = nil;
    self.dateField = nil;
    self.notesField = nil;
}

- (void)dealloc {
    self.mapView.delegate = nil;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.dateField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.view findAndResignFirstResponder];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    // Content View
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height - self.footerView.height)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentView];
    
    // Venue Mini View
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 112)];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.contentView addSubview:self.mapView];
    
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]), 250, 250);
    [self.mapView setRegion:mapRegion animated:NO];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:self.venueDict];
    [self.mapView addAnnotation:annotation];
    
    // Date and time
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-kTimeInterval3Months];
    datePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:kTimeInterval3Months];
    [datePicker setDate:[NSDate date] animated:NO];
    [datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.dateField = [[PSTextField alloc] initWithFrame:CGRectMake(0, self.mapView.bottom, self.view.width, 44) withInset:UIEdgeInsetsMake(12, 8, 12, 8)];
    [PSStyleSheet applyStyle:@"eventField" forTextField:self.dateField];
    self.dateField.backgroundColor = [UIColor whiteColor];
    self.dateField.placeholder = @"Choose a date and time";
    self.dateField.inputView = datePicker;
    self.dateField.leftViewMode = UITextFieldViewModeAlways;
    self.dateField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconClockBlack"]];
    self.dateField.text = [NSDate stringFromDate:datePicker.date withFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    [self.contentView addSubview:self.dateField];
    
    
    // Add notes
    self.notesField = [[PSTextField alloc] initWithFrame:CGRectMake(0, self.dateField.bottom, self.view.width, 44) withInset:UIEdgeInsetsMake(12, 8, 12, 8)];
    [PSStyleSheet applyStyle:@"eventField" forTextField:self.notesField];
    self.notesField.backgroundColor = [UIColor whiteColor];
    self.notesField.placeholder = @"Add Notes... (optional)";
    [self.notesField addTarget:self action:@selector(notesChanged:) forControlEvents:UIControlEventEditingChanged];
    self.notesField.leftViewMode = UITextFieldViewModeAlways;
    self.notesField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconComposeBlack"]];
    [self.contentView addSubview:self.notesField];
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
    [self.rightButton setImage:[UIImage imageNamed:@"IconCheckWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    self.rightButton.userInteractionEnabled = NO;
    
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
    [self createEvent];
}

- (void)datePickerChanged:(UIDatePicker *)datePicker {
    self.selectedDate = datePicker.date;
    self.dateField.text = [NSDate stringFromDate:datePicker.date withFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
}

- (void)notesChanged:(PSTextField *)notesField {
    self.notes = notesField.text;
}


- (void)createEvent {
    [self.view findAndResignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Adding Event..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/events", API_BASE_URL];
    
    // FB
    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"];
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    NSString *fbName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbName"];
    BOOL shouldPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPostToFacebook"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fbAccessToken forKey:@"fbAccessToken"];
    [parameters setObject:fbId forKey:@"fbId"];
    [parameters setObject:fbName forKey:@"fbName"];
    [parameters setObject:[NSNumber numberWithBool:shouldPost] forKey:@"shouldPostToFacebook"];
    
    // Venue
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"]];
    if ([location objectForKey:@"postalCode"]) {
        formattedAddress = [formattedAddress stringByAppendingFormat:@" %@", [location objectForKey:@"postalCode"]];
    }
    
    [parameters setObject:[self.venueDict objectForKey:@"id"] forKey:@"venueId"];
    [parameters setObject:[self.venueDict objectForKey:@"name"] forKey:@"venueName"];
    [parameters setObject:formattedAddress forKey:@"venueAddress"];
    
    // Event
    if (self.selectedDate) {
        [parameters setObject:[NSNumber numberWithDouble:[self.selectedDate millisecondsSince1970]] forKey:@"date"];
    }
    
    if (self.notes) {
        [parameters setObject:self.notes forKey:@"notes"];
    }
    
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
            
            if (res && [res isKindOfClass:[NSDictionary class]]) {
                [[NotificationManager sharedManager] downloadNotificationsWithCompletionBlock:NULL];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewEventCreatedNotification object:nil userInfo:res];
                
                [SVProgressHUD dismissWithSuccess:@"Event Added"];
                
                EventViewController *vc = [[EventViewController alloc] initWithVenueDict:self.venueDict eventDict:res];
                [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES completionBlock:^{
                    [(PSNavigationController *)self.parentViewController removeViewController:self];
                }];
            } else {
                [SVProgressHUD dismissWithError:@"Event Not Added"];
            }
        } else {
            [SVProgressHUD dismissWithError:@"Event Not Added"];
        }
    }];
}


#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSString *reuseIdentifier = NSStringFromClass([VenueAnnotationView class]);
    VenueAnnotationView *v = (VenueAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (!v) {
        v = [[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        v.canShowCallout = NO;
    }
    
    return v;
}


@end
