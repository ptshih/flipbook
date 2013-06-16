//
//  NewLeadViewController.m
//  Celery
//
//  Created by Peter Shih on 4/17/13.
//
//

#import "NewLeadViewController.h"

#import "CountryPicker.h"

@interface NewLeadViewController () <UITextFieldDelegate, CountryPickerDelegate>

@property (nonatomic, strong) NSString *productId;

@property (nonatomic, strong) NSMutableArray *textFields;

@property (nonatomic, assign) UITextField *activeField;
@property (nonatomic, assign) UITextField *emailField;
@property (nonatomic, assign) UITextField *nameField;
@property (nonatomic, assign) UITextField *zipField;
@property (nonatomic, assign) UITextField *countryField;
@end

@implementation NewLeadViewController

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
        self.shouldShowFooter = NO;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.shouldShowNullView = NO;
        
        self.textFields = [NSMutableArray array];
        
        self.tableViewStyle = UITableViewStyleGrouped;
        
        self.productId = @"5149055816b6139690000002";
        
        self.title = @"New Lead";
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self.textFields firstObject] becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -

- (void)resignKeyboard {
    [self.view endEditing:YES];
}

- (void)prevNext:(UISegmentedControl *)control {
    NSInteger idx = [self.textFields indexOfObject:self.activeField];
    
    if (control.selectedSegmentIndex == 0) {
        // Prev
        NSInteger newIdx = (idx - 1) >= 0 ? (idx - 1) : 0;
        [[self.textFields objectAtIndex:newIdx] becomeFirstResponder];
    } else if (control.selectedSegmentIndex == 1) {
        // Next
        NSInteger newIdx = (idx + 1) <= self.textFields.count - 1 ? (idx + 1) : self.textFields.count - 1;
        [[self.textFields objectAtIndex:newIdx] becomeFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger idx = [self.textFields indexOfObject:self.activeField];
    
    if (idx == self.textFields.count - 1) {
        [textField resignFirstResponder];
        return YES;
    }
    
    NSInteger newIdx = (idx + 1) <= self.textFields.count - 1 ? (idx + 1) : self.textFields.count - 1;
    [[self.textFields objectAtIndex:newIdx] becomeFirstResponder];
    
    return YES;
}

#pragma mark - Picker

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code {
    self.activeField.text = name;
    [self.activeField resignFirstResponder];
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    
//}
//
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    return 0;
//}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    self.viewToAdjustForKeyboard = self.tableView;
    
    CGFloat top = 16.0;
    CGFloat left = 16.0;
    CGFloat width = self.contentView.width - left * 2;
    
    // Toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Previous", @"Next", nil]];
    segmentControl.momentary = YES;
    [segmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    [segmentControl addTarget:self action:@selector(prevNext:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *prevNextButton = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:prevNextButton, flexButton, doneButton, nil];

    [toolbar setItems:itemsArray];
    
    // Picker
    CountryPicker *pickerView = [[CountryPicker alloc] init];
    pickerView.delegate = self;
    [pickerView setWithLocale:[NSLocale currentLocale]];
    
    // Fields
    UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectZero];
    emailField.delegate = self;
    emailField.frame = CGRectMake(left, top, width, 30.0);
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.placeholder = @"Your Email";
    emailField.inputAccessoryView = toolbar;
    emailField.returnKeyType = UIReturnKeyNext;
    self.emailField = emailField;
    
    top = emailField.bottom + 8.0;
    
    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectZero];
    nameField.delegate = self;
    nameField.frame = CGRectMake(left, top, width, 30.0);
    nameField.keyboardType = UIKeyboardTypeAlphabet;
    nameField.placeholder = @"Your Name";
    nameField.inputAccessoryView = toolbar;
    nameField.returnKeyType = UIReturnKeyNext;
    self.nameField = nameField;
    
    top = nameField.bottom + 8.0;
    
    UITextField *zipField = [[UITextField alloc] initWithFrame:CGRectZero];
    zipField.delegate = self;
    zipField.frame = CGRectMake(left, top, width, 30.0);
    zipField.keyboardType = UIKeyboardTypeNumberPad;
    zipField.placeholder = @"Your Zip / Postal Code";
    zipField.inputAccessoryView = toolbar;
    zipField.returnKeyType = UIReturnKeyDone;
    self.zipField = zipField;

    top = zipField.bottom + 8.0;
    
    UITextField *countryField = [[UITextField alloc] initWithFrame:CGRectZero];
    countryField.delegate = self;
    countryField.frame = CGRectMake(left, top, width, 30.0);
    countryField.text = [[CountryPicker countryNamesByCode] objectForKey:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
    countryField.inputAccessoryView = toolbar;
    countryField.inputView = pickerView;
    self.countryField = countryField;

    
    [self.textFields addObject:emailField];
    [self.textFields addObject:nameField];
    [self.textFields addObject:zipField];
    [self.textFields addObject:countryField];
    
    [self.contentView addSubview:emailField];
    [self.contentView addSubview:nameField];
    [self.contentView addSubview:zipField];
    [self.contentView addSubview:countryField];

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
}

#pragma mark - Actions

- (void)leftAction {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)centerAction {
}

- (void)rightAction {
    NSString *email = self.emailField.text;
    NSString *name = self.nameField.text;
    NSString *zip = self.zipField.text;
    NSString *country = self.countryField.text;
    
    if (email.length == 0 || zip.length == 0 || country.length == 0) {
        PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Empty Field!"];
        [av setCancelButtonWithTitle:@"Ok" block:NULL];
        [av show];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *lead = [NSMutableDictionary dictionary];
    [lead setObject:[[UserManager sharedManager] userId] forKey:@"seller_id"];
    [lead setObject:@"mobile-command-center" forKey:@"slug"];
    [lead setObject:@"Mobile Command Center" forKey:@"product_name"];
    [lead setObject:email forKey:@"email"];
    if (name && name.length > 0) [lead setObject:name forKey:@"name"];
    [lead setObject:zip forKey:@"zip"];
    [lead setObject:country forKey:@"country"];
    
    [parameters setObject:lead forKey:@"lead"];
    
    NSString *authString = [NSString stringWithFormat:@"%@:%@", [[UserManager sharedManager] accessToken], [[UserManager sharedManager] secret]];
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"application/json" forKey:@"Content-Type"];
    [headers setObject:authValue forKey:@"Authorization"];
    
    NSString *URLPath = [NSString stringWithFormat:@"%@/leads", API_BASE_URL];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:headers parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession cachePriority:PSURLCachePriorityHigh usingCache:NO completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [self errorAction];
        } else {
            // Parse apiResponse
            id apiResponse = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            
            if (apiResponse && [apiResponse isKindOfClass:[NSDictionary class]]) {
                [self leftAction];
            } else {
                [self errorAction];
            }
        }
    }];
}

- (void)errorAction {
    PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"There was an Error!"];
    [av setCancelButtonWithTitle:@"Ok" block:NULL];
    [av show];
}

@end
