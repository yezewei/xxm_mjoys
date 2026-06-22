---
name: vue-view-overview-from-wizard
description: 将多步骤向导弹窗的"查看模式"拆分为独立只读概览弹窗，列表点击"查看"时打开概览而非向导
source: auto-skill
extracted_at: '2026-06-22T12:00:00.000Z'
---

# 从多步骤向导中拆分只读查看概览弹窗

当一个多步骤新建/编辑向导弹窗同时承担"查看"功能（通过 `isViewMode` 禁用表单），导致查看体验不佳（用户需逐步翻页才能看到全部信息）时，将查看功能拆分为独立的只读概览弹窗。

## 适用场景

- 列表页有"查看"按钮，当前复用新建/编辑向导的 view 模式
- 向导步骤 ≥ 3 步，查看时需要翻页才能看完全部信息
- 向导最后一步底部有一个概览卡片（规则概览/策略概览），查看时应直接展示这类概览
- 需要将"编辑"入口和"查看"入口解耦

## 操作步骤

### 1. 移除向导最后一步中的概览卡片

向导最后一步底部通常有一个 `.strategy-overview` 或类似的概览区块，将其整块删除：

```html
<!-- 删除这段 -->
<div class="strategy-overview">
  <div class="overview-title">规则概览</div>
  <div class="overview-grid">
    <div class="overview-item">...</div>
  </div>
</div>
```

### 2. 补充列表数据中缺失的字段

查看概览通常需要展示比列表表格更多的字段（如 `inspectType`、`qualityModel`），需确保数据接口/类型/mock 数据包含这些字段：

```ts
interface ListItem {
  // 原有字段
  ruleName: string
  dataType: string
  // 补充查看概览需要的字段
  inspectType: 'ai' | 'manual'
  qualityModel: string
  // ...
}
```

### 3. 新增查看弹窗状态变量

```ts
const viewModalVisible = ref(false)
const viewRecord = ref<ListItem | null>(null)
```

### 4. 修改 handleView 函数

从"打开向导的 view 模式"改为"打开独立查看弹窗"：

```ts
// 修改前
const handleView = (record: ListItem) => {
  isViewMode.value = true
  isEditMode.value = false
  editingRuleId.value = record.id
  currentStep.value = 1
  fillFormData(record)
  modalVisible.value = true
}

// 修改后
const handleView = (record: ListItem) => {
  viewRecord.value = record
  viewModalVisible.value = true
}
```

### 5. 在已有 Modal 之后添加查看概览弹窗

放在编辑弹窗的 `</a-modal>` 之后、`</div></template>` 之前：

```html
<!-- 查看规则概览弹窗 -->
<a-modal
  v-model:open="viewModalVisible"
  title="查看XX"
  width="800px"
  :footer="null"
  @cancel="viewModalVisible = false"
>
  <div v-if="viewRecord" class="view-overview-content">
    <!-- 按业务模块分区块展示 -->
    <div class="view-section">
      <div class="view-section-title">基本信息</div>
      <div class="overview-grid">
        <div class="overview-item">
          <span class="overview-label">字段名</span>
          <span class="overview-value">{{ viewRecord.field }}</span>
        </div>
        <!-- 需要标签渲染的字段用 a-tag -->
        <div class="overview-item">
          <span class="overview-label">数据类型</span>
          <span class="overview-value">
            <a-tag v-if="viewRecord.type === 'a'" color="blue">类型A</a-tag>
            <a-tag v-else color="cyan">类型B</a-tag>
          </span>
        </div>
        <!-- 枚举字段用 options 映射 -->
        <div class="overview-item">
          <span class="overview-label">模型</span>
          <span class="overview-value">
            {{ modelOptions.find(o => o.value === viewRecord!.model)?.label || viewRecord.model }}
          </span>
        </div>
      </div>
    </div>

    <a-divider />

    <!-- 第二区块：抽样/分配规则 -->
    <div class="view-section">
      <div class="view-section-title">抽样规则</div>
      <div class="overview-grid">
        <!-- ... -->
      </div>
    </div>

    <a-divider />

    <!-- 第三区块：调度/执行规则 -->
    <div class="view-section">
      <div class="view-section-title">任务规则</div>
      <div class="overview-grid">
        <!-- 条件渲染不同模式的展示 -->
        <div class="overview-item">
          <span class="overview-label">时间偏移</span>
          <span class="overview-value">
            <template v-if="viewRecord.offsetMode === 'timeRange'">
              当天 {{ viewRecord.startTime || '未设置' }} ~ {{ viewRecord.endTime || '未设置' }}
            </template>
            <template v-else>
              T-{{ viewRecord.offset }} 日
            </template>
          </span>
        </div>
        <!-- Switch 只读展示 -->
        <div class="overview-item">
          <span class="overview-label">状态</span>
          <span class="overview-value">
            <a-switch :checked="viewRecord.status === 'enabled'" size="small" disabled />
          </span>
        </div>
      </div>
    </div>
  </div>

  <template #footer>
    <a-button @click="viewModalVisible = false">关闭</a-button>
  </template>
</a-modal>
```

### 6. 添加查看弹窗专用样式

```css
.view-overview-content {
  padding: 8px 0;
}

.view-section {
  margin-bottom: 0;
}

.view-section-title {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 16px;
}
```

> `overview-grid`、`overview-item`、`overview-label`、`overview-value` 等样式如果向导中已有，可直接复用，无需重复声明。

### 7. 如有需要，添加格式化辅助函数

当查看概览中的某个字段展示逻辑与列表列的格式化不同（如执行计划需要更详细的描述），添加专用函数：

```ts
const getViewScheduleLabel = (record: ListItem) => {
  let desc = `每天 ${record.executeTime}`
  if (record.offsetMode === 'timeRange') {
    desc += `，抓取当天 ${record.startTime || '未设置'}~${record.endTime || '未设置'} 的数据`
  } else {
    desc += `，T-${record.offset} 日`
  }
  return desc
}
```

## 设计要点

### 概览区块划分原则

按向导步骤自然划分：
- 步骤 1（基本信息）→ 区块 1
- 步骤 2（规则配置）→ 区块 2
- 步骤 3（调度/执行）→ 区块 3

每两个区块之间用 `<a-divider />` 分隔。

### 字段渲染策略

| 字段类型 | 渲染方式 |
|---------|---------|
| 普通文本 | `{{ viewRecord.field }}` |
| 枚举（有 options 数组） | `.find(o => o.value === ...)?.label` |
| 标签型枚举 | `<a-tag :color="...">` |
| 条件模式 | `<template v-if="viewRecord.mode === 'x'">` |
| 布尔状态 | `<a-switch :checked="..." disabled />` |
| 数值+单位 | `{{ viewRecord.value }} 条` / `{{ viewRecord.value }}%` |

### 与向导 view 模式的区别

| 维度 | 旧方案（向导 view 模式） | 新方案（独立概览弹窗） |
|------|------------------------|----------------------|
| 用户操作 | 逐步翻页，每步禁用表单 | 一屏看完所有信息 |
| 代码维护 | view 模式散落在每个步骤中 | 集中在一个独立模板中 |
| 样式 | 复用表单样式，有大量 disabled 控件 | 纯展示，无表单控件 |
| 标题 | "查看XX规则"（同编辑） | "查看XX规则"（独立弹窗） |
| 底部按钮 | "关闭"（隐藏上一步/下一步） | "关闭"（模板中显式声明） |

## 常见陷阱

### viewRecord 类型断言

在 `.find()` 的回调中使用 `viewRecord` 时需要非空断言 `viewRecord!`，因为外层已有 `v-if="viewRecord"` 保证：

```ts
{{ qualityModelOptions.find(o => o.value === viewRecord!.qualityModel)?.label }}
```

### 条件渲染中的时间对象格式化

向导中 `dayjs` 对象直接调用 `.format('HH:mm')`，但查看概览中数据来自原始记录（字符串），直接展示即可：

```html
<!-- 向导中（dayjs 对象） -->
{{ formData.schedule.dataStartTime.format('HH:mm') }}

<!-- 查看概览中（字符串） -->
{{ viewRecord.dataStartTime || '未设置' }}
```

### 概览弹窗宽度

查看弹窗通常比编辑弹窗窄（800px vs 960px），因为没有表单控件需要更多横向空间。
