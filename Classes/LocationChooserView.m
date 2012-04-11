//
//  LocationChooserView.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationChooserView.h"
#import "PSPopoverView.h"

@interface LocationChooserView ()

@property (nonatomic, assign) PSTextField *queryField;

@end

@implementation LocationChooserView

@synthesize
queryField = _queryField,
mapView = _mapView,
query = _query;

- (id)initWithFrame:(CGRect)frame mapRegion:(MKCoordinateRegion)mapRegion {
    self = [super initWithFrame:frame];
    if (self) {
        self.mapView = [[[MKMapView alloc] initWithFrame:self.bounds] autorelease];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mapView.delegate = self;
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.showsUserLocation = YES;
        [self.mapView setRegion:mapRegion animated:NO];
        [self addSubview:self.mapView];
        
        UIView *queryView = [[[UIView alloc] initWithFrame:CGRectMake(8, 8, self.mapView.width - 16 - 36 - 8, 36)] autorelease];
        queryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        queryView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        queryView.layer.cornerRadius = 4.0;
        queryView.layer.masksToBounds = YES;
        queryView.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        queryView.layer.borderWidth = 1.0;
        
        PSTextField *queryField = [[[PSTextField alloc] initWithFrame:queryView.bounds withInset:UIEdgeInsetsMake(8, 8, 8, 8)] autorelease];
        [PSStyleSheet applyStyle:@"queryField" forTextField:queryField];
        queryField.leftViewMode = UITextFieldViewModeAlways;
        UIImageView *searchImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconSearchMiniWhite"]] autorelease];
        searchImageView.contentMode = UIViewContentModeLeft;
        queryField.leftView = searchImageView;
        queryField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        queryField.delegate = self;
        queryField.returnKeyType = UIReturnKeySearch;
        queryField.clearButtonMode = UITextFieldViewModeWhileEditing;
        queryField.autocorrectionType = UITextAutocorrectionTypeNo;
        queryField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        queryField.placeholder = @"Search for something...";
//        [queryField setEnablesReturnKeyAutomatically:YES];
        [queryField addTarget:self action:@selector(queryChanged:) forControlEvents:UIControlEventEditingChanged];
        [queryView addSubview:queryField];
        self.queryField = queryField;
        
        [self.mapView addSubview:queryView];
        
        // Current Location
        UIButton *currentLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        currentLocationButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        currentLocationButton.frame = CGRectMake(self.mapView.width - 36 - 8, 8, 36, 36);
        [currentLocationButton setImage:[UIImage imageNamed:@"IconLocationArrowMini"] forState:UIControlStateNormal];
        currentLocationButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        currentLocationButton.layer.cornerRadius = 4.0;
        currentLocationButton.layer.masksToBounds = YES;
        currentLocationButton.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        currentLocationButton.layer.borderWidth = 1.0;
        [currentLocationButton addTarget:self action:@selector(centerCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:currentLocationButton];
        
        UIButton *redoSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        redoSearchButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        redoSearchButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        redoSearchButton.layer.cornerRadius = 4.0;
        redoSearchButton.layer.masksToBounds = YES;
        redoSearchButton.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        redoSearchButton.layer.borderWidth = 1.0;
        [redoSearchButton addTarget:self action:@selector(redoSearch) forControlEvents:UIControlEventTouchUpInside];
        redoSearchButton.height = 36;
        redoSearchButton.width = self.mapView.width - 16;
        redoSearchButton.left = 8;
        redoSearchButton.top = self.mapView.height - 8 - 36;
        [redoSearchButton setTitle:@"Redo Search In This Area" forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"popoverTitleLabel" forButton:redoSearchButton];
        [self.mapView addSubview:redoSearchButton];
        
        
    }
    return self;
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.query = nil;
    [super dealloc];
}

- (void)centerCurrentLocation {
    if (![[PSLocationCenter defaultCenter] locationServicesEnabled]) {
        return;
    }
    
    CLLocationCoordinate2D coord;
    if (self.mapView.userLocation) {
        coord = self.mapView.userLocation.location.coordinate;
    } else {
        coord = [[PSLocationCenter defaultCenter] locationCoordinate];
    }
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(coord, kMapRegionRadius * 2, kMapRegionRadius * 2);
    [self.mapView setRegion:mapRegion animated:YES];
}

- (void)redoSearch {
    if ([self.nextResponder.nextResponder isKindOfClass:[PSPopoverView class]]) {
        [(PSPopoverView *)self.nextResponder.nextResponder dismiss];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];
    [self redoSearch];
    return YES;
}

- (void)queryChanged:(PSTextField *)textField {
    self.query = textField.text;
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self.queryField isFirstResponder]) {
        [self.queryField resignFirstResponder];
    }
}

@end
