//
//  CheckinViewController.h
//  Lunchbox
//
//  Created by Peter Shih on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"

@interface CheckinViewController : PSViewController <UIWebViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
