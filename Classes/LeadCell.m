//
//  LeadCell.m
//  Celery
//
//  Created by Peter Shih on 4/17/13.
//
//

#import "LeadCell.h"


// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 8.0);
    } else {
        return CGSizeMake(8.0, 8.0);
    }
}

@interface LeadCell ()

@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UILabel *productLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation LeadCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Image
        //        self.psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        //        self.psImageView.loadingColor = RGBACOLOR(30, 30, 30, 1.0);
        //        self.psImageView.clipsToBounds = YES;
        //        self.psImageView.contentMode = UIViewContentModeCenter;
        //        [self.psImageView loadImage:[UIImage imageNamed:@"ItemDoingBlack"]];
        //        [self.contentView addSubview:self.psImageView];
        
        // Labels
        self.emailLabel = [UILabel labelWithStyle:@"leadCellEmailLabel"];
        [self.contentView addSubview:self.emailLabel];
        self.productLabel = [UILabel labelWithStyle:@"leadCellProductLabel"];
        [self.contentView addSubview:self.productLabel];
        
        self.locationLabel = [UILabel labelWithStyle:@"leadCellLocationLabel"];
        [self.contentView addSubview:self.locationLabel];
        
        self.dateLabel = [UILabel labelWithStyle:@"leadCellDateLabel"];
        [self.contentView addSubview:self.dateLabel];
        
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.emailLabel.text = nil;
    self.productLabel.text = nil;
    self.locationLabel.text = nil;
    self.dateLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = margin().width;
    CGFloat top = margin().height;
    CGFloat width = self.contentView.width - margin().width * 2;
    CGSize labelSize = CGSizeZero;
    
    // Label
    labelSize = [self.emailLabel sizeForLabelInWidth:width];
    self.emailLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    top = self.emailLabel.bottom + margin().height;
    
    labelSize = [self.productLabel sizeForLabelInWidth:width];
    self.productLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    top = self.productLabel.bottom + margin().height;
    
    labelSize = [self.locationLabel sizeForLabelInWidth:width];
    self.locationLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    top = self.locationLabel.bottom + margin().height;
    
    labelSize = [self.dateLabel sizeForLabelInWidth:width];
    self.dateLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *email = [NSString stringWithFormat:@"%@", [dict objectForKey:@"email"]];
    if ([[dict objectForKey:@"name"] notNull]) {
        email = [NSString stringWithFormat:@"%@ (%@)", email, [dict objectForKey:@"name"]];
    }
    self.emailLabel.text = email;
    
    NSString *productName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"product_name"]];
    self.productLabel.text = productName;
    
    NSString *location = [NSString stringWithFormat:@"%@, %@", [dict objectForKey:@"zip"], [dict objectForKey:@"country"]];
    self.locationLabel.text = location;
    
    NSDate *date = [NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"created"] doubleValue]];
    NSString *dateText = [date stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    self.dateLabel.text = dateText;
}

+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat height = 0.0;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - margin().width * 2;
    
    height += margin().height;
    
    NSString *email = [NSString stringWithFormat:@"%@", [dict objectForKey:@"email"]];
    if ([[dict objectForKey:@"name"] notNull]) {
        email = [NSString stringWithFormat:@"%@ (%@)", email, [dict objectForKey:@"name"]];
    }
    height += [PSStyleSheet sizeForText:email width:width style:@"leadCellEmailLabel"].height + margin().height;
    
    NSString *productName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"product_name"]];
    height += [PSStyleSheet sizeForText:productName width:width style:@"leadCellProductLabel"].height + margin().height;
    
    NSString *location = [NSString stringWithFormat:@"%@, %@", [dict objectForKey:@"zip"], [dict objectForKey:@"country"]];
    height += [PSStyleSheet sizeForText:location width:width style:@"leadCellLocationLabel"].height + margin().height;
 
    NSDate *date = [NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"created"] doubleValue]];
    NSString *dateText = [date stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    height += [PSStyleSheet sizeForText:dateText width:width style:@"leadCellDateLabel"].height;
    
    height += margin().height;
    
    return height;
}

@end
