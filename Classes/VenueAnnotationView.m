//
//  VenueAnnotationView.m
//  Lunchbox
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueAnnotationView.h"

@implementation VenueAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.centerOffset = CGPointMake(0, -27);
        self.image = [UIImage imageNamed:@"PinVenueRed"];
    }
    
    return self;
}


@end
