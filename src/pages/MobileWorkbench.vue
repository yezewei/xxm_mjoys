<template>
  <div class="mobile-workbench">
    <!-- 顶部统计卡片 -->
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
        <div class="stat-card">
          <div class="stat-label">近7天待跟进</div>
          <div class="stat-value">{{ stats.weekPending }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">近7天已完成</div>
          <div class="stat-value completed">{{ stats.weekCompleted }}</div>
        </div>
      </div>
    </div>

    <!-- 场景筛选区域 -->
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
        <a-select
          v-model:value="selectedSceneId"
          placeholder="请选择场景"
          style="width: 100%"
          @change="handleSceneChange"
        >
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

    <!-- 任务列表区域 -->
    <div class="task-section">
      <div class="task-header">
        <div class="task-title">
          <UnorderedListOutlined />
          <span>任务列表</span>
        </div>
        <div class="task-header-right">
          <div class="task-count">
            共 <span class="count-num">{{ filteredTaskList.length }}</span> 条
          </div>
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
        </div>
      </div>

      <!-- 地图模式 -->
      <div v-if="viewMode === 'map'" class="map-view">
        <div class="map-container" ref="mapContainerRef"></div>
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
        <div
          v-for="task in filteredTaskList"
          :key="task.id"
          class="task-card"
          @click="handleTaskClick(task)"
        >
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
              <a-button type="primary" size="small" @click.stop="handleFollow(task)">
                去跟进
              </a-button>
              <a-button size="small" @click.stop="handleCall(task)">
                呼叫
              </a-button>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="filteredTaskList.length === 0" class="empty-state">
          <InboxOutlined class="empty-icon" />
          <div class="empty-text">暂无任务数据</div>
          <div class="empty-hint">请调整筛选条件或选择其他场景</div>
        </div>
      </div>
    </div>

    <!-- 跟进弹窗 -->
    <a-modal
      v-model:open="followModalVisible"
      title="填写跟进信息"
      :footer="null"
      :width="360"
      class="follow-modal"
    >
      <div class="follow-form" v-if="currentFollowTask">
        <div class="follow-customer-info">
          <div class="customer-name">{{ currentFollowTask.customerName }}</div>
          <div class="customer-phone">{{ currentFollowTask.phone }}</div>
        </div>

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
import { ref, reactive, computed, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { message, Modal } from 'ant-design-vue'
import type { Dayjs } from 'dayjs'
import {
  FilterOutlined,
  ReloadOutlined,
  UnorderedListOutlined,
  PhoneOutlined,
  ClockCircleOutlined,
  RobotOutlined,
  InboxOutlined,
  EnvironmentOutlined,
  RightOutlined
} from '@ant-design/icons-vue'

// 高德地图类型声明
declare global {
  interface Window {
    AMap: any
  }
}

const router = useRouter()

// ============ 类型定义 ============
interface SceneItem {
  id: number
  name: string
  code: string
  status: 'active' | 'closed' | 'expired'
  statusLabel: string
  callTimeRange: string
  collabType: string
  collabEnabled: boolean
  createTime: string
  lastAssignTime: string
  pendingCount: number
  totalCount: number
}

interface TaskItem {
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
  sceneId: number
}

interface FilterForm {
  followStatus: string | undefined
}

// ============ 统计数据 ============
const stats = reactive({
  todayPending: 12,
  todayCompleted: 8,
  weekPending: 45,
  weekCompleted: 32
})

// ============ 视图模式 ============
const viewMode = ref<'list' | 'map'>('list')
const mapContainerRef = ref<HTMLElement | null>(null)
const mapInstance = ref<any>(null)

// 地图客户位置数据（模拟经纬度）
const customerLocations = [
  { id: 1, lng: 121.4737, lat: 31.2304, name: '上海市' },
  { id: 2, lng: 116.4074, lat: 39.9042, name: '北京市' },
  { id: 3, lng: 113.2644, lat: 23.1291, name: '广州市' },
  { id: 4, lng: 114.0579, lat: 22.5431, name: '深圳市' },
  { id: 5, lng: 120.1551, lat: 30.2741, name: '杭州市' },
  { id: 6, lng: 106.5516, lat: 29.5630, name: '重庆市' },
  { id: 7, lng: 104.0657, lat: 30.6571, name: '成都市' },
  { id: 8, lng: 118.7969, lat: 32.0603, name: '南京市' }
]

// 初始化地图
const initMap = () => {
  if (!mapContainerRef.value) return

  // 检查高德地图API是否已加载
  if (typeof window.AMap === 'undefined') {
    console.warn('高德地图API未加载，使用模拟地图')
    renderMockMap()
    return
  }

  try {
    const map = new window.AMap.Map(mapContainerRef.value, {
      zoom: 6,
      center: [116.397428, 39.90923],
      mapStyle: 'amap://styles/whitesmoke'
    })

    mapInstance.value = map

    // 添加客户标记
    filteredTaskList.value.forEach((task, index) => {
      const location = customerLocations[index % customerLocations.length]
      const marker = new window.AMap.Marker({
        position: [location.lng, location.lat],
        title: task.customerName,
        content: `<div class="custom-marker ${getMarkerClass(task.followResult)}">${task.customerName.charAt(0)}</div>`,
        offset: new window.AMap.Pixel(-15, -15)
      })

      marker.on('click', () => {
        handleTaskClick(task)
      })

      map.add(marker)
    })

    // 自适应视图
    map.setFitView()
  } catch (e) {
    console.error('地图初始化失败:', e)
    renderMockMap()
  }
}

// 模拟地图
const renderMockMap = () => {
  if (!mapContainerRef.value) return
  mapContainerRef.value.innerHTML = `
    <div style="position:relative;width:100%;height:100%;background:linear-gradient(135deg,#d4e6f1,#aed6f1,#85c1e9);overflow:hidden">
      <div style="position:absolute;inset:0;background-image:linear-gradient(rgba(255,255,255,0.3) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,0.3) 1px,transparent 1px);background-size:40px 40px"></div>
      <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);text-align:center;color:#1a5cd6;font-size:16px;font-weight:600">
        <div style="font-size:40px;margin-bottom:8px">🗺️</div>
        <div>客户分布地图</div>
        <div style="font-size:12px;color:#666;margin-top:4px">共 ${filteredTaskList.value.length} 个客户</div>
      </div>
    </div>
  `
}

// 监听视图模式变化
watch(viewMode, (newVal) => {
  if (newVal === 'map') {
    nextTick(() => {
      initMap()
    })
  }
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

// ============ 场景列表 ============
const sceneList = ref<SceneItem[]>([
  {
    id: 1,
    name: '华夏总行-新客有礼（呼通即转）',
    code: '20260604ELWTDWHL',
    status: 'expired',
    statusLabel: '作业时间不满足',
    callTimeRange: '09:00-18:00',
    collabType: '呼通即转',
    collabEnabled: true,
    createTime: '2026-06-01 10:00:00',
    lastAssignTime: '2026-06-10 09:30:00',
    pendingCount: 0,
    totalCount: 0
  },
  {
    id: 2,
    name: '华夏总行-新客C+会',
    code: '20260604ELWTDWH2',
    status: 'active',
    statusLabel: '作业中',
    callTimeRange: '09:00-18:00',
    collabType: '呼通即转(AI同时接待)',
    collabEnabled: true,
    createTime: '2026-06-02 14:00:00',
    lastAssignTime: '2026-06-12 14:20:00',
    pendingCount: 1,
    totalCount: 1696
  },
  {
    id: 3,
    name: 'AI呼通即转',
    code: '20260604AICALL',
    status: 'active',
    statusLabel: '作业中',
    callTimeRange: '08:00-21:00',
    collabType: '呼通即转',
    collabEnabled: false,
    createTime: '2026-06-03 09:00:00',
    lastAssignTime: '',
    pendingCount: 2,
    totalCount: 1696
  },
  {
    id: 4,
    name: '企微加粉转人工（卡部）-上海兴业卡部',
    code: '20260604QWWZF',
    status: 'closed',
    statusLabel: '已关闭',
    callTimeRange: '09:00-17:00',
    collabType: '触发话术/QA转接',
    collabEnabled: false,
    createTime: '2026-05-28 16:00:00',
    lastAssignTime: '',
    pendingCount: 0,
    totalCount: 0
  },
  {
    id: 5,
    name: '华夏总行-存量客户激活',
    code: '20260605ELCLJH',
    status: 'expired',
    statusLabel: '作业时间不满足',
    callTimeRange: '09:00-18:00',
    collabType: 'AI播发完开场白后转接',
    collabEnabled: false,
    createTime: '2026-06-05 11:00:00',
    lastAssignTime: '2026-06-11 11:10:00',
    pendingCount: 5,
    totalCount: 3200
  }
])

// ============ 当前选中场景 ============
const selectedSceneId = ref<number>(2)

// ============ 跟进状态列表 ============
const followStatusList = [
  { label: '全部', value: undefined },
  { label: '待跟进', value: 'pending' },
  { label: '持续跟进', value: 'following' },
  { label: '明确转化', value: 'converted' },
  { label: '明确拒绝', value: 'rejected' }
]

// ============ 时间范围 ============
const timeRangeOptions = [
  { label: '今天', value: 'today' },
  { label: '近7天', value: '7days' },
  { label: '近30天', value: '30days' }
]
const selectedTimeRange = ref('7days')

// ============ 筛选表单 ============
const filterForm = reactive<FilterForm>({
  followStatus: undefined
})

// ============ 任务列表数据 ============
const taskList = ref<TaskItem[]>([
  { id: 1, customerName: '张三', phone: '189****3312', seatAccount: 'seat_001', followResult: '待跟进', isManualReach: '否', aiUserType: '高意向', dialogTag: '有意向', aiAssignTime: '2026-06-10 09:30:00', lastAssignTime: '2026-06-12 14:20:00', assignHistory: '2次', isManualCall: '否', sceneId: 2 },
  { id: 2, customerName: '李四', phone: '138****5567', seatAccount: 'seat_002', followResult: '持续跟进', isManualReach: '是', aiUserType: '中意向', dialogTag: '需跟进', aiAssignTime: '2026-06-09 10:15:00', lastAssignTime: '2026-06-12 16:45:00', assignHistory: '3次', isManualCall: '是', sceneId: 2 },
  { id: 3, customerName: '王五', phone: '156****8821', seatAccount: 'seat_003', followResult: '明确转化', isManualReach: '是', aiUserType: '高意向', dialogTag: '已转化', aiAssignTime: '2026-06-08 11:00:00', lastAssignTime: '2026-06-11 09:10:00', assignHistory: '5次', isManualCall: '是', sceneId: 2 },
  { id: 4, customerName: '赵六', phone: '152****4433', seatAccount: 'seat_004', followResult: '明确拒绝', isManualReach: '否', aiUserType: '低意向', dialogTag: '无意向', aiAssignTime: '2026-06-10 14:30:00', lastAssignTime: '2026-06-12 10:00:00', assignHistory: '1次', isManualCall: '否', sceneId: 2 },
  { id: 5, customerName: '孙七', phone: '135****9901', seatAccount: 'seat_005', followResult: '待跟进', isManualReach: '否', aiUserType: '中意向', dialogTag: '有意向', aiAssignTime: '2026-06-11 08:45:00', lastAssignTime: '2026-06-12 15:30:00', assignHistory: '1次', isManualCall: '否', sceneId: 2 },
  { id: 6, customerName: '周八', phone: '186****7788', seatAccount: 'seat_006', followResult: '待跟进', isManualReach: '否', aiUserType: '高意向', dialogTag: '需回访', aiAssignTime: '2026-06-11 10:20:00', lastAssignTime: '2026-06-12 11:00:00', assignHistory: '2次', isManualCall: '否', sceneId: 3 },
  { id: 7, customerName: '吴九', phone: '139****2211', seatAccount: 'seat_007', followResult: '持续跟进', isManualReach: '是', aiUserType: '中意向', dialogTag: '待确认', aiAssignTime: '2026-06-09 16:00:00', lastAssignTime: '2026-06-12 13:15:00', assignHistory: '4次', isManualCall: '是', sceneId: 3 },
  { id: 8, customerName: '郑十', phone: '150****6655', seatAccount: 'seat_008', followResult: '待跟进', isManualReach: '否', aiUserType: '低意向', dialogTag: '未接通', aiAssignTime: '2026-06-12 09:00:00', lastAssignTime: '2026-06-12 09:00:00', assignHistory: '1次', isManualCall: '否', sceneId: 2 },
  { id: 9, customerName: '钱十一', phone: '136****4455', seatAccount: 'seat_009', followResult: '待跟进', isManualReach: '否', aiUserType: '高意向', dialogTag: '有意向', aiAssignTime: '2026-06-12 10:30:00', lastAssignTime: '2026-06-12 10:30:00', assignHistory: '1次', isManualCall: '否', sceneId: 5 },
  { id: 10, customerName: '陈十二', phone: '158****7766', seatAccount: 'seat_010', followResult: '持续跟进', isManualReach: '是', aiUserType: '中意向', dialogTag: '需跟进', aiAssignTime: '2026-06-11 15:00:00', lastAssignTime: '2026-06-12 16:00:00', assignHistory: '2次', isManualCall: '是', sceneId: 5 }
])

// ============ 过滤后的任务列表 ============
const filteredTaskList = computed(() => {
  let list = [...taskList.value]

  // 按场景筛选
  if (selectedSceneId.value) {
    list = list.filter(task => task.sceneId === selectedSceneId.value)
  }

  // 按跟进状态筛选
  if (filterForm.followStatus) {
    const statusMap: Record<string, string> = {
      'pending': '待跟进',
      'following': '持续跟进',
      'converted': '明确转化',
      'rejected': '明确拒绝'
    }
    list = list.filter(task => task.followResult === statusMap[filterForm.followStatus as string])
  }

  return list
})

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

const handleSceneChange = (value: number) => {
  selectedSceneId.value = value
  message.info(`已切换到场景：${sceneList.value.find(s => s.id === value)?.name}`)
}

const handleStatusSelect = (status: string | undefined) => {
  filterForm.followStatus = status
}

const handleResetFilter = () => {
  selectedSceneId.value = 2
  filterForm.followStatus = undefined
  selectedTimeRange.value = '7days'
  message.success('筛选条件已重置')
}

const handleTaskClick = (task: TaskItem) => {
  router.push(`/mobile/task-detail/${task.id}`)
}

// ============ 跟进弹窗相关 ============
const followModalVisible = ref(false)
const followSubmitting = ref(false)
const currentFollowTask = ref<TaskItem | null>(null)

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

const handleFollow = (task: TaskItem) => {
  currentFollowTask.value = task
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

    // 更新任务列表中的跟进结果
    if (currentFollowTask.value) {
      const index = taskList.value.findIndex(t => t.id === currentFollowTask.value?.id)
      if (index !== -1) {
        taskList.value[index].followResult = followForm.followResult
      }
    }
  }, 500)
}

const handleCall = (task: TaskItem) => {
  message.info(`呼叫：${task.phone}`)
}
</script>

<style scoped>
.mobile-workbench {
  min-height: 100vh;
  background: #f5f7fa;
  padding-bottom: 16px;
}

/* 统计卡片区域 */
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

/* 筛选区域 */
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

/* 任务列表区域 */
.task-section {
  margin: 16px;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.task-header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.task-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #1a3a5c;
}

.task-count {
  font-size: 13px;
  color: #8c9bab;
}

.count-num {
  color: #2b6ff2;
  font-weight: 600;
}

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
  width: 100%;
  height: 300px;
}

/* 自定义地图标记 */
:deep(.custom-marker) {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  transition: transform 0.2s;
}

:deep(.custom-marker:hover) {
  transform: scale(1.2);
}

:deep(.custom-marker.pending) {
  background: #fa8c16;
}

:deep(.custom-marker.following) {
  background: #1890ff;
}

:deep(.custom-marker.converted) {
  background: #52c41a;
}

:deep(.custom-marker.rejected) {
  background: #ff4d4f;
}

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

/* 空状态 */
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

/* 跟进弹窗样式 */
.follow-modal :deep(.ant-modal) {
  top: 50%;
  transform: translateY(-50%);
  margin: 0 auto;
}

.follow-customer-info {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 16px;
}

.follow-customer-info .customer-name {
  font-size: 16px;
  font-weight: 600;
  color: #1a3a5c;
}

.follow-customer-info .customer-phone {
  font-size: 13px;
  color: #8c9bab;
  margin-top: 4px;
}

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

/* 响应式调整 */
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
</style>
