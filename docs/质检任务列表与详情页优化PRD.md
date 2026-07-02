# 质检任务列表与详情页优化 PRD

## 文档信息

| 项目 | 内容 |
|------|------|
| 项目名称 | 象小秘质检任务列表与详情页优化 |
| 文档版本 | V1.0 |
| 创建日期 | 2026-06-30 |
| 状态 | 已完成 |

---

## 一、背景与目标

### 1.1 背景
当前质检任务功能在搜索筛选、数据展示等方面存在以下问题：
- 搜索区域使用多个独立搜索框，布局不统一，宽度不一致
- 任务列表缺少"质检范围"和"数据追加"字段，无法快速了解任务配置
- 任务详情页缺少"质检数据范围"查看入口，无法快速查看任务的数据配置信息
- 搜索条件中的操作符使用英文显示，不符合中文用户习惯

### 1.2 优化目标
1. 优化搜索区域布局，统一宽度，提升视觉一致性
2. 任务列表新增"质检范围"和"数据追加"字段，支持筛选
3. 任务详情页新增"质检数据范围"弹窗，展示任务创建时的数据配置
4. 将所有英文操作符转换为中文显示

---

## 二、功能需求

### 2.0 质检模式与数据追加功能

#### 2.0.1 录音类型卡片选择器

**位置：** 质检任务创建 - 步骤2

**功能描述：**
将原有的Radio单选改为卡片式选择器，提供更直观的交互体验。

**卡片选项：**

| 卡片名称 | 值 | 说明 |
|----------|-----|------|
| 人机协同录音 | ai_assisted | AI外呼产生的录音数据 |
| 人工外呼录音 | manual_outbound | 人工坐席外呼产生的录音数据 |
| 手动上传录音 | manual_upload | 手动上传的录音文件 |

**交互规则：**
- 点击卡片选中，显示对勾标记
- 选中卡片有蓝色边框高亮
- 卡片紧凑布局（padding: 8px 16px，font-size: 13px）
- 删除"录音类型"标签文案，卡片直接展示

---

#### 2.0.2 质检范围选择

**位置：** 质检任务创建 - 步骤2（手动上传录音时不显示）

**功能描述：**
支持两种质检范围模式，满足不同质检需求。

**质检范围选项：**

| 模式 | 值 | 说明 |
|------|-----|------|
| 全量质检 | full | 对符合条件的全部数据进行质检 |
| 部分抽检 | sampling | 按规则抽样部分数据进行质检 |

**交互规则：**
- 默认选中"全量质检"
- 选择不同模式时，下方配置区域动态切换
- 手动上传录音时隐藏此选项

---

#### 2.0.3 全量质检模式

**功能描述：**
全量质检模式复用现有条件表达式配置功能。

**配置项：**
- 条件表达式配置（字段类型、操作符、值）
- 支持多表达式，用"或"连接
- 支持多条件，用"且"连接

**字段类型选项：**

| 字段 | 值 | 输入类型 |
|------|-----|----------|
| 通话时间 | callTime | 时间选择器 |
| 通话时长 | callDuration | 数字输入框 |
| 客户意图 | intent | 文本输入框 |
| 坐席工号 | agent | 文本输入框 |

**操作符选项：**

| 操作符 | 值 | 说明 |
|--------|-----|------|
| = | = | 等于 |
| > | > | 大于 |
| < | < | 小于 |
| 包含 | contains | 包含指定内容 |
| 介于 | between | 介于两个值之间（显示两个输入框） |

---

#### 2.0.4 部分抽检模式

**功能描述：**
部分抽检模式支持按规则抽样部分数据进行质检。

**配置项：**

**1. 抽检数量**
- 输入框，限制输入正整数
- 表单校验：必填，正整数
- 提示：抽检条数不得大于总数据量

**2. 分配方式**

| 方式 | 值 | 说明 |
|------|-----|------|
| 按总量 | total | 设置抽检总数量 |
| 按比例 | ratio | 按百分比抽检 |
| 按人均 | perPerson | 按人均数量抽检 |

**3. 实时计算（按比例模式）**
- 查询按钮：点击查询当前条件下的数据总量
- 实时计算：抽检数量 = 总数 × 百分比 / 100
- 人均数量：抽检数量 ÷ 质检员人数

**4. 抽样方式**

| 方式 | 值 | 说明 |
|------|-----|------|
| 平均分配 | average | 数据平均分配给各质检员 |
| 按比例分配 | ratio | 按比例分配给各质检员 |

**5. 抽样维度**

| 维度 | 值 | 说明 |
|------|-----|------|
| 按场景 | scene | 按业务场景抽样 |
| 按坐席 | agent | 按坐席工号抽样 |
| 按通话时长 | callDuration | 按通话时长抽样 |

---

#### 2.0.5 自动追加新数据

**位置：** 质检范围选择区域内（全量质检和部分抽检都支持）

**功能描述：**
开启后，系统将按照配置的时间规则自动查询并追加符合条件的新数据到质检任务中。

**配置项：**

| 配置项 | 组件类型 | 说明 |
|--------|----------|------|
| 自动追加开关 | Switch | 开启/关闭自动追加 |
| 执行时间 | TimePicker | 每天执行时间（格式：HH:mm） |
| 查询开始类型 | Select | 当天/昨天 |
| 查询开始时间 | TimePicker | 开始时间（格式：HH:mm） |
| 查询结束类型 | Select | 当天/昨天 |
| 查询结束时间 | TimePicker | 结束时间（格式：HH:mm） |

**交互规则：**
- 默认关闭
- 开启后显示配置区域
- 配置区域用边框容器包裹
- 配置项以自然语言语句形式展示：
  - "每天 [执行时间] 点查询 [当天/昨天] [开始时间] ~ [当天/昨天] [结束时间] 时间段内满足条件的数据加入质检任务"

**提示文案：**
- 开启后，系统将按照配置的时间规则自动查询并追加符合条件的新数据到质检任务中

---

#### 2.0.6 数据去重（暂时隐藏）

**位置：** 质检范围选择区域内

**功能描述：**
对质检数据进行去重处理，避免重复质检。

**配置项：**

| 配置项 | 组件类型 | 说明 |
|--------|----------|------|
| 数据去重开关 | Switch | 开启/关闭数据去重 |
| 去重类型 | Radio | 全局去重/同质检模型去重 |

**去重类型说明：**

| 类型 | 值 | 说明 |
|------|-----|------|
| 全局去重 | global | 标记话术库+话术键为重复的通话，并去除重复的通话 |
| 同质检模型去重 | model | 标记话术库+话术键+质检模型为重复的通话，并去除重复的通话 |

**当前状态：** 功能已实现但暂时隐藏，待后续版本开放

---

#### 2.0.7 质检模式切换联动

**功能描述：**
当质检范围从"全量质检"切换到"部分抽检"时，保留已配置的条件表达式和自动追加配置。

**联动规则：**
- 切换质检范围时不清空条件表达式
- 切换质检范围时不清空自动追加配置
- 部分抽检模式下显示抽检配置区域
- 全量质检模式下隐藏抽检配置区域

---

#### 2.0.8 产品逻辑说明

**1. 数据追加触发逻辑**

| 触发条件 | 执行逻辑 |
|----------|----------|
| 任务状态为"进行中" | 系统在配置的执行时间自动触发查询 |
| 任务状态为"已完成" | 不再触发自动追加 |
| 任务状态为"已暂停" | 暂停自动追加，恢复后继续执行 |

**执行流程：**
1. 每天到达执行时间（如08:00）
2. 系统根据配置的时间范围查询数据
   - 例：查询昨天 00:00 ~ 23:59 时间段内的数据
3. 筛选满足条件表达式的数据
4. 对筛选结果进行去重（如开启）
5. 将新数据追加到质检任务中
6. 更新任务统计数据

**2. 抽检数量计算逻辑**

| 分配方式 | 计算公式 | 示例 |
|----------|----------|------|
| 按总量 | 抽检数量 = 用户输入值 | 输入100，则抽检100条 |
| 按比例 | 抽检数量 = 数据总量 × 百分比 / 100 | 总量1000，比例10%，则抽检100条 |
| 按人均 | 人均数量 = 抽检数量 / 质检员人数 | 抽检100条，5人，则人均20条 |

**数据量校验：**
- 按总量：输入值 ≤ 满足条件的数据总量
- 按比例：百分比 ≤ 100%
- 按人均：人均数量 ≤ 满足条件的数据总量 / 质检员人数

**3. 数据去重逻辑**

| 去重类型 | 去重规则 | 适用场景 |
|----------|----------|----------|
| 全局去重 | 话术库 + 话术键 相同的通话视为重复 | 跨任务去重，避免同一通话被多个任务重复质检 |
| 同质检模型去重 | 话术库 + 话术键 + 质检模型 相同的通话视为重复 | 同模型内去重，不同模型可质检同一通话 |

**去重处理流程：**
1. 查询满足条件的数据
2. 根据去重规则标记重复数据
3. 保留首次出现的数据，去除重复数据
4. 返回去重后的数据列表

**4. 条件表达式组合逻辑**

**多条件组合规则：**
- 同一表达式内的多个条件：AND（且）关系
- 不同表达式之间：OR（或）关系

**示例：**
```
表达式1：通话时间 介于 2026-02-01 ~ 2026-02-28 且 坐席工号 = 新入职坐席
表达式2：通话时长 > 60 且 客户意图 包含 金融产品

最终条件：(表达式1) 或 (表达式2)
```

**5. 质检员分配逻辑**

| 质检范围 | 分配方式 | 说明 |
|----------|----------|------|
| 全量质检 | 平均分配 | 数据按质检员人数平均分配 |
| 部分抽检（按总量/按比例） | 平均分配 | 抽检数据按质检员人数平均分配 |
| 部分抽检（按人均） | 按人均数量 | 每人分配固定数量的数据 |

**分配示例：**
- 全量质检：100条数据，5个质检员 → 每人20条
- 部分抽检（按总量）：抽检100条，5个质检员 → 每人20条
- 部分抽检（按人均）：每人20条，5个质检员 → 共100条

**6. 任务状态流转逻辑**

```
待开始 → 进行中 → 已完成
         ↓    ↑
       已暂停 ←┘
```

| 状态转换 | 触发条件 | 影响 |
|----------|----------|------|
| 待开始 → 进行中 | 手动开始或到达开始时间 | 开始质检，触发自动追加 |
| 进行中 → 已暂停 | 手动暂停 | 暂停质检，暂停自动追加 |
| 已暂停 → 进行中 | 手动恢复 | 恢复质检，恢复自动追加 |
| 进行中 → 已完成 | 手动完成或所有数据质检完毕 | 结束质检，停止自动追加 |

---

## 二（续）、任务列表功能需求

### 2.1 质检任务列表优化

#### 2.1.1 搜索区域布局优化

**位置：** 质检任务列表页顶部搜索区域

**修改内容：**

| 修改项 | 修改前 | 修改后 |
|--------|--------|--------|
| 搜索框数量 | 3个独立搜索框（任务名称、任务ID、任务说明） | 1个合并搜索框（任务名称/ID/说明） |
| 搜索框宽度 | span=8 | span=6（与其他筛选项一致） |
| 布局方式 | 两行布局，第一行14列，第二行18-24列 | 两行布局，第一行24列，第二行12-18列 |

**搜索项配置（第一行）：**

| 序号 | 搜索项 | 组件类型 | 占位符 | 宽度 |
|------|--------|----------|--------|------|
| 1 | 任务名称/ID/说明 | 输入框 | 请输入任务名称/ID/说明 | span=6 |
| 2 | 任务状态 | 下拉选择 | 请选择任务状态 | span=6 |
| 3 | 质检范围 | 下拉选择 | 请选择质检范围 | span=6 |
| 4 | 质检对象 | 下拉选择 | 请选择质检对象 | span=6 |

**搜索项配置（第二行）：**

| 序号 | 搜索项 | 组件类型 | 占位符 | 宽度 | 条件 |
|------|--------|----------|--------|------|------|
| 1 | 质检模型 | 下拉选择 | 请选择质检模型 | span=6 | 始终显示 |
| 2 | 数据追加 | 下拉选择 | 请选择数据追加 | span=6 | 始终显示 |
| 3 | 审核员 | 下拉选择 | 请选择审核员 | span=6 | AI质检任务 |
| 4 | 质检员 | 下拉选择 | 请选择质检员 | span=6 | 人工质检任务 |

**数据追加筛选选项：**
- 开启（value: 'true'）
- 关闭（value: 'false'）

---

#### 2.1.2 新增"质检范围"表格列

**位置：** 任务列表表格，在"质检对象"列之前

**列配置：**

| 属性 | 值 |
|------|-----|
| 列名 | 质检范围 |
| 字段 | qualityScope |
| 宽度 | 110px |
| 对齐方式 | 左对齐 |

**显示规则：**
- `full` → 全量质检
- `sampling` → 部分抽检

---

#### 2.1.3 新增"数据追加"表格列

**位置：** 任务列表表格，在"质检范围"列之后

**列配置：**

| 属性 | 值 |
|------|-----|
| 列名 | 数据追加 |
| 字段 | autoAppend |
| 宽度 | 100px |
| 对齐方式 | 左对齐 |

**显示规则：**
- `true` → 开启
- `false` → 关闭

---

#### 2.1.4 接口变更

**QualityTaskItem 接口新增字段：**

```typescript
interface QualityTaskItem {
  // ... 原有字段
  qualityScope: 'full' | 'sampling'  // 已存在
  autoAppend: boolean  // 新增：数据追加状态
}
```

**SearchFormData 接口新增字段：**

```typescript
interface SearchFormData {
  // ... 原有字段
  autoAppend: string | undefined  // 新增：数据追加筛选
}
```

---

### 2.2 质检任务详情页优化

#### 2.2.1 新增"质检数据范围"查看入口

**位置：** 任务信息卡片，第一行信息，在"质检对象"之后

**交互规则：**
- 显示文本：质检数据范围：
- 点击"查看"链接打开数据范围弹窗
- 链接样式：蓝色，hover时显示下划线

---

#### 2.2.2 质检数据范围弹窗

**弹窗配置：**

| 属性 | 值 |
|------|-----|
| 标题 | 质检数据范围 |
| 宽度 | 640px |
| 底部按钮 | 无（只读查看） |

**弹窗内容：**

**1. 质检范围**
- 标签：质检范围
- 内容：全量质检 / 部分抽检

**2. 录音类型**
- 标签：录音类型
- 内容：人机协同录音 / 人工外呼录音 / 手动上传录音

**3. 条件筛选**（有配置时显示）
- 标签：条件筛选
- 内容：条件表达式列表
- 显示格式：字段 操作符 值 [且/或连接]

**字段类型映射：**

| 字段值 | 显示文本 |
|--------|----------|
| callTime | 通话时间 |
| callDuration | 通话时长 |
| intent | 客户意图 |
| agent | 坐席工号 |

**操作符映射：**

| 操作符值 | 显示文本 |
|----------|----------|
| = | 等于 |
| > | 大于 |
| < | 小于 |
| >= | 大于等于 |
| <= | 小于等于 |
| != | 不等于 |
| contains | 包含 |
| between | 介于 |

**4. 自动追加新数据**（开启时显示）
- 标签：自动追加新数据
- 执行时间：每天 XX:XX 点
- 查询时间范围：[当天/昨天] XX:XX ~ [当天/昨天] XX:XX

**5. 抽检配置**（质检范围为"部分抽检"时显示）
- 标签：抽检配置
- 抽检数量：XXX 条
- 分配方式：按总量 / 按比例 / 按人均
- 分配值：XXX
- 抽样方式：平均分配 / 按比例分配
- 抽样维度：按场景 / 按坐席 / 按通话时长

---

#### 2.2.3 Mock数据示例

**人工质检任务：**

```javascript
{
  taskId: 1,
  taskName: '2026 年 2 月新入职坐席合规质检（人工）',
  qualityScope: 'full',
  recordType: 'manual_outbound',
  conditionExpressions: [
    {
      conditions: [
        { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' },
        { fieldType: 'agent', operator: '=', value: '新入职坐席' }
      ]
    }
  ],
  autoAppend: true,
  autoAppendExecTime: '08:00',
  autoAppendStartType: 'today',
  autoAppendRangeStart: '00:00',
  autoAppendEndType: 'today',
  autoAppendRangeEnd: '23:59'
}
```

**AI质检任务：**

```javascript
{
  taskId: 2,
  taskName: '2026 年 2 月金融产品合规质检专项',
  qualityScope: 'sampling',
  recordType: 'ai_assisted',
  conditionExpressions: [
    {
      conditions: [
        { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' }
      ]
    },
    {
      conditions: [
        { fieldType: 'callDuration', operator: '>', value: '60' },
        { fieldType: 'intent', operator: 'contains', value: '金融产品' }
      ]
    }
  ],
  autoAppend: true,
  autoAppendExecTime: '09:00',
  autoAppendStartType: 'yesterday',
  autoAppendRangeStart: '08:00',
  autoAppendEndType: 'today',
  autoAppendRangeEnd: '20:00',
  samplingCount: 100,
  allocationMethod: 'ratio',
  allocationValue: 10,
  samplingMethod: 'average',
  samplingDimension: 'scene'
}
```

---

#### 2.2.4 新增辅助函数

```typescript
// 录音类型标签
const getRecordTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    ai_assisted: '人机协同录音',
    manual_outbound: '人工外呼录音',
    manual_upload: '手动上传录音',
  }
  return map[type] || '-'
}

// 字段类型标签
const getFieldTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    callTime: '通话时间',
    callDuration: '通话时长',
    intent: '客户意图',
    agent: '坐席工号',
  }
  return map[type] || type
}

// 操作符标签
const getOperatorLabel = (operator: string) => {
  const map: Record<string, string> = {
    '=': '等于',
    '>': '大于',
    '<': '小于',
    '>=': '大于等于',
    '<=': '小于等于',
    '!=': '不等于',
    'contains': '包含',
    'between': '介于',
  }
  return map[operator] || operator
}

// 分配方式标签
const getAllocationMethodLabel = (method: string) => {
  const map: Record<string, string> = {
    total: '按总量',
    ratio: '按比例',
    perPerson: '按人均',
  }
  return map[method] || '-'
}

// 抽样方式标签
const getSamplingMethodLabel = (method: string) => {
  const map: Record<string, string> = {
    average: '平均分配',
    ratio: '按比例分配',
  }
  return map[method] || '-'
}

// 抽样维度标签
const getSamplingDimensionLabel = (dimension: string) => {
  const map: Record<string, string> = {
    scene: '按场景',
    agent: '按坐席',
    callDuration: '按通话时长',
  }
  return map[dimension] || '-'
}
```

---

## 三、接口变更

### 3.1 QualityTask.vue 接口变更

**QualityTaskItem 接口：**

```typescript
interface QualityTaskItem {
  // ... 原有字段
  qualityScope: 'full' | 'sampling'
  autoAppend: boolean  // 新增
}
```

**SearchFormData 接口：**

```typescript
interface SearchFormData {
  // ... 原有字段
  autoAppend: string | undefined  // 新增
}
```

---

### 3.2 QualityTaskDetail.vue 接口变更

**新增响应式变量：**

```typescript
const dataRangeVisible = ref(false)  // 数据范围弹窗可见性
```

---

## 三（续）、质检模式与数据追加接口定义

### 3.3 质检模式相关接口

**质检范围枚举：**

```typescript
type QualityScope = 'full' | 'sampling'
// full: 全量质检
// sampling: 部分抽检
```

**录音类型枚举：**

```typescript
type RecordType = 'ai_assisted' | 'manual_outbound' | 'manual_upload'
// ai_assisted: 人机协同录音
// manual_outbound: 人工外呼录音
// manual_upload: 手动上传录音
```

**字段类型枚举：**

```typescript
type FieldType = 'callTime' | 'callDuration' | 'intent' | 'agent'
// callTime: 通话时间
// callDuration: 通话时长
// intent: 客户意图
// agent: 坐席工号
```

**操作符枚举：**

```typescript
type Operator = '=' | '>' | '<' | '>=' | '<=' | '!=' | 'contains' | 'between'
// =: 等于
// >: 大于
// <: 小于
// >=: 大于等于
// <=: 小于等于
// !=: 不等于
// contains: 包含
// between: 介于
```

---

### 3.4 数据追加相关接口

**数据追加配置接口：**

```typescript
interface AutoAppendConfig {
  autoAppend: boolean  // 是否开启自动追加
  autoAppendExecTime?: string  // 执行时间（HH:mm）
  autoAppendStartType?: 'today' | 'yesterday'  // 查询开始类型
  autoAppendRangeStart?: string  // 查询开始时间（HH:mm）
  autoAppendEndType?: 'today' | 'yesterday'  // 查询结束类型
  autoAppendRangeEnd?: string  // 查询结束时间（HH:mm）
}
```

**条件表达式接口：**

```typescript
interface ConditionItem {
  fieldType: FieldType  // 字段类型
  operator: Operator  // 操作符
  value: string  // 值
  value2?: string  // 介于操作时的第二个值
}

interface ConditionExpression {
  conditions: ConditionItem[]  // 条件列表（AND关系）
}

interface ConditionExpressions {
  expressions: ConditionExpression[]  // 表达式列表（OR关系）
}
```

---

### 3.5 抽检配置相关接口

**分配方式枚举：**

```typescript
type AllocationMethod = 'total' | 'ratio' | 'perPerson'
// total: 按总量
// ratio: 按比例
// perPerson: 按人均
```

**抽样方式枚举：**

```typescript
type SamplingMethod = 'average' | 'ratio'
// average: 平均分配
// ratio: 按比例分配
```

**抽样维度枚举：**

```typescript
type SamplingDimension = 'scene' | 'agent' | 'callDuration'
// scene: 按场景
// agent: 按坐席
// callDuration: 按通话时长
```

**抽检配置接口：**

```typescript
interface SamplingConfig {
  samplingCount: number  // 抽检数量
  allocationMethod: AllocationMethod  // 分配方式
  allocationValue?: number  // 分配值（按比例时为百分比）
  samplingMethod: SamplingMethod  // 抽样方式
  samplingDimension: SamplingDimension  // 抽样维度
}
```

---

### 3.6 综合数据结构

**质检任务详情数据接口：**

```typescript
interface QualityTaskDetail {
  // 基础信息
  taskId: number | string
  taskName: string
  taskDescription?: string
  qualityObject: string
  qualityModel: string
  
  // 质检范围
  qualityScope: QualityScope
  recordType: RecordType
  
  // 条件表达式
  conditionExpressions?: ConditionExpression[]
  
  // 数据追加
  autoAppend: boolean
  autoAppendExecTime?: string
  autoAppendStartType?: 'today' | 'yesterday'
  autoAppendRangeStart?: string
  autoAppendEndType?: 'today' | 'yesterday'
  autoAppendRangeEnd?: string
  
  // 抽检配置（仅 qualityScope='sampling' 时有效）
  samplingCount?: number
  allocationMethod?: AllocationMethod
  allocationValue?: number
  samplingMethod?: SamplingMethod
  samplingDimension?: SamplingDimension
  
  // 其他字段
  taskStatus: string
  createTime: string
  updateTime?: string
  auditor?: string
  inspector?: string | string[]
}
```

---

## 四、样式变更

### 4.1 QualityTaskDetail.vue 新增样式

```scss
/* 数据范围链接 */
.data-range-link {
  color: #1677ff;
  cursor: pointer;
  font-size: 14px;
}

.data-range-link:hover {
  color: #4096ff;
  text-decoration: underline;
}

/* 数据范围弹窗内容 */
.data-range-content {
  padding: 8px 0;
}

.data-range-section {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.data-range-section:last-child {
  border-bottom: none;
}

.section-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 8px;
}

.section-value {
  font-size: 14px;
  color: #595959;
}

/* 条件表达式样式 */
.condition-expressions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.condition-expression-item {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.expression-conditions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.condition-field {
  color: #1677ff;
  font-weight: 500;
}

.condition-operator {
  color: #8c8c8c;
  margin: 0 4px;
}

.condition-value {
  color: #262626;
}

.condition-connector {
  color: #8c8c8c;
  margin: 0 8px;
}

.expression-connector {
  color: #ff4d4f;
  font-weight: 500;
  margin: 0 8px;
}

/* 自动追加和抽检配置样式 */
.auto-append-info,
.sampling-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.append-item,
.sampling-item {
  display: flex;
  align-items: center;
}

.append-label,
.sampling-label {
  color: #8c8c8c;
  font-size: 14px;
  min-width: 100px;
}

.append-value,
.sampling-value {
  color: #262626;
  font-size: 14px;
}
```

---

## 五、测试要点

### 5.1 质检任务列表

- [ ] 搜索区域布局正确，所有筛选项宽度一致（span=6）
- [ ] 第一行4个筛选项正好占满24列，无换行
- [ ] 第二行筛选项按条件显示（审核员/质检员）
- [ ] 关键词搜索支持任务名称、ID、说明模糊搜索
- [ ] 质检范围筛选功能正常
- [ ] 数据追加筛选功能正常（开启/关闭）
- [ ] 质检范围列显示正确（全量质检/部分抽检）
- [ ] 数据追加列显示正确（开启/关闭）
- [ ] 搜索重置功能正常

### 5.2 质检任务详情

- [ ] 任务信息卡片显示"质检数据范围：查看"链接
- [ ] 点击"查看"链接打开数据范围弹窗
- [ ] 弹窗标题显示"质检数据范围"
- [ ] 质检范围显示正确
- [ ] 录音类型显示正确（中文）
- [ ] 条件筛选显示正确（字段、操作符、值均为中文）
- [ ] 多条件表达式"且"/"或"连接显示正确
- [ ] 自动追加新数据配置显示正确
- [ ] 抽检配置显示正确（仅部分抽检时显示）
- [ ] 弹窗只读，无底部按钮

---

## 六、注意事项

1. **向后兼容：** `autoAppend` 字段为新增字段，需确保后端接口支持或有默认值
2. **Mock数据：** 当前使用Mock数据展示，实际开发需对接后端接口
3. **操作符映射：** 所有操作符已转换为中文显示，确保用户理解
4. **响应式布局：** 搜索区域在不同屏幕宽度下可能需要调整

---

## 七、变更记录

| 版本 | 日期 | 修改人 | 修改内容 |
|------|------|--------|----------|
| V1.0 | 2026-06-30 | - | 初始版本，完成所有功能需求文档 |
| V1.1 | 2026-06-30 | - | 补充质检模式与数据追加接口定义（枚举类型、配置接口、综合数据结构） |
| V1.2 | 2026-06-30 | - | 补充产品逻辑说明（数据追加触发、抽检计算、去重逻辑、条件组合、质检员分配、状态流转） |
