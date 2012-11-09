//
//  LocationChooserView.m
//  Lunchbox
//
//  Created by Peter on 2/28/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "LocationChooserView.h"
#import "PSPopoverView.h"

@interface LocationChooserView ()

@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *currentLocationButton;

@property (nonatomic, strong) MKCircle *circleOverlay;

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
        
        PSTextField *queryField = [[PSTextField alloc] initWithFrame:CGRectZero withMargins:CGSizeMake(8, 8)];
        [PSStyleSheet applyStyle:@"h5BoldLightLabel" forTextField:queryField];
        queryField.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        queryField.layer.cornerRadius = 4.0;
        queryField.layer.masksToBounds = YES;
        queryField.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        queryField.layer.borderWidth = 1.0;
        queryField.layer.shouldRasterize = YES;
        queryField.layer.rasterizationScale = [UIScreen mainScreen].scale;
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
        [self.mapView addSubview:queryField];
        self.queryField = queryField;
        
        // Current Location
        UIButton *currentLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.currentLocationButton = currentLocationButton;
        currentLocationButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
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
        redoSearchButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        redoSearchButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        redoSearchButton.layer.cornerRadius = 4.0;
        redoSearchButton.layer.masksToBounds = YES;
        redoSearchButton.layer.borderColor = [RGBACOLOR(76, 76, 76, 0.5) CGColor];
        redoSearchButton.layer.borderWidth = 1.0;
        redoSearchButton.layer.shouldRasterize = YES;
        redoSearchButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [redoSearchButton addTarget:self action:@selector(redoSearch) forControlEvents:UIControlEventTouchUpInside];
        [redoSearchButton setTitle:@"Search This Area" forState:UIControlStateNormal];
        [PSStyleSheet applyStyle:@"h5BoldLightLabel" forButton:redoSearchButton];
        redoSearchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.mapView addSubview:redoSearchButton];
        self.searchButton.alpha = 0.0;
    }
    return self;
}

- (void)dealloc {
    self.mapView.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat top = 8.0;
    CGFloat left = 8.0;
    CGFloat width = self.mapView.width - 16.0;
    
    self.currentLocationButton.frame = CGRectMake(self.mapView.width - 36 - 8, top, 36, 36);
    width -= self.currentLocationButton.width + 8.0;
    self.queryField.frame = CGRectMake(left, top, width, 36);
    
    self.searchButton.frame = CGRectMake(self.mapView.width - 160.0 - 8.0, self.mapView.height - 8.0 - 31.0, 160.0, 31.0);
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
    
    [self.mapView removeOverlay:self.circleOverlay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CGFloat mapRadius = (MKMapRectSpanDistance(self.mapView.visibleMapRect) / 2.0) - 16.0;
    
    self.circleOverlay = [MKCircle circleWithCenterCoordinate:self.mapView.centerCoordinate radius:mapRadius];
    [self.mapView addOverlay:self.circleOverlay];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if(overlay == self.circleOverlay) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:self.circleOverlay];
        circleView.fillColor = RGBACOLOR(29, 153, 188, 0.3);
        circleView.strokeColor = [UIColor clearColor];
        return circleView;
    }
    
    return nil;
}

@end
