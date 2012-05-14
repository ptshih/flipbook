//
//  EventCell.m
//  Lunchbox
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"

#define MARGIN 8.0
#define IMAGE_SIZE 40.0

@interface EventCell ()

@property (nonatomic, strong) TTTAttributedLabel *messageLabel;

@end

@implementation EventCell

@synthesize
messageLabel = _messageLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.psImageView];
        
        self.messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.userInteractionEnabled = NO;
        [PSStyleSheet applyStyle:@"eventMessageLabel" forLabel:self.messageLabel];
        [self.contentView addSubview:self.messageLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
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
    
    labelSize = [PSStyleSheet sizeForText:self.messageLabel.text width:width style:@"eventMessageLabel"];
    self.messageLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
//    top = self.textLabel.bottom;
    
//    self.detailTextLabel.frame = CGRectMake(left, top, width, 25.0);
//    top = self.detailTextLabel.bottom;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [dict objectForKey:@"fbId"]]];
    [self.psImageView loadImageWithURL:profileURL];
    
    // Attributed message
    NSString *message = [NSString stringWithFormat:@"%@ is going to %@ for %@", [dict objectForKey:@"fbName"], [dict objectForKey:@"venueName"], [dict objectForKey:@"reason"]];
    
    
    [self.messageLabel setText:message afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange userNameRange = [[mutableAttributedString string] rangeOfString:[dict objectForKey:@"fbName"] options:NSCaseInsensitiveSearch];
        NSRange venueNameRange = [[mutableAttributedString string] rangeOfString:[dict objectForKey:@"venueName"] options:NSCaseInsensitiveSearch];
        NSRange reasonRange = [[mutableAttributedString string] rangeOfString:[dict objectForKey:@"reason"] options:NSCaseInsensitiveSearch];
        
        //Color
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:userNameRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:venueNameRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:reasonRange];
        
        return mutableAttributedString;
    }];
    
//    self.textLabel.text = message;
//    self.detailTextLabel.text = [dict objectForKey:@"venueId"];
    
//    UIButton *accessoryButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(accessoryButtonTapped:withEvent:)];
//    [accessoryButton setImage:[UIImage imageNamed:@"IconPlusWhite"] forState:UIControlStateNormal];
//    
//    self.accessoryView = accessoryButton;
//    self.parentTableView = tableView;
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSDictionary *dict = (NSDictionary *)object;
    
    CGFloat height = 0.0;
    CGFloat width = 268.0 - MARGIN * 2;
    width -= IMAGE_SIZE + MARGIN;
    
    
    NSString *message = [NSString stringWithFormat:@"%@ is going to %@ for %@", [dict objectForKey:@"fbName"], [dict objectForKey:@"venueName"], [dict objectForKey:@"reason"]];
    CGSize labelSize = [PSStyleSheet sizeForText:message width:width style:@"eventMessageLabel"];
    height += labelSize.height;
    
    height = MAX(IMAGE_SIZE, height);
    
    height += MARGIN * 2;
    
    return height;
}

#pragma mark - Action
//- (void)accessoryButtonTapped:(UIButton *)button withEvent:(UIEvent *)event {
//    NSIndexPath * indexPath = [self.parentTableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView: self.parentTableView]];
//    if (!indexPath) return;
//    
//    if (self.parentTableView.delegate && [self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
//        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//    }
//}

@end
