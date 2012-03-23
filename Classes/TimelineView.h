//
//  TimelineView.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class PSCachedImageView;

@interface TimelineView : PSCollectionViewCell

@property (nonatomic, retain) PSCachedImageView *imageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *addressLabel;
@property (nonatomic, retain) UILabel *categoryLabel;
@property (nonatomic, retain) UILabel *distanceLabel;

@end
