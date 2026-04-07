# Pagination 分页组件

可复用的分页组件，基于 `ant-design-vue` 的 `a-pagination` 封装。

## 使用方式

```vue
<template>
  <div>
    <!-- 基本用法 -->
    <Pagination
      v-model:current="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      @change="handlePageChange"
      @page-size-change="handlePageSizeChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import Pagination from '@/components/Pagination';

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(100);

const handlePageChange = (page: number, pageSize: number) => {
  console.log('当前页:', page, '每页条数:', pageSize);
  // 在这里加载数据
};

const handlePageSizeChange = (current: number, size: number) => {
  console.log('当前页:', current, '每页条数:', size);
  // 在这里加载数据
};
</script>
```

## Props

| 参数 | 说明 | 类型 | 默认值 |
|------|------|------|--------|
| current | 当前页码 | `number` | `1` |
| pageSize | 每页条数 | `number` | `10` |
| total | 数据总数 | `number` | - |
| showSizeChanger | 是否展示每页条数切换器 | `boolean` | `true` |
| showQuickJumper | 是否展示快速跳转 | `boolean` | `true` |
| showTotal | 是否展示总数 | `boolean` | `true` |
| pageSizeOptions | 每页条数选项 | `string[]` | `['10', '20', '50']` |
| showLessItems | 是否显示较少页面内容 | `boolean` | `false` |
| simple | 是否采用简单模式 | `boolean` | `false` |
| locale | 国际化配置 | `object` | `{ items_per_page: '条/页', jump_to: '跳转至', page: '页' }` |

## Events

| 事件名 | 说明 | 回调参数 |
|--------|------|----------|
| update:current | 当前页码变化 | `(current: number)` |
| update:pageSize | 每页条数变化 | `(pageSize: number)` |
| change | 页码变化 | `(page: number, pageSize: number)` |
| pageSizeChange | 每页条数变化 | `(current: number, size: number)` |

## 文件结构

```
src/components/Pagination/
├── index.vue    # 组件实现
└── index.ts     # 组件导出
```
