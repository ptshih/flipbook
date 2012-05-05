//
//  VenueListViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"
#import "PSPopoverView.h"

@interface VenueListViewController : PSCollectionViewController <PSPopoverViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL shouldRefreshOnAppear;

- (id)initWithCategory:(NSString *)category;

@end
