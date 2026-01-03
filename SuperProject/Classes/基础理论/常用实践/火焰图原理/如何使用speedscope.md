# 如何使用 speedscope 查看火焰图 🔥

## 功能说明

**核心特性：** 导出的数据使用**微秒(μs)**作为单位，speedscope 会自动显示为具体时间

**解决方案：**
- ✅ **标准格式**（微秒数）- speedscope 显示为 ms 或 s
- 📝 **带注释格式** - 方便控制台直接查看

**关键点：** 
- 采样次数转换为微秒：`微秒 = 采样次数 × 采样间隔(秒) × 1,000,000`
- speedscope 自动识别并显示为可读的时间格式

---

## 快速使用步骤 ⚡

### 1. 运行采样代码

```objc
[[SUPSimpleFlameGraph sharedInstance] startSamplingWithInterval:0.05];
[self yourTask];
[[SUPSimpleFlameGraph sharedInstance] stopSampling];
[[SUPSimpleFlameGraph sharedInstance] printFoldedStackToConsole];
```

### 2. 控制台输出示例

```
========== 📊 采样统计信息 ==========
总采样次数: 100
采样间隔: 50.00 ms
总耗时估算: 5000.00 ms
=====================================

========== 🔥 FLAME GRAPH DATA (复制以下内容到 speedscope.app) ==========
提示：数字单位为微秒(μs)，speedscope 会自动转换显示为 ms 或 s

main;viewDidLoad;fetchData;networkRequest 2000000
main;viewDidLoad;setupUI;layoutViews 1000000
main;applicationDidLoad;initDatabase 500000
main;viewDidLoad 250000
========== END ==========

========== 📝 带时间信息的格式 (供查看) ==========
main;viewDidLoad;fetchData;networkRequest 40  (2000.00 ms)
main;viewDidLoad;setupUI;layoutViews 20  (1000.00 ms)
main;applicationDidLoad;initDatabase 10  (500.00 ms)
main;viewDidLoad 5  (250.00 ms)
========== END ==========
```

### 3. 复制到 speedscope

**重要：** 只复制 "🔥 FLAME GRAPH DATA" 部分的数据行！

```
main;viewDidLoad;fetchData;networkRequest 2000000
main;viewDidLoad;setupUI;layoutViews 1000000
main;applicationDidLoad;initDatabase 500000
main;viewDidLoad 250000
```

**数字说明：**
- 数字单位是**微秒(μs)**
- speedscope 会自动转换显示：
  - `2000000 μs` → `2.00 s` 或 `2000 ms`
  - `250000 μs` → `250 ms`

**不要包含：**
- ❌ 分隔线 `========== ... ==========`
- ❌ 提示文字
- ❌ 带时间注释的格式

### 4. 打开 speedscope

1. 访问 https://speedscope.app
2. 在页面中点击或直接粘贴数据
3. 选择 "Left Heavy" 或 "Sandwich" 视图

---

## 查看火焰图

### 视图模式

| 模式 | 说明 | 适用场景 |
|------|------|---------|
| **Time Order** | 按时间顺序显示 | 查看执行流程 |
| **Left Heavy** | 按调用栈聚合 | **推荐：查找热点** ⭐ |
| **Sandwich** | 三明治视图 | 查看函数被谁调用 |

### 操作技巧

**鼠标操作：**
- 点击：展开/折叠节点
- 悬停：查看详细信息
- 滚轮：缩放
- 拖动：平移

**快捷键：**
- `W/A/S/D`：缩放和平移
- `1/2/3`：切换视图模式

---

## 数据解读

### 火焰图怎么看？

```
                ┌──────────────┐
                │networkRequest│ ← 最宽：最耗时（40次）
        ┌───────┴──────┬───────┘
        │  fetchData   │layoutViews│
    ┌───┴──────────────┴───┬───────┐
    │    viewDidLoad       │  init │
┌───┴──────────────────────┴───────┘
│           main                   │
└──────────────────────────────────┘
```

**关键点：**
1. **宽度** = 采样次数 = 耗时
2. **从下往上** = 调用链（main 调用 viewDidLoad，viewDidLoad 调用 fetchData）
3. **最宽的条** = 最耗时的函数 = 优化重点！

### 具体数值在哪里？

**方式1：** 直接在 speedscope 中查看 ⭐ 推荐
- 鼠标悬停在火焰图的任意条上
- speedscope 会显示具体的时间值（如 `2.00 s` 或 `2000 ms`）
- 数值是根据微秒自动转换的

**方式2：** 查看控制台的"带时间信息的格式"
```
main;viewDidLoad;fetchData;networkRequest 40  (2000.00 ms) ← 这里
```

**方式3：** 运行 `printDetailedStatistics`
```
[[SUPSimpleFlameGraph sharedInstance] printDetailedStatistics];
```

输出：
```
调用路径                                    采样次数    耗时(ms)    占比(%)
==========================================================================
main;viewDidLoad;fetchData;networkRequest      40     2000.00     40.00%
```

---

## 常见问题

### Q1: speedscope 如何显示具体时间？

**自动显示！** speedscope 会自动将微秒转换为可读时间：
- `2000000` → 显示为 `2.00 s` 或 `2000 ms`
- `500000` → 显示为 `500 ms`
- 鼠标悬停在火焰图上即可看到

**如果看不到具体数值：**
- ✅ 确保复制了正确的数据（数字应该是微秒级别的大数字）
- ✅ 在 speedscope 中鼠标悬停查看
- ✅ 切换到 "Left Heavy" 视图

### Q2: 数字太大了，这正常吗？

**完全正常！** 数字是微秒单位：
```
2000000 微秒 = 2000 毫秒 = 2 秒
500000 微秒 = 500 毫秒 = 0.5 秒
```

speedscope 会自动识别并转换为 ms 或 s 显示，不用担心！

### Q3: 为什么提供两种格式？

| 格式 | 用途 | 优点 | 缺点 |
|------|------|------|------|
| **标准格式** | speedscope 可视化 | 兼容性好，图形直观 | 没有具体数值 |
| **带注释格式** | 控制台查看 | 有具体 ms 数值 | 不能用于 speedscope |

**最佳实践：** 两种都用！
- speedscope：看整体结构和热点
- 带注释格式：看具体数值

---

## 完整示例

### 代码

```objc
- (void)analyzePerformance {
    // 1. 开始采样
    [[SUPSimpleFlameGraph sharedInstance] startSamplingWithInterval:0.05];
    
    // 2. 执行要分析的代码
    [self loadAndRenderData];
    
    // 3. 停止采样
    [[SUPSimpleFlameGraph sharedInstance] stopSampling];
    
    // 4. 查看详细统计（包含具体 ms）
    [[SUPSimpleFlameGraph sharedInstance] printDetailedStatistics];
    
    // 5. 导出火焰图数据（标准格式 + 带注释格式）
    [[SUPSimpleFlameGraph sharedInstance] printFoldedStackToConsole];
}
```

### 控制台输出

```
🔥 开始火焰图采样 - 间隔: 50.00 ms
🔥 火焰图采样已停止，共采样 100 次

========== 📊 火焰图详细统计 ==========
总采样次数: 100
采样间隔: 50.00 ms
总耗时估算: 5000.00 ms

调用路径                                              采样次数       耗时(ms)     占比(%)
========================================================================================================
main;viewDidLoad;loadData;networkFetch                      40       2000.00     40.00%
main;viewDidLoad;renderUI;drawViews                         30       1500.00     30.00%
========== END ==========

========== 📊 采样统计信息 ==========
总采样次数: 100
采样间隔: 50.00 ms
总耗时估算: 5000.00 ms
=====================================

========== 🔥 FLAME GRAPH DATA (复制以下内容到 speedscope.app) ==========
提示：数字单位为微秒(μs)，speedscope 会自动转换显示为 ms 或 s

main;viewDidLoad;loadData;networkFetch 2000000
main;viewDidLoad;renderUI;drawViews 1500000
main;viewDidLoad;setupUI 500000
main;viewDidLoad 250000
main 250000
========== END ==========

========== 📝 带时间信息的格式 (供查看) ==========
main;viewDidLoad;loadData;networkFetch 40  (2000.00 ms)
main;viewDidLoad;renderUI;drawViews 30  (1500.00 ms)
main;viewDidLoad;setupUI 10  (500.00 ms)
main;viewDidLoad 5  (250.00 ms)
main 5  (250.00 ms)
========== END ==========
```

### 使用步骤

1. **复制标准格式数据**（不包括分隔线和提示）
```
main;viewDidLoad;loadData;networkFetch 2000000
main;viewDidLoad;renderUI;drawViews 1500000
main;viewDidLoad;setupUI 500000
main;viewDidLoad 250000
main 250000
```

2. **打开 speedscope.app**，粘贴数据

3. **切换到 "Left Heavy" 视图**

4. **查看具体时间**
   - speedscope 自动将微秒转换为可读格式
   - 鼠标悬停即可看到：`networkFetch: 2.00 s` 或 `2000 ms`

5. **分析结果**
   - 最宽的条：`networkFetch` (2000ms)
   - 第二宽：`drawViews` (1500ms)
   - 优化重点：网络请求和 UI 渲染

---

## 优化建议

根据火焰图找到的热点，采取相应优化措施：

| 热点函数 | 优化方向 |
|---------|---------|
| 网络请求 | 异步处理、缓存、CDN |
| JSON 解析 | 增量解析、后台线程 |
| UI 渲染 | 异步绘制、复用视图 |
| 数据库操作 | 批量操作、索引优化 |
| 图片处理 | 降采样、缓存、异步加载 |

---

## 总结

✅ **标准格式** → speedscope 可视化  
📝 **带注释格式** → 查看具体 ms  
📊 **详细统计** → Top 20 热点排序  

三管齐下，精准定位性能瓶颈！🎯

