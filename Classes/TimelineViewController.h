//
//  TimelineViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSCollectionView.h"
#import "PSPullRefreshView.h"

@interface TimelineViewController : PSBaseViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, PSPullRefreshViewDelegate, UIScrollViewDelegate>

@property (nonatomic, copy) NSString *timelineId;
@property (nonatomic, copy) NSDate *fromDate;
@property (nonatomic, copy) NSDate *toDate;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) PSCollectionView *collectionView;
@property (nonatomic, retain) PSPullRefreshView *pullRefreshView;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;
@property (nonatomic, assign) BOOL shouldRefreshOnAppear;

- (id)initWithTimelineId:(NSString *)timelineId;


@end
