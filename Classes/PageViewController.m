//
//  PageViewController.m
//  Mosaic
//
//  Created by Peter Shih on 12/18/12.
//
//

#import "PageViewController.h"

#import "PSGridView.h"

@interface PageViewController () <PSGridViewDelegate, PSGridViewDataSource>

@property (nonatomic, strong) PSGridView *gridView;
@property (nonatomic, strong) NSDictionary *gridDictionary;

@end

@implementation PageViewController

- (id)initWithGridDictionary:(NSDictionary *)gridDictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.gridDictionary = gridDictionary;
    }
    
    return self;
}

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

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.gridView = [[PSGridView alloc] initWithFrame:self.contentView.bounds dictionary:self.gridDictionary];
    self.gridView.autoresizingMask = ~UIViewAutoresizingNone;
    self.gridView.gridViewDelegate = self;
    self.gridView.gridViewDataSource = self;
    
    [self.contentView addSubview:self.gridView];
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
    NSDictionary *dict = [self.gridView exportData];
    NSLog(@"export: %@", dict);
    
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    //    NSLog(@"json: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
}

- (void)gridView:(PSGridView *)gridView configureCell:(PSGridViewCell *)cell completionBlock:(void (^)(BOOL cellConfigured))completionBlock {
}

- (void)gridView:(PSGridView *)gridView didSelectCell:(PSGridViewCell *)cell atIndices:(NSSet *)indices completionBlock:(void (^)(BOOL cellConfigured))completionBlock {
}

- (void)gridView:(PSGridView *)gridView didLongPressCell:(PSGridViewCell *)cell atIndices:(NSSet *)indices completionBlock:(void (^)(BOOL cellRemoved))completionBlock {
}

@end
