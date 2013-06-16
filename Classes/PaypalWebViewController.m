//
//  PaypalWebViewController.m
//  Celery
//
//  Created by Peter Shih on 5/10/13.
//
//

#import "PaypalWebViewController.h"

@interface PaypalWebViewController () <UIWebViewDelegate>

@end

@implementation PaypalWebViewController

- (id)initWithURLPath:(NSString *)URLPath title:(NSString *)title {
    self = [super initWithURLPath:URLPath title:title];
    if (self) {
        self.shouldShowFooter = NO;
    }
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    // User clicked cancel
    if ([request.URL.absoluteString rangeOfString:@"closewindow"].location != NSNotFound) {
        [self cancelled];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    
    NSString *headlineText = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('headlineText').innerHTML"];
    
    if ([headlineText isEqualToString:@"Log in to your PayPal account"]) {
        [self.delegate paypalWebViewControllerDidBeginLogin:self];
    } else if ([headlineText isEqualToString:@"Sign up for future payments"]) {
        [self.delegate paypalWebViewControllerDidBeginApprove:self];
    } else if ([headlineText isEqualToString:@"Thank you for signing up"]) {
        [self succeeded];
    }
    
}

#pragma mark - DOM

- (void)setEmail:(NSString *)email {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('email').value = '%@'", email]];
}

- (void)setPassword:(NSString *)password {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('password').value = '%@'", password]];
}

- (void)clickLogin {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login').click()"];
}

- (void)clickAccept {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('_eventId_submit').click()"];
}

- (void)clickCancel {
    
}

- (NSString *)getConsent1 {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('consent1').getElementsByTagName('p')[0].innerHTML"];
}

- (NSString *)getConsent2 {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('consent2').getElementsByTagName('p')[0].innerHTML"];
}

#pragma mark - Actions

- (void)succeeded {
    [self.delegate paypalWebViewDidSucceed];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelled {
    [self.delegate paypalWebViewDidFail];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftAction {
    [self cancelled];
}

@end
