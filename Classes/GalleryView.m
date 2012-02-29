//
//  GalleryView.m
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryView.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

@implementation GalleryView

@synthesize
object = _object,
backgroundView = _backgroundView,
imageView = _imageView,
nameLabel = _nameLabel,
homeCityLabel = _homeCityLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.backgroundView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        self.backgroundView.layer.shadowOpacity = 0.7;
        self.backgroundView.layer.shadowRadius = 3.0;
        self.backgroundView.layer.masksToBounds = NO;
        self.backgroundView.layer.shouldRasterize = YES;
        [self addSubview:self.backgroundView];
        
        self.imageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.nameLabel = [UILabel labelWithStyle:@"titleLabel"];
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        [self addSubview:self.homeCityLabel];
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    self.imageView = nil;
    self.backgroundView = nil;
    
    self.nameLabel = nil;
    self.homeCityLabel = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
    self.homeCityLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.backgroundView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.backgroundView.bounds] CGPath];
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
//    CGFloat right = self.width - MARGIN;
    
    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"titleLabel"];
    self.nameLabel.top = self.imageView.bottom + MARGIN;
    self.nameLabel.left = left;
    self.nameLabel.width = labelSize.width;
    self.nameLabel.height = labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:self.homeCityLabel.text width:width style:@"subtitleLabel"];
    self.homeCityLabel.top = self.nameLabel.bottom;
    self.homeCityLabel.left = left;
    self.homeCityLabel.width = labelSize.width;
    self.homeCityLabel.height = labelSize.height;
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView loadImageWithURL:[NSURL URLWithString:[self.object objectForKey:@"source"]] cacheType:PSURLCacheTypePermanent];
    
    self.nameLabel.text = [self.object objectForKey:@"name"];
    self.homeCityLabel.text = [self.object objectForKey:@"homeCity"];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    CGSize labelSize = CGSizeZero;
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"name"] width:width style:@"titleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"homeCity"] width:width style:@"subtitleLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
