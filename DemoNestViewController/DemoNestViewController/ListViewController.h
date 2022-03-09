//
//  ListViewController.h
//  DemoNestViewController
//
//  Created by 斯斯扣 on 2022/3/7.
//

#import <UIKit/UIKit.h>

#import "JXCategoryListContainerView.h"

#import "SubTableView.h"


@protocol ListTableScrollDelegate <NSObject>

- (void)enableBottomTableViewScroll:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ListViewController : UIViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, strong) SubTableView *subTableView;

@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, weak) id<ListTableScrollDelegate> listScrollDelegate;

@end

NS_ASSUME_NONNULL_END
