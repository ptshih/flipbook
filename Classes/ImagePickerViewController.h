//
//  ImagePickerViewController.h
//  Grid
//
//  Created by Peter Shih on 12/21/12.
//
//

#import "PSCollectionViewController.h"

@protocol ImagePickerDelegate;

@interface ImagePickerViewController : PSCollectionViewController

@property (nonatomic, unsafe_unretained) id <ImagePickerDelegate> delegate;

- (id)initWithSource:(NSString *)source;

@end

@protocol ImagePickerDelegate <NSObject>

@optional
- (void)imagePicker:(ImagePickerViewController *)imagePicker didPickImage:(UIImage *)image;
- (void)imagePicker:(ImagePickerViewController *)imagePicker didPickImageWithURLPath:(NSString *)URLPath;

@end
