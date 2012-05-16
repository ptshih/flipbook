//
//  FBConnectViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBConnectViewController.h"

@interface FBConnectViewController ()

@end

@implementation FBConnectViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidBegin:) name:kPSFacebookCenterDialogDidBegin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin:) name:kPSFacebookCenterDialogDidSucceed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin:) name:kPSFacebookCenterDialogDidFail object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidBegin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidFail object:nil];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return RGBCOLOR(50, 50, 50);
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Subviews
- (void)setupSubviews {
    // Top
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60.0)];
    topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
    [self.view addSubview:topView];
    
    UILabel *logo = [UILabel labelWithText:@"Tell Your Friends" style:@"h1Label"];
    logo.textAlignment = UITextAlignmentCenter;
    logo.frame = topView.bounds;
    [topView addSubview:logo];
    
    
    
    // Middle
    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.bottom, self.view.width, 281.0)];
    midView.backgroundColor = RGBCOLOR(50, 50, 50);
    [self.view addSubview:midView];
    
    
    
    // Bottom
    UIView *botView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 119, self.view.width, 119)];
    botView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
    [self.view addSubview:botView];
    
    // Add disclaimer
    UILabel *disclaimer = [UILabel labelWithText:@"We use facebook to find your friends." style:@"fbDisclaimerLabel"];
    disclaimer.textAlignment = UITextAlignmentCenter;
    disclaimer.frame = CGRectMake(0, 10, botView.width, 20.0);
    [botView addSubview:disclaimer];
    
    // Add a login button
    UIButton *fbButton = [UIButton buttonWithFrame:CGRectMake(0, 30.0, botView.width, 59) andStyle:nil target:self action:@selector(login:)];
    [fbButton setImage:[UIImage imageNamed:@"ButtonFacebook"] forState:UIControlStateNormal];
    [fbButton setImage:[UIImage imageNamed:@"ButtonFacebookHighlighted"] forState:UIControlStateHighlighted];
    [botView addSubview:fbButton];
    
    // Add exit
    UIButton *closeButton = [UIButton buttonWithStyle:@"fbNoThanksLabel"];
    closeButton.frame = CGRectMake(0, botView.height - 30.0, botView.width, 20.0);
    [closeButton setTitle:@"No Thanks" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [botView addSubview:closeButton];
}

#pragma mark - Actions
- (void)login:(UIButton *)button {
    [[PSFacebookCenter defaultCenter] authorizeWithPermissions:FB_PERMISSIONS];
}

- (void)dismiss {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionDown animated:YES];
}

- (void)uploadAccessToken {
    // Setup the network request
    NSString *URLPath = [NSString stringWithFormat:@"%@/lunchbox/fbconnect", API_BASE_URL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[PSFacebookCenter defaultCenter] accessToken] forKey:@"fbAccessToken"];
    [parameters setObject:[NSNumber numberWithDouble:[[[PSFacebookCenter defaultCenter] expirationDate] timeIntervalSince1970]] forKey:@"fbExpirationDate"];
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:blockSelf];
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSDictionary *fbUser = (NSDictionary *)res;
            if (fbUser && [fbUser isKindOfClass:[NSDictionary class]]) {
                NSString *fbId = [fbUser objectForKey:@"fbId"];
                NSString *fbName = [fbUser objectForKey:@"fbName"];
                [[NSUserDefaults standardUserDefaults] setObject:fbId forKey:@"fbId"];
                [[NSUserDefaults standardUserDefaults] setObject:fbName forKey:@"fbName"];
                
                [blockSelf loginDidSucceed:YES];
            } else {
                [blockSelf loginDidNotSucceed];
            }
        } else {
            [blockSelf loginDidNotSucceed];
        }
    }];

}

#pragma mark - Login
- (void)loginDidSucceed:(BOOL)animated {
    [SVProgressHUD dismissWithSuccess:@"Facebook Login Succeeded"];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSucceeded object:nil];
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionDown animated:animated];
}

- (void)loginDidNotSucceed {
    [SVProgressHUD dismissWithError:@"Facebook dropped the ball, please try again."];
    [[PSFacebookCenter defaultCenter] logout];
}

#pragma mark - Notifications
- (void)fbDidBegin:(NSNotification *)note {
    [SVProgressHUD showWithStatus:@"Logging in to Facebook" maskType:SVProgressHUDMaskTypeGradient];
}

- (void)fbDidLogin:(NSNotification *)note {
    [SVProgressHUD showWithStatus:@"Logged in to Facebook" maskType:SVProgressHUDMaskTypeGradient];
    
    // Got fb access token, upload this to our server
    [self uploadAccessToken];
}

- (void)fbDidNotLogin:(NSNotification *)note {
    [SVProgressHUD showSuccessWithStatus:@"Facebook Login Cancelled"];
}

@end
