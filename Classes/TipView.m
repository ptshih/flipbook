//
//  TipView.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipView.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0

@interface TipView ()

@property (nonatomic, retain) PSCachedImageView *imageView;
@property (nonatomic, retain) UILabel *tipLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *homeCityLabel;
@property (nonatomic, retain) UIImageView *divider;

@end

@implementation TipView

@synthesize
imageView = _imageView,
tipLabel = _tipLabel,
nameLabel = _nameLabel,
homeCityLabel = _homeCityLabel,
divider = _divider;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *shadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadowImage] autorelease];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadowView.frame = CGRectInset(self.bounds, -1, -2);
        [self addSubview:shadowView];
        
        self.imageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.imageView.shouldAnimate = NO;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.tipLabel = [UILabel labelWithStyle:@"bodyLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.tipLabel];
        
        self.nameLabel = [UILabel labelWithStyle:@"h4Label"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"bodyLabel"];
        self.homeCityLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.homeCityLabel];
        
        self.divider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        [self addSubview:self.divider];
    }
    return self;
}

- (void)dealloc {
    self.imageView = nil;
    self.tipLabel = nil;
    self.nameLabel = nil;
    self.homeCityLabel = nil;
    self.divider = nil;
    [super dealloc];
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
    
    labelSize = [PSStyleSheet sizeForText:self.tipLabel.text width:width style:@"bodyLabel"];
    self.tipLabel.top = top;
    self.tipLabel.left = left;
    self.tipLabel.width = labelSize.width;
    self.tipLabel.height = labelSize.height;
    
    top = self.tipLabel.bottom + MARGIN;
    self.divider.frame = CGRectMake(left, top, width, 1.0);
    top = self.divider.bottom + MARGIN;
    
    self.imageView.frame = CGRectMake(left, top, 30, 30);
    
    left += self.imageView.width + MARGIN;
    width -= self.imageView.width + MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"h4Label"];
    self.nameLabel.top = top;
    self.nameLabel.left = left;
    self.nameLabel.width = labelSize.width;
    self.nameLabel.height = labelSize.height;
    
    top = self.nameLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.homeCityLabel.text width:width style:@"bodyLabel"];
    self.homeCityLabel.top = top;
    self.homeCityLabel.left = left;
    self.homeCityLabel.width = labelSize.width;
    self.homeCityLabel.height = labelSize.height;
}

- (void)fillViewWithObject:(id)object {
    [super fillViewWithObject:object];
    
    NSDictionary *user = [self.object objectForKey:@"user"];
    NSString *name = [user objectForKey:@"firstName"];
    name = [user objectForKey:@"lastName"] ? [name stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : name;
    
    self.tipLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"text"]];
    self.nameLabel.text = name;
    self.homeCityLabel.text = [user objectForKey:@"homeCity"];
    
    [self.imageView loadImageWithURL:[NSURL URLWithString:[user objectForKey:@"photo"]] cacheType:PSURLCacheTypeSession];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    CGSize labelSize = CGSizeZero;
    
    height += MARGIN;
    
    NSString *tipText = [NSString stringWithFormat:@"%@", [object objectForKey:@"text"]];
    labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"bodyLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    height += 1.0;
    height += MARGIN;
    
    width -= 30 + MARGIN;
    
    CGFloat footerHeight = 0.0;
    
    NSDictionary *user = [object objectForKey:@"user"];
    NSString *name = [user objectForKey:@"firstName"];
    name = [user objectForKey:@"lastName"] ? [name stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : name;
    labelSize = [PSStyleSheet sizeForText:name width:width style:@"h4Label"];
    footerHeight += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[user objectForKey:@"homeCity"] width:width style:@"bodyLabel"];
    footerHeight += labelSize.height;
    
    height += MAX(footerHeight, 30.0);
    
    height += MARGIN;
    
    return height;
}

@end
