//
//  WelcomeViewController.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (nonatomic, strong) PSTextField *emailField;
@property (nonatomic, strong) PSTextField *passwordField;

@end

@implementation WelcomeViewController


#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        
        self.title = @"Welcome";
    }
    return self;
}

#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return BASE_BG_COLOR;
}

- (UIColor *)rowBackgroundColorForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    return BASE_BG_COLOR;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    CGFloat top = 16.0;
    CGFloat left = 16.0;
    CGFloat width = self.contentView.width - left * 2;
    
    PSTextField *emailField = [[PSTextField alloc] initWithFrame:CGRectMake(left, top, width, 37.0) withMargins:CGSizeMake(8, 8)];
    self.emailField = emailField;
    emailField.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
    emailField.font = [PSStyleSheet fontForStyle:@"leadDarkField"];
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.placeholder = @"E-mail";
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.contentView addSubview:emailField];
    
    top = emailField.bottom + 8.0;
    
    PSTextField *passwordField = [[PSTextField alloc] initWithFrame:CGRectMake(left, top, width, 37.0) withMargins:CGSizeMake(8, 8)];
    self.passwordField = passwordField;
    passwordField.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
    passwordField.font = [PSStyleSheet fontForStyle:@"leadDarkField"];
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.placeholder = @"Password";
    passwordField.secureTextEntry = YES;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.contentView addSubview:passwordField];
    
    top = passwordField.bottom + 8.0;
    
    CGFloat buttonWidth = floorf((width - 8.0) / 2.0);
    
    UIButton *signIn = [UIButton buttonWithFrame:CGRectMake(left, top, buttonWidth, 32.0) andStyle:@"lightButton" target:self action:@selector(leftAction)];
    [signIn setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [signIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.contentView addSubview:signIn];
    
    left = signIn.right + 8.0;
    
    UIButton *signUp = [UIButton buttonWithFrame:CGRectMake(left, top, buttonWidth, 32.0) andStyle:@"darkButton" target:self action:@selector(rightAction)];
    [signUp setBackgroundImage:[[UIImage imageNamed:@"ButtonBlue"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
    [signUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.contentView addSubview:signUp];
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
}

- (void)setupFooter {
    [super setupFooter];
}

#pragma mark - Actions

- (void)leftAction {
    // Sign In
    
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length > 0 && password.length > 0) {
        [[UserManager sharedManager] loginWithEmail:email password:password completionHandler:^(NSError *error, NSDictionary *user) {
            if (!error && user) {
                
            } else {
                
            }
        }];
    }
}

- (void)centerAction {
    
}

- (void)rightAction {
    PSPDFAlertView *av = [[PSPDFAlertView alloc] initWithTitle:@"Not Implemented"];
    [av setCancelButtonWithTitle:@"Ok" block:NULL];
    [av show];
    
    
    // Sign Up
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length > 0 && password.length > 0) {
        [[UserManager sharedManager] signupWithEmail:email password:password completionHandler:^(NSError *error, NSDictionary *user) {
            if (!error && user) {
                
            } else {
                
            }
        }];
    }
}

@end
