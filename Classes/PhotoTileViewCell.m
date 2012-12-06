//
//  PhotoTileViewCell.m
//  Mosaic
//
//  Created by Peter Shih on 12/4/12.
//
//

#import "PhotoTileViewCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}

@interface PhotoTileViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *overlayView;


@end

@implementation PhotoTileViewCell


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.loadingColor = RGBACOLOR(60, 60, 60, 1.0);
        self.imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.imageView.shouldAnimate = NO;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        self.overlayView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        [self addSubview:self.overlayView];
        
        self.nameLabel = [UILabel labelWithStyle:@"cellTitleLightLabel"];
        [self.overlayView addSubview:self.nameLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - margin().width * 2;
    CGFloat top = margin().height;
    CGFloat left = margin().width;
    
    CGSize labelSize = CGSizeZero;
    
    // Photo
    self.imageView.frame = self.bounds;
    
    // Overlay
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    self.overlayView.frame = CGRectMake(0.0, self.height - labelSize.height - margin().height * 2, self.imageView.width, labelSize.height + margin().height * 2);
}

- (void)tileView:(PSTileView *)tileView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super tileView:tileView fillCellWithObject:object atIndex:index];
    
    // Photo
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"picture"]]];
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    
    NSString *name = [object objectForKey:@"name"];
    if (name) {
        NSString *nameText = [NSString stringWithFormat:@"%@", name];
        self.nameLabel.text = nameText;
    } else {
        NSString *timestamp = [NSDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"created_time"] doubleValue]]];
        self.nameLabel.text = timestamp;
    }
}

@end
