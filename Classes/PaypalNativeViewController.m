//
//  PaypalNativeViewController.m
//  Celery
//
//  Created by Peter Shih on 5/13/13.
//
//

#import "PaypalNativeViewController.h"
#import "PaypalWebViewController.h"

enum {
    PaypalStepLoading = 0,
    PaypalStepLogin = 1,
    PaypalStepApprove = 2,
    PaypalStepSuccess = 3
};
typedef uint32_t PaypalStep;

@interface PaypalNativeViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSMutableDictionary *order;

@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *paypalButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) PSTextField *emailField;
@property (nonatomic, strong) PSTextField *passwordField;

@property (nonatomic, assign) PaypalStep step;
@property (nonatomic, assign) NSInteger frameCount;

@end

@implementation PaypalNativeViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Paypal";
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = YES;
        
        self.headerHeight = 44.0;
        
        self.step = PaypalStepLoading;
        self.frameCount = 0;
    }
    return self;
}

#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return TEXTURE_LIGHT_SKETCH;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDataSource];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    // Invisible WebView
    [self setupWebView];
    
    // Consent
    self.messageLabel = [UILabel labelWithStyle:@"h6DarkLabel"];
    [self.contentView addSubview:self.messageLabel];
    
    // Login
    PSTextField *emailField = [[PSTextField alloc] initWithFrame:CGRectZero withMargins:CGSizeMake(8, 8)];
    self.emailField = emailField;
    emailField.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
    emailField.font = [PSStyleSheet fontForStyle:@"leadDarkField"];
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.placeholder = @"E-mail";
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.contentView addSubview:emailField];
    
    
    PSTextField *passwordField = [[PSTextField alloc] initWithFrame:CGRectZero withMargins:CGSizeMake(8, 8)];
    self.passwordField = passwordField;
    passwordField.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
    passwordField.font = [PSStyleSheet fontForStyle:@"leadDarkField"];
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.placeholder = @"Password";
    passwordField.secureTextEntry = YES;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.contentView addSubview:passwordField];
    
    
    self.paypalButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"lightButton" target:nil action:nil];
    [self.paypalButton setTitle:@"Loading..." forState:UIControlStateNormal];
    [self.paypalButton setEnabled:NO];
    [self.paypalButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [self.contentView addSubview:self.paypalButton];
    
    self.cancelButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"lightButton" target:nil action:nil];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelButton];
}

- (void)relayoutSubviews {
    CGFloat top = 16.0;
    CGFloat left = 16.0;
    CGFloat width = self.contentView.width - left * 2;
    
    // Message
    if (self.messageLabel.text.length > 0) {
        self.messageLabel.hidden = NO;
        CGSize labelSize = [self.messageLabel sizeForLabelInWidth:width];
        self.messageLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
        top = self.messageLabel.bottom + 8.0;
    } else {
        self.messageLabel.hidden = YES;
    }
    
    
    if (self.step == PaypalStepLogin) {
        self.cancelButton.hidden = NO;
        
        self.emailField.frame = CGRectMake(left, top, width, 37.0);
        top = self.emailField.bottom + 8.0;
        self.passwordField.frame = CGRectMake(left, top, width, 37.0);
        top = self.passwordField.bottom + 8.0;
        self.paypalButton.frame = CGRectMake(left, top, width, 37.0);
        top = self.paypalButton.bottom + 8.0;
        self.cancelButton.frame = CGRectMake(left, top, width, 37.0);
    } else if (self.step == PaypalStepApprove) {
        self.cancelButton.hidden = NO;
        self.emailField.hidden = YES;
        self.passwordField.hidden = YES;
        
        self.paypalButton.frame = CGRectMake(left, top, width, 37.0);
        top = self.paypalButton.bottom + 8.0;
        self.cancelButton.frame = CGRectMake(left, top, width, 37.0);
    } else if (self.step == PaypalStepSuccess) {
        self.cancelButton.hidden = YES;
        
        self.paypalButton.frame = CGRectMake(left, top, width, 37.0);
    }
}

- (void)setupHeader {
    [super setupHeader];
    self.headerView.backgroundColor = [self baseBackgroundColor];
    
    UIImageView *ppLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PayPalLogo"]];
    ppLogo.contentMode = UIViewContentModeScaleAspectFit;
    ppLogo.frame = CGRectMake(0, 4, self.headerView.width, 36);
    [self.headerView addSubview:ppLogo];
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinnerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.spinnerView.frame = self.rightButton.frame;
    self.spinnerView.hidesWhenStopped = YES;
    [self.headerView addSubview:self.spinnerView];
}

- (void)setupFooter {
    [super setupFooter];
}

- (void)loadDataSource {
    [super loadDataSource];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        NSDictionary *order = @{@"products": @[@{@"slug": @"demo", @"quantity": @"1"}], @"seller_id": @"5190861b09b9e50000000003"};
        [parameters setObject:order forKey:@"order"];
        
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        NSString *authString = [NSString stringWithFormat:@"%@:%@", [[UserManager sharedManager] accessToken], [[UserManager sharedManager] secret]];
        NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
        [headers setObject:authValue forKey:@"Authorization"];
        [headers setObject:@"application/json" forKey:@"Content-Type"];
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/paypal/preapproval", API_BASE_URL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:headers parameters:parameters];
        
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (data && !error) {
            id apiResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@", apiResponse);
            
            self.order = [NSMutableDictionary dictionaryWithDictionary:[apiResponse objectForKey:@"order"]];
            
            NSString *sandboxUrl = [NSString stringWithFormat:@"https://www.sandbox.paypal.com/webapps/adaptivepayment/flow/preapproval?expType=mini&preapprovalkey=%@", [apiResponse objectForKey:@"preapprovalKey"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:sandboxUrl]]];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismiss];
            });
        }
    });
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    self.webView.alpha = 0.0;
    self.webView.delegate = self;
    [self.contentView addSubview:self.webView];
}

#pragma mark - Actions

- (void)leftAction {
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)centerAction {
}

- (void)rightAction {
//    PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Coming Soon"];
//    [av setCancelButtonWithTitle:@"Ok" block:NULL];
//    [av show];
}

- (void)login {
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    if (email.length > 0 && password.length > 0) {
        [self.paypalButton setTitle:@"Loading..." forState:UIControlStateNormal];
        [self.paypalButton setEnabled:NO];
        [self setEmail:email];
        [self setPassword:password];
        [self clickLogin];
        
        self.cancelButton.hidden = YES;
        [self setEditing:NO animated:YES];
    }
}

- (void)approve {
    [self.paypalButton setTitle:@"Loading..." forState:UIControlStateNormal];
    [self.paypalButton setEnabled:NO];
    [self clickApprove];
    
    self.cancelButton.hidden = YES;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)clickApprove {
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

- (NSString *)getMemo {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('preappr-memo')[0].getElementsByTagName('span')[1].innerHTML"];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // User clicked cancel
    if ([request.URL.absoluteString rangeOfString:@"closewindow"].location != NSNotFound) {
        NSLog(@"cancelled");
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.frameCount == 0) {
        [self.spinnerView startAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:PSNetworkingOperationDidStartNotification object:nil];
    }
    self.frameCount++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    if (self.frameCount == 0) {
        [self.spinnerView stopAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:PSNetworkingOperationDidFinishNotification object:nil];
    }
    
    NSString *headlineText = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('headlineText').innerHTML"];
    
    if ([headlineText isEqualToString:@"Log in to your PayPal account"]) {
        NSLog(@"login");
        [self dataSourceDidLoad];
        self.step = PaypalStepLogin;

        self.messageLabel.text = @"Log in to your PayPal account (DEMO E-mail: buyer1@trycelery.com, Password: airbrite1)";
        [self relayoutSubviews];
        [self.paypalButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.paypalButton setEnabled:YES];
        [self.paypalButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.paypalButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    } else if ([headlineText isEqualToString:@"Sign up for future payments"]) {
        NSLog(@"approve");
        self.step = PaypalStepApprove;
        
        self.messageLabel.text = [NSString stringWithFormat:@"%@\r\n\r\n%@", [self getMemo], [self getConsent1]];
        [self relayoutSubviews];
        [self.paypalButton setTitle:@"Approve" forState:UIControlStateNormal];
        [self.paypalButton setEnabled:YES];
        [self.paypalButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.paypalButton addTarget:self action:@selector(approve) forControlEvents:UIControlEventTouchUpInside];
    } else if ([headlineText isEqualToString:@"Thank you for signing up"]) {
        NSLog(@"succeeded");
        self.step = PaypalStepSuccess;
        
        self.messageLabel.text = [NSString stringWithFormat:@"Thank you for your order. Your order number is: %@", [self.order objectForKey:@"id"]];
        [self relayoutSubviews];
        [self.paypalButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [self.paypalButton setEnabled:YES];
        [self.paypalButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.paypalButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.frameCount--;
    
    if (self.frameCount == 0) {
        [self.spinnerView stopAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:PSNetworkingOperationDidFinishNotification object:nil];
    }
}

@end
