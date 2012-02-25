//
//  TimelineView.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineView.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

@implementation TimelineView

@synthesize
object = _object,
backgroundView = _backgroundView,
imageView = _imageView,
nameLabel = _nameLabel;

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
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.nameLabel = [UILabel labelWithStyle:@"timelineNameLabel"];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    self.imageView = nil;
    self.backgroundView = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.backgroundView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.backgroundView.bounds] CGPath];
    
    CGFloat width = self.width - MARGIN * 2;
    
    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(MARGIN, MARGIN, width, scaledHeight);
    
    CGSize labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"timelineNameLabel"];
    self.nameLabel.top = self.imageView.bottom + MARGIN;
    self.nameLabel.left = MARGIN;
    self.nameLabel.width = labelSize.width;
    self.nameLabel.height = labelSize.height;
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView loadImageWithURL:[NSURL URLWithString:[self.object objectForKey:@"source"]] cacheType:PSURLCacheTypePermanent];
    
    self.nameLabel.text = [self.object objectForKey:@"name"];
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
    
    CGSize labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"name"] width:width style:@"timelineNameLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
