//
//  BottomContainerView.m
//  DemoNestViewController
//
//  Created by 斯斯扣 on 2022/3/7.
//

#import "BottomContainerView.h"

@interface BottomContainerView ()<ListTableScrollDelegate>

@end

@implementation BottomContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _currentIdx = 0;
        [self addSubview:self.listContainerView];
        [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
    }
    
    return self;
}

- (ListViewController *)currentList {
    ListViewController *listVC = [self.lists objectForKey:[NSString stringWithFormat:@"%ld", _currentIdx]];
    if (listVC) {
        return listVC;
    }
    return nil;
}

#pragma mark - ListTableScrollDelegate

- (void)enableBottomTableViewScroll:(BOOL)enabled {
    if (self.scrollableDelegate) {
        [self.scrollableDelegate enableBottomTableViewScroll:enabled];
    }
}

#pragma mark - Custom Accessors
// 列表容器视图
- (BottomListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[BottomListContainerView alloc] initWithType:JXCategoryListContainerType_CollectionView delegate:self];
        if ([_listContainerView.scrollView isKindOfClass:[UICollectionView class]]) {
            UICollectionViewLayout *layout = ((UICollectionView *)_listContainerView.scrollView).collectionViewLayout;
            if (layout && [layout isKindOfClass:[UICollectionViewFlowLayout class]]) {
                [(UICollectionViewFlowLayout *)layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            }
        }
    }
    return _listContainerView;
}

#pragma mark - JXCategoryListContainerViewDelegate
// 返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return 5;
}

// 返回各个列表菜单下的实例，该实例需要遵守并实现 <JXCategoryListContentViewDelegate> 协议
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    ListViewController *list = [[ListViewController alloc] init];
    list.listScrollDelegate = self;
    [self.lists setObject:list forKey:[NSString stringWithFormat:@"%ld", index]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SubListsUpdate" object:self.lists];
    return list;
}

- (void)listContainerViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self isKindOfClass:[BottomContainerView class]]) {
        CGFloat index = scrollView.contentOffset.x/scrollView.bounds.size.width;
        CGFloat absIndex = fabs(index - self.currentIdx);
        if (absIndex >= 1) {
            //”快速滑动的时候，只响应最外层VC持有的scrollView“，说实话，完全可以不用处理这种情况。如果你们的产品经理坚持认为这是个问题，就把这块代码加上吧。
            //嵌套使用的时候，最外层的VC持有的scrollView在翻页之后，就断掉一次手势。解决快速滑动的时候，只响应最外层VC持有的scrollView。子VC持有的scrollView却没有响应
            self.listContainerView.scrollView.panGestureRecognizer.enabled = NO;
            self.listContainerView.scrollView.panGestureRecognizer.enabled = YES;
            _currentIdx = floor(index);
        }
    }
}

- (NSMutableDictionary *)lists {
    if (!_lists) {
        _lists = [NSMutableDictionary dictionary];
    }
    
    return _lists;
}

@end
