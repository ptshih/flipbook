//
//  CategoryListViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryListViewController.h"

#import "VenueListViewController.h"

#define MARGIN 8.0
#define LABEL_HEIGHT 40.0
#define kTopViewTag 9001
#define kMidViewTag 9002
#define kBotViewTag 9003

@interface CategoryListViewController ()

@end

@implementation CategoryListViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor blackColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [self addRoundedCorners];
}

- (void)setupSubviews {
    // Images
    UIImageView *topView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryFood.jpg"]] autorelease];
    [self.view addSubview:topView];
    topView.tag = kTopViewTag;
    topView.contentScaleFactor = [UIScreen mainScreen].scale;
    topView.contentMode = UIViewContentModeScaleAspectFill;
    topView.clipsToBounds = YES;
    topView.userInteractionEnabled = YES;
    [topView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushCategory:)] autorelease]];

    UIImageView *midView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryCafe.jpg"]] autorelease];
    [self.view addSubview:midView];
    midView.tag = kMidViewTag;
    midView.contentScaleFactor = [UIScreen mainScreen].scale;
    midView.contentMode = UIViewContentModeScaleAspectFill;
    midView.clipsToBounds = YES;
    midView.userInteractionEnabled = YES;
    [midView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushCategory:)] autorelease]];
    
    UIImageView *botView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CategoryNightlife.jpg"]] autorelease];
    [self.view addSubview:botView];
    botView.tag = kBotViewTag;
    botView.contentScaleFactor = [UIScreen mainScreen].scale;
    botView.contentMode = UIViewContentModeScaleAspectFill;
    botView.clipsToBounds = YES;
    botView.userInteractionEnabled = YES;
    [botView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushCategory:)] autorelease]];
    
    CGFloat height = ceilf(self.view.height / 3.0);
    CGFloat botHeight = self.view.height - (height * 2.0);
    
    topView.frame = CGRectMake(0, 0, self.view.width, height);
    midView.frame = CGRectMake(0, topView.bottom, self.view.width, height);
    botView.frame = CGRectMake(0, midView.bottom, self.view.width, botHeight);
    
    // Labels
    CGSize labelSize = CGSizeZero;
    CGFloat width = topView.width - MARGIN * 2;
    
    UILabel *topLabel = [UILabel labelWithText:@"  Food and Restaurants  " style:@"categoryHeadline"];
    [topView addSubview:topLabel];
    labelSize = [PSStyleSheet sizeForText:topLabel.text width:width style:@"categoryHeadline"];
    topLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    topLabel.frame = CGRectMake(MARGIN, topView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
    
    UILabel *midLabel = [UILabel labelWithText:@"  Coffee and Tea  " style:@"categoryHeadline"];
    [midView addSubview:midLabel];
    labelSize = [PSStyleSheet sizeForText:midLabel.text width:width style:@"categoryHeadline"];
    midLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    midLabel.frame = CGRectMake(MARGIN, midView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
    
    UILabel *botLabel = [UILabel labelWithText:@"  Bars and Nightclubs  " style:@"categoryHeadline"];
    [botView addSubview:botLabel];
    labelSize = [PSStyleSheet sizeForText:botLabel.text width:width style:@"categoryHeadline"];
    botLabel.backgroundColor = RGBACOLOR(255, 255, 255, 0.75);
    botLabel.frame = CGRectMake(MARGIN, botView.height - LABEL_HEIGHT - MARGIN, labelSize.width, LABEL_HEIGHT);
}

- (void)pushCategory:(UITapGestureRecognizer *)gestureRecognizer {
    NSString *category = nil;
    UIView *view = gestureRecognizer.view;
    switch (view.tag) {
        case kTopViewTag:
            category = @"food";
            break;
        case kMidViewTag:
            category = @"coffee";
            break;
        case kBotViewTag:
            category = @"drinks";
            break;
        default:
            category = @"food";
            break;
    }
    
    id vc = [[[VenueListViewController alloc] initWithCategory:category] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

@end
