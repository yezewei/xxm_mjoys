---
name: vue-realtime-calc
description: Vue 3 表单中根据用户输入实时计算并展示结果（如抽检数量 = 总数 × 百分比），带绿色高亮提示
source: auto-skill
extracted_at: '2026-06-29T10:05:16.434Z'
---

# Vue 实时计算显示

在表单配置场景中，根据用户输入的参数实时计算结果并展示，提升用户体验。

## 适用场景

- 抽检数量 = 总数 × 百分比
- 总价 = 单价 × 数量
- 预计时长 = 任务数 × 平均时长
- 任何需要即时反馈计算结果的表单

## 实现步骤

### 1. 查询基础数据

先获取计算所需的基础数据（如数据总量）：

```vue
<div class="query-row">
  <a-button type="link" @click="handleQueryData" :loading="queryLoading">
    <search-outlined />
    查询数据
  </a-button>
  <span v-if="queryResult !== null" class="query-result">
    符合条件 <strong>{{ queryResult }}</strong> 条数据
  </span>
</div>
```

### 2. 添加实时计算显示

在表单项下方添加计算结果展示：

```vue
<a-form-item label="抽取百分比">
  <a-input-number v-model:value="form.allocationValue" :min="1" :max="100" />
  <span class="quota-unit">%</span>
  <div class="quota-tip">按总量的百分比抽取</div>
  <!-- 实时计算结果 -->
  <div v-if="queryResult !== null && form.allocationValue" class="quota-calc">
    预计抽检 <strong>{{ Math.floor(queryResult * form.allocationValue / 100) }}</strong> 条
  </div>
</a-form-item>
```

### 3. 多条件计算

当计算依赖多个表单字段时：

```vue
<div v-if="form.value && form.inspector?.length" class="quota-calc">
  预计抽检 <strong>{{ form.value * form.inspector.length }}</strong> 条
</div>
```

## CSS 样式

```css
/* 查询行 */
.query-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

/* 实时计算结果 - 绿色高亮 */
.quota-calc {
  font-size: 13px;
  color: #52c41a;
  margin-top: 4px;
  padding: 4px 8px;
  background: #f6ffed;
  border-radius: 4px;
  display: inline-block;
}

/* 提示文案 */
.quota-tip {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
}
```

## 关键点

1. **条件渲染**：使用 `v-if` 确保有数据且有输入时才显示
2. **即时响应**：直接在模板中计算，无需额外 watch/computed
3. **视觉区分**：计算结果用绿色背景区分于普通提示
4. **数据依赖**：先查询基础数据，再基于此计算

## 完整示例

```vue
<div class="sampling-content">
  <!-- 查询基础数据 -->
  <div class="query-row">
    <a-button type="link" @click="handleQuery">查询数据</a-button>
    <span v-if="total !== null">共 <strong>{{ total }}</strong> 条</span>
  </div>
  
  <!-- 配置 + 实时计算 -->
  <a-form-item label="抽取比例">
    <a-input-number v-model:value="form.ratio" :min="1" :max="100" />
    <span>%</span>
    <div v-if="total !== null && form.ratio" class="quota-calc">
      预计抽取 <strong>{{ Math.floor(total * form.ratio / 100) }}</strong> 条
    </div>
  </a-form-item>
</div>
```
