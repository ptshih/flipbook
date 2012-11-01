//
//  SliceCell.m
//  Lunchbox
//
//  Created by Peter Shih on 10/26/12.
//
//

#import "SliceCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 8.0);
    } else {
        return CGSizeMake(8.0, 8.0);
    }
}

@interface SliceCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation SliceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Image
        self.psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.psImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.psImageView];
        
        // Labels
        self.titleLabel = [UILabel labelWithStyle:@"h2DarkLabel"];
        self.titleLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = margin().width;
    CGFloat top = margin().height;
    CGFloat width = self.contentView.width - margin().width * 2;
    CGSize labelSize = CGSizeZero;
    
    // Image
    self.psImageView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
    
    // Label
    labelSize = [self.titleLabel sizeForLabelInWidth:width];
    self.titleLabel.frame = CGRectMake(left, self.contentView.height - labelSize.height - top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *image = [dict objectForKey:@"image"];
    [self.psImageView setOriginalURL:[NSURL URLWithString:image]];
    [self.psImageView setThumbnailURL:[NSURL URLWithString:image]];
    [self.psImageView loadImageWithURL:self.psImageView.originalURL cacheType:PSURLCacheTypePermanent];
    
    NSString *title = [NSString stringWithFormat:@" %@ ", [dict objectForKey:@"name"]];
    
    self.titleLabel.text = title;
}


+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return isDeviceIPad() ? 320.0 : 160.0;
}

@end
