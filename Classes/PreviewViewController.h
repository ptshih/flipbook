//
//  PreviewViewController.h
//  OSnap
//
//  Created by Peter Shih on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"

@interface PreviewViewController : PSViewController <UITextFieldDelegate>

- (id)initWithDictionary:(NSDictionary *)dictionary image:(UIImage *)image;

@end
