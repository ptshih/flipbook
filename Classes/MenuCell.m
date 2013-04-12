//
//  MenuCell.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "MenuCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 8.0);
    } else {
        return CGSizeMake(8.0, 8.0);
    }
}

@interface MenuCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Image
        self.psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.psImageView.loadingColor = RGBACOLOR(30, 30, 30, 1.0);
        self.psImageView.clipsToBounds = YES;
        self.psImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.psImageView];
        
        // Labels
        self.titleLabel = [UILabel labelWithStyle:@"menuTitleLabel"];
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
    CGFloat width = 80.0 - margin().width * 2;
    
    self.psImageView.frame = CGRectMake(left, top, width, 60.0 - margin().height);
    top = self.psImageView.bottom;
    
    // Label
    self.titleLabel.frame = CGRectMake(left, top, width, 20.0 - margin().height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *icon = [dict objectForKey:@"icon"] ? [dict objectForKey:@"icon"] : @"IconCartWhite";
    [self.psImageView loadImage:[UIImage imageNamed:icon]];
    
    NSString *title = [NSString stringWithFormat:@"%@", [dict objectForKey:@"title"]];
    self.titleLabel.text = title;
}

+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return 80.0;
}

@end
