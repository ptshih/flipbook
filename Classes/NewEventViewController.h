//
//  NewEventViewController.h
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"

#define kNewEventCreatedNotification @"NewEventCreatedNotification"

@interface NewEventViewController : PSViewController

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
