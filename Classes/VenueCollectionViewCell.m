//
//  VenueCollectionViewCell.m
//  Lunchbox
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueCollectionViewCell.h"

#define MARGIN 4.0

@interface VenueCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *ratingsLabel;
@property (nonatomic, strong) UIImageView *topDivider;
@property (nonatomic, strong) UIImageView *divider;

@end

@implementation VenueCollectionViewCell

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
        
        self.nameLabel = [UILabel labelWithStyle:@"h5CondDarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.addressLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
        self.addressLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.addressLabel];
        
        self.categoryLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
        self.categoryLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.categoryLabel];
        
        self.ratingsLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
        self.ratingsLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.ratingsLabel];
        
        self.tipLabel = [UILabel labelWithStyle:@"h6GeorgiaDarkLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        self.tipLabel.hidden = YES;
        [self addSubview:self.tipLabel];
        
        self.topDivider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        self.topDivider.hidden = YES;
        [self addSubview:self.topDivider];
        
        self.divider = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]];
        self.divider.hidden = YES;
        [self addSubview:self.divider];
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
    self.addressLabel.text = nil;
    self.categoryLabel.text = nil;
    self.tipLabel.text = nil;
    self.tipLabel.hidden = YES;
    self.ratingsLabel.text = nil;
    self.topDivider.hidden = YES;
    self.divider.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
//    CGFloat right = self.width - MARGIN;
    
    CGSize labelSize = CGSizeZero;
    
    // Name
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.nameLabel.bottom + MARGIN;
    
    // Photo
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
    
    // Ratings
    labelSize = [self.ratingsLabel sizeForLabelInWidth:width];
    self.ratingsLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.ratingsLabel.bottom;
    
    // Category
    labelSize = [self.categoryLabel sizeForLabelInWidth:width];
    self.categoryLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.categoryLabel.bottom;
    
    // Tip
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
    
    // Address
    labelSize = [self.addressLabel sizeForLabelInWidth:width];
    self.addressLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.addressLabel.bottom;
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
    
    NSString *categoryText = [NSString stringWithFormat:@"❖ %@", [venue objectForKey:@"category"]];
    self.categoryLabel.text = categoryText;
    
    // Rating
    CGFloat rating = [[venue objectForKey:@"rating"] floatValue];
    NSInteger ratingSignals = [[venue objectForKey:@"ratingSignals"] integerValue];
    NSString *ratingText = [NSString stringWithFormat:@"★ %.1f out of %d ratings", rating, ratingSignals];
    self.ratingsLabel.text = ratingText;
    
    // Tip
    NSString *tip = [venue objectForKey:@"tip"];
    if (tip) {
        NSString *tipText = [NSString stringWithFormat:@"%@", tip];
        self.tipLabel.text = tipText;
    }
    
    // Address
    NSDictionary *location = [venue objectForKey:@"location"];
    if (location) {
        NSMutableString *locationText = [NSMutableString stringWithString:[location objectForKey:@"address"]];
        [locationText appendFormat:@" (%@)", [NSString localizedStringForDistance:[[location objectForKey:@"distance"] floatValue]]];
        if ([location objectForKey:@"crossStreet"]) {
            [locationText appendFormat:@" (%@)", [location objectForKey:@"crossStreet"]];
        }
        self.addressLabel.text = locationText;
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
    
    height += MARGIN * 2;
    
    // Labels
    CGSize labelSize = CGSizeZero;
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"name"] width:width style:@"h5CondDarkLabel"];
    height += labelSize.height;
    
    NSString *categoryText = [NSString stringWithFormat:@"❖ %@", [venue objectForKey:@"category"]];
    labelSize = [PSStyleSheet sizeForText:categoryText width:width style:@"h6DarkLabel"];
    height += labelSize.height;
    
    // Divider
    height += MARGIN;
    height += 1.0;
    height += MARGIN;
    
    // Rating
    CGFloat rating = [[venue objectForKey:@"rating"] floatValue];
    NSInteger ratingSignals = [[venue objectForKey:@"ratingSignals"] integerValue];
    NSString *ratingText = [NSString stringWithFormat:@"★ %.1f out of %d ratings", rating, ratingSignals];
    labelSize = [PSStyleSheet sizeForText:ratingText width:width style:@"h6DarkLabel"];
    height += labelSize.height;
    
    NSString *tip = [venue objectForKey:@"tip"];
    if (tip) {
        NSString *tipText = [NSString stringWithFormat:@"%@", tip];
        labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"h6GeorgiaDarkLabel"];
        height += labelSize.height;
        
        height += MARGIN;
        height += 1.0;
        height += MARGIN;
    }
    
    // Address
    NSDictionary *location = [venue objectForKey:@"location"];
    if (location) {
        NSMutableString *locationText = [NSMutableString stringWithString:[location objectForKey:@"address"]];
        [locationText appendFormat:@" (%@)", [NSString localizedStringForDistance:[[location objectForKey:@"distance"] floatValue]]];
        if ([location objectForKey:@"crossStreet"]) {
            [locationText appendFormat:@" (%@)", [location objectForKey:@"crossStreet"]];
        }
        labelSize = [PSStyleSheet sizeForText:locationText width:width style:@"h6DarkLabel"];
        height += labelSize.height;
    }
    
    height += MARGIN;
    
    return height;
}

@end
