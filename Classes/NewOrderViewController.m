//
//  NewOrderViewController.m
//  Celery
//
//  Created by Peter Shih on 4/17/13.
//
//

#import "NewOrderViewController.h"

#import "CardIO.h"

@interface NewOrderViewController () <CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) NSString *productId;

@property (nonatomic, strong) NSMutableDictionary *paymentDict;

@property (nonatomic, strong) UIButton *paymentButton;

@end

@implementation NewOrderViewController

#pragma mark - Init

- (id)initWithProductId:(NSString *)productId {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.productId = productId;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.shouldShowHeader = YES;
        self.shouldShowFooter = YES;
        
        self.headerHeight = 44.0;
        self.footerHeight = 44.0;
        
        self.shouldShowNullView = NO;
        
        self.tableViewStyle = UITableViewStyleGrouped;
        
//        self.textFields = [NSMutableArray array];
        
        self.productId = @"5149055816b6139690000002";
        
        self.paymentDict = [NSMutableDictionary dictionary];
        
        self.title = @"New Order";
    }
    return self;
}

#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return BASE_BG_COLOR;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[self.textFields firstObject] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    self.viewToAdjustForKeyboard = self.tableView;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconXWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconCheckWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
}

- (void)setupFooter {
    [super setupFooter];
    
    UIButton *paymentButton = [UIButton buttonWithFrame:CGRectInset(self.footerView.bounds, 8, 4) andStyle:@"lightButton" target:self action:@selector(scanCard)];
    self.paymentButton = paymentButton;
    [paymentButton setTitle:@"Scan or Enter Card" forState:UIControlStateNormal];
    [paymentButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    
    [self.footerView addSubview:paymentButton];
}

#pragma mark - Actions

- (void)scanCard {
    CardIOPaymentViewController *vc = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    vc.appToken = @"a4027397a2fa41ebb37e4a33cc7b8c9e";
    [self presentViewController:vc animated:YES completion:NULL];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [paymentViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %02i/%i, cvv: %@.", info.cardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    // Use the card info...
    [self.paymentDict setObject:info.cardNumber forKey:@"card_number"];
    [self.paymentDict setObject:[NSString stringWithFormat:@"%02d", info.expiryMonth] forKey:@"card_exp_month"];
    [self.paymentDict setObject:[NSString stringWithFormat:@"%d", info.expiryYear] forKey:@"card_exp_year"];
    [self.paymentDict setObject:info.cvv forKey:@"card_cvc"];
    
    
    [self.paymentButton setTitle:@"Card Entered. Rescan?" forState:UIControlStateNormal];
    [paymentViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)leftAction {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)centerAction {
}

- (void)rightAction {    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *order = [NSMutableDictionary dictionary];
    [order setObject:[[UserManager sharedManager] userId] forKey:@"seller_id"];
    [order setObject:self.productId forKey:@"product_id"];
    [order setObject:@"1" forKey:@"quantity"];
    
    // Get Buyer
    for (NSDictionary *field in [self.items objectAtIndex:0]) {
        NSString *key = [field objectForKey:@"key"];
        NSString *value = [field objectForKey:@"value"];
        NSString *placeholder = [field objectForKey:@"placeholder"];
        if (!value || value.length == 0) {
            PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Missing Field" message:placeholder];
            [av setCancelButtonWithTitle:@"Ok" block:NULL];
            [av show];
            return;
        }
        
        [order setObject:value forKey:key];
    }
    
    // Get Shipping
    for (NSDictionary *field in [self.items objectAtIndex:1]) {
        NSString *key = [field objectForKey:@"key"];
        NSString *value = [field objectForKey:@"value"];
        if (!value) {
            continue;
        }
        
        [order setObject:value forKey:key];
    }
    
    // Get Payment
    if (self.paymentDict.count > 0) {
        [order setObject:[self.paymentDict objectForKey:@"card_number"] forKey:@"card_number"];
        [order setObject:[self.paymentDict objectForKey:@"card_exp_month"] forKey:@"card_exp_month"];
        [order setObject:[self.paymentDict objectForKey:@"card_exp_year"] forKey:@"card_exp_year"];
        [order setObject:[self.paymentDict objectForKey:@"card_cvc"] forKey:@"card_cvc"];
    } else {
        PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Missing Payment" message:@"You must scan or enter a credit card."];
        [av setCancelButtonWithTitle:@"Ok" block:NULL];
        [av show];
        return;
    }
    
    // Get Payment
//    for (NSDictionary *field in [self.items objectAtIndex:1]) {
//        NSString *key = [field objectForKey:@"key"];
//        NSString *value = [field objectForKey:@"value"];
//        if (!value) {
//            continue;
//        }
//        
//        [order setObject:value forKey:key];
//    }
    
//    [order setObject:@"ptshih@mail.ru" forKey:@"buyer_email"];
//    [order setObject:@"Pedro Sanchez" forKey:@"buyer_name"];
//    [order setObject:@"123 Noob St" forKey:@"buyer_street"];
//    [order setObject:@"San Francisco" forKey:@"buyer_city"];
//    [order setObject:@"CA" forKey:@"buyer_state"];
//    [order setObject:@"94105" forKey:@"buyer_zip"];
//    [order setObject:@"US" forKey:@"buyer_country"];
    
//    [order setObject:@"4242424242424242" forKey:@"card_number"];
//    [order setObject:@"05" forKey:@"card_exp_month"];
//    [order setObject:@"2015" forKey:@"card_exp_year"];
//    [order setObject:@"123" forKey:@"card_cvc"];
    
    [parameters setObject:order forKey:@"order"];
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@", [[UserManager sharedManager] accessToken], [[UserManager sharedManager] secret]];
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"application/json" forKey:@"Content-Type"];
    [headers setObject:authValue forKey:@"Authorization"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/orders", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:headers parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [self errorActionWithError:error];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                [self leftAction];
            } else {
                [self errorActionWithError:nil];
            }
        }
    }];
}

- (void)errorActionWithError:(NSError *)error {
    NSString *message = error ? error.localizedDescription : nil;
    PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"There was an Error!" message:message];
    [av setCancelButtonWithTitle:@"Ok" block:NULL];
    [av show];
}

#pragma mark - Data Source

- (void)loadDataSource {
    [super loadDataSource];
    
    NSMutableArray *sections = [NSMutableArray array];
    
    // Buyer Info
    NSMutableArray *buyer = [NSMutableArray array];
    [buyer addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_email", @"placeholder": @"Your Email"}]];
    [buyer addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_name", @"placeholder": @"Your Full Name"}]];
    [sections addObject:buyer];
    
    // Shipping Info
    NSMutableArray *shipping = [NSMutableArray array];
    [shipping addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_street", @"placeholder": @"Street"}]];
    [shipping addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_city", @"placeholder": @"City"}]];
    [shipping addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_state", @"placeholder": @"State / Province"}]];
    [shipping addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_zip", @"placeholder": @"Zip / Postal Code"}]];
    [shipping addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"buyer_country", @"placeholder": @"Country"}]];
    [sections addObject:shipping];
    
//    NSMutableArray *payment = [NSMutableArray array];
//    [payment addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"card_number", @"enabled": @"false", @"placeholder": @"Card Number"}]];
//    [payment addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"card_exp_month", @"enabled": @"false", @"placeholder": @"Card Exp Month"}]];
//    [payment addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"card_exp_year", @"enabled": @"false", @"placeholder": @"Card Exp Year"}]];
//    [payment addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"key": @"card_cvc", @"enabled": @"false", @"placeholder": @"Card CVC"}]];
//    [sections addObject:payment];
    
    [self dataSourceShouldLoadObjects:sections animated:NO];
    [self dataSourceDidLoad];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}


#pragma mark - TableView

//- (UIView *)accessoryViewAtIndexPath:(NSIndexPath *)indexPath {
//    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DisclosureArrowGray"]];
//}

//- (UITableViewCellSelectionStyle)selectionStyleAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellSelectionStyleBlue;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 44.0)];
//        UIButton *scanButton = [UIButton buttonWithFrame:CGRectInset(headerView.bounds, 9, 6) andStyle:@"lightButton" target:self action:@selector(scanCard)];
//        [scanButton setTitle:@"Scan or Enter Card" forState:UIControlStateNormal];
//        [scanButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
//        [headerView addSubview:scanButton];
//        
//        return headerView;
//    } else {
//        return nil;
//    }
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Required";
            break;
        case 1:
            return @"Optional";
            break;
        default:
            return nil;
            break;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0.0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.0;
//}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    return [PSTextFieldCell class];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeightForObject:item atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:item atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

@end
