//
//  WYCollectionViewWaterfallLayout.h
//  PhotoTool
//
//  Created by saucymqin on 16/3/11.
//  Copyright © 2016年 tencent. All rights reserved.
//  from  https://github.com/chiahsien/CHTCollectionViewWaterfallLayout  modified

#import <UIKit/UIKit.h>

/**
 *  Enumerated structure to define direction in which items can be rendered.
 */
typedef NS_ENUM (NSUInteger, WYTCollectionViewWaterfallLayoutItemRenderDirection) {
    WYTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst,
    WYTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight,
    WYTCollectionViewWaterfallLayoutItemRenderDirectionRightToLeft
};

/**
 *  Constants that specify the types of supplementary views that can be presented using a waterfall layout.
 */

@protocol WYCollectionViewDelegateWaterfallLayout <UICollectionViewDelegateFlowLayout>
@optional

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section;

@end

static CGFloat CHTFloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

@interface WYCollectionViewWaterfallLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize estimatedItemSize NS_AVAILABLE_IOS(8_0); // defaults to CGSizeZero - setting a non-zero size enables cells that self-size via -preferredLayoutAttributesFittingAttributes:
@property (nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionVertical
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

// Set these properties to YES to get headers that pin to the top of the screen and footers that pin to the bottom while scrolling (similar to UITableView).
@property (nonatomic) BOOL sectionHeadersPinToVisibleBounds NS_AVAILABLE_IOS(9_0);
@property (nonatomic) BOOL sectionFootersPinToVisibleBounds NS_AVAILABLE_IOS(9_0);

@property (nonatomic, assign) NSUInteger firstColumnMultiply;/**< 第一列加倍  default 0(不加倍) */
@property (nonatomic, assign) NSInteger  columnCount;        /**< 列数 */

@property (nonatomic, assign) UIEdgeInsets headerInset; /**< default UIEdgeInsetsZero */
@property (nonatomic, assign) UIEdgeInsets footerInset; /**< default UIEdgeInsetsZero */

/**
 *  @brief The direction in which items will be rendered in subsequent rows.
 *  @discussion
 *    The direction in which each item is rendered. This could be left to right (WYTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight), right to left (WYTCollectionViewWaterfallLayoutItemRenderDirectionRightToLeft), or shortest column fills first (WYTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst).
 *
 *    Default: WYTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
 */
@property (nonatomic, assign) WYTCollectionViewWaterfallLayoutItemRenderDirection itemRenderDirection;

/**
 *  @brief The minimum height of the collection view's content.
 *  @discussion
 *    The minimum height of the collection view's content. This could be used to allow hidden headers with no content.
 *
 *    Default: 0.f
 */
@property (nonatomic, assign) CGFloat minimumContentHeight;

/**
 *  @brief The calculated width of an item in the specified section.
 *  @discussion
 *    The width of an item is calculated based on number of columns, the collection view width, and the horizontal insets for that section.
 */
- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section;

@end
