//
//  WYWaterFlowLayout.m
//  WaterFlowLayout
//
//  Created by saucymqin on 2017/5/16.
//  Copyright © 2017年 saucym. All rights reserved.
//

#import "WYWaterFlowLayout.h"

#ifndef TICK
#define TICK
#endif

#ifndef TOCK
#define TOCK
#endif

static CGFloat p_scale = 2;

static CGFloat WYWaterFlowLayoutFloorCGFloat(CGFloat value) {
    return floor(value * p_scale) / p_scale;
}

static NSInteger WYWaterPixFromRound(CGFloat value) {//size转换成像素点
    return round(value * p_scale);
}

@interface WYSpaceIndexSet : NSMutableIndexSet //用于保存一个矩形的位置和大小以及矩形底部那条线上的空位 1像素点为1个单位
@property (nonatomic, readonly) CGFloat maxY;
@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat width;
@end

@implementation WYSpaceIndexSet

+ (instancetype)indexSetWithFrame:(CGRect)frame maxWidth:(CGFloat)maxWidth {
    WYSpaceIndexSet *set = [[self alloc] init];
    set->_maxY = WYWaterPixFromRound(CGRectGetMaxY(frame));
    set->_x = WYWaterPixFromRound(frame.origin.x);
    set->_width = WYWaterPixFromRound(frame.size.width);
    [set addIndexesInRange:NSMakeRange(0, WYWaterPixFromRound(maxWidth))];
    
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
@property (nonatomic, assign) NSInteger  columnCount;   /**< 列数 default 4 */

@property (nonatomic, assign) BOOL isSectionHeadersPinToVisibleChangeBounds;

#pragma mark - WYFlowLayoutProtocol
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionVertical TODO:UICollectionViewScrollDirectionHorizontal 还未实现
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic) BOOL sectionHeadersPinToVisibleBounds;
@property (nonatomic) BOOL sectionFootersPinToVisibleBounds;/**< TODO:还未实现 */

@end

@implementation WYWaterFlowLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

#pragma mark - Init
- (void)commonInit {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p_scale = [UIScreen mainScreen].scale;
    });
    
    _minimumLineSpacing  = 1;
    _minimumInteritemSpacing  = 1;
    _scrollDirection = UICollectionViewScrollDirectionVertical;
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

- (void)prepareLayout { //TODO: 使用UICollectionViewLayoutInvalidationContext优化布局计算 这个网站有详细的介绍 http://www.jianshu.com/p/97e930658671
    TICK;
    [super prepareLayout];
    
    if (self.isSectionHeadersPinToVisibleChangeBounds) {
        self.isSectionHeadersPinToVisibleChangeBounds = NO;
        return;
    }
    
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
            attributes.frame = CGRectMake(headerInset.left, top, maxContentWidth - headerInset.left - headerInset.right, headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allAttributes addObject:attributes];
            
            top += headerHeight + headerInset.bottom;
        }
        
        /**< 2. Section items */
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray<UICollectionViewLayoutAttributes *> *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        if (itemCount > 0) {
            CGFloat minimumLineSpacing = self.minimumLineSpacing;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
                minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
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
                
                itemSize.height += minimumLineSpacing;
                if (itemSize.width > maxWidth && maxWidth > 0) {
                    itemSize.height /= itemSize.width / maxWidth;
                    itemSize.width = maxWidth;
                }
                
                CGRect rect = [self calculationRectWithItemWithSize:itemSize maxWidth:maxWidth maxTop:&top withSpaces:emptySpaces];
                rect.origin.x   += sectionInset.left;
                rect.size.width -= columnSpacing;
                
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
            attributes.frame = CGRectMake(footerInset.left, top, maxContentWidth - footerInset.left - footerInset.right, footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allAttributes addObject:attributes];
            
            top += footerHeight + footerInset.bottom;
        }
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)
    
    self.maxContentBottom = top;
    
    // 把20个作为一组计算出一个超集rect，主要用来加速滑动时定位
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
        attribute = [self attributesHeaderPinToVisibleBoundsAttributs:attribute] ? : attribute;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    
    return attribute;
}

- (UICollectionViewLayoutAttributes *)attributesHeaderPinToVisibleBoundsAttributs:(UICollectionViewLayoutAttributes *)attribute {
    if (self.sectionHeadersPinToVisibleBounds && attribute.representedElementKind == UICollectionElementKindSectionHeader) {
        CGPoint nextHeaderOrigin = CGPointMake(INFINITY, INFINITY);
        if (attribute.indexPath.section + 1 < self.headersAttribute.count) {
            UICollectionViewLayoutAttributes *nextHeaderAttributes = self.headersAttribute[@(attribute.indexPath.section + 1)];
            nextHeaderOrigin = nextHeaderAttributes.frame.origin;
        }
        
        CGRect frame = attribute.frame;
        frame.origin.y = MIN(MAX(self.collectionView.contentOffset.y + self.collectionView.contentInset.top + self.headersPinToVisibleOffset, frame.origin.y), nextHeaderOrigin.y - CGRectGetHeight(frame));
        UICollectionViewLayoutAttributes *nAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:attribute.representedElementKind withIndexPath:attribute.indexPath];
        nAttribute.zIndex = 1024;
        nAttribute.frame = frame;
        return nAttribute;
    }
    
    return nil;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    TICK;
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrs = [NSMutableArray array];
    
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
    
    BOOL hasHeader = NO;
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attribute = self.allAttributes[i];
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            attribute = [self attributesHeaderPinToVisibleBoundsAttributs:attribute] ? : attribute;
            [attrs addObject:attribute];
            if (attribute.representedElementKind == UICollectionElementKindSectionHeader && attribute.indexPath.section == attrs.firstObject.indexPath.section) {
                hasHeader = YES;
            }
        }
    }
    
    if (!hasHeader && self.sectionHeadersPinToVisibleBounds) {
        UICollectionViewLayoutAttributes *attribute = self.headersAttribute[@(attrs.firstObject.indexPath.section)];
        attribute = [self attributesHeaderPinToVisibleBoundsAttributs:attribute] ? : attribute;
        if (attribute) {
            [attrs addObject:attribute];//一组里面cell太多的时候可能header会不在显示rect里面，这里把它单独加一次
        }
    }
    
    TOCK;
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    BOOL isWidthChange = CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds);
    if (self.sectionHeadersPinToVisibleBounds || isWidthChange) {
        self.isSectionHeadersPinToVisibleChangeBounds = !isWidthChange;
        return YES;
    }
    
    return NO;
}

//根据size计算新item的位置，并且更新空白位置信息  TODO:为了性能暂时不考虑size.width < maxWidth的情况，业务测自己保证大小
- (CGRect)calculationRectWithItemWithSize:(CGSize)size maxWidth:(CGFloat)maxWidth maxTop:(CGFloat *)p_top withSpaces:(NSMutableArray<WYSpaceIndexSet *> *)spaceArray {
    __block CGPoint point_pix = CGPointZero;
    __block NSInteger spaceIndex = 0;
    CGSize size_pix = CGSizeMake(WYWaterPixFromRound(size.width), WYWaterPixFromRound(size.height));
    /**< 对比已有的空位找到一个能放下size大小的空位 (这里绝对能找到，因为有一个顶部空位做初始值) */
    [spaceArray enumerateObjectsUsingBlock:^(WYSpaceIndexSet *obj, NSUInteger idx, BOOL *stop) {
        [obj enumerateRangesUsingBlock:^(NSRange range, BOOL *stopSet) {
            if (range.length >= size_pix.width) {
                point_pix.x = range.location;
                point_pix.y = obj.maxY;
                spaceIndex = idx + 1; //找到一个初始位置，这个位置是可能比实际需要放的位置要靠前，后面枚举的时候再进一步调整该位置
                *stop = YES;
                *stopSet = YES;
            }
        }];
    }];
    
    size_pix.width += WYWaterPixFromRound(self.minimumInteritemSpacing);
    CGRect rect = CGRectMake(point_pix.x / p_scale, point_pix.y / p_scale, size_pix.width / p_scale, size_pix.height / p_scale);
    WYSpaceIndexSet *spaceObj = [WYSpaceIndexSet indexSetWithFrame:rect maxWidth:maxWidth];
    
    NSMutableIndexSet *shouldDeleteSet = [NSMutableIndexSet indexSet];
    __block CGFloat top = spaceObj.maxY;
    /**< 对空位进行处理，比它低的空位被它占用，比他高的会占用它的空位 */
    [spaceArray enumerateObjectsUsingBlock:^(WYSpaceIndexSet *obj, NSUInteger idx, BOOL *stop) {//spaceArray 是有序的，这里是按低到高枚举
        if (obj.maxY > spaceObj.maxY) {
            [spaceObj removeIndexesInRange:NSMakeRange(obj.x, obj.width)];//比他高的会占用它的空位
        } else if (obj.maxY < spaceObj.maxY) {
            [obj removeIndexesInRange:NSMakeRange(spaceObj.x, spaceObj.width)];//比它低的空位被它占用
            if (obj.count < WYWaterPixFromRound(self.miniItemWidth + self.minimumInteritemSpacing)) { //这一行已经没有空位了需要删除掉
                [shouldDeleteSet addIndex:idx];
            }
            
            if (spaceIndex < idx + 1) {
                spaceIndex = idx + 1; //调整位置到比他它矮的位置后面
            }
        } else if (spaceIndex < idx + 1) {
            if (obj.x < spaceObj.x) {//跟它一样高并且在它左边，那么它的位置可以调整
                spaceIndex = idx + 1;
            }
        }
        
        if (obj.maxY > top) {
            top = obj.maxY;
        }
    }];
    
    [spaceArray insertObject:spaceObj atIndex:spaceIndex];
    if (shouldDeleteSet.count > 0) {//删除没空间的空位
        [spaceArray removeObjectsAtIndexes:shouldDeleteSet];
    }
    
    if (p_top) {
        *p_top = top / p_scale;
    }
    
    return rect;
}

@end

@implementation WYWaterFlowLayout (WYFlowLayoutProtocol)
@end

@implementation UICollectionViewFlowLayout (WYFlowLayoutProtocol)
@end

