//
//  VenuesViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"
#import "PSPopoverView.h"

@interface VenuesViewController : PSCollectionViewController

- (id)initWithCategory:(NSString *)category query:(NSString *)query title:(NSString *)title;

@end
