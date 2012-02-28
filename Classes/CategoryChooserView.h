//
//  CategoryChooserView.h
//  Mealtime
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface CategoryChooserView : PSView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;

@end
