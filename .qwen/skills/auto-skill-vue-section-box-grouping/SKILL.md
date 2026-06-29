---
name: vue-section-box-grouping
description: 在 Ant Design Vue 弹窗步骤表单中用 section-box 边框容器对相关表单区域进行视觉分组
source: auto-skill
extracted_at: '2026-06-29T06:41:46.913Z'
---

# 弹窗表单区域视觉分组（section-box）

## 场景
在多步骤 Modal 弹窗中，步骤表单包含多个逻辑区域（如录音类型 + 条件筛选），需要用边框容器将它们分组，使层次清晰。

## 做法

### 1. 模板结构
用 `<div class="section-box">` 包裹每个逻辑区域，标题放在框外：

```vue
<div class="step-content">
  <!-- 区域 1：独立框 -->
  <div class="section-box">
    <a-form ...>
      <a-form-item label="录音类型">...</a-form-item>
    </a-form>
    <!-- 条件子内容也放在同一框内 -->
    <div v-if="showUpload" class="upload-section">...</div>
  </div>

  <!-- 区域 2：标题在框外 -->
  <div class="section-title">请选择需要质检的数据范围</div>
  <div class="section-box">
    <div class="condition-area">
      <!-- 筛选条件表达式 -->
    </div>
  </div>
</div>
```

### 2. 条件区域用 `<template v-if>` 包裹
当框体内有多个元素且需要条件显示时，用 `<template v-if>` 包裹整个区域（标题 + 框），避免多余的 DOM 节点：

```vue
<template v-if="recordType !== 'manual_upload'">
  <div class="section-title">数据范围</div>
  <div class="section-box">
    <div class="condition-area">
      ...
    </div>
  </div>
</template>
```

### 3. 样式

```css
.section-box {
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  padding: 16px 20px;
  margin-bottom: 16px;
  background: #fafafa;
}

.section-title {
  color: #333;
  font-size: 14px;
  font-weight: 500;
  margin: 0 0 8px;
}
```

## 注意事项

### 缩进必须严格正确
在 `<template v-if>` 内嵌套 `<div>` 时，**缩进错位会导致 Vue 编译器报 "Element is missing end tag"**。每个 `<div>` 的闭合标签必须与对应的开标签对齐：

```vue
<!-- ✅ 正确 -->
<template v-if="show">
  <div class="section-box">
    <div class="condition-area">
      <div class="content">...</div>
    </div>
  </div>
</template>

<!-- ❌ 错误（缩进错位导致编译报错）-->
<template v-if="show">
<div class="section-box">
<div class="condition-area">
<div class="content">...</div>
</div>
</div>
</template>
```

### 框内条件子内容 vs 框外条件区域
- 框**内**条件内容：直接用 `v-if`，内容消失时框仍可见（如上传区域）
- 框**外**条件区域：用 `<template v-if>` 包裹标题+框，整个区域一起隐藏/显示

## 变体：标签在容器内部

当多个配置区域并列展示且每个区域有独立标题时，将标签放在边框容器内部，形成"卡片区块"效果：

```vue
<!-- 质检数量 -->
<div class="quality-count-section">
  <div class="quality-count-label">质检数量</div>
  <div class="quality-count-content">
    <!-- 内容 -->
  </div>
</div>

<!-- 抽样方式（条件显示） -->
<template v-if="qualityScope === 'sampling'">
  <div class="sampling-method-section">
    <div class="sampling-method-label">抽样方式</div>
    <!-- 内容 -->
  </div>
</template>

<!-- 数据追加（条件显示） -->
<template v-if="qualityScope === 'full'">
  <div class="auto-append-section">
    <div class="auto-append-label">数据追加</div>
    <!-- 内容 -->
  </div>
</template>
```

样式保持一致（统一容器 + 统一标签）：

```css
/* 所有区块容器共用相同样式 */
.quality-count-section,
.sampling-method-section,
.auto-append-section {
  margin-top: 16px;
  padding: 16px 20px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fafafa;
}

/* 所有区块标签共用相同样式 */
.quality-count-label,
.sampling-method-label,
.auto-append-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 12px;
}
```

### 标签 + 开关在右上角

当区块顶部有标题和开关时，用 `justify-content: space-between` 将开关推到右上角，开关控制下方内容的显隐：

```vue
<div class="auto-append-section">
  <div class="auto-append-header">
    <div class="auto-append-label">数据追加</div>
    <a-switch v-model:checked="form.autoAppend" />
  </div>
  <div v-if="form.autoAppend" class="auto-append-content">
    <!-- 开关开启后才展示的内容 -->
  </div>
</div>
```

```css
.auto-append-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.auto-append-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
}

.auto-append-content {
  margin-top: 12px;
}
```

注意：使用此变体时，标签的 `margin-bottom` 应去掉（由 header 的 flex 布局控制间距）。

### 与卡片选择器联动
当区块可见性由卡片式 radio 选择器控制时，在每个区块的 `<template v-if>` 中检查选中值：

```vue
<!-- 卡片选择器 -->
<div class="scope-cards">
  <div class="scope-card" :class="{ active: scope === 'full' }" @click="scope = 'full'">...</div>
  <div class="scope-card" :class="{ active: scope === 'sampling' }" @click="scope = 'sampling'">...</div>
</div>

<!-- 条件区块 -->
<template v-if="scope === 'full'">
  <div class="auto-append-section">...</div>
</template>
<template v-if="scope === 'sampling'">
  <div class="sampling-method-section">...</div>
</template>
```

### 需要隐藏整个区域时
用 `v-if` 在容器层级直接控制（不额外套 `<template>`）：

```vue
<div v-if="recordType !== 'manual_upload'" class="quality-count-section">
  <div class="quality-count-label">质检数量</div>
  ...
</div>
```
