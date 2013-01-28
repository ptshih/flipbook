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
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Image
//        self.psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
//        self.psImageView.loadingColor = RGBACOLOR(30, 30, 30, 1.0);
//        self.psImageView.clipsToBounds = YES;
//        self.psImageView.contentMode = UIViewContentModeCenter;
//        [self.psImageView loadImage:[UIImage imageNamed:@"ItemDoingBlack"]];
//        [self.contentView addSubview:self.psImageView];
        
        // Labels
        self.titleLabel = [UILabel labelWithStyle:@"h2LightLabel"];
//        self.titleLabel.backgroundColor = RGBACOLOR(30, 30, 30, 0.75);
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
    
    // Label
    labelSize = [self.titleLabel sizeForLabelInWidth:width];
    self.titleLabel.frame = CGRectMake(left, self.contentView.height - labelSize.height - top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *title = [NSString stringWithFormat:@"%@", [dict objectForKey:@"title"]];
    self.titleLabel.text = title;
}

+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat height = 0.0;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - margin().width * 2;
    
    height += margin().height;
    
    // Label
    NSString *title = [dict objectForKey:@"title"];
    height += [PSStyleSheet sizeForText:title width:width style:@"h2LightLabel"].height;
    
    height += margin().height;
    
    return height;
}

@end
