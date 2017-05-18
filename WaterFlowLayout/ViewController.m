//
//  ViewController.m
//  WaterFlowLayout
//
//  Created by saucymqin on 2017/5/16.
//  Copyright © 2017年 neutron. All rights reserved.
//

#import "ViewController.h"
#import "WYCollectionViewWaterfallLayout.h"
#import "WYWaterFlowLayout.h"

#define CELL_COUNT 300
#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

@interface CHTCollectionViewWaterfallCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@end@implementation CHTCollectionViewWaterfallCell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_label];
    }
    return self;
}
@end

@interface ViewController ()<UICollectionViewDataSource, WYCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellSizes;

@end

@implementation ViewController


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        WYCollectionViewWaterfallLayout *layout = [[WYWaterFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.headerReferenceSize = CGSizeMake(0, 15);
        layout.footerReferenceSize = CGSizeMake(0, 10);
        if ([layout isKindOfClass:[WYCollectionViewWaterfallLayout class]]) {
            layout.sectionHeadersPinToVisibleBounds = YES;
            layout.columnCount = 8;
            layout.firstColumnMultiply = 1;
        }
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.contentInset = UIEdgeInsetsMake(100, 150, 40, 20);
        [_collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:HEADER_IDENTIFIER];
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:FOOTER_IDENTIFIER];
    }
    return _collectionView;
}

static CGFloat aItem;

- (NSArray *)cellSizes {
    CGFloat item = aItem;
    if (!_cellSizes) {
        NSInteger count = 10;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        [array addObject:[NSValue valueWithCGSize:CGSizeMake(item * 1, item * 3)]];
        [array addObject:[NSValue valueWithCGSize:CGSizeMake(item * 3, item * 3)]];
        for (NSInteger i = 0; i < count; i ++) {
            [array addObject:[NSValue valueWithCGSize:CGSizeMake(item * (i % 3 + 1), item * ((i + 1) % 3 + 1))]];
        }
        
        _cellSizes = array;
    }
    return _cellSizes;
}

#pragma mark - Life Cycle

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewDidLoad {
    aItem = 30;
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(vc_refreshLayout)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(vc_add_andRefreshLayout:)];
    UIBarButtonItem *sub = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(vc_add_andRefreshLayout:)];
    sub.tag = 1;
    self.navigationItem.leftBarButtonItems = @[add, sub];
}

- (void)vc_refreshLayout {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)vc_add_andRefreshLayout:(UIBarButtonItem *)item {
    aItem += item.tag == 0 ? 10 : -10;
    _cellSizes = nil;
    [UIView animateWithDuration:0.3 animations:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return 7;
    return CELL_COUNT;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
    return 150;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CHTCollectionViewWaterfallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.label.backgroundColor = [UIColor lightGrayColor];
    cell.label.text = [NSString stringWithFormat:@"%ld", indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:HEADER_IDENTIFIER
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor yellowColor];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:FOOTER_IDENTIFIER
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor blueColor];
    }
    
    return reusableView;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item % self.cellSizes.count] CGSizeValue];
}

@end
