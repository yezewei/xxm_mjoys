<template>
  <div class="quality-home-page">
    <!-- 今日统计 -->
    <a-card class="statistics-card">
      <div class="section-header">
        <BookOutlined class="section-icon" />
        <span class="section-title">今日统计</span>
      </div>
      <div class="stats-list">
        <div class="stat-item">
          <div class="stat-label">我的质检任务</div>
          <div class="stat-value">
            <span class="stat-number">{{ stats.myTasks }}</span>
            <span class="stat-unit">个</span>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-label">智能质检任务</div>
          <div class="stat-value">
            <span class="stat-number">{{ stats.aiTasks }}</span>
            <span class="stat-unit">个</span>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-label">人工质检任务</div>
          <div class="stat-value">
            <span class="stat-number">{{ stats.manualTasks }}</span>
            <span class="stat-unit">个</span>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-label">今日已质检通话</div>
          <div class="stat-value">
            <span class="stat-number">{{ stats.todayChecked }}</span>
            <span class="stat-unit">条</span>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-label">当前已质检通话</div>
          <div class="stat-value">
            <span class="stat-number">{{ stats.currentChecked }}</span>
            <span class="stat-unit">条</span>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-label">剩余待质检通话</div>
          <div class="stat-value">
            <span class="stat-number highlight">{{ stats.remaining }}</span>
            <span class="stat-unit">条</span>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-label">质检完成度</div>
          <div class="stat-value">
            <span class="stat-number">{{ stats.completionRate }}</span>
            <span class="stat-unit">%</span>
          </div>
        </div>
      </div>
    </a-card>

    <!-- 今日待办 -->
    <a-card class="todo-card">
      <div class="section-header">
        <BookOutlined class="section-icon" />
        <span class="section-title">今日待办</span>
      </div>
      <div class="todo-list">
        <div
          v-for="task in todoList"
          :key="task.id"
          class="todo-item"
        >
          <div class="todo-content">
            <div class="todo-header">
              <span class="todo-title">{{ task.name }}</span>
              <span class="todo-type">
                <RobotOutlined class="type-icon" />
                {{ task.type }}
              </span>
              <a-tag :color="task.status === '已暂停' ? 'orange' : 'blue'" class="status-tag">
                {{ task.status }}
              </a-tag>
            </div>
            <div class="todo-footer">
              <div class="todo-info">
                <span class="pending-count">
                  目前有<em class="highlight-number">{{ task.pendingCount }}</em>个待处理通话
                </span>
                <span class="progress-text">
                  审核进度{{ task.progress }}/{{ task.totalCount }} {{ task.progressPercent }}%
                </span>
              </div>
              <a-button class="handle-btn" @click="handleTask(task)">
                去处理
              </a-button>
            </div>
          </div>
        </div>
        <a-empty v-if="todoList.length === 0" description="暂无待办任务" />
      </div>
    </a-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import {
  BookOutlined,
  RobotOutlined
} from '@ant-design/icons-vue'

const router = useRouter()

// 统计数据
const stats = ref({
  myTasks: 1,
  aiTasks: 1,
  manualTasks: 0,
  todayChecked: 0,
  currentChecked: 0,
  remaining: 265,
  completionRate: 0
})

// 待办任务列表
const todoList = ref([
  {
    id: 27,
    name: 'test2026.2.9__19:20',
    type: 'AI 质检',
    status: '已暂停',
    pendingCount: 265,
    progress: 0,
    totalCount: 265,
    progressPercent: 0
  }
])

// 处理任务
const handleTask = (task: typeof todoList.value[0]) => {
  console.log('处理任务:', task)
  // 跳转到质检工作台
  router.push('/quality-workbench')
}
</script>

<style scoped>
.quality-home-page {
  padding: 24px;
  background-color: #f5f7fb;
  min-height: 100vh;
}

/* 卡片通用样式 */
.statistics-card,
.todo-card {
  margin-bottom: 16px;
  border-radius: 4px;
}

/* 章节标题 */
.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.section-icon {
  font-size: 18px;
  color: #1677ff;
  margin-right: 8px;
}

.section-title {
  font-size: 14px;
  font-weight: 500;
  color: #1f2329;
}

/* 统计卡片 */
.stats-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0px;
}

.stat-item {
  background: #f5f7fa;
  border-radius: 4px;
  padding: 16px 20px;
  text-align: left;
  white-space: nowrap;
  width: 150px;
  height: 100px;
  margin-right: 10px;
  margin-bottom: 10px;
}

.stat-label {
  font-size: 14px;
  color: #8f959e;
  margin-bottom: 12px;
}

.stat-value {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.stat-number {
  font-size: 20px;
  font-weight: 600;
  color: #1f2329;
}

.stat-number.highlight {
  color: #1677ff;
}

.stat-unit {
  font-size: 12px;
  color: #8f959e;
}

/* 待办列表 */
.todo-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.todo-item {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 20px;
  transition: all 0.3s;
  width: calc(50% - 8px);
}

.todo-item:hover {
  border-color: #1677ff;
  box-shadow: 0 2px 8px rgba(22, 119, 255, 0.1);
}

.todo-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.todo-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.todo-title {
  font-size: 16px;
  font-weight: 500;
  color: #1f2329;
}

.todo-type {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #595959;
}

.type-icon {
  font-size: 16px;
  color: #1677ff;
}

.status-tag {
  border-radius: 2px;
  font-size: 12px;
  padding: 2px 8px;
}

.todo-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.todo-info {
  display: flex;
  align-items: center;
  gap: 24px;
}

.pending-count {
  font-size: 14px;
  color: #595959;
}

.pending-count em {
  font-style: normal;
  font-weight: 500;
  color: #ff7a45;
}

.progress-text {
  font-size: 14px;
  color: #8f959e;
}

.handle-btn {
  color: #1677ff;
  border-color: #1677ff;
  background: #fff;
}

.handle-btn:hover {
  color: #4096ff;
  border-color: #4096ff;
  background: #fff;
}

/* 空状态 */
:deep(.ant-empty) {
  margin: 20px 0;
}

:deep(.ant-empty-description) {
  color: #8f959e;
}
</style>
