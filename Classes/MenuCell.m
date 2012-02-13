//
//  MenuCell.m
//  Phototime
//
//  Created by Peter on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCell.h"
#import "PSCachedImageView.h"
#import "Timeline.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return 48.0;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    Timeline *t = (Timeline *)object;
    self.textLabel.text = [NSString stringWithFormat:@"%@ - %@", t.id, t.ownerId];
    self.detailTextLabel.text = t.members;
}

@end