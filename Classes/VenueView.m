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

@property (nonatomic, retain) PSCachedImageView *imageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *addressLabel;
@property (nonatomic, retain) UILabel *categoryLabel;
@property (nonatomic, retain) UILabel *distanceLabel;
@property (nonatomic, retain) UILabel *tipUserLabel;
@property (nonatomic, retain) UILabel *tipLabel;
@property (nonatomic, retain) UILabel *statsLabel;
@property (nonatomic, retain) UIImageView *topDivider;
@property (nonatomic, retain) UIImageView *divider;

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
divider = _divider;

+ (void)initialize {
    __numberFormatter = [[NSNumberFormatter alloc] init];
    [__numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *shadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadowImage] autorelease];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadowView.frame = CGRectInset(self.bounds, -1, -2);
        [self addSubview:shadowView];
        
        self.imageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.imageView.shouldAnimate = YES;
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
        
        self.statsLabel = [UILabel labelWithStyle:@"metaLabel"];
        self.statsLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.statsLabel];
        
        self.tipUserLabel = [UILabel labelWithStyle:@"attributedBoldLabel"];
        self.tipUserLabel.backgroundColor = self.backgroundColor;
        self.tipUserLabel.hidden = YES;
        [self addSubview:self.tipUserLabel];
        
        self.tipLabel = [UILabel labelWithStyle:@"attributedLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        self.tipLabel.hidden = YES;
        [self addSubview:self.tipLabel];
        
        // Must set to 0 lines and word wrap line break mode
//        self.tipLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
//        self.tipLabel.backgroundColor = self.backgroundColor;
//        self.tipLabel.userInteractionEnabled = NO;
//        [PSStyleSheet applyStyle:@"attributedLabel" forLabel:self.tipLabel];
//        [self addSubview:self.tipLabel];
        
        self.topDivider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        self.topDivider.hidden = YES;
        [self addSubview:self.topDivider];
        
        self.divider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        self.divider.hidden = YES;
        [self addSubview:self.divider];
    }
    return self;
}

- (void)dealloc {
    self.imageView = nil;
    self.nameLabel = nil;
    self.addressLabel = nil;
    self.categoryLabel = nil;
    self.distanceLabel = nil;
    self.tipUserLabel = nil;
    self.tipLabel = nil;
    self.statsLabel = nil;
    self.topDivider = nil;
    self.divider = nil;
    [super dealloc];
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
    
    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top = self.imageView.bottom + MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:self.statsLabel.text width:width style:@"metaLabel"];
    self.statsLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.statsLabel.bottom;
    
    top += MARGIN;
    self.topDivider.hidden = NO;
    self.topDivider.frame = CGRectMake(left, top, width, 1.0);
    top = self.topDivider.bottom + MARGIN;
    
    if ([self.tipLabel.text length] > 0) {
        labelSize = [PSStyleSheet sizeForText:self.tipUserLabel.text width:width style:@"attributedBoldLabel"];
        self.tipUserLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
        self.tipUserLabel.hidden = NO;
        
        top = self.tipUserLabel.bottom;
        
        labelSize = [PSStyleSheet sizeForText:self.tipLabel.text width:width style:@"attributedLabel"];
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

- (void)fillViewWithObject:(id)object {
    [super fillViewWithObject:object];
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView loadImageWithURL:[NSURL URLWithString:[self.object objectForKey:@"source"]] cacheType:PSURLCacheTypePermanent];
    
    self.nameLabel.text = [self.object objectForKey:@"name"];
    self.addressLabel.text = [self.object objectForKey:@"address"];
    self.categoryLabel.text = [self.object objectForKey:@"category"];
    self.distanceLabel.text = [NSString localizedStringForDistance:[[self.object objectForKey:@"distance"] floatValue]];
    self.statsLabel.text = [NSString stringWithFormat:@"%@ people checked in.", [__numberFormatter stringFromNumber:[[self.object objectForKey:@"stats"] objectForKey:@"checkinsCount"]]];
    
    NSDictionary *tip = [self.object objectForKey:@"tip"];
    if (tip) {
        NSDictionary *tipUser = [tip objectForKey:@"user"];
        NSString *tipUserName = tipUser ? [tipUser objectForKey:@"firstName"] : nil;
        tipUserName = [tipUser objectForKey:@"lastName"] ? [tipUserName stringByAppendingFormat:@" %@", [tipUser objectForKey:@"lastName"]] : tipUserName;
        NSString *tipUserText = [NSString stringWithFormat:@"%@ says:", tipUserName];
        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
        
        self.tipUserLabel.text = tipUserText;
        self.tipLabel.text = tipText;
        
//        [self.tipLabel setText:tipText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
//            NSRange userNameRange = [[mutableAttributedString string] rangeOfString:tipUserName options:NSCaseInsensitiveSearch];
//            
//            // Color
//            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:userNameRange];
//            
//            return mutableAttributedString;
//        }];
    }
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
    
    height += MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:[NSString stringWithFormat:@"%@ people checked in.", [__numberFormatter stringFromNumber:[[object objectForKey:@"stats"] objectForKey:@"checkinsCount"]]] width:width style:@"metaLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    height += 1.0;
    height += MARGIN;
    
    NSDictionary *tip = [object objectForKey:@"tip"];
    if (tip) {
        NSDictionary *tipUser = [tip objectForKey:@"user"];
        NSString *tipUserName = tipUser ? [tipUser objectForKey:@"firstName"] : nil;
        tipUserName = [tipUser objectForKey:@"lastName"] ? [tipUserName stringByAppendingFormat:@" %@", [tipUser objectForKey:@"lastName"]] : tipUserName;
        NSString *tipUserText = [NSString stringWithFormat:@"%@ says:", tipUserName];
        NSString *tipText = [[tip objectForKey:@"text"] capitalizedString];
        
        labelSize = [PSStyleSheet sizeForText:tipUserText width:width style:@"attributedBoldLabel"];
        height += labelSize.height;
        
        labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"attributedLabel"];
        height += labelSize.height;
        
        height += MARGIN;
        height += 1.0;
        height += MARGIN;
    }
    
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"address"] width:width style:@"subtitleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"category"] width:width style:@"metaLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
