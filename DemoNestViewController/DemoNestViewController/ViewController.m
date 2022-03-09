//
//  ViewController.m
//  DemoNestViewController
//
//  Created by 斯斯扣 on 2022/3/4.
//

#import "ViewController.h"

#import "BottomTableView.h"
#import "BottomContainerView.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, BottomTableScrollableDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) UIView *nav;

@property (nonatomic, strong) BottomTableView *bottomTableView;

@property (nonatomic, assign) NSInteger currentIdx;
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) BottomContainerView *containerView;

@property (nonatomic, strong) ListViewController *currentList;

@property (nonatomic, assign) BOOL enableBottomScroll;
@property (nonatomic, assign) CGFloat originOffsetY;
@property (nonatomic, assign) CGFloat beginContentOffsetY;
@property (nonatomic, assign) CGFloat nowSubOffsetY;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _enableBottomScroll = YES;
    _currentIdx = 0;
    
    _nav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _nav.backgroundColor = UIColor.redColor;
    [self.view addSubview:_nav];
    
    _bottomTableView = [[BottomTableView alloc] initWithFrame:CGRectMake(0, _nav.frame.origin.y + _nav.frame.size.height, kScreenWidth, kScreenHeight - _nav.frame.origin.y - _nav.frame.size.height) style:UITableViewStyleGrouped];
    if (@available(iOS 11.0, *)) {
        if ([_bottomTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            _bottomTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    _bottomTableView.panGestureRecognizer.cancelsTouchesInView = NO;
    _bottomTableView.dataSource = self;
    _bottomTableView.delegate = self;
    _bottomTableView.tableHeaderView = [UIView new];
    _bottomTableView.tableFooterView = [UIView new];
    _bottomTableView.estimatedSectionHeaderHeight = 0.01;
    _bottomTableView.estimatedSectionFooterHeight = 0.01;
    [_bottomTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [_bottomTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"containerListCell"];
    
    [self.view addSubview:_bottomTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subListsUpdate:) name:@"SubListsUpdate" object:nil];
}

- (void)subListsUpdate:(NSNotification *)notifi {
    self.bottomTableView.lists = self.containerView.lists;
}

#pragma mark - scrollViewDidScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bottomTableView) {
        CGFloat offsetY = self.bottomTableView.contentOffset.y;
        
        _originOffsetY = [self.bottomTableView rectForSection:2].origin.y;
        
        if (!_enableBottomScroll) {
            _bottomTableView.contentOffset = CGPointMake(0, _originOffsetY);
        } else {
            if (offsetY >= _originOffsetY) {
                _bottomTableView.contentOffset = CGPointMake(0, _originOffsetY);
                self.enableBottomScroll = NO;
                self.currentList.canScroll = YES;
            } else {
                if (self.currentList.canScroll == YES) {
                    CGFloat subOffsetY = self.currentList.subTableView.contentOffset.y;
                    if (subOffsetY > self.nowSubOffsetY) {
                        CGFloat offY = subOffsetY - _nowSubOffsetY;
                        CGFloat bottomOffY = _beginContentOffsetY + offY;
//                        [self.currentList.subTableView setContentOffset:CGPointMake(0, _nowSubOffsetY) animated:NO];
//                        [self.bottomTableView setContentOffset:CGPointMake(0, bottomOffY) animated:NO];
                        self.currentList.subTableView.contentOffset = CGPointMake(0, _nowSubOffsetY);
                        _bottomTableView.contentOffset = CGPointMake(0, bottomOffY);
                        _beginContentOffsetY = bottomOffY;
                    } else {
                        _nowSubOffsetY = subOffsetY;
                        _bottomTableView.contentOffset = CGPointMake(0, _beginContentOffsetY);
                    }
                }
            }
        }
        
        self.bottomTableView.showsVerticalScrollIndicator = self.enableBottomScroll;
    }
}

#pragma mark - BottomTableScrollableDelegate
- (void)enableBottomTableViewScroll:(BOOL)enabled {
    if (self.enableBottomScroll == enabled) {
        return;
    }
    self.enableBottomScroll = enabled;
    _beginContentOffsetY = self.bottomTableView.contentOffset.y;
}

#pragma mark - JXCategoryViewDelegate

// 点击选中或者滚动选中都会调用该方法。适用于只关心选中事件，不关心具体是点击还是滚动选中的。
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    // 侧滑手势处理
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
    if (_currentIdx != index) {
        if (!_enableBottomScroll) {
            self.enableBottomScroll = YES;
        }
        
        _currentIdx = index;
        _containerView.currentIdx = _currentIdx;
        
        self.beginContentOffsetY = self.bottomTableView.contentOffset.y;
        self.nowSubOffsetY = self.currentList.subTableView.contentOffset.y;
    }
}

// 滚动选中的情况才会调用该方法
- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) {
        return 1;
    } else if (section == 1) {
        return 10;
    } else if (section == 2) {
        return 1;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return kScreenHeight - self.nav.frame.origin.y - self.nav.frame.size.height - 50;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    view.backgroundColor = [UIColor blackColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"containerListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cell.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(cell.contentView);
        }];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if (indexPath.section == 2) {
            cell.textLabel.text = @"";
            [cell.contentView addSubview:self.categoryView];
            [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(cell.contentView);
            }];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, indexPath.row];
            cell.backgroundColor = UIColor.greenColor;
        }
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - getter
- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.backgroundColor = UIColor.blueColor;
        _categoryView.defaultSelectedIndex = _currentIdx;
        _categoryView.frame = CGRectMake(0, 0, kScreenWidth, 50);
        _categoryView.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        _categoryView.titleSelectedFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:15];
        _categoryView.titleColor = UIColor.whiteColor;
        _categoryView.titleSelectedColor = UIColor.whiteColor;
        _categoryView.titles = @[@"第一页", @"第二页", @"第三页", @"第四页", @"第五页"];
        _categoryView.delegate = self;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.backgroundColor = UIColor.whiteColor;
        lineView.indicatorColor = UIColor.whiteColor;
        lineView.indicatorHeight = 2;
        lineView.indicatorCornerRadius = 1;
        lineView.indicatorWidth = JXCategoryViewAutomaticDimension;
        /// 也可以试试固定宽度
        lineView.indicatorWidth = 15;
        /// 设置指示器延长 style
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        
        _categoryView.indicators = @[lineView];
        
        _categoryView.listContainer = self.containerView.listContainerView;
    }
    
    return _categoryView;
}

- (BottomContainerView *)containerView {
    if (!_containerView) {
        _containerView = [[BottomContainerView alloc] initWithFrame:CGRectZero];
        _containerView.scrollableDelegate = self;
        _containerView.currentIdx = _currentIdx;
    }
    
    return _containerView;
}

- (ListViewController *)currentList {
    return self.containerView.currentList;
}

@end
