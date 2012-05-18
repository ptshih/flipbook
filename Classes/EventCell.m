//
//  EventCell.m
//  Lunchbox
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"
#import "PSFacepileView.h"

#define MARGIN 8.0
#define IMAGE_SIZE 40.0

@interface EventCell ()

@property (nonatomic, strong) TTTAttributedLabel *messageLabel;
@property (nonatomic, strong) PSFacepileView *facepileView;

@end

@implementation EventCell

@synthesize
messageLabel = _messageLabel,
facepileView = _facepileView;

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
        
        self.facepileView = [[PSFacepileView alloc] initWithFrame:CGRectZero];
        self.facepileView.hidden = YES;
        [self.contentView addSubview:self.facepileView];
        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.facepileView prepareForReuse];
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
    
    if (!self.facepileView.hidden) {
        self.facepileView.top = top;
        self.facepileView.left = left;
    }
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;
    
    NSDictionary *where = [dict objectForKey:@"where"];
    
    NSArray *attendees = [dict objectForKey:@"attendees"];
    NSMutableArray *fbNames = [NSMutableArray array];
    NSMutableArray *fbIds = [NSMutableArray array];
    for (NSDictionary *attendee in attendees) {
        [fbNames addObject:[attendee objectForKey:@"fbName"]];
        [fbIds addObject:[attendee objectForKey:@"fbId"]];
    }
    NSString *creatorId = [[attendees objectAtIndexOrNil:0] objectForKey:@"fbId"];
    
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", creatorId]];
    [self.psImageView loadImageWithURL:profileURL];
    
//    NSDate *eventDate = [NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"timestamp"] doubleValue]];
//    NSString *eventDateString = [eventDate stringWithFormat:@"EEEE, MMMM d"];
    
    // Attributed message
    NSString *names = [fbNames componentsJoinedByString:@", "];
    NSString *isOrAre = ([fbNames count] > 1) ? @"are" : @"is";
    NSString *message = [NSString stringWithFormat:@"%@ %@ going to %@", names, isOrAre, [where objectForKey:@"venueName"]];
    
    [self.messageLabel setText:message afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange userNameRange = [[mutableAttributedString string] rangeOfString:names options:NSCaseInsensitiveSearch];
        NSRange venueNameRange = [[mutableAttributedString string] rangeOfString:[where objectForKey:@"venueName"] options:NSCaseInsensitiveSearch];
//        NSRange dateRange = [[mutableAttributedString string] rangeOfString:eventDateString options:NSCaseInsensitiveSearch];
        
        
        //Color
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:userNameRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:venueNameRange];
//        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:dateRange];
        
        return mutableAttributedString;
    }];

    NSArray *friendIds = [fbIds subarrayWithRange:NSMakeRange(1, [fbIds count] - 1)];
    if (friendIds.count > 0) {
        self.facepileView.hidden = NO;
        
        NSMutableArray *faces = [NSMutableArray array];
        for (NSString *fbId in friendIds) {
            NSDictionary *face = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", fbId] forKey:@"url"];
            [faces addObject:face];
        }
        [self.facepileView loadWithFaces:faces];
    }
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSDictionary *dict = (NSDictionary *)object;
    
    NSDictionary *where = [dict objectForKey:@"where"];
    
    NSArray *attendees = [dict objectForKey:@"attendees"];
    NSMutableArray *fbNames = [NSMutableArray array];
    NSMutableArray *fbIds = [NSMutableArray array];
    for (NSDictionary *attendee in attendees) {
        [fbNames addObject:[attendee objectForKey:@"fbName"]];
        [fbIds addObject:[attendee objectForKey:@"fbId"]];
    }
//    NSString *creatorId = [[attendees objectAtIndexOrNil:0] objectForKey:@"fbId"];
    
    CGFloat height = 0.0;
    CGFloat width = 268.0 - MARGIN * 2;
    width -= IMAGE_SIZE + MARGIN;
    
//    NSDate *eventDate = [NSDate dateWithMillisecondsSince1970:[[dict objectForKey:@"timestamp"] doubleValue]];
//    NSString *eventDateString = [eventDate stringWithFormat:@"EEEE, MMMM d"];
    
    NSString *names = [fbNames componentsJoinedByString:@", "];
    NSString *isOrAre = ([fbNames count] > 1) ? @"are" : @"is";
    NSString *message = [NSString stringWithFormat:@"%@ %@ going to %@", names, isOrAre, [where objectForKey:@"venueName"]];
    CGSize labelSize = [PSStyleSheet sizeForText:message width:width style:@"eventMessageLabel"];
    height += labelSize.height;
    
    height = MAX(IMAGE_SIZE, height);
    
    NSArray *friendIds = [fbIds subarrayWithRange:NSMakeRange(1, [fbIds count] - 1)];
    if (friendIds.count > 0) {
        // has facepile
        NSMutableArray *faces = [NSMutableArray array];
        for (NSString *fbId in friendIds) {
            NSDictionary *face = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", fbId] forKey:@"url"];
            [faces addObject:face];
        }
        CGFloat facepileHeight = [PSFacepileView heightWithFaces:faces];
        height += facepileHeight;
    }
    
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
