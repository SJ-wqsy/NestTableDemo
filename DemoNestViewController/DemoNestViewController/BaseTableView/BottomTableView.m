//
//  BottomTableView.m
//  DemoNestViewController
//
//  Created by 斯斯扣 on 2022/3/4.
//

#import "BottomTableView.h"
#import <WebKit/WebKit.h>

@interface BottomTableView ()

@end

@implementation BottomTableView

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    id view = otherGestureRecognizer.view;
    if ([[view superview] isKindOfClass:[WKWebView class]]) {
        view = [view superview];
    }
    
    NSArray *allLists = self.lists.allValues;
    for (UIViewController *obj in allLists) {
        if (obj && [obj isKindOfClass:[UIViewController class]]) {
            if ([obj.view.subviews containsObject:view]) {
                return YES;
            }
        }
    }
    
    if (view == self) {
        return YES;
    }
    
    return NO;
}


@end
