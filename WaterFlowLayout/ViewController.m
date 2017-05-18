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

static CGFloat minimumLineSpacing = 1;
static CGFloat minimumInteritemSpacing = 1;

- (UICollectionView *)collectionView {
    if (!_collectionView) {
//        WYCollectionViewWaterfallLayout *layout = [[WYCollectionViewWaterfallLayout alloc] init];
        WYCollectionViewWaterfallLayout *layout = [[WYWaterFlowLayout alloc] init];
        layout.minimumInteritemSpacing = minimumInteritemSpacing;
        layout.minimumLineSpacing = minimumLineSpacing;
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
//        _collectionView.contentInset = UIEdgeInsetsMake(10, 15, 44, 15);
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
    if (!_cellSizes) {
        NSInteger count = 10;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        [self addSizeToArray:array widthCount:1 heightCount:3];
        [self addSizeToArray:array widthCount:1 heightCount:2];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:2 heightCount:3];
        [self addSizeToArray:array widthCount:2 heightCount:2];
        [self addSizeToArray:array widthCount:2 heightCount:1];
        [self addSizeToArray:array widthCount:3 heightCount:3];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        [self addSizeToArray:array widthCount:1 heightCount:1];
        
        _cellSizes = array;
    }
    
    return _cellSizes;
}

- (void)addSizeToArray:(NSMutableArray *)array widthCount:(NSInteger)wCount heightCount:(NSInteger)hCount {
    [array addObject:[NSValue valueWithCGSize:CGSizeMake(aItem * wCount + (wCount - 1) * minimumInteritemSpacing, aItem * hCount + (hCount - 1) * minimumLineSpacing)]];
}

#pragma mark - Life Cycle

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewDidLoad {
    aItem = 30;
    [super viewDidLoad];
    self.title = @"水流布局测试";
    [self.view addSubview:self.collectionView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(vc_refreshLayout)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"+" style:0 target:self action:@selector(vc_add_andRefreshLayout:)];
    [add setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:33]} forState:UIControlStateNormal];
    UIBarButtonItem *sub = [[UIBarButtonItem alloc] initWithTitle:@"-" style:0 target:self action:@selector(vc_add_andRefreshLayout:)];
    [sub setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:33]} forState:UIControlStateNormal];
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
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
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
