//
//  VenueAnnotation.h
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSDictionary *venueDict;

+ (VenueAnnotation *)venueAnnotationWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
