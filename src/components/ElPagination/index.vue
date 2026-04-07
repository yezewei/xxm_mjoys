<template>
  <div class="pagination-component">
    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :page-sizes="pageSizes"
      :total="total"
      :layout="layout"
      :background="background"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue';

interface Props {
  currentPage?: number;
  pageSize?: number;
  total: number;
  pageSizes?: number[];
  layout?: string;
  background?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  currentPage: 1,
  pageSize: 10,
  pageSizes: () => [10, 20, 50, 100],
  layout: 'total, prev, pager, next, sizes, jumper',
  background: true,
});

const emit = defineEmits<{
  'update:currentPage': [value: number];
  'update:pageSize': [value: number];
  sizeChange: [size: number];
  currentChange: [page: number];
  change: [page: number, size: number];
}>();

const currentPage = ref(props.currentPage);
const pageSize = ref(props.pageSize);

// 监听外部变化
watch(
  () => props.currentPage,
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

// 每页条数变化
const handleSizeChange = (size: number) => {
  emit('update:pageSize', size);
  emit('sizeChange', size);
  emit('change', currentPage.value, size);
};

// 页码变化
const handleCurrentChange = (page: number) => {
  emit('update:currentPage', page);
  emit('currentChange', page);
  emit('change', page, pageSize.value);
};
</script>

<style scoped>
.pagination-component {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 16px;
  padding-top: 16px;
}

.pagination-component :deep(.el-pagination) {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pagination-component :deep(.el-pagination__total) {
  font-size: 14px;
  color: #1f2329;
  margin-right: 8px;
}

.pagination-component :deep(.el-pager) {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pagination-component :deep(.el-pager li) {
  min-width: 32px;
  height: 32px;
  line-height: 32px;
  font-size: 14px;
  border-radius: 4px;
  border: 1px solid #d9d9d9;
  background: #fff;
  transition: all 0.3s;
}

.pagination-component :deep(.el-pager li.is-active) {
  background-color: #1677ff;
  color: #fff;
  border: 1px solid #1677ff;
}

.pagination-component :deep(.el-pager li:hover) {
  color: #1677ff;
  border-color: #1677ff;
}

.pagination-component :deep(.btn-prev),
.pagination-component :deep(.btn-next) {
  border: 1px solid #d9d9d9;
  background: #fff;
  font-size: 14px;
  color: #1f2329;
  min-width: 32px;
  height: 32px;
  border-radius: 4px;
  transition: all 0.3s;
}

.pagination-component :deep(.btn-prev):hover,
.pagination-component :deep(.btn-next):hover {
  color: #1677ff;
  border-color: #1677ff;
}

.pagination-component :deep(.el-pagination__sizes) {
  margin-left: 8px;
}

.pagination-component :deep(.el-select .el-input__wrapper) {
  min-width: 110px;
  height: 32px;
  border-radius: 4px;
}

.pagination-component :deep(.el-pagination__jump) {
  margin-left: 16px;
  font-size: 14px;
  color: #1f2329;
}

.pagination-component :deep(.el-input__inner) {
  height: 32px;
  border-radius: 4px;
}
</style>
