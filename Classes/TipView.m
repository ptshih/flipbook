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

@property (nonatomic, retain) UILabel *tipLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *homeCityLabel;
@property (nonatomic, retain) UIImageView *divider;

@end

@implementation TipView

@synthesize
tipLabel = _tipLabel,
nameLabel = _nameLabel,
homeCityLabel = _homeCityLabel,
divider = _divider;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipLabel = [UILabel labelWithStyle:@"bodyLabel"];
        self.tipLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.tipLabel];
        
        self.nameLabel = [UILabel labelWithStyle:@"titleLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        self.homeCityLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.homeCityLabel];
        
        self.divider = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:1 topCapWidth:1]] autorelease];
        [self addSubview:self.divider];
    }
    return self;
}

- (void)dealloc {
    self.tipLabel = nil;
    self.nameLabel = nil;
    self.homeCityLabel = nil;
    self.divider = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
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
    [super fillViewWithObject:object];
    
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
