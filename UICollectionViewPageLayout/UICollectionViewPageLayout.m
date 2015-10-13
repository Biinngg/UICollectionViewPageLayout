//
//  UICollectionViewPageLayout.m
//  UICollectionViewPageLayout
//
//  Created by Liu Bing on 9/22/15.
//  Copyright © 2015 UnixOSS. All rights reserved.
//

#import "UICollectionViewPageLayout.h"

@interface UICollectionViewPageLayout ()

@property (nonatomic, strong, nullable) NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *layoutInformation;
@property (nonatomic, assign) NSInteger pageCount;

@end


@implementation UICollectionViewPageLayout

- (void)prepareLayout
{
    if (self.itemSize.width == 0 || self.itemSize.height == 0 || self.collectionView == nil) {
        return;
    }
    
    self.collectionView.pagingEnabled = YES;
    
    NSInteger rowsPerPage = self.collectionView.bounds.size.height / self.itemSize.height;
    NSInteger columnsPerPage = self.collectionView.bounds.size.width / self.itemSize.width;
    NSInteger countsPerPage = rowsPerPage * columnsPerPage;
    
    NSMutableDictionary *information = [NSMutableDictionary dictionary];
    NSInteger index = 0;
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSInteger page = index / countsPerPage;
            NSInteger count = index % countsPerPage;
            NSInteger row = count / columnsPerPage;
            NSInteger column = count % columnsPerPage;
            information[indexPath] = [self attributesAtIndexPath:indexPath page:page row:row column:column];
            index++;
        }
    }
    self.layoutInformation = [information copy];
    self.pageCount = (index % countsPerPage != 0) ? index/countsPerPage+1 : index/countsPerPage;
}

- (UICollectionViewLayoutAttributes *)attributesAtIndexPath:(NSIndexPath *)indexPath page:(NSInteger)page row:(NSInteger)row column:(NSInteger)column
{
    CGFloat originX = page * self.collectionView.bounds.size.width + column * self.itemSize.width;
    CGFloat originY = self.itemSize.height * row;
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
    return attributes;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width * self.pageCount, self.collectionView.bounds.size.height);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> * _Nullable)layoutAttributesForElementsInRect:(CGRect)rect
{
    __block NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];
    [self.layoutInformation enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, UICollectionViewLayoutAttributes * _Nonnull obj, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [attributes addObject:obj];
        }
    }];
    return [attributes copy];
}

- (UICollectionViewLayoutAttributes * _Nullable)layoutAttributesForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
{
    return self.layoutInformation[indexPath];
}

@end
