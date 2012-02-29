//
//  GalleryView.h
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@class PSCachedImageView;

@interface GalleryView : PSView

@property (nonatomic, retain) id object;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) PSCachedImageView *imageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *homeCityLabel;

- (void)prepareForReuse;
- (void)fillViewWithObject:(id)object;
+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth;

@end
