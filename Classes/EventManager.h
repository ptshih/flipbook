//
//  EventManager.h
//  Lunchbox
//
//  Created by Peter Shih on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventManager : NSObject

+ (id)sharedManager;

- (NSArray *)events;

@end
