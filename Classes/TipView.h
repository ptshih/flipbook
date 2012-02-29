//
//  TipView.h
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@class PSCachedImageView;

@interface TipView : PSView

@property (nonatomic, retain) id object;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UILabel *tipLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *homeCityLabel;
@property (nonatomic, retain) UIImageView *divider;

- (void)prepareForReuse;
- (void)fillViewWithObject:(id)object;
+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth;

@end
