//
//  AppDelegate.h
//  Mosaic
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PSNavigationController *navigationController;
@property (nonatomic, strong) NSDate *backgroundDate;
@property (nonatomic, strong) NSDate *foregroundDate;
@property (nonatomic, assign) BOOL shouldReloadInterface;

- (void)pushVenueWithId:(NSString *)venueId;

@end
