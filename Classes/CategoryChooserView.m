//
//  CategoryChooserView.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryChooserView.h"
#import "PSPopoverView.h"

@implementation CategoryChooserView

@synthesize
tableView = _tableView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
        
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStyleGrouped] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = NO;
        [self addSubview:self.tableView];
        [self.tableView reloadData];
        
        NSInteger categoryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"categoryIndex"];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:categoryIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone]; // preselect category
    }
    return self;
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    self.tableView = nil;
    [super dealloc];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Choose a start and end date for your Timeline.";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [UITableViewCell class];
    UITableViewCell *cell = nil;
    NSString *reuseIdentifier = @"UITableViewCellBase";
    
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil) { 
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Food and Restaurants";
            break;
        case 1:
            cell.textLabel.text = @"Coffee and Cafes";
            break;
        case 2:
            cell.textLabel.text = @"Nightlight and Drinks";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"categoryIndex"];
    if ([self.nextResponder.nextResponder isKindOfClass:[PSPopoverView class]]) {
        [(PSPopoverView *)self.nextResponder.nextResponder dismiss];
    }
}

@end
