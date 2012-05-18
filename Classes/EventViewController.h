//
//  EventViewController.h
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSTableViewController.h"

@interface EventViewController : PSTableViewController

- (id)initWithVenueDict:(NSDictionary *)venueDict eventDict:(NSDictionary *)eventDict;

@end
