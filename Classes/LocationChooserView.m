//
//  LocationChooserView.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationChooserView.h"

@implementation LocationChooserView

@synthesize
mapView = _mapView;

- (id)initWithFrame:(CGRect)frame mapRegion:(MKCoordinateRegion)mapRegion {
    self = [super initWithFrame:frame];
    if (self) {
        self.mapView = [[[MKMapView alloc] initWithFrame:self.bounds] autorelease];
        self.mapView.delegate = self;
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.showsUserLocation = YES;
        [self.mapView setRegion:mapRegion animated:NO];
        [self addSubview:self.mapView];
        
        // Current Location
        UIButton *currentLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        currentLocationButton.frame = CGRectMake(self.mapView.width - 36 - 8, 8, 36, 36);
        [currentLocationButton setImage:[UIImage imageNamed:@"IconLocationArrowMini"] forState:UIControlStateNormal];
        currentLocationButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        currentLocationButton.layer.cornerRadius = 4.0;
        currentLocationButton.layer.masksToBounds = YES;
        currentLocationButton.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        currentLocationButton.layer.borderWidth = 1.0;
        [currentLocationButton addTarget:self action:@selector(centerCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:currentLocationButton];
    }
    return self;
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
    [super dealloc];
}

- (void)centerCurrentLocation {
    CLLocationCoordinate2D coord;
    if (self.mapView.userLocation) {
        coord = self.mapView.userLocation.location.coordinate;
    } else {
        coord = [[PSLocationCenter defaultCenter] locationCoordinate];
    }
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
    [self.mapView setRegion:mapRegion animated:YES];
}

@end
