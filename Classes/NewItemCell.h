//
//  NewItemCell.h
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "PSCell.h"

@protocol NewItemCellDelegate;

@interface NewItemCell : PSCell

@property (nonatomic, unsafe_unretained) id delegate;

@end

@protocol NewItemCellDelegate <NSObject>

- (void)cellModifiedWithText:(NSString *)text;

@end