//
//  VenueCollectionViewCell.m
//  Lunchbox
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueCollectionViewCell.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

static NSNumberFormatter *__numberFormatter = nil;

@interface VenueCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UIImageView *topDivider;
@property (nonatomic, strong) UIImageView *divider;
@property (nonatomic, strong) UIImageView *peopleIcon;

@end

@implementation VenueCollectionViewCell

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
        
        self.nameLabel = [UILabel labelWithStyle:@"titleDarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.addressLabel = [UILabel labelWithStyle:@"subtitleDarkLabel"];
        self.addressLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.addressLabel];
        
        self.categoryLabel = [UILabel labelWithStyle:@"metaDarkLabel"];
        self.categoryLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.categoryLabel];
        
        self.distanceLabel = [UILabel labelWithStyle:@"metaDarkLabel"];
        self.distanceLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.distanceLabel];
        
        self.statsLabel = [UILabel labelWithStyle:@"metaDarkLabel"];
        self.statsLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.statsLabel];
        
        self.tipLabel = [UILabel labelWithStyle:@"georgiaDarkLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        self.tipLabel.hidden = YES;
        [self addSubview:self.tipLabel];
        
        // Must set to 0 lines and word wrap line break mode
//        self.tipLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
//        self.tipLabel.backgroundColor = self.backgroundColor;
//        self.tipLabel.userInteractionEnabled = NO;
//        [PSStyleSheet applyStyle:@"textDarkLabel" forLabel:self.tipLabel];
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
    
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.nameLabel.bottom + MARGIN;
    
    NSDictionary *photo = [self.object objectForKey:@"photo"];
    CGFloat photoWidth, photoHeight;
    if (photo) {
        photoWidth = [[photo objectForKey:@"width"] floatValue];
        photoHeight = [[photo objectForKey:@"height"] floatValue];
    } else {
        photoWidth = photoHeight = 256.0;
    }
    
    CGFloat objectWidth = photoWidth;
    CGFloat objectHeight = photoHeight;
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top = self.imageView.bottom + MARGIN;
    
    self.peopleIcon.frame = CGRectMake(left, top + 2, 10, 10);
    
    labelSize = [self.statsLabel sizeForLabelInWidth:width];
    self.statsLabel.frame = CGRectMake(left + 12, top, labelSize.width, labelSize.height);
    
    top = self.statsLabel.bottom;
    
    top += MARGIN;
    self.topDivider.hidden = NO;
    self.topDivider.frame = CGRectMake(left, top, width, 1.0);
    top = self.topDivider.bottom + MARGIN;
    
    if ([self.tipLabel.text length] > 0) {
        labelSize = [self.tipLabel sizeForLabelInWidth:width];
        self.tipLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
        self.tipLabel.hidden = NO;
        
        top = self.tipLabel.bottom;
        top += MARGIN;
        self.divider.hidden = NO;
        self.divider.frame = CGRectMake(left, top, width, 1.0);
        top = self.divider.bottom + MARGIN;
    }
    
    labelSize = [self.addressLabel sizeForLabelInWidth:width];
    self.addressLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.addressLabel.bottom;
    
    labelSize = [self.distanceLabel sizeForLabelInWidth:width];
    self.distanceLabel.frame = CGRectMake(right - labelSize.width, top, labelSize.width, labelSize.height);
    
    labelSize = [self.categoryLabel sizeForLabelInWidth:(width - self.distanceLabel.width - MARGIN)];
    
    self.categoryLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    NSDictionary *venue = (NSDictionary *)object;
    
    // Photo
    NSDictionary *photo = [venue objectForKey:@"photo"];
    if (photo) {
        // Use venue photo
        NSString *href = [photo objectForKey:@"href"];
        [self.imageView setOriginalURL:[NSURL URLWithString:href]];
        [self.imageView setThumbnailURL:[NSURL URLWithString:href]];
        [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    } else {
        // Use category icon
        NSString *href = [venue objectForKey:@"categoryIcon"];
        [self.imageView setOriginalURL:[NSURL URLWithString:href]];
        [self.imageView setThumbnailURL:[NSURL URLWithString:href]];
        [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    }
    
    // Labels
    self.nameLabel.text = [venue objectForKey:@"name"];
    self.categoryLabel.text = [venue objectForKey:@"category"];
    
    NSDictionary *location = [venue objectForKey:@"location"];
    if (location) {
        self.addressLabel.text = [NSString stringWithFormat:@"%@ (%@)", [location objectForKey:@"address"], [location objectForKey:@"crossStreet"]];
        self.distanceLabel.text = [NSString localizedStringForDistance:[[location objectForKey:@"distance"] floatValue]];
    }
    
    NSDictionary *stats = [venue objectForKey:@"stats"];
    if (stats) {
        self.statsLabel.text = [NSString stringWithFormat:@"%@ people checked in", [__numberFormatter stringFromNumber:[stats objectForKey:@"checkinsCount"] ]];
    }
    
    NSString *tip = [venue objectForKey:@"tip"];
    if (tip) {
        self.tipLabel.text = tip;
    }
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    NSDictionary *venue = (NSDictionary *)object;
    
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    // Photo
    NSDictionary *photo = [object objectForKey:@"photo"];
    CGFloat photoWidth, photoHeight;
    if (photo) {
        photoWidth = [[photo objectForKey:@"width"] floatValue];
        photoHeight = [[photo objectForKey:@"height"] floatValue];
    } else {
        photoWidth = photoHeight = 256.0;
    }
    
    CGFloat objectWidth = photoWidth;
    CGFloat objectHeight = photoHeight;
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    
    // Labels
    CGSize labelSize = CGSizeZero;
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"name"] width:width style:@"titleDarkLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"category"] width:width style:@"metaDarkLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    NSDictionary *location = [venue objectForKey:@"location"];
    if (location) {
        NSString *locationText = [NSString stringWithFormat:@"%@ (%@)", [location objectForKey:@"address"], [location objectForKey:@"crossStreet"]];
        labelSize = [PSStyleSheet sizeForText:locationText width:width style:@"subtitleDarkLabel"];
        height += labelSize.height;
        
        height += MARGIN;
        height += 1.0;
        height += MARGIN;
    }
    
    NSDictionary *stats = [venue objectForKey:@"stats"];
    if (stats) {
        NSString *statsText = [NSString stringWithFormat:@"%@ people checked in", [__numberFormatter stringFromNumber:[stats objectForKey:@"checkinsCount"] ]];
        labelSize = [PSStyleSheet sizeForText:statsText width:width style:@"metaDarkLabel"];
        height += labelSize.height;
    }
    
    NSString *tip = [venue objectForKey:@"tip"];
    if (tip) {
        NSString *tipText = tip;
        labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"georgiaDarkLabel"];
        height += labelSize.height;
        
        height += MARGIN;
        height += 1.0;
        height += MARGIN;
    }
    
    
    height += MARGIN;
    
    return height;
}

@end
