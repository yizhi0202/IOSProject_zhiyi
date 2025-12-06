//
//  SUPSimpleFlameGraph.m
//  SuperProject
//
//  Created by zhi yi on 2025/12/6.
//  Copyright © 2025 superMan. All rights reserved.
//

#import "SUPSimpleFlameGraph.h"
#import <execinfo.h>
#import <mach/mach.h>
#import <mach/mach_types.h>
#import <mach/thread_act.h>
#import <mach/vm_map.h>
#import <pthread.h>
#import <dlfcn.h>  // 新增

#pragma mark - KSStackNode

// arm64 架构的栈回溯
typedef struct {
    uintptr_t fp;  // frame pointer (x29)
    uintptr_t lr;  // link register (x30)
} StackFrame;

@interface SUPSymbolInfo : NSObject
@property (nonatomic, copy) NSString *symbolName;
@property (nonatomic, copy) NSString *moduleName;
@end

@implementation SUPSymbolInfo
@end

@implementation KSStackNode

- (instancetype)init {
    if (self = [super init]) {
        _children = [NSMutableDictionary dictionary];
        _sampleCount = 0;
    }
    return self;
}

@end

#pragma mark - SUPSimpleFlameGraph

@interface SUPSimpleFlameGraph ()
@property (nonatomic, strong) dispatch_source_t samplingTimer;
@property (nonatomic, strong) KSStackNode *rootNode;
@property (nonatomic, assign) NSUInteger totalSamples;
@property (nonatomic, strong) dispatch_queue_t samplingQueue;
@end

@implementation SUPSimpleFlameGraph

+ (instancetype)sharedInstance {
    static SUPSimpleFlameGraph *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SUPSimpleFlameGraph alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _rootNode = [[KSStackNode alloc] init];
        _rootNode.symbolName = @"root";
        _totalSamples = 0;
        _samplingQueue = dispatch_queue_create("com.flame.sampling", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)reset {
    self.rootNode = [[KSStackNode alloc] init];
    self.rootNode.symbolName = @"root";
    self.totalSamples = 0;
}

#pragma mark - 采样控制

- (void)startSamplingWithInterval:(NSTimeInterval)interval {
    [self stopSampling];
    [self reset];
    
    // 预先获取主线程 port（在主线程执行）
    [self getMainMachThread];
    
    self.samplingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.samplingQueue);
    
    uint64_t intervalNs = (uint64_t)(interval * NSEC_PER_SEC);
    dispatch_source_set_timer(self.samplingTimer, dispatch_time(DISPATCH_TIME_NOW, intervalNs), intervalNs, 0);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.samplingTimer, ^{
        [weakSelf captureMainThreadCallStack];  // 直接在采样队列调用，不 dispatch 到主线程
    });
    
    dispatch_resume(self.samplingTimer);
}

- (void)stopSampling {
    if (self.samplingTimer) {
        dispatch_source_cancel(self.samplingTimer);
        self.samplingTimer = nil;
        NSLog(@"🔥 火焰图采样已停止，共采样 %lu 次", (unsigned long)self.totalSamples);
    }
}

#pragma mark - 火焰图导出
/// 导出为 Folded Stack 格式（可用于 speedscope.app）
- (NSString *)exportToFoldedStackFormat {
    NSMutableString *output = [NSMutableString string];
    [self exportNode:self.rootNode path:@"" output:output];
    return output;
}

/// 递归导出节点
- (void)exportNode:(KSStackNode *)node path:(NSString *)path output:(NSMutableString *)output {
    NSString *currentPath;
    
    if (path.length == 0) {
        currentPath = node.symbolName;
    } else {
        currentPath = [NSString stringWithFormat:@"%@;%@", path, node.symbolName];
    }
    
    // 如果是叶子节点或者有自己的采样（不只是传递给子节点）
    if (node.children.count == 0) {
        // 叶子节点：输出完整路径和采样数
        [output appendFormat:@"%@ %lu\n", currentPath, (unsigned long)node.sampleCount];
    } else {
        // 计算自身消耗（总采样 - 子节点采样之和）
        NSUInteger childrenSamples = 0;
        for (KSStackNode *child in node.children.allValues) {
            childrenSamples += child.sampleCount;
        }
        
        NSUInteger selfSamples = node.sampleCount - childrenSamples;
        if (selfSamples > 0) {
            [output appendFormat:@"%@ %lu\n", currentPath, (unsigned long)selfSamples];
        }
        
        // 递归处理子节点
        for (KSStackNode *child in node.children.allValues) {
            [self exportNode:child path:currentPath output:output];
        }
    }
}

/// 打印到控制台并返回
- (void)printFoldedStackToConsole {
    NSString *foldedStack = [self exportToFoldedStackFormat];
    NSLog(@"\n\n========== 🔥 FLAME GRAPH DATA (复制以下内容到 speedscope.app) ==========\n%@\n========== END ==========\n", foldedStack);
}

#pragma mark - 调用栈采集

- (void)captureMainThreadCallStack {
    // 直接在采样线程中获取主线程的调用栈（不要 dispatch 到主线程）
    thread_t mainThread = [self getMainMachThread];
    if (mainThread == MACH_PORT_NULL) return;
    
    NSArray<SUPSymbolInfo *> *symbols = [self captureCallStackOfThread:mainThread];
    
    if (symbols.count > 0) {
        [self aggregateCallStackWithSymbols:symbols];
        self.totalSamples++;
    }
}

/// 获取主线程的 mach thread
- (thread_t)getMainMachThread {
    static thread_t mainThread = MACH_PORT_NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 在主线程执行一次获取 thread port
        if ([NSThread isMainThread]) {
            mainThread = mach_thread_self();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                mainThread = mach_thread_self();
            });
        }
    });
    return mainThread;
}

/// 获取指定线程的调用栈（核心方法）
- (NSArray<SUPSymbolInfo *> *)captureCallStackOfThread:(thread_t)thread {
    NSMutableArray<SUPSymbolInfo *> *result = [NSMutableArray array];
    
    // 暂停线程
    if (thread_suspend(thread) != KERN_SUCCESS) {
        return result;
    }
    
    // 获取线程状态（arm64）
#if defined(__arm64__)
    _STRUCT_MCONTEXT64 machineContext;
    mach_msg_type_number_t stateCount = ARM_THREAD_STATE64_COUNT;
    
    kern_return_t kr = thread_get_state(thread,
                                        ARM_THREAD_STATE64,
                                        (thread_state_t)&machineContext.__ss,
                                        &stateCount);
    
    if (kr == KERN_SUCCESS) {
        // 获取 PC, LR, FP
        uintptr_t pc = (uintptr_t)machineContext.__ss.__pc;
        uintptr_t lr = (uintptr_t)machineContext.__ss.__lr;
        uintptr_t fp = (uintptr_t)machineContext.__ss.__fp;
        
        // 1. 添加当前 PC
        [self addSymbolForAddress:pc toArray:result];
        
        // 2. 添加 LR（返回地址）
        if (lr != 0 && lr != pc) {
            [self addSymbolForAddress:lr toArray:result];
        }
        
        // 3. 栈回溯
        const int maxFrames = 64;
        int frameCount = 0;
        
        while (fp != 0 && frameCount < maxFrames) {
            StackFrame *frame = (StackFrame *)fp;
            
            // 安全检查：确保地址可读
            if (![self isValidAddress:(uintptr_t)frame]) {
                break;
            }
            
            uintptr_t returnAddress = frame->lr;
            if (returnAddress == 0) break;
            
            [self addSymbolForAddress:returnAddress toArray:result];
            
            fp = frame->fp;
            frameCount++;
        }
    }
#endif
    
    // 恢复线程
    thread_resume(thread);
    
    // 过滤掉采样器自身的函数
    return [self filterSamplerFunctions:result];
}

/// 添加符号信息
- (void)addSymbolForAddress:(uintptr_t)address toArray:(NSMutableArray *)array {
    SUPSymbolInfo *info = [[SUPSymbolInfo alloc] init];
    
    Dl_info dlInfo;
    if (dladdr((void *)address, &dlInfo)) {
        info.symbolName = dlInfo.dli_sname ? @(dlInfo.dli_sname) : [NSString stringWithFormat:@"0x%lx", address];
        info.moduleName = dlInfo.dli_fname ? @(dlInfo.dli_fname).lastPathComponent : @"Unknown";
    } else {
        info.symbolName = [NSString stringWithFormat:@"0x%lx", address];
        info.moduleName = @"Unknown";
    }
    
    [array addObject:info];
}

/// 检查地址是否可读
- (BOOL)isValidAddress:(uintptr_t)address {
    if (address == 0) return NO;
    
    vm_size_t vmsize = 0;
    vm_address_t vmaddr = (vm_address_t)address;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t infoCount = VM_REGION_BASIC_INFO_COUNT_64;
    memory_object_name_t object;
    
    kern_return_t kr = vm_region_64(mach_task_self(),
                                    &vmaddr,
                                    &vmsize,
                                    VM_REGION_BASIC_INFO_64,
                                    (vm_region_info_t)&info,
                                    &infoCount,
                                    &object);
    
    if (kr != KERN_SUCCESS) return NO;
    return (info.protection & VM_PROT_READ) != 0;
}

/// 过滤采样器自身的函数
- (NSArray<SUPSymbolInfo *> *)filterSamplerFunctions:(NSArray<SUPSymbolInfo *> *)symbols {
    NSMutableArray *filtered = [NSMutableArray array];
    
    for (SUPSymbolInfo *info in symbols) {
        // 跳过采样器相关函数
        if ([info.symbolName containsString:@"SUPSimpleFlameGraph"] ||
            [info.symbolName containsString:@"SUPFlameGraph"] ||
            [info.symbolName containsString:@"captureCallStack"] ||
            [info.symbolName containsString:@"captureMainThread"]) {
            continue;
        }
        [filtered addObject:info];
    }
    
    // 反转：根函数在前
    return [[filtered reverseObjectEnumerator] allObjects];
}

/// 获取当前线程调用栈符号
- (NSArray<SUPSymbolInfo *> *)captureCurrentThreadCallStack {
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    
    NSMutableArray<SUPSymbolInfo *> *result = [NSMutableArray array];
    
    for (int i = 0; i < frames; i++) {
        SUPSymbolInfo *info = [[SUPSymbolInfo alloc] init];
        
        Dl_info dlInfo;
        if (dladdr(callstack[i], &dlInfo)) {
            info.symbolName = dlInfo.dli_sname ? @(dlInfo.dli_sname) : [NSString stringWithFormat:@"%p", callstack[i]];
            info.moduleName = dlInfo.dli_fname ? @(dlInfo.dli_fname).lastPathComponent : @"Unknown";
        } else {
            info.symbolName = [NSString stringWithFormat:@"%p", callstack[i]];
            info.moduleName = @"Unknown";
        }
        [result addObject:info];
    }
    
    return [[result reverseObjectEnumerator] allObjects];
}

/// 从符号字符串中提取函数名
- (NSString *)extractFunctionName:(NSString *)symbol {
    NSArray *components = [symbol componentsSeparatedByString:@" "];
    for (NSString *comp in components) {
        if (comp.length > 0 && ![comp hasPrefix:@"0x"] && ![comp containsString:@"+"]) {
            // 使用 NSScanner 检查是否为纯数字
            NSScanner *scanner = [NSScanner scannerWithString:comp];
            NSInteger intValue;
            if (!([scanner scanInteger:&intValue] && [scanner isAtEnd])) {
                return comp;
            }
        }
    }
    return symbol.lastPathComponent;
}

#pragma mark - 数据聚合

- (void)aggregateCallStackWithSymbols:(NSArray<SUPSymbolInfo *> *)symbols {
    KSStackNode *currentNode = self.rootNode;
    currentNode.sampleCount++;
    
    for (SUPSymbolInfo *info in symbols) {
        NSString *key = [NSString stringWithFormat:@"%@::%@", info.moduleName, info.symbolName];
        
        KSStackNode *childNode = currentNode.children[key];
        if (!childNode) {
            childNode = [[KSStackNode alloc] init];
            childNode.symbolName = info.symbolName;
            currentNode.children[key] = childNode;
        }
        childNode.sampleCount++;
        currentNode = childNode;
    }
}

- (KSStackNode *)aggregatedCallTree {
    return self.rootNode;
}

#pragma mark - 火焰图渲染

- (UIView *)generateFlameGraphViewWithFrame:(CGRect)frame {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.15 alpha:1.0];
    
    CGFloat totalWidth = frame.size.width;
    CGFloat rowHeight = 20.0;
    CGFloat yOffset = frame.size.height - rowHeight; // 从底部开始绘制
    
    [self renderNode:self.rootNode
          parentView:scrollView
              xStart:0
               width:totalWidth
             yOffset:&yOffset
           rowHeight:rowHeight
        totalSamples:self.totalSamples];
    
    // 调整 contentSize
    scrollView.contentSize = CGSizeMake(totalWidth, frame.size.height - yOffset);
    
    return scrollView;
}

- (void)renderNode:(KSStackNode *)node
        parentView:(UIView *)parentView
            xStart:(CGFloat)xStart
             width:(CGFloat)width
           yOffset:(CGFloat *)yOffset
         rowHeight:(CGFloat)rowHeight
      totalSamples:(NSUInteger)totalSamples {
    
    if (node.sampleCount == 0 || width < 2) return;
    
    // 创建当前节点视图
    UIView *nodeView = [[UIView alloc] initWithFrame:CGRectMake(xStart, *yOffset, width - 1, rowHeight - 1)];
    nodeView.backgroundColor = [self colorForSymbol:node.symbolName];
    nodeView.layer.cornerRadius = 2;
    
    // 添加标签
    UILabel *label = [[UILabel alloc] initWithFrame:nodeView.bounds];
    label.text = node.symbolName;
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [nodeView addSubview:label];
    
    [parentView addSubview:nodeView];
    
    // 递归渲染子节点
    CGFloat childXStart = xStart;
    CGFloat childYOffset = *yOffset - rowHeight;
    
    for (KSStackNode *childNode in node.children.allValues) {
        CGFloat childWidth = (width * childNode.sampleCount) / node.sampleCount;
        
        [self renderNode:childNode
              parentView:parentView
                  xStart:childXStart
                   width:childWidth
                 yOffset:&childYOffset
               rowHeight:rowHeight
            totalSamples:totalSamples];
        
        childXStart += childWidth;
    }
    
    // 更新最小 yOffset
    if (childYOffset < *yOffset) {
        *yOffset = childYOffset;
    }
}

/// 根据符号名生成颜色（模拟火焰效果）
- (UIColor *)colorForSymbol:(NSString *)symbol {
    NSUInteger hash = symbol.hash;
    CGFloat hue = (hash % 50) / 360.0;  // 0-50度 红橙黄
    CGFloat sat = 0.7 + (hash % 20) / 100.0;
    CGFloat bri = 0.75 + (hash % 20) / 100.0;
    return [UIColor colorWithHue:hue saturation:sat brightness:bri alpha:1.0];
}

@end
