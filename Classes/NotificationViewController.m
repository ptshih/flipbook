//
//  NotificationViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationViewController.h"

#import "PSPopoverView.h"
#import "AppDelegate.h"

#import "EventCell.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldAddRoundedCorners = YES;
        self.shouldPullRefresh = YES;
        self.tableViewStyle = UITableViewStylePlain;
        self.tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = [UIColor lightGrayColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kNotificationManagerDidUpdate object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    NSArray *notifications = [[NotificationManager sharedManager] notifications];
    [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:notifications] animated:NO];
    [self dataSourceDidLoad];
    
    // Download updates
    [[NotificationManager sharedManager] downloadNotificationsWithCompletionBlock:^(NSArray *notifications, NSError *error) {
        if (!error) {
            [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:notifications] animated:NO];
            [self dataSourceDidLoad];
        } else {
            [self dataSourceDidError];
        }
    }];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    // Download updates
    [[NotificationManager sharedManager] downloadNotificationsWithCompletionBlock:^(NSArray *notifications, NSError *error) {
        if (!error) {
            [self dataSourceShouldLoadObjects:[NSArray arrayWithObject:notifications] animated:NO];
            [self dataSourceDidLoad];
        } else {
            [self dataSourceDidError];
        }
    }];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}


#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [EventCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeightForObject:object atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *venueId = [object objectForKey:@"venueId"];
    NSString *eventId = [object objectForKey:@"_id"];
    if ([self.nextResponder.nextResponder isKindOfClass:[PSPopoverView class]]) {
        [(PSPopoverView *)self.nextResponder.nextResponder dismiss];
        [(AppDelegate *)APP_DELEGATE pushVenueWithId:venueId eventId:eventId];
    }
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    //    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
}

- (void)endRefresh {
    [super endRefresh];
    //    [SVProgressHUD dismiss];
}

@end
