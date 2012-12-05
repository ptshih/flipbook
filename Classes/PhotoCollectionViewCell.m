//
//  PhotoCollectionViewCell.m
//  Mosaic
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}


@interface PhotoCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation PhotoCollectionViewCell

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
        
        self.dateLabel = [UILabel labelWithStyle:@"georgiaDarkLabel"];
        self.dateLabel.textAlignment = UITextAlignmentCenter;
        self.dateLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.dateLabel];
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.dateLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - margin().width * 2;
    CGFloat top = margin().height;
    CGFloat left = margin().width;
    
    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top += self.imageView.height + margin().height;
    
    CGSize labelSize = CGSizeZero;
    
    // Date
    labelSize = [self.dateLabel sizeForLabelInWidth:width];
    self.dateLabel.frame = CGRectMake(left, top, width, labelSize.height);
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"href"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"thumb"]]];
    [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"created"] doubleValue]];
    NSString *dateText = [NSDate stringFromDate:date withFormat:@"MMMM d, yyyy"];
    self.dateLabel.text = dateText;
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - margin().width * 2;
    
    height += margin().height;
    
    CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += margin().height;
    
    CGSize labelSize = CGSizeZero;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"created"] doubleValue]];
    NSString *dateText = [NSDate stringFromDate:date withFormat:@"MMM d, yyyy"];
    labelSize = [PSStyleSheet sizeForText:dateText width:width style:@"georgiaDarkLabel"];
    height += labelSize.height;
    
    height += margin().height;
    
    return height;
}

@end
