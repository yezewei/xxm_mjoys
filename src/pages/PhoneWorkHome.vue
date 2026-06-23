<template>
  <div class="phone-work-home">
    <!-- 顶部步骤条 -->
    <div class="page-header">
      <h1 class="page-title">每日拨测</h1>
      <a-steps :current="currentStep" size="small" class="daily-steps">
        <a-step title="打开软电话" description="打开软电话，确保软电话处于可用状态" />
        <a-step title="电话拨测" description="电话拨测，检查通话是否正常。点击拨测" />
      </a-steps>
    </div>

    <!-- 今日统计区 -->
    <div class="section-container">
      <div class="section-title">今日统计</div>
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-label">今天我要跟进的场景</div>
          <div class="stat-value">{{ todayStats.sceneCount }}<span class="stat-unit">个</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今天AI协呼电话数</div>
          <div class="stat-value">{{ todayStats.aiCallCount }}<span class="stat-unit">个</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今天协呼接通数</div>
          <div class="stat-value">{{ todayStats.connectedCount }}<span class="stat-unit">个</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今天已跟进的用户</div>
          <div class="stat-value">{{ todayStats.followedCount }}<span class="stat-unit">个</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今天协呼接通率</div>
          <div class="stat-value highlight">{{ todayStats.connectRate }}<span class="stat-unit">%</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今天未跟进的用户</div>
          <div class="stat-value">{{ todayStats.unfollowedCount }}<span class="stat-unit">个</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今天漏接第二次跟进数</div>
          <div class="stat-value">{{ todayStats.missedFollowCount }}<span class="stat-unit">个</span></div>
        </div>
        <div class="stat-card">
          <div class="stat-label">今日下发给我的客户</div>
          <div class="stat-value">{{ todayStats.assignedCustomerCount }}<span class="stat-unit">个</span></div>
        </div>
      </div>
    </div>

    <!-- 我的待办区 -->
    <div class="section-container">
      <div class="section-title">我的待办</div>

      <!-- 二次跟进子区域 -->
      <div class="follow-up-card">
        <div class="follow-up-header">
          <SyncOutlined class="follow-up-icon" />
          <span class="follow-up-title">二次跟进</span>
        </div>
        <div class="follow-up-desc">需要您进行二次跟进</div>
      </div>

      <!-- 任务卡片列表 -->
      <div class="task-list">
        <div
          v-for="task in todoTaskList"
          :key="task.id"
          class="task-card"
          @click="handleViewTask(task)"
        >
          <div class="task-name">{{ task.name }}</div>
          <div class="task-info">
            <div class="info-row">
              <span class="info-label">近30天共有</span>
              <span class="info-value">{{ task.pendingCount }}</span>
              <span class="info-label">个待跟进任务</span>
            </div>
            <div class="info-row">
              <span class="info-label">来源：</span>
              <span class="info-text">{{ task.source }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">跟进进度：</span>
              <span class="info-value">{{ task.followedCount }}/{{ task.totalCount }}</span>
              <span class="info-label">完成</span>
              <span class="info-percent" :class="{ 'completed': task.progress === 100 }">{{ task.progress }}%</span>
            </div>
            <div class="info-row">
              <span class="info-label">场景有效期：</span>
              <span class="info-text">{{ task.expireDate }}</span>
              <span class="info-label">还有{{ task.remainingDays }}天结束</span>
            </div>
          </div>
          <div class="task-action">
            <a class="view-link">去查看</a>
          </div>
        </div>
      </div>
    </div>

    <!-- 常见问题排查区 -->
    <div class="section-container">
      <div class="section-title">常见问题排查</div>
      <div class="faq-list">
        <div
          v-for="(faq, index) in faqList"
          :key="index"
          class="faq-item"
          @click="handleFaqClick(faq)"
        >
          <div class="faq-header">
            <QuestionCircleOutlined class="faq-icon" />
            <span class="faq-question">{{ faq.question }}</span>
            <RightOutlined class="faq-arrow" />
          </div>
        </div>
      </div>
    </div>

    <!-- 常见问题弹窗 -->
    <a-modal
      v-model:open="faqModalVisible"
      :title="currentFaq?.question || '常见问题'"
      @cancel="handleFaqModalClose"
      :footer="null"
      width="600px"
    >
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { message } from 'ant-design-vue'
import {
  PhoneOutlined,
  SyncOutlined,
  QuestionCircleOutlined,
  RightOutlined
} from '@ant-design/icons-vue'

// ============ 类型定义 ============
interface TodayStats {
  sceneCount: number
  aiCallCount: number
  connectedCount: number
  followedCount: number
  connectRate: number
  unfollowedCount: number
  missedFollowCount: number
  assignedCustomerCount: number
}

interface TodoTask {
  id: number
  name: string
  pendingCount: number
  source: string
  followedCount: number
  totalCount: number
  progress: number
  expireDate: string
  remainingDays: number | string
}

// ============ 步骤条状态 ============
const currentStep = ref(0)

// ============ 今日统计数据 ============
const todayStats = reactive<TodayStats>({
  sceneCount: 0,
  aiCallCount: 0,
  connectedCount: 0,
  followedCount: 0,
  connectRate: 0.0,
  unfollowedCount: 0,
  missedFollowCount: 0,
  assignedCustomerCount: 0
})

// ============ 待办任务列表 ============
const todoTaskList = ref<TodoTask[]>([
  {
    id: 1,
    name: '代发薪客户资产提升-江苏中行...',
    pendingCount: 0,
    source: '近30天已下发任务',
    followedCount: 0,
    totalCount: 0,
    progress: 0,
    expireDate: '2025-09-04',
    remainingDays: '--'
  },
  {
    id: 2,
    name: '手机银行新客三重礼-北京中行...',
    pendingCount: 0,
    source: '近30天已下发任务',
    followedCount: 0,
    totalCount: 0,
    progress: 0,
    expireDate: '2025-07-30',
    remainingDays: '--'
  },
  {
    id: 3,
    name: '贷款逾期催收-恒丰银行（POC...',
    pendingCount: 0,
    source: '近30天已下发任务',
    followedCount: 0,
    totalCount: 0,
    progress: 0,
    expireDate: '2025-06-16',
    remainingDays: '--'
  },
  {
    id: 4,
    name: '理财-新恒梦钱包-恒丰银行（P...',
    pendingCount: 0,
    source: '近30天已下发任务',
    followedCount: 0,
    totalCount: 0,
    progress: 0,
    expireDate: '2025-06-16',
    remainingDays: '--'
  },
  {
    id: 5,
    name: '信用卡-新客天天刷（叶泽伟测...',
    pendingCount: 0,
    source: '近30天已下发任务',
    followedCount: 0,
    totalCount: 1,
    progress: 100,
    expireDate: '2025-05-08',
    remainingDays: '--'
  },
  {
    id: 6,
    name: '信用卡-新客天天刷（叶泽伟测...',
    pendingCount: 0,
    source: '近30天已下发任务',
    followedCount: 0,
    totalCount: 1,
    progress: 100,
    expireDate: '2025-05-08',
    remainingDays: '--'
  }
])

// ============ 常见问题数据 ============
interface FaqItem {
  question: string
  possibleCauses: string[]
  solutions: string[]
}

const faqList = ref<FaqItem[]>([
  {
    question: '软电话无法打开怎么办？',
    possibleCauses: [
      '浏览器未授权麦克风/扬声器权限',
      '软电话插件未安装或版本过旧',
      '浏览器兼容性问题（推荐Chrome）'
    ],
    solutions: [
      '检查浏览器权限设置，允许麦克风访问',
      '重新安装或更新软电话插件',
      '切换至Chrome浏览器重试',
      '清除浏览器缓存后刷新页面'
    ]
  },
  {
    question: '拨测电话无法接通？',
    possibleCauses: [
      '软电话未正常注册SIP',
      '外呼号码格式错误或已停机',
      '网络防火墙阻止SIP通信'
    ],
    solutions: [
      '确认软电话状态显示"已注册"',
      '检查号码格式是否正确（含区号）',
      '检查网络防火墙是否放行SIP端口',
      '尝试更换网络环境后重试'
    ]
  },
  {
    question: '坐席软电话无法挂断？',
    possibleCauses: [
      '软电话（小象通/Linphone）异常或崩溃',
      '网络闪断导致BYE消息未发送',
      'SIP会话状态异常（死锁/僵死）'
    ],
    solutions: [
      '首先尝试在工作台页面点击挂断，观察是否生效',
      '若工作台挂断无效，强制关闭软电话进程（任务管理器结束），系统侧超时后会释放该通话',
      '检查该坐席的网络稳定性，确认是否有瞬间断连但未触发SIP超时清理',
      '查看SIP日志，确认BYE消息是否成功发出，以及服务器是否正常响应',
      '若反复出现，检查小象通版本是否为最新，考虑重装或切换为其他软电话测试'
    ]
  },
  {
    question: '统计数据不更新？',
    possibleCauses: [
      '后端服务异常或正在维护',
      '前端缓存未及时刷新',
      '接口响应超时'
    ],
    solutions: [
      '尝试刷新页面或清除浏览器缓存',
      '检查后端服务状态是否正常',
      '联系管理员确认是否有定时维护',
      '检查网络连接是否稳定'
    ]
  }
])

// ============ 弹窗状态 ============
const faqModalVisible = ref(false)
const currentFaq = ref<FaqItem | null>(null)

const handleFaqClick = (faq: FaqItem) => {
  currentFaq.value = faq
  faqModalVisible.value = true
}

const handleFaqModalClose = () => {
  faqModalVisible.value = false
  currentFaq.value = null
}

// ============ 方法 ============
const handleOpenSoftPhone = () => {
  message.info('正在打开软电话...')
  // TODO: 调用软电话 SDK 启动拨号功能
}

const handleViewTask = (task: TodoTask) => {
  message.info(`查看任务: ${task.name}`)
  // TODO: 跳转至该任务的跟进详情页
}
</script>

<style scoped>
.phone-work-home {
  padding: 16px;
  background-color: #f5f7fa;
  min-height: 100vh;
  width: 100%;
}

/* 顶部标题栏 */
.page-header {
  background: #fff;
  padding: 16px;
  border-radius: 10px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.page-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
  color: #1a3a5c;
}

.daily-steps {
  margin-top: 12px;
  overflow-x: auto;
  overflow-y: hidden;
}

.daily-steps :deep(.ant-steps) {
  min-width: max-content;
}

.daily-steps :deep(.ant-steps-item) {
  flex: 1 1 0;
  min-width: 0;
}

.daily-steps :deep(.ant-steps-item-container) {
  width: auto;
}

.daily-steps :deep(.ant-steps-item-title) {
  font-size: 14px;
  font-weight: 600;
}

.daily-steps :deep(.ant-steps-item-description) {
  font-size: 12px;
  white-space: nowrap !important;
}

/* 软电话控制区 */
.soft-phone-card {
  background: #f0f7ff;
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 16px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.soft-phone-card:hover {
  background: #e6f0ff;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.soft-phone-content {
  display: flex;
  align-items: center;
  gap: 12px;
}

.soft-phone-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #2b6ff2, #1a5cd8);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24px;
}

.soft-phone-title {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 4px;
}

.soft-phone-desc {
  font-size: 13px;
  color: #8c9bab;
}

/* 区域容器 */
.section-container {
  background: #fff;
  border-radius: 10px;
  padding: 16px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 16px;
}

/* 统计网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.stat-card {
  background: #f8fafc;
  border-radius: 6px;
  padding: 12px;
}

.stat-label {
  font-size: 12px;
  color: #8c9bab;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
  color: #2b6ff2;
}

.stat-value.highlight {
  color: #2b6ff2;
}

.stat-unit {
  font-size: 12px;
  color: #8c9bab;
  margin-left: 2px;
  font-weight: 400;
}

/* 二次跟进卡片 */
.follow-up-card {
  background: #f8fafc;
  border-radius: 8px;
  padding: 12px 14px;
  margin-bottom: 16px;
}

.follow-up-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.follow-up-icon {
  color: #2b6ff2;
  font-size: 16px;
}

.follow-up-title {
  font-size: 14px;
  font-weight: 600;
  color: #1a3a5c;
}

.follow-up-desc {
  font-size: 13px;
  color: #8c9bab;
  padding-left: 24px;
}

/* 任务列表 */
.task-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.task-card {
  background: #fff;
  border: 1px solid #ebeef2;
  border-radius: 10px;
  padding: 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.task-card:hover {
  border-color: #2b6ff2;
  box-shadow: 0 4px 12px rgba(43, 111, 242, 0.15);
}

.task-name {
  font-size: 14px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 12px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.task-info {
  margin-bottom: 12px;
}

.info-row {
  font-size: 12px;
  color: #8c9bab;
  margin-bottom: 6px;
  line-height: 1.5;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  color: #8c9bab;
}

.info-value {
  color: #3d4a5c;
  font-weight: 500;
}

.info-text {
  color: #3d4a5c;
}

.info-percent {
  color: #2b6ff2;
  font-weight: 600;
  margin-left: 4px;
}

.info-percent.completed {
  color: #52c41a;
}

.task-action {
  text-align: right;
}

.view-link {
  color: #2b6ff2;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: color 0.3s;
}

.view-link:hover {
  color: #1a5cd8;
}

/* 常见问题 */
.faq-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.faq-item {
  background: #f8fafc;
  border-radius: 8px;
  padding: 12px 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.faq-item:hover {
  background: #e6f0ff;
  border-color: #2b6ff2;
}

.faq-header {
  display: flex;
  align-items: center;
  gap: 10px;
}

.faq-icon {
  color: #2b6ff2;
  font-size: 16px;
  flex-shrink: 0;
}

.faq-question {
  flex: 1;
  font-size: 14px;
  color: #1a3a5c;
  font-weight: 500;
}

.faq-arrow {
  color: #8c9bab;
  font-size: 12px;
  flex-shrink: 0;
}

/* 弹窗内容样式 */
.faq-modal-content {
  padding: 8px 0;
}

.faq-section {
  margin-bottom: 20px;
}

.faq-section:last-child {
  margin-bottom: 0;
}

.faq-section-title {
  font-size: 14px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 12px;
}

.faq-list-items {
  margin: 0;
  padding-left: 20px;
}

.faq-list-items li {
  font-size: 13px;
  color: #3d4a5c;
  line-height: 1.8;
  margin-bottom: 4px;
}

.faq-list-items.solutions li {
  margin-bottom: 8px;
}

/* 响应式调整 */
@media screen and (max-width: 480px) {
  .phone-work-home {
    padding: 12px;
  }

  .page-header {
    padding: 12px;
  }

  .page-title {
    font-size: 16px;
  }

  .soft-phone-card {
    padding: 12px;
  }

  .soft-phone-icon {
    width: 40px;
    height: 40px;
    font-size: 20px;
  }

  .soft-phone-title {
    font-size: 14px;
  }

  .soft-phone-desc {
    font-size: 12px;
  }

  .section-container {
    padding: 12px;
  }

  .section-title {
    font-size: 14px;
    margin-bottom: 12px;
  }

  .stats-grid {
    gap: 8px;
  }

  .stat-card {
    padding: 10px;
  }

  .stat-label {
    font-size: 11px;
    margin-bottom: 6px;
  }

  .stat-value {
    font-size: 18px;
  }

  .task-card {
    padding: 12px;
  }

  .task-name {
    font-size: 13px;
    margin-bottom: 10px;
  }

  .info-row {
    font-size: 11px;
    margin-bottom: 4px;
  }
}
</style>
