//
//  InstagramPickerViewCell.m
//  Grid
//
//  Created by Peter Shih on 12/21/12.
//
//

#import "InstagramPickerViewCell.h"

#import "PSCachedImageView.h"

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(4.0, 4.0);
    } else {
        return CGSizeMake(4.0, 4.0);
    }
}

@interface InstagramPickerViewCell ()

@property (nonatomic, strong) PSCachedImageView *imageView;

@end

@implementation InstagramPickerViewCell


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
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - margin().width * 2;
    CGFloat top = margin().height;
    CGFloat left = margin().width;
    
    // all squares
    self.imageView.frame = CGRectMake(left, top, width, width);
    
    top += self.imageView.height + margin().height;
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [super collectionView:collectionView fillCellWithObject:object atIndex:index];
    
    NSDictionary *image = [[self.object objectForKey:@"images"] objectForKey:@"standard_resolution"];
    NSDictionary *thumb = [[self.object objectForKey:@"images"] objectForKey:@"thumbnail"];
    NSString *origUrl = [image objectForKey:@"url"];
    NSString *thumbUrl = [thumb objectForKey:@"url"];
    
    // Photo
    [self.imageView setThumbnailURL:[NSURL URLWithString:thumbUrl]];
    [self.imageView setOriginalURL:[NSURL URLWithString:origUrl]];
    
    [self.imageView loadImageWithURL:self.imageView.originalURL cacheType:PSURLCacheTypePermanent];
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - margin().width * 2;
    
    height += margin().height;
    
    height += width;
    
    height += margin().height;
    
    return height;
}


@end
