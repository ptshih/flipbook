//
//  PaypalViewController.m
//  Celery
//
//  Created by Peter Shih on 5/10/13.
//
//

#import "PaypalViewController.h"
#import "PaypalWebViewController.h"
#import "PaypalNativeViewController.h"

//#import "PayPalMobile.h"

@interface PaypalViewController () <PaypalWebViewControllerDelegate>

@property (nonatomic, copy) NSMutableDictionary *order;

@property (nonatomic, strong) UILabel *orderLabel;

@end

@implementation PaypalViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Paypal";
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = NO;
        
        self.headerHeight = 44.0;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return TEXTURE_LIGHT_SKETCH;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load
    [self loadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.slidingViewController.underRightViewController = nil;
    
    [self.headerView addGestureRecognizer:self.slidingViewController.panGesture];
    self.view.layer.shadowOpacity = 0.75;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    PayPalPayment *payment = [[PayPalPayment alloc] init];
//    payment.amount = [[NSDecimalNumber alloc] initWithString:@"39.95"];
//    payment.currencyCode = @"USD";
//    payment.shortDescription = @"Awesome sawse";
//    
//    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
//    
//    NSString *payerId = @"ptshih@mail.ru";
//    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:@"AbGMIxBlI-Gv1dq376K3g4Pl1Y_0KS6pzptiLoBk4coqnHZDei10M9hj46zf" receiverEmail:@"brian@airbriteinc.com" payerId:payerId payment:payment delegate:self];
//    
//    [self presentViewController:paymentViewController animated:YES completion:nil];
}

//- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment {
//    [self dismissViewControllerAnimated:YES completion:nil];    
//}
//
//- (void)payPalPaymentDidCancel {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)launchPaypal {
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
    id apiResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSLog(@"%@", apiResponse);
    
    self.order = [NSMutableDictionary dictionaryWithDictionary:[apiResponse objectForKey:@"order"]];
    
    NSString *sandboxUrl = [NSString stringWithFormat:@"https://www.sandbox.paypal.com/webapps/adaptivepayment/flow/preapproval?expType=mini&preapprovalkey=%@", [apiResponse objectForKey:@"preapprovalKey"]];
    
    
    PaypalWebViewController *vc = [[PaypalWebViewController alloc] initWithURLPath:sandboxUrl title:@"paypal"];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)launchPaypalNative {
    PaypalNativeViewController *vc = [[PaypalNativeViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - Paypal Webview Controller Delegate

- (void)paypalWebViewControllerDidBeginLogin:(PaypalWebViewController *)paypalWebViewController {
    NSLog(@"login");
    [paypalWebViewController setEmail:@"buyer1@trycelery.com"];
    [paypalWebViewController setPassword:@"airbrite1"];
}

- (void)paypalWebViewControllerDidBeginApprove:(PaypalWebViewController *)paypalWebViewController {
    NSLog(@"approve");
}

- (void)paypalWebViewDidSucceed {
    NSLog(@"succeeded");
    self.orderLabel.text = [NSString stringWithFormat:@"Order ID: %@", [self.order objectForKey:@"id"]];
    [self.orderLabel sizeToFit];
    self.orderLabel.center = self.contentView.center;
}

- (void)paypalWebViewDidFail {
    NSLog(@"cancelled");
}


#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];

    UIButton *paymentButton = [UIButton buttonWithFrame:CGRectMake(8, 8, self.contentView.width - 16, 37.0) andStyle:@"lightButton" target:self action:@selector(launchPaypal)];
    [paymentButton setTitle:@"Paypal Webview Flow" forState:UIControlStateNormal];
    [paymentButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [self.contentView addSubview:paymentButton];
    
    UIButton *nativeButton = [UIButton buttonWithFrame:CGRectMake(8, 64, self.contentView.width - 16, 37.0) andStyle:@"lightButton" target:self action:@selector(launchPaypalNative)];
    [nativeButton setTitle:@"Paypal Native Flow" forState:UIControlStateNormal];
    [nativeButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [self.contentView addSubview:nativeButton];
    
    UILabel *l = [UILabel labelWithText:@"Place a test order first" style:@"h1DarkLabel"];
    [l sizeToFit];
    l.center = self.contentView.center;
    [self.contentView addSubview:l];
    self.orderLabel = l;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconMenuWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconSearchWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

- (void)setupFooter {
    [super setupFooter];
}

#pragma mark - Actions

- (void)leftAction {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)centerAction {
}

- (void)rightAction {
    PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Coming Soon"];
    [av setCancelButtonWithTitle:@"Ok" block:NULL];
    [av show];
}

#pragma mark - Data Source

- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)loadMoreDataSource {
    [super loadMoreDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

- (void)dataSourceDidLoadMore {
    [super dataSourceDidLoadMore];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    
    
    [self dataSourceDidLoad];
}

@end
