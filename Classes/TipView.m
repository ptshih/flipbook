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

@implementation TipView

@synthesize
object = _object,
backgroundView = _backgroundView,
tipLabel = _tipLabel,
nameLabel = _nameLabel,
homeCityLabel = _homeCityLabel,
divider = _divider;

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

        self.tipLabel = [UILabel labelWithStyle:@"bodyLabel"];
        [self addSubview:self.tipLabel];
        
        self.nameLabel = [UILabel labelWithStyle:@"titleLabel"];
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        [self addSubview:self.homeCityLabel];
        
        self.divider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        [self addSubview:self.divider];
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    self.backgroundView = nil;
    
    self.tipLabel = nil;
    self.nameLabel = nil;
    self.homeCityLabel = nil;
    self.divider = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.tipLabel.text = nil;
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
    
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:self.tipLabel.text width:width style:@"bodyLabel"];
    self.tipLabel.top = top;
    self.tipLabel.left = left;
    self.tipLabel.width = labelSize.width;
    self.tipLabel.height = labelSize.height;
    
    top = self.tipLabel.bottom + MARGIN;
    self.divider.frame = CGRectMake(left, top, width, 1.0);
    top = self.divider.bottom + MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"titleLabel"];
    self.nameLabel.top = top;
    self.nameLabel.left = left;
    self.nameLabel.width = labelSize.width;
    self.nameLabel.height = labelSize.height;
    
    top = self.nameLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.homeCityLabel.text width:width style:@"subtitleLabel"];
    self.homeCityLabel.top = top;
    self.homeCityLabel.left = left;
    self.homeCityLabel.width = labelSize.width;
    self.homeCityLabel.height = labelSize.height;
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
    NSDictionary *user = [self.object objectForKey:@"user"];
    NSString *name = [user objectForKey:@"firstName"];
    name = [user objectForKey:@"lastName"] ? [name stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : name;
    
    self.tipLabel.text = [NSString stringWithFormat:@"\"%@\"", [object objectForKey:@"text"]];
    self.nameLabel.text = name;
    self.homeCityLabel.text = [user objectForKey:@"homeCity"];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    CGSize labelSize = CGSizeZero;
    
    height += MARGIN;
    
    NSString *tipText = [NSString stringWithFormat:@"\"%@\"", [object objectForKey:@"text"]];
    labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"bodyLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    height += 1.0;
    height += MARGIN;
    
    NSDictionary *user = [object objectForKey:@"user"];
    NSString *name = [user objectForKey:@"firstName"];
    name = [user objectForKey:@"lastName"] ? [name stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : name;
    labelSize = [PSStyleSheet sizeForText:name width:width style:@"titleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[user objectForKey:@"homeCity"] width:width style:@"subtitleLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
