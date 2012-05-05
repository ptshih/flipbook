//
//  CheckinViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckinViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface CheckinViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) PSTextView *textView;
@property (nonatomic, strong) UIButton *addPhotoButton;
@property (nonatomic, strong) UIButton *checkinButton;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, assign) BOOL hasPhoto;

- (void)addCheckinPhoto:(NSDictionary *)checkin;
- (void)checkinSucceeded:(BOOL)didSucceed;

@end

@implementation CheckinViewController

@synthesize
popover = _popover;

@synthesize
textView = _textView,
addPhotoButton = _addPhotoButton,
checkinButton = _checkinButton,
selectedImage = _selectedImage,

venueDict = _venueDict,
webView = _webView,

hasPhoto = _hasPhoto;

#pragma mark - Init
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary; 
        
        self.shouldAddRoundedCorners = YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hasPhoto = NO;
    }
    return self;
}

- (void)viewDidUnload {
    if (self.webView) {
        self.webView.delegate = nil;
        self.webView = nil;
    }
    if (self.popover) {
        self.popover.delegate = nil;
        self.popover = nil;
    }
    self.textView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    if (self.webView) {    
        self.webView.delegate = nil;
    }
    if (self.popover) {
        self.popover.delegate = nil;
    }
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Check 4sq token
    NSString *fsAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fsAccessToken"];
    
    if (!fsAccessToken) {
        // show webview
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.top = self.headerView.bottom;
        self.webView.height -= self.headerView.height;
        self.webView.delegate = self;
        
        NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@", FS_CLIENT_ID, FS_CALLBACK_URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
        
        [self.webView loadRequest:request];
        [self.view addSubview:self.webView];
    } else {
        // don't show webview
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *fsAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fsAccessToken"];
    if (fsAccessToken) {
        [self.textView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)setupSubviews {
    [super setupSubviews];
    
    [self setupHeader];
    
    UIView *composeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, 200)];
    [self.view addSubview:composeView];
    composeView.backgroundColor = self.view.backgroundColor;
    
    self.textView = [[PSTextView alloc] initWithFrame:CGRectMake(8, 8, self.view.width - 96 - 24, 96.0)];
    [composeView addSubview:self.textView];
    self.textView.backgroundColor = composeView.backgroundColor;
    self.textView.font = [UIFont fontWithName:@"HelveticaNeueLT-MediumCond" size:16.0];
    self.textView.placeholder = @"What are you up to?";
    
    self.textView.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.masksToBounds = YES;
    
    self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [composeView addSubview:self.addPhotoButton];
    self.addPhotoButton.frame = CGRectMake(self.view.width - 96 - 8, 8, 96, 96);
    [self.addPhotoButton setBackgroundImage:[[UIImage imageNamed:@"AddPhotoBackground"] stretchableImageWithLeftCapWidth:17 topCapHeight:17] forState:UIControlStateNormal];
    [self.addPhotoButton setImage:[UIImage imageNamed:@"AddPhoto"] forState:UIControlStateNormal];
    [self.addPhotoButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.addPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.addPhotoButton.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
    self.addPhotoButton.layer.borderWidth = 0.5;
    self.addPhotoButton.layer.masksToBounds = YES;
    
    UILabel *disclaimerLabel = [UILabel labelWithText:@"Note: Checkins and photos are public on Foursquare." style:@"metaCenteredLabel"];
    [composeView addSubview:disclaimerLabel];
    disclaimerLabel.frame = CGRectMake(8, self.textView.bottom + 8, self.view.width - 16, 14.0);
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:[self.venueDict objectForKey:@"name"] forState:UIControlStateNormal];
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCheckWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerAnimated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
    [self checkin];
}

- (void)addPhoto:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    // Only show "Take Photo" option if device supports it
    BOOL canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (canTakePicture) {
        [as addButtonWithTitle:@"Take Photo"];
    }
    
    [as addButtonWithTitle:@"Choose From Library"];
    [as addButtonWithTitle:@"Cancel"];
    [as setCancelButtonIndex:[as numberOfButtons] - 1];
    
    [as showInView:self.view];
}

- (void)checkin {
    [SVProgressHUD showWithStatus:@"Checking you in..." maskType:SVProgressHUDMaskTypeGradient];
    
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
    
    NSString *fsAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fsAccessToken"];
    
    if (!fsAccessToken) {
        [self checkinSucceeded:NO];
        return;
    }
    
    NSString *shout = nil;
    
    // Setup the network request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fsAccessToken forKey:@"oauth_token"];
    [parameters setObject:FS_API_VERSION forKey:@"v"];
    [parameters setObject:[self.venueDict objectForKey:@"id"] forKey:@"venueId"];
    [parameters setObject:[[PSLocationCenter defaultCenter] locationString] forKey:@"ll"];
    if (shout) {
        [parameters setObject:shout forKey:@"shout"];
    }
    [parameters setObject:@"public" forKey:@"broadcast"];
    
    NSString *URLPath = @"https://api.foursquare.com/v2/checkins/add";
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    
    BLOCK_SELF;
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
            [blockSelf checkinSucceeded:NO];
        } else {
            // Success
            NSDictionary *checkin = (NSDictionary *)JSON;
            
            if (blockSelf.hasPhoto) {
                [blockSelf addCheckinPhoto:checkin];
            } else {
                [blockSelf checkinSucceeded:YES];
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [blockSelf checkinSucceeded:NO];
    }];
    [op start];
}

- (void)addCheckinPhoto:(NSDictionary *)checkin {
    NSString *fsAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fsAccessToken"];
    
    if (!fsAccessToken) {
        [self checkinSucceeded:NO];
        return;
    }
    
    if (![checkin objectForKey:@"response"] || ![[checkin objectForKey:@"response"] objectForKey:@"checkin"]) {
        [self checkinSucceeded:NO];
        return;
    }
    
    NSString *checkinId = [[[checkin objectForKey:@"response"] objectForKey:@"checkin"] objectForKey:@"id"];
    if (!checkinId) {
        [self checkinSucceeded:NO];
        return;
    }
    
    // Setup the network request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:fsAccessToken forKey:@"oauth_token"];
    [parameters setObject:FS_API_VERSION forKey:@"v"];
    [parameters setObject:checkinId forKey:@"checkinId"];
//    [parameters setObject:[self.venueDict objectForKey:@"id"] forKey:@"venueId"];
    [parameters setObject:[[PSLocationCenter defaultCenter] locationString] forKey:@"ll"];
    [parameters setObject:[NSNumber numberWithInteger:1] forKey:@"public"];
    
    NSString *URLPath = @"https://api.foursquare.com";
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:URL];
    NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.8);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/v2/photos/add" parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    }];
    
    BLOCK_SELF;
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
        } else {
            // Success
            NSDictionary *photo = (NSDictionary *)JSON;
            NSLog(@"photo added: %@", photo);
            [blockSelf checkinSucceeded:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"photo not added: %@", JSON);
        [blockSelf checkinSucceeded:NO];
    }];
    [op start];
}

- (void)checkinSucceeded:(BOOL)didSucceed {
    if (didSucceed) {
        [SVProgressHUD dismissWithSuccess:@"Check In Succeeded"];
        [self leftAction];
    } else {
        [SVProgressHUD dismissWithError:@"Check In Failed"];
        self.leftButton.enabled = YES;
        self.rightButton.enabled = YES;
    }
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (isDeviceIPad()) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *scaledImage = [originalImage imageScaledAndRotated];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
        }
        
        self.selectedImage = scaledImage;
        self.hasPhoto = YES;
        [self.addPhotoButton setImage:self.selectedImage forState:UIControlStateNormal];
    }
    
    if (isDeviceIPad()) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
    }
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) return;
    
    NSString *buttonName = [actionSheet buttonTitleAtIndex:buttonIndex];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([buttonName isEqualToString:@"Take Photo"]) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([buttonName isEqualToString:@"Choose From Library"]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.sourceType = sourceType;
        
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            vc.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        }
        
        if (isDeviceIPad()) {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
            self.popover.delegate = self;
            [self.popover presentPopoverFromRect:self.headerView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self presentViewController:vc animated:YES completion:^{}];
        }
    }
}

#pragma mark - UIPopoverDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *URLString = [[self.webView.request URL] absoluteString];
    NSLog(@"--> %@", URLString);
    if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        if (accessToken) {
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"fsAccessToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            BLOCK_SELF;
            [UIView animateWithDuration:0.3 animations:^{
                webView.alpha = 0.0;
            } completion:^(BOOL finished){
                [webView removeFromSuperview];
                [blockSelf.textView becomeFirstResponder];
            }];
        }
    }
}

@end
