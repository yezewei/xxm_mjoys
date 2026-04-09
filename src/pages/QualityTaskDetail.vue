<template>
  <div class="quality-task-detail">
    <div class="detail-wrapper">
      <!-- 任务信息卡片 -->
      <a-card class="task-info-card">
        <div class="card-header">
          <span class="card-title">{{ currentTask?.taskName || '请选择任务' }}</span>
          <a-tag :color="activeTab === 'ai' ? 'blue' : 'green'" class="task-type-tag">
            {{ activeTab === 'ai' ? 'AI 质检' : '人工质检' }}
          </a-tag>
        </div>
        <div class="info-content">
          <div class="info-row">
            <div class="info-item">
              <span class="item-label">质检模型：</span>
              <span class="item-value">{{ currentTask?.qualityModel || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="item-label">质检员：</span>
              <span class="item-value">{{ currentTask?.auditor || currentTask?.creator || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="item-label">质检对象：</span>
              <span class="item-value">{{ currentTask?.qualityObject || '-' }}</span>
              <span class="item-note" v-if="currentTask?.autoAppend">（新数据自动追加）</span>
            </div>
          </div>
          <div class="info-row">
            <div class="info-item">
              <span class="item-label">任务说明：</span>
              <span class="item-value">{{ currentTask?.taskDescription || '-' }}</span>
            </div>
            <div class="progress-group" v-if="activeTab === 'ai'">
              <div class="progress-item">
                <a-progress
                  type="circle"
                  :percent="currentTask?.aiProgressPercent || 0"
                  :format="(percent: number) => `${percent}%`"
                  size="small"
                  stroke-color="#1677ff"
                />
                <span class="progress-label">AI 质检进度</span>
                <span class="progress-detail">{{ currentTask?.aiProgressPercent || 0 }}% {{ currentTask?.aiCompleted || 0 }}/{{ currentTask?.aiTotal || 0 }}</span>
              </div>
              <div class="progress-item">
                <a-progress
                  type="circle"
                  :percent="manualProgressPercent"
                  :format="(percent: number) => `${percent}%`"
                  size="small"
                  stroke-color="#1677ff"
                />
                <span class="progress-label">人工质检进度</span>
                <span class="progress-detail">{{ manualProgressPercent }}% {{ currentTask?.manualCount || 0 }}/{{ currentTask?.aiTotal || 0 }}</span>
              </div>
            </div>
            <div class="progress-group" v-else>
              <div class="progress-item">
                <a-progress
                  type="circle"
                  :percent="manualProgressPercent"
                  :format="(percent: number) => `${percent}%`"
                  size="small"
                  stroke-color="#52c41a"
                />
                <span class="progress-label">人工质检进度</span>
                <span class="progress-detail">{{ manualProgressPercent }}% {{ currentTask?.manualCount || 0 }}/{{ currentTask?.aiTotal || 0 }}</span>
              </div>
            </div>
          </div>
        </div>
      </a-card>

      <!-- 筛选区域 -->
      <div class="filter-card">
        <div class="intent-toolbar" v-if="activeTab === 'ai'">
          <a-input
            v-model:value="filterForm.detailId"
            placeholder="请输入质检任务明细 ID"
            class="filter-input"
            allow-clear
          />
          <a-input
            v-model:value="filterForm.callId"
            placeholder="请输入通话记录 ID"
            class="filter-input"
            allow-clear
          />
          <a-select
            v-model:value="filterForm.aiStatus"
            placeholder="请选择 AI 质检状态"
            class="filter-select"
            allow-clear
          >
            <a-select-option value="pending">未开始</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
            <a-select-option value="failed">已失败</a-select-option>
          </a-select>
          <a-select
            v-model:value="filterForm.manualStatus"
            placeholder="请选择人工质检状态"
            class="filter-select"
            allow-clear
          >
            <a-select-option value="pending">未开始</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
          </a-select>
        </div>
        <div class="intent-toolbar" v-else>
          <a-input
            v-model:value="filterForm.detailId"
            placeholder="请输入质检任务明细 ID"
            class="filter-input"
            allow-clear
          />
          <a-input
            v-model:value="filterForm.callId"
            placeholder="请输入通话记录 ID"
            class="filter-input"
            allow-clear
          />
          <a-select
            v-model:value="filterForm.manualStatus"
            placeholder="请选择人工质检状态"
            class="filter-select"
            allow-clear
          >
            <a-select-option value="pending">未开始</a-select-option>
            <a-select-option value="completed">已完成</a-select-option>
          </a-select>
          <a-select
            v-model:value="filterForm.isModified"
            placeholder="请选择是否人工修改"
            class="filter-select"
            allow-clear
          >
            <a-select-option value="yes">是</a-select-option>
            <a-select-option value="no">否</a-select-option>
          </a-select>
        </div>
        <div class="intent-toolbar">
          <a-select
            v-model:value="filterForm.isModified"
            placeholder="请选择是否人工修改"
            class="filter-select"
            allow-clear
          >
            <a-select-option value="yes">是</a-select-option>
            <a-select-option value="no">否</a-select-option>
          </a-select>
          <a-select
            v-model:value="filterForm.triggerItem"
            placeholder="请选择触发质检项"
            class="filter-select"
            allow-clear
          >
            <a-select-option value="item1">服务态度</a-select-option>
            <a-select-option value="item2">业务规范</a-select-option>
            <a-select-option value="item3">合规要求</a-select-option>
          </a-select>
          <div class="filter-buttons">
            <a-button type="primary" @click="handleFilterSearch">
              <search-outlined />
              搜索
            </a-button>
            <a-button @click="handleReset">
              <reload-outlined />
              重置
            </a-button>
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
          row-key="id"
          :pagination="false"
          :scroll="{ x: 1200 }"
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
                <a v-if="activeTab === 'ai' && record.aiStatus === '已失败'" class="action-link" @click="() => handleRetry(record)">重试</a>
              </a-space>
            </template>
          </template>
        </a-table>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <Pagination
            v-model:current="currentPage"
            v-model:page-size="pageSize"
            :total="tableData.length"
            @change="handlePageChange"
          />
        </div>
      </a-card>
    </div>

    <!-- 质检详情弹窗 -->
    <QualityDetailModal ref="qualityDetailRef" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { message, Modal } from 'ant-design-vue'
import {
  SearchOutlined,
  ReloadOutlined
} from '@ant-design/icons-vue'
import Pagination from '@/components/Pagination'
import QualityDetailModal from '@/components/QualityDetailModal.vue'

interface TableDataItem {
  id: number
  detailId: number
  callId: number
  aiStatus: string
  manualStatus: string
  triggerRule: string
  aiSummary: string
  isModified: string
}

interface FilterForm {
  detailId: string
  callId: string
  aiStatus: string | undefined
  manualStatus: string | undefined
  isModified: string | undefined
  triggerItem: string | undefined
}

const router = useRouter()
const route = useRoute()

// 从 URL 参数获取任务类型，默认为 'ai'
const taskTypeFromQuery = computed(() => {
  return (route.query.taskType as string) || 'ai'
})

const activeTab = ref<'ai' | 'manual'>('ai')
const currentPage = ref(1)
const pageSize = ref(10)
const selectedRowKeys = ref<number[]>([])
const currentTask = ref<any>(null)
const qualityDetailRef = ref<InstanceType<typeof QualityDetailModal>>()

const filterForm = reactive<FilterForm>({
  detailId: '',
  callId: '',
  aiStatus: undefined,
  manualStatus: undefined,
  isModified: undefined,
  triggerItem: undefined,
})

const columns = computed(() => {
  const baseColumns = [
    {
      title: '质检任务明细 ID',
      dataIndex: 'detailId',
      key: 'detailId',
      width: 150,
      ellipsis: true
    },
    {
      title: '通话记录 ID',
      dataIndex: 'callId',
      key: 'callId',
      width: 150,
      ellipsis: true
    }
  ]

  // AI 质检任务列
  if (activeTab.value === 'ai') {
    baseColumns.push(
      {
        title: 'AI 质检状态',
        dataIndex: 'aiStatus',
        key: 'aiStatus',
        width: 120,
        ellipsis: true
      },
      {
        title: '人工质检状态',
        dataIndex: 'manualStatus',
        key: 'manualStatus',
        width: 120,
        ellipsis: true
      },
      {
        title: '是否人工修改',
        dataIndex: 'isModified',
        key: 'isModified',
        width: 120,
        ellipsis: true
      },
      {
        title: '触发质检规则',
        dataIndex: 'triggerRule',
        key: 'triggerRule',
        width: 150,
        ellipsis: true
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
        width: 120,
        ellipsis: true
      },
      {
        title: '触发质检规则',
        dataIndex: 'triggerRule',
        key: 'triggerRule',
        width: 150,
        ellipsis: true
      }
    )
  }

  baseColumns.push({
    title: '操作',
    key: 'action',
    width: activeTab.value === 'ai' ? 150 : 100,
    fixed: 'right',
    ellipsis: true
  })

  return baseColumns
})

const mockTableData: TableDataItem[] = [
  {
    id: 1,
    detailId: 1001,
    callId: 5001,
    aiStatus: '已完成',
    manualStatus: '未开始',
    triggerRule: '服务态度',
    aiSummary: '客户表示满意',
    isModified: '否',
  },
  {
    id: 2,
    detailId: 1002,
    callId: 5002,
    aiStatus: '已完成',
    manualStatus: '已完成',
    triggerRule: '业务规范',
    aiSummary: '已按流程操作',
    isModified: '是',
  },
  {
    id: 3,
    detailId: 1003,
    callId: 5003,
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: '合规要求',
    aiSummary: '-',
    isModified: '否',
  },
]

const manualProgressPercent = computed(() => {
  if (!currentTask.value) return 0
  const total = currentTask.value.aiTotal || 0
  const completed = currentTask.value.manualCount || 0
  return total > 0 ? Math.round((completed / total) * 100) : 0
})

// 人工质检任务的模拟数据（类似 QualityWorkbench 中的"2026 年 2 月新入职坐席合规质检（人工）"）
const manualTaskMockData: TableDataItem[] = [
  {
    id: 1,
    detailId: 3480,
    callId: 2674,
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: '',
    aiSummary: '',
    isModified: '否',
  },
  {
    id: 2,
    detailId: 3483,
    callId: 2679,
    aiStatus: '已完成',
    manualStatus: '未开始',
    triggerRule: '服务态度，业务规范',
    aiSummary: '客户通话过程中表现出较强的投诉倾向，坐席沟通态度良好，但业务解释不够清晰',
    isModified: '是',
  },
  {
    id: 3,
    detailId: 3488,
    callId: 2689,
    aiStatus: '已完成',
    manualStatus: '未开始',
    triggerRule: '合规要求',
    aiSummary: '坐席未按要求进行风险提示，需要补充合规话术',
    isModified: '否',
  },
  {
    id: 4,
    detailId: 3482,
    callId: 2678,
    aiStatus: '已失败',
    manualStatus: '未开始',
    triggerRule: '',
    aiSummary: '',
    isModified: '否',
  },
  {
    id: 5,
    detailId: 3479,
    callId: 2670,
    aiStatus: '已完成',
    manualStatus: '已完成',
    triggerRule: '营销意向',
    aiSummary: '客户表现出明确的购买意向，坐席成功引导客户完成产品介绍，建议后续跟进',
    isModified: '是',
  },
  {
    id: 6,
    detailId: 3481,
    callId: 2677,
    aiStatus: '未开始',
    manualStatus: '未开始',
    triggerRule: '',
    aiSummary: '',
    isModified: '否',
  },
]

const tableData = computed(() => {
  // 根据任务类型返回不同的数据
  if (activeTab.value === 'manual') {
    return manualTaskMockData
  }
  return mockTableData
})

onMounted(() => {
  const taskId = Number(route.params.id)
  // 从 URL 参数获取任务类型
  const taskType = taskTypeFromQuery.value
  
  // 根据任务类型设置 activeTab 和加载不同的数据
  activeTab.value = taskType === 'manual' ? 'manual' : 'ai'
  
  // 模拟加载任务详情
  if (taskType === 'manual') {
    // 人工质检任务数据（类似 QualityWorkbench 中的"2026 年 2 月新入职坐席合规质检（人工）"）
    currentTask.value = {
      taskId: taskId,
      taskName: '2026 年 2 月新入职坐席合规质检（人工）',
      taskDescription: '新入职坐席服务规范与合规性人工专项质检',
      qualityModel: '合规质检（人工）',
      qualityObject: '人工外呼录音',
      creator: 'hzy',
      auditor: '赵六',
      aiProgressPercent: 0,
      aiCompleted: 0,
      aiTotal: 150,
      manualCount: 0,
      autoAppend: true,
    }
  } else {
    // AI 质检任务数据
    currentTask.value = {
      taskId: taskId,
      taskName: '2026 年 2 月金融产品合规质检专项',
      taskDescription: '2026 年 2 月金融产品外呼合规性检测专项任务',
      qualityModel: '合规质检',
      qualityObject: '人工外呼录音',
      creator: 'hzy',
      auditor: '张三',
      aiProgressPercent: 25,
      aiCompleted: 50,
      aiTotal: 200,
      manualCount: 20,
      autoAppend: true,
    }
  }
})

const handleViewDetail = (record: TableDataItem) => {
  message.info(`查看明细 ${record.detailId} 详情`)
}

const openQualityDetail = (record: TableDataItem) => {
  if (qualityDetailRef.value) {
    // 根据当前标签页传递任务类型
    qualityDetailRef.value.open(activeTab.value)
  }
}

const handleRetry = (record: TableDataItem) => {
  Modal.confirm({
    title: '重试确认',
    content: `确定要重试质检明细 ${record.detailId} 吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      message.success('重试成功')
    },
  })
}

const handlePageChange = (page: number, size: number) => {
  currentPage.value = page
  pageSize.value = size
  console.log('分页变化:', page, size)
}

const handleFilterSearch = () => {
  console.log('搜索条件:', filterForm)
  message.success('搜索成功')
}

const handleReset = () => {
  Object.assign(filterForm, {
    detailId: '',
    callId: '',
    aiStatus: undefined,
    manualStatus: undefined,
    isModified: undefined,
    triggerItem: undefined,
  })
  message.success('已重置搜索条件')
}

const onSelectChange = (selectedRowKeys: (string | number)[]) => {
  selectedRowKeys.value = selectedRowKeys as number[]
}
</script>

<style scoped>
.quality-task-detail {
  height: 100%;
  padding: 16px;
  background: #f5f7fa;
  overflow: auto;
}

.detail-wrapper {
  max-width: 1400px;
  margin: 0 auto;
}

/* 任务信息卡片 */
.task-info-card {
  margin-bottom: 16px;
}

.task-info-card :deep(.ant-card-body) {
  padding: 16px 24px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.ai-icon-large {
  width: 32px;
  height: 32px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
}

.task-type-tag {
  margin-left: 8px;
}

.info-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-row {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.item-label {
  color: #8c8c8c;
}

.item-value {
  color: #262626;
}

.item-link {
  color: #1677ff;
  cursor: pointer;
}

.item-note {
  color: #8c8c8c;
  font-size: 13px;
}

.progress-group {
  display: flex;
  gap: 32px;
  margin-top: 8px;
}

.progress-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-label {
  font-size: 14px;
  color: #595959;
}

.progress-detail {
  font-size: 13px;
  color: #8c8c8c;
}

/* 筛选区域 */
.filter-card {
  margin-bottom: 16px;
  background: #fff;
  border-radius: 4px;
  padding: 16px 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.filter-card :deep(.ant-card-body) {
  padding: 0;
}

.intent-toolbar {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 12px;
  align-items: center;
}

.intent-toolbar:last-child {
  margin-bottom: 0;
}

/* 筛选输入框和选择框统一宽度 */
.filter-input,
.filter-select {
  width: 100%;
}

.filter-input :deep(.ant-input),
.filter-select :deep(.ant-select-selector) {
  width: 100%;
}

/* 按钮容器 */
.filter-buttons {
  display: flex;
  gap: 8px;
  justify-content: flex-start;
}

/* 按钮保持默认尺寸 */
.filter-buttons :deep(.ant-btn) {
  /* 不使用 min-width，保持默认宽度 */
}

/* 表格卡片 */
.table-card {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.table-card :deep(.ant-card-body) {
  padding: 16px 24px;
}

.table-header-info {
  margin-bottom: 16px;
  font-size: 14px;
  color: #595959;
}

.table-card :deep(.ant-table-thead > tr > th) {
  background: #f0f5ff;
  font-weight: 600;
  color: #262626;
  white-space: nowrap;
}

.table-card :deep(.ant-table-thead > tr > th .ant-table-cell) {
  white-space: nowrap;
}

.table-card :deep(.ant-table-tbody > tr:hover > td) {
  background: #f0f5ff;
}

.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.action-link {
  color: #1677ff;
  cursor: pointer;
  text-decoration: none;
}

.action-link:hover {
  color: #4096ff;
}

.status-tag {
  font-size: 12px;
}
</style>
