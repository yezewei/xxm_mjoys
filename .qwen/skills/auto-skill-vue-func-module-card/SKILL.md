---
name: vue-func-module-card
description: Vue 3 设置页功能模块卡片布局：标题 + 开关/按钮 + 描述文案的上下结构，支持条件子选项
source: auto-skill
extracted_at: '2026-06-25T03:13:41.366Z'
---

# 功能模块卡片布局（设置页）

适用于系统配置/全局设置页面，每个功能模块采用"功能标题 + 开关/按钮 + 描述文案"的上下结构。

## 适用场景

- 系统全局配置页、功能开关管理页
- 每个模块独立，不使用表单网格（a-row/a-col），而是纵向堆叠
- 模块内包含：标题、描述、主控件（开关/按钮）、可选的子选项区域

## Template 结构

```html
<!-- 按钮型模块（如手动触发同步） -->
<div class="func-module">
  <div class="func-module-header">
    <div class="func-module-info">
      <h3 class="func-module-title">报表引擎维度同步</h3>
      <p class="func-module-desc">手动同步场景、批次、机构、坐席等基础维度数据，用于修复报表统计数据缺失。</p>
    </div>
    <a-button type="primary" :loading="syncing" @click="handleSync">
      <sync-outlined />
      立即同步
    </a-button>
  </div>
</div>

<!-- 开关型模块（无子选项） -->
<div class="func-module">
  <div class="func-module-header">
    <div class="func-module-info">
      <h3 class="func-module-title">全局导出限制功能</h3>
      <p class="func-module-desc">开启后，仅在工作时间允许导出数据，且单次导出最多选择 31 天。</p>
    </div>
    <a-switch v-model:checked="form.exportLimit" checked-children="开" un-checked-children="关" />
  </div>
</div>

<!-- 开关型模块（带条件子选项） -->
<div class="func-module">
  <div class="func-module-header">
    <div class="func-module-info">
      <h3 class="func-module-title">虚拟号查询真实号码展示</h3>
      <p class="func-module-desc">开启后，坐席在跟进页面查看客户时，系统自动查询真实号码并展示。</p>
    </div>
    <a-switch v-model:checked="form.showRealNumber" checked-children="开" un-checked-children="关" />
  </div>
  <!-- 开关开启时展示子选项 -->
  <div v-if="form.showRealNumber" class="func-module-body">
    <div class="sub-option-row">
      <span class="sub-option-label">展示方式：</span>
      <a-radio-group v-model:value="form.displayMode">
        <a-radio value="fixedMask">固定脱敏展示</a-radio>
        <a-radio value="permissionMask">按脱敏权限展示</a-radio>
      </a-radio-group>
    </div>
  </div>
</div>
```

## CSS

```css
.func-module {
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 20px 24px;
  margin-bottom: 12px;
}

.func-module:last-of-type {
  margin-bottom: 0;
}

.func-module-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.func-module-info {
  flex: 1;
  margin-right: 24px;
}

.func-module-title {
  font-size: 15px;
  font-weight: 600;
  color: #1f2329;
  margin: 0 0 6px 0;
}

.func-module-desc {
  font-size: 13px;
  color: #8f959e;
  margin: 0;
  line-height: 1.6;
}

/* 条件子选项区域（开关开启后展示） */
.func-module-body {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.sub-option-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.sub-option-label {
  font-size: 13px;
  color: #595959;
  flex-shrink: 0;
}
```

## 关键点

- **不用 a-row/a-col 网格**：每个模块是独立的纵向卡片，标题+描述在左、控件在右
- **`func-module-header` 用 flex 布局**：左侧 `.func-module-info`（flex:1）占满剩余空间，右侧控件固定宽度
- **子选项用 `v-if` 条件渲染**：依赖主开关状态，开关关闭时不渲染子选项区域
- **`func-module-body` 用 `border-top` 分隔**：与主开关区域视觉区分
- **模块间距用 `margin-bottom: 12px`**，最后一个模块用 `:last-of-type` 去除底边距
- **按钮型模块**（如手动同步）：按钮带 `:loading` 状态，点击后异步操作完成再提示
- 描述文案保持简洁，说明功能作用和影响范围即可
