---
name: vue-mobile-dashboard
description: Vue 3 + Ant Design Vue 移动端看板页面：全屏布局、统计卡片、任务列表、跟进弹窗、任务详情、电话沟通记录、对话弹窗
source: auto-skill
extracted_at: '2026-07-09T07:10:18.922Z'
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

## 8. 移动端页面全屏布局（不使用 Layout）

### 问题：移动端页面需要全屏显示，不使用顶部栏和左侧菜单

### 解决方案：在 App.vue 中判断路由，移动端页面直接渲染 router-view

```vue
<!-- App.vue -->
<template>
  <a-config-provider :theme="{...}">
    <!-- 移动端页面不使用 Layout -->
    <template v-if="isMobileRoute">
      <router-view />
    </template>
    <!-- 其他页面使用 Layout -->
    <template v-else>
      <Layout />
    </template>
  </a-config-provider>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import Layout from "./components/Layout.vue";

const route = useRoute()

// 判断是否为移动端路由
const isMobileRoute = computed(() => {
  return route.path === '/mobile' || route.path.startsWith('/mobile/')
})
</script>
```

### 路由配置

```typescript
// router.ts
{
  path: "/mobile",
  name: "MobileWorkbench",
  component: () => import("./pages/MobileWorkbench.vue"),
},
{
  path: "/mobile/task-detail/:id",
  name: "MobileTaskDetail",
  component: () => import("./pages/MobileTaskDetail.vue"),
},
```

## 9. 移动端任务卡片列表

### 单列卡片布局（适合移动端滑动）

```vue
<div class="task-list">
  <div
    v-for="task in taskList"
    :key="task.id"
    class="task-card"
    @click="handleTaskClick(task)"
  >
    <div class="task-card-header">
      <div class="customer-name">{{ task.customerName }}</div>
      <a-tag :color="getStatusColor(task.status)" size="small">
        {{ task.status }}
      </a-tag>
    </div>
    <div class="task-card-body">
      <div class="info-row">
        <PhoneOutlined class="info-icon" />
        <span class="info-value">{{ task.phone }}</span>
      </div>
      <div class="info-row">
        <ClockCircleOutlined class="info-icon" />
        <span class="info-value">{{ task.time }}</span>
      </div>
    </div>
    <div class="task-card-footer">
      <div class="footer-tags">
        <a-tag v-if="task.tag" color="blue" size="small">{{ task.tag }}</a-tag>
      </div>
      <div class="footer-actions">
        <a-button type="primary" size="small" @click.stop="handleAction(task)">
          操作
        </a-button>
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

.task-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #f0f2f5;
}
```

## 10. 移动端跟进弹窗

### 弹窗模板

```vue
<a-modal
  v-model:open="followModalVisible"
  title="填写跟进信息"
  :footer="null"
  :width="360"
>
  <div class="follow-form">
    <div class="form-item">
      <div class="form-label required">跟进结果</div>
      <a-radio-group v-model:value="followForm.followResult" button-style="solid">
        <a-radio-button value="持续跟进">持续跟进</a-radio-button>
        <a-radio-button value="明确转化">明确转化</a-radio-button>
        <a-radio-button value="明确拒绝">明确拒绝</a-radio-button>
      </a-radio-group>
    </div>

    <div class="form-item">
      <div class="form-label">跟进备注</div>
      <a-textarea
        v-model:value="followForm.remark"
        placeholder="请输入跟进备注"
        :rows="3"
        :maxlength="200"
        show-count
      />
    </div>

    <div class="form-item">
      <div class="form-label">是否加企微</div>
      <a-switch v-model:checked="followForm.addWechat" checked-children="是" un-checked-children="否" />
    </div>

    <div class="form-item" v-if="followForm.followResult === '持续跟进'">
      <div class="form-label required">下次跟进时间</div>
      <a-date-picker
        v-model:value="followForm.nextFollowTime"
        placeholder="请选择下次跟进时间"
        style="width: 100%"
        :disabled-date="disabledDate"
      />
    </div>

    <div class="form-actions">
      <a-button @click="followModalVisible = false">取消</a-button>
      <a-button type="primary" @click="handleSubmitFollow" :loading="followSubmitting">提交</a-button>
    </div>
  </div>
</a-modal>
```

### 数据结构

```typescript
interface FollowForm {
  followResult: string
  remark: string
  addWechat: boolean
  nextFollowTime: Dayjs | null
}

const followForm = reactive<FollowForm>({
  followResult: '持续跟进',
  remark: '',
  addWechat: false,
  nextFollowTime: null
})

const disabledDate = (current: Dayjs) => {
  return current && current < new Date(new Date().setHours(0, 0, 0, 0))
}
```

### 样式

```css
.follow-form .form-item {
  margin-bottom: 16px;
}

.follow-form .form-label {
  font-size: 13px;
  color: #3d4a5c;
  margin-bottom: 8px;
  font-weight: 500;
}

.follow-form .form-label.required::before {
  content: '*';
  color: #ff4d4f;
  margin-right: 4px;
}

.follow-form :deep(.ant-radio-group) {
  display: flex;
  width: 100%;
}

.follow-form :deep(.ant-radio-button-wrapper) {
  flex: 1;
  text-align: center;
  font-size: 13px;
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.form-actions .ant-btn {
  flex: 1;
}
```

## 11. 移动端任务详情页面

### 页面结构

```
detail-header       → 返回按钮 + 标题 + 操作按钮
customer-card       → 客户信息卡片（头像、姓名、电话、快捷操作）
stats-section       → 统计数据（4列网格）
info-section        → 基本信息列表
info-section        → 关联场景
info-section        → 跟进记录时间轴
bottom-bar          → 底部固定操作栏
```

### 顶部导航栏

```vue
<div class="detail-header">
  <div class="header-left" @click="handleBack">
    <LeftOutlined />
    <span>返回</span>
  </div>
  <div class="header-title">任务详情</div>
  <div class="header-right">
    <a-button type="primary" size="small" @click="handleFollow">
      去跟进
    </a-button>
  </div>
</div>
```

```css
.detail-header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}
```

### 客户信息卡片

```vue
<div class="customer-card">
  <div class="customer-header">
    <div class="customer-avatar">
      <span>{{ customerName?.charAt(0) || '客' }}</span>
    </div>
    <div class="customer-info">
      <div class="customer-name">{{ customerName }}</div>
      <div class="customer-phone">{{ phone }}</div>
    </div>
    <a-tag :color="getStatusColor(status)" class="status-tag">
      {{ status }}
    </a-tag>
  </div>
  <div class="customer-actions">
    <div class="action-item" @click="handleCall">
      <PhoneOutlined />
      <span>呼叫</span>
    </div>
    <div class="action-item" @click="handleSms">
      <MessageOutlined />
      <span>短信</span>
    </div>
    <div class="action-item" @click="handleCopy">
      <CopyOutlined />
      <span>复制</span>
    </div>
  </div>
</div>
```

```css
.customer-card {
  margin: 16px;
  background: linear-gradient(135deg, #2b6ff2 0%, #1a5cd6 100%);
  border-radius: 12px;
  padding: 20px;
  color: #fff;
}

.customer-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 600;
}

.customer-actions {
  display: flex;
  justify-content: space-around;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}
```

### 底部固定操作栏

```vue
<div class="bottom-bar">
  <div class="bottom-bar-inner">
    <a-button @click="handleBack" style="flex: 1">返回列表</a-button>
    <a-button type="primary" @click="handleFollow" style="flex: 1">去跟进</a-button>
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
  padding: 12px 16px;
  padding-bottom: calc(12px + env(safe-area-inset-bottom));
  z-index: 100;
}
```

## 12. 电话沟通记录展示

### 数据结构

```typescript
interface DialogItem {
  role: 'ai' | 'customer'
  content: string
  time: string
}

interface CallDetail {
  duration: string
  result: string
  recordingUrl: string
  dialogList: DialogItem[]
}

interface FollowRecord {
  id: number
  type: 'follow' | 'call'
  title: string
  time: string
  remark?: string
  addWechat?: boolean
  nextFollowTime?: string
  callDetail?: CallDetail
}
```

### 时间轴模板

```vue
<a-timeline v-if="followRecords.length">
  <a-timeline-item
    v-for="(record, index) in followRecords"
    :key="index"
    :color="getTimelineColor(record.type)"
  >
    <div class="timeline-item">
      <div class="timeline-header">
        <span class="timeline-title">{{ record.title }}</span>
        <span class="timeline-time">{{ record.time }}</span>
      </div>

      <!-- 电话沟通记录 -->
      <div v-if="record.type === 'call'" class="call-record-card">
        <div class="call-info">
          <div class="call-info-item">
            <span class="call-label">通话时长</span>
            <span class="call-value">{{ record.callDetail?.duration }}</span>
          </div>
          <div class="call-info-item">
            <span class="call-label">拨打结果</span>
            <span class="call-value">
              <a-tag :color="record.callDetail?.result === '已接通' ? 'green' : 'orange'" size="small">
                {{ record.callDetail?.result }}
              </a-tag>
            </span>
          </div>
        </div>
        <div class="call-actions">
          <a-button type="link" size="small" @click="showCallDialog(record)">
            <FileTextOutlined /> 查看对话
          </a-button>
          <a-button type="link" size="small" @click="playRecording(record)">
            <AudioOutlined /> {{ playingRecordId === record.id ? '播放中...' : '听录音' }}
          </a-button>
        </div>
      </div>

      <!-- 跟进记录 -->
      <div v-else>
        <div class="timeline-content" v-if="record.remark">
          {{ record.remark }}
        </div>
        <div class="timeline-footer">
          <span v-if="record.addWechat" class="wechat-tag">
            <WechatOutlined /> 已加企微
          </span>
          <span v-if="record.nextFollowTime" class="next-time">
            下次跟进：{{ record.nextFollowTime }}
          </span>
        </div>
      </div>
    </div>
  </a-timeline-item>
</a-timeline>
```

### 电话记录卡片样式

```css
.call-record-card {
  background: #f0f7ff;
  border-radius: 8px;
  padding: 12px;
  margin-top: 8px;
}

.call-info {
  display: flex;
  gap: 24px;
  margin-bottom: 12px;
}

.call-actions {
  display: flex;
  gap: 8px;
  border-top: 1px solid #d6e8ff;
  padding-top: 12px;
}
```

## 13. 对话详情弹窗

### 弹窗模板（聊天气泡样式）

```vue
<a-modal
  v-model:open="callDialogVisible"
  title="通话对话详情"
  :footer="null"
  :width="360"
>
  <div class="call-dialog-content" v-if="currentCallRecord">
    <div class="call-dialog-header">
      <div class="dialog-info">
        <span class="dialog-time">{{ currentCallRecord.time }}</span>
        <span class="dialog-duration">时长：{{ currentCallRecord.callDetail?.duration }}</span>
      </div>
    </div>
    <div class="dialog-messages">
      <div
        v-for="(msg, index) in currentCallRecord.callDetail?.dialogList"
        :key="index"
        class="dialog-message"
        :class="msg.role"
      >
        <div class="message-role">{{ msg.role === 'ai' ? 'AI' : '客户' }}</div>
        <div class="message-content">{{ msg.content }}</div>
        <div class="message-time">{{ msg.time }}</div>
      </div>
    </div>
  </div>
</a-modal>
```

### 对话气泡样式

```css
.dialog-messages {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.dialog-message {
  display: flex;
  flex-direction: column;
  max-width: 85%;
}

.dialog-message.ai {
  align-self: flex-start;
}

.dialog-message.customer {
  align-self: flex-end;
}

.message-content {
  padding: 10px 14px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.5;
  word-break: break-word;
}

.dialog-message.ai .message-content {
  background: #f0f2f5;
  color: #1a3a5c;
  border-top-left-radius: 4px;
}

.dialog-message.customer .message-content {
  background: #1890ff;
  color: #fff;
  border-top-right-radius: 4px;
}
```

### 录音播放功能

```typescript
const playingRecordId = ref<number | null>(null)
let audioPlayer: HTMLAudioElement | null = null

const playRecording = (record: FollowRecord) => {
  if (!record.callDetail?.recordingUrl) {
    message.warning('暂无录音文件')
    return
  }

  // 如果正在播放当前录音，则停止
  if (playingRecordId.value === record.id && audioPlayer) {
    audioPlayer.pause()
    audioPlayer = null
    playingRecordId.value = null
    return
  }

  // 停止之前的播放
  if (audioPlayer) {
    audioPlayer.pause()
    audioPlayer = null
  }

  // 播放新录音
  audioPlayer = new Audio(record.callDetail.recordingUrl)
  playingRecordId.value = record.id

  audioPlayer.play().catch(() => {
    message.error('录音播放失败')
    playingRecordId.value = null
  })

  audioPlayer.onended = () => {
    playingRecordId.value = null
    audioPlayer = null
  }
}
```

## 14. 客户标签展示

### 数据结构

```typescript
interface TagItem {
  tagName: string
  tagValue?: string
}

interface Tags {
  bankTags?: TagItem[]      // 银行标签
  aiCallTags?: TagItem[]    // AI 外呼标签
  manualCallTags?: TagItem[] // 人工外呼标签
  customTags?: TagItem[]    // 自定义标签
}
```

### 模板结构

```vue
<div class="tags-container">
  <!-- 银行标签 -->
  <div class="tag-group">
    <div class="tag-group-title">
      <BankOutlined class="tag-icon bank" />
      <span>银行标签</span>
    </div>
    <div class="tag-list">
      <a-tag v-for="(tag, index) in tags?.bankTags" :key="index" color="blue">
        {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
      </a-tag>
      <span v-if="!tags?.bankTags?.length" class="empty-tag">暂无</span>
    </div>
  </div>
  <!-- AI外呼标签 -->
  <div class="tag-group">
    <div class="tag-group-title">
      <RobotOutlined class="tag-icon ai" />
      <span>AI 外呼标签</span>
    </div>
    <div class="tag-list">
      <a-tag v-for="(tag, index) in tags?.aiCallTags" :key="index" color="cyan">
        {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
      </a-tag>
      <span v-if="!tags?.aiCallTags?.length" class="empty-tag">暂无</span>
    </div>
  </div>
  <!-- 人工外呼标签 -->
  <div class="tag-group">
    <div class="tag-group-title">
      <PhoneOutlined class="tag-icon manual" />
      <span>人工外呼标签</span>
    </div>
    <div class="tag-list">
      <a-tag v-for="(tag, index) in tags?.manualCallTags" :key="index" color="green">
        {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
      </a-tag>
      <span v-if="!tags?.manualCallTags?.length" class="empty-tag">暂无</span>
    </div>
  </div>
  <!-- 自定义标签 -->
  <div class="tag-group">
    <div class="tag-group-title">
      <TagsOutlined class="tag-icon custom" />
      <span>自定义标签</span>
    </div>
    <div class="tag-list">
      <a-tag v-for="(tag, index) in tags?.customTags" :key="index" color="orange">
        {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
      </a-tag>
      <span v-if="!tags?.customTags?.length" class="empty-tag">暂无</span>
    </div>
  </div>
</div>
```

### 样式

```css
.tags-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.tag-group {
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f2f5;
}

.tag-group:last-child {
  padding-bottom: 0;
  border-bottom: none;
}

.tag-group-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 500;
  color: #3d4a5c;
  margin-bottom: 10px;
}

.tag-icon {
  font-size: 14px;
}

.tag-icon.bank { color: #1890ff; }
.tag-icon.ai { color: #13c2c2; }
.tag-icon.manual { color: #52c41a; }
.tag-icon.custom { color: #fa8c16; }

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.empty-tag {
  font-size: 12px;
  color: #bfbfbf;
}
```

## 15. 组件依赖

- Ant Design Vue: Steps, Modal, Popover, Radio, Switch, DatePicker, Timeline, Tag, Button
- 图标: PhoneOutlined, MessageOutlined, CopyOutlined, ClockCircleOutlined, UserOutlined, AppstoreOutlined, FileTextOutlined, WechatOutlined, AudioOutlined, LeftOutlined, TagsOutlined, BankOutlined, RobotOutlined

## 16. 地图模式与列表模式切换

### 视图模式切换按钮

```vue
<div class="view-mode-switch">
  <div
    class="mode-btn"
    :class="{ active: viewMode === 'list' }"
    @click="viewMode = 'list'"
  >
    <UnorderedListOutlined />
  </div>
  <div
    class="mode-btn"
    :class="{ active: viewMode === 'map' }"
    @click="viewMode = 'map'"
  >
    <EnvironmentOutlined />
  </div>
</div>
```

### 数据定义

```typescript
const viewMode = ref<'list' | 'map'>('list')

// 地图客户位置数据（模拟）
const mapCustomers = computed(() => {
  return filteredTaskList.value.map((task, index) => ({
    ...task,
    x: 15 + (index % 5) * 17 + Math.random() * 5,
    y: 15 + Math.floor(index / 5) * 20 + Math.random() * 10
  }))
})

const getMarkerClass = (followResult: string) => {
  const classMap: Record<string, string> = {
    '待跟进': 'pending',
    '持续跟进': 'following',
    '明确转化': 'converted',
    '明确拒绝': 'rejected'
  }
  return classMap[followResult] || 'pending'
}

const handleMarkerClick = (customer: any) => {
  handleTaskClick(customer)
}
```

### 地图视图模板

```vue
<!-- 地图模式 -->
<div v-if="viewMode === 'map'" class="map-view">
  <div class="map-container">
    <div class="map-bg">
      <!-- 模拟地图网格 -->
      <div class="map-grid"></div>
      <!-- 客户位置标记 -->
      <div
        v-for="(customer, index) in mapCustomers"
        :key="customer.id"
        class="map-marker"
        :style="{ left: customer.x + '%', top: customer.y + '%' }"
        @click="handleMarkerClick(customer)"
      >
        <div class="marker-dot" :class="getMarkerClass(customer.followResult)"></div>
        <div class="marker-label">{{ customer.customerName }}</div>
      </div>
    </div>
  </div>
  <!-- 图例 -->
  <div class="map-legend">
    <div class="legend-item">
      <div class="legend-dot pending"></div>
      <span>待跟进</span>
    </div>
    <div class="legend-item">
      <div class="legend-dot following"></div>
      <span>持续跟进</span>
    </div>
    <div class="legend-item">
      <div class="legend-dot converted"></div>
      <span>已转化</span>
    </div>
    <div class="legend-item">
      <div class="legend-dot rejected"></div>
      <span>已拒绝</span>
    </div>
  </div>
  <!-- 客户列表（地图下方） -->
  <div class="map-customer-list">
    <div class="list-title">客户列表</div>
    <div
      v-for="task in filteredTaskList"
      :key="task.id"
      class="map-customer-item"
      @click="handleTaskClick(task)"
    >
      <div class="item-left">
        <div class="item-name">{{ task.customerName }}</div>
        <div class="item-phone">{{ task.phone }}</div>
      </div>
      <div class="item-right">
        <a-tag :color="getFollowStatusColor(task.followResult)" size="small">
          {{ task.followResult }}
        </a-tag>
        <RightOutlined class="arrow-icon" />
      </div>
    </div>
  </div>
</div>

<!-- 列表模式 -->
<div v-else class="task-list">
  <!-- 原有列表卡片内容 -->
</div>
```

### 地图相关样式

```css
/* 视图模式切换 */
.view-mode-switch {
  display: flex;
  background: #f0f2f5;
  border-radius: 6px;
  padding: 2px;
}

.mode-btn {
  padding: 6px 10px;
  border-radius: 4px;
  cursor: pointer;
  color: #8c9bab;
  font-size: 16px;
  transition: all 0.2s;
}

.mode-btn.active {
  background: #fff;
  color: #2b6ff2;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

/* 地图视图 */
.map-view {
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.map-container {
  position: relative;
  width: 100%;
  height: 300px;
  background: #e8f4f8;
  overflow: hidden;
}

.map-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, #d4e6f1 0%, #aed6f1 50%, #85c1e9 100%);
}

.map-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.3) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.3) 1px, transparent 1px);
  background-size: 40px 40px;
}

.map-marker {
  position: absolute;
  transform: translate(-50%, -50%);
  cursor: pointer;
  z-index: 10;
  transition: transform 0.2s;
}

.map-marker:hover {
  transform: translate(-50%, -50%) scale(1.2);
  z-index: 20;
}

.marker-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  margin: 0 auto;
}

.marker-dot.pending {
  background: #fa8c16;
}

.marker-dot.following {
  background: #1890ff;
}

.marker-dot.converted {
  background: #52c41a;
}

.marker-dot.rejected {
  background: #ff4d4f;
}

.marker-label {
  font-size: 11px;
  color: #1a3a5c;
  white-space: nowrap;
  margin-top: 4px;
  text-shadow: 0 1px 2px #fff;
  font-weight: 500;
}

/* 地图图例 */
.map-legend {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding: 12px;
  background: #fafafa;
  border-top: 1px solid #f0f0f0;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #595959;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.legend-dot.pending { background: #fa8c16; }
.legend-dot.following { background: #1890ff; }
.legend-dot.converted { background: #52c41a; }
.legend-dot.rejected { background: #ff4d4f; }

/* 地图客户列表 */
.map-customer-list {
  padding: 12px;
}

.list-title {
  font-size: 14px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 12px;
  padding-left: 8px;
  border-left: 3px solid #2b6ff2;
}

.map-customer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #fff;
  border-radius: 8px;
  margin-bottom: 8px;
  border: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.2s;
}

.map-customer-item:active {
  background: #f5f7fa;
  transform: scale(0.98);
}

.item-left {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.item-name {
  font-size: 15px;
  font-weight: 600;
  color: #1a3a5c;
}

.item-phone {
  font-size: 13px;
  color: #8c9bab;
}

.item-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.arrow-icon {
  font-size: 12px;
  color: #bfbfbf;
}
```

### 图标依赖

```typescript
import {
  EnvironmentOutlined,
  RightOutlined,
  UnorderedListOutlined
} from '@ant-design/icons-vue'
```
