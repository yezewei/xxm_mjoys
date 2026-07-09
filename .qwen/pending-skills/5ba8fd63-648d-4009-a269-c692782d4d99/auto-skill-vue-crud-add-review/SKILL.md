---
name: vue-crud-add-review
description: 在 Vue 3 + Ant Design Vue CRUD 页面中增加审核/审批功能，包含状态字段、审核弹窗、状态筛选和条件操作按钮
source: auto-skill
extracted_at: '2026-07-09T06:14:43.348Z'
---

# Vue CRUD 页面添加审核功能

## 适用场景
在已有的 Vue 3 + Ant Design Vue CRUD 页面中增加审核/审批工作流，使新建或编辑的记录需要经过审核才能正式生效。

## 步骤

### 1. 搜索区域添加状态筛选

在搜索区域的 `<a-space>` 中添加审核状态下拉框：

```vue
<a-select
  v-model:value="searchForm.status"
  placeholder="审核状态"
  allow-clear
  style="width: 150px;"
>
  <a-select-option value="pending">待审核</a-select-option>
  <a-select-option value="approved">已通过</a-select-option>
  <a-select-option value="rejected">已拒绝</a-select-option>
</a-select>
```

更新 `searchForm` 添加 `status` 字段：
```ts
const searchForm = reactive({
  fieldName: '',
  status: undefined as string | undefined,
});
```

更新 `handleReset` 清空状态筛选：
```ts
const handleReset = () => {
  searchForm.fieldName = '';
  searchForm.status = undefined;
  // ...
};
```

### 2. 表格列添加审核状态列

在表格列配置中添加状态列（通常放在字典列之后、时间列之前）：

```ts
{
  title: '审核状态',
  dataIndex: 'status',
  key: 'status',
  width: 100,
},
```

在 `<template #bodyCell>` 中添加状态列渲染：

```vue
<template v-else-if="column.key === 'status'">
  <a-tag :color="getStatusColor(record.status)">
    {{ getStatusText(record.status) }}
  </a-tag>
</template>
```

### 3. 添加状态辅助函数

```ts
// 获取审核状态颜色
const getStatusColor = (status: string) => {
  const colorMap: Record<string, string> = {
    pending: 'warning',
    approved: 'success',
    rejected: 'error',
  };
  return colorMap[status] || 'default';
};

// 获取审核状态文本
const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待审核',
    approved: '已通过',
    rejected: '已拒绝',
  };
  return textMap[status] || status;
};
```

### 4. 操作列添加审核按钮

在操作列中添加条件显示的审核按钮（仅对待审核状态显示）：

```vue
<a-button
  v-if="record.status === 'pending'"
  type="link"
  size="small"
  @click="handleReview(record)"
>
  审核
</a-button>
```

### 5. 添加审核弹窗

在新增/编辑弹窗之后添加审核弹窗：

```vue
<!-- 审核弹窗 -->
<a-modal
  v-model:open="reviewModalVisible"
  title="标签审核"
  width="500px"
  :confirm-loading="reviewConfirmLoading"
  ok-text="确定"
  cancel-text="取消"
  @ok="handleReviewOk"
>
  <a-form layout="vertical">
    <a-form-item label="标签名称">
      <a-input :value="reviewData.fieldName" disabled />
    </a-form-item>
    <a-form-item label="审核结果">
      <a-radio-group v-model:value="reviewData.status">
        <a-radio value="approved">通过</a-radio>
        <a-radio value="rejected">拒绝</a-radio>
      </a-radio-group>
    </a-form-item>
    <a-form-item label="审核意见" v-if="reviewData.status === 'rejected'">
      <a-textarea
        v-model:value="reviewData.remark"
        placeholder="请输入拒绝原因"
        :rows="3"
      />
    </a-form-item>
  </a-form>
</a-modal>
```

### 6. 添加审核相关的响应式数据和方法

```ts
// 审核弹窗控制
const reviewModalVisible = ref(false);
const reviewConfirmLoading = ref(false);
const reviewData = ref({
  id: undefined as number | undefined,
  fieldName: '',
  status: 'approved',
  remark: '',
});

// 打开审核弹窗
const handleReview = (record: any) => {
  reviewData.value = {
    id: record.id,
    fieldName: record.fieldName,
    status: 'approved',
    remark: '',
  };
  reviewModalVisible.value = true;
};

// 提交审核
const handleReviewOk = () => {
  reviewConfirmLoading.value = true;
  // TODO: 调用后端 API 审核
  setTimeout(() => {
    message.success(`审核${reviewData.value.status === 'approved' ? '通过' : '拒绝'}成功`);
    reviewModalVisible.value = false;
    reviewConfirmLoading.value = false;
    loadData();
  }, 500);
};
```

### 7. 更新新增逻辑设置默认状态

新增记录时设置默认状态为 `pending`：

```ts
const handleAdd = () => {
  formData.value = {
    // ...
    status: 'pending',
  };
};
```

## 注意事项

- 审核弹窗中的拒绝原因输入框仅在选择"拒绝"时显示（`v-if="reviewData.status === 'rejected'"`）
- 审核按钮仅对待审核状态的记录显示
- 状态颜色映射：待审核=warning(橙色)、已通过=success(绿色)、已拒绝=error(红色)
- 审核后需要刷新列表数据以更新状态显示
