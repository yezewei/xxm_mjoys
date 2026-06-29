---
name: vue-inline-sentence-form
description: Vue 3 + Ant Design Vue 中将表单配置项嵌入自然语言语句，用选择器/时间选择器等控件替换关键词，形成一行可读的配置说明
source: auto-skill
extracted_at: '2026-06-29T09:31:43.307Z'
---

# 内嵌语句式表单配置

## 场景
表单配置项不适合传统的"标签 + 输入框"网格布局，而是需要嵌入一句自然语言中，用控件替换关键词，让配置意图一目了然。适用于定时任务、数据追加规则、筛选条件描述等场景。

## 典型效果
```
每天 [08:00] 点查询 [昨天] [00:00] ~ [当天] [23:59] 时间段内满足条件的数据加入质检任务
```
其中 `[...]` 部分是可交互的表单控件。

## 做法

### 1. 模板结构
用 `flex` 容器将文字和控件交错排列，`gap` 控制间距：

```vue
<div class="auto-append-sentence">
  每天
  <a-time-picker v-model:value="form.execTime" format="HH:mm" :placeholder="'执行时间'" style="width: 100px" />
  点查询
  <a-select v-model:value="form.startType" style="width: 70px">
    <a-select-option value="today">当天</a-select-option>
    <a-select-option value="yesterday">昨天</a-select-option>
  </a-select>
  <a-time-picker v-model:value="form.rangeStart" format="HH:mm" :placeholder="'开始时间'" style="width: 100px" />
  ~
  <a-select v-model:value="form.endType" style="width: 70px">
    <a-select-option value="today">当天</a-select-option>
    <a-select-option value="yesterday">昨天</a-select-option>
  </a-select>
  <a-time-picker v-model:value="form.rangeEnd" format="HH:mm" :placeholder="'结束时间'" style="width: 100px" />
  时间段内满足条件的数据加入任务
</div>
```

### 2. CSS
关键是 `display: flex` + `align-items: center` + `gap` + `flex-wrap`，让文字和控件在同一行内自然排列：

```css
.inline-sentence {
  font-size: 14px;
  color: #262626;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px;
  line-height: 32px;
}
```

### 3. 配套边框容器
语句通常放在带标签的边框容器内，开关控制显隐：

```vue
<div class="config-section">
  <div class="config-header">
    <div class="config-label">数据追加</div>
    <a-switch v-model:checked="form.autoAppend" />
  </div>
  <div v-if="form.autoAppend" class="config-content">
    <div class="inline-sentence">
      每天 <a-time-picker ... /> 点查询 ...
    </div>
  </div>
</div>
```

```css
.config-section {
  margin-top: 16px;
  padding: 16px 20px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fafafa;
}

.config-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.config-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
}

.config-content {
  margin-top: 12px;
}
```

## 关键点

- **不要用 a-form + a-form-item**：语句式布局不需要传统的表单标签，直接用 flex 排列即可
- **控件宽度固定**：每个控件用 `style="width: Npx"` 固定宽度，避免文字挤压变形
- **纯文字用裸文本节点**：不需要 `<span>` 包裹，直接写在 div 内
- **`flex-wrap: wrap`**：当一行放不下时自动换行，移动端友好
- **`line-height: 32px`**：与 Ant Design Vue 控件高度对齐（默认 32px）
- **`gap: 4px`**：文字和控件之间保持紧凑但不粘连

## 适用场景

- 定时任务配置（每天X点执行）
- 数据追加规则（查询Y~Z时间段的数据）
- 筛选条件描述（当字段等于/包含/大于某值时）
- 通知规则（当事件发生时发送到渠道）
- 任何需要用自然语言表达的复合配置
