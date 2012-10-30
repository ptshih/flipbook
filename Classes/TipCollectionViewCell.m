//
//  TipCollectionViewCell.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipCollectionViewCell.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

@interface TipCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *homeCityLabel;
@property (nonatomic, strong) UIImageView *divider;

@end

@implementation TipCollectionViewCell

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
        
        self.tipLabel = [UILabel labelWithStyle:@"h6GeorgiaDarkLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.tipLabel];
        
        self.nameLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
        self.homeCityLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.homeCityLabel];
        
        self.divider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        [self addSubview:self.divider];
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.tipLabel.text = nil;
    self.nameLabel.text = nil;
    self.homeCityLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
    
    CGSize labelSize = CGSizeZero;
    
    labelSize = [self.tipLabel sizeForLabelInWidth:width];
    self.tipLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.tipLabel.bottom + MARGIN;
    self.divider.frame = CGRectMake(left, top, width, 1.0);
    top = self.divider.bottom + MARGIN;
    
    self.imageView.frame = CGRectMake(left, top, 30, 30);
    
    left += self.imageView.width + MARGIN;
    width -= self.imageView.width + MARGIN;
    
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.nameLabel.bottom;
    
    labelSize = [self.homeCityLabel sizeForLabelInWidth:width];
    self.homeCityLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    
    self.tipLabel.text = [object objectForKey:@"text"];
    self.nameLabel.text = [object objectForKey:@"userName"];
    self.homeCityLabel.text = [object objectForKey:@"userHomeCity"];
    
    [self.imageView loadImageWithURL:[NSURL URLWithString:[object objectForKey:@"userPhoto"]] cacheType:PSURLCacheTypePermanent];
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    CGSize labelSize = CGSizeZero;
    
    height += MARGIN;
    
    NSString *tipText = [NSString stringWithFormat:@"%@", [object objectForKey:@"text"]];
    labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"h6GeorgiaDarkLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    height += 1.0;
    height += MARGIN;
    
    width -= 30 + MARGIN;
    
    CGFloat footerHeight = 0.0;
    
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"userName"] width:width style:@"h6DarkLabel"];
    footerHeight += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"userHomeCity"] width:width style:@"h6DarkLabel"];
    footerHeight += labelSize.height;
    
    height += MAX(footerHeight, 30.0);
    
    height += MARGIN;
    
    return height;
}

@end
