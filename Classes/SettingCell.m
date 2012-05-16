//
//  SettingCell.m
//  Lunchbox
//
//  Created by Peter Shih on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingCell.h"

#define kPostToFacebookTag 9001

#define MARGIN 8.0

@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        [PSStyleSheet applyStyle:@"h2Label" forLabel:self.textLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryView = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
//    CGFloat left = MARGIN;
//    CGFloat top = MARGIN;
//    CGFloat width = self.contentView.width - MARGIN * 2;
//    CGSize labelSize = CGSizeZero;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSString *)object atIndexPath:(NSIndexPath *)indexPath {
    self.textLabel.text = object;
    
    if ([object isEqualToString:@"Post to Facebook"]) {
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectZero];
        s.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPostToFacebook"];
        s.tag = kPostToFacebookTag;
        [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = s;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat height = 44.0;
    
    return height;
}


- (void)switchChanged:(UISwitch *)s {
    if (s.tag == kPostToFacebookTag) {
        [[NSUserDefaults standardUserDefaults] setBool:s.on forKey:@"shouldPostToFacebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
