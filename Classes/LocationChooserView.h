//
//  LocationChooserView.h
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface LocationChooserView : PSView <MKMapViewDelegate>

@property (nonatomic, retain) MKMapView *mapView;

- (id)initWithFrame:(CGRect)frame mapRegion:(MKCoordinateRegion)mapRegion;

@end
