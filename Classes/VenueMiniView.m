//
//  VenueMiniView.m
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueMiniView.h"

#import "VenueAnnotation.h"
#import "VenueAnnotationView.h"

#define MARGIN 8.0

@interface VenueMiniView () <MKMapViewDelegate>

@property (nonatomic, copy) NSDictionary *venueDict;

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation VenueMiniView

@synthesize
venueDict = _venueDict;

@synthesize
mapView = _mapView;

- (id)initWithDictionary:(NSDictionary *)dictionary frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.venueDict = dictionary;
        
        CGFloat height = frame.size.height;
        
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, height - MARGIN * 2, height - MARGIN * 2)];
        self.mapView.delegate = self;
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.mapView.zoomEnabled = NO;
        self.mapView.scrollEnabled = NO;
        self.mapView.layer.cornerRadius = 4.0;
        self.mapView.layer.masksToBounds = YES;
        self.mapView.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        self.mapView.layer.borderWidth = 1.0;
        self.mapView.layer.shouldRasterize = YES;
        self.mapView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self addSubview:self.mapView];
        
        NSDictionary *location = [self.venueDict objectForKey:@"location"];
        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]), 200, 200);
        [self.mapView setRegion:mapRegion animated:NO];
        [self.mapView removeAnnotations:[self.mapView annotations]];
        VenueAnnotation *annotation = [VenueAnnotation venueAnnotationWithDictionary:self.venueDict];
        [self.mapView addAnnotation:annotation];
        
        CGFloat labelWidth = self.width - self.mapView.width - MARGIN * 3;
        
        // Map Labels
        UILabel *nameLabel = [UILabel labelWithText:[self.venueDict objectForKey:@"name"] style:@"h2Label"];
        nameLabel.frame = CGRectMake(self.mapView.right + MARGIN, MARGIN + 2.0, labelWidth, 20.0);
        [self addSubview:nameLabel];
        
        NSString *formattedAddress = [NSString stringWithFormat:@"%@ %@, %@", [location objectForKey:@"address"], [location objectForKey:@"city"], [location objectForKey:@"state"]];
        UILabel *addressLabel = [UILabel labelWithText:formattedAddress style:@"subtitleLabel"];
        addressLabel.frame = CGRectMake(self.mapView.right + MARGIN, nameLabel.bottom + 2.0, labelWidth, 16.0);
        [self addSubview:addressLabel];
        
        NSString *primaryCategory = [[[self.venueDict objectForKey:@"categories"] objectAtIndexOrNil:0] objectForKey:@"shortName"];
        UILabel *categoryLabel = [UILabel labelWithText:primaryCategory style:@"metaLabel"];
        categoryLabel.frame = CGRectMake(self.mapView.right + MARGIN, addressLabel.bottom + 2.0, labelWidth, 16.0);
        [self addSubview:categoryLabel];
    }
    return self;
}

- (void)dealloc {
    self.mapView.delegate = nil;
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
