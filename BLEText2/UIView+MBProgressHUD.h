//
//  UIView+MBProgressHUD.h
//  block
//
//  Created by caixiang on 2017/3/17.
//  Copyright © 2017年 蔡翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MBProgressHUD)

/**
 *  只带文字提示
 */
- (void)showTitle:(NSString *)title;
- (void)showTitle:(NSString *)title navigationBar:(BOOL)hiden;
- (void)showTitle:(NSString *)title yOffset:(CGFloat)y;

/**
 *  菊花加载
 */
- (void)showLoadMessageAtCenter;
- (void)showLoadMessageAtCenter:(NSString *)title;
- (void)showLoadMessageAtCenter:(NSString *)title navigationBar:(BOOL)hiden;
- (void)showLoadMessageAtCenter:(NSString *)title yOffset:(CGFloat)y;

/**
 *  网络请求成功
 */
- (void)showSuccess:(NSString *)title;
- (void)showSuccess:(NSString *)title navigationBar:(BOOL)hiden;
- (void)showSuccess:(NSString *)title yOffset:(CGFloat)y;

/**
 *  网络请求失败
 */
- (void)showError:(NSString *)title;
- (void)showError:(NSString *)title navigationBar:(BOOL)hiden;
- (void)showError:(NSString *)title yOffset:(CGFloat)y;

/**
 *  隐藏
 */
- (void)hide;





@end
