//
//  VenueView.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueView.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

static NSNumberFormatter *__numberFormatter = nil;

@interface VenueView ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *tipUserLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UIImageView *topDivider;
@property (nonatomic, strong) UIImageView *divider;
@property (nonatomic, strong) UIImageView *peopleIcon;

@end

@implementation VenueView

@synthesize
imageView = _imageView,
nameLabel = _nameLabel,
addressLabel = _addressLabel,
categoryLabel = _categoryLabel,
distanceLabel = _distanceLabel,
tipUserLabel = _tipUserLabel,
tipLabel = _tipLabel,
statsLabel = _statsLabel,
topDivider = _topDivider,
divider = _divider,
peopleIcon = _peopleIcon;

+ (void)initialize {
    __numberFormatter = [[NSNumberFormatter alloc] init];
    [__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

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
        
        self.nameLabel = [UILabel labelWithStyle:@"titleLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.addressLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        self.addressLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.addressLabel];
        
        self.categoryLabel = [UILabel labelWithStyle:@"metaLabel"];
        self.categoryLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.categoryLabel];
        
        self.distanceLabel = [UILabel labelWithStyle:@"metaLabel"];
        self.distanceLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.distanceLabel];
        
        self.statsLabel = [UILabel labelWithStyle:@"metaDarkLabel"];
        self.statsLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.statsLabel];
        
        self.tipUserLabel = [UILabel labelWithStyle:@"boldLabel"];
        self.tipUserLabel.backgroundColor = self.backgroundColor;
        self.tipUserLabel.hidden = YES;
        [self addSubview:self.tipUserLabel];
        
        self.tipLabel = [UILabel labelWithStyle:@"textLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        self.tipLabel.hidden = YES;
        [self addSubview:self.tipLabel];
        
        // Must set to 0 lines and word wrap line break mode
//        self.tipLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
//        self.tipLabel.backgroundColor = self.backgroundColor;
//        self.tipLabel.userInteractionEnabled = NO;
//        [PSStyleSheet applyStyle:@"textLabel" forLabel:self.tipLabel];
//        [self addSubview:self.tipLabel];
        
        self.topDivider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        self.topDivider.hidden = YES;
        [self addSubview:self.topDivider];
        
        self.divider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        self.divider.hidden = YES;
        [self addSubview:self.divider];
        
        self.peopleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPersonMiniBlack"]];
        self.peopleIcon.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.peopleIcon];
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
    self.addressLabel.text = nil;
    self.categoryLabel.text = nil;
    self.distanceLabel.text = nil;
    self.tipUserLabel.text = nil;;
    self.tipUserLabel.hidden = YES;
    self.tipLabel.text = nil;
    self.tipLabel.hidden = YES;
    self.statsLabel.text = nil;
    self.topDivider.hidden = YES;
    self.divider.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
    CGFloat right = self.width - MARGIN;
    
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"titleLabel"];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.nameLabel.bottom + MARGIN;
    
    CGFloat objectWidth = [[self.object objectForKey:@"photoWidth"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"photoHeight"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top = self.imageView.bottom + MARGIN;
    
    self.peopleIcon.frame = CGRectMake(left, top + 2, 10, 10);
    
    labelSize = [PSStyleSheet sizeForText:self.statsLabel.text width:(width - 12) style:@"metaDarkLabel"];
    self.statsLabel.frame = CGRectMake(left + 12, top, labelSize.width, labelSize.height);
    
    top = self.statsLabel.bottom;
    
    top += MARGIN;
    self.topDivider.hidden = NO;
    self.topDivider.frame = CGRectMake(left, top, width, 1.0);
    top = self.topDivider.bottom + MARGIN;
    
    if ([self.tipLabel.text length] > 0) {
        labelSize = [PSStyleSheet sizeForText:self.tipUserLabel.text width:width style:@"boldLabel"];
        self.tipUserLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
        self.tipUserLabel.hidden = NO;
        
        top = self.tipUserLabel.bottom;
        
        labelSize = [PSStyleSheet sizeForText:self.tipLabel.text width:width style:@"textLabel"];
        self.tipLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
        self.tipLabel.hidden = NO;
        
        top = self.tipLabel.bottom;
        top += MARGIN;
        self.divider.hidden = NO;
        self.divider.frame = CGRectMake(left, top, width, 1.0);
        top = self.divider.bottom + MARGIN;
    }
    
    labelSize = [PSStyleSheet sizeForText:self.addressLabel.text width:width style:@"subtitleLabel"];
    self.addressLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.addressLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.distanceLabel.text width:width style:@"metaLabel"];
    self.distanceLabel.frame = CGRectMake(right - labelSize.width, top, labelSize.width, labelSize.height);
    
    
    labelSize = [PSStyleSheet sizeForText:self.categoryLabel.text width:(width - self.distanceLabel.width - MARGIN) style:@"metaLabel"];
    self.categoryLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    NSDictionary *venue = (NSDictionary *)object;
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[venue objectForKey:@"photoURLPath"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[venue objectForKey:@"photoURLPath"]]];
    [self.imageView loadImageWithURL:[NSURL URLWithString:[venue objectForKey:@"photoURLPath"]] cacheType:PSURLCacheTypePermanent];
    
    
    self.nameLabel.text = [venue objectForKey:@"name"];
    self.categoryLabel.text = [venue objectForKey:@"primaryCategory"];
    
    if ([venue objectForKey:@"location"] && [[venue objectForKey:@"location"] objectForKey:@"address"]) {
        self.addressLabel.text = [[venue objectForKey:@"location"] objectForKey:@"address"];
    }
    if ([venue objectForKey:@"location"] && [[venue objectForKey:@"location"] objectForKey:@"distance"]) {
        self.distanceLabel.text = [NSString localizedStringForDistance:[[[venue objectForKey:@"location"] objectForKey:@"distance"] floatValue]];
    }

    if ([venue objectForKey:@"stats"] && [[venue objectForKey:@"stats"] objectForKey:@"checkinsCount"]) {
        self.statsLabel.text = [NSString stringWithFormat:@"%@ people checked in", [__numberFormatter stringFromNumber:[[venue objectForKey:@"stats"] objectForKey:@"checkinsCount"] ]];
    }
    
    if ([venue objectForKey:@"tipUserName"] && [venue objectForKey:@"tipText"]) {
        self.tipUserLabel.text = [venue objectForKey:@"tipUserName"];
        self.tipLabel.text = [venue objectForKey:@"tipText"];
    }
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    NSDictionary *venue = (NSDictionary *)object;
    
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    CGFloat objectWidth = [[venue objectForKey:@"photoWidth"] floatValue];
    CGFloat objectHeight = [[venue objectForKey:@"photoHeight"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    CGSize labelSize = CGSizeZero;
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"name"] width:width style:@"titleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"primaryCategory"] width:width style:@"metaLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    if ([venue objectForKey:@"stats"] && [[venue objectForKey:@"stats"] objectForKey:@"checkinsCount"]) {
        labelSize = [PSStyleSheet sizeForText:[NSString stringWithFormat:@"%@ people checked in", [__numberFormatter stringFromNumber:[[venue objectForKey:@"stats"] objectForKey:@"checkinsCount"]]] width:width style:@"metaDarkLabel"];
        height += labelSize.height;
    }
    
    height += MARGIN;
    height += 1.0;
    height += MARGIN;
    
    if ([venue objectForKey:@"tipUserName"] && [venue objectForKey:@"tipText"]) {
        labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"tipUserName"] width:width style:@"boldLabel"];
        height += labelSize.height;
        
        labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"tipText"] width:width style:@"textLabel"];
        height += labelSize.height;
        
        height += MARGIN;
        height += 1.0;
        height += MARGIN;
    }
    
    if ([venue objectForKey:@"location"] && [[venue objectForKey:@"location"] objectForKey:@"address"]) {
        labelSize = [PSStyleSheet sizeForText:[[venue objectForKey:@"location"] objectForKey:@"address"] width:width style:@"subtitleLabel"];
        height += labelSize.height;
    }

    height += MARGIN;
    
    return height;
}

@end
