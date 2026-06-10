---
name: vue-crud-add-field
description: 在 Vue 3 + Ant Design Vue CRUD 页面中新增字段，并传播到关联组件的系统化步骤
source: auto-skill
extracted_at: '2026-06-03T09:02:08.322Z'
---

# 在 Vue CRUD 页面新增字段

当需要为已有的 Vue 3 + Ant Design Vue CRUD 列表页添加新字段时，按以下顺序依次修改，避免遗漏：

## 1. 接口定义
在 `interface XxxItem` 中添加新字段（含类型、可选标记）。

## 2. 示例/模拟数据
在 `dataSource` 数组的每条记录中补充新字段的初始值。

## 3. 表单数据 & 验证
- 在 `reactive({ ... ruleForm })` 中添加字段及默认值。
- 在 `formRules` 中按需添加验证规则（`required`、`trigger` 等）。

## 4. 表单弹窗 UI
在 `<a-form>` 中合适位置插入 `<a-form-item>`，常用组件：
- `a-input` / `a-textarea` — 文本
- `a-select` — 下拉选择
- `a-radio-group` + `a-radio-button` — 互斥选项（如 得分/扣分）
- `a-input-number` — 数值输入，配合 `:min` `:max` `:precision` 控制范围

## 5. 表格列配置
在 `visibleColumns` 计算属性中添加列对象（`title`、`key`、`width` 等）。

## 6. 表格 bodyCell 渲染
在 `<template #bodyCell>` 中用 `v-else-if="column.key === 'xxx'"` 添加自定义渲染逻辑。对于状态类字段，可用 `<a-tag :color="...">` 做视觉区分。

## 7. CRUD 方法同步
- **handleAddRule** — 重置新字段为默认值
- **handleEdit** — 从 `record` 读取新字段赋值给 `ruleForm`
- **handleRuleModalOk** — 编辑和新增分支中都要把 `ruleForm` 的新字段写回 `dataSource`

## 8. 传播到关联组件
当新字段需要在其他组件中也展示时：
- **共享数据源的组件**（如弹窗内嵌的列表）：直接在对应组件的示例数据中补充字段即可。
- **独立 mock 数据的组件**（如详情弹窗）：在组件内定义 `ruleScores` 等数据映射 + 辅助函数（如 `getRuleScoreText`、`getRuleScoreColor`），避免硬编码重复逻辑。
- **模板中多处相同结构**：使用 `edit` 工具的 `replace_all: true` 批量替换，需确保匹配串在文件中唯一或确实需要全部替换。

## 9. 汇总计算属性
当新字段需要在多处展示汇总值时：
- 为每个数据来源创建独立的 `computed`（如 `aiScoreSummary`、`allScoreSummary`）。
- 汇总逻辑需对规则编号去重（`Set`），避免同一规则被多次计入。
- 返回值统一为 `{ add, deduct, total }` 结构，模板中按需展示。

## 10. 数值区间搜索
当新字段是数值类型且需要按区间搜索时：

### FilterForm 扩展
添加 `xxxMin: number | undefined` 和 `xxxMax: number | undefined` 两个字段。

### 区间搜索 UI
在筛选区域用 `<div class="score-range-group">` 包裹两个 `<a-input-number>`，中间用 `<span class="range-separator">~</span>` 连接：
```html
<div class="score-range-group">
  <span class="range-label">AI评分：</span>
  <a-input-number v-model:value="filterForm.aiScoreMin" :min="0" :max="100" placeholder="最低分" class="range-input" allow-clear />
  <span class="range-separator">~</span>
  <a-input-number v-model:value="filterForm.aiScoreMax" :min="0" :max="100" placeholder="最高分" class="range-input" allow-clear />
</div>
```

### CSS
```css
.score-range-group { display: flex; align-items: center; gap: 8px; width: 100%; }
.range-label { font-size: 14px; color: #595959; white-space: nowrap; }
.range-input { flex: 1; }
.range-separator { color: #8f959e; font-size: 14px; }
```

> **区间输入框宽度**：使用 `flex: 1` 让两个输入框各占一半，总宽度与其他 `width: 100%` 的输入框一致。不要用固定 `width: 110px`，否则总宽度会比其他字段窄。

### 条件列显示
当不同任务类型需要展示不同列时，在 `columns` computed 中根据 `activeTab` 或 `getTaskType()` 条件性地 push 不同列。例如人工任务只显示人工评分，AI 任务显示 AI 评分 + 人工评分。

### 数值颜色编码
在 bodyCell 中根据数值范围设置颜色：
- ≥80: 绿色 `#52c41a`（良好）
- 60~79: 橙色 `#faad14`（一般）
- <60: 红色 `#ff4d4f`（较差）

### handleReset
在重置函数中清空 `xxxMin` 和 `xxxMax` 为 `undefined`。

## 注意事项
- 编辑回填时注意可选字段的 fallback（如 `record.scoreType || 'add'`）。
- `a-form-item` 嵌套在 `a-space` 内时，内层需加 `no-style` 避免重复 label。
- 表格 scroll.x 值可能需要随列增加而调大。
- 关联组件中的静态数据（如 `ruleKeywords`、`ruleScores`）应与主页面保持一致，建议用注释标注来源。
- 区间搜索的 `a-input-number` 需设置 `allow-clear` 以便用户清空。
