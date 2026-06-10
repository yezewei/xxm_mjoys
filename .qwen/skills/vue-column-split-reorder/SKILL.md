---
name: vue-column-split-reorder
description: 在 Vue 3 + Ant Design Vue CRUD 页面中将单列拆分为多列、按语义分类重排序，并跨多文件同步
source: auto-skill
extracted_at: '2026-06-03T10:07:28.925Z'
---

# 列拆分与语义重排序

当需要将一个已有列（如"触发质检规则"）拆分为多个子列（如"关键词匹配质检项"、"AI识别质检项"、"人工标注质检项"），并按语义类别重新排列列顺序时，按以下步骤操作。

## 适用场景

- 一个字段承载了多种类型的信息，需要拆分为独立列以便分类展示和搜索
- 多个页面共享相同的表格结构（如"工作台-任务明细"和"任务详情-任务明细"），需要同步修改
- 列需要按语义分组排序（如：基本信息 → 关键词 → AI → 人工）

## 1. 确认影响范围

在开始修改前，先用 `grep_search` 搜索旧字段名（如 `triggerRule`、`triggerItem`），确认所有需要修改的文件和位置。典型需要修改的文件：

- **列表页 A**（如 QualityWorkbench.vue）
- **列表页 B**（如 QualityTaskDetail.vue）
- **详情弹窗**（如 QualityDetailModal.vue）— 如果用户明确说不动，则跳过

> **关键**：与用户确认哪些文件需要改、哪些不动，避免误改。

## 2. 接口定义拆分

将旧字段替换为多个新字段：

```ts
// 旧
triggerRule: string

// 新
keywordRules: string
aiRules: string
manualRules: string
```

同时更新搜索表单接口：

```ts
// 旧
triggerItem: string | undefined

// 新
keywordRule: string | undefined
aiRule: string | undefined
manualRule: string | undefined
```

## 3. Mock 数据拆分

将旧字段值拆分到对应的新字段中：

```ts
// 旧
{ triggerRule: 'A1, B1, B2' }

// 新
{ keywordRules: 'A1', aiRules: 'B1, B2', manualRules: '' }
```

注意：每条记录的拆分逻辑可能不同，需根据业务含义分配。

## 4. 列定义拆分 + 语义重排序

### 拆分列

将旧列替换为多个新列：

```ts
// 旧
{ title: '触发质检规则', dataIndex: 'triggerRule', key: 'triggerRule', width: 200 }

// 新
{ title: '关键词匹配质检项', dataIndex: 'keywordRules', key: 'keywordRules', width: 160 },
{ title: 'AI识别质检项', dataIndex: 'aiRules', key: 'aiRules', width: 160 },
{ title: '人工标注质检项', dataIndex: 'manualRules', key: 'manualRules', width: 160 },
```

### 语义重排序

按类别分组排列列，而非按添加顺序：

```
任务基本信息（ID、时间、坐席、客户…）
→ 关键词（关键词匹配质检项）
→ AI（AI识别质检项、AI质检总结、AI评分）
→ 人工（人工标注质检项、人工质检总结、人工评分、审核员/质检员）
```

如果存在任务类型差异（如人工任务无 AI 列），需在 `columns` computed 中根据 `activeTab` 或 `getTaskType()` 条件性地构建列数组，但保持同类列的相对顺序一致。

## 5. bodyCell 模板拆分

为每个新列添加独立的渲染模板：

```html
<template v-else-if="column.key === 'keywordRules'">
  <span v-if="record.keywordRules">{{ record.keywordRules }}</span>
  <span v-else style="color: #bfbfbf">-</span>
</template>
<template v-else-if="column.key === 'aiRules'">
  <span v-if="record.aiRules">{{ record.aiRules }}</span>
  <span v-else style="color: #bfbfbf">-</span>
</template>
<template v-else-if="column.key === 'manualRules'">
  <span v-if="record.manualRules">{{ record.manualRules }}</span>
  <span v-else style="color: #bfbfbf">-</span>
</template>
```

## 6. 搜索抽屉字段拆分

将旧的单个搜索控件替换为多个独立控件：

```html
<!-- 旧：下拉选择 -->
<a-form-item>
  <a-select v-model:value="filterForm.triggerItem" placeholder="触发质检项" allow-clear>
    <a-select-option value="item1">服务态度</a-select-option>
  </a-select>
</a-form-item>

<!-- 新：多个输入框（更灵活，支持模糊搜索） -->
<a-form-item>
  <a-input v-model:value="filterForm.keywordRule" placeholder="关键词匹配质检项" allow-clear />
</a-form-item>
<a-form-item>
  <a-input v-model:value="filterForm.aiRule" placeholder="AI识别质检项" allow-clear />
</a-form-item>
<a-form-item>
  <a-input v-model:value="filterForm.manualRule" placeholder="人工标注质检项" allow-clear />
</a-form-item>
```

> 如果旧字段是 `a-select`（固定选项），拆分后通常改为 `a-input`（支持自由输入搜索），因为拆分后的子字段选项可能不同或更灵活。

## 7. handleReset 更新

在重置函数中，将旧字段替换为所有新字段：

```ts
const handleReset = () => {
  Object.assign(filterForm, {
    // ...其他字段...
    keywordRule: undefined,  // 替换旧的 triggerItem
    aiRule: undefined,
    manualRule: undefined,
    // ...其他字段...
  })
}
```

## 8. 跨文件同步一致性检查

修改完所有文件后，用 `grep_search` 验证：

```bash
# 确认旧字段名已全部清除
grep: pattern="旧字段名"  # 如 triggerRule、triggerItem

# 确认新字段在所有文件中一致
grep: pattern="新字段名"  # 如 keywordRules、aiRules、manualRules
```

检查点：
- 接口定义一致
- Mock 数据字段名一致
- 列定义 key/dataIndex 一致
- bodyCell 模板 key 匹配
- 搜索表单字段名一致
- handleReset 包含所有新字段

## 注意事项

- **不要改错文件**：如果用户指定了范围（如"只改列表页，不改详情弹窗"），严格遵守
- **列宽调整**：拆分后每列通常比原列窄（如 200 → 160），但总宽度可能增加，检查 `scroll.x` 是否需要调大
- **空值展示**：拆分后某些记录的新字段可能为空，统一用 `-` 或留空，保持视觉一致
- **同步拆分类似字段**：如"质检总结"也同时拆分为"AI质检总结"和"人工质检总结"，一并处理避免遗漏
