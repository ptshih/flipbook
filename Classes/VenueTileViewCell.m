//
//  VenueTileViewCell.m
//  Grid
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "VenueTileViewCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}

@interface VenueTileViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *overlayView;

@end

@implementation VenueTileViewCell

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
    
    NSDictionary *venue = (NSDictionary *)object;
    
    // Photo
    NSDictionary *photo = [venue objectForKey:@"photo"];
    if (photo) {
        // Use venue photo
        NSString *href = [photo objectForKey:@"href"];
        [self.imageView setOriginalURL:[NSURL URLWithString:href]];
        [self.imageView setThumbnailURL:[NSURL URLWithString:href]];
        [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    } else {
        // Use category icon
        NSString *href = [venue objectForKey:@"categoryIcon"];
        [self.imageView setOriginalURL:[NSURL URLWithString:href]];
        [self.imageView setThumbnailURL:[NSURL URLWithString:href]];
        [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    }
    
    self.nameLabel.text = [venue objectForKey:@"name"];
    
    
}

@end
