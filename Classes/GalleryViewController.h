//
//  GalleryViewController.h
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"
#import "PSGalleryView.h"

@interface GalleryViewController : PSCollectionViewController

@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *venueName;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;

- (id)initWithVenueId:(NSString *)venueId venueName:(NSString *)venueName;

@end
