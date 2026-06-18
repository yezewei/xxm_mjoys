---
name: vue-cross-tab-navigate
description: Vue 3 子组件中表单项以提示文案替代输入控件，点击链接跳转到同页面另一个 Tab 页签
source: auto-skill
extracted_at: '2026-06-16T10:56:51.418Z'
---

# Vue 3 表单项提示跳转至另一 Tab

## 场景

在多 Tab 页面中，某个 Tab 下的表单项不再需要用户直接编辑，而是提示用户前往另一个 Tab 配置。需要将输入控件替换为提示文案 + 可点击链接，点击后自动切换到目标 Tab。

## 步骤

### 1. 子组件：替换输入控件为提示文案

将原来的 `<a-input>` 等输入控件替换为带链接的提示文案：

```vue
<!-- 呼通即转：转接提示语 -->
<div v-if="systemSettingsForm.transferCondition === 'auto-transfer'" class="transfer-sub-setting">
  <a-form-item label="转接提示语配置项：" class="required-label" style="margin-bottom: 0;">
    <span class="form-tip">
      提示：请在
      <a class="link-text" @click.prevent="handleGoToFallbackSetting">流程兜底设置</a>
      中配置转接提示语文案，并上传对应录音
    </span>
  </a-form-item>
</div>
```

关键点：
- 使用 `@click.prevent` 阻止默认跳转行为
- 复用已有的 `.link-text` 和 `.form-tip` 样式类
- 如果原字段不再使用，从 `reactive` 数据中移除该字段

### 2. 子组件：添加 emit 事件

在 `defineEmits` 中声明新事件：

```ts
const emit = defineEmits<{
  // ...已有事件
  (e: 'go-to-fallback-setting'): void;
}>();
```

### 3. 子组件：添加跳转方法

```ts
const handleGoToFallbackSetting = () => {
  emit('go-to-fallback-setting');
};
```

### 4. 父组件：监听事件

在所有使用该子组件的父组件中绑定事件：

```vue
<SystemSettingsTab
  @save="handleSystemSettingsSave"
  @back="handleSystemSettingsBack"
  @go-to-fallback-setting="handleGoToFallbackSetting"
/>
```

> ⚠️ 注意检查所有使用该子组件的父组件（grep 搜索组件名），每个都要绑定事件。

### 5. 父组件：添加 Tab 切换方法

```ts
const handleGoToFallbackSetting = () => {
  activeTabKey.value = 'fallback'; // 目标 Tab 的 key
};
```

## 注意事项

- 如果同一子组件被多个父组件使用（如 SceneTemplateDetail.vue 和 SceneDetail.vue），每个父组件都需要绑定事件并添加处理方法
- 目标 Tab key 需要与 `<a-tab-pane key="fallback">` 中的 key 一致
- 使用 `@click.prevent` 而非 `href="#"` 可避免页面滚动到顶部
