//
//  GridViewController.m
//  Grid
//
//  Created by Peter Shih on 12/14/12.
//
//

#import "GridViewController.h"
#import "PageViewController.h"
#import "PSGridView.h"

#import "PSYouTubeView.h"

@interface GridViewController ()

@property (nonatomic, strong) PSGridView *gridView;

@end

@implementation GridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
//        self.headerRightWidth = 0.0;
        
        self.limit = 25;
    }
    return self;
}

#pragma mark - View Config

- (UIColor *)baseBackgroundColor {
    return TEXTURE_BLACK_SQUARES;
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen:{
            // Session opened
            NSLog(@"FB Session Access Token: %@", session.accessToken);
            break;
        }
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        // can include any of the "publish" or "manage" permissions
//        NSArray *publishPermissions = [NSArray arrayWithObjects:@"publish_actions", nil];
//        //
//        [[FBSession activeSession] reauthorizeWithPublishPermissions:publishPermissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
//            /* handle success + failure in block */
//        }];
    }
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // See if we have a valid token for the current state.
    NSArray *readPermissions = [NSArray arrayWithObjects:@"email", @"user_photos", @"friends_photos", nil];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // To-do, show logged in view
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
    } else {
        // No, display the login page.
        [FBSession openActiveSessionWithReadPermissions:readPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"igAccessToken"]) {
        // Sample response: http://your-redirect-uri#access_token=2275353.f59def8.40572794d9de40ccb360b6c54fa865dd
        NSString *igClientId = @"933e9c75ab0c432fbe152fd3d645c4e8";
        NSString *igRedirectUri = @"ig933e9c75ab0c432fbe152fd3d645c4e8://authorize";
        NSDictionary *params = @{@"client_id" : igClientId, @"redirect_uri" : igRedirectUri, @"response_type" : @"token"};
        NSString *qs = PSQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding);
        NSString *igPath = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?%@", qs];
        
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:igPath]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if (![[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] linkFromController:self];
//    }
    

}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.gridView = [[PSGridView alloc] initWithFrame:self.contentView.bounds dictionary:nil];
    self.gridView.autoresizingMask = ~UIViewAutoresizingNone;
    self.gridView.parentViewController = self;
    
    [self.contentView addSubview:self.gridView];
    
    
//    PSYouTubeView *v = [[PSYouTubeView alloc] initWithFrame:self.contentView.bounds];
//    [v loadYouTubeWithSource:@"http://www.youtube.com/embed/9bZkp7q19f0" contentSize:v.frame.size];
//    [self.contentView addSubview:v];
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconShareWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    //    self.rightButton.userInteractionEnabled = NO;
}

#pragma mark - Actions

- (void)leftAction {
    [self.gridView toggleTargetMode];
}

- (void)centerAction {
}

- (void)rightAction {
    NSDictionary *dict = [self.gridView exportData];
    NSLog(@"export: %@", dict);
    
    PageViewController *vc = [[PageViewController alloc] initWithGridDictionary:dict];
    [self.navigationController pushViewController:vc animated:YES];
    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//    NSLog(@"json: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation != UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
