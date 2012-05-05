//
//  TipListViewController.h
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"

@interface TipListViewController : PSCollectionViewController

@property (nonatomic, copy) NSDictionary *venueDict;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
