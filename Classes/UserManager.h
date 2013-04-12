//
//  UserManager.h
//  Vip
//
//  Created by Peter Shih on 9/17/12.
//
//

#import <Foundation/Foundation.h>

#define kUserManagerDidLoginNotification @"kUserManagerDidLoginNotification"

@interface UserManager : NSObject

+ (id)sharedManager;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(NSError *error, NSDictionary *user))completionHandler;
- (void)signupWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(NSError *error, NSDictionary *user))completionHandler;

- (NSString *)accessToken;
- (NSString *)secret;

@end
