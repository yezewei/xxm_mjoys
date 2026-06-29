---
name: vue-modal-mode-switch
description: Vue 3 弹窗步骤中用 Radio 切换两种功能模式（如全量/抽检），一种模式保持原有逻辑，另一种模式展示从其他组件移植的完整子功能（含独立数据表、CRUD、计算属性）
source: auto-skill
extracted_at: '2026-06-29T06:53:58.970Z'
---

# 弹窗步骤内双模式切换

当弹窗某一步骤需要在两种完全不同的功能模式间切换时（如「全量质检」vs「部分抽检」），其中一种模式保留原有逻辑，另一种模式需要展示从其他组件移植过来的完整子功能（含独立数据表、增删改查、计算属性），按以下步骤实现。

> 与 `vue-conditional-radio-subform`（radio + tooltip + 简单子表单）不同，本技能处理的是**整个功能块级别的模式切换**，两种模式各自有独立的数据模型和交互逻辑。
> 与 `vue-field-to-multimode`（改造已有单字段为多模式）不同，本技能不改造已有字段，而是在已有内容上方新增模式选择器，将已有内容归入一种模式。

## 1. 扩展表单接口

在 form interface 中添加模式标识字段及新模式所需的全部子字段：

```ts
interface CreateTaskForm {
  // ... 已有字段
  qualityScope: 'full' | 'sampling'          // 模式标识
  samplingCount: number | null                // 新模式字段
  allocationMethod: 'total' | 'ratio' | 'perPerson'  // 新模式字段
  allocationValue: number | null
  samplingMethod: 'average' | 'ratio'
  samplingDimension: 'scene' | 'agent' | 'callDuration'
}
```

在 reactive 初始化中添加对应默认值：

```ts
const createTaskForm = reactive<CreateTaskForm>({
  // ... 已有字段
  qualityScope: 'full',           // 默认模式 A
  allocationMethod: 'total',
  allocationValue: null,
  samplingMethod: 'average',
  samplingDimension: 'scene',
})
```

## 2. 模板结构

在原有内容**上方**插入模式选择器，用 `<template v-if>` 包裹两种模式的内容。

### 2.1 模式选择器样式

**普通模式**（简单场景，两种模式差异小）用 `a-radio-group` 即可。

**卡片模式**（推荐，两种模式差异大时更醒目）：用自定义卡片代替 radio，支持 hover/active/选中勾选态：

```html
<div class="scope-section">
  <div class="scope-cards">
    <div
      class="scope-card"
      :class="{ active: form.scope === 'full' }"
      @click="form.scope = 'full'; handleScopeChange()"
    >
      <div class="scope-card-info">
        <div class="scope-card-title">全量质检</div>
        <div class="scope-card-desc">对符合条件的全部数据进行质检</div>
      </div>
      <check-circle-filled v-if="form.scope === 'full'" class="scope-card-check" />
    </div>
    <div
      class="scope-card"
      :class="{ active: form.scope === 'sampling' }"
      @click="form.scope = 'sampling'; handleScopeChange()"
    >
      <div class="scope-card-info">
        <div class="scope-card-title">部分抽检</div>
        <div class="scope-card-desc">按规则抽样部分数据进行质检</div>
      </div>
      <check-circle-filled v-if="form.scope === 'sampling'" class="scope-card-check" />
    </div>
  </div>
</div>
```

卡片 CSS：
```css
.scope-cards { display: flex; gap: 16px; }
.scope-card {
  flex: 1; display: flex; align-items: center; gap: 12px;
  padding: 14px 20px; border: 2px solid #e8e8e8; border-radius: 8px;
  cursor: pointer; transition: all 0.2s ease; background: #fff;
}
.scope-card:hover { border-color: #91caff; background: #f0f7ff; }
.scope-card.active { border-color: #1677ff; background: #e6f4ff; box-shadow: 0 0 0 1px rgba(22,119,255,0.1); }
.scope-card-title { font-size: 15px; font-weight: 600; color: #262626; margin-bottom: 4px; }
.scope-card.active .scope-card-title { color: #1677ff; }
.scope-card-desc { font-size: 12px; color: #8c8c8c; }
.scope-card-check { font-size: 20px; color: #1677ff; flex-shrink: 0; }
```

> 不要在卡片上方加"质检范围"之类的标签——卡片标题自身已足够清晰。

### 2.2 统一数量区域

当两种模式都需要展示"数量"相关配置时，用一个共享的 section 统一展示，而非各自独立：

```html
<!-- 统一数量区域 — 两种模式共用一个容器 -->
<div v-if="showCountSection" class="count-section">
  <div class="count-section-label">质检数量</div>

  <!-- 模式 A：自动查询 -->
  <div v-if="form.scope === 'full'" class="count-content">
    <a-button type="link" @click="handleQueryData" :loading="queryLoading">
      <search-outlined /> 查询数据
    </a-button>
    <span v-if="queryResult !== null">
      已查询到 <strong>{{ queryResult }}</strong> 条数据
    </span>
  </div>

  <!-- 模式 B：采样数量配置 -->
  <div v-if="form.scope === 'sampling'" class="count-content">
    <!-- 采样数量表单 -->
  </div>
</div>
```

### 2.3 模式专属内容

数量区域之后，再用 `<template v-if>` 展示各自独有的功能块：

```html
<!-- 模式 A 独有：自动追加、去重 -->
<template v-if="form.scope === 'full'">
  <div class="auto-append-section">...</div>
  <div class="dedup-section">...</div>
</template>

<!-- 模式 B 独有：抽样方式 -->
<template v-if="form.scope === 'sampling'">
  <div class="step-section-subtitle">抽样方式</div>
  <!-- 维度选择 + 动态表格 -->
</template>
```

**要点**：
- 用 `<template v-if>` 而非 `<div v-if>` 避免产生多余 DOM 节点
- 数量配置归入统一区域，专属功能各自独立
- 模式 B 的结构从源组件（如 `SamplingRule.vue`）的对应步骤移植

## 3. 移植子功能时的适配

从源组件移植 UI 时，需要做以下适配：

### 3.1 数据模型简化
源组件可能有多步骤、多维度数组等复杂结构。移植时简化为目标场景所需的最小数据模型：

```ts
// 源组件 SamplingRule.vue 用数组管理多维度
const samplingDimensions = ref<SamplingDimension[]>([...])

// 目标组件简化为单维度 + 三个独立数组
const samplingSceneItems = ref([{ sceneName: undefined, ratio: null }])
const samplingAgentItems = ref([{ agentId: undefined, count: null }])
const samplingDurationItems = ref([{ minDuration: null, maxDuration: null, ratio: null }])
```

### 3.2 表格列定义复用
直接从源组件复制列定义，按需微调列宽或文案：

```ts
const sceneColumns = [
  { title: '场景名称', key: 'sceneName', width: 200 },
  { title: '比例', key: 'ratio', width: 140 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]
```

### 3.3 选项数据独立定义
即使源组件已有选项数据，在目标组件中独立定义一份（避免跨组件依赖）：

```ts
const sceneOptions = [
  { label: '场景A', value: '场景A' },
  // ...
]
const agentOptions = [
  { label: '张三', value: '张三' },
  // ...
]
```

### 3.4 样式对齐源组件（关键）

移植 UI 时，**必须对齐源组件的布局和样式模式**，而非自行发明。逐项检查源组件并复制：

| 检查项 | 源组件模式 | 错误做法 |
|--------|-----------|---------|
| 表单布局 | `a-form` + `layout="horizontal"` + `label-col/wrapper-col` | 用 `a-form-item` 包裹但无 form 父级 |
| 必填标记 | `<template #label><span class="required-label">*</span> 文字</template>` | 直接在 label prop 写文字 |
| 表单提示 | `quota-unit`（单位）+ `quota-tip`（说明） | 用自定义 div + 内联样式 |
| 分隔线 | `<a-divider />` | 用 margin 或空行分隔 |
| 信息提示 | `<a-alert type="info" show-icon />` | 用纯文字 `<div class="tip">` |
| 维度选择 | `dimension-section` + `dimension-label` + `a-select` | 用 `a-radio-group` 做维度切换 |
| 维度说明 | `a-alert` 按维度条件切换 message | 用 `v-if` 切换纯文字 |
| 表格 | `class="dimension-table"`（蓝底表头）+ `size="small" bordered` | 无 class 的裸 `a-table` |
| 表格底部 | `dimension-table-footer`（左侧添加按钮 + 右侧合计） | 添加按钮和合计分开放 |
| 比例合计 | `<span class="ratio-total" :class="{ 'ratio-error': total > 100 }">` | 用自定义 class |
| 时长区间 | `range-separator`（~）+ `range-unit`（秒） | 用内联 style |

> 如果目标组件已有同名 class（如 `.step-section-subtitle`），直接复用；如果没有，从源组件复制 CSS。

### 3.5 表格 bodyCell 中的条件渲染
根据模式字段（如 `samplingMethod`）在表格列内做条件渲染：

```html
<template v-if="column.key === 'ratio'">
  <div style="display: flex; align-items: center; gap: 4px">
    <!-- 比例模式：显示输入框 -->
    <a-input-number v-if="form.samplingMethod === 'ratio'" v-model:value="record.ratio" ... />
    <span v-if="form.samplingMethod === 'ratio'">%</span>
    <!-- 平均模式：显示自动计算值 -->
    <span v-if="form.samplingMethod === 'average'">{{ items.length > 0 ? Math.floor(form.allocationValue / items.length) : 0 }}</span>
    <span v-if="form.samplingMethod === 'average'"> 条/维度</span>
  </div>
</template>
```

## 4. 新增响应式数据和 CRUD 处理函数

```ts
// 响应式数组 — 每个维度一个独立数组
const samplingSceneItems = ref<Array<{ sceneName: string | undefined; ratio: number | null }>>([
  { sceneName: undefined, ratio: null },
])

// CRUD — 增删改查每个维度
const handleAddSamplingSceneItem = () => {
  samplingSceneItems.value.push({ sceneName: undefined, ratio: null })
}
const handleDeleteSamplingSceneItem = (index: number) => {
  samplingSceneItems.value.splice(index, 1)
}

// 计算属性 — 比例合计校验
const samplingSceneRatioTotal = computed(() => {
  return samplingSceneItems.value.reduce((sum, item) => sum + (item.ratio || 0), 0)
})
```

## 5. 模式切换重置与自动查询

切换模式时，重置新模式的所有字段为初始状态。如果切回原有模式有"查询数据"等操作，应自动触发并显示 loading 态：

```ts
const queryLoading = ref(false)

const handleQueryData = () => {
  queryLoading.value = true
  queryResult.value = null
  setTimeout(() => {
    queryResult.value = Math.floor(Math.random() * 1000) + 100
    queryLoading.value = false
  }, 600)
}

const handleScopeChange = () => {
  if (form.scope === 'sampling') {
    // 重置新模式字段
    form.allocationMethod = 'total'
    form.allocationValue = null
    form.samplingMethod = 'average'
    form.samplingDimension = 'scene'
    samplingSceneItems.value = [{ sceneName: undefined, ratio: null }]
    samplingAgentItems.value = [{ agentId: undefined, ratio: null }]
    samplingDurationItems.value = [{ minDuration: null, maxDuration: null, ratio: null }]
    queryResult.value = null  // 清除旧查询结果
  } else {
    // 切回原模式时自动触发查询
    handleQueryData()
  }
}
```

> 切到模式 A 时自动查询，给用户即时反馈；切到模式 B 时清除旧的查询结果，避免混淆。

## 6. CSS 样式

```css
/* 模式选择器 */
.scope-section {
  padding: 12px 0 4px;
}

/* section-box 标题（如果 .section-box 已有但 .section-box-title 未定义） */
.section-box-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 16px;
}

/* 配置行布局 */
.allocation-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

/* 提示文案 */
.allocation-tip,
.sampling-method-tip {
  margin-top: 4px;
  color: #999;
  font-size: 12px;
}

/* 维度表格区域 */
.dimension-table-area {
  margin-top: 12px;
}

.dimension-table-title {
  font-weight: 500;
  margin-bottom: 8px;
  color: #333;
}

/* 比例合计校验 */
.ratio-total-row {
  margin-top: 8px;
  font-size: 13px;
  color: #666;
}
.ratio-error {
  color: #ff4d4f;
  font-weight: 500;
}
.ratio-error-tip {
  color: #ff4d4f;
  font-size: 12px;
  margin-left: 4px;
}
```

## 7. 验证清单

- [ ] 模式 A（原有功能）：所有原有逻辑正常工作，无回归
- [ ] 模式 B（新功能）：各维度表格增删正常、比例合计校验正确
- [ ] 模式切换：从 A→B 重置 B 的字段；从 B→A 重置 A 的状态
- [ ] 手动上传录音等条件分支：确认 `v-if` 条件与模式 `v-if` 不冲突
- [ ] 表单校验：提交时按当前模式校验对应字段
- [ ] 样式：section-box 间距、表格边框、提示文案显示正常
