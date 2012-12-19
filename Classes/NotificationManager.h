//
//  NotificationManager.h
//  Grid
//
//  Created by Peter Shih on 5/15/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotificationManagerDidUpdate @"NotificationManagerDidUpdate"

typedef void (^NotificationManagerCompletionBlock)(NSArray *notifications, NSError *error);

@interface NotificationManager : NSObject

@property (nonatomic, strong) NSMutableArray *notifications;

+ (id)sharedManager;

- (void)downloadNotificationsWithCompletionBlock:(NotificationManagerCompletionBlock)completionBlock;

@end
