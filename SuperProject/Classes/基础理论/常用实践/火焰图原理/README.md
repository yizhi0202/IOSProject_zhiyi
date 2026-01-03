# 火焰图采样器 - 量化性能分析工具 🔥

## 快速开始 ⚡

### 1. 基础使用（3行代码）

```objc
[[SUPSimpleFlameGraph sharedInstance] startSamplingWithInterval:0.05];  // 开始采样
[self yourHeavyTask];                                                   // 执行要分析的代码
[[SUPSimpleFlameGraph sharedInstance] stopSampling];                   // 停止采样
```

### 2. 查看结果

```objc
// 方式1: 控制台查看详细统计（包含具体 ms 数值）⭐ 新增
[[SUPSimpleFlameGraph sharedInstance] printDetailedStatistics];

// 方式2: 导出到 speedscope 可视化（包含时间注释）⭐ 增强
[[SUPSimpleFlameGraph sharedInstance] printFoldedStackToConsole];
```

---

## 输出示例

### 控制台统计输出

```
========== 📊 火焰图详细统计 ==========
总采样次数: 100
采样间隔: 50.00 ms
总耗时估算: 5000.00 ms

调用路径                                                              采样次数       耗时(ms)     占比(%)
========================================================================================================
main;viewDidLoad;fetchData;networkRequest                                 40       2000.00     40.00%
main;viewDidLoad;setupUI;layoutViews                                      20       1000.00     20.00%
main;applicationDidLoad;initDatabase                                      10        500.00     10.00%
main;viewDidLoad;fetchData                                                 5        250.00      5.00%
========== END ==========
```

### speedscope 导出数据

**控制台会输出两种格式：**

#### 1. 标准格式（用于 speedscope）⭐

```
========== 🔥 FLAME GRAPH DATA (复制以下内容到 speedscope.app) ==========
提示：数字单位为微秒(μs)，speedscope 会自动转换显示为 ms 或 s

main;viewDidLoad;fetchData;networkRequest 2000000
main;viewDidLoad;setupUI;layoutViews 1000000
main;applicationDidLoad;initDatabase 500000
========== END ==========
```

**关键说明：**
- 数字是**微秒(μs)**单位
- speedscope 会自动转换显示为 ms 或 s
- 例如：`2000000 μs` → speedscope 显示为 `2.00 s` 或 `2000 ms`

**使用方法：**
1. 复制"FLAME GRAPH DATA"部分的数据行（不包括分隔线和提示）
2. 打开 https://speedscope.app
3. 粘贴数据
4. 鼠标悬停在火焰图上即可看到具体的时间数值！

#### 2. 带时间信息的格式（供查看）📝

```
========== 📝 带时间信息的格式 (供查看) ==========
main;viewDidLoad;fetchData;networkRequest 40  (2000.00 ms)
main;viewDidLoad;setupUI;layoutViews 20  (1000.00 ms)
main;applicationDidLoad;initDatabase 10  (500.00 ms)
========== END ==========
```

这个格式包含具体的 ms 数值，方便直接查看，但不要复制到 speedscope（格式不兼容）

---

## 核心改进 ✨

| 功能 | 说明 | 示例 |
|------|------|------|
| **详细统计** | 控制台输出 Top 20 热点 | `printDetailedStatistics` |
| **时间注释** | 导出数据包含 ms 信息 | `# 2000.00 ms` |
| **元数据头** | 总采样数、间隔、总耗时 | `# Total Samples: 100` |
| **量化分析** | 具体数值，不只是比例 | `2000.00 ms (40.00%)` |

---

## 完整示例

```objc
- (void)profileMyFeature {
    // 1️⃣ 开始采样（建议 50-100ms）
    [[SUPSimpleFlameGraph sharedInstance] startSamplingWithInterval:0.05];
    
    // 2️⃣ 执行要分析的功能
    [self loadDataAndRefreshUI];
    
    // 3️⃣ 停止采样
    [[SUPSimpleFlameGraph sharedInstance] stopSampling];
    
    // 4️⃣ 查看控制台统计（快速定位热点）
    [[SUPSimpleFlameGraph sharedInstance] printDetailedStatistics];
    
    // 5️⃣ 导出火焰图（深入分析调用链）
    [[SUPSimpleFlameGraph sharedInstance] printFoldedStackToConsole];
}
```

---

## 采样间隔建议

| 场景 | 间隔 | 说明 |
|------|------|------|
| 🔍 **开发调试** | 10-20ms | 高精度，细节分析 |
| ⭐ **性能分析** | **50-100ms** | **推荐：平衡精度和开销** |
| 📊 **生产监控** | 100-500ms | 低开销，长期监控 |
| 🎬 **UI 卡顿** | 16.67ms | 一帧时间（60fps） |

---

## 测试工具

运行 `SUPFlameGraphTestViewController` 体验完整功能：

```objc
SUPFlameGraphTestViewController *testVC = [[SUPFlameGraphTestViewController alloc] init];
[self.navigationController pushViewController:testVC animated:YES];
```

点击按钮即可看到：
- ✅ 完整的采样流程
- ✅ 详细的统计输出
- ✅ 火焰图导出数据
- ✅ 模拟的性能分析场景

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `SUPSimpleFlameGraph.h/m` | 核心实现（已增强） |
| `README.md` | 快速入门（本文件） |
| `使用示例.md` | 详细文档和最佳实践 |
| `改进说明.md` | 技术改进详解 |
| `SUPFlameGraphTestViewController.h/m` | 测试工具 |

---

## 核心原理

```
定时采样 → 获取调用栈 → 符号化 → 聚合 → 计算耗时 → 可视化
   ↓           ↓           ↓        ↓        ↓          ↓
每 N ms    PC/LR/FP    地址→函数   构建树   次数×间隔   输出结果
```

**时间计算：**
```
实际耗时 = 采样次数 × 采样间隔
例：40次 × 50ms = 2000ms
```

---

## 注意事项

⚠️ **这是估算值，不是精确测量**

- ✅ 适合：宏观性能分析、找热点函数
- ❌ 不适合：微观性能测量、精确计时
- ⚠️ 采样会轻微影响性能（thread_suspend）
- 💡 建议仅在开发/测试环境使用

---

## 快速问答

**Q: 如何只看耗时 Top 10？**  
A: `printDetailedStatistics` 默认显示 Top 20，已按耗时排序

**Q: speedscope 还是显示百分比？**  
A: 鼠标悬停可看具体数值，新版数据在注释中包含 ms 信息

**Q: 可以采样子线程吗？**  
A: 当前版本只支持主线程

**Q: 如何优化性能？**  
A: 看统计表，优化占比最高的函数！

---

## 相关链接

- 📊 [speedscope.app](https://speedscope.app) - 火焰图在线可视化工具
- 📖 [使用示例.md](./使用示例.md) - 详细使用文档
- 🔧 [改进说明.md](./改进说明.md) - 技术改进详解

---

**开始使用，精确定位性能瓶颈！** 🎯

