//
//  VenueAnnotation.m
//  Grid
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "VenueAnnotation.h"

@implementation VenueAnnotation

+ (VenueAnnotation *)venueAnnotationWithDictionary:(NSDictionary *)dictionary {
    return [[[self class] alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.venueDict = dictionary;
    }
    return self;
}


#pragma mark - MKAnnotation
- (CLLocationCoordinate2D)coordinate {
    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    CLLocationDegrees lat = [[location objectForKey:@"lat"] floatValue];
    CLLocationDegrees lng = [[location objectForKey:@"lng"] floatValue];
    return CLLocationCoordinate2DMake(lat, lng);
}

- (NSString *)title {
    return [self.venueDict objectForKey:@"name"];
}

- (NSString *)subtitle {
//    NSDictionary *location = [self.venueDict objectForKey:@"location"];
    
    NSString *distance, *duration;
    if ([self.venueDict objectForKey:@"route"]) {
        NSDictionary *route = [self.venueDict objectForKey:@"route"];

        if ([[route objectForKey:@"legs"] count] > 0) {
            NSDictionary *leg = [[route objectForKey:@"legs"] lastObject];
            distance = [[leg objectForKey:@"distance"] objectForKey:@"text"];
            duration = [[leg objectForKey:@"duration"] objectForKey:@"text"];
        }
    }
    NSString *s = [NSString stringWithFormat:@"%@ | %@", distance, duration];
    return s;
//    return [location objectForKey:@"address"] ? [location objectForKey:@"address"] : nil;
}

@end
