//
//  PaypalWebViewController.h
//  Celery
//
//  Created by Peter Shih on 5/10/13.
//
//

#import "PSWebViewController.h"

@protocol PaypalWebViewControllerDelegate;

@interface PaypalWebViewController : PSWebViewController

@property (nonatomic, unsafe_unretained) id <PaypalWebViewControllerDelegate> delegate;

- (void)setEmail:(NSString *)email;
- (void)setPassword:(NSString *)password;
- (void)clickLogin;
- (void)clickAccept;
- (void)clickCancel;
- (NSString *)getConsent1;
- (NSString *)getConsent2;

@end

@protocol PaypalWebViewControllerDelegate <NSObject>

@optional
- (void)paypalWebViewControllerDidBeginLogin:(PaypalWebViewController *)paypalWebViewController;
- (void)paypalWebViewControllerDidBeginApprove:(PaypalWebViewController *)paypalWebViewController;
- (void)paypalWebViewDidSucceed;
- (void)paypalWebViewDidFail;

@end