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

@end

NS_ASSUME_NONNULL_END
