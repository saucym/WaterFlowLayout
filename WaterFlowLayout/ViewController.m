//
//  ViewController.m
//  WaterFlowLayout
//
//  Created by saucymqin on 2017/5/16.
//  Copyright © 2017年 saucym. All rights reserved.
//

#import "ViewController.h"
#import "WYWaterFlowLayout.h"
#import "CHTCollectionViewWaterfallLayout.h"

#define CELL_COUNT 100
#define CELL_IDENTIFIER @"WaterfallCell"
#define HEADER_IDENTIFIER @"WaterfallHeader"
#define FOOTER_IDENTIFIER @"WaterfallFooter"

@interface WYTestFlowLayout : UICollectionViewFlowLayout
@end
@implementation WYTestFlowLayout

- (void)prepareLayout {
    TICK;
    [super prepareLayout];
    TOCK;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    TICK;
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    TOCK;
    return array;
}

@end


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

@interface ViewController ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

//@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellSizes;
@property (nonatomic, strong) NSArray *waterCellSizes;

@end

@implementation ViewController

static CGFloat minimumLineSpacing = 1;
static CGFloat minimumInteritemSpacing = 1;

static UIEdgeInsets sectionInset;
static CGFloat headerHeight = 36;
static CGFloat headerWidth  = 36;
static CGFloat footerHeight = 0;

//- (UICollectionView *)collectionView {
//    if (!_collectionView) {
//        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[self.class layout]];
//        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        _collectionView.dataSource = self;
//        _collectionView.delegate = self;
//        [self.view addSubview:_collectionView];
//    }
//    
//    return _collectionView;
//}

+ (UICollectionViewLayout *)layout {
    NSInteger type = 2;
    sectionInset = UIEdgeInsetsMake(1, 0, 1, 0);
    
    UICollectionViewLayout *useLayout = nil;
    if (type == 0) {
        useLayout = [self testLayout];
    } else if (type == 1) {
        useLayout = [self waterfallLayout];
    } else {
        useLayout = [self waterFlowLayout];
    }
    
    return useLayout;
}

+ (UICollectionViewLayout *)waterFlowLayout {
    WYWaterFlowLayout *layout = [[WYWaterFlowLayout alloc] init];
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
    layout.minimumLineSpacing = minimumLineSpacing;
    layout.sectionInset = sectionInset;
    layout.headerReferenceSize = CGSizeMake(headerWidth, headerHeight);
    layout.footerReferenceSize = CGSizeMake(headerWidth, footerHeight);
    layout.headerInset = UIEdgeInsetsMake(10, 20, 30, 40);
    layout.miniItemWidth = 10;
    return layout;
}

+ (UICollectionViewLayout *)testLayout {
    WYTestFlowLayout *layout = [[WYTestFlowLayout alloc] init];
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
    layout.minimumLineSpacing = minimumLineSpacing;
    layout.sectionInset = sectionInset;
    layout.headerReferenceSize = CGSizeMake(headerWidth, headerHeight);
    layout.footerReferenceSize = CGSizeMake(headerWidth, footerHeight);
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return layout;
}

+ (UICollectionViewLayout *)waterfallLayout {
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.minimumColumnSpacing = minimumLineSpacing;
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
    layout.sectionInset = sectionInset;
    layout.columnCount  = 8;
    layout.headerHeight = headerHeight;
    layout.footerHeight = footerHeight;
    return layout;
}

static CGFloat aItem;

- (NSArray *)cellSizes {
    if (!_cellSizes) {
        NSInteger count = 10;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
//        for (NSInteger i = 0; i < 100; i++) {
//            [self addSizeToArray:array widthCount:1 + arc4random() % 5 heightCount:1 + arc4random() % 4];
//        }
        
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
        _waterCellSizes = [array copy];
    }
    
    return _cellSizes;
}

- (void)addSizeToArray:(NSMutableArray *)array widthCount:(NSInteger)wCount heightCount:(NSInteger)hCount {
    [array addObject:[NSValue valueWithCGSize:CGSizeMake(aItem * wCount + (wCount - 1) * minimumInteritemSpacing, aItem * hCount + (hCount - 1) * minimumLineSpacing)]];
}

#pragma mark - Life Cycle

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (instancetype)init {
    self = [self initWithCollectionViewLayout:[ViewController layout]];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    aItem = 30;
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [self.collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:HEADER_IDENTIFIER];
    [self.collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:FOOTER_IDENTIFIER];
    
    self.title = @"水流布局测试";
    
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

static NSInteger itemCount = 10;

- (void)vc_add_andRefreshLayout:(UIBarButtonItem *)item {
    if (item.tag == 0) {
        [self.collectionView setCollectionViewLayout:[self.class waterFlowLayout] animated:YES];
    } else {
        [self.collectionView setCollectionViewLayout:[self.class waterfallLayout] animated:YES];
    }
    return;
    
    itemCount += item.tag == 0 ? 1 : -1;
    if (item.tag == 0) {
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:itemCount - 1 inSection:0]]];
    } else {
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:itemCount inSection:0]]];
    }
    
    return;
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
//    return itemCount;
    return CELL_COUNT;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CHTCollectionViewWaterfallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.label.text = [NSString stringWithFormat:@"%ld", indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CHTCollectionViewWaterfallCell *reusableView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:HEADER_IDENTIFIER
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor lightGrayColor];
        reusableView.label.text = @"header";
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:FOOTER_IDENTIFIER
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor yellowColor];
        reusableView.label.text = @"footer";
    }
    
    return reusableView;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item % self.cellSizes.count] CGSizeValue];
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}

@end
