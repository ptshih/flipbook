//
//  VenueMiniCell.m
//  Lunchbox
//
//  Created by Peter Shih on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueMiniCell.h"

#define MARGIN 8.0
#define IMAGE_SIZE 44.0

@interface VenueMiniCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *categoryLabel;

@end

@implementation VenueMiniCell

@synthesize
nameLabel = _nameLabel,
addressLabel = _addressLabel,
categoryLabel = _categoryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.psImageView];
        
        self.nameLabel = [UILabel labelWithStyle:@"titleLabel"];
        [self addSubview:self.nameLabel];
        
        self.addressLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        [self addSubview:self.addressLabel];
        
        self.categoryLabel = [UILabel labelWithStyle:@"metaLabel"];
        [self addSubview:self.categoryLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
    CGFloat left = MARGIN;
    CGFloat top = MARGIN;
    CGFloat width = self.contentView.width - MARGIN * 2;
    CGSize labelSize = CGSizeZero;
    
    // Image
    self.psImageView.frame = CGRectMake(left, top, IMAGE_SIZE, IMAGE_SIZE);
    left = self.psImageView.right + MARGIN;
    width -= self.psImageView.width + MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"titleLabel"];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.nameLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.addressLabel.text width:width style:@"subtitleLabel"];
    self.addressLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.addressLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.categoryLabel.text width:width style:@"metaLabel"];
    self.categoryLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.categoryLabel.bottom;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;
//    NSDictionary *user = [dict objectForKey:@"user"];
    NSDictionary *venue = [dict objectForKey:@"venue"];
    
    // Picture
    NSURL *categoryURL = [NSURL URLWithString:[venue objectForKey:@"categoryUrl"]];
    [self.psImageView loadImageWithURL:categoryURL];
    
    self.nameLabel.text = [venue objectForKey:@"name"];
    self.addressLabel.text = [venue objectForKey:@"address"];
    self.categoryLabel.text = [venue objectForKey:@"category"];
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSDictionary *dict = (NSDictionary *)object;
//    NSDictionary *user = [dict objectForKey:@"user"];
    NSDictionary *venue = [dict objectForKey:@"venue"];
    
    CGFloat height = 0.0;
    CGFloat width = 268.0 - MARGIN * 2;
    width -= IMAGE_SIZE + MARGIN;
    
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"name"] width:width style:@"titleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"address"] width:width style:@"subtitleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[venue objectForKey:@"category"] width:width style:@"metaLabel"];
    height += labelSize.height;
    
    height += MARGIN * 2;
    
    height = MAX(IMAGE_SIZE + MARGIN * 2, height);
    
    return height;
}

@end
