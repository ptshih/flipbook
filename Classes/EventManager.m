//
//  EventManager.m
//  Lunchbox
//
//  Created by Peter Shih on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventManager.h"

@implementation EventManager

+ (id)sharedManager {
    static id sharedManager;
    if (!sharedManager) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)events {
//    NSArray *events = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"events" ofType:@"plist"]];
    NSMutableDictionary *fakeEvent = [NSMutableDictionary dictionary];
    [fakeEvent setObject:@"4b709d01f964a5204c252de3" forKey:@"venueId"];
    [fakeEvent setObject:@"548430564" forKey:@"fbId"];
    [fakeEvent setObject:@"Peter Shih" forKey:@"fbName"];
    [fakeEvent setObject:[NSArray arrayWithObjects:@"2420700", @"2502195", nil] forKey:@"attendees"];
    [fakeEvent setObject:@"Dinner" forKey:@"reason"];
    [fakeEvent setObject:[NSDate date] forKey:@"timestamp"];
    
    return [NSArray arrayWithObject:fakeEvent];
}

@end
