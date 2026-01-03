//
//  SUPSimpleFlameGraph.h
//  SuperProject
//
//  Created by zhi yi on 2025/12/6.
//  Copyright © 2025 superMan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 调用栈节点
@interface KSStackNode : NSObject
@property (nonatomic, copy) NSString *symbolName;
@property (nonatomic, assign) NSUInteger sampleCount;
@property (nonatomic, strong) NSMutableDictionary<NSString *, KSStackNode *> *children;
@end

/// 火焰图采样器
@interface SUPSimpleFlameGraph : NSObject

+ (instancetype)sharedInstance;

/// 开始采样
- (void)startSamplingWithInterval:(NSTimeInterval)interval;

/// 停止采样
- (void)stopSampling;

- (void)printFoldedStackToConsole;

/// 获取聚合后的调用树
- (KSStackNode *)aggregatedCallTree;

/// 打印详细统计（包含具体时间和采样次数）
- (void)printDetailedStatistics;

/// 导出为 Folded Stack 格式（标准格式，兼容 speedscope）
- (NSString *)exportToFoldedStackFormat;

/// 导出为带时间注释的格式（供查看，包含 ms 信息）
- (NSString *)exportToFoldedStackWithTimeComments;

@end

NS_ASSUME_NONNULL_END
