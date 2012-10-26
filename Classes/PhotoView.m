//
//  PhotoView.m
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoView.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

@implementation PhotoView

@synthesize
imageView = _imageView,
nameLabel = _nameLabel,
homeCityLabel = _homeCityLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImage *shadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadowView.frame = CGRectInset(self.bounds, -1, -2);
        [self addSubview:shadowView];
        
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.shouldAnimate = NO;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.nameLabel = [UILabel labelWithStyle:@"titleDarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"subtitleDarkLabel"];
        self.homeCityLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.homeCityLabel];
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
    self.homeCityLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
//    CGFloat right = self.width - MARGIN;
    
    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"titleDarkLabel"];
    self.nameLabel.top = self.imageView.bottom + MARGIN;
    self.nameLabel.left = left;
    self.nameLabel.width = labelSize.width;
    self.nameLabel.height = labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:self.homeCityLabel.text width:width style:@"subtitleDarkLabel"];
    self.homeCityLabel.top = self.nameLabel.bottom;
    self.homeCityLabel.left = left;
    self.homeCityLabel.width = labelSize.width;
    self.homeCityLabel.height = labelSize.height;
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView loadImageWithURL:[NSURL URLWithString:[self.object objectForKey:@"source"]] cacheType:PSURLCacheTypePermanent];
    
    self.nameLabel.text = [self.object objectForKey:@"name"];
    self.homeCityLabel.text = [self.object objectForKey:@"homeCity"];
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    CGSize labelSize = CGSizeZero;
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"name"] width:width style:@"titleDarkLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"homeCity"] width:width style:@"subtitleDarkLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
