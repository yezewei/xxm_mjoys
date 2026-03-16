<template>
  <div class="quality-inspection-workbench">
    <a-row :gutter="16" class="main-container">
      <!-- 左侧任务列表区域 -->
      <a-col :span="6" class="left-panel" v-show="!leftPanelCollapsed">
        <div class="task-list-container">
          <!-- 搜索框 -->
          <div class="search-box">
            <a-input-search
              v-model:value="searchKeyword"
              placeholder="请输入任务名称或 ID 搜索"
              enter-button="搜索"
              @search="handleSearch"
              class="task-search"
            />
          </div>

          <!-- 标签切换 -->
          <div class="tab-switch">
            <a-radio-group v-model:value="activeTab" button-style="solid">
              <a-radio-button value="todo">待办任务</a-radio-button>
              <a-radio-button value="all">全部任务</a-radio-button>
            </a-radio-group>
          </div>

          <!-- 任务卡片列表 -->
          <div class="task-list">
            <div
              v-for="task in filteredTaskList"
              :key="task.id"
              class="task-card"
              :class="{ 'active': selectedTaskId === task.id }"
              @click="selectTask(task)"
            >
              <div class="task-header">
                <div class="task-icon" :class="{ 'active': selectedTaskId === task.id }">
                  <!-- AI 图标：蓝色六边形宝石图标 -->
                  <svg v-if="getTaskType(task) === 'ai'" viewBox="0 0 24 24" width="22" height="22">
                    <defs>
                      <linearGradient id="aiGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" style="stop-color:#1677ff;stop-opacity:1" />
                        <stop offset="100%" style="stop-color:#0958d9;stop-opacity:1" />
                      </linearGradient>
                    </defs>
                    <path d="M12 2L4 7v10l8 5 8-5V7L12 2z" fill="url(#aiGradient)"/>
                    <text x="12" y="15.5" text-anchor="middle" fill="white" font-size="8" font-weight="600" font-family="Arial">AI</text>
                  </svg>
                  <!-- 人工图标：绿色圆形人像图标 -->
                  <svg v-else viewBox="0 0 24 24" width="22" height="22">
                    <defs>
                      <linearGradient id="manualGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" style="stop-color:#52c41a;stop-opacity:1" />
                        <stop offset="100%" style="stop-color:#389e0d;stop-opacity:1" />
                      </linearGradient>
                    </defs>
                    <circle cx="12" cy="12" r="10" fill="url(#manualGradient)"/>
                    <circle cx="12" cy="9" r="3.5" fill="white"/>
                    <path d="M12 13.5c-3.6 0-6.5 1.8-6.5 4.5v1h13v-1c0-2.7-2.9-4.5-6.5-4.5z" fill="white"/>
                  </svg>
                </div>
                <div class="task-name">{{ task.name }}</div>
              </div>
              <div class="task-info">
                <div class="info-row">
                  <span class="label">质检任务 ID：</span>
                  <span class="value">{{ task.id }}</span>
                </div>
                <div class="info-row">
                  <span class="label">质检模型：</span>
                  <span class="value">{{ task.model }}</span>
                </div>
                <div class="info-row">
                  <span class="label">质检进度：</span>
                  <span class="value">{{ task.progress }}</span>
                </div>
              </div>
              <div class="task-footer">
                <a-tag :color="getTaskType(task) === 'ai' ? 'blue' : 'green'">{{ task.tag }}</a-tag>
                <span class="follow-count">需跟进 {{ task.totalCount }} 个任务</span>
              </div>
            </div>
          </div>

          <!-- 底部分页 -->
          <div class="pagination-box">
            <span class="total-count">共 {{ totalTasks }} 条</span>
            <a-pagination
              v-model:current="currentPage"
              :total="totalTasks"
              :pageSize="10"
              show-less-items
              size="small"
            />
          </div>
        </div>
      </a-col>

      <!-- 右侧详情区域 -->
      <a-col :span="18" v-show="!leftPanelCollapsed" class="right-panel">
        <!-- 任务信息卡片 -->
        <a-card class="task-info-card">
          <div class="card-header">
            <RobotOutlined class="ai-icon-large" />
            <span class="card-title">{{ currentTask?.name || '请选择任务' }}</span>
          </div>
          <div class="info-content">
            <div class="info-row">
              <div class="info-item">
                <span class="item-label">质检模型：</span>
                <span class="item-value">{{ currentTask?.model || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="item-label">质检员：</span>
                <span class="item-value">{{ currentTask?.auditor || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="item-label">质检对象：</span>
                <a class="item-link">人工通话录音</a>
                <span class="item-note">（新数据自动追加）</span>
              </div>
            </div>
            <div class="info-row">
              <div class="info-item">
                <span class="item-label">任务说明：</span>
                <span class="item-value">{{ currentTask?.description || '-' }}</span>
              </div>
              <div class="progress-group" v-if="getTaskType(currentTask) === 'ai'">
                <div class="progress-item">
                  <a-progress
                    type="circle"
                    :percent="aiProgressPercent"
                    :format="() => `${aiProgressPercent}%`"
                    size="small"
                    stroke-color="#1677ff"
                  />
                  <span class="progress-label">AI 质检进度</span>
                  <span class="progress-detail">{{ aiProgressPercent }}% {{ currentTask?.aiCount || 0 }}/{{ currentTask?.totalCount || 0 }}</span>
                </div>
                <div class="progress-item">
                  <a-progress
                    type="circle"
                    :percent="manualProgressPercent"
                    :format="() => `${manualProgressPercent}%`"
                    size="small"
                    stroke-color="#1677ff"
                  />
                  <span class="progress-label">人工质检进度</span>
                  <span class="progress-detail">{{ manualProgressPercent }}% {{ currentTask?.manualCount || 0 }}/{{ currentTask?.totalCount || 0 }}</span>
                </div>
              </div>
              <div class="progress-group" v-else>
                <div class="progress-item">
                  <a-progress
                    type="circle"
                    :percent="manualProgressPercent"
                    :format="() => `${manualProgressPercent}%`"
                    size="small"
                    stroke-color="#52c41a"
                  />
                  <span class="progress-label">人工质检进度</span>
                  <span class="progress-detail">{{ manualProgressPercent }}% {{ currentTask?.manualCount || 0 }}/{{ currentTask?.totalCount || 0 }}</span>
                </div>
              </div>
            </div>
          </div>
        </a-card>

        <!-- 筛选区域 -->
        <div class="filter-card">
          <div class="intent-toolbar" v-if="getTaskType(currentTask) === 'ai'">
            <div class="toolbar-left">
              <a-space>
                <a-input
                  v-model:value="filterForm.detailId"
                  placeholder="请输入质检任务明细 ID"
                  style="width: 180px"
                  allow-clear
                />
                <a-input
                  v-model:value="filterForm.callId"
                  placeholder="请输入通话记录 ID"
                  style="width: 180px"
                  allow-clear
                />
                <a-select
                  v-model:value="filterForm.aiStatus"
                  placeholder="请选择 AI 质检状态"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="pending">未开始</a-select-option>
                  <a-select-option value="completed">已完成</a-select-option>
                  <a-select-option value="failed">已失败</a-select-option>
                </a-select>
                <a-select
                  v-model:value="filterForm.manualStatus"
                  placeholder="请选择人工质检状态"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="pending">未开始</a-select-option>
                  <a-select-option value="completed">已完成</a-select-option>
                </a-select>
              </a-space>
            </div>
          </div>
          <div class="intent-toolbar" v-else>
            <div class="toolbar-left">
              <a-space>
                <a-input
                  v-model:value="filterForm.detailId"
                  placeholder="请输入质检任务明细 ID"
                  style="width: 180px"
                  allow-clear
                />
                <a-input
                  v-model:value="filterForm.callId"
                  placeholder="请输入通话记录 ID"
                  style="width: 180px"
                  allow-clear
                />
                <a-select
                  v-model:value="filterForm.manualStatus"
                  placeholder="请选择人工质检状态"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="pending">未开始</a-select-option>
                  <a-select-option value="completed">已完成</a-select-option>
                </a-select>
                <a-select
                  v-model:value="filterForm.isModified"
                  placeholder="请选择是否人工修改"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="yes">是</a-select-option>
                  <a-select-option value="no">否</a-select-option>
                </a-select>
              </a-space>
            </div>
          </div>
          <div class="intent-toolbar" style="margin-top: 12px;">
            <div class="toolbar-left">
              <a-space>
                <a-select
                  v-model:value="filterForm.isModified"
                  placeholder="请选择是否人工修改"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="yes">是</a-select-option>
                  <a-select-option value="no">否</a-select-option>
                </a-select>
                <a-select
                  v-model:value="filterForm.triggerItem"
                  placeholder="请选择触发质检项"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="item1">服务态度</a-select-option>
                  <a-select-option value="item2">业务规范</a-select-option>
                  <a-select-option value="item3">合规要求</a-select-option>
                </a-select>
                <a-button type="primary" @click="handleFilterSearch">
                  <SearchOutlined />
                  搜索
                </a-button>
                <a-button @click="handleReset">
                  <ReloadOutlined />
                  重置
                </a-button>
              </a-space>
            </div>
          </div>
        </div>

        <!-- 数据表格 -->
        <a-card class="table-card">
          <div class="table-header-info">
            <span>共 {{ tableData.length }} 条，已选 {{ selectedRowKeys.length }} 条</span>
          </div>
          <a-table
            :columns="columns"
            :data-source="tableData"
            :row-selection="{
              selectedRowKeys: selectedRowKeys,
              onChange: onSelectChange
            }"
            :pagination="{
              pageSize: 10,
              showSizeChanger: true,
              showQuickJumper: true,
              showTotal: (total) => `共 ${total} 条`,
              locale: {
                items_per_page: '条/页',
                jump_to: '前往',
                page: '页'
              }
            }"
            :scroll="{ x: 1200 }"
            row-key="id"
            class="quality-table"
          >
            <template #bodyCell="{ column, record }">
              <!-- AI 质检状态 -->
              <template v-if="column.key === 'aiStatus'">
                <a-tag :color="record.aiStatus === '已失败' ? 'red' : record.aiStatus === '已完成' ? 'green' : 'default'" class="status-tag">
                  {{ record.aiStatus }}
                </a-tag>
              </template>
              <!-- 人工质检状态 -->
              <template v-else-if="column.key === 'manualStatus'">
                <a-tag :color="record.manualStatus === '已完成' ? 'green' : 'default'" class="status-tag">
                  {{ record.manualStatus }}
                </a-tag>
              </template>
              <!-- 是否人工修改 -->
              <template v-else-if="column.key === 'isModified'">
                <a-tag :color="record.isModified === '是' ? 'orange' : 'default'" class="status-tag">
                  {{ record.isModified || '否' }}
                </a-tag>
              </template>
              <!-- 触发质检规则 -->
              <template v-else-if="column.key === 'triggerRule'">
                <span v-if="record.triggerRule">{{ record.triggerRule }}</span>
                <span v-else>-</span>
              </template>
              <!-- 质检总结 -->
              <template v-else-if="column.key === 'aiSummary'">
                <span v-if="record.aiSummary">{{ record.aiSummary }}</span>
                <span v-else>-</span>
              </template>
              <!-- 操作 -->
              <template v-else-if="column.key === 'action'">
                <a-space>
                  <a class="action-link" @click="() => openQualityDetail(record)">质检详情</a>
                  <a v-if="getTaskType(currentTask) === 'ai' && record.aiStatus === '已失败'" class="action-link" @click="() => handleRetry(record)">重试</a>
                </a-space>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>
    
    <!-- 质检详情弹窗 -->
    <QualityDetailModal ref="qualityDetailRef" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { message, Modal } from 'ant-design-vue'
import {
  LeftOutlined,
  RightOutlined,
  ReloadOutlined,
  SearchOutlined
} from '@ant-design/icons-vue'
import QualityDetailModal from '@/components/QualityDetailModal.vue'

// ============ 类型定义 ============
interface TaskItem {
  id: number
  name: string
  model: string
  progress: string
  tag: string
  totalCount: number
  aiCount: number
  manualCount: number
  auditor?: string
  description?: string
}

interface TableDataItem {
  id: number
  detailId: number
  callId: number
  agent: string
  aiStatus: '未开始' | '已完成' | '已失败'
  manualStatus: '未开始' | '已完成'
  triggerRule: string
  aiSummary?: string
  isModified?: '是' | '否'
}

interface FilterForm {
  detailId: string
  callId: string
  agent: string | undefined
  aiStatus: string | undefined
  manualStatus: string | undefined
  isModified: string | undefined
  triggerItem: string | undefined
}

// ============ 左侧任务列表状态 ============
const searchKeyword = ref('')
const activeTab = ref<'todo' | 'all'>('todo')
const selectedTaskId = ref<number | null>(27)
const currentPage = ref(1)
const totalTasks = ref(4)
const leftPanelCollapsed = ref(false)

// ============ 任务列表数据 ============
const taskList = ref<TaskItem[]>([
  {
    id: 27,
    name: '2026 年 2 月金融产品合规质检专项',
    model: '合规质检',
    progress: '0/265 0%',
    tag: '人工外呼录音',
    totalCount: 265,
    aiCount: 0,
    manualCount: 0,
    auditor: '张三',
    description: '2026 年 2 月金融产品外呼合规性检测专项任务'
  },
  {
    id: 28,
    name: '2026 年 2 月营销活动客户意向分析',
    model: '营销意向',
    progress: '50/200 25%',
    tag: '人工外呼录音',
    totalCount: 200,
    aiCount: 50,
    manualCount: 20,
    auditor: '李四',
    description: '2026 年 2 月营销活动客户购买意向识别与分析'
  },
  {
    id: 29,
    name: '2026 年 2 月客服投诉专线质检',
    model: '投诉倾向',
    progress: '100/180 55%',
    tag: '人工外呼录音',
    totalCount: 180,
    aiCount: 100,
    manualCount: 80,
    auditor: '王五',
    description: '客服投诉专线通话质量监测与客户情绪分析'
  },
  {
    id: 30,
    name: '2026 年 2 月新入职坐席合规质检（人工）',
    model: '合规质检（人工）',
    progress: '0/150 0%',
    tag: '人工外呼录音',
    totalCount: 150,
    aiCount: 0,
    manualCount: 0,
    auditor: '赵六',
    description: '新入职坐席服务规范与合规性人工专项质检'
  }
])

// ============ 当前选中任务 ============
const currentTask = computed(() => {
  return taskList.value.find(t => t.id === selectedTaskId.value) || null
})

// ============ 过滤后的任务列表 ============
const filteredTaskList = computed(() => {
  let list = taskList.value
  
  // 按待办/全部过滤
  if (activeTab.value === 'todo') {
    list = list.filter(task => task.aiCount < task.totalCount || task.manualCount < task.totalCount)
  }
  
  // 按关键词搜索
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    list = list.filter(task => 
      task.name.toLowerCase().includes(keyword) || 
      task.id.toString().includes(keyword)
    )
  }
  
  return list
})

// ============ 进度计算 ============
const aiProgressPercent = computed(() => {
  if (!currentTask.value) return 0
  return Math.round((currentTask.value.aiCount / currentTask.value.totalCount) * 100)
})

const manualProgressPercent = computed(() => {
  if (!currentTask.value) return 0
  return Math.round((currentTask.value.manualCount / currentTask.value.totalCount) * 100)
})

// ============ 筛选表单 ============
const filterForm = reactive<FilterForm>({
  detailId: '',
  callId: '',
  agent: undefined,
  aiStatus: undefined,
  manualStatus: undefined,
  isModified: undefined,
  triggerItem: undefined
})

// ============ 表格列定义 ============
const columns = computed(() => {
  const baseColumns = [
    {
      title: '质检任务明细 ID',
      dataIndex: 'detailId',
      key: 'detailId',
      width: 150
    },
    {
      title: '通话记录 ID',
      dataIndex: 'callId',
      key: 'callId',
      width: 150
    }
  ]

  // AI 质检任务列
  if (currentTask.value && getTaskType(currentTask.value) === 'ai') {
    baseColumns.push(
      {
        title: 'AI 质检状态',
        dataIndex: 'aiStatus',
        key: 'aiStatus',
        width: 120
      },
      {
        title: '人工质检状态',
        dataIndex: 'manualStatus',
        key: 'manualStatus',
        width: 120
      },
      {
        title: '是否人工修改',
        dataIndex: 'isModified',
        key: 'isModified',
        width: 120
      },
      {
        title: '触发质检规则',
        dataIndex: 'triggerRule',
        key: 'triggerRule',
        width: 150
      },
      {
        title: '质检总结',
        dataIndex: 'aiSummary',
        key: 'aiSummary',
        width: 200,
        ellipsis: true
      }
    )
  } else {
    // 人工质检任务列
    baseColumns.push(
      {
        title: '人工质检状态',
        dataIndex: 'manualStatus',
        key: 'manualStatus',
        width: 120
      },
      {
        title: '触发质检规则',
        dataIndex: 'triggerRule',
        key: 'triggerRule',
        width: 150
      }
    )
  }

  baseColumns.push({
    title: '操作',
    key: 'action',
    width: currentTask.value && getTaskType(currentTask.value) === 'ai' ? 150 : 100,
    fixed: 'right'
  })

  return baseColumns
})

// ============ 表格数据 ============
const tableData = ref<TableDataItem[]>([
  {
    id: 1,
    detailId: 3480,
    callId: 2674,
    agent: '张三',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: '',
    aiSummary: '',
    isModified: '否'
  },
  {
    id: 2,
    detailId: 3483,
    callId: 2679,
    agent: '李四',
    aiStatus: '已完成',
    manualStatus: '未开始',
    triggerRule: '服务态度，业务规范',
    aiSummary: '客户通话过程中表现出较强的投诉倾向，坐席沟通态度良好，但业务解释不够清晰',
    isModified: '是'
  },
  {
    id: 3,
    detailId: 3488,
    callId: 2689,
    agent: '王五',
    aiStatus: '已完成',
    manualStatus: '未开始',
    triggerRule: '合规要求',
    aiSummary: '坐席未按要求进行风险提示，需要补充合规话术',
    isModified: '否'
  },
  {
    id: 4,
    detailId: 3482,
    callId: 2678,
    agent: '赵六',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: '',
    aiSummary: '',
    isModified: '否'
  },
  {
    id: 5,
    detailId: 3479,
    callId: 2670,
    agent: '孙七',
    aiStatus: '已完成',
    manualStatus: '已完成',
    triggerRule: '营销意向',
    aiSummary: '客户表现出明确的购买意向，坐席成功引导客户完成产品介绍，建议后续跟进',
    isModified: '是'
  },
  {
    id: 6,
    detailId: 3481,
    callId: 2677,
    agent: '周八',
    aiStatus: '未开始',
    manualStatus: '未开始',
    triggerRule: '',
    aiSummary: '',
    isModified: '否'
  }
])

// ============ 选中行 ============
const selectedRowKeys = ref<number[]>([])

// ============ 质检详情弹窗 ============
const qualityDetailRef = ref()

// ============ 方法 ============
// 获取任务类型
const getTaskType = (task: TaskItem): 'ai' | 'manual' => {
  if (task.model.includes('（人工）')) {
    return 'manual'
  }
  // 如果人工审核数量大于 0，也视为人工质检任务
  if (task.manualCount > 0 && task.aiCount === 0) {
    return 'manual'
  }
  return 'ai'
}

// 打开质检详情
const openQualityDetail = (record: TableDataItem) => {
  console.log('打开质检详情:', record)
  console.log('qualityDetailRef:', qualityDetailRef.value)
  const taskType = currentTask.value ? getTaskType(currentTask.value) : 'ai'
  if (qualityDetailRef.value) {
    qualityDetailRef.value.open(taskType)
  } else {
    console.error('qualityDetailRef 为空')
  }
}

// 重试
const handleRetry = (record: TableDataItem) => {
  Modal.confirm({
    title: '确认重试',
    content: '确认将当前任务重新进行 AI 质检？',
    okText: '确认',
    cancelText: '取消',
    onOk: () => {
      console.log('重试:', record)
      message.success('操作成功')
    }
  })
}

const handleSearch = () => {
  console.log('搜索任务:', searchKeyword.value)
}

const selectTask = (task: TaskItem) => {
  selectedTaskId.value = task.id
  console.log('选中任务:', task)
}

const toggleLeftPanel = () => {
  leftPanelCollapsed.value = !leftPanelCollapsed.value
}

const handleReset = () => {
  filterForm.detailId = ''
  filterForm.callId = ''
  filterForm.agent = undefined
  filterForm.aiStatus = undefined
  filterForm.manualStatus = undefined
  filterForm.isModified = undefined
  filterForm.triggerItem = undefined
}

const handleFilterSearch = () => {
  console.log('筛选条件:', filterForm)
}

const onSelectChange = (selectedKeys: number[]) => {
  selectedRowKeys.value = selectedKeys
}
</script>

<style scoped>
.quality-inspection-workbench {
  padding: 16px;
  background-color: #f5f7fb;
  min-height: 100vh;
}

.main-container {
  height: calc(100vh - 32px);
}

/* 左侧面板样式 */
.left-panel {
  height: 100%;
  overflow: visible;
  position: relative;
}

.task-list-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
  position: relative;
}

.search-box {
  margin-bottom: 12px;
}

.task-search :deep(.ant-input-search-button) {
  background-color: #1677ff;
  border-color: #1677ff;
}

.tab-switch {
  margin-bottom: 12px;
  width: 100%;
}

.tab-switch :deep(.ant-radio-group) {
  display: flex;
  width: 100%;
}

.tab-switch :deep(.ant-radio-button-wrapper) {
  flex: 1;
  text-align: center;
}

.tab-switch :deep(.ant-radio-button-wrapper-checked) {
  color: #fff;
  background-color: #1677ff;
  border-color: #1677ff;
}

.task-list {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 12px;
}

.task-card {
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 12px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.task-card:hover {
  border-color: #1677ff;
  box-shadow: 0 2px 8px rgba(22, 119, 255, 0.15);
}

.task-card.active {
  border-color: #1677ff;
  background-color: #e6f7ff;
}

.task-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.task-icon {
  margin-right: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #fff;
  border-radius: 4px;
  flex-shrink: 0;
}

.task-icon.active {
  background: transparent;
}

.task-name {
  font-weight: 500;
  color: #1f2329;
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.task-info {
  margin-bottom: 12px;
}

.info-row {
  display: flex;
  margin-bottom: 6px;
  font-size: 13px;
}

.info-row .label {
  color: #8f959e;
  flex-shrink: 0;
}

.info-row .value {
  color: #595959;
}

.task-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}

.follow-count {
  font-size: 12px;
  color: #8f959e;
}

.pagination-box {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 12px;
  border-top: 1px solid #e8e8e8;
}

.total-count {
  font-size: 12px;
  color: #8f959e;
}

/* 右侧面板样式 */
.right-panel {
  height: 100%;
  overflow-y: auto;
}

.task-info-card {
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}

.ai-icon-large {
  font-size: 20px;
  color: #1677ff;
  margin-right: 8px;
}

.card-title {
  font-size: 16px;
  font-weight: 500;
  color: #1f2329;
}

.info-content {
  margin-bottom: 0;
}

.info-row {
  display: flex;
  margin-bottom: 12px;
  gap: 24px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-item {
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.item-label {
  color: #8f959e;
  margin-right: 8px;
}

.item-value {
  color: #595959;
}

.item-link {
  color: #1677ff;
}

.item-note {
  color: #8f959e;
  font-size: 12px;
  margin-left: 4px;
}

.progress-group {
  display: flex;
  align-items: center;
  gap: 24px;
}

.progress-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.progress-label {
  font-size: 13px;
  color: #595959;
}

.progress-detail {
  font-size: 12px;
  color: #8f959e;
}

/* 筛选卡片样式 */
.filter-card {
  margin-bottom: 16px;
  background: #fff;
  padding: 16px;
  border-radius: 4px;
}

.intent-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toolbar-right {
  display: flex;
  align-items: center;
}

/* 表格卡片样式 */
.table-card {
  background: #fff;
}

.table-header-info {
  margin-bottom: 12px;
  font-size: 13px;
  color: #595959;
}

.quality-table :deep(.ant-table-thead > tr > th) {
  background-color: #e6f4ff;
  color: #1f2329;
  font-weight: 500;
}

.quality-table :deep(.ant-table-tbody > tr) {
  height: 45px;
}

.quality-table :deep(.ant-table-tbody > tr:hover > td) {
  background-color: #fafafa;
}

.status-tag {
  border-radius: 2px;
  font-size: 12px;
  padding: 2px 8px;
}

.action-link {
  color: #1677ff;
  cursor: pointer;
}

.action-link:hover {
  text-decoration: underline;
}

/* 滚动条样式 */
.task-list::-webkit-scrollbar {
  width: 6px;
}

.task-list::-webkit-scrollbar-thumb {
  background-color: #d9d9d9;
  border-radius: 3px;
}

.task-list::-webkit-scrollbar-thumb:hover {
  background-color: #bfbfbf;
}

.right-panel::-webkit-scrollbar {
  width: 6px;
}

.right-panel::-webkit-scrollbar-thumb {
  background-color: #d9d9d9;
  border-radius: 3px;
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .left-panel {
    display: none;
  }
}
</style>
