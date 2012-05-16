//
//  InfoPopoverView.m
//  Lunchbox
//
//  Created by Peter Shih on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoPopoverView.h"

@interface InfoPopoverView () <UIGestureRecognizerDelegate>

@end

@implementation InfoPopoverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.5;
        overlayView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        gr.delegate = self;
        [overlayView addGestureRecognizer:gr];
        [self addSubview:overlayView];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InfoPopover"]];
        bg.center = self.center;
        bg.top = 44.0;
        [self addSubview:bg];
        
        UILabel *infoLabel = [UILabel labelWithStyle:@"infoPopoverLabel"];
        infoLabel.text = @"Tap the Navigation Bar to Start!\r\n\r\nYou can now tell your friends that you plan on going somewhere later.\r\n\r\nYou can also join your friends who have already made plans.";
        infoLabel.frame = UIEdgeInsetsInsetRect(bg.bounds, UIEdgeInsetsMake(30, 30, 42, 30));
        [bg addSubview:infoLabel];
        
    }
    return self;
}

- (void)dismiss {
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
