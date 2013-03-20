//
//  VenueAnnotationView.m
//  Grid
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "VenueAnnotationView.h"
#import "VenueAnnotation.h"

@implementation VenueAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.centerOffset = CGPointMake(0, -27);
        VenueAnnotation *ann = (VenueAnnotation *)self.annotation;
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[ann.venueDict objectForKey:@"categoryIconSmall"]]]];
//        self.image = image;
        
//        UIImage *frame = [UIImage imageNamed:[NSString stringWithFormat:@"F.png"];
//        UIImage *image = theImageInFrameInner;

        UIGraphicsBeginImageContext(CGSizeMake(32, 32));

//        [frame drawInRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [image drawInRect:CGRectMake(0, 0, 32, 32)]; // the frame your inner image
        //maybe you should draw the left bottom icon here,


        //then set back the new image, done
        self.image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
                          
                          
//        self.image = [UIImage imageNamed:@"PinVenueRed"];
    }
    
    return self;
}


@end
