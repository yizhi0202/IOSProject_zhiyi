//
//  SUPTableViewHitchDetectViewController.m
//  SuperProject
//
//  Created by zhi yi on 2025/7/26.
//  Copyright © 2025 superMan. All rights reserved.
//

#import "SUPTableViewHitchDetectViewController.h"
#import "SUPTableViewHitchDetectCell.h"

@interface SUPTableViewHitchDetectViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isOptimizedMode;

@end

@implementation SUPTableViewHitchDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"性能测试";
    
    self.isOptimizedMode = NO;
    
    [self setupData];
    [self setupUI];
}

- (void)setupData {
    self.dataArray = [NSMutableArray array];
    NSArray *texts = @[
        @"这是一段用来测试的短文本。",
        @"这是一段比较长的文本，它会占据多行空间，用来测试动态行高计算时的性能表现，观察是否会因此产生卡顿。",
        @"UITableView是iOS开发中非常核心的组件，优化它的性能至关重要。",
        @"异步加载图片、缓存行高、减少离屏渲染是关键的优化手段。",
        @"使用Instruments的Time Profiler和Core Animation工具可以帮助我们定位问题。"
    ];
    for (int i = 0; i < 100; i++) {
        NSDictionary *item = @{
            @"text": texts[i % texts.count],
            // 使用一个不变的图片URL，实际项目中每个item的URL不同
            // lorempicsum.photos 提供随机图片，但可能较慢
            @"imageUrl": [NSString stringWithFormat:@"https://p1-ec.eckwai.com/udata/pkg/ks-merchant/merchant_home/universal_images/JustForTest/tmpTestImage.png", i]
        };
        [self.dataArray addObject:item];
    }
}

- (void)setupUI {
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"卡顿模式", @"优化模式"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 120; // 使用固定高度简化demo
    [self.tableView registerClass:[SUPTableViewHitchDetectCell class] forCellReuseIdentifier:@"DemoCell"];
    [self.view addSubview:self.tableView];
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    self.isOptimizedMode = (sender.selectedSegmentIndex == 1);
    [self.tableView reloadData];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SUPTableViewHitchDetectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoCell" forIndexPath:indexPath];
    
    NSDictionary *data = self.dataArray[indexPath.row];
    [cell configureWithData:data isOptimized:self.isOptimizedMode];
    
    return cell;
}

// 如果行高是动态的，也需要优化
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     // 在这个demo中我们用了固定高度，如果动态则需要计算和缓存
     return 120;
}

@end
