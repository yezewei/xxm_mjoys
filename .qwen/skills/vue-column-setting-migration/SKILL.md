---
name: vue-column-setting-migration
description: 将页面从旧版 ColumnSettingModal API（columns/visible/columnOrder/@apply）迁移到新版 API（pageKey/defaultColumns/@save/ref.open）
source: auto-skill
extracted_at: '2026-06-09T05:57:14.103Z'
---

# ColumnSettingModal API 迁移

当页面使用的 `ColumnSettingModal` 组件报 TS 错误（缺少 `pageKey`、`defaultColumns` 属性），说明页面还在用旧版 API，需要迁移到新版。

## 新旧 API 对比

| 项目 | 旧版 API | 新版 API |
|------|----------|----------|
| 打开方式 | `v-model:visible` | `ref.open()` |
| 列配置 | `:columns` + `:column-order` + `:visible-column-keys` | `:default-columns`（ColumnConfigItem[]） |
| 事件 | `@apply`（回调参数: visibleKeys, order） | `@save`（回调参数: ColumnConfigItem[]） |
| 持久化 | 页面自行 localStorage 读写 | 组件内部自动 localStorage 读写 |
| 页面标识 | 无 | `page-key` 字符串 |

## 迁移步骤

### 1. 更新 import

```ts
// 新增
import type { ColumnConfigItem } from '../utils/columnConfig';
```

### 2. 转换 allColumns 类型

从 `TableColumnType[]` 转为 `ColumnConfigItem[]`，添加 `key`、`visible`、`order` 字段：

```ts
// 旧
const allColumns: TableColumnType[] = [
  { title: '通话ID', dataIndex: 'callUuid', key: 'callUuid', width: 200 },
  { title: '操作', dataIndex: 'action', key: 'action', width: 120, align: 'center', fixed: 'right' },
];

// 新
const allColumns: ColumnConfigItem[] = [
  { key: 'callUuid', title: '通话ID', dataIndex: 'callUuid', width: 200, visible: true, order: 0 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 120, visible: true, order: 16 },
];
```

**注意**：`ColumnConfigItem` 没有 `align` 和 `fixed` 字段，这些需要在 `visibleColumns` computed 中补回。

### 3. 替换状态管理

删除旧的状态变量：
```ts
// 删除
const columnSettingVisible = ref(false);
const STORAGE_KEY = 'column_config_xxx';
const savedConfig = localStorage.getItem(STORAGE_KEY);
const visibleColumnKeys = ref<string[]>(...);
const columnOrder = ref<string[]>(...);
```

替换为：
```ts
const columnSettingModalRef = ref<InstanceType<typeof ColumnSettingModal> | null>(null);
const currentColumns = ref<ColumnConfigItem[]>([]);
```

### 4. 更新 visibleColumns computed

```ts
const visibleColumns = computed(() => {
  const columnsToUse = currentColumns.value.length > 0 ? currentColumns.value : allColumns;
  return columnsToUse
    .filter(col => col.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(col => ({
      title: col.title,
      dataIndex: col.dataIndex,
      key: col.key,
      width: col.width,
      // ColumnConfigItem 不含的属性在此补回
      align: col.key === 'action' ? 'center' as const : undefined,
      fixed: col.key === 'action' ? 'right' as const : undefined,
    }));
});
```

### 5. 添加 onMounted 加载保存的配置

```ts
import { onMounted } from 'vue';

onMounted(() => {
  const stored = localStorage.getItem('column_config_<page-key>');
  if (stored) {
    try {
      const savedConfig = JSON.parse(stored);
      const merged = savedConfig.map((s: ColumnConfigItem) => {
        const defaultCol = allColumns.find(c => c.key === s.key);
        return {
          key: s.key,
          title: s.title,
          dataIndex: s.dataIndex,
          width: s.width || defaultCol?.width,
          visible: s.visible !== undefined ? s.visible : true,
          order: s.order !== undefined ? s.order : defaultCol?.order || 0,
        };
      });
      currentColumns.value = merged.sort((a: ColumnConfigItem, b: ColumnConfigItem) => a.order - b.order);
    } catch (e) {
      console.warn('加载列配置失败:', e);
    }
  }
});
```

### 6. 替换 handler 方法

```ts
// 旧
const showColumnSetting = () => {
  columnSettingVisible.value = true;
};
const handleColumnSettingApply = (newVisibleKeys: string[], newOrder: string[]) => {
  visibleColumnKeys.value = newVisibleKeys;
  columnOrder.value = newOrder;
  localStorage.setItem(STORAGE_KEY, JSON.stringify({ visibleKeys: newVisibleKeys, order: newOrder }));
};

// 新
const showColumnSetting = () => {
  columnSettingModalRef.value?.open();
};
const handleColumnSave = (columns: ColumnConfigItem[]) => {
  currentColumns.value = columns;
};
const handleColumnCancel = () => {};
```

### 7. 更新模板

```html
<!-- 旧 -->
<ColumnSettingModal
  v-model:visible="columnSettingVisible"
  :columns="allColumns"
  :column-order="columnOrder"
  :visible-column-keys="visibleColumnKeys"
  @apply="handleColumnSettingApply"
/>

<!-- 新 -->
<ColumnSettingModal
  ref="columnSettingModalRef"
  page-key="<page-key>"
  :default-columns="allColumns"
  @save="handleColumnSave"
  @cancel="handleColumnCancel"
/>
```

`page-key` 值需要唯一，通常与页面路由名一致（如 `manual-call-report`、`quality-workbench`）。

## 常见错误

### TS2345: missing properties pageKey, defaultColumns

说明模板还在用旧版 props。按上述步骤 7 更新模板。

### TS2322: Type 'string[]' is not assignable to type 'string'

通常是因为 `allColumns` 的类型还是 `TableColumnType[]`，改为 `ColumnConfigItem[]` 后消失。

### 导出 Excel 时列信息丢失

如果导出功能依赖 `visibleColumnKeys` 或 `columnOrder`，改为依赖 `visibleColumns` computed（已经过滤和排序好的列）。

## 参考文件

- 组件实现：`src/components/ColumnSettingModal.vue`
- 类型定义：`src/utils/columnConfig.ts` 中的 `ColumnConfigItem`
- 完整示例：`src/pages/AICallReport.vue`（已使用新版 API）
