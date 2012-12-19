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

@interface GridViewController () <PSGridViewDelegate, PSGridViewDataSource>

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

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

#pragma mark - Config Subviews

- (void)setupSubviews {
    [super setupSubviews];
    
    self.gridView = [[PSGridView alloc] initWithFrame:self.contentView.bounds dictionary:nil];
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






- (void)gridView:(PSGridView *)gridView configureCell:(PSGridViewCell *)cell completionBlock:(void (^)(BOOL cellConfigured))completionBlock {
    
    [UIActionSheet actionSheetWithTitle:@"Add/Edit Content" message:nil destructiveButtonTitle:nil buttons:@[@"Text", @"Image URL", @"Color", @"Photo", @"Remove"] showInView:self.view onDismiss:^(int buttonIndex, NSString *textInput) {
        
        // Load with configuration
        switch (buttonIndex) {
            case 0: {
                [UIAlertView alertViewWithTitle:@"Enter Text" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        NSDictionary *content = @{@"type" : @"text", @"text": textInput};
                        [cell loadContent:content];
                    }
                    completionBlock(YES);
                } onCancel:^{
                    completionBlock(NO);
                }];
                break;
            }
            case 1: {
                [UIAlertView alertViewWithTitle:@"Image" style:UIAlertViewStylePlainTextInput message:@"URL" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        NSDictionary *content = @{@"type" : @"image", @"href": textInput};
                        [cell loadContent:content];
                    }
                    completionBlock(YES);
                } onCancel:^{
                    completionBlock(NO);
                }];
                break;
            }
            case 2: {
                [cell loadColor:TEXTURE_DARK_LINEN];
                completionBlock(YES);
                break;
            }
            case 3: {
                [UIActionSheet photoPickerWithTitle:@"Pick a Photo" showInView:self.view presentVC:self onPhotoPicked:^(UIImage *chosenImage) {
                    [cell loadImage:chosenImage];
                    completionBlock(YES);
                } onCancel:^{
                    completionBlock(NO);
                }];
                break;
            }
            case 4: {
                // remove cell
                break;
            }
            default:
                completionBlock(NO);
                break;
        }
    } onCancel:^{
        completionBlock(NO);
    }];
}

- (void)gridView:(PSGridView *)gridView didSelectCell:(PSGridViewCell *)cell atIndices:(NSSet *)indices completionBlock:(void (^)(BOOL cellConfigured))completionBlock {
//    NSLog(@"%@", indices);
    
    
    [gridView.gridViewDataSource gridView:gridView configureCell:cell completionBlock:completionBlock];
    
//    [gridView editCell:cell];
    
//    [UIAlertView alertViewWithTitle:@"Image" style:UIAlertViewStylePlainTextInput message:@"URL" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
//        NSLog(@"%@", textInput);
//        
//        if (textInput.length > 0) {
//            [cell loadImageAtURL:[NSURL URLWithString:textInput]];
//        }
//    } onCancel:^{
//    }];
    
//    [cell loadImage:[UIImage imageNamed:@"lumbergh.jpg"]];
}

- (void)gridView:(PSGridView *)gridView didLongPressCell:(PSGridViewCell *)cell atIndices:(NSSet *)indices completionBlock:(void (^)(BOOL cellRemoved))completionBlock {
    [UIAlertView alertViewWithTitle:@"Remove Cell?" style:UIAlertViewStyleDefault message:nil cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] onDismiss:^(int buttonIndex, NSString *textInput) {
        completionBlock(YES);
    } onCancel:^{
        completionBlock(NO);
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation != UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
