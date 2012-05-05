//
//  PhotoTagsViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoTagsViewController.h"

@interface PhotoTagsViewController ()

@property (nonatomic, copy) NSDictionary *venueDict;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation PhotoTagsViewController

@synthesize
venueDict,
tags,
buttons;

@synthesize
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = dictionary;
        self.tags = [NSMutableArray array];
        self.buttons = [NSMutableArray array];
        
        self.shouldAddRoundedCorners = YES;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
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
    
    // Grid of 4 categories
    [self.tags addObject:@"food"];
    [self.tags addObject:@"drink"];
    [self.tags addObject:@"ambiance"];
    [self.tags addObject:@"people"];
    
    CGFloat top = self.headerView.bottom + 8.0;
    CGFloat left = 8.0;
    CGFloat width = floorf((self.view.width - 24.0) / 2.0);
    CGFloat height = floorf((self.view.height - self.headerView.height - self.footerView.height - 24.0) / 2.0);
    
    UIButton *button = nil;
    
    int i = 0;
    for (NSString *tag in self.tags) {
        int col = i % 2;
        int row = i / 2;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(left + col * 8.0 + col * width, top + row * 8.0 + row * height, width, height);
        [button setBackgroundImage:[[UIImage imageNamed:@"AddPhotoBackground"] stretchableImageWithLeftCapWidth:17 topCapHeight:17] forState:UIControlStateNormal];
        [button setTitle:tag forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"AddPhoto"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectTag:) forControlEvents:UIControlEventTouchUpInside];
        
        button.layer.borderColor = [RGBACOLOR(200, 200, 200, 1.0) CGColor];
        button.layer.borderWidth = 0.5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
        
        [self.buttons addObject:button];
        
        i++;
    }
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

- (void)selectTag:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    NSString *tag = [self.tags objectAtIndex:index];
    
    // tag selected, push photo selector
    NSLog(@"tag: %@", tag);
    
}

@end
