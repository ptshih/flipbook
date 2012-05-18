//
//  VenueMiniView.m
//  Lunchbox
//
//  Created by Peter Shih on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueMiniView.h"

@interface VenueMiniView ()

@property (nonatomic, copy) NSDictionary *venueDict;

@end

@implementation VenueMiniView

@synthesize
venueDict = _venueDict;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.venueDict = dictionary;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

@end
