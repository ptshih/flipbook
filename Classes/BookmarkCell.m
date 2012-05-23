//
//  BookmarkCell.m
//  Lunchbox
//
//  Created by Peter Shih on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkCell.h"

#define MARGIN 8.0
#define IMAGE_SIZE 32.0

@interface BookmarkCell ()

@property (nonatomic, strong) TTTAttributedLabel *messageLabel;
@property (nonatomic, strong) UILabel *timestampLabel;

@end

@implementation BookmarkCell

@synthesize
messageLabel = _messageLabel,
timestampLabel = _timestampLabel;

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
        
        self.timestampLabel = [UILabel labelWithStyle:@"metaLabel"];
        [self.contentView addSubview:self.timestampLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.messageLabel.text = nil;
    self.timestampLabel.text = nil;
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
    
    top = self.messageLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.timestampLabel.text width:width style:@"metaLabel"];
    self.timestampLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;

    // Picture
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [dict objectForKey:@"fbId"]]];
    [self.psImageView loadImageWithURL:profileURL];
    
    // Attributed message
    NSString *userName = [dict objectForKey:@"fbName"];
    NSString *venueName = [dict objectForKey:@"venueName"];
    NSString *venueAddress = [dict objectForKey:@"venueAddress"];
    NSString *message = [NSString stringWithFormat:@"%@ saved %@ located at %@", userName, venueName, venueAddress];
    
    [self.messageLabel setText:message afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange userNameRange = [[mutableAttributedString string] rangeOfString:userName options:NSCaseInsensitiveSearch];
        NSRange venueNameRange = [[mutableAttributedString string] rangeOfString:venueName options:NSCaseInsensitiveSearch];
        NSRange venueAddressRange = [[mutableAttributedString string] rangeOfString:venueAddress options:NSCaseInsensitiveSearch];
        
        //Color
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:userNameRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:venueNameRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:venueAddressRange];
        
        return mutableAttributedString;
    }];
    
    NSString *timestamp = [[PSDateFormatter sharedDateFormatter] shortRelativeStringFromDate:[NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"timestamp"] doubleValue]] includeTime:PSDateFormatterIncludeTimeLast24Hours useShortDate:YES];
    self.timestampLabel.text = timestamp;
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSDictionary *dict = (NSDictionary *)object;
    
    CGFloat height = 0.0;
    CGFloat width = 268.0 - MARGIN * 2;
    width -= IMAGE_SIZE + MARGIN;
    
    
    // Attributed message
    NSString *userName = [dict objectForKey:@"fbName"];
    NSString *venueName = [dict objectForKey:@"venueName"];
    NSString *venueAddress = [dict objectForKey:@"venueAddress"];
    NSString *message = [NSString stringWithFormat:@"%@ saved %@ located at %@", userName, venueName, venueAddress];
    
    CGSize labelSize = [PSStyleSheet sizeForText:message width:width style:@"eventMessageLabel"];
    height += labelSize.height;
    
    NSString *timestamp = [[PSDateFormatter sharedDateFormatter] shortRelativeStringFromDate:[NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"timestamp"] doubleValue]] includeTime:PSDateFormatterIncludeTimeLast24Hours useShortDate:YES];
    labelSize = [PSStyleSheet sizeForText:timestamp width:width style:@"metaLabel"];
    height += labelSize.height;
        
    height += MARGIN * 2;
    
    height = MAX(IMAGE_SIZE + MARGIN * 2, height);
    
    return height;
}

@end
