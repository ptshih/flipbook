//
//  TipsViewController.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipsViewController.h"
#import "TipCollectionViewCell.h"

@interface TipsViewController ()

@property (nonatomic, copy) NSDictionary *venueDict;

@end

@implementation TipsViewController


#pragma mark - Init
- (id)initWithVenueDict:(NSDictionary *)venueDict {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.venueDict = venueDict;
        
        self.shouldShowHeader = YES;
        self.shouldShowFooter = NO;
        self.shouldPullRefresh = NO;
        self.shouldShowNullView = NO;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        self.headerHeight = 44.0;
        self.footerHeight = 0.0;
        
        self.headerRightWidth = 0.0;
        
        self.title = [NSString stringWithFormat:@"Tips for %@", [self.venueDict objectForKey:@"name"]];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[LocalyticsSession sharedLocalyticsSession] tagScreen:NSStringFromClass([self class])];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    if (isDeviceIPad()) {
        self.collectionView.numColsPortrait = 2;
        self.collectionView.numColsLandscape = 3;
    } else {
        self.collectionView.numColsPortrait = 1;
        self.collectionView.numColsLandscape = 2;
    }
    
    // 4sq attribution
    UIImageView *pb4sq = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PoweredByFoursquareBlack"]];
    pb4sq.contentMode = UIViewContentModeCenter;
    pb4sq.frame = CGRectMake(0, 0, self.collectionView.width, pb4sq.height);
    
    self.collectionView.footerView = pb4sq;
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:self.title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
}

#pragma mark - Actions
- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    self.items = [self.venueDict objectForKey:@"tips"];
    [self dataSourceDidLoad];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    self.items = [self.venueDict objectForKey:@"tips"];
    [self dataSourceDidLoad];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    DLog(@"remote data source did error");
    [super dataSourceDidError];
}

#pragma mark - PSCollectionViewDelegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [TipCollectionViewCell class];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    Class cellClass = [self collectionView:collectionView cellClassForRowAtIndex:index];
    
    id cell = [self.collectionView dequeueReusableViewForClass:[cellClass class]];
    if (!cell) {
        cell = [[cellClass alloc] initWithFrame:CGRectZero];
    }
    
    [cell collectionView:collectionView fillCellWithObject:item atIndex:index];
    
    return cell;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index {
    Class cellClass = [self collectionView:collectionView cellClassForRowAtIndex:index];
    
    NSDictionary *item = [self.items objectAtIndex:index];
    
    return [cellClass rowHeightForObject:item inColumnWidth:collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index {
    //    Class cellClass = [self collectionView:collectionView cellClassForRowAtIndex:index];
    
    //    NSDictionary *item = [self.items objectAtIndex:index];
}

@end
