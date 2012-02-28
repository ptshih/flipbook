//
//  TimelineViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"
#import "PSPopoverView.h"

@interface TimelineViewController : PSCollectionViewController <PSPopoverViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;
@property (nonatomic, assign) BOOL shouldRefreshOnAppear;
@property (nonatomic, assign) NSInteger categoryIndex;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, assign) CGFloat radius;


@end
