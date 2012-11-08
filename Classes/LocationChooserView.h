//
//  LocationChooserView.h
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSView.h"

@interface LocationChooserView : PSView <MKMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, strong) PSTextField *queryField;
@property (nonatomic, assign) BOOL locationDidChange;

- (id)initWithFrame:(CGRect)frame mapRegion:(MKCoordinateRegion)mapRegion;

@end
