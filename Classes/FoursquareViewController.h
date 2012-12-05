//
//  FoursquareViewController.h
//  Mosaic
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSCollectionViewController.h"

@interface FoursquareViewController : PSCollectionViewController

- (id)initWithCategory:(NSString *)category query:(NSString *)query title:(NSString *)title;

@end
