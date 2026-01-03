//
//  SUPFlameGraphTestViewController.m
//  SuperProject
//
//  Created by Cursor AI
//  测试火焰图采样功能
//

#import "SUPFlameGraphTestViewController.h"
#import "SUPSimpleFlameGraph.h"

@interface SUPFlameGraphTestViewController ()

@end

@implementation SUPFlameGraphTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"火焰图测试";
    
    [self setupUI];
}

- (void)setupUI {
    // 开始采样按钮
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(50, 150, self.view.bounds.size.width - 100, 50);
    [startBtn setTitle:@"开始采样并执行测试代码" forState:UIControlStateNormal];
    startBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startBtn.layer.cornerRadius = 8;
    [startBtn addTarget:self action:@selector(startProfilingTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    // 说明文字
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 250, self.view.bounds.size.width - 100, 200)];
    infoLabel.numberOfLines = 0;
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.textColor = [UIColor darkGrayColor];
    infoLabel.text = @"点击按钮后将执行以下操作：\n\n1. 开始火焰图采样（50ms间隔）\n2. 执行模拟的耗时操作\n3. 停止采样\n4. 在控制台输出详细统计\n5. 导出火焰图数据\n\n请查看 Xcode 控制台输出！";
    [self.view addSubview:infoLabel];
}

#pragma mark - Test Methods

- (void)startProfilingTest {
    NSLog(@"\n========== 🚀 开始火焰图性能分析 ==========\n");
    
    // 1. 开始采样（50ms 间隔）
    [[SUPSimpleFlameGraph sharedInstance] startSamplingWithInterval:0.05];
    
    // 2. 执行要分析的代码
    [self performTestOperations];
    
    // 3. 停止采样
    [[SUPSimpleFlameGraph sharedInstance] stopSampling];
    
    // 4. 打印详细统计
    [[SUPSimpleFlameGraph sharedInstance] printDetailedStatistics];
    
    // 5. 导出火焰图数据
    [[SUPSimpleFlameGraph sharedInstance] printFoldedStackToConsole];
    
    // 提示用户
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"采样完成" 
                                                                   message:@"请查看 Xcode 控制台输出\n\n可以复制火焰图数据到 speedscope.app 查看可视化结果" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performTestOperations {
    NSLog(@"开始执行测试操作...");
    
    // 模拟多种不同耗时的操作
    [self operationA];  // 耗时操作 A
    [self operationB];  // 耗时操作 B
    [self operationC];  // 耗时操作 C
    
    NSLog(@"测试操作执行完成");
}

#pragma mark - Simulated Heavy Operations

/// 操作 A：模拟数据加载（耗时较长）
- (void)operationA {
    [self fetchDataFromNetwork];
    [self parseJSONData];
}

- (void)fetchDataFromNetwork {
    // 模拟网络请求耗时（300ms）
    [self busyWork:0.3];
}

- (void)parseJSONData {
    // 模拟 JSON 解析（100ms）
    [self busyWork:0.1];
    [self processDataItem];
}

- (void)processDataItem {
    // 模拟数据处理（50ms）
    [self busyWork:0.05];
}

/// 操作 B：模拟 UI 更新（耗时中等）
- (void)operationB {
    [self updateTableView];
    [self refreshUI];
}

- (void)updateTableView {
    // 模拟表格更新（150ms）
    [self busyWork:0.15];
}

- (void)refreshUI {
    // 模拟 UI 刷新（80ms）
    [self busyWork:0.08];
}

/// 操作 C：模拟数据库操作（耗时较短）
- (void)operationC {
    [self saveToDatabase];
}

- (void)saveToDatabase {
    // 模拟数据库写入（50ms）
    [self busyWork:0.05];
}

/// 模拟 CPU 繁忙工作
- (void)busyWork:(NSTimeInterval)duration {
    NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:duration];
    
    // 执行一些计算密集型操作
    volatile double result = 0;
    while ([NSDate date].timeIntervalSince1970 < endTime.timeIntervalSince1970) {
        for (int i = 0; i < 1000; i++) {
            result += sqrt(i) * sin(i);
        }
    }
}

@end

