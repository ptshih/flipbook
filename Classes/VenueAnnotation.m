//
//  VenueAnnotation.m
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueAnnotation.h"

@implementation VenueAnnotation

@synthesize
venueDict = _venueDict;

+ (VenueAnnotation *)venueAnnotationWithDictionary:(NSDictionary *)dictionary {
    return [[[[self class] alloc] initWithDictionary:dictionary] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.venueDict = dictionary;
    }
    return self;
}

- (void)dealloc {
    self.venueDict = nil;
    [super dealloc];
}

#pragma mark - MKAnnotation
- (CLLocationCoordinate2D)coordinate {
    CLLocationDegrees lat = [[self.venueDict objectForKey:@"lat"] floatValue];
    CLLocationDegrees lng = [[self.venueDict objectForKey:@"lng"] floatValue];
    return CLLocationCoordinate2DMake(lat, lng);
}

- (NSString *)title {
    return [self.venueDict objectForKey:@"name"];
}

- (NSString *)subtitle {
    return [self.venueDict objectForKey:@"address"] ? [self.venueDict objectForKey:@"address"] : nil;
}

@end
