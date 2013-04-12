//
//  ProductCollectionViewCell.m
//  Celery
//
//  Created by Peter Shih on 4/12/13.
//
//

#import "ProductCollectionViewCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}

@interface ProductCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *taglineLabel;

@end

@implementation ProductCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImage *shadowImage = [[UIImage imageNamed:@"ShadowFlattened"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadowView.frame = CGRectInset(self.bounds, -1, -2);
        [self addSubview:shadowView];
        
        self.imageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.shouldAnimate = NO;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.nameLabel = [UILabel labelWithStyle:@"h5DarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.taglineLabel = [UILabel labelWithStyle:@"productTaglineLabel"];
        self.taglineLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.taglineLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
    self.taglineLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - margin().width * 2;
    CGFloat top = margin().height;
    CGFloat left = margin().width;
    
    CGSize labelSize = CGSizeZero;
    
    // Image
    self.imageView.frame = CGRectMake(left, top, width, width);
    top = self.imageView.bottom + margin().height;
    
    // Name
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    top = self.nameLabel.bottom;
    
    // Tagline
    if (self.taglineLabel.text.length > 0) {
        labelSize = [self.taglineLabel sizeForLabelInWidth:width];
        self.taglineLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    }
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    if ([[object objectForKey:@"image"] notNull]) {
        [self.imageView setOriginalURL:[NSURL URLWithString:[object objectForKey:@"image"]]];
        [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    } else {
        [self.imageView loadImage:[UIImage imageNamed:@"lumbergh.jpg"]];
    }
    
    self.nameLabel.text = [object objectForKey:@"name"];
    
    if ([[object objectForKey:@"tagline"] notNull]) {
        self.taglineLabel.text = [object objectForKey:@"tagline"];
    }
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - margin().width * 2;
    
    height += margin().height;
    
    // Image
    height += width + margin().height;
    
    // Labels
    CGSize labelSize = CGSizeZero;
    
    if ([[object objectForKey:@"name"] notNull]) {
        labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"name"] width:width style:@"h5DarkLabel"];
        height += labelSize.height;
    }
    
    if ([[object objectForKey:@"tagline"] notNull]) {
        labelSize = [PSStyleSheet sizeForText:[object objectForKey:@"tagline"] width:width style:@"productTaglineLabel"];
        height += labelSize.height;
    }
    
    height += margin().height;
    
    return height;
}

@end
