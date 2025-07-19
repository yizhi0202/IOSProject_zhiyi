//
//  SUPChildBlockViewController.h
//  SuperProject
//
//  Created by NShunJian on 2018/1/20.
//  Copyright © 2018年 superMan. All rights reserved.
//

#import "SUPBaseViewController.h"

@interface SUPChildBlockViewController : SUPBaseViewController

@property(nonatomic,copy) void(^successBlock)();

//********************************************************************
//      命名事例
-(void)test:(void(^)(int asd))blank;
//
///*定义属性，block属性可以用strong修饰，也可以用copy修饰
/// 但是在MRC环境下需要使用copy  因为若block在栈空间 函数执行完成后销毁，没有将block拷贝到堆空间，block以及捕获的变量都会释放，再访问block可能造成崩溃 保证兼容性最好都用copy
///*/
//@property (nonatomic, strong) void(^myBlock)();                   //无参无返回值
//@property (nonatomic, strong) void(^myBlock1)(NSString *);        //带参数无返回值
//@property (nonatomic, strong) NSString *(^myBlock2)(NSString *);  //带参数与返回值
//**********************************************************************
@end
