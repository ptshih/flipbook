//
//  NewItemCell.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "NewItemCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 8.0);
    } else {
        return CGSizeMake(8.0, 8.0);
    }
}

@interface NewItemCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end



@implementation NewItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
    height += [PSStyleSheet sizeForText:title width:width style:@"h2DarkLabel"].height;
    
    height += margin().height;
    
    return height;
}

@end
