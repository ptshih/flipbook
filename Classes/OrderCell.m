//
//  OrderCell.m
//  Celery
//
//  Created by Peter Shih on 4/11/13.
//
//

#import "OrderCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 8.0);
    } else {
        return CGSizeMake(8.0, 8.0);
    }
}

@interface OrderCell ()

@property (nonatomic, strong) UILabel *orderidLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *productLabel;
@property (nonatomic, strong) UILabel *buyerLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation OrderCell

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
        self.productLabel = [UILabel labelWithStyle:@"orderCellProductLabel"];
        [self.contentView addSubview:self.productLabel];
        
        self.totalLabel = [UILabel labelWithStyle:@"orderCellTotalLabel"];
        [self.contentView addSubview:self.totalLabel];
        
        self.dateLabel = [UILabel labelWithStyle:@"orderCellDateLabel"];
        [self.contentView addSubview:self.dateLabel];
        
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.orderidLabel.text = nil;
    self.dateLabel.text = nil;
    self.productLabel.text = nil;
    self.buyerLabel.text = nil;
    self.totalLabel.text = nil;
    self.statusLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = margin().width;
    CGFloat top = margin().height;
    CGFloat width = self.contentView.width - margin().width * 2;
    CGSize labelSize = CGSizeZero;
    
    // Label
    labelSize = [self.productLabel sizeForLabelInWidth:width];
    self.productLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    top = self.productLabel.bottom + margin().height;
    
    labelSize = [self.dateLabel sizeForLabelInWidth:width];
    self.dateLabel.frame = CGRectMake(width - labelSize.width - margin().width, top, labelSize.width, labelSize.height);
    
    width -= labelSize.width + margin().width;
    
    labelSize = [self.totalLabel sizeForLabelInWidth:width];
    self.totalLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSDictionary *product = [[dict objectForKey:@"products"] firstObject];
    NSString *productName = [NSString stringWithFormat:@"%@", [product objectForKey:@"name"]];
    self.productLabel.text = productName;
    
    NSDecimalNumber *cents = [NSDecimalNumber decimalNumberWithDecimal:[[dict objectForKey:@"total"] decimalValue]];
    NSDecimalNumber *dollars = [cents decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *total = [NSString stringWithFormat:@"Total: %@", [numberFormatter stringFromNumber:dollars]];
    self.totalLabel.text = total;
    
    
    NSDate *date = [NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"created"] doubleValue]];
    NSString *dateText = [date stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    self.dateLabel.text = dateText;
}

+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat height = 0.0;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - margin().width * 2;
    
    height += margin().height;
    
    // Label
    NSDictionary *product = [[dict objectForKey:@"products"] firstObject];
    NSString *productName = [NSString stringWithFormat:@"%@", [product objectForKey:@"name"]];
    height += [PSStyleSheet sizeForText:productName width:width style:@"orderCellProductLabel"].height + margin().height;
    
//    NSDecimalNumber *cents = [NSDecimalNumber decimalNumberWithDecimal:[[dict objectForKey:@"total"] decimalValue]];
//    NSDecimalNumber *dollars = [cents decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//    NSString *total = [NSString stringWithFormat:@"Total: %@", [numberFormatter stringFromNumber:dollars]];
//    height += [PSStyleSheet sizeForText:total width:width style:@"orderCellTotalLabel"].height;
    
    NSDate *date = [NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"created"] doubleValue]];
    NSString *dateText = [date stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    height += [PSStyleSheet sizeForText:dateText width:width style:@"orderCellDateLabel"].height;
    
    height += margin().height;
    
    return height;
}

@end
