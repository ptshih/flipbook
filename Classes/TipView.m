//
//  TipView.m
//  Mealtime
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
homeCityLabel = _homeCityLabel;

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

        self.tipLabel = [UILabel labelWithStyle:@"tipLabel"];
        [self addSubview:self.tipLabel];
        
        self.nameLabel = [UILabel labelWithStyle:@"timelineNameLabel"];
        [self addSubview:self.nameLabel];
        
        self.homeCityLabel = [UILabel labelWithStyle:@"timelineHomeCityLabel"];
        [self addSubview:self.homeCityLabel];
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    self.backgroundView = nil;
    
    self.tipLabel = nil;
    self.nameLabel = nil;
    self.homeCityLabel = nil;
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
    
    labelSize = [PSStyleSheet sizeForText:self.tipLabel.text width:width style:@"tipLabel"];
    self.tipLabel.top = top;
    self.tipLabel.left = left;
    self.tipLabel.width = labelSize.width;
    self.tipLabel.height = labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"timelineNameLabel"];
    self.nameLabel.top = self.tipLabel.bottom;
    self.nameLabel.left = left;
    self.nameLabel.width = labelSize.width;
    self.nameLabel.height = labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:self.homeCityLabel.text width:width style:@"timelineHomeCityLabel"];
    self.homeCityLabel.top = self.nameLabel.bottom;
    self.homeCityLabel.left = left;
    self.homeCityLabel.width = labelSize.width;
    self.homeCityLabel.height = labelSize.height;
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
    NSDictionary *user = [self.object objectForKey:@"user"];
    NSString *name = [user objectForKey:@"firstName"];
    name = [user objectForKey:@"lastName"] ? [name stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : name;
    
    self.tipLabel.text = [self.object objectForKey:@"text"];
    self.nameLabel.text = name;
    self.homeCityLabel.text = [user objectForKey:@"homeCity"];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    CGSize labelSize = CGSizeZero;
    
    height += MARGIN;
    
    NSString *tipText = [object objectForKey:@"text"];
    labelSize = [PSStyleSheet sizeForText:tipText width:width style:@"tipLabel"];
    height += labelSize.height;
    
    NSDictionary *user = [object objectForKey:@"user"];
    NSString *name = [user objectForKey:@"firstName"];
    name = [user objectForKey:@"lastName"] ? [name stringByAppendingFormat:@" %@", [user objectForKey:@"lastName"]] : name;
    labelSize = [PSStyleSheet sizeForText:name width:width style:@"timelineNameLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[user objectForKey:@"homeCity"] width:width style:@"timelineHomeCityLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
