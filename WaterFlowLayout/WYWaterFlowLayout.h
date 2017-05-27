//
//  WYWaterFlowLayout.h
//  WaterFlowLayout
//
//  Created by saucymqin on 2017/5/16.
//  Copyright © 2017年 saucym. All rights reserved.
//  从上到下，从左到右布局

#import <UIKit/UIKit.h>

@protocol UICollectionViewDelegateWaterFlowLayout <UICollectionViewDelegateFlowLayout>
@optional
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section;
@end

@interface WYWaterFlowLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;       /**< 竖直方向间距 deafult 1 */
@property (nonatomic) CGFloat minimumInteritemSpacing;  /**< 水平方向间距 default 1 */
@property (nonatomic, assign) CGSize itemSize;          /**< 每一个cell的默认大小 默认正方形 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;/**< default UIEdgeInsetsZero */

@property (nonatomic, assign) CGSize headerReferenceSize;
@property (nonatomic, assign) CGSize footerReferenceSize;
@property (nonatomic, assign) UIEdgeInsets headerInset; /**< default UIEdgeInsetsZero */
@property (nonatomic, assign) UIEdgeInsets footerInset; /**< default UIEdgeInsetsZero */

@property (nonatomic, assign) CGFloat miniItemWidth;    /**< default 30 */

@end
