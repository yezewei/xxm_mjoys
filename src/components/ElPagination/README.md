# ElPagination 分页组件（Element Plus 版本）

可复用的分页组件，基于 `element-plus` 的 `el-pagination` 封装。

## 使用方式

```vue
<template>
  <div>
    <!-- 基本用法 -->
    <ElPagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      @change="handlePageChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import ElPagination from '@/components/ElPagination';

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(100);

const handlePageChange = (page: number, size: number) => {
  console.log('当前页:', page, '每页条数:', size);
  // 在这里加载数据
};
</script>
```

## Props

| 参数 | 说明 | 类型 | 默认值 |
|------|------|------|--------|
| currentPage | 当前页码 | `number` | `1` |
| pageSize | 每页条数 | `number` | `10` |
| total | 数据总数 | `number` | - |
| pageSizes | 每页条数选项 | `number[]` | `[10, 20, 50, 100]` |
| layout | 布局方式 | `string` | `'total, prev, pager, next, sizes, jumper'` |
| background | 是否为分页按钮添加背景色 | `boolean` | `true` |

## Events

| 事件名 | 说明 | 回调参数 |
|--------|------|----------|
| update:currentPage | 当前页码变化 | `(currentPage: number)` |
| update:pageSize | 每页条数变化 | `(pageSize: number)` |
| sizeChange | 每页条数变化 | `(size: number)` |
| currentChange | 页码变化 | `(page: number)` |
| change | 页码或每页条数变化 | `(page: number, size: number)` |

## 文件结构

```
src/components/ElPagination/
├── index.vue    # 组件实现
└── index.ts     # 组件导出
```

## 样式说明

组件已内置 Ant Design 风格的分页样式：
- 页码按钮采用白色背景，灰色边框
- 激活状态为蓝色背景，白色文字
- hover 效果为蓝色边框和文字
- 每页条数选择器高度为 32px
- 快速跳转输入框宽度为 50px
