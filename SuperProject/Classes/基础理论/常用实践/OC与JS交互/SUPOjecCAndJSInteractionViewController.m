//
//  SUPOjecCAndJSInteractionViewController.m
//  SuperProject
//
//  Created by zhi yi on 2025/8/2.
//  Copyright © 2025 superMan. All rights reserved.
//

#import "SUPOjecCAndJSInteractionViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface SUPOjecCAndJSInteractionViewController ()
@property (nonatomic, strong) JSContext *jsContext;
@end

@implementation SUPOjecCAndJSInteractionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // 1. 初始化JSContext
    [self setupJSContext];
    
    // 2. 创建一个按钮来触发OC调用JS
    UIButton *callJsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [callJsButton setTitle:@"Call JavaScript via JavaScriptCore" forState:UIControlStateNormal];
    [callJsButton addTarget:self action:@selector(callJavaScriptAction) forControlEvents:UIControlEventTouchUpInside];
    callJsButton.frame = CGRectMake(50, 200, 300, 50);

    // 为按钮添加边框和圆角
    callJsButton.layer.borderColor = [UIColor grayColor].CGColor;
    callJsButton.layer.borderWidth = 1.0f;
    callJsButton.layer.cornerRadius = 8.0f;
    
    [self.view addSubview:callJsButton];
}

- (void)setupJSContext {
    // 初始化 JSContext
    self.jsContext = [[JSContext alloc] init];

    // 定义一个JS函数，这个函数将被OC调用
    NSString *jsFunction = @"function add(a, b) { return a + b; }";
    [self.jsContext evaluateScript:jsFunction];

    NSLog(@"[OC] JSContext initialized and 'add' function is defined.");
}

- (void)callJavaScriptAction {
    NSLog(@"[OC] Button clicked. Preparing to call JavaScript function 'add'.");

    // 从JSContext中获取我们定义的'add'函数
    JSValue *addFunction = self.jsContext[@"add"];
    
    // 安全检查：在调用前，确认该JSValue不是undefined
    if ([addFunction isUndefined]) {
        NSLog(@"[OC] Error: JavaScript function 'add' not found in JSContext.");
        return; // 直接返回，避免崩溃
    }
    
    // 准备要传递给JS函数的参数
    NSArray *args = @[@5, @10];
    
    // 使用 callWithArguments: 调用JS函数
    JSValue *result = [addFunction callWithArguments:args];
    
    // 打印JS函数的返回值
    NSLog(@"[OC] JavaScript function 'add' returned: %d", [result toInt32]);
}

@end
