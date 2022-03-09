//
//  ListViewController.m
//  DemoNestViewController
//
//  Created by 斯斯扣 on 2022/3/7.
//

#import "ListViewController.h"

#import "MJRefresh.h"

#define COLOR_WITH_RGB(R,G,B,A) [UIColor colorWithRed:R green:G blue:B alpha:A]

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景颜色：随机色
    self.view.backgroundColor = COLOR_WITH_RGB(arc4random()%255/255.0, arc4random()%255/255.0, arc4random()%255/255.0, 1);
    
    [self.view addSubview:self.subTableView];
    [self.subTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

#pragma mark - JXCategoryListContentViewDelegate
/**
 实现 <JXCategoryListContentViewDelegate> 协议方法，返回该视图控制器所拥有的「视图」
 */
- (UIView *)listView {
    return self.view;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.subTableView) {
        if (self.canScroll == NO) {
            [self.subTableView setContentOffset:CGPointZero animated:NO];
        } else if(self.subTableView.contentOffset.y <= 0) {
            self.canScroll = NO;
            if (self.listScrollDelegate) {
                [self.listScrollDelegate enableBottomTableViewScroll:YES];
            }
        }
        
        self.subTableView.showsVerticalScrollIndicator = self.canScroll;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"subTable - %ld-%ld", indexPath.section, indexPath.row];
    cell.backgroundColor = self.view.backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (UITableView *)subTableView {
    if (!_subTableView) {
        _subTableView = [[SubTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _subTableView.backgroundColor = UIColor.cyanColor;
        if (@available(iOS 11.0, *)) {
            if ([_subTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                _subTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        _subTableView.dataSource = self;
        _subTableView.delegate = self;
        _subTableView.panGestureRecognizer.cancelsTouchesInView = NO;
        [_subTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        
        __weak typeof(self)weakSelf = self;
        _subTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            [weakSelf.subTableView.mj_footer endRefreshingWithNoMoreData];
        }];
    }

    return _subTableView;
}

@end
