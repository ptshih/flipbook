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

@property (nonatomic, strong) PSTextField *queryField;
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation LocationChooserView

- (id)initWithFrame:(CGRect)frame mapRegion:(MKCoordinateRegion)mapRegion {
    self = [super initWithFrame:frame];
    if (self) {
        self.locationDidChange = NO;
        
        self.mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mapView.delegate = self;
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.showsUserLocation = YES;
        [self.mapView setRegion:mapRegion animated:NO];
        [self addSubview:self.mapView];
        
        UIView *queryView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, self.mapView.width - 16 - 36 - 8, 36)];
        queryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        queryView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        queryView.layer.cornerRadius = 4.0;
        queryView.layer.masksToBounds = YES;
        queryView.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        queryView.layer.borderWidth = 1.0;
        queryView.layer.shouldRasterize = YES;
        queryView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        PSTextField *queryField = [[PSTextField alloc] initWithFrame:queryView.bounds withMargins:CGSizeMake(8, 8)];
        [PSStyleSheet applyStyle:@"leadLightField" forTextField:queryField];
        
        queryField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        queryField.leftViewMode = UITextFieldViewModeAlways;
        UIImageView *searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconSearchMiniWhite"]];
        searchImageView.contentMode = UIViewContentModeCenter;
        queryField.leftView = searchImageView;
        
        queryField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        queryField.delegate = self;
        queryField.returnKeyType = UIReturnKeySearch;
        queryField.autocorrectionType = UITextAutocorrectionTypeNo;
        queryField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        queryField.placeholder = @"Search for anything...";
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
        currentLocationButton.layer.shouldRasterize = YES;
        currentLocationButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [currentLocationButton addTarget:self action:@selector(centerCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:currentLocationButton];
        
        UIButton *redoSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.searchButton = redoSearchButton;
//        [redoSearchButton setBackgroundImage:[[UIImage imageNamed:@"ButtonWhite"] stretchableImageWithLeftCapWidth:5 topCapHeight:15] forState:UIControlStateNormal];
        redoSearchButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        redoSearchButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        redoSearchButton.layer.cornerRadius = 4.0;
        redoSearchButton.layer.masksToBounds = YES;
        redoSearchButton.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        redoSearchButton.layer.borderWidth = 1.0;
        redoSearchButton.layer.shouldRasterize = YES;
        redoSearchButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [redoSearchButton addTarget:self action:@selector(redoSearch) forControlEvents:UIControlEventTouchUpInside];
        [redoSearchButton setTitle:@"Search This Area" forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"leadLightLabel" forButton:redoSearchButton];
        redoSearchButton.frame = CGRectMake(self.mapView.width - 144.0 - 8.0, self.mapView.height - 8.0 - 31.0, 144.0, 31.0);
        [self.mapView addSubview:redoSearchButton];
        self.searchButton.alpha = 0.0;
    }
    return self;
}

- (void)dealloc {
    self.mapView.delegate = nil;
}

- (void)clearField:(UIButton *)button {
    self.queryField.text = nil;
}

- (void)centerCurrentLocation {
    if (![CLLocationManager locationServicesEnabled] || ![[PSLocationCenter defaultCenter] locationServicesAuthorized]) {
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
    self.locationDidChange = YES;
    
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
    
    [UIView animateWithDuration:0.4 animations:^{
        self.searchButton.alpha = 1.0;
    }];
}

@end
