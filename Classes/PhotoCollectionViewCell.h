//
//  PhotoCollectionViewCell.h
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class PSCachedImageView;

@interface PhotoCollectionViewCell : PSCollectionViewCell

@property (nonatomic, strong, readonly) PSCachedImageView *imageView;

@end