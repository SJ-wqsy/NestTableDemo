//
//  BottomContainerView.h
//  DemoNestViewController
//
//  Created by 斯斯扣 on 2022/3/7.
//

#import <UIKit/UIKit.h>

#import "ListViewController.h"
#import "BottomListContainerView.h"

@protocol BottomTableScrollableDelegate <NSObject>

- (void)enableBottomTableViewScroll:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BottomContainerView : UIView<JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) BottomListContainerView *listContainerView;
@property (nonatomic, strong) NSMutableDictionary *lists;
@property (nonatomic, assign) NSInteger currentIdx;

@property (nonatomic, weak) id<BottomTableScrollableDelegate> scrollableDelegate;
- (ListViewController *)currentList;

@end

NS_ASSUME_NONNULL_END
