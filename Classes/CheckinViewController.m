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

@interface CheckinViewController ()

@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;

@property (nonatomic, assign) UIButton *addPhotoButton;
@property (nonatomic, retain) UIImage *selectedImage;

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, retain) UIWebView *webView;

@end

@implementation CheckinViewController

@synthesize
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,

addPhotoButton = _addPhotoButton,
selectedImage = _selectedImage,

venueDict = _venueDict,
webView = _webView;

#pragma mark - Init
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary; 
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload {
    if (self.webView) {
        self.webView.delegate = nil;
        self.webView = nil;
    }
    [super viewDidUnload];
}

- (void)dealloc {
    if (self.webView) {    
        self.webView.delegate = nil;
        self.webView = nil;
    }
    self.venueDict = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    // Check 4sq token
    NSString *fsAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"fsAccessToken"];
    
    if (!fsAccessToken) {
        // show webview
        self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
        self.webView.delegate = self;
        
        NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@", FS_CLIENT_ID, FS_CALLBACK_URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
        
        [self.webView loadRequest:request];
        [self.view addSubview:self.webView];
    } else {
        // don't show webview
    }
}

- (void)setupSubviews {
    [self setupHeader];
    
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(8, 8 + self.headerView.height, self.view.width - 16, self.view.width - 16)] autorelease];
    [self.view addSubview:containerView];
    
    UIImage *shadowImage = [[UIImage imageNamed:@"Shadow"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadowImage] autorelease];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowView.frame = CGRectInset(containerView.bounds, -1, -2);
    shadowView.opaque = YES;
    shadowView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:shadowView];
    
    self.addPhotoButton = [UIButton buttonWithFrame:CGRectInset(containerView.bounds, 8, 8) andStyle:nil target:self action:@selector(addPhoto)];
    self.addPhotoButton.backgroundColor = RGBCOLOR(200, 200, 200);
    self.addPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [containerView addSubview:self.addPhotoButton];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
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
    [self.rightButton setImage:[UIImage imageNamed:@"IconSliderWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionDown animated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
}

- (void)addPhoto {
    UIImagePickerController *vc = [[[UIImagePickerController alloc] init] autorelease];
    vc.delegate = self;
    [self presentModalViewController:vc animated:YES];
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        self.selectedImage = [(UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage] imageScaledAndRotated];
        [self.addPhotoButton setImage:self.selectedImage forState:UIControlStateNormal];
//        CGFloat photoWidth = self.selectedImage.size.width;
//        CGFloat photoHeight = self.selectedImage.size.height;
//        CGFloat scaledHeight = floorf(photoHeight / (photoWidth / self.previewView.width));
        
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.selectedImage, nil, nil, nil);
        }
    }
    
    [picker.presentingViewController dismissModalViewControllerAnimated:YES];
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
            
            [UIView animateWithDuration:0.3 animations:^{
                webView.alpha = 0.0;
            } completion:^(BOOL finished){
                [webView removeFromSuperview];
            }];
        }
    }
}

@end
