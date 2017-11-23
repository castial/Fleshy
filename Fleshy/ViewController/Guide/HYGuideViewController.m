//
//  HYGuideViewController.m
//  Fleshy
//
//  Created by Hyyy on 2017/10/27.
//  Copyright © 2017年 Hyyy. All rights reserved.
//

#import "HYGuideViewController.h"
#import "HYGuideGenderView.h"
#import "HYGuideChooseTimeView.h"
#import "HYGuideFinishView.h"
#import "HYPlan.h"
#import "HYPerformance.h"
#import "HYPlan+Database.h"
#import "HYPerformance+Database.h"

NSString *const HYGuideChangeColorEvent = @"HYGuideChangeColorEvent";

@interface HYGuideViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) HYGuideGenderView *guideGenderView;   // 性别引导页面
@property (nonatomic, strong) HYGuideChooseTimeView *chooseTimeView;    // 时间选择页面
@property (nonatomic, strong) HYGuideFinishView *finishView;        // 完成页面

@property (nonatomic, strong) HYPlan *plan;

@end

@implementation HYGuideViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kPageBgColor;
    
//    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_icon"]];
//    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.navigationItem.titleView = titleImageView;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.guideGenderView];
    [self.scrollView addSubview:self.chooseTimeView];
    [self.scrollView addSubview:self.finishView];
}

#pragma mark - Events
- (void)hy_routerEventWithName:(NSString *)eventName userInfo:(id)userInfo {
    if ([HYGuideGenderNextEvent isEqualToString:eventName]) {
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        
        [self refreshView];
    }else if ([HYGuideChooseTimeNextEvent isEqualToString:eventName]) {
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth * 2, 0) animated:YES];
        
        [self.finishView reloadData:userInfo];
    }else if ([HYGuideFinishBtnEvent isEqualToString:eventName]) {
        // 引导页消失，刷新数据
        self.plan = (HYPlan *)userInfo;
        [self generatePlanData];
    }else {
        [super hy_routerEventWithName:eventName userInfo:userInfo];
    }
}

#pragma mark - Private Methods
- (void)refreshView {
    [self.chooseTimeView refreshView];
}

- (void)generatePlanData {
    // 生成一条计划数据，然后创建多条执行数据与之对应
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [HYPlan databasae_insertPlan:self.plan block:^(BOOL isSuccess, NSString *message) {
        if (isSuccess) {
            [HYPlan database_queryPlan:self.plan.planName block:^(BOOL isSuccess, HYPlan *plan, NSString *message) {
                NSLog(@"%@", plan);
                if (plan) {                    
                    // 创建执行数据
                    NSMutableArray *array = [NSMutableArray array];
                    for (int i=1; i<=plan.durationDays; i++) {
                        HYPerformance *performance = [[HYPerformance alloc] init];
                        performance.planId = plan.planId;
                        performance.isPerform = NO;
                        performance.performDate = [plan.startTime dateByAddingDays:i];
                        [array addObject:performance];
                    }
                    [HYPerformance database_insertPerformances:array block:^(BOOL isSuccess, NSString *message) {
                        if (isSuccess) {
                            [hud hideAnimated:YES];
                            
                            [self.navigationController removeFromParentViewController];
                            [UIView animateWithDuration:0.5 animations:^{
                                self.navigationController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                self.navigationController.view.alpha = 0;
                            } completion:^(BOOL finished) {
                                // 发送计划创建完成通知
                                [[NSNotificationCenter defaultCenter] postNotificationName:HYPlanInitialSuccessNotification object:plan];
                                
                                // 生成计划通知 (开始和结束)
                                [self generateStartPlanNotification:plan];
                                [self generateEndPlanNotification:plan];

                                // dismiss引导页
                                [self removeFromParentViewController];
                                [self.view removeFromSuperview];
                            }];
                        }
                    }];
                }
            }];
        }
    }];
    [self.view hy_hideLoading];
}

- (void)generateStartPlanNotification:(HYPlan *)plan {
    NSDate *fireDate = [plan.startTime dateByAddingMinutes:-5];
    NSString *title = [NSString stringWithFormat:@"%@马上开始，请做好准备", plan.planName];
    NSString *subTitle = @"";
    NSString *alertBody = [NSString stringWithFormat:@"%@计划在%@即将开始了，恭喜您度过美好的一天！", plan.planName, [plan.startTime stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
    [HYLocalNotification createLocalNotification:fireDate alertTitle:title subTitle:subTitle identifier:HYPlanStartNotificationIdentifier categoryIdentifier:HYPlanStartCategoryIdentifier alertBody:alertBody badge:0 userInfo:nil];
}

- (void)generateEndPlanNotification:(HYPlan *)plan {
    NSString *title = @"恭喜您，完成计划";
    NSString *subTitle = @"";
    NSString *alertBody = @"每一步坚持，都是巨大的成功！";
    [HYLocalNotification createLocalNotification:plan.endTime alertTitle:title subTitle:subTitle identifier:HYPlanEndNotificationIdentifier categoryIdentifier:HYPlanEndCategoryIdentifier alertBody:alertBody badge:0 userInfo:nil];
}

#pragma mark - Setter and Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
        _scrollView.scrollEnabled = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(kScreenWidth * 3, kScreenHeight - 64);
        _scrollView.delegate = self;
//        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _scrollView;
}

- (HYGuideGenderView *)guideGenderView {
    if (!_guideGenderView) {
        _guideGenderView = [[HYGuideGenderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    }
    return _guideGenderView;
}

- (HYGuideChooseTimeView *)chooseTimeView {
    if (!_chooseTimeView) {
        _chooseTimeView = [[HYGuideChooseTimeView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight - 64)];
    }
    return _chooseTimeView;
}

- (HYGuideFinishView *)finishView {
    if (!_finishView) {
        _finishView = [[HYGuideFinishView alloc] initWithFrame:CGRectMake(kScreenWidth * 2, 0, kScreenWidth, kScreenHeight - 64)];
    }
    return _finishView;
}

- (HYPlan *)plan {
    if (!_plan) {
        _plan = [[HYPlan alloc] init];
    }
    return _plan;
}

@end
