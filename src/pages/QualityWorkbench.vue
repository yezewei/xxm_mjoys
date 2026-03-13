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
              v-for="task in taskList"
              :key="task.id"
              class="task-card"
              :class="{ 'active': selectedTaskId === task.id }"
              @click="selectTask(task)"
            >
              <div class="task-header">
                <div class="task-icon">
                  <RobotOutlined class="ai-icon" />
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
                <a-tag color="blue">{{ task.tag }}</a-tag>
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
                <span class="item-label">审核员：</span>
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
              <div class="progress-group">
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
                  <span class="progress-label">人工审核进度</span>
                  <span class="progress-detail">{{ manualProgressPercent }}% {{ currentTask?.manualCount || 0 }}/{{ currentTask?.totalCount || 0 }}</span>
                </div>
              </div>
            </div>
          </div>
        </a-card>

        <!-- 筛选区域 -->
        <div class="filter-card">
          <div class="intent-toolbar">
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
                  v-model:value="filterForm.agent"
                  placeholder="请选择分配坐席"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="agent1">坐席 A</a-select-option>
                  <a-select-option value="agent2">坐席 B</a-select-option>
                  <a-select-option value="agent3">坐席 C</a-select-option>
                </a-select>
                <a-select
                  v-model:value="filterForm.aiStatus"
                  placeholder="请选择 AI 质检状态"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="success">已成功</a-select-option>
                  <a-select-option value="failed">已失败</a-select-option>
                  <a-select-option value="processing">处理中</a-select-option>
                </a-select>
              </a-space>
            </div>
          </div>
          <div class="intent-toolbar" style="margin-top: 12px;">
            <div class="toolbar-left">
              <a-space>
                <a-select
                  v-model:value="filterForm.manualStatus"
                  placeholder="请选择人工审核状态"
                  allow-clear
                  style="width: 180px"
                >
                  <a-select-option value="pending">未开始</a-select-option>
                  <a-select-option value="processing">审核中</a-select-option>
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
              showTotal: (total) => `共 ${total} 条`
            }"
            :scroll="{ x: 1200 }"
            row-key="id"
            class="quality-table"
          >
            <template #bodyCell="{ column, record }">
              <!-- AI 质检状态 -->
              <template v-if="column.key === 'aiStatus'">
                <a-tag :color="record.aiStatus === '已失败' ? 'red' : record.aiStatus === '已成功' ? 'green' : 'blue'" class="status-tag">
                  {{ record.aiStatus }}
                </a-tag>
              </template>
              <!-- 人工审核状态 -->
              <template v-else-if="column.key === 'manualStatus'">
                <a-tag :color="record.manualStatus === '未开始' ? 'default' : record.manualStatus === '已完成' ? 'green' : 'blue'" class="status-tag">
                  {{ record.manualStatus }}
                </a-tag>
              </template>
              <!-- 触发质检规则 -->
              <template v-else-if="column.key === 'triggerRule'">
                <span v-if="record.triggerRule">{{ record.triggerRule }}</span>
                <span v-else>-</span>
              </template>
              <!-- 操作 -->
              <template v-else-if="column.key === 'action'">
                <a-space>
                  <a class="action-link" @click="() => openQualityDetail(record)">质检详情</a>
                  <a class="action-link" @click="() => handleRetry(record)">重试</a>
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
import {
  RobotOutlined,
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
  aiStatus: '已成功' | '已失败' | '处理中'
  manualStatus: '未开始' | '审核中' | '已完成'
  triggerRule: string
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
    name: 'test2026.2.9__19:20',
    model: '合规质检',
    progress: '0/265 0%',
    tag: '人工外呼录音',
    totalCount: 265,
    aiCount: 0,
    manualCount: 0,
    auditor: 'yezewei',
    description: 'test2026.2.9__19:20'
  },
  {
    id: 28,
    name: 'test2026.2.10__10:30',
    model: '营销意向',
    progress: '50/200 25%',
    tag: '人工外呼录音',
    totalCount: 200,
    aiCount: 50,
    manualCount: 20,
    auditor: 'zhangsan',
    description: '2026 年 2 月 10 日上午外呼任务'
  },
  {
    id: 29,
    name: 'test2026.2.10__14:00',
    model: '投诉倾向',
    progress: '100/180 55%',
    tag: '客服录音',
    totalCount: 180,
    aiCount: 100,
    manualCount: 80,
    auditor: 'lisi',
    description: '客服投诉专线质检'
  },
  {
    id: 30,
    name: 'test2026.2.11__09:00',
    model: '合规质检（人工）',
    progress: '0/150 0%',
    tag: '人工外呼录音',
    totalCount: 150,
    aiCount: 0,
    manualCount: 0,
    auditor: 'wangwu',
    description: '新入职坐席专项质检'
  }
])

// ============ 当前选中任务 ============
const currentTask = computed(() => {
  return taskList.value.find(t => t.id === selectedTaskId.value) || null
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
const columns = [
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
  },
  {
    title: '分配坐席',
    dataIndex: 'agent',
    key: 'agent',
    width: 120
  },
  {
    title: 'AI 质检状态',
    dataIndex: 'aiStatus',
    key: 'aiStatus',
    width: 120
  },
  {
    title: '人工审核状态',
    dataIndex: 'manualStatus',
    key: 'manualStatus',
    width: 120
  },
  {
    title: '触发质检规则',
    dataIndex: 'triggerRule',
    key: 'triggerRule',
    width: 150
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right'
  }
]

// ============ 表格数据 ============
const tableData = ref<TableDataItem[]>([
  {
    id: 1,
    detailId: 3480,
    callId: 2674,
    agent: 'shxy006',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: ''
  },
  {
    id: 2,
    detailId: 3483,
    callId: 2679,
    agent: 'hnzxyjh01',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: ''
  },
  {
    id: 3,
    detailId: 3488,
    callId: 2689,
    agent: 'hnzxyjh01',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: ''
  },
  {
    id: 4,
    detailId: 3482,
    callId: 2678,
    agent: 'hnzxyjh01',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: ''
  },
  {
    id: 5,
    detailId: 3479,
    callId: 2670,
    agent: 'hnzhzx01',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: ''
  },
  {
    id: 6,
    detailId: 3481,
    callId: 2677,
    agent: 'hnzxyjh01',
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: ''
  }
])

// ============ 选中行 ============
const selectedRowKeys = ref<number[]>([])

// ============ 质检详情弹窗 ============
const qualityDetailRef = ref()

// ============ 方法 ============
// 打开质检详情
const openQualityDetail = (record: TableDataItem) => {
  console.log('打开质检详情:', record)
  console.log('qualityDetailRef:', qualityDetailRef.value)
  if (qualityDetailRef.value) {
    qualityDetailRef.value.open()
  } else {
    console.error('qualityDetailRef 为空')
  }
}

// 重试
const handleRetry = (record: TableDataItem) => {
  console.log('重试:', record)
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
  background: #e6f4ff;
  border-radius: 4px;
}

.ai-icon {
  font-size: 16px;
  color: #1677ff;
}

.task-name {
  font-weight: 500;
  color: #1f2329;
  font-size: 14px;
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
