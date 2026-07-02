---
name: vue-dimension-table-group
description: Vue 3 采样维度表格增加组别列和实时计算抽检条数列，支持按场景/坐席/通话时长多维度，支持多种分配方式
source: auto-skill
extracted_at: '2026-07-01T07:30:00.000Z'
---

# 采样维度表格增加组别和抽检条数

在采样维度配置表格中，为每个维度项增加"组别"序号列和"抽检条数"实时计算列，提升数据可读性。

## 适用场景

- 质检任务创建中的采样维度配置
- 任何需要按组别划分并计算数量的维度表格
- 按场景、按坐席、按通话时长等多维度配置
- 支持多种分配方式（按总数/按比例/人均数量）

## 重要：两处区域都需要修改

维度表格通常出现在两个区域，**都必须同步修改**：
1. **主表单区域**（如 createTaskStep === 2）— 用户创建任务时的配置区
2. **策略/概览区域** — 已有配置的展示/编辑区

遗漏任一区域会导致用户看到不一致的界面（如用户反馈"按坐席没有加上"就是因为主表单区域被遗漏）。

## 两种表格类型

| 类型 | 输入方式 | 列定义变量 | 合计显示 |
|------|----------|-----------|---------|
| 比例型 | 用户输入比例 (%) | sceneColumns / durationColumns / agentColumns | 合计：XX%（带超100%校验） |
| 数量型 | 用户直接输入条数 | agentListColumns / agentGroupColumns | 合计：XX 条 |

注意：主表单区域的按坐席表格（`agentColumns`）可能是**比例型**，而策略区域的按坐席表格（`agentListColumns`/`agentGroupColumns`）是**数量型**。需要分别处理。

## 实现步骤

### 1. 更新列定义

为每个维度表格的列定义添加"组别"和"抽检条数"列：

```typescript
// 按场景表格列
const sceneColumns = [
  { title: '组别', key: 'group', width: 80 },           // 新增：第一列
  { title: '场景名称', key: 'sceneName', width: 200 },
  { title: '比例', key: 'ratio', width: 140 },
  { title: '抽检条数', key: 'samplingCount', width: 120 }, // 新增：比例后
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按坐席列表表格列
const agentListColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '坐席工号', key: 'agentId', width: 200 },
  { title: '抽取条数', key: 'count', width: 140 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按坐席分组表格列
const agentGroupColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '分组名称', key: 'groupName', width: 200 },
  { title: '每人抽取', key: 'count', width: 160 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按通话时长表格列
const durationColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '时长区间', key: 'range', width: 240 },
  { title: '比例', key: 'ratio', width: 140 },
  { title: '抽检条数', key: 'samplingCount', width: 120 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]
```

### 2. 定义计算函数（支持多种分配方式）

```typescript
// 根据占比计算数量（支持按总数/按比例/人均数量）
const samplingCountByRatio = (ratio: number) => {
  if (!createTaskForm.allocationValue || !ratio) return 0
  
  // 根据分配方式计算总抽检数量
  let totalCount = 0
  if (createTaskForm.allocationMethod === 'total') {
    // 按总数：直接使用用户输入的值
    totalCount = createTaskForm.allocationValue
  } else if (createTaskForm.allocationMethod === 'ratio') {
    // 按比例：总数 = 查询结果 × 百分比 / 100
    if (!queryResult.value) return 0
    totalCount = Math.floor(queryResult.value * createTaskForm.allocationValue / 100)
  } else if (createTaskForm.allocationMethod === 'perPerson') {
    // 人均数量：总数 = 每人数量 × 质检员人数
    const inspectorCount = createTaskForm.inspector?.length || 1
    totalCount = createTaskForm.allocationValue * inspectorCount
  }
  
  // 根据比例计算当前行的抽检条数
  return Math.floor(totalCount * ratio / 100)
}

// 计算总抽检数量（用于显示）
const totalSamplingCount = computed(() => {
  if (!createTaskForm.allocationValue) return 0
  
  if (createTaskForm.allocationMethod === 'total') {
    return createTaskForm.allocationValue
  } else if (createTaskForm.allocationMethod === 'ratio') {
    if (!queryResult.value) return 0
    return Math.floor(queryResult.value * createTaskForm.allocationValue / 100)
  } else if (createTaskForm.allocationMethod === 'perPerson') {
    const inspectorCount = createTaskForm.inspector?.length || 1
    return createTaskForm.allocationValue * inspectorCount
  }
  return 0
})
```

### 3. 更新表格模板

在表格的 `bodyCell` 插槽中添加新列的渲染逻辑：

```vue
<a-table :columns="sceneColumns" :data-source="samplingSceneItems" ...>
  <template #bodyCell="{ column, record: item, index: itemIndex }">
    <!-- 组别列 -->
    <template v-if="column.key === 'group'">
      组{{ itemIndex + 1 }}
    </template>
    <!-- 原有列 -->
    <template v-else-if="column.key === 'sceneName'">
      <!-- 场景选择器 -->
    </template>
    <template v-else-if="column.key === 'ratio'">
      <a-input-number v-model:value="item.ratio" :min="0" :max="100" .../> %
    </template>
    <!-- 抽检条数列 -->
    <template v-else-if="column.key === 'samplingCount'">
      <span class="sampling-count-value">{{ samplingCountByRatio(item.ratio || 0) }}</span>
    </template>
    <template v-else-if="column.key === 'action'">
      <!-- 操作按钮 -->
    </template>
  </template>
</a-table>
```

### 4. 添加总抽检数量提示（可选）

在采样维度表格上方显示总抽检数量：

```vue
<!-- 总抽检数量提示 -->
<div v-if="totalSamplingCount > 0" class="total-sampling-count-tip">
  总抽检数量：<strong>{{ totalSamplingCount }}</strong> 条
</div>
```

### 5. 添加样式

```scss
/* 抽检条数 */
.sampling-count-value {
  font-size: 14px;
  color: #1677ff;  // 蓝色高亮
  font-weight: 500;
}

/* 总抽检数量提示 */
.total-sampling-count-tip {
  margin-bottom: 16px;
  padding: 8px 12px;
  background: #f6ffed;
  border: 1px solid #b7eb8f;
  border-radius: 4px;
  font-size: 14px;
  color: #52c41a;
}
```

## 关键点

1. **列定义共享**：多个表格共享同一列定义，修改一处即可同步所有表格
2. **组别序号**：使用 `itemIndex + 1` 动态生成，随行数自动更新
3. **实时计算**：抽检条数基于比例和分配方式实时计算，无需额外 watch
4. **空值处理**：当比例为空时显示 0，避免计算错误
5. **多种分配方式**：支持按总数、按比例、人均数量三种方式计算
6. **两处区域同步**：主表单区域和策略区域的维度表格都必须修改，不能遗漏
7. **比例型 vs 数量型**：按坐席在主表单区域可能是比例型（agentColumns），在策略区域是数量型（agentListColumns/agentGroupColumns），需分别处理合计显示

## 计算逻辑

| 分配方式 | 计算公式 | 示例 |
|----------|----------|------|
| 按总数 (total) | totalCount × ratio / 100 | 100 × 30% = 30 |
| 按比例 (ratio) | queryResult × percent / 100 × ratio / 100 | 1000 × 10% × 30% = 30 |
| 人均数量 (perPerson) | perPerson × inspectorCount × ratio / 100 | 20 × 5人 × 30% = 30 |

## 数量型表格的合计显示

对于数量型表格（agentListColumns / agentGroupColumns），需要：
1. 定义 computed 属性计算合计：
```typescript
const agentListTotalCount = computed(() => {
  return samplingAgentItems.value.reduce((sum, item) => sum + (item.count || 0), 0)
})
```
2. 在表格底部显示合计：
```vue
<span class="count-total">
  合计：{{ agentListTotalCount }} 条
</span>
```
3. 添加对应样式：
```scss
.count-total {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}
```

## 注意事项

- 组别列宽度固定 80px，适合显示"组1"~"组99"
- 抽检条数列宽度 120px，可容纳较大数字
- 计算函数需要访问 `createTaskForm.allocationValue` 和 `createTaskForm.allocationMethod`
- 多个维度表格（场景、坐席、通话时长）都需要同步更新
- 按坐席列表/分组表格只有组别列，没有抽检条数列（使用 count 字段）
- 修改列定义后，模板中的 `bodyCell` 插槽也必须同步添加新列的渲染逻辑
- `dimension-table-footer` 已有样式，新增的 `count-total` 需单独添加样式
