---
name: vue-column-replace
description: 在 Vue 3 + Ant Design Vue CRUD 页面中整体替换表格列结构（字段重命名/增删/重排），同步更新接口、列定义、mock数据、模板渲染、导出
source: auto-skill
extracted_at: '2026-06-22T11:18:07.771Z'
---

# CRUD 表格列结构整体替换

当需要对已有 CRUD 表格的列结构做大幅调整（字段重命名、增删、重排）时，按以下 6 步依次修改，避免遗漏导致运行时报错。

## 适用场景

- 产品需求变更导致字段结构整体调整（如"免打扰名单"从旧字段切换到全新字段列表）
- 接口字段重命名（如 `phoneNumber` → `联系方式`，列标题同步变更）
- 需要在多个关联位置同步新字段

## 修改步骤

### 1. 接口定义 `interface XxxItem`

移除不再需要的字段，添加新字段，保持类型正确：

```ts
interface DndItem {
  id: string;
  phoneNumber: string;    // 保留
  addMethod: string;      // 新增
  sourceReason: string;   // 新增（替代旧字段）
  orgName: string;        // 新增
  approvalStatus: string; // 新增
  // customerName: 删除
  // dndLevel: 删除
}
```

### 2. 列定义 `allXxxColumns`

更新 `ColumnConfigItem[]`，调整 `order` 值保证排列顺序，`title` 对应产品需求的列名：

```ts
const allDndColumns: ColumnConfigItem[] = [
  { key: 'id', title: 'ID', dataIndex: 'id', width: 150, visible: true, order: 0 },
  { key: 'phoneNumber', title: '联系方式', dataIndex: 'phoneNumber', width: 140, visible: true, order: 1 },
  { key: 'addMethod', title: '添加方式', dataIndex: 'addMethod', width: 110, visible: true, order: 2 },
  // ... 按需求顺序排列
  { key: 'approvalStatus', title: '审批状态', dataIndex: 'approvalStatus', width: 120, visible: true, order: 10 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 160, visible: true, order: 11 },
];
```

注意：`action` 列始终放最后，`order` 值为最大。

### 3. 模拟数据 `loadXxxData`

更新数据生成逻辑，移除旧字段、添加新字段。使用数组取模实现多样化：

```ts
const loadDndData = () => {
  dndLoading.value = true;
  setTimeout(() => {
    const sources = ['客户申请', '系统标记', '人工添加', '监管要求'];
    const statuses = ['待审批', '审批通过', '审批不通过'];
    const reasons = ['客户主动申请', '多次投诉标记', '监管合规要求', ...];
    const methods = ['手动添加', '批量导入', '系统自动'];
    const orgs = ['象小秘总行', '华东分行', '华南分行', ...];
    const prefixes = ['138', '139', '150', '186', '177', '199'];

    dndDataSource.value = Array.from({ length: 30 }, (_, i) => ({
      id: `DND-${String(i + 1).padStart(6, '0')}`,
      phoneNumber: `${prefixes[i % 8]}${String(10000000 + i * 3333333).slice(0, 8)}`,
      addMethod: methods[i % 3],
      approvalStatus: statuses[i % 3],
      // ... 其他字段
    }));
  }, 400);
};
```

要点：
- 数组长度建议 20~30 条，方便分页和滚动测试
- 手机号用不同号段前缀增加真实感
- 日期字段用模运算生成不同月份/日期
- 备注等文本字段准备 10+ 条不同内容

### 4. 表格模板 `bodyCell` 渲染

移除旧字段的 `v-else-if` 分支，添加新字段的渲染逻辑。常用渲染模式：

```html
<!-- 状态类字段 — Tag 颜色 -->
<template v-else-if="column.key === 'approvalStatus'">
  <a-tag :color="record.approvalStatus === '审批通过' ? 'green'
    : record.approvalStatus === '审批不通过' ? 'red' : 'orange'">
    {{ record.approvalStatus }}
  </a-tag>
</template>

<!-- 枚举类字段 — Tag 区分 -->
<template v-else-if="column.key === 'addMethod'">
  <a-tag :color="record.addMethod === '手动添加' ? 'green'
    : record.addMethod === '批量导入' ? 'blue' : 'orange'">
    {{ record.addMethod }}
  </a-tag>
</template>

<!-- 特殊值高亮 -->
<template v-else-if="column.key === 'releaseTime'">
  <span :style="{ color: record.releaseTime === '永久' ? '#ff4d4f' : '' }">
    {{ record.releaseTime }}
  </span>
</template>

<!-- 普通文本（长文本截断 + Tooltip） -->
<template v-else-if="column.key === 'remark'">
  <a-tooltip v-if="record.remark" placement="topLeft">
    <template #title><span>{{ record.remark }}</span></template>
    <span class="remark-text">{{ record.remark }}</span>
  </a-tooltip>
  <span v-else style="color: #ccc;">-</span>
</template>
```

简单文本字段（如 `orgName`、`sourceReason`）不需要 bodyCell 分支，直接由 a-table 默认渲染。

### 5. 导出处理 `handleXxxExport`

同步更新 headers 和 rows 映射，确保字段顺序和标题与列定义一致：

```ts
const handleDndExport = () => {
  const headers = ['ID', '联系方式', '添加方式', '来源', '添加原因', '机构名称', '添加时间', '解除时间', '添加人', '备注', '审批状态'];
  const rows = dndDataSource.value.map(item => [
    item.id, item.phoneNumber, item.addMethod, item.source,
    item.sourceReason, item.orgName, item.addTime, item.releaseTime,
    item.operator, item.remark, item.approvalStatus,
  ]);
  // XLSX.writeFile ...
};
```

### 6. 搜索表单（按需）

如果新字段需要作为搜索条件，同步更新：
- `xxxSearch` reactive 对象（添加新字段、移除旧字段）
- 搜索区域的 `<a-form-item>` UI
- `handleXxxReset` 函数中清空新字段

## 注意事项

- 修改顺序：接口 → 列定义 → 模拟数据 → 模板渲染 → 导出 → 搜索。先改接口和列定义，TypeScript 会提示哪些地方还在引用旧字段。
- 如果页面有详情弹窗或编辑弹窗，也需要同步更新其中的字段展示。
- 多 Tab 页面中只改其中一个 Tab 时，注意不要误改其他 Tab 的接口和列定义。
- 搜索表单中已移除的字段要从 `handleXxxReset` 中一并清除，否则残留空赋值。
