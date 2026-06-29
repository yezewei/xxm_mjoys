---
name: vue-card-radio-selector
description: Vue 3 + Ant Design Vue 中将 a-radio-group 替换为卡片式选择器，支持单选高亮、对勾标记、hover 状态，含紧凑模式变体
source: auto-skill
extracted_at: '2026-06-29T10:15:00.000Z'
---

# 卡片式单选选择器

将 `a-radio-group` 替换为可视化的卡片选择器，适用于需要突出显示选项的场景（如录音类型、质检范围等）。

## 适用场景

- 选项数量少（2~4个），需要更直观的视觉选择
- 选项有简短标题，可能带描述文案
- 需要突出当前选中状态

## 变体一：标准卡片（带描述）

用于主要功能选择，如质检范围。

### Template 结构

```html
<div class="scope-cards">
  <div
    class="scope-card"
    :class="{ active: form.qualityScope === 'full' }"
    @click="form.qualityScope = 'full'"
  >
    <div class="scope-card-info">
      <div class="scope-card-title">全量质检</div>
      <div class="scope-card-desc">对符合条件的全部数据进行质检</div>
    </div>
    <check-circle-filled v-if="form.qualityScope === 'full'" class="scope-card-check" />
  </div>
</div>
```

### CSS

```css
.scope-cards {
  display: flex;
  gap: 12px;
}

.scope-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  border: 2px solid #e8e8e8;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #fff;
  position: relative;
}

.scope-card:hover {
  border-color: #91caff;
  background: #f0f7ff;
}

.scope-card.active {
  border-color: #1677ff;
  background: #e6f4ff;
  box-shadow: 0 0 0 1px rgba(22, 119, 255, 0.1);
}

.scope-card-info {
  flex: 1;
}

.scope-card-title {
  font-size: 14px;
  color: #595959;
  line-height: 1.4;
}

.scope-card.active .scope-card-title {
  color: #1677ff;
  font-weight: 600;
}

.scope-card-desc {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
}

.scope-card-check {
  font-size: 18px;
  color: #1677ff;
}
```

## 变体二：紧凑卡片（无描述）

用于辅助选项选择，如录音类型，空间有限时使用。

### Template 结构

```html
<div class="record-type-section">
  <div
    class="record-type-card"
    :class="{ active: form.recordType === 'ai_assisted' }"
    @click="form.recordType = 'ai_assisted'"
  >
    人机协同录音
    <check-circle-filled v-if="form.recordType === 'ai_assisted'" class="record-type-check" />
  </div>
  <div
    class="record-type-card"
    :class="{ active: form.recordType === 'manual_outbound' }"
    @click="form.recordType = 'manual_outbound'"
  >
    人工外呼录音
    <check-circle-filled v-if="form.recordType === 'manual_outbound'" class="record-type-check" />
  </div>
</div>
```

### CSS

```css
.record-type-section {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.record-type-card {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 8px 16px;
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #fff;
  font-size: 13px;
  color: #595959;
}

.record-type-card:hover {
  border-color: #91caff;
  color: #1677ff;
}

.record-type-card.active {
  border-color: #1677ff;
  color: #1677ff;
  background: #f0f7ff;
}

.record-type-check {
  font-size: 14px;
  color: #1677ff;
}
```

## 选择建议

| 场景 | 使用变体 | 原因 |
|------|----------|------|
| 主要功能选择（质检范围） | 标准卡片 | 需要描述说明，视觉权重高 |
| 辅助选项（录音类型） | 紧凑卡片 | 节省空间，快速选择 |
| 选项 ≤ 2 个 | 紧凑卡片 | 无需大卡片 |
| 选项 3~4 个 | 标准卡片 | 防止拥挤 |

## 关键点

- **无图标设计**：卡片仅含标题（+可选描述），不使用图标，保持简洁
- **选中状态三重反馈**：边框变蓝（`border-color: #1677ff`）、背景变浅蓝（`background: #e6f4ff`）、对勾（`CheckCircleFilled`）
- **hover 状态**：边框变浅蓝 + 背景变浅，暗示可点击
- **不依赖 a-radio-group**：直接用 `@click` 绑定值，`:class` 控制 active 状态
- **图标导入**：需要从 `@ant-design/icons-vue` 导入 `CheckCircleFilled`
