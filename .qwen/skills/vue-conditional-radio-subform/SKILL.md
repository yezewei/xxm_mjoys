---
name: vue-conditional-radio-subform
description: Vue 3 + Ant Design Vue 中带 Tooltip 提示的横向单选组，根据选中值动态展示条件子表单（输入框、单选等）
source: auto-skill
extracted_at: '2026-06-16T08:24:48.412Z'
---

# 带条件子表单的单选组

当需要一个 radio group，每个选项旁边有 tooltip 帮助说明，并且根据选中值动态展示不同的子配置表单时，按以下步骤实现。

## 1. 响应式数据

在 `reactive()` 中定义主选字段及各子表单字段：

```ts
const form = reactive({
  mainOption: 'option-a' as 'option-a' | 'option-b' | 'option-c',
  // 子表单字段
  subInput: '默认提示语',       // 对应 option-a 的输入框
  subRadio: 'value-x' as 'value-x' | 'value-y', // 对应 option-b/option-c 的单选
});
```

> 子表单字段提前定义，切换选项时不会丢失已填内容。

## 2. 模板结构

### 2.1 横向带 Tooltip 的 Radio Group

用 `a-radio-group` 包裹，内部用 flex 布局横向排列，每个 radio 旁放 `a-tooltip` + `question-circle-outlined` 图标：

```html
<a-radio-group v-model:value="form.mainOption">
  <div class="conditional-radio-list">
    <div class="conditional-radio-item">
      <a-radio value="option-a">选项A</a-radio>
      <a-tooltip placement="topLeft" overlay-class-name="option-tooltip">
        <template #title>
          <div class="tooltip-content">选项A的详细说明文案……</div>
        </template>
        <question-circle-outlined class="option-help-icon" />
      </a-tooltip>
    </div>
    <!-- 更多选项... -->
  </div>
</a-radio-group>
```

### 2.2 条件子表单

在 radio-group 关闭后、form-item 内部，用 `v-if` 根据选中值展示对应子配置：

```html
<!-- 输入框子表单 -->
<div v-if="form.mainOption === 'option-a'" class="sub-setting-card">
  <a-form-item label="提示语：" class="required-label" style="margin-bottom: 0;">
    <a-input v-model:value="form.subInput" placeholder="请输入" style="width: 400px;" />
  </a-form-item>
</div>

<!-- 单选子表单 -->
<div v-if="form.mainOption === 'option-b' || form.mainOption === 'option-c'" class="sub-setting-card">
  <a-form-item label="介入方式：" style="margin-bottom: 0;">
    <a-radio-group v-model:value="form.subRadio">
      <a-radio value="value-x">等AI说完当前话术再接入</a-radio>
      <a-radio value="value-y">坐席接通后立即接管通话</a-radio>
    </a-radio-group>
  </a-form-item>
</div>
```

## 3. 样式

```css
/* 横向排列 */
.conditional-radio-list {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 12px 24px;
  margin: 8px 0;
}

.conditional-radio-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.conditional-radio-item .ant-radio-wrapper {
  font-size: 14px;
  color: #595959;
  line-height: 1.5;
}

/* 帮助图标 */
.option-help-icon {
  color: #8c8c8c;
  font-size: 14px;
  cursor: help;
  flex-shrink: 0;
}

.option-help-icon:hover {
  color: #1890ff;
}

/* 子配置卡片 */
.sub-setting-card {
  margin-top: 16px;
  padding: 16px;
  background: #fafafa;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
}
```

## 4. Tooltip 全局样式

Tooltip 渲染在组件外部，scoped 样式不生效，需额外添加非 scoped 的 `<style>` 块：

```html
<style>
.option-tooltip .ant-tooltip-inner {
  max-width: 420px;
  font-size: 13px;
  line-height: 1.8;
  color: #fff;
}

.option-tooltip .tooltip-content {
  white-space: normal;
  word-break: break-all;
}
</style>
```

## 5. 文案优化要点

- 子表单的 label 用「方式」「规则」等词让用户明确知道在配置什么行为。
- radio 选项文案要体现**用户视角的动作结果**，而非技术术语。例如：
  - ❌「即时介入」→ ✅「坐席接通后立即接管通话」
  - ❌「AI播放完当前话术」→ ✅「等AI说完当前话术再接入」
- tooltip 说明文案要完整描述触发条件 → 系统行为 → 异常兜底，让用户清楚每种模式的完整流程。
