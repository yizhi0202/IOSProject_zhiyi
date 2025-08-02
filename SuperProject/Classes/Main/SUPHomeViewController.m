//
//  SUPHomeViewController.m
//  SuperProject
//
//  Created by NShunJian on 2018/1/20.
//  Copyright © 2018年 superMan. All rights reserved.
//

#import "SUPHomeViewController.h"
#import "SUPWebViewController.h"
#import "SUPLiftCycleViewController.h"
#import "SUPRunTimeViewController.h"
//#import "SUPNSThreadViewController.h"
//#import "SUPGCDViewController.h"
//#import "SUPNSOperationViewController.h"
//#import "SUPLockViewController.h"
#import "SUPProtocolViewController.h"
#import "SUPBlockLoopViewController.h"
#import "SUPTableViewHitchDetectViewController.h"
#import "SUPOjecCAndJSInteractionViewController.h"
//
//#import "SUPDynamicViewController.h"
//#import "SUPCoreAnimationViewController.h"
//#import "SUPDrawRectViewController.h"

@interface SUPHomeViewController ()

@end

@implementation SUPHomeViewController

#pragma mark viewController生命周期
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //关闭抽屉模式
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    //设置打开抽屉模式
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    edgeInsets.bottom += self.tabBarController.tabBar.SUP_height;
    self.tableView.contentInset = edgeInsets;

    SUPWordArrowItem *item00 = [SUPWordArrowItem itemWithTitle:@"ViewController的生命周期 :" subTitle: nil];
    item00.destVc = [SUPLiftCycleViewController class];
    
    SUPWordArrowItem *item01 = [SUPWordArrowItem itemWithTitle:@"运行时RunTime 的知识运用" subTitle: nil];
    item01.destVc = [SUPRunTimeViewController class];

    SUPWordArrowItem *item03 = [SUPWordArrowItem itemWithTitle:@"Protocol 的实现类(代理是如何实现的流程)" subTitle: nil];
    item03.destVc = [SUPProtocolViewController class];


    SUPWordArrowItem *item04 = [SUPWordArrowItem itemWithTitle:@"Block 内存释放" subTitle: nil];
    item04.destVc = [SUPBlockLoopViewController class];
    
    SUPWordArrowItem *item05 = [SUPWordArrowItem itemWithTitle:@"UITableView卡顿排查" subTitle: nil];
    item05.destVc = [SUPTableViewHitchDetectViewController class];
    
    SUPWordArrowItem *item06 = [SUPWordArrowItem itemWithTitle:@"OC与JS交互" subTitle: nil];
    item06.destVc = [SUPOjecCAndJSInteractionViewController class];

    
    SUPItemSection *section0 = [SUPItemSection sectionWithItems:@[item00,item01,item03,item04,item05,item06] andHeaderTitle:@"生命周期, RunTime" footerTitle:nil];

    [self.sections addObject:section0];



//    SUPWordArrowItem *item10 = [SUPWordArrowItem itemWithTitle:@"NSThread 多线程" subTitle: nil];
//    item10.destVc = [SUPNSThreadViewController class];

//    SUPWordArrowItem *item11 = [SUPWordArrowItem itemWithTitle:@"GCD 多线程" subTitle: nil];
//    item11.destVc = [SUPGCDViewController class];
//
//    SUPWordArrowItem *item12 = [SUPWordArrowItem itemWithTitle:@" NSOperation 多线程" subTitle: nil];
//    item12.destVc = [SUPNSOperationViewController class];
//
//    SUPWordArrowItem *item13 = [SUPWordArrowItem itemWithTitle:@"同步锁知识" subTitle: nil];
//    item13.destVc = [SUPLockViewController class];
//
//
//
//    SUPItemSection *section1 = [SUPItemSection sectionWithItems:@[item10] andHeaderTitle:@"NSThread, GCD, NSOperation, Lock" footerTitle:nil];
//
//    [section1.items makeObjectsPerformSelector:@selector(setTitleColor:) withObject:[UIColor RandomColor]];

//    [self.sections addObject:section1];
//
//
//    SUPWordArrowItem *item20 = [SUPWordArrowItem itemWithTitle:@"物理仿真" subTitle: @""];

//    item20.destVc = [SUPDynamicViewController class];
//
//    SUPWordArrowItem *item21 = [SUPWordArrowItem itemWithTitle:@"核心动画" subTitle: @""];
//
//    item21.destVc = [SUPCoreAnimationViewController class];
//
//    SUPWordArrowItem *item22 = [SUPWordArrowItem itemWithTitle:@"绘图 Quartz2D" subTitle: @"Draw Rect"];
//
//    item22.destVc = [SUPDrawRectViewController class];
//
//    SUPItemSection *section2 = [SUPItemSection sectionWithItems:@[item20] andHeaderTitle:@"物理仿真, 核心动画, 绘图 Quartz2D" footerTitle:nil];
//
//    [self.sections addObject:section2];


    UITabBarItem *homeItem = self.navigationController.tabBarItem;

    [homeItem setBadgeValue:@"3"];

}


#pragma mark - SUPNavUIBaseViewControllerDataSource
//- (BOOL)navUIBaseViewControllerIsNeedNavBar:(SUPNavUIBaseViewController *)navUIBaseViewController
//{
//    return YES;
//}



#pragma mark - DataSource
/**头部标题*/
- (NSMutableAttributedString*)SUPNavigationBarTitle:(SUPNavigationBar *)navigationBar
{
    return [self changeTitle:@"基础"];
}

/** 背景图片 */
//- (UIImage *)SUPNavigationBarBackgroundImage:(SUPNavigationBar *)navigationBar
//{
//
//}

/** 背景色 */
//- (UIColor *)SUPNavigationBackgroundColor:(SUPNavigationBar *)navigationBar
//{
//
//}

/** 是否隐藏底部黑线 */
- (BOOL)SUPNavigationIsHideBottomLine:(SUPNavigationBar *)navigationBar
{
    return NO;
}

/** 导航条的高度 */
//- (CGFloat)SUPNavigationHeight:(SUPNavigationBar *)navigationBar
//{
//
//}


/** 导航条的左边的 view */
//- (UIView *)SUPNavigationBarLeftView:(SUPNavigationBar *)navigationBar
//{
//
//}
/** 导航条右边的 view */
//- (UIView *)SUPNavigationBarRightView:(SUPNavigationBar *)navigationBar
//{
//
//}
/** 导航条中间的 View */
//- (UIView *)SUPNavigationBarTitleView:(SUPNavigationBar *)navigationBar
//{
//
//}
/** 导航条左边的按钮 */
- (UIImage *)SUPNavigationBarLeftButtonImage:(UIButton *)leftButton navigationBar:(SUPNavigationBar *)navigationBar
{
    [leftButton setTitle:@"😁" forState:UIControlStateNormal];
    return nil;
}
/** 导航条右边的按钮 */
- (UIImage *)SUPNavigationBarRightButtonImage:(UIButton *)rightButton navigationBar:(SUPNavigationBar *)navigationBar
{
    [rightButton setTitle:@"百度" forState:UIControlStateNormal];

    [rightButton setTitleColor:[UIColor RandomColor] forState:UIControlStateNormal];
    return nil;
}



#pragma mark - Delegate
/** 左边的按钮的点击 */
-(void)leftButtonEvent:(UIButton *)sender navigationBar:(SUPNavigationBar *)navigationBar
{
    NSLog(@"======");
}
/** 右边的按钮的点击 */
-(void)rightButtonEvent:(UIButton *)sender navigationBar:(SUPNavigationBar *)navigationBar
{
    SUPWebViewController *ac = [SUPWebViewController new];
    ac.gotoURL = @"http://www.baidu.com";

    [self.navigationController pushViewController:ac animated:YES];
    NSLog(@"%s", __func__);
}
/** 中间如果是 label 就会有点击 */
-(void)titleClickEvent:(UILabel *)sender navigationBar:(SUPNavigationBar *)navigationBar
{
    NSLog(@"%s", __func__);
}


#pragma mark 自定义代码

-(NSMutableAttributedString *)changeTitle:(NSString *)curTitle
{   if(curTitle){
    
}
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:curTitle ?: @""];

    [title addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, title.length)];

    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, title.length)];

    return title;
}






@end




