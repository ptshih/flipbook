//
//  BrandItemCollectionViewCell.m
//  Mosaic
//
//  Created by Peter Shih on 10/30/12.
//
//

#import "BrandItemCollectionViewCell.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}

@interface BrandItemCollectionViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation BrandItemCollectionViewCell

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
        
        self.nameLabel = [UILabel labelWithStyle:@"cellTitleDarkLabel"];
        self.nameLabel.backgroundColor = self.backgroundColor;
        [self addSubview:self.nameLabel];
        
        self.descLabel = [UILabel labelWithStyle:@"cellDescriptionDarkLabel"];
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
    
    if ([self.object objectForKey:@"image"]) {
        CGFloat objectWidth = [self.object objectForKey:@"width"] ? [[self.object objectForKey:@"width"] floatValue] : 256.0;
        CGFloat objectHeight = [self.object objectForKey:@"height"] ? [[self.object objectForKey:@"width"] floatValue] : 256.0;
        CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
        self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
        
        top += self.imageView.height + margin().height;
        
        self.imageView.hidden = NO;
    } else {
        self.imageView.hidden = YES;
    }
    
    CGSize labelSize = CGSizeZero;
    
    // Name
    labelSize = [self.nameLabel sizeForLabelInWidth:width];
    self.nameLabel.frame = CGRectMake(left, top, width, labelSize.height);
    
    top = self.nameLabel.bottom;
    
    // Desc
    if (self.descLabel.text.length > 0) {
        labelSize = [self.descLabel sizeForLabelInWidth:width];
        self.descLabel.frame = CGRectMake(left, top, width, labelSize.height);
        self.descLabel.hidden = NO;
    } else {
        self.descLabel.hidden = YES;
    }
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    
    if ([self.object objectForKey:@"image"]) {
        [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"image"]]];
        [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"image"]]];
        [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
    }
    
    NSMutableString *nameText = [NSMutableString stringWithString:[object objectForKey:@"name"]];
    if ([object objectForKey:@"price"]) {
        [nameText appendFormat:@" - $%@", [object objectForKey:@"price"]];
    }
    self.nameLabel.text = nameText;
    
    NSString *descText = [object objectForKey:@"short_description"];
    self.descLabel.text = descText;
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - margin().width * 2;
    
    height += margin().height;
    
    if ([object objectForKey:@"image"]) {
        CGFloat objectWidth = 256.0;
        CGFloat objectHeight = 256.0;
        CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
        height += scaledHeight;
        
        height += margin().height;
    }
    
    CGSize labelSize = CGSizeZero;
    
    NSMutableString *nameText = [NSMutableString stringWithString:[object objectForKey:@"name"]];
    if ([object objectForKey:@"price"]) {
        [nameText appendFormat:@" - $%@", [object objectForKey:@"price"]];
    }
    labelSize = [PSStyleSheet sizeForText:nameText width:width style:@"cellTitleDarkLabel"];
    height += labelSize.height;
    
    NSString *descText = [object objectForKey:@"short_description"];
    if (descText && descText.length > 0) {
        labelSize = [PSStyleSheet sizeForText:descText width:width style:@"cellDescriptionDarkLabel"];
        height += labelSize.height;
    }
    
    height += margin().height;
    
    return height;
}

@end
