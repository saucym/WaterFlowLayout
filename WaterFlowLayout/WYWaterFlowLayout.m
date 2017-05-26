//
//  WYWaterFlowLayout.m
//  WaterFlowLayout
//
//  Created by saucymqin on 2017/5/16.
//  Copyright © 2017年 neutron. All rights reserved.
//

#import "WYWaterFlowLayout.h"

static CGFloat WYWaterFlowLayoutFloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

@interface WYSpaceIndexSet : NSMutableIndexSet //用于保存空位
@property (nonatomic, assign) CGRect itemFrame;
@end

@implementation WYSpaceIndexSet

+ (instancetype)indexSetWithFrame:(CGRect)frame maxWidth:(CGFloat)maxWidth {
    WYSpaceIndexSet *set = [[self alloc] init];
    set.itemFrame = frame;
    [set addIndexesInRange:NSMakeRange(0, maxWidth)];
    
    return set;
}

@end

@interface WYWaterFlowLayout ()

@property (nonatomic, weak) id <UICollectionViewDelegateWaterFlowLayout> delegate;

@property (nonatomic, strong) NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *itemsAttributes;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *headersAttribute;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *footersAttribute;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *allAttributes;
@property (nonatomic, strong) NSMutableArray *unionRects;/// Array to store union rectangles
@property (nonatomic, assign) CGFloat maxContentBottom;

@end

@implementation WYWaterFlowLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

#pragma mark - Init
- (void)commonInit {
    _minimumLineSpacing  = 1;
    _minimumInteritemSpacing  = 1;
    _headerInset  = UIEdgeInsetsZero;
    _footerInset  = UIEdgeInsetsZero;
    _columnCount  = 4;
    _miniItemWidth = 10;
    [self recalculateItemSizeWithColumnCount:_columnCount];
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

#pragma mark - Public

#pragma mark - Private Accessors

- (NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *)itemsAttributes {
    if (!_itemsAttributes) {
        _itemsAttributes = [NSMutableArray array];
    }
    
    return _itemsAttributes;
}

- (NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *)headersAttribute {
    if (!_headersAttribute) {
        _headersAttribute = [NSMutableDictionary dictionary];
    }
    
    return _headersAttribute;
}

- (NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *)footersAttribute {
    if (!_footersAttribute) {
        _footersAttribute = [NSMutableDictionary dictionary];
    }
    
    return _footersAttribute;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)allAttributes {
    if (!_allAttributes) {
        _allAttributes = [NSMutableArray array];
    }
    
    return _allAttributes;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (id <UICollectionViewDelegateWaterFlowLayout> )delegate {
    return (id <UICollectionViewDelegateWaterFlowLayout> )self.collectionView.delegate;
}

- (void)recalculateItemSizeWithColumnCount:(NSInteger)columnCount {
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - self.sectionInset.left - self.sectionInset.right - self.collectionView.contentInset.left - self.collectionView.contentInset.right - (columnCount - 1) * self.minimumInteritemSpacing) / columnCount;
    self.itemSize  = CGSizeMake(WYWaterFlowLayoutFloorCGFloat(width), WYWaterFlowLayoutFloorCGFloat(width));
}

- (void)prepareLayout {
    TICK;
    [super prepareLayout];
    
    [self.itemsAttributes removeAllObjects];
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.allAttributes removeAllObjects];
    [self.unionRects removeAllObjects];
    self.maxContentBottom = 0;
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    CGFloat const maxContentWidth = self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
    CGFloat const mini_x = self.collectionView.contentInset.left;
    
    CGFloat   top = 0;//self.collectionView.contentInset.top;////这里不需要加top，因为已经体现到bounds上了
    UICollectionViewLayoutAttributes *attributes;
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        /**< 1. Section header */
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section].height;
        } else {
            headerHeight = self.headerReferenceSize.height;
        }
        
        if (headerHeight > 0) {
            UIEdgeInsets headerInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
                headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
            } else {
                headerInset = self.headerInset;
            }
            
            top += headerInset.top;
            
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left + mini_x, top, maxContentWidth - headerInset.left - headerInset.right, headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allAttributes addObject:attributes];
            
            top += headerHeight + headerInset.bottom;
        }
        
        /**< 2. Section items */
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray<UICollectionViewLayoutAttributes *> *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        if (itemCount > 0) {
            CGFloat minimumLineSpacing;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
                minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
            } else {
                minimumLineSpacing = self.minimumLineSpacing;
            }
            
            CGFloat columnSpacing = self.minimumInteritemSpacing;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
                columnSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
            }
            
            UIEdgeInsets sectionInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            } else {
                sectionInset = self.sectionInset;
            }
            
            CGFloat const maxWidth = maxContentWidth - sectionInset.left - sectionInset.right;
            top += sectionInset.top;
            NSMutableArray<WYSpaceIndexSet *> *emptySpaces = [NSMutableArray arrayWithCapacity:20];//用于缓存当前的布局状态
            [emptySpaces addObject:[WYSpaceIndexSet indexSetWithFrame:CGRectMake(0, top, 0, 0) maxWidth:maxWidth]];
            
            for (NSInteger item = 0; item < itemCount; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                
                CGSize itemSize;
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                    itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                } else {
                    itemSize = self.itemSize;
                }
                
                itemSize.width  += _minimumInteritemSpacing;
                itemSize.height += minimumLineSpacing;
                if (itemSize.width > maxWidth && maxWidth > 0) {
                    itemSize.height /= itemSize.width / maxWidth;
                    itemSize.width = maxWidth;
                }
                
                CGRect rect = [self willAddItemWithSize:itemSize maxWidth:maxWidth maxTop:&top withSpaces:emptySpaces];
                rect.origin.x   += _minimumInteritemSpacing + sectionInset.left;
                rect.size.width -= _minimumInteritemSpacing;
                
                rect.origin.y    += minimumLineSpacing;
                rect.size.height -= minimumLineSpacing;
                
                attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = rect;
                [itemAttributes addObject:attributes];
                [self.allAttributes addObject:attributes];
            }
            
            top += sectionInset.bottom;
        }
        
        [self.itemsAttributes addObject:itemAttributes];
        
        /**< 3. Section footer */
        CGFloat footerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section].height;
        } else {
            footerHeight = self.footerReferenceSize.height;
        }
        
        if (footerHeight > 0) {
            UIEdgeInsets footerInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
                footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
            } else {
                footerInset = self.footerInset;
            }
            
            top += footerInset.top;
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left + mini_x, top, maxContentWidth - footerInset.left - footerInset.right, footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allAttributes addObject:attributes];
            
            top += footerHeight + footerInset.bottom;
        }
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)
    
    self.maxContentBottom = top;
    
    // 把20个作为一组计算出一个超集rect，主要用来加上滑动时定位
    NSInteger idx = 0;
    NSInteger itemCounts = [self.allAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
    
    TOCK;
}

- (CGSize)collectionViewContentSize {
    CGSize contentSize = CGSizeZero;
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return contentSize;
    }
    
    contentSize.width = self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
    contentSize.height = self.maxContentBottom;// + self.collectionView.contentInset.bottom; //这里不需要加bottom，因为已经体现到bounds上了
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.itemsAttributes count]) {
        return nil;
    }
    
    if (path.item >= [self.itemsAttributes[path.section] count]) {
        return nil;
    }
    
    return (self.itemsAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        attribute = self.headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    
    return attribute;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    TICK;
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allAttributes.count);
            break;
        }
    }
    
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
     }
    
    TOCK;
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    
    return NO;
}

- (CGRect)willAddItemWithSize:(CGSize)size maxWidth:(CGFloat)maxWidth maxTop:(CGFloat *)p_top withSpaces:(NSMutableArray<WYSpaceIndexSet *> *)emptySpaces { //TODO:可以仔细研究下这里面的计算 看是否有优化空间，这里调用太频繁了
    __block CGPoint point = CGPointZero;
    //对比已有的空位找到一个能放下的size空位
    [emptySpaces enumerateObjectsUsingBlock:^(WYSpaceIndexSet *set, NSUInteger idx, BOOL *stop) {
        [set enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stopSet) {
            if (range.length >= size.width) {
                point.x = range.location;
                point.y = CGRectGetMaxY(set.itemFrame);
                *stop = YES;
                *stopSet = YES;
            }
        }];
    }];
    
    CGRect rect = (CGRect){point, size};
    
    WYSpaceIndexSet *nSet = [WYSpaceIndexSet indexSetWithFrame:rect maxWidth:maxWidth];
    
    NSMutableIndexSet *shouldDeleteSet = [NSMutableIndexSet indexSet];
    __block CGFloat top = CGRectGetMaxY(nSet.itemFrame);
    //对空位进行处理，比它低的空位被它占用，比他高的会占用它的空位
    [emptySpaces enumerateObjectsUsingBlock:^(WYSpaceIndexSet * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectGetMaxY(obj.itemFrame) > CGRectGetMaxY(nSet.itemFrame)) {//比他高的会占用它的空位
            [nSet removeIndexesInRange:NSMakeRange(obj.itemFrame.origin.x, obj.itemFrame.size.width)];
        } else if (CGRectGetMaxY(obj.itemFrame) < CGRectGetMaxY(nSet.itemFrame)) { //比它低的空位被它占用
            [obj removeIndexesInRange:NSMakeRange(nSet.itemFrame.origin.x, nSet.itemFrame.size.width)];
            
            if (obj.count <= self.miniItemWidth) { //这一行已经没有空位了需要删除掉
                [shouldDeleteSet addIndex:idx];
            }
        }
        
        if (CGRectGetMaxY(obj.itemFrame) > top) {
            top = CGRectGetMaxY(obj.itemFrame);
        }
    }];
    
    if (p_top) {
        *p_top = top;
    }
    
    if (shouldDeleteSet.count > 0) {//删除没空间的空位
        [emptySpaces removeObjectsAtIndexes:shouldDeleteSet];
    }
    
    [emptySpaces addObject:nSet];
    
    //按从低到高排序
    [emptySpaces sortUsingComparator:^NSComparisonResult(WYSpaceIndexSet *obj1, WYSpaceIndexSet *obj2) {
        if (CGRectGetMaxY(obj1.itemFrame) == CGRectGetMaxY(obj2.itemFrame)) {
            return obj1.itemFrame.origin.x > obj2.itemFrame.origin.x;
        }
        
        return CGRectGetMaxY(obj1.itemFrame) > CGRectGetMaxY(obj2.itemFrame);
    }];
    
    return rect;
}

@end
