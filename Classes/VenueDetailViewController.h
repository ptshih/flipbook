//
//  VenueDetailViewController.h
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"

@interface VenueDetailViewController : PSCollectionViewController <MKMapViewDelegate, UIAlertViewDelegate>

- (id)initWithVenueId:(NSString *)venueId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary event:(NSDictionary *)event;

@end
