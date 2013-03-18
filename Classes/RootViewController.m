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

@interface RootViewController () <MKMapViewDelegate>

@property (nonatomic, strong) UIView *durationView;
@property (nonatomic, strong) UISlider *durationSlider;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *venueAnnotations;

@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) BOOL hasLoadedOnce;

@end

@implementation RootViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Check";
        
        self.shouldShowHeader = NO;
        self.shouldShowFooter = YES;
        self.shouldShowNullView = NO;
        
        self.headerHeight = 0.0;
        self.footerHeight = 49.0;
        
        self.hasLoadedOnce = NO;
        self.centerCoordinate = CLLocationCoordinate2DMake([[PSLocationCenter defaultCenter] lat], [[PSLocationCenter defaultCenter] lng]);
        
        self.venueAnnotations = [NSMutableArray array];
        
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
    
    UIView *durationView = [[UIView alloc] initWithFrame:CGRectMake(10, self.contentView.height - 56 - 15, 56, 56)];
    durationView.backgroundColor = [UIColor grayColor];
    self.durationView = durationView;
    [self.contentView addSubview:durationView];
    
    [durationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadData)]];
}

- (void)setupFooter {
    [super setupFooter];
    self.footerView.backgroundColor = [UIColor colorWithRGBHex:0xebe7e4];
    
    UISlider *durationSlider = [[UISlider alloc] initWithFrame:CGRectInset(self.footerView.bounds, 15, 0)];
    durationSlider.minimumValue = 5.0;
    durationSlider.maximumValue = 20.0;
    [durationSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.durationSlider = durationSlider;
    
    [self.footerView addSubview:durationSlider];
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSLog(@"Slider Value: %f", slider.value);
}

- (void)reloadData {
    [self reloadDataSource];
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
                NSArray *venues = [apiResponse objectForKey:@"venues"];
                
                [self.mapView removeAnnotations:self.venueAnnotations];
                [self.venueAnnotations removeAllObjects];
                for (NSDictionary *venue in venues) {
                    VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:venue];
                    [self.mapView addAnnotation:annotation];
                    [self.venueAnnotations addObject:annotation];
                }
                [self dataSourceDidLoad];
                
            } else {
                [self dataSourceDidError];
            }
        }
    }];
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
    
    NSDictionary *route = [[venueAnnotation.venueDict objectForKey:@"routes"] lastObject];
    MKPolyline *polyline = [MKPolyline polylineWithEncodedString:[[route objectForKey:@"overview_polyline"] objectForKey:@"points"]];
    [self.mapView addOverlay:polyline];
}

@end
