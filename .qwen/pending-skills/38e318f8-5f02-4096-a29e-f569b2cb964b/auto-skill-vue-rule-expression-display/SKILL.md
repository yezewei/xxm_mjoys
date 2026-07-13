---
name: vue-rule-expression-display
description: 在详情弹窗中只读展示规则客群/筛选条件的表达式树（条件项+操作符+值+逻辑关系），含辅助函数获取中文标签
source: auto-skill
extracted_at: '2026-07-09T09:00:23.677Z'
---

# 详情弹窗中只读展示规则表达式

在查看详情弹窗中，当实体类型为"规则型"（如规则客群、规则筛选器）时，只读展示其条件表达式树，包括条件字段中文名、操作符中文名、值、以及表达式间/条件间的逻辑关系。

## 适用场景

- 规则客群详情中展示筛选条件表达式
- 自动化规则详情中展示触发条件
- 数据筛选器详情中展示过滤规则
- 任何由表达式树（嵌套条件+逻辑运算符）定义的业务规则的只读展示

## 数据结构

```typescript
interface ConditionItem {
  field: string        // 条件字段标识，如 'gender', 'ageRange'
  operator: string     // 操作符标识，如 'eq', 'between'
  value: string        // 条件值，如 '男', '18-30'
}

interface Expression {
  id: string
  conditions: ConditionItem[]
  nextLogic?: 'AND' | 'OR'  // 与下一个表达式之间的逻辑关系
}

// 实体数据
interface EntityData {
  groupType: 'fixed' | 'rule'
  conditions?: Expression[]
  // ...其他字段
}
```

## 实现步骤

### 1. 模板：条件渲染表达式区域

仅在规则类型且有表达式数据时显示，用 `<template v-if>` 包裹：

```vue
<!-- 规则型实体显示筛选条件 -->
<template v-if="viewData.groupType === 'rule' && viewData.conditions?.length > 0">
  <a-divider>筛选条件</a-divider>
  <div class="view-conditions">
    <div v-for="(expression, exprIndex) in viewData.conditions" :key="expression.id" class="view-expression-item">
      <!-- 表达式头：编号 + 与下一表达式的逻辑关系 -->
      <div class="view-expression-header">
        <span class="view-expression-title">表达式{{ exprIndex + 1 }}</span>
        <span v-if="exprIndex < viewData.conditions.length - 1" class="view-expression-logic">
          {{ expression.nextLogic || 'AND' }}
        </span>
      </div>
      <!-- 条件列表 -->
      <div class="view-expression-conditions">
        <div v-for="(condition, condIndex) in expression.conditions" :key="condIndex" class="view-condition-item">
          <a-tag color="blue">{{ getConditionLabel(condition.field) }}</a-tag>
          <span class="view-condition-operator">{{ getOperatorLabel(condition.field, condition.operator) }}</span>
          <a-tag color="green">{{ condition.value }}</a-tag>
          <span v-if="condIndex < expression.conditions.length - 1" class="view-condition-logic">AND</span>
        </div>
      </div>
    </div>
  </div>
</template>
```

### 2. 辅助函数：将标识转为中文标签

依赖已有的配置常量数组/映射（如 `CONDITION_ITEMS`、`OPERATORS`）：

```typescript
// 条件项配置（通常已有）
const CONDITION_ITEMS = [
  { value: 'gender', label: '性别', valueType: 'enum' },
  { value: 'ageRange', label: '年龄范围', valueType: 'range' },
  { value: 'region', label: '地区', valueType: 'enum' },
  // ...
]

// 操作符配置（通常已有）
const OPERATORS: Record<string, Array<{ value: string; label: string }>> = {
  gender: [
    { value: 'eq', label: '等于' },
    { value: 'neq', label: '不等于' },
  ],
  ageRange: [{ value: 'between', label: '介于' }],
  // ...
}

// 获取条件字段中文标签
const getConditionLabel = (field: string): string => {
  const item = CONDITION_ITEMS.find(i => i.value === field)
  return item ? item.label : field
}

// 获取操作符中文标签（操作符按字段分组）
const getOperatorLabel = (field: string, operator: string): string => {
  const operators = OPERATORS[field]
  if (!operators) return operator
  const op = operators.find(o => o.value === operator)
  return op ? op.label : operator
}
```

### 3. 样式

```scss
/* 外层容器：灰色背景 */
.view-conditions {
  background: #fafafa;
  border-radius: 6px;
  padding: 16px;
  margin-bottom: 16px;
}

/* 单个表达式卡片 */
.view-expression-item {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 12px;
  margin-bottom: 8px;

  &:last-child { margin-bottom: 0; }
}

/* 表达式标题行 */
.view-expression-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.view-expression-title {
  font-weight: 500;
  color: #1f2329;
}

/* 表达式间逻辑关系标签（AND/OR） */
.view-expression-logic {
  margin-left: 8px;
  color: #ff7a00;
  font-weight: 500;
}

/* 条件列表：横向排列 */
.view-expression-conditions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

/* 单个条件项 */
.view-condition-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.view-condition-operator {
  color: #646a73;
}

/* 条件间逻辑关系 */
.view-condition-logic {
  color: #ff7a00;
  font-weight: 500;
}
```

## 关键点

1. **条件渲染**：用 `v-if` 判断实体类型为规则型且有表达式数据才展示，固定型实体不显示此区域
2. **标签转换**：复用已有的 `CONDITION_ITEMS` 和 `OPERATORS` 配置常量做标识→中文转换，fallback 返回原始标识
3. **逻辑关系高亮**：AND/OR 用橙色（`#ff7a00`）高亮，与普通文本区分
4. **字段标签用蓝色 tag，值用绿色 tag**：视觉上区分"字段名"和"字段值"
5. **辅助函数放在 data/script 顶部**：模板中直接调用，不依赖 props 或 emits
6. **样式放在已有表达式编辑样式之后**：命名用 `view-` 前缀区分编辑态和只读态
