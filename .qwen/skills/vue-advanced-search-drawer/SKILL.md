---
name: vue-advanced-search-drawer
description: 将 Ant Design Vue 页面的内联筛选区域改造为抽屉式高级搜索交互模式
source: auto-skill
extracted_at: '2026-06-03T09:39:31.006Z'
---

# 抽屉式高级搜索改造

当页面筛选条件过多（≥6 个）导致界面拥挤时，将大部分条件移入右侧抽屉，内联只保留最常用的 2~3 个关键条件 + 操作按钮。

## 1. 新增状态变量

```ts
const drawerVisible = ref(false)
```

## 2. 精简内联搜索栏

只保留最高频的 2~3 个字段（如 ID、状态）+ 搜索/重置/高级搜索 三个按钮：

```html
<div class="filter-card">
  <div class="intent-toolbar">
    <div class="toolbar-left">
      <a-space>
        <a-input v-model:value="filterForm.detailId" placeholder="..." style="width: 180px" allow-clear />
        <a-input v-model:value="filterForm.callId" placeholder="..." style="width: 180px" allow-clear />
        <a-select v-model:value="filterForm.asrStatus" placeholder="..." allow-clear style="width: 180px">
          <!-- options -->
        </a-select>
        <a-button type="primary" @click="handleFilterSearch"><search-outlined /> 搜索</a-button>
        <a-button @click="handleReset"><reload-outlined /> 重置</a-button>
        <a-button @click="drawerVisible = true"><search-outlined /> 高级搜索</a-button>
      </a-space>
    </div>
  </div>
</div>
```

> **不要用 `grid-template-columns: repeat(4, 1fr)`**，否则按钮会被拉伸到与输入框等宽。使用 `toolbar-left > a-space` 模式，输入框给固定宽度（如 `180px`），按钮保持自然宽度。

## 3. 添加抽屉组件

紧接在 filter-card 之后、数据表格之前放置 `<a-drawer>`：

```html
<a-drawer
  title="高级搜索"
  :open="drawerVisible"
  @close="drawerVisible = false"
  :width="480"
  :body-style="{ padding: '16px 24px' }"
>
  <a-form layout="vertical">
    <!-- 所有筛选条件，每个一个 a-form-item -->
    <a-form-item label="字段名">
      <a-select v-model:value="filterForm.xxx" placeholder="..." allow-clear style="width: 100%">
        <!-- options -->
      </a-select>
    </a-form-item>

    <!-- 数值区间搜索 -->
    <a-form-item label="评分区间">
      <div class="score-range-group">
        <a-input-number v-model:value="filterForm.scoreMin" :min="0" :max="100" placeholder="最低" class="range-input" allow-clear />
        <span class="range-separator">~</span>
        <a-input-number v-model:value="filterForm.scoreMax" :min="0" :max="100" placeholder="最高" class="range-input" allow-clear />
      </div>
    </a-form-item>

    <!-- 条件性显示：根据 activeTab / getTaskType() 等 -->
    <template v-if="activeTab === 'ai'">
      <a-form-item label="AI 质检状态">...</a-form-item>
    </template>
    <template v-else>
      <a-form-item label="质检员">...</a-form-item>
    </template>
  </a-form>

  <!-- 底部固定按钮 -->
  <div class="drawer-footer">
    <a-button @click="handleReset" style="margin-right: 8px">重置</a-button>
    <a-button type="primary" @click="handleFilterSearch">搜索</a-button>
  </div>
</a-drawer>
```

## 4. 抽屉设计要点

- **宽度**：`480px`（标签约 120px + 控件约 180px + 两侧留白约 180px），可根据实际控件宽度调整，最小不小于 `控件宽度 + 100px`
- **布局**：`a-form layout="vertical"` 纵向排列，每行一个条件，控件 `width: 100%` 撑满
- **底部按钮**：使用绝对定位固定在抽屉底部，与 body 内容区分离
- **数据共享**：抽屉和内联共用同一个 `filterForm`，搜索/重置逻辑完全复用
- **条件分组**：用 `<template v-if>` 按任务类型（AI/人工）条件性展示不同字段

## 5. CSS

```css
/* 内联搜索栏 */
.intent-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* 抽屉底部固定按钮 */
.drawer-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 12px 24px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  text-align: right;
  z-index: 1;
}

/* 区间搜索 */
.score-range-group { display: flex; align-items: center; gap: 8px; width: 100%; }
.range-input { flex: 1; }
.range-separator { color: #8f959e; font-size: 14px; }

/* 高级搜索抽屉行间距（默认 24px 过大，缩短为 12px） */
.advanced-search-drawer :deep(.ant-form-item) {
  margin-bottom: 12px;
}
```

> **区间输入框宽度**：使用 `flex: 1` 让两个输入框各占一半，总宽度与其他 `width: 100%` 的输入框一致。不要用固定 `width: 110px`，否则总宽度会比其他字段窄。
> **行间距**：Ant Design Vue 表单默认 `margin-bottom: 24px`，在抽屉中显得过于松散，建议缩短为 `12px`。

## 6. 同步修改 handleReset

重置函数中需清空所有筛选字段（包括抽屉中的），因为内联和抽屉共享同一个 filterForm。

## 注意事项

- **无 label 模式**：本项目抽屉表单采用无 label 设计，用 `placeholder` 作为字段名称（如 `placeholder="关键词匹配质检项"`），不使用 `a-form-item label="..."`。保持此约定以统一视觉风格。
- 抽屉放在模板中的位置不影响渲染，但建议紧跟 filter-card 之后便于维护
- 如果页面有 AI/人工两种任务类型且字段差异大，抽屉内用 `<template v-if>` 分组，避免字段混乱
- `a-drawer` 的 `:open` 属性在 Ant Design Vue 4.x 中替代了旧版 `v-model:open`，注意版本兼容
- 内联栏和抽屉中的同一个字段（如 detailId）会双向绑定同一个值，无需额外同步
