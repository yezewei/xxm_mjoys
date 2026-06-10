# 任务明细列表字段拆分与布局优化 PRD

## 文档信息

| 项目 | 内容 |
|------|------|
| 项目名称 | 象小秘质检任务明细列表优化 |
| 文档版本 | V1.0 |
| 创建日期 | 2026-03-21 |
| 状态 | 开发中 |

---

## 一、背景与目标

### 1.1 背景
当前质检任务明细列表（工作台-任务明细列表、任务详情-任务明细列表）存在以下问题：
- "触发质检规则"为单一字段，无法区分关键词、AI、人工三种质检来源
- "质检总结"为单一字段，无法区分AI生成与人工撰写的总结内容
- 列排列顺序缺乏逻辑分组，信息密度分布不合理
- 高级搜索仅支持按"触发质检项"下拉选择，无法按分类独立检索
- 任务详情页搜索栏按钮宽度异常，区间搜索宽度不一致，抽屉行间距过大

### 1.2 优化目标
1. 将"触发质检规则"拆分为关键词匹配、AI识别、人工标注三个独立列
2. 将"质检总结"拆分为AI质检总结、人工质检总结两个独立列
3. 按「任务基本信息 → 关键词 → AI → 人工」逻辑重新排列列顺序
4. 高级搜索支持按三类质检项独立检索
5. 修复搜索栏布局、区间搜索宽度、抽屉行间距等样式问题

---

## 二、适用范围

| 页面 | 文件 | 说明 |
|------|------|------|
| 工作台-任务明细列表 | QualityWorkbench.vue | 质检工作台主页面 |
| 任务详情-任务明细列表 | QualityTaskDetail.vue | 质检任务详情页面 |

---

## 三、功能需求

### 3.1 质检项列拆分

**修改内容：** 将原"触发质检规则"单列拆分为三列

| 原列名 | 拆分后列名 | 数据字段 | 说明 |
|--------|------------|----------|------|
| 触发质检规则 | 关键词匹配质检项 | keywordRules | 展示关键词命中的质检项 |
| 触发质检规则 | AI识别质检项 | aiRules | 展示AI识别命中的质检项（仅AI任务类型可见） |
| 触发质检规则 | 人工标注质检项 | manualRules | 展示人工标注的质检项 |

**列宽：** 各列宽度 160px

**无数据展示：** 字段为空时显示 `-`

**任务类型可见性：**

| 列名 | AI质检任务 | 人工质检任务 |
|------|-----------|-------------|
| 关键词匹配质检项 | ✅ | ✅ |
| AI识别质检项 | ✅ | ❌ |
| 人工标注质检项 | ✅ | ✅ |

---

### 3.2 质检总结列拆分

**修改内容：** 将原"质检总结"单列拆分为两列

| 原列名 | 拆分后列名 | 数据字段 | 说明 |
|--------|------------|----------|------|
| 质检总结 | AI质检总结 | aiSummary | 展示AI生成的质检总结（仅AI任务类型可见） |
| 质检总结 | 人工质检总结 | manualSummary | 展示人工撰写的质检总结 |

**列宽：** 各列宽度 200px

**无数据展示：** 字段为空时显示 `-`

**任务类型可见性：**

| 列名 | AI质检任务 | 人工质检任务 |
|------|-----------|-------------|
| AI质检总结 | ✅ | ❌ |
| 人工质检总结 | ✅ | ✅ |

---

### 3.3 列顺序调整

**排序规则：** 按「任务基本信息 → 关键词 → AI → 人工」的逻辑重新排列列顺序

#### AI质检任务列顺序

| 序号 | 列名 | 分类 |
|------|------|------|
| 1 | 明细ID | 基本信息 |
| 2 | 通话记录ID | 基本信息 |
| 3 | ASR识别状态 | 基本信息 |
| 4 | AI质检状态 | 基本信息 |
| 5 | 人工质检状态 | 基本信息 |
| 6 | 是否人工修改 | 基本信息 |
| 7 | 关键词匹配质检项 | 关键词 |
| 8 | AI识别质检项 | AI |
| 9 | 人工标注质检项 | 人工 |
| 10 | AI质检总结 | AI |
| 11 | 人工质检总结 | 人工 |
| 12 | AI评分 | AI |
| 13 | 人工评分 | 人工 |
| 14 | 审核员 | 基本信息 |
| 15 | 操作 | - |

#### 人工质检任务列顺序

| 序号 | 列名 | 分类 |
|------|------|------|
| 1 | 明细ID | 基本信息 |
| 2 | 通话记录ID | 基本信息 |
| 3 | ASR识别状态 | 基本信息 |
| 4 | 人工质检状态 | 基本信息 |
| 5 | 是否人工修改 | 基本信息 |
| 6 | 关键词匹配质检项 | 关键词 |
| 7 | 人工标注质检项 | 人工 |
| 8 | 人工质检总结 | 人工 |
| 9 | 人工评分 | 人工 |
| 10 | 质检员 | 基本信息 |
| 11 | 操作 | - |

---

### 3.4 高级搜索条件扩展

**修改内容：** 将原"触发质检项"下拉选择替换为三个独立搜索条件

| 原搜索条件 | 替换为 | 输入类型 | 数据字段 |
|------------|--------|----------|----------|
| 触发质检项（下拉选择） | 关键词匹配质检项 | 文本输入框，allow-clear | keywordRule |
| 触发质检项（下拉选择） | AI识别质检项 | 文本输入框，allow-clear | aiRule |
| 触发质检项（下拉选择） | 人工标注质检项 | 文本输入框，allow-clear | manualRule |

**搜索条件位置：** 在"是否人工修改"之后、"质检员"之前

**重置规则：** 点击"重置"按钮时，三个新增搜索条件均重置为 `undefined`

---

### 3.5 搜索栏布局修复

**适用页面：** QualityTaskDetail.vue

**问题描述：** 搜索/重置/高级搜索三个按钮宽度异常，被拉伸为与输入框等宽

**原因分析：** 原布局使用 `grid-template-columns: repeat(4, 1fr)`，按钮作为 grid 子项被强制拉伸

**修复方案：**
- 将输入框和按钮包裹在 `toolbar-left` + `a-space` 容器中（与 QualityWorkbench 保持一致）
- 布局方式从 `grid` 改为 `flex`
- 输入框宽度统一为 `180px`
- 清理不再使用的 `.filter-input`、`.filter-select`、`.filter-buttons` 样式

**修复后结构：**
```html
<div class="filter-card">
  <div class="intent-toolbar">
    <div class="toolbar-left">
      <a-space>
        <a-input style="width: 180px" ... />
        <a-input style="width: 180px" ... />
        <a-select style="width: 180px" ... />
        <a-button type="primary">搜索</a-button>
        <a-button>重置</a-button>
        <a-button>高级搜索</a-button>
      </a-space>
    </div>
  </div>
</div>
```

**CSS 变更：**
```scss
// 修改前
.intent-toolbar {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

// 修改后
.intent-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
```

---

### 3.6 区间搜索宽度对齐

**适用页面：** QualityWorkbench.vue、QualityTaskDetail.vue

**问题描述：** 高级搜索中评分区间（如"AI评分最低 ~ AI评分最高"）的总宽度与其他输入框不一致

**修复方案：**
- `score-range-group` 添加 `width: 100%`
- `range-input` 从固定 `width: 110px` 改为 `flex: 1`（两个输入框各占一半）

```scss
// 修改前
.score-range-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.range-input {
  width: 110px;
}

// 修改后
.score-range-group {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}

.range-input {
  flex: 1;
}
```

---

### 3.7 搜索条件行间距优化

**适用页面：** QualityWorkbench.vue、QualityTaskDetail.vue

**问题描述：** 高级搜索抽屉中筛选条件之间行间距过大（Ant Design Vue 默认 24px）

**修复方案：** 覆盖默认 `margin-bottom` 为 `8px`

```scss
.advanced-search-drawer :deep(.ant-form-item) {
  margin-bottom: 8px;
}
```

---

## 四、接口变更

### 4.1 TableDataItem 接口（任务明细列表）

```typescript
interface TableDataItem {
  id: number
  detailId: string
  callId: string
  asrStatus: string
  aiStatus?: string
  manualStatus: string
  isModified: string

  // 已移除
  // triggerRule: string

  // 新增字段
  keywordRules: string    // 关键词匹配质检项
  aiRules: string         // AI识别质检项
  manualRules: string     // 人工标注质检项
  aiSummary: string       // AI质检总结
  manualSummary: string   // 人工质检总结

  aiScore?: number
  manualScore: number
  auditor?: string
  inspector?: string
  operation: string
}
```

### 4.2 FilterForm 接口（高级搜索）

```typescript
interface FilterForm {
  detailId: string
  callId: string
  asrStatus: string | undefined
  aiStatus: string | undefined
  manualStatus: string | undefined
  isModified: string | undefined

  // 已移除
  // triggerItem: string | undefined

  // 新增字段
  keywordRule: string | undefined   // 关键词匹配质检项搜索
  aiRule: string | undefined        // AI识别质检项搜索
  manualRule: string | undefined    // 人工标注质检项搜索

  auditor: string | undefined
  aiScoreMin: number | undefined
  aiScoreMax: number | undefined
  manualScoreMin: number | undefined
  manualScoreMax: number | undefined
}
```

---

## 五、测试要点

### 5.1 质检项拆分

- [ ] AI任务类型显示关键词匹配、AI识别、人工标注三列
- [ ] 人工任务类型显示关键词匹配、人工标注两列（无AI列）
- [ ] 无数据时显示 `-`

### 5.2 质检总结拆分

- [ ] AI任务类型显示AI质检总结、人工质检总结两列
- [ ] 人工任务类型仅显示人工质检总结列
- [ ] 无数据时显示 `-`

### 5.3 列顺序

- [ ] 列顺序按「基本信息 → 关键词 → AI → 人工」排列
- [ ] 工作台和任务详情页列顺序一致

### 5.4 高级搜索

- [ ] 三个质检项搜索框可独立输入和清除
- [ ] 搜索条件与表格列字段对应正确
- [ ] 重置按钮清空所有新增搜索条件

### 5.5 布局与样式

- [ ] 搜索/重置/高级搜索按钮宽度正常，未被拉伸
- [ ] 区间搜索总宽度与其他输入框一致
- [ ] 高级搜索抽屉中筛选条件行间距紧凑

---

## 六、变更文件清单

| 文件 | 修改内容 |
|------|----------|
| QualityWorkbench.vue | 接口、列定义、bodyCell模板、Mock数据、搜索条件、CSS |
| QualityTaskDetail.vue | 接口、列定义、bodyCell模板、Mock数据、搜索条件、布局修复、CSS |

---

## 七、质检规则评分功能

### 7.1 规则管理页面评分设置

**适用页面：** QualityRule.vue（质检规则管理页面）

**功能描述：** 每条质检规则支持配置评分规则，用于质检时对通话质量进行量化评分。

#### 数据模型

| 字段 | 类型 | 说明 |
|------|------|------|
| scoreType | `'add' \| 'deduct'` | 评分类型：add=得分，deduct=扣分 |
| scoreValue | `number` | 评分值（0-100 整数） |

#### 表格展示

**列名：** 评分

**展示规则：**
- 使用 `a-tag` 标签展示
- 得分（add）：绿色标签，格式 `+{value}分`
- 扣分（deduct）：红色标签，格式 `-{value}分`
- 未配置时显示 `-`

**示例：**
- `+10分`（绿色）— 得分规则
- `-5分`（红色）— 扣分规则

#### 添加/编辑弹窗

**表单项：** 评分设置

**交互规则：**
- 使用 `a-radio-group` 切换评分类型
  - `得分`（value: add）
  - `扣分`（value: deduct）
- 默认选中 `得分`
- 使用 `a-input-number` 输入分值
  - 最小值：0
  - 最大值：100
  - 精度：整数（precision: 0）
  - 后缀：分
  - 占位符：请输入分值
  - 宽度：140px

**表单校验：**
- 评分类型（scoreType）：必填
- 评分值（scoreValue）：必填

#### 接口定义

```typescript
interface QualityRuleItem {
  id: number
  ruleCode: string
  ruleName: string
  ruleDescription: string
  qualityModelId?: number
  qualityModelName?: string
  tags: string
  tagsArray: string[]
  keywordRules?: string
  scoreType?: 'add' | 'deduct'  // 评分类型
  scoreValue?: number            // 评分值
}
```

---

### 7.2 任务明细列表评分展示

**适用页面：** QualityWorkbench.vue、QualityTaskDetail.vue

**功能描述：** 任务明细列表中展示 AI 评分和人工评分，用于直观反映通话质量。

#### 列定义

| 列名 | 数据字段 | 任务类型可见性 | 说明 |
|------|----------|----------------|------|
| AI评分 | aiScore | 仅 AI 任务 | AI 模型对通话的评分 |
| 人工评分 | manualScore | AI + 人工任务 | 人工质检员对通话的评分 |

**列宽：** 100px

#### 展示规则

- 评分以数字形式展示，带颜色区分
- 未评分（null/undefined）时显示 `-`

**颜色规则：**

| 评分区间 | 颜色 | 色值 | 含义 |
|----------|------|------|------|
| ≥ 80 | 绿色 | #52c41a | 优秀 |
| 60 ~ 79 | 黄色 | #faad14 | 一般 |
| < 60 | 红色 | #ff4d4f | 较差 |

**样式：** 数字加粗（font-weight: 600）

#### 高级搜索 — 评分区间

**搜索字段：**

| 搜索条件 | 输入类型 | 数据字段 | 说明 |
|----------|----------|----------|------|
| AI评分最低 | 数字输入框 | aiScoreMin | AI 评分下限（仅 AI 任务） |
| AI评分最高 | 数字输入框 | aiScoreMax | AI 评分上限（仅 AI 任务） |
| 人工评分最低 | 数字输入框 | manualScoreMin | 人工评分下限 |
| 人工评分最高 | 数字输入框 | manualScoreMax | 人工评分上限 |

**输入限制：** 最小值 0，最大值 100

**布局：** 两两配对使用区间搜索组件（`score-range-group`），格式 `最低 ~ 最高`

#### 接口定义

```typescript
interface TableDataItem {
  // ... 其他字段
  aiScore?: number      // AI评分（仅AI任务类型有值）
  manualScore?: number  // 人工评分
}

interface FilterForm {
  // ... 其他字段
  aiScoreMin: number | undefined
  aiScoreMax: number | undefined
  manualScoreMin: number | undefined
  manualScoreMax: number | undefined
}
```

---

### 7.3 评分测试要点

#### 规则管理页面

- [ ] 添加规则时可选择得分/扣分
- [ ] 分值输入限制为 0-100 整数
- [ ] 表格中得分显示绿色 `+N分`，扣分显示红色 `-N分`
- [ ] 编辑规则时评分设置回显正确
- [ ] 未配置评分时显示 `-`

#### 明细列表

- [ ] AI评分列仅在 AI 任务类型下可见
- [ ] 人工评分列在两种任务类型下均可见
- [ ] 评分颜色按 ≥80 绿色、60-79 黄色、<60 红色显示
- [ ] 未评分时显示 `-`
- [ ] 评分区间搜索（最低/最高）可正常输入和清除
- [ ] 重置按钮清空所有评分搜索条件
