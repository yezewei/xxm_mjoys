---
name: vue-multi-step-wizard
description: 在 Ant Design Vue Modal 中实现多步骤向导流程，支持动态步骤数、条件步骤内容、分步校验和策略概览
source: auto-skill
extracted_at: '2026-06-09T05:49:44.885Z'
---

# 多步骤向导弹窗

当 Modal 中的配置项过多、需要分步引导用户完成时，使用 `a-steps` + 条件渲染实现向导流程。适用于质检任务创建、策略配置、批量操作等场景。

## 适用场景

- 配置流程有明确的先后依赖关系（先选范围 → 再配维度 → 最后命名）
- 不同模式下步骤数量不同（如全量质检 2 步 vs 抽检 6 步）
- 最后一步需要展示配置概览供用户确认

## 1. 状态变量

```ts
const currentStep = ref(0)
const qualityScope = ref<'full' | 'sampling'>('full')

// 动态步骤列表
const createSteps = computed(() => {
  if (qualityScope.value === 'full') {
    return [{ title: '基本信息' }, { title: '质检范围' }]
  }
  return [
    { title: '基本信息' },
    { title: '数据范围' },
    { title: '抽样维度' },
    { title: '配额上限' },
    { title: '调度计划' },
    { title: '命名保存' },
  ]
})

const isLastStep = computed(() => currentStep.value === createSteps.value.length - 1)
```

## 2. 步骤条组件

```html
<a-steps :current="currentStep" size="small" class="create-steps">
  <a-step v-for="step in createSteps" :key="step.title" :title="step.title" />
</a-steps>
```

## 3. 条件步骤内容

每个步骤用 `v-if="currentStep === N"` 包裹，不同模式共享步骤 0，之后分支：

```html
<!-- 步骤0：基本信息（所有模式共享） -->
<div v-if="currentStep === 0" class="step-content">
  <!-- 基础表单：任务名称、类型、模型等 -->
</div>

<!-- 步骤1：质检范围选择（两种模式都走这一步，但后续步骤不同） -->
<div v-else-if="currentStep === 1" class="step-content">
  <a-radio-group v-model:value="qualityScope">
    <a-radio-button value="full">全量质检</a-radio-button>
    <a-radio-button value="sampling">抽检</a-radio-button>
  </a-radio-group>

  <!-- 全量模式：在此步骤展示条件配置（作为最后一步） -->
  <template v-if="qualityScope === 'full'">
    <!-- 条件表达式配置 -->
  </template>

  <!-- 抽检模式：在此步骤仅选范围，后续步骤配置细节 -->
  <template v-else>
    <!-- 数据范围筛选器 -->
  </template>
</div>

<!-- 步骤2+：仅抽检模式 -->
<div v-else-if="currentStep === 2 && qualityScope === 'sampling'" class="step-content">
  <!-- 抽样维度配置 -->
</div>
<!-- ...更多步骤... -->
```

## 4. 导航方法

```ts
const handleNext = () => {
  // 当前步骤校验
  if (!validateCurrentStep()) return

  // 切换模式时重置后续步骤数据
  if (currentStep.value === 1 && qualityScope.value === 'sampling') {
    resetSamplingData()
  }

  currentStep.value++
}

const handlePrev = () => {
  if (currentStep.value > 0) currentStep.value--
}

const handleCancel = () => {
  currentStep.value = 0
  qualityScope.value = 'full'
  // 重置所有表单数据
  resetAllFormData()
}
```

**步骤 1 特殊处理**：当用户在步骤 1 切换质检范围时，如果从抽检切回全量，需要清空抽检相关数据（维度、配额、调度等），避免脏数据。

## 5. Modal Footer 动态按钮

```html
<template #footer>
  <a-button @click="handleCancel">取消</a-button>
  <a-button v-if="currentStep > 0" @click="handlePrev">上一步</a-button>
  <a-button v-if="!isLastStep" type="primary" @click="handleNext">下一步</a-button>
  <a-button v-if="isLastStep" type="primary" @click="handleConfirm">确认创建</a-button>
</template>
```

## 6. 分步校验策略

在 `handleNext` 中对当前步骤做校验，不通过则 `return` 阻止前进：

| 步骤 | 校验内容 |
|------|----------|
| 基本信息 | 必填字段（任务名称、质检模型等） |
| 数据范围 | 筛选器字段完整性（有操作符必须有值） |
| 抽样维度 | 至少一个维度、每个维度配置完整（场景有名称和比例、坐席有列表、时长有区间） |
| 配额上限 | 数值 > 0（如果填写） |
| 调度计划 | 非永久模式下必须有生效时间；周/月模式必须选执行日 |

最终确认（`handleConfirm`）时做全量校验，确保所有步骤数据完整。

## 7. 维度卡片模式

当一个步骤需要配置多个同类维度（如抽样维度），使用卡片列表模式：

```ts
interface SamplingDimension {
  id: number
  type: 'scene' | 'agent' | 'callDuration' | 'custom'
  // ...各类型专属字段
}

const samplingDimensions = ref<SamplingDimension[]>([])
let dimensionIdCounter = 0

const handleAddDimension = () => {
  samplingDimensions.value.push({
    id: ++dimensionIdCounter,
    type: 'scene',
    // ...默认值
  })
}

const handleDeleteDimension = (dIndex: number) => {
  samplingDimensions.value.splice(dIndex, 1)
}
```

模板中用 `v-for="(dimension, dIndex) in samplingDimensions"` 渲染卡片，每个卡片内根据 `dimension.type` 条件渲染不同的配置表单。

**卡片结构**：
```html
<div v-for="(dimension, dIndex) in dimensions" :key="dimension.id" class="dimension-card">
  <div class="dimension-card-header">
    <span class="dimension-index">{{ dIndex + 1 }}</span>
    <a-select v-model:value="dimension.type" @change="handleTypeChange(dIndex)">
      <a-select-option value="scene">按场景</a-select-option>
      <a-select-option value="agent">按坐席</a-select-option>
    </a-select>
    <a-switch v-model:checked="dimension.mutualExclusive" checked-children="互斥" un-checked-children="共享" />
    <a-button type="text" danger @click="handleDeleteDimension(dIndex)"><delete-outlined /></a-button>
  </div>
  <div class="dimension-card-body">
    <!-- 根据 dimension.type 条件渲染 -->
  </div>
</div>
```

## 8. 最后一步：策略概览

在命名保存步骤中，用只读卡片展示前面步骤的配置摘要，让用户确认：

```html
<div class="strategy-overview">
  <div class="overview-grid">
    <div class="overview-item">
      <span class="overview-label">数据范围</span>
      <span class="overview-value">{{ dataRangeDescription }}</span>
    </div>
    <div class="overview-item">
      <span class="overview-label">抽样维度</span>
      <span class="overview-value">{{ samplingDimensions.length }}个维度</span>
    </div>
    <!-- ...更多摘要项... -->
  </div>
</div>
```

使用 computed 属性生成摘要文本，避免在模板中写复杂逻辑。

## 9. Modal 宽度

多步骤向导通常需要更宽的 Modal：
- 2~3 步简单向导：`width="700px"`
- 4~6 步复杂向导（含表格/卡片）：`width="900px"`

## 10. CSS 关键样式

```scss
.create-steps {
  margin-bottom: 24px;
}

.step-content {
  min-height: 400px; // 保持步骤切换时高度稳定，避免页面跳动
}

.step-section-title {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 4px;
}

.step-section-desc {
  font-size: 12px;
  color: #8c8c8c;
  margin-bottom: 12px;
}

// 维度卡片
.dimension-card {
  border: 1px solid #f0f0f0;
  border-radius: 6px;
  margin-bottom: 12px;
  overflow: hidden;
}

.dimension-card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 16px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
}

.dimension-index {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #1890ff;
  color: #fff;
  border-radius: 50%;
  font-size: 12px;
  font-weight: 600;
}

.dimension-card-body {
  padding: 16px;
}

// 策略概览
.overview-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.overview-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.overview-label {
  font-size: 12px;
  color: #8c8c8c;
}

.overview-value {
  font-size: 14px;
  color: #262626;
}
```

## 11. 重构步骤结构

当需要合并、拆分或重排向导步骤时（如从 5 步合并为 3 步），按以下清单逐项修改：

### 修改清单

1. **模板**：用新步骤内容替换旧步骤 `v-if/v-else-if` 块，确保 `currentStep === N` 编号连续
2. **步骤条**：更新 `a-step` 列表，使 `:current` 与步骤数匹配
3. **Footer 按钮**：「完成」按钮的 `v-if` 条件改为新的最后一步编号
4. **handleNext 校验**：删除已合并步骤的校验分支，将校验逻辑移到对应的新步骤中
5. **CSS**：如果新增了子标题等元素，补充对应样式（如 `.step-section-subtitle`）

### 合并步骤的典型模式

将原步骤 A 和 B 合并为新步骤时：
- 把 B 的模板内容追加到 A 的 `v-if` 块末尾
- 用 `a-divider` 分隔不同区域，用 `.step-section-subtitle` 标注子模块标题
- 将 B 的校验逻辑合并到 A 的校验函数中

## 12. 向已有步骤添加表单字段

在现有向导步骤中新增字段时，需要同步修改以下 5 处：

```ts
// 1. FormData 接口 — 新增字段
interface FormData {
  // ...existing fields
  inspectType: string    // 新增
  qualityModel: string   // 新增
}

// 2. createDefaultFormData — 设置默认值
const createDefaultFormData = (): FormData => ({
  // ...existing defaults
  inspectType: 'ai',
  qualityModel: undefined as unknown as string,  // Select 组件需用 undefined 才显示 placeholder
})

// 3. 模板 — 在对应步骤的 form-item 中添加控件
// 4. handleNext — 在步骤校验中添加必填检查
// 5. 概览卡片 — 如果最后一步有配置摘要，同步新增摘要项
```

## 13. Ant Design Vue Select 的 placeholder 不显示

**问题**：`a-select` 组件的 `v-model:value` 初始化为空字符串 `''` 时，placeholder 不会显示。

**原因**：Ant Design Vue 的 Select 在 `value` 为 falsy 但非 `undefined` 时不展示 placeholder。

**解决**：将默认值设为 `undefined`，而非空字符串：

```ts
// ❌ 错误 — placeholder 不显示
qualityModel: '',

// ✅ 正确 — placeholder 正常显示
qualityModel: undefined as unknown as string,
```

> `as unknown as string` 是为了满足 TypeScript 类型检查（字段声明为 `string` 类型但初始值为 `undefined`）。

**同理**：`a-input` 没有这个问题，空字符串 `''` 即可正常显示 placeholder。

## 注意事项

- **模式切换清数据**：从多步骤模式切回少步骤模式时，必须清空多出步骤的数据，否则确认创建时会携带脏数据
- **步骤条 `:current` 是 0-indexed**：`a-steps` 的 `current` 从 0 开始
- **保持步骤高度稳定**：给 `.step-content` 设置 `min-height`，避免步骤切换时页面跳动
- **`a-range-picker` 需要 dayjs**：Ant Design Vue 4.x 的日期组件依赖 dayjs，项目中已内置
- **互斥维度开关**：如果多个维度之间有互斥关系（命中 A 则不参与 B），用 `a-switch` 在卡片头部配置
- **增量 ID**：维度/子项等动态列表使用自增 ID 而非数组 index 作为 key，避免 splice 后 key 冲突

## 常见 TypeScript 错误

### reactive 对象误用 .value

`reactive()` 创建的对象在 script 中直接访问属性，**不加 `.value`**。只有 `ref()` 才需要 `.value`。

```ts
// ❌ 错误 — globalQuotas 是 reactive，没有 .value
const globalQuotas = reactive<GlobalQuotas>({ ... })
if (globalQuotas.value.inspectorDailyMax !== null) { ... }

// ✅ 正确
if (globalQuotas.inspectorDailyMax !== null) { ... }
```

**排查方法**：搜索 `.value` 调用，对照声明处确认是 `ref` 还是 `reactive`。模板中两者都不需要 `.value`（ref 会自动解包）。

### 多态字段类型的赋值

当接口字段类型为联合类型（如 `string | string[]`）时，赋值目标如果是 `string` 类型，需要用 `Array.isArray()` 做类型收窄：

```ts
interface QualityTaskItem {
  auditor: string | string[]  // 可能是单个或多个审核员
}

interface EditTaskForm {
  inspector: string  // 编辑表单是单选
}

// ❌ 错误 — Type 'string | string[]' is not assignable to type 'string'
editTaskForm.inspector = row.auditor || row.creator

// ✅ 正确 — 用 Array.isArray 收窄
editTaskForm.inspector = Array.isArray(row.auditor) ? row.auditor[0] : (row.auditor || row.creator)
```

### 清理旧流程的死代码

用新流程替换旧流程后，旧的弹窗、方法、响应式数据会变成死代码。虽然不影响运行，但会增加维护负担和编译警告。建议：
1. 删除旧的 Modal 模板
2. 删除旧的方法定义（如 `checkSamplingDataAvailable`）
3. 删除旧的响应式数据（如 `samplingRules`、`samplingRuleModalVisible`）
4. 删除旧的列定义和表单校验逻辑
