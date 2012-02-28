//
//  LocationChooserView.m
//  Mealtime
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
        [self.mapView setRegion:mapRegion animated:NO];
        [self addSubview:self.mapView];
    }
    return self;
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
    [super dealloc];
}

@end
