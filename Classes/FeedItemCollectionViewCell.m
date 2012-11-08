//
//  FeedItemCollectionViewCell.m
//  Lunchbox
//
//  Created by Peter Shih on 11/8/12.
//
//

#import "FeedItemCollectionViewCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}

@interface FeedItemCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end


@implementation FeedItemCollectionViewCell

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
        
        self.nameLabel = [UILabel labelWithStyle:@"h5CondDarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.descLabel = [UILabel labelWithStyle:@"h6GeorgiaDarkLabel"];
        self.descLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.descLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
    self.nameLabel.text = nil;
    self.descLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - margin().width * 2;
    CGFloat top = margin().height;
    CGFloat left = margin().width;
    
    CGFloat objectWidth = [self.object objectForKey:@"width"] ? [[self.object objectForKey:@"width"] floatValue] : 256.0;
    CGFloat objectHeight = [self.object objectForKey:@"height"] ? [[self.object objectForKey:@"width"] floatValue] : 256.0;
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top += self.imageView.height + margin().height;
    
    CGSize labelSize = CGSizeZero;
    
    // Name
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, width, labelSize.height);
    
    top = self.nameLabel.bottom;
    
    // Desc
    labelSize = [self.descLabel sizeForLabelInWidth:width];
    self.descLabel.frame = CGRectMake(left, top, width, labelSize.height);
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"image"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"image"]]];
    [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    
    NSString *nameText = [object objectForKey:@"title"];
    self.nameLabel.text = nameText;
    
    NSString *descText = [object objectForKey:@"description"];
    self.descLabel.text = descText;
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - margin().width * 2;
    
    height += margin().height;
    
    CGFloat objectWidth = 256.0;
    CGFloat objectHeight = 256.0;
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += margin().height;
    
    CGSize labelSize = CGSizeZero;
    
    NSString *nameText = [object objectForKey:@"title"];
    labelSize = [PSStyleSheet sizeForText:nameText width:width style:@"h5CondDarkLabel"];
    height += labelSize.height;
    
    NSString *descText = [object objectForKey:@"description"];
    labelSize = [PSStyleSheet sizeForText:descText width:width style:@"h6GeorgiaDarkLabel"];
    height += labelSize.height;
    
    height += margin().height;
    
    return height;
}


@end
