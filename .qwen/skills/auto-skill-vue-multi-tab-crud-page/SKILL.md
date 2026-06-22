---
name: vue-multi-tab-crud-page
description: 在 Vue 3 + Ant Design Vue 中构建多 Tab 数据管理页，每个 Tab 独立搜索/表格/分页/导出/列配置，共享 ColumnSettingModal 和导出弹窗
source: auto-skill
extracted_at: '2026-06-22T10:54:07.150Z'
---

# 多 Tab 数据管理页面

当需要在一个页面中用 `a-tabs` 组织多个独立数据列表时，每个 Tab 各自持有搜索/表格/分页/列配置状态，但共享 ColumnSettingModal 和导出弹窗组件。

## 适用场景

- 数据湖：AI外呼批次 / 人工外呼批次 / 待绑定批次 / 上传失败批次 / 免打扰名单
- 质检任务：AI质检任务 / 人工质检任务
- 任何需要 Tab 分区展示同类 CRUD 列表的页面

## 页面结构

```
<template>
  <div class="xxx-page">
    <div class="quality-wrapper">
      <!-- 无顶部 page-header-section，直接进入 Tab -->
      <div class="tab-section">
        <a-tabs v-model:activeKey="activeTab" :animated="false" @change="handleTabChange">
          <a-tab-pane key="tab1" tab="标签1">
            <div class="search-and-table-area">
              <div class="search-area">...</div>
              <div class="table-toolbar">...</div>
              <div class="table-area">
                <div class="table-wrapper"><a-table ... /></div>
                <Pagination ... />
              </div>
            </div>
          </a-tab-pane>
          <!-- 更多 tab-pane -->
        </a-tabs>
      </div>
    </div>

    <!-- 共享的列设置弹窗 -->
    <ColumnSettingModal
      ref="columnSettingModalRef"
      :page-key="`page-name-${activeTab}`"
      :default-columns="currentSettingColumns"
      @save="handleColumnSave"
      @cancel="handleColumnCancel"
    />

    <!-- 共享的导出弹窗 -->
    <a-modal v-model:open="exportModalVisible" ...>
      <a-checkbox-group v-model:value="exportFieldKeys" :options="exportFieldOptions" />
    </a-modal>
  </div>
</template>
```

## 搜索区域布局

每个 Tab 搜索栏无边框，一行 4 个 `a-col :span="6"`，按钮行左对齐：

```html
<div class="search-area">
  <a-form layout="vertical">
    <!-- 第一行：4 个搜索条件 -->
    <a-row :gutter="16">
      <a-col :span="6"><a-form-item><a-input ... /></a-form-item></a-col>
      <a-col :span="6"><a-form-item><a-select ... /></a-form-item></a-col>
      <a-col :span="6"><a-form-item><a-input ... /></a-form-item></a-col>
      <a-col :span="6"><a-form-item><a-range-picker ... /></a-form-item></a-col>
    </a-row>
    <!-- 第二行：剩余条件 + 按钮（紧跟左侧，不用 offset） -->
    <a-row :gutter="16">
      <a-col :span="6"><a-form-item><a-range-picker ... /></a-form-item></a-col>
      <a-col :span="6">
        <a-form-item>
          <a-space class="search-btn-space">
            <a-button @click="handleReset"><reload-outlined />重置</a-button>
            <a-button type="primary" @click="handleSearch"><search-outlined />搜索</a-button>
          </a-space>
        </a-form-item>
      </a-col>
    </a-row>
  </a-form>
</div>
```

条件不足一行 4 个时（如上传失败批次只有 4 个搜索条件），按钮独占一行、左对齐：
```html
<a-row :gutter="16">
  <a-col :span="6">
    <a-form-item>...</a-form-item>
  </a-col>
  <!-- 不用 :offset，按钮自然左对齐 -->
</a-row>
```

CSS（无边框 + 行间距 12px）：
```css
.search-area {
  background: #fff;
  border-radius: 6px;
  padding: 16px 0 4px;
}
.search-area :deep(.ant-row) {
  margin-bottom: 0;       /* 不用负边距，避免行被压缩 */
}
.search-area :deep(.ant-form-item) {
  margin-bottom: 12px;    /* 两行之间保持 12px 间距 */
}
```

## 每个 Tab 的独立状态

每个 Tab 维护自己的响应式状态，结构相同：

```ts
// 搜索表单
const xxxSearch = reactive({ field1: '', field2: undefined as string | undefined, ... });

// 数据源
const xxxDataSource = ref<XxxItem[]>([]);
const xxxTotal = ref(0);
const xxxLoading = ref(false);
const xxxSelectedKeys = ref<string[]>([]);
const xxxPagination = reactive({ current: 1, pageSize: 10, total: 0 });

// 列定义
const allXxxColumns: ColumnConfigItem[] = [...];
const xxxColumnConfig = ref<ColumnConfigItem[]>([]);
const xxxVisibleColumns = computed(() => {
  const cols = xxxColumnConfig.value.length > 0 ? xxxColumnConfig.value : allXxxColumns;
  return cols.filter(c => c.visible).sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(c => ({
      title: c.title, dataIndex: c.dataIndex, key: c.key, width: c.width,
      align: c.key === 'action' ? 'center' as const : undefined,
      fixed: c.key === 'action' ? 'right' as const : undefined,
    }));
});
```

## Tab 切换 → 共享弹窗的映射

用一个映射表将 `activeTab` 与各 Tab 的列配置关联，这样 ColumnSettingModal 和导出弹窗不需要为每个 Tab 各写一份：

```ts
const tabColumnsMap: Record<string, { all: ColumnConfigItem[]; config: typeof xxxColumnConfig }> = {
  tab1: { all: allTab1Columns, config: tab1ColumnConfig },
  tab2: { all: allTab2Columns, config: tab2ColumnConfig },
  // ...
};

// ColumnSettingModal 的 default-columns 动态指向当前 Tab
const currentSettingColumns = computed(() => {
  const entry = tabColumnsMap[activeTab.value];
  return entry && entry.config.value.length > 0 ? entry.config.value : (entry?.all ?? []);
});

// 导出弹窗的字段选项也动态指向当前 Tab
const exportFieldOptions = computed(() => {
  const entry = tabColumnsMap[activeTab.value];
  if (!entry) return [];
  const cols = entry.config.value.length > 0 ? entry.config.value : entry.all;
  return cols.filter(c => c.key !== 'action').map(c => ({ label: c.title, value: c.dataIndex }));
});

// 保存列设置时写回当前 Tab
const handleColumnSave = (columns: ColumnConfigItem[]) => {
  const entry = tabColumnsMap[activeTab.value];
  if (entry) entry.config.value = columns;
};
```

ColumnSettingModal 的 `page-key` 需要包含 Tab key 以隔离 localStorage：
```html
<ColumnSettingModal :page-key="`page-name-${activeTab}`" ... />
```

## 导出 Excel

共享一个导出弹窗，用变量记住当前操作的是哪个 Tab：

```ts
let currentExportTab = '';

const openExportModal = (tab: string) => {
  currentExportTab = tab;
  exportFieldKeys.value = exportFieldOptions.value.map(opt => opt.value);
  exportModalVisible.value = true;
};

const dataSourceMap: Record<string, any[]> = {
  tab1: tab1DataSource.value,
  tab2: tab2DataSource.value,
  // ...
};

const tabNameMap: Record<string, string> = { tab1: '标签1', tab2: '标签2', ... };

const handleExportExcel = () => {
  const headers = exportFieldKeys.value.map(key => { /* ... */ });
  const rows = (dataSourceMap[currentExportTab] || []).map(item =>
    exportFieldKeys.value.map(key => (item as any)[key] ?? '')
  );
  // 用 XLSX 生成文件，sheet 名和文件名取自 tabNameMap
};
```

## 关键 CSS

```css
.tab-section {
  background: #fff;
  padding: 0 24px;
}
.tab-section :deep(.ant-tabs-nav) {
  margin-bottom: 0;
}
.search-and-table-area {
  padding-top: 16px;
}
.table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
}
```

## 表格工具栏 — 批量操作

某些 Tab 需要批量操作按钮（批量删除、导入、导出），按钮行左对齐、紧跟在选择计数后面：

```html
<div class="table-toolbar">
  <div class="table-toolbar-left">
    <span class="selection-info">共 {{ total }} 条，已选 {{ selectedKeys.length }} 条</span>
    <!-- 批量删除：需选中才可用 -->
    <a-popconfirm title="确定批量删除选中记录吗？" @confirm="handleBatchRemove">
      <a-button type="primary" danger size="small" :disabled="selectedKeys.length === 0">
        <delete-outlined /> 批量删除
      </a-button>
    </a-popconfirm>
    <!-- 导入：a-upload + before-upload 返回 false 阻止自动上传 -->
    <a-upload :show-upload-list="false" accept=".xlsx,.xls,.csv" :before-upload="handleImport">
      <a-button size="small"><import-outlined /> 导入</a-button>
    </a-upload>
    <!-- 导出 -->
    <a-button size="small" @click="handleExport">
      <file-excel-outlined /> 导出
    </a-button>
  </div>
</div>
```

导入解析模式（FileReader + XLSX）：
```ts
const handleImport = (file: File) => {
  const reader = new FileReader();
  reader.onload = (e) => {
    const wb = XLSX.read(e.target?.result, { type: 'array' });
    const ws = wb.Sheets[wb.SheetNames[0]];
    const data = XLSX.utils.sheet_to_json<any[]>(ws, { header: 1 });
    // data[0] 为表头，data[1..] 为数据行
    // 逐行映射到接口类型，追加到 dataSource
    message.success(`导入成功，共 ${data.length - 1} 条`);
  };
  reader.readAsArrayBuffer(file);
  return false; // 阻止 a-upload 自动上传
};
```

导出专用按钮（不经共享导出弹窗，直接导出全量数据）：
```ts
const handleExport = () => {
  const headers = ['列1', '列2', ...];
  const rows = dataSource.value.map(item => [item.field1, item.field2, ...]);
  const ws = XLSX.utils.aoa_to_sheet([headers, ...rows]);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Sheet1');
  XLSX.writeFile(wb, `文件名_${new Date().toISOString().slice(0, 10)}.xlsx`);
};
```

批量删除：
```ts
const handleBatchRemove = () => {
  dataSource.value = dataSource.value.filter(item => !selectedKeys.value.includes(item.id));
  total.value -= selectedKeys.value.length;
  selectedKeys.value = [];
  message.success('批量删除成功');
};
```

注意 `a-table` 需配置 `row-selection` 以支持多选：
```html
<a-table :row-selection="{ selectedRowKeys: selectedKeys, onChange: (keys: string[]) => { selectedKeys = keys } }" ... />
```

## handleTabChange：切换 Tab 必须加载数据

`onMounted` 只加载默认 Tab 的数据。`handleTabChange` **不能留空**，必须根据 `activeTab` 调用对应的加载函数：

```ts
const handleTabChange = () => {
  const loadMap: Record<string, () => void> = {
    tab1: loadTab1Data,
    tab2: loadTab2Data,
    tab3: loadTab3Data,
    // ...
  };
  loadMap[activeTab.value]?.();
};
```

常见 bug：`handleTabChange` 留空或只写注释，导致切换到其他 Tab 时表格无数据。

## 注意事项

- `a-tabs` 加 `:animated="false"` 避免切换时内容闪烁
- 搜索按钮行不使用 `:offset`，始终左对齐；条件不满 4 个时空位自然留白
- 搜索行间距通过 `.search-area :deep(.ant-row)` 设 `margin-bottom: 0` + `.ant-form-item` 设 `margin-bottom: 12px` 实现行间 12px 间距
- 表格行操作列 `fixed: 'right'` + `align: 'center'`
- 操作按钮多于 3 个时，操作列宽度需 ≥ 280px，表格 `scroll.x` 同步加大以防止按钮溢出
