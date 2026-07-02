---
name: vue-conditional-detail-display
description: 只读详情弹窗中根据枚举字段值动态展示不同字段集（如采样数量按分配方式展示不同文案和单位）
source: auto-skill
extracted_at: '2026-07-01T07:40:00.000Z'
---

# 只读详情弹窗条件展示

在只读详情/概览弹窗中，根据某个枚举字段的值，动态展示不同的字段内容、文案格式或详情列表。

## 适用场景

- 数据范围弹窗中"抽检配置"根据分配方式展示不同单位的采样数量
- 任何只读摘要视图中需要根据配置类型切换展示格式
- 详情弹窗中某个区域仅在特定条件下可见（如抽样维度仅在按比例采样时展示）

## 实现步骤

### 1. 接口定义：使用联合类型约束枚举字段

```typescript
interface DetailItem {
  // 枚举字段用联合类型约束，而非 string
  allocationMethod?: 'total' | 'ratio' | 'perPerson'
  allocationValue?: number
  samplingMethod?: 'average' | 'ratio'
  samplingDimensionType?: 'scene' | 'agent' | 'callDuration'
  // 详情列表用数组
  samplingDimensionDetails?: { name: string; value: number }[]
}
```

### 2. 模板：条件渲染不同文案格式

用 `v-if` / `v-else-if` 根据枚举值展示不同格式的同一行数据：

```vue
<div class="detail-item">
  <span class="detail-label">采样数量：</span>
  <span class="detail-value">
    <template v-if="item.allocationMethod === 'total'">
      按总户数 {{ item.allocationValue || '-' }}条
    </template>
    <template v-else-if="item.allocationMethod === 'ratio'">
      按比例 {{ item.allocationValue || '-' }}%
    </template>
    <template v-else-if="item.allocationMethod === 'perPerson'">
      按人均数量每人 {{ item.allocationValue || '-' }}条
    </template>
    <template v-else>-</template>
  </span>
</div>
```

### 3. 条件可见的子区域

当某区域仅在特定条件下展示时，直接在容器上加 `v-if`：

```vue
<div class="detail-item" v-if="item.samplingMethod === 'ratio'">
  <span class="detail-label">抽样维度：</span>
  <span class="detail-value">
    {{ getDimensionLabel(item.samplingDimensionType) }}
    <template v-if="item.samplingDimensionDetails?.length">
      <span class="dimension-detail">{{ getDimensionDetailText(item) }}</span>
    </template>
  </span>
</div>
```

### 4. 辅助函数：格式化详情列表

根据维度类型拼接详情文本，不同维度用不同单位：

```typescript
const getDimensionDetailText = (item: DetailItem) => {
  if (!item.samplingDimensionDetails?.length) return ''
  // 按通话时长用"秒"，其余用"%"
  const unit = item.samplingDimensionType === 'callDuration' ? '秒' : '%'
  return item.samplingDimensionDetails.map(d => `${d.name} ${d.value}${unit}`).join('、')
}
```

### 5. 样式

```scss
.dimension-detail {
  display: block;        // 详情列表换行展示
  margin-top: 4px;
  color: #8c8c8c;
  font-size: 13px;
}
```

## 关键点

1. **联合类型**：枚举字段必须用 `'a' | 'b' | 'c'` 而非 `string`，模板中的 `===` 比较才安全
2. **fallback else**：始终提供 `<template v-else>-</template>` 兜底，防止未知枚举值显示空白
3. **条件可见用 v-if**：整个区域不需要时用 `v-if` 而非 `v-show`，避免无意义的 DOM 和辅助函数调用
4. **详情单位随类型变化**：不同枚举值对应不同单位（条/%/秒），在辅助函数中根据类型决定
5. **删除旧字段时清理样式和辅助函数**：重构接口后用 `grep` 搜索旧字段名，确保模板、辅助函数、样式全部同步更新
