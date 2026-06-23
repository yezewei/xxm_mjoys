---
name: vue-mobile-dashboard
description: Vue 3 + Ant Design Vue 移动端看板页面：步骤条样式调整、统计卡片网格布局、任务卡片2列布局、常见问题弹窗、软电话状态指示器
source: auto-skill
extracted_at: '2026-06-23T12:10:26.199Z'
---

# 移动端看板页面开发

适用于电话工作台、每日拨测等移动端卡片式看板页面。

## 1. Steps 步骤条样式调整

### 问题：描述文案换行或超出屏幕

```vue
<a-steps :current="currentStep" size="small" class="daily-steps">
  <a-step title="步骤1" description="描述文案较长时需要特殊处理" />
  <a-step title="步骤2" description="确保文案完整显示不换行" />
</a-steps>
```

### 解决方案

```css
.daily-steps {
  overflow-x: auto;      /* 横向滚动 */
  overflow-y: hidden;
}

/* 步骤项自适应宽度 */
.daily-steps :deep(.ant-steps-item) {
  flex: 1 1 0;
  min-width: 0;
}

/* 描述文案不换行 */
.daily-steps :deep(.ant-steps-item-description) {
  font-size: 12px;
  white-space: nowrap !important;  /* 需要 !important 覆盖默认样式 */
}

/* 标题样式 */
.daily-steps :deep(.ant-steps-item-title) {
  font-size: 14px;
  font-weight: 600;
}
```

### 控制步骤状态

```typescript
// current = 0: 第一步显示数字1（当前步骤）
// current = 1: 第一步显示打钩，第二步显示数字2
const currentStep = ref(0)
```

## 2. 统计卡片网格布局

### 一行4个卡片

```vue
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-label">指标名称</div>
    <div class="stat-value">{{ value }}<span class="stat-unit">个</span></div>
  </div>
  <!-- 更多卡片... -->
  <div class="stat-card full-width">
    <!-- 最后一个卡片跨列显示 -->
  </div>
</div>
```

```css
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);  /* 4列布局 */
  gap: 12px;
}

.stat-card.full-width {
  grid-column: span 4;  /* 跨4列 */
}

/* 响应式调整 */
@media screen and (max-width: 480px) {
  .stats-grid {
    gap: 8px;
  }
  .stat-card {
    padding: 10px;
  }
  .stat-label {
    font-size: 11px;
  }
  .stat-value {
    font-size: 18px;
  }
}
```

## 3. 样式规范

| 元素 | 样式 |
|------|------|
| 页面背景 | #f5f7fa |
| 卡片背景 | #ffffff |
| 卡片圆角 | 10px |
| 卡片阴影 | 0 2px 8px rgba(0,0,0,0.06) |
| 主色 | #2b6ff2 |
| 标题文字 | #1a3a5c, 16px, font-weight: 600 |
| 辅助文字 | #8c9bab |

## 4. 任务卡片2列布局

### 待办任务卡片网格

```vue
<div class="task-list">
  <div v-for="task in todoTaskList" :key="task.id" class="task-card">
    <div class="task-name">{{ task.name }}</div>
    <div class="task-info">...</div>
    <div class="task-action">
      <a class="view-link">去查看</a>
    </div>
  </div>
</div>
```

```css
.task-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);  /* 2列布局 */
  gap: 12px;
}

.task-card {
  background: #fff;
  border: 1px solid #ebeef2;
  border-radius: 10px;
  padding: 14px;
  cursor: pointer;
}

.task-card:hover {
  border-color: #2b6ff2;
  box-shadow: 0 4px 12px rgba(43, 111, 242, 0.15);
}
```

## 5. 常见问题弹窗 (FAQ)

### 数据结构

```typescript
interface FaqItem {
  question: string
  possibleCauses: string[]  // 可能原因列表
  solutions: string[]        // 排查方案列表
}
```

### 模板结构

```vue
<!-- FAQ列表 -->
<div class="faq-list">
  <div v-for="(faq, index) in faqList" :key="index" class="faq-item" @click="handleFaqClick(faq)">
    <div class="faq-header">
      <QuestionCircleOutlined class="faq-icon" />
      <span class="faq-question">{{ faq.question }}</span>
      <RightOutlined class="faq-arrow" />
    </div>
  </div>
</div>

<!-- FAQ详情弹窗 -->
<a-modal v-model:open="faqModalVisible" :title="currentFaq?.question" :footer="null" width="600px">
  <div class="faq-modal-content" v-if="currentFaq">
    <div class="faq-section">
      <div class="faq-section-title">可能原因：</div>
      <ul class="faq-list-items">
        <li v-for="(cause, index) in currentFaq.possibleCauses" :key="index">{{ cause }}</li>
      </ul>
    </div>
    <div class="faq-section">
      <div class="faq-section-title">排查方案：</div>
      <ol class="faq-list-items solutions">
        <li v-for="(solution, index) in currentFaq.solutions" :key="index">{{ solution }}</li>
      </ol>
    </div>
  </div>
</a-modal>
```

### 样式

```css
.faq-item {
  background: #f8fafc;
  border-radius: 8px;
  padding: 12px 14px;
  cursor: pointer;
}

.faq-item:hover {
  background: #e6f0ff;
}

.faq-section-title {
  font-size: 14px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 12px;
}

.faq-list-items li {
  font-size: 13px;
  color: #3d4a5c;
  line-height: 1.8;
}
```

## 6. 软电话状态指示器 (Layout顶栏)

### 模板结构

```vue
<!-- 顶部菜单栏中的软电话状态 -->
<a-popover placement="bottomRight" trigger="click">
  <template #content>
    <div class="soft-phone-info">
      <div class="info-item">
        <span class="info-label">分机号：</span>
        <span class="info-value">{{ softPhoneInfo.extension }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">本机IP：</span>
        <span class="info-value">{{ softPhoneInfo.ip }}</span>
      </div>
    </div>
  </template>
  <div class="soft-phone-status" :class="{ 'connected': softPhoneConnected }">
    <PhoneOutlined />
    <span class="status-text">{{ softPhoneConnected ? '已连接' : '未连接' }}</span>
  </div>
</a-popover>
```

### 数据

```typescript
const softPhoneConnected = ref(false)
const softPhoneInfo = ref({
  extension: '1001',
  ip: '192.168.1.100'
})
```

### 样式

```css
.soft-phone-status {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 16px;
  background: #fff2f0;      /* 未连接：红色背景 */
  border: 1px solid #ffccc7;
  cursor: pointer;
  font-size: 13px;
  color: #ff4d4f;
}

.soft-phone-status.connected {
  background: #f6ffed;      /* 已连接：绿色背景 */
  border-color: #b7eb8f;
  color: #52c41a;
}

.soft-phone-info {
  min-width: 180px;
}
```

## 7. 页面结构

```
page-header        → 标题 + 步骤条
section-container  → 今日统计（4列网格）
section-container  → 我的待办（任务卡片2列布局）
section-container  → 常见问题排查（FAQ列表 + 弹窗详情）
```

## 8. 组件依赖

- Ant Design Vue: Steps, Modal, Popover
- 图标: PhoneOutlined, SyncOutlined, QuestionCircleOutlined, RightOutlined
