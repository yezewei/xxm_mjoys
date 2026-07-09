<template>
  <div class="mobile-task-detail">
    <!-- 顶部导航栏 -->
    <div class="detail-header">
      <div class="header-left" @click="handleBack">
        <LeftOutlined />
        <span>返回</span>
      </div>
      <div class="header-title">任务详情</div>
      <div class="header-right"></div>
    </div>

    <!-- 客户信息卡片 -->
    <div class="customer-card">
      <div class="customer-header">
        <div class="customer-avatar">
          <span>{{ taskDetail.customerName?.charAt(0) || '客' }}</span>
        </div>
        <div class="customer-info">
          <div class="customer-name">{{ taskDetail.customerName }}</div>
          <div class="customer-phone">{{ taskDetail.phone }}</div>
        </div>
        <a-tag :color="getFollowStatusColor(taskDetail.followResult)" class="status-tag">
          {{ taskDetail.followResult }}
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
        <div class="action-item" @click="handleFollow">
          <EditOutlined />
          <span>去跟进</span>
        </div>
      </div>
    </div>

    <!-- 统计数据 -->
    <div class="stats-section">
      <div class="stats-grid">
        <div class="stat-item">
          <div class="stat-value">{{ taskDetail.statistics?.callCount || 0 }}</div>
          <div class="stat-label">拨打次数</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ taskDetail.statistics?.followCount || 0 }}</div>
          <div class="stat-label">跟进次数</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ taskDetail.statistics?.assignCount || 0 }}</div>
          <div class="stat-label">分配次数</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ taskDetail.statistics?.duration || '0秒' }}</div>
          <div class="stat-label">通话时长</div>
        </div>
      </div>
    </div>

    <!-- 基本信息 -->
    <div class="info-section">
      <div class="section-title">
        <UserOutlined />
        <span>基本信息</span>
      </div>
      <div class="info-list">
        <div class="info-item">
          <div class="info-label">客户名称</div>
          <div class="info-value">{{ taskDetail.customerName }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">联系方式</div>
          <div class="info-value">{{ taskDetail.phone }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">直营坐席</div>
          <div class="info-value">{{ taskDetail.seatAccount || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">AI用户分类</div>
          <div class="info-value">
            <a-tag :color="getAiUserTypeColor(taskDetail.aiUserType)" size="small">
              {{ taskDetail.aiUserType || '-' }}
            </a-tag>
          </div>
        </div>
        <div class="info-item">
          <div class="info-label">对话标签</div>
          <div class="info-value">{{ taskDetail.dialogTag || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">是否人工触达</div>
          <div class="info-value">
            <a-tag :color="taskDetail.isManualReach === '是' ? 'green' : 'default'" size="small">
              {{ taskDetail.isManualReach }}
            </a-tag>
          </div>
        </div>
        <div class="info-item">
          <div class="info-label">是否人工外呼</div>
          <div class="info-value">
            <a-tag :color="taskDetail.isManualCall === '是' ? 'green' : 'default'" size="small">
              {{ taskDetail.isManualCall }}
            </a-tag>
          </div>
        </div>
        <div class="info-item">
          <div class="info-label">AI分配时间</div>
          <div class="info-value">{{ taskDetail.aiAssignTime || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="info-label">最近分配时间</div>
          <div class="info-value">{{ taskDetail.lastAssignTime || '-' }}</div>
        </div>
      </div>
    </div>

    <!-- 关联场景 -->
    <div class="info-section">
      <div class="section-title">
        <AppstoreOutlined />
        <span>关联场景</span>
      </div>
      <div class="scene-list" v-if="taskDetail.scenes?.length">
        <div v-for="(scene, index) in taskDetail.scenes" :key="index" class="scene-item">
          <div class="scene-icon">
            <AppstoreOutlined />
          </div>
          <div class="scene-info">
            <div class="scene-name">{{ scene.name }}</div>
            <div class="scene-time">加入时间：{{ scene.joinTime }}</div>
          </div>
        </div>
      </div>
      <a-empty v-else description="暂无关联场景" :image="false" />
    </div>

    <!-- 客户标签 -->
    <div class="info-section">
      <div class="section-title">
        <TagsOutlined />
        <span>客户标签</span>
      </div>
      <div class="tags-container">
        <!-- 银行标签 -->
        <div class="tag-group">
          <div class="tag-group-title">
            <BankOutlined class="tag-icon bank" />
            <span>银行标签</span>
          </div>
          <div class="tag-list">
            <a-tag v-for="(tag, index) in taskDetail.tags?.bankTags" :key="index" color="blue">
              {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
            </a-tag>
            <span v-if="!taskDetail.tags?.bankTags?.length" class="empty-tag">暂无</span>
          </div>
        </div>
        <!-- AI外呼标签 -->
        <div class="tag-group">
          <div class="tag-group-title">
            <RobotOutlined class="tag-icon ai" />
            <span>AI 外呼标签</span>
          </div>
          <div class="tag-list">
            <a-tag v-for="(tag, index) in taskDetail.tags?.aiCallTags" :key="index" color="cyan">
              {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
            </a-tag>
            <span v-if="!taskDetail.tags?.aiCallTags?.length" class="empty-tag">暂无</span>
          </div>
        </div>
        <!-- 人工外呼标签 -->
        <div class="tag-group">
          <div class="tag-group-title">
            <PhoneOutlined class="tag-icon manual" />
            <span>人工外呼标签</span>
          </div>
          <div class="tag-list">
            <a-tag v-for="(tag, index) in taskDetail.tags?.manualCallTags" :key="index" color="green">
              {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
            </a-tag>
            <span v-if="!taskDetail.tags?.manualCallTags?.length" class="empty-tag">暂无</span>
          </div>
        </div>
        <!-- 自定义标签 -->
        <div class="tag-group">
          <div class="tag-group-title">
            <TagsOutlined class="tag-icon custom" />
            <span>自定义标签</span>
          </div>
          <div class="tag-list">
            <a-tag v-for="(tag, index) in taskDetail.tags?.customTags" :key="index" color="orange">
              {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
            </a-tag>
            <span v-if="!taskDetail.tags?.customTags?.length" class="empty-tag">暂无</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 跟进记录 -->
    <div class="info-section">
      <div class="section-title">
        <FileTextOutlined />
        <span>跟进记录</span>
      </div>
      <div class="timeline-container">
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
        <a-empty v-else description="暂无跟进记录" :image="false" />
      </div>
    </div>

    <!-- 对话详情弹窗 -->
    <a-modal
      v-model:open="callDialogVisible"
      title="通话对话详情"
      :footer="null"
      :width="360"
      class="call-dialog-modal"
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

    <!-- 跟进弹窗 -->
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { message } from 'ant-design-vue'
import type { Dayjs } from 'dayjs'
import {
  LeftOutlined,
  PhoneOutlined,
  MessageOutlined,
  EditOutlined,
  UserOutlined,
  AppstoreOutlined,
  FileTextOutlined,
  WechatOutlined,
  AudioOutlined,
  TagsOutlined,
  BankOutlined,
  RobotOutlined
} from '@ant-design/icons-vue'

const router = useRouter()
const route = useRoute()

// ============ 任务详情数据 ============
interface TagItem {
  tagName: string
  tagValue?: string
}

interface TaskDetail {
  id: number
  customerName: string
  phone: string
  seatAccount: string
  followResult: string
  isManualReach: string
  aiUserType: string
  dialogTag: string
  aiAssignTime: string
  lastAssignTime: string
  assignHistory: string
  isManualCall: string
  statistics: {
    callCount: number
    followCount: number
    assignCount: number
    duration: string
  }
  scenes: Array<{
    name: string
    joinTime: string
  }>
  tags?: {
    bankTags?: TagItem[]
    aiCallTags?: TagItem[]
    manualCallTags?: TagItem[]
    customTags?: TagItem[]
  }
}

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

const taskDetail = ref<TaskDetail>({
  id: 0,
  customerName: '',
  phone: '',
  seatAccount: '',
  followResult: '',
  isManualReach: '',
  aiUserType: '',
  dialogTag: '',
  aiAssignTime: '',
  lastAssignTime: '',
  assignHistory: '',
  isManualCall: '',
  statistics: {
    callCount: 0,
    followCount: 0,
    assignCount: 0,
    duration: '0秒'
  },
  scenes: []
})

const followRecords = ref<FollowRecord[]>([])

// ============ 对话弹窗相关 ============
const callDialogVisible = ref(false)
const currentCallRecord = ref<FollowRecord | null>(null)
const playingRecordId = ref<number | null>(null)
let audioPlayer: HTMLAudioElement | null = null

// ============ 跟进弹窗相关 ============
const followModalVisible = ref(false)
const followSubmitting = ref(false)

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

// ============ 加载数据 ============
onMounted(() => {
  const taskId = route.params.id as string
  loadTaskDetail(taskId)
  loadFollowRecords(taskId)
})

const loadTaskDetail = (taskId: string) => {
  // TODO: 调用后端 API 获取任务详情
  // 模拟数据
  taskDetail.value = {
    id: Number(taskId),
    customerName: '张三',
    phone: '189****3312',
    seatAccount: 'seat_001',
    followResult: '待跟进',
    isManualReach: '否',
    aiUserType: '高意向',
    dialogTag: '有意向',
    aiAssignTime: '2026-06-10 09:30:00',
    lastAssignTime: '2026-06-12 14:20:00',
    assignHistory: '2次',
    isManualCall: '否',
    statistics: {
      callCount: 5,
      followCount: 2,
      assignCount: 2,
      duration: '3分20秒'
    },
    scenes: [
      { name: '华夏总行-新客C+会', joinTime: '2026-06-01' },
      { name: '华夏总行-新客有礼', joinTime: '2026-05-15' }
    ],
    tags: {
      bankTags: [
        { tagName: 'VIP 客户', tagValue: '是' },
        { tagName: '高价值客户' },
        { tagName: '信用卡客户' },
        { tagName: '贷款客户', tagValue: '住房贷款' }
      ],
      aiCallTags: [
        { tagName: 'AI 已接通' },
        { tagName: 'AI 有意向', tagValue: '高' },
        { tagName: 'AI 需回拨' }
      ],
      manualCallTags: [
        { tagName: '人工需跟进', tagValue: '3次' },
        { tagName: '人工成功' }
      ],
      customTags: [
        { tagName: '潜力客户', tagValue: '高' },
        { tagName: '新客户' },
        { tagName: '重要客户' }
      ]
    }
  }
}

const loadFollowRecords = (taskId: string) => {
  // TODO: 调用后端 API 获取跟进记录
  // 模拟数据
  followRecords.value = [
    {
      id: 1,
      type: 'call',
      title: '电话沟通',
      time: '2026-06-15 15:00:00',
      callDetail: {
        duration: '2分30秒',
        result: '已接通',
        recordingUrl: 'https://example.com/recording/001.mp3',
        dialogList: [
          { role: 'ai', content: '您好，我是华夏银行的客服，请问是张先生吗？', time: '00:00' },
          { role: 'customer', content: '是的，我是。', time: '00:05' },
          { role: 'ai', content: '张先生您好，我们注意到您是我们的重要客户，今天联系您是想了解一下您对我们新推出的理财产品是否感兴趣？', time: '00:08' },
          { role: 'customer', content: '什么理财产品？说来听听。', time: '00:15' },
          { role: 'ai', content: '我们最新推出的是稳健型理财产品，年化收益率在4.5%左右，风险较低，非常适合像您这样的优质客户。', time: '00:18' },
          { role: 'customer', content: '听起来还不错，我需要考虑一下。', time: '00:25' },
          { role: 'ai', content: '好的，张先生。我可以安排我们的理财顾问为您详细介绍，您看什么时候方便？', time: '00:30' },
          { role: 'customer', content: '下周吧，我比较忙。', time: '00:35' },
          { role: 'ai', content: '好的，那我安排下周三下午联系您，可以吗？', time: '00:38' },
          { role: 'customer', content: '可以的。', time: '00:42' },
          { role: 'ai', content: '好的，张先生，感谢您的时间，祝您生活愉快，再见！', time: '00:45' }
        ]
      }
    },
    {
      id: 2,
      type: 'follow',
      title: '持续跟进',
      time: '2026-06-15 14:30:00',
      remark: '客户表示需要考虑一下，下周再联系',
      addWechat: true,
      nextFollowTime: '2026-06-20'
    },
    {
      id: 3,
      type: 'call',
      title: '电话沟通',
      time: '2026-06-14 10:15:00',
      callDetail: {
        duration: '1分10秒',
        result: '未接通',
        recordingUrl: 'https://example.com/recording/002.mp3',
        dialogList: [
          { role: 'ai', content: '您好，我是华夏银行的客服，请问是张先生吗？', time: '00:00' },
          { role: 'ai', content: '您好？请问有人在吗？', time: '00:10' },
          { role: 'ai', content: '抱歉，未能接通，稍后再联系。', time: '00:20' }
        ]
      }
    },
    {
      id: 4,
      type: 'follow',
      title: '待跟进',
      time: '2026-06-12 14:20:00',
      remark: '初次分配，等待跟进',
      addWechat: false,
      nextFollowTime: ''
    }
  ]
}

// ============ 方法 ============
const getFollowStatusColor = (status: string) => {
  const colorMap: Record<string, string> = {
    '待跟进': 'orange',
    '持续跟进': 'blue',
    '明确转化': 'green',
    '明确拒绝': 'red'
  }
  return colorMap[status] || 'default'
}

const getAiUserTypeColor = (type: string) => {
  const colorMap: Record<string, string> = {
    '高意向': 'green',
    '中意向': 'blue',
    '低意向': 'orange'
  }
  return colorMap[type] || 'default'
}

const getTimelineColor = (type: string) => {
  return type === 'call' ? '#1890ff' : '#52c41a'
}

const showCallDialog = (record: FollowRecord) => {
  currentCallRecord.value = record
  callDialogVisible.value = true
}

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

const handleBack = () => {
  router.push('/mobile')
}

const handleCall = () => {
  message.info(`呼叫：${taskDetail.value.phone}`)
}

const handleSms = () => {
  message.info(`发送短信：${taskDetail.value.phone}`)
}

const handleFollow = () => {
  followForm.followResult = '持续跟进'
  followForm.remark = ''
  followForm.addWechat = false
  followForm.nextFollowTime = null
  followModalVisible.value = true
}

const handleSubmitFollow = () => {
  if (!followForm.followResult) {
    message.warning('请选择跟进结果')
    return
  }
  if (followForm.followResult === '持续跟进' && !followForm.nextFollowTime) {
    message.warning('请选择下次跟进时间')
    return
  }

  followSubmitting.value = true
  setTimeout(() => {
    followSubmitting.value = false
    followModalVisible.value = false
    message.success('跟进信息提交成功')

    // 更新详情数据
    taskDetail.value.followResult = followForm.followResult
    taskDetail.value.statistics.followCount += 1

    // 添加跟进记录
    followRecords.value.unshift({
      id: Date.now(),
      type: 'follow',
      title: followForm.followResult,
      time: new Date().toLocaleString(),
      remark: followForm.remark,
      addWechat: followForm.addWechat,
      nextFollowTime: followForm.nextFollowTime?.format('YYYY-MM-DD') || ''
    })
  }, 500)
}
</script>

<style scoped>
.mobile-task-detail {
  min-height: 100vh;
  background: #f5f7fa;
  padding-bottom: 16px;
}

/* 顶部导航栏 */
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

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: #2b6ff2;
  font-size: 14px;
}

.header-title {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a5c;
}

/* 客户信息卡片 */
.customer-card {
  margin: 16px;
  background: linear-gradient(135deg, #2b6ff2 0%, #1a5cd6 100%);
  border-radius: 12px;
  padding: 20px;
  color: #fff;
}

.customer-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
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

.customer-info {
  flex: 1;
}

.customer-name {
  font-size: 18px;
  font-weight: 600;
}

.customer-phone {
  font-size: 13px;
  opacity: 0.85;
  margin-top: 4px;
}

.status-tag {
  border: none;
}

.customer-actions {
  display: flex;
  justify-content: space-around;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  font-size: 12px;
}

.action-item .anticon {
  font-size: 20px;
}

/* 统计数据 */
.stats-section {
  margin: 0 16px 16px;
  background: #fff;
  border-radius: 10px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
  color: #2b6ff2;
}

.stat-label {
  font-size: 11px;
  color: #8c9bab;
  margin-top: 4px;
}

/* 信息区域 */
.info-section {
  margin: 0 16px 16px;
  background: #fff;
  border-radius: 10px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #1a3a5c;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f2f5;
}

.section-title .anticon {
  color: #2b6ff2;
}

/* 信息列表 */
.info-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-label {
  font-size: 13px;
  color: #8c9bab;
}

.info-value {
  font-size: 13px;
  color: #3d4a5c;
  font-weight: 500;
}

/* 场景列表 */
.scene-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.scene-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 8px;
}

.scene-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: #e6f0ff;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #2b6ff2;
}

.scene-name {
  font-size: 14px;
  font-weight: 500;
  color: #1a3a5c;
}

.scene-time {
  font-size: 12px;
  color: #8c9bab;
  margin-top: 4px;
}

/* 客户标签 */
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

.tag-icon.bank {
  color: #1890ff;
}

.tag-icon.ai {
  color: #13c2c2;
}

.tag-icon.manual {
  color: #52c41a;
}

.tag-icon.custom {
  color: #fa8c16;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.empty-tag {
  font-size: 12px;
  color: #bfbfbf;
}

/* 时间轴 */
.timeline-container {
  max-height: 400px;
  overflow-y: auto;
}

.timeline-item {
  padding-bottom: 8px;
}

.timeline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.timeline-title {
  font-size: 14px;
  font-weight: 500;
  color: #1a3a5c;
}

.timeline-time {
  font-size: 12px;
  color: #8c9bab;
}

.timeline-content {
  font-size: 13px;
  color: #3d4a5c;
  background: #f5f7fa;
  padding: 8px 12px;
  border-radius: 6px;
  margin-bottom: 8px;
}

.timeline-footer {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #8c9bab;
}

.wechat-tag {
  color: #52c41a;
}

/* 电话记录卡片 */
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

.call-info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.call-label {
  font-size: 12px;
  color: #8c9bab;
}

.call-value {
  font-size: 14px;
  font-weight: 500;
  color: #1a3a5c;
}

.call-actions {
  display: flex;
  gap: 8px;
  border-top: 1px solid #d6e8ff;
  padding-top: 12px;
}

.call-actions .ant-btn {
  padding: 0 8px;
  font-size: 13px;
}

/* 对话弹窗样式 */
.call-dialog-content {
  max-height: 60vh;
  overflow-y: auto;
}

.call-dialog-header {
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f2f5;
  margin-bottom: 16px;
}

.dialog-info {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  color: #8c9bab;
}

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

.message-role {
  font-size: 12px;
  color: #8c9bab;
  margin-bottom: 4px;
}

.dialog-message.customer .message-role {
  text-align: right;
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

.message-time {
  font-size: 11px;
  color: #bfbfbf;
  margin-top: 4px;
}

.dialog-message.customer .message-time {
  text-align: right;
}

/* 跟进弹窗样式 */
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
</style>
