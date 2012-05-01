//
//  PhotoCategoryViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoCategoryViewController.h"

@interface PhotoCategoryViewController ()

@property (nonatomic, copy) NSDictionary *venueDict;

@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;

@end

@implementation PhotoCategoryViewController

@synthesize
venueDict;

@synthesize
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary;
        
        self.shouldAddRoundedCorners = YES;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    self.venueDict = nil;
    
    [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    [self setupHeader];
    
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.centerButton setTitle:[NSString stringWithFormat:@"What Kind of Photo?"] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    //    [self.rightButton setImage:[UIImage imageNamed:@"IconPinWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.rightButton.userInteractionEnabled = NO;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
}

@end
