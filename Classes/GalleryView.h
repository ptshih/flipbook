//
//  GalleryView.h
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class PSCachedImageView;

@interface GalleryView : PSCollectionViewCell

@property (nonatomic, retain) PSCachedImageView *imageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *homeCityLabel;

@end
