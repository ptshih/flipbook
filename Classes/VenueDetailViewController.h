//
//  VenueDetailViewController.h
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"

@interface VenueDetailViewController : PSCollectionViewController <MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;
@property (nonatomic, retain) MKMapView *mapView;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
