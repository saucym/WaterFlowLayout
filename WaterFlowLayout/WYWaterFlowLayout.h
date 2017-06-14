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

@protocol WYFlowLayoutProtocol <NSObject>

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

@end

@interface WYWaterFlowLayout : UICollectionViewLayout<WYFlowLayoutProtocol>

@property (nonatomic, assign) UIEdgeInsets headerInset; /**< default UIEdgeInsetsZero */
@property (nonatomic, assign) UIEdgeInsets footerInset; /**< default UIEdgeInsetsZero */
@property (nonatomic, assign) CGFloat miniItemWidth;    /**< default 10 这个值越大布局速度越快 */

#pragma mark - WYFlowLayoutProtocol
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionVertical TODO:UICollectionViewScrollDirectionHorizontal 还未实现
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

@end


@interface UICollectionViewFlowLayout (WYFlowLayoutProtocol)<WYFlowLayoutProtocol>
@end
