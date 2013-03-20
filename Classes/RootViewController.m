//
//  RootViewController.m
//  Detour
//
//  Created by Peter Shih on 3/16/13.
//
//

#import "RootViewController.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

@implementation MKPolyline (MKPolyline_EncodedString)

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedString length]];
    [encoded appendString:encodedString];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    
    NSInteger numberOfSteps = array.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [array objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    return polyLine;
}
//
//+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
//    const char *bytes = [encodedString UTF8String];
//    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//    NSUInteger idx = 0;
//    
//    NSUInteger count = length / 4;
//    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
//    NSUInteger coordIdx = 0;
//    
//    float latitude = 0;
//    float longitude = 0;
//    while (idx < length) {
//        char byte = 0;
//        int res = 0;
//        char shift = 0;
//        
//        do {
//            byte = bytes[idx++] - 63;
//            res |= (byte & 0x1F) << shift;
//            shift += 5;
//        } while (byte >= 0x20);
//        
//        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
//        latitude += deltaLat;
//        
//        shift = 0;
//        res = 0;
//        
//        do {
//            byte = bytes[idx++] - 0x3F;
//            res |= (byte & 0x1F) << shift;
//            shift += 5;
//        } while (byte >= 0x20);
//        
//        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
//        longitude += deltaLon;
//        
//        float finalLat = latitude * 1E-5;
//        float finalLon = longitude * 1E-5;
//        
//        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
//        coords[coordIdx++] = coord;
//        
//        if (coordIdx == count) {
//            NSUInteger newCount = count + 10;
//            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
//            count = newCount;
//        }
//    }
//    
//    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
//    free(coords);
//    
//    return polyline;
//}

@end

@interface RootViewController () <MKMapViewDelegate, UISearchBarDelegate>

// Views
@property (nonatomic, strong) UIView *modeView;
@property (nonatomic, strong) UIView *durationView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UISlider *durationSlider;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) MKMapView *mapView;

// Objects
@property (nonatomic, strong) NSOperationQueue *routeQueue;
@property (nonatomic, strong) NSString *selectedMode;
@property (nonatomic, strong) NSMutableArray *venues;
@property (nonatomic, strong) NSMutableArray *venueAnnotations;

// Constants
@property (nonatomic, assign) CGFloat lastDuration;
@property (nonatomic, assign) BOOL durationDidChange;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) BOOL hasLoadedOnce;

@end

@implementation RootViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Check";
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = YES;
        self.shouldShowNullView = NO;
        
        self.headerHeight = 44.0;
        self.footerHeight = 49.0;
        
        self.hasLoadedOnce = NO;
        self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] lat], [[PSLocationCenter defaultCenter] lng]);

        self.venues = [NSMutableArray array];
        self.venueAnnotations = [NSMutableArray array];
        
        self.routeQueue = [[NSOperationQueue alloc] init];
        self.routeQueue.maxConcurrentOperationCount = 1;
        
        self.lastDuration = 10;
        self.durationDidChange = NO;
        
        self.selectedMode = @"walking";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:kPSLocationCenterDidUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFail) name:kPSLocationCenterDidFail object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Location Notification

- (void)locationDidUpdate {
    self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] lat], [[PSLocationCenter defaultCenter] lng]);
    
    if (!self.hasLoadedOnce) {
        [self loadDataSource];
    }
}

- (void)locationDidFail {
    if (!self.hasLoadedOnce) {
        [self dataSourceDidError];
    }
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.contentView.bounds];
    self.mapView = mapView;
    mapView.delegate = self;
    mapView.scrollEnabled = YES;
    mapView.zoomEnabled = YES;
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.contentView addSubview:mapView];
    
    // Mode
    UIView *modeView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.width - 32 - 10, self.contentView.height - 32 - 15, 32, 32)];
    modeView.backgroundColor = [UIColor clearColor];
    self.modeView = modeView;
    [self.contentView addSubview:modeView];
    
    UIButton *modeButton = [[UIButton alloc] initWithFrame:modeView.bounds];
    [modeButton setImage:[UIImage imageNamed:@"IconHeartBlack"] forState:UIControlStateNormal];
    [modeButton addTarget:self action:@selector(selectMode:) forControlEvents:UIControlEventTouchUpInside];
    [modeView addSubview:modeButton];
    
    
    // Duration
    UIView *durationView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.height - 56 - 15, 56, 56)];
    durationView.backgroundColor = [UIColor lightGrayColor];
    self.durationView = durationView;
    [self.contentView addSubview:durationView];

    UILabel *durationLabel = [UILabel labelWithStyle:@"titleDarkLabel"];
    self.durationLabel = durationLabel;
    durationLabel.frame = CGRectMake(0, 0, durationView.width, durationView.height / 2);
    durationLabel.textAlignment = UITextAlignmentCenter;
    [durationView addSubview:durationLabel];
    self.durationLabel.text = [NSString stringWithFormat:@"%.0f", self.lastDuration];
    
    UILabel *minLabel = [UILabel labelWithText:@"min" style:@"titleDarkLabel"];
    minLabel.frame = CGRectMake(0, durationView.height / 2, durationView.width, durationView.height / 2);
    minLabel.textAlignment = UITextAlignmentCenter;
    [durationView addSubview:minLabel];
}

- (void)setupHeader {
    [super setupHeader];
    self.headerView.backgroundColor = [UIColor colorWithRGBHex:0xebe7e4];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:self.headerView.bounds];
    searchBar.delegate = self;
    searchBar.placeholder = @"Looking for something specific?";
    [self.headerView addSubview:searchBar];
}

- (void)setupFooter {
    [super setupFooter];
    self.footerView.backgroundColor = [UIColor colorWithRGBHex:0xebe7e4];
    
    UISlider *durationSlider = [[UISlider alloc] initWithFrame:CGRectInset(self.footerView.bounds, 15, 0)];
    durationSlider.minimumValue = 5.0;
    durationSlider.maximumValue = 20.0;
    durationSlider.value = self.lastDuration;
    [durationSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [durationSlider addTarget:self action:@selector(sliderDurationChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.durationSlider = durationSlider;
    
    [self.footerView addSubview:durationSlider];
}

- (void)sliderDurationChanged:(UISlider *)slider {
    if (self.durationDidChange) {
        self.durationDidChange = NO;
        [self reloadDataSource];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    // Round the slider values to integers
    CGFloat val = roundf(slider.value);
    
    // Snap the slider to the integer value
    slider.value = val;
    
    // If the value has actually changed, do something
    if (val != self.lastDuration) {
        self.durationDidChange = YES;
        self.lastDuration = val;
        NSLog(@"Slider Value: %f", val);
        self.durationLabel.text = [NSString stringWithFormat:@"%.0f", self.lastDuration];
    }
}

- (void)selectMode:(UIButton *)button {
    [UIActionSheet actionSheetWithTitle:@"Mode of Transit?" message:nil buttons:@[@"Walking", @"Driving", @"Bicyling"] showInView:self.view onDismiss:^(int buttonIndex, NSString *textInput) {
        switch (buttonIndex) {
            case 0:
                self.selectedMode = @"walking";
                break;
            case 1:
                self.selectedMode = @"driving";
                break;
            case 2:
                self.selectedMode = @"bicyling";
                break;
            default:
                return;
                break;
        }
        [self reloadDataSource];
    } onCancel:^{
    }];
}

#pragma mark - Data Source

- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
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
    
    [self loadVenues];
}

- (void)dataSourceDidLoadMore {
    [super dataSourceDidLoadMore];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    if (![[PSLocationCenter defaultCenter] hasAcquiredLocation]) {
        self.hasLoadedOnce = NO;
        return;
    } else {
        self.hasLoadedOnce = YES;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *ll = [NSString stringWithFormat:@"%g,%g", self.centerCoordinate.latitude, self.centerCoordinate.longitude];
    [parameters setObject:ll forKey:@"ll"];
    [parameters setObject:@"10" forKey:@"limit"];
    [parameters setObject:self.selectedMode forKey:@"mode"];
    [parameters setObject:[[NSNumber numberWithFloat:self.lastDuration] stringValue] forKey:@"duration"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/venues", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [[PSURLCache sharedCache] removeCacheForURL:cachedURL cacheType:PSURLCacheTypeSession];
            [self dataSourceDidError];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                // Suggested Radius

                // List of Venues
                [self.venues removeAllObjects];
                NSArray *venues = [apiResponse objectForKey:@"venues"];
                for (NSDictionary *venue in venues) {
                    [self.venues addObject:[NSMutableDictionary dictionaryWithDictionary:venue]];
                }
                
//                for (NSDictionary *venue in venues) {
//                    NSString *venueId = [venue objectForKey:@"id"];
//
//                    NSSet *o = [self.reusableVenues objectsPassingTest:^(NSDictionary *obj, BOOL *stop){
//                        NSString *existingId = [obj objectForKey:@"id"];
//                        return [venueId isEqualToString:existingId];
//                    }];
//                    
//                    if (o.count == 0) {
//                        [self.reusableVenues addObject:[NSMutableDictionary dictionaryWithDictionary:venue]];
//                    }
//                }
                
                [self dataSourceDidLoad];
                
            } else {
                [self dataSourceDidError];
            }
        }
    }];
}

/**
 This method drops the pins on the map based on criteria
 It takes into account duration threshold and search filter
 */
- (void)loadVenues {
    // Clear map
    [self.mapView removeAnnotations:self.venueAnnotations];
    [self.venueAnnotations removeAllObjects];
    
    NSString *origin = [NSString stringWithFormat:@"%g,%g", self.centerCoordinate.latitude, self.centerCoordinate.longitude];
    
    // Filter venues
    
//    for (NSMutableDictionary *venue in self.reusableVenues) {
//        NSDictionary *location = [venue objectForKey:@"location"];
//        CGFloat distance = [[location objectForKey:@"distance"] floatValue];
//        
//        // Calculate average travel speed and radius for search
//        // Walking = 3mi/hr or 0.05mi/min or 80m/min
//        // Driving = 30mi/hr or 0.5mi/min or 800m/min
//        // Bicycling = 12mi/hr or 0.2mi/min or 320m/min
//        
//        CGFloat radius = 0.0;
//        if ([self.selectedMode isEqualToString:@"walking"]) {
//            radius = 80 * self.lastDuration;
//        } else if ([self.selectedMode isEqualToString:@"bicycling"]) {
//            radius = 300 * self.lastDuration;
//        } else {
//            radius = 600 * self.lastDuration;
//        }
//        
//        if (distance <= radius) {
//            [self.venues addObject:venue];
//        }
//    }
    
    
    // Load venues that match current criteria
    for (NSMutableDictionary *venue in self.venues) {
        
        // If venue already has route, reuse it
        if ([venue objectForKey:@"route"]) {
            NSDictionary *route = [venue objectForKey:@"route"];
            NSNumber *durationNumber = [[[[route objectForKey:@"legs"] lastObject] objectForKey:@"duration"] objectForKey:@"value"];
            CGFloat duration = [durationNumber floatValue]; // in seconds
            CGFloat lastDuration = self.lastDuration * 60; // in seconds
            
            if (duration <= lastDuration) {
                [self.routeQueue addOperationWithBlock:^{
                    ASSERT_NOT_MAIN_THREAD;
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        ASSERT_MAIN_THREAD;
                        VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:venue];
                        [self.mapView addAnnotation:annotation];
                        [self.venueAnnotations addObject:annotation];
                    }];
                }];
            }
        } else {
            // Get route from google
            NSDictionary *location = [venue objectForKey:@"location"];
            CLLocationDegrees lat = [[location objectForKey:@"lat"] floatValue];
            CLLocationDegrees lng = [[location objectForKey:@"lng"] floatValue];
            NSString *destination = [NSString stringWithFormat:@"%f,%f", lat, lng];
            
            [self.routeQueue addOperationWithBlock:^{
                ASSERT_NOT_MAIN_THREAD;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:nil];
                
                NSURL *URL = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/directions/json"];
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:@"true" forKey:@"sensor"];
                [params setObject:@"false" forKey:@"alternatives"];
                [params setObject:origin forKey:@"origin"];
                [params setObject:destination forKey:@"destination"];
                [params setObject:self.selectedMode forKey:@"mode"];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:params];
                
                
                NSError *error = nil;
                NSHTTPURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                id apiResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    ASSERT_MAIN_THREAD;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:nil];
                    
                    if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                        NSString *status = [apiResponse objectForKey:@"status"];
                        if ([status isEqualToString:@"OK"]) {
                            NSDictionary *route = [[apiResponse objectForKey:@"routes"] firstObject];
                            [venue setObject:route forKey:@"route"];
                            
                            NSNumber *durationNumber = [[[[route objectForKey:@"legs"] lastObject] objectForKey:@"duration"] objectForKey:@"value"];
                            CGFloat duration = [durationNumber floatValue]; // in seconds
                            CGFloat lastDuration = self.lastDuration * 60; // in seconds
                            
                            if (duration <= lastDuration) {
                                VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:venue];
                                [self.mapView addAnnotation:annotation];
                                [self.venueAnnotations addObject:annotation];
                            }
                        }
                    }

                }];
            }];
        }
    }
    
    [self.routeQueue addOperationWithBlock:^{
        ASSERT_NOT_MAIN_THREAD;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            ASSERT_MAIN_THREAD;
            [self fitMapToPins];
        }];
    }];
    
//        NSDictionary *route = [[venue objectForKey:@"routes"] lastObject];
//        
//        // Get duration in seconds
//        NSNumber *durationNumber = [[[[route objectForKey:@"legs"] lastObject] objectForKey:@"duration"] objectForKey:@"value"];
//        CGFloat duration = [durationNumber floatValue]; // in seconds
//        CGFloat lastDuration = self.lastDuration * 60; // in seconds
//        if (duration > lastDuration) {
//            continue;
//        }
//        
//        // Apply a text match based on what is in the search bar
//        // Use NSPredicate
//        
//        VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:venue];
//        [self.mapView addAnnotation:annotation];
//        [self.venueAnnotations addObject:annotation];

    

    // If no results and only user location, zoom to fit
//    if (self.venueAnnotations.count > 0) {

//    } else {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate([[self.mapView.annotations firstObject] coordinate]);
//        annotati/onPoint = MKMap
//    }
}

- (void)fitMapToPins {
    // Fit map to pins
    MKMapPoint annotationPoint = MKMapPointForCoordinate(self.mapView.userLocation.coordinate);
    MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        pointRect = MKMapRectInset(pointRect, -1000, -1000); // outset the map a bit
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self loadVenues];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    NSString *reuseIdentifier = NSStringFromClass([VenueAnnotationView class]);
    VenueAnnotationView *v = (VenueAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (!v) {
        v = [[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        v.canShowCallout = YES;
        v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        v.animatesDrop = YES;
    }
    
    return v;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 2.0;
        polylineView.fillColor = [UIColor redColor];
        return polylineView;
    } else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    [self.mapView removeOverlays:[self.mapView overlays]];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }

    [self.mapView removeOverlays:[self.mapView overlays]];

    VenueAnnotation *venueAnnotation = view.annotation;
    
    NSDictionary *route = [venueAnnotation.venueDict objectForKey:@"route"];
    if (route) {
        MKPolyline *polyline = [MKPolyline polylineWithEncodedString:[[route objectForKey:@"overview_polyline"] objectForKey:@"points"]];
        [self.mapView addOverlay:polyline];
    }
}

@end
