---
name: vue-mobile-workbench
description: 移动端工作台页面：顶部统计卡片、场景筛选、任务卡片列表、底部操作栏，适配移动端交互
source: auto-skill
extracted_at: '2026-07-09T07:00:00.000Z'
---

# 移动端工作台页面开发

适用于将桌面端工作台改造为移动端任务管理页面。

## 1. 页面结构

```
stats-section      → 顶部统计卡片（4个指标）
filter-section     → 场景筛选区域（场景选择、状态标签、时间范围）
task-section       → 任务列表（卡片式布局）
bottom-bar         → 底部操作栏（固定定位）
```

## 2. 顶部统计卡片

### 背景渐变 + 4列网格

```vue
<div class="stats-section">
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-label">今日待跟进</div>
      <div class="stat-value">{{ stats.todayPending }}</div>
    </div>
    <div class="stat-card">
      <div class="stat-label">今日已完成</div>
      <div class="stat-value completed">{{ stats.todayCompleted }}</div>
    </div>
    <!-- 更多卡片... -->
  </div>
</div>
```

```css
.stats-section {
  padding: 16px;
  background: linear-gradient(135deg, #2b6ff2 0%, #1a5cd6 100%);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  padding: 14px;
  backdrop-filter: blur(10px);
}

.stat-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.85);
  margin-bottom: 8px;
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #fff;
}

.stat-value.completed {
  color: #b7eb8f;
}
```

## 3. 场景筛选区域

### 场景选择 + 状态标签 + 时间范围

```vue
<div class="filter-section">
  <div class="filter-header">
    <div class="filter-title">
      <FilterOutlined />
      <span>场景筛选</span>
    </div>
    <a-button type="link" size="small" @click="handleResetFilter">
      <ReloadOutlined /> 重置
    </a-button>
  </div>

  <!-- 场景选择 -->
  <div class="filter-item">
    <div class="filter-label">选择场景</div>
    <a-select v-model:value="selectedSceneId" placeholder="请选择场景" style="width: 100%">
      <a-select-option v-for="scene in sceneList" :key="scene.id" :value="scene.id">
        {{ scene.name }}
      </a-select-option>
    </a-select>
  </div>

  <!-- 跟进状态筛选 -->
  <div class="filter-item">
    <div class="filter-label">跟进状态</div>
    <div class="status-tags">
      <div
        v-for="status in followStatusList"
        :key="status.value"
        class="status-tag"
        :class="{ active: filterForm.followStatus === status.value }"
        @click="handleStatusSelect(status.value)"
      >
        {{ status.label }}
      </div>
    </div>
  </div>

  <!-- 时间范围筛选 -->
  <div class="filter-item">
    <div class="filter-label">时间范围</div>
    <a-segmented v-model:value="selectedTimeRange" :options="timeRangeOptions" block />
  </div>
</div>
```

```css
.filter-section {
  margin: 16px;
  background: #fff;
  border-radius: 10px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.filter-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #1a3a5c;
}

.filter-item {
  margin-bottom: 16px;
}

.filter-item:last-child {
  margin-bottom: 0;
}

.filter-label {
  font-size: 13px;
  color: #8c9bab;
  margin-bottom: 8px;
}

.status-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.status-tag {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 13px;
  color: #3d4a5c;
  background: #f5f7fa;
  cursor: pointer;
  transition: all 0.2s;
}

.status-tag.active {
  background: #e6f0ff;
  color: #2b6ff2;
  font-weight: 500;
}
```

## 4. 任务卡片列表

### 卡片式布局 + 信息行 + 底部操作

```vue
<div class="task-list">
  <div v-for="task in filteredTaskList" :key="task.id" class="task-card" @click="handleTaskClick(task)">
    <div class="task-card-header">
      <div class="customer-name">{{ task.customerName }}</div>
      <a-tag :color="getFollowStatusColor(task.followResult)" size="small">
        {{ task.followResult }}
      </a-tag>
    </div>

    <div class="task-card-body">
      <div class="info-row">
        <PhoneOutlined class="info-icon" />
        <span class="info-value">{{ task.phone }}</span>
      </div>
      <div class="info-row">
        <ClockCircleOutlined class="info-icon" />
        <span class="info-value">分配时间：{{ task.lastAssignTime }}</span>
      </div>
      <div class="info-row" v-if="task.aiUserType">
        <RobotOutlined class="info-icon" />
        <span class="info-value">AI分类：{{ task.aiUserType }}</span>
      </div>
    </div>

    <div class="task-card-footer">
      <div class="footer-tags">
        <a-tag v-if="task.isManualReach === '是'" color="green" size="small">已人工触达</a-tag>
        <a-tag v-if="task.isManualCall === '是'" color="blue" size="small">已人工外呼</a-tag>
      </div>
      <div class="footer-actions">
        <a-button type="primary" size="small" @click.stop="handleFollow(task)">去跟进</a-button>
        <a-button size="small" @click.stop="handleCall(task)">呼叫</a-button>
      </div>
    </div>
  </div>
</div>
```

```css
.task-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-card {
  background: #fff;
  border-radius: 10px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.2s;
}

.task-card:active {
  transform: scale(0.98);
}

.task-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.customer-name {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a5c;
}

.task-card-body {
  margin-bottom: 12px;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-icon {
  color: #8c9bab;
  font-size: 14px;
}

.info-value {
  font-size: 13px;
  color: #3d4a5c;
}

.task-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #f0f2f5;
}

.footer-tags {
  display: flex;
  gap: 6px;
}

.footer-actions {
  display: flex;
  gap: 8px;
}
```

## 5. 底部操作栏

### 固定定位 + 安全区域适配

```vue
<div class="bottom-bar">
  <div class="bottom-bar-inner">
    <div class="bar-item" @click="handleBatchExport">
      <ExportOutlined />
      <span>导出</span>
    </div>
    <div class="bar-item" @click="handleBatchAssign">
      <TeamOutlined />
      <span>分配</span>
    </div>
    <div class="bar-item" @click="handleBatchSms">
      <MessageOutlined />
      <span>短信</span>
    </div>
    <div class="bar-item" @click="handleRefresh">
      <ReloadOutlined />
      <span>刷新</span>
    </div>
  </div>
</div>
```

```css
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.06);
  z-index: 100;
  padding: 8px 0;
  padding-bottom: calc(8px + env(safe-area-inset-bottom));
}

.bottom-bar-inner {
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.bar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 8px 16px;
  cursor: pointer;
  color: #3d4a5c;
  font-size: 12px;
  transition: all 0.2s;
}

.bar-item:active {
  color: #2b6ff2;
}

.bar-item .anticon {
  font-size: 20px;
}
```

## 6. 空状态

```vue
<div v-if="filteredTaskList.length === 0" class="empty-state">
  <InboxOutlined class="empty-icon" />
  <div class="empty-text">暂无任务数据</div>
  <div class="empty-hint">请调整筛选条件或选择其他场景</div>
</div>
```

```css
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.empty-icon {
  font-size: 48px;
  color: #d9d9d9;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 16px;
  color: #8c9bab;
  margin-bottom: 8px;
}

.empty-hint {
  font-size: 13px;
  color: #bfbfbf;
}
```

## 7. 样式规范

| 元素 | 样式 |
|------|------|
| 页面背景 | #f5f7fa |
| 统计区域背景 | linear-gradient(135deg, #2b6ff2 0%, #1a5cd6 100%) |
| 卡片背景 | #ffffff |
| 卡片圆角 | 10px |
| 卡片阴影 | 0 2px 8px rgba(0,0,0,0.06) |
| 主色 | #2b6ff2 |
| 标题文字 | #1a3a5c, 16px, font-weight: 600 |
| 辅助文字 | #8c9bab |
| 正文文字 | #3d4a5c, 13px |

## 8. 组件依赖

- Ant Design Vue: Select, Segmented, Tag, Button
- 图标: FilterOutlined, ReloadOutlined, PhoneOutlined, ClockCircleOutlined, RobotOutlined, InboxOutlined, ExportOutlined, TeamOutlined, MessageOutlined

## 9. 响应式适配

```css
@media screen and (max-width: 360px) {
  .stats-grid {
    gap: 8px;
  }

  .stat-card {
    padding: 10px;
  }

  .stat-value {
    font-size: 24px;
  }

  .filter-section {
    margin: 12px;
    padding: 12px;
  }

  .task-section {
    margin: 12px;
  }
}
```
