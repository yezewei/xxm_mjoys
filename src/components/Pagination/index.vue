<template>
  <div class="pagination-component">
    <a-pagination
      v-model:current="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      :show-size-changer="showSizeChanger"
      :show-quick-jumper="showQuickJumper"
      :show-total="showTotal ? (total: number) => `共 ${total} 条` : undefined"
      :page-size-options="pageSizeOptions"
      :show-less-items="showLessItems"
      :simple="simple"
      :locale="locale"
      @change="handlePageChange"
      @show-size-change="handlePageSizeChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';

interface Props {
  current?: number;
  pageSize?: number;
  total: number;
  showSizeChanger?: boolean;
  showQuickJumper?: boolean;
  showTotal?: boolean;
  pageSizeOptions?: string[];
  showLessItems?: boolean;
  simple?: boolean;
  locale?: {
    items_per_page?: string;
    jump_to?: string;
    page?: string;
  };
}

const props = withDefaults(defineProps<Props>(), {
  current: 1,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: true,
  pageSizeOptions: () => ['10', '20', '50'],
  showLessItems: false,
  simple: false,
  locale: () => ({
    items_per_page: '条/页',
    jump_to: '跳转至',
    page: '页',
  }),
});

const emit = defineEmits<{
  'update:current': [value: number];
  'update:pageSize': [value: number];
  change: [page: number, pageSize: number];
  pageSizeChange: [current: number, size: number];
}>();

const currentPage = ref(props.current);
const pageSize = ref(props.pageSize);

// 监听外部变化
watch(
  () => props.current,
  (val) => {
    currentPage.value = val;
  }
);

watch(
  () => props.pageSize,
  (val) => {
    pageSize.value = val;
  }
);

// 分页变化
const handlePageChange = (page: number, size: number) => {
  emit('update:current', page);
  emit('change', page, size);
};

// 每页条数变化
const handlePageSizeChange = (current: number, size: number) => {
  emit('update:pageSize', size);
  emit('pageSizeChange', current, size);
};
</script>

<style scoped>
.pagination-component {
  padding: 16px 24px;
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid #f0f0f0;
}

.pagination-component :deep(.ant-pagination) {
  margin: 0;
}

.pagination-component :deep(.ant-pagination-item) {
  border-color: #d9d9d9;
}

.pagination-component :deep(.ant-pagination-item-active) {
  border-color: #1890ff;
  background: #1890ff;
}

.pagination-component :deep(.ant-pagination-item-active a) {
  color: #fff;
}

.pagination-component :deep(.ant-pagination-options-quick-jumper input) {
  border-color: #d9d9d9;
}

.pagination-component :deep(.ant-pagination-options-quick-jumper) {
  color: #666;
}

.pagination-component :deep(.ant-pagination-options-size-changer) {
  color: #666;
}

/* 修改分页文本显示 */
.pagination-component :deep(.ant-select-selector) {
  border-color: #d9d9d9 !important;
}

/* 修改每页条数文本 */
.pagination-component :deep(.ant-select-selection-item) {
  font-size: 13px;
}

.pagination-component :deep(.ant-pagination-options-quick-jumper) {
  margin-left: 16px;
}

.pagination-component :deep(.ant-pagination-options-quick-jumper input) {
  width: 50px !important;
  margin: 0 8px;
}
</style>
