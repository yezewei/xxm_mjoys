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
                v-model:value="filterForm.asrStatus"
                placeholder="请选择 ASR 识别状态"
                allow-clear
                style="width: 180px"
              >
                <a-select-option value="未完成">未完成</a-select-option>
                <a-select-option value="已完成">已完成</a-select-option>
              </a-select>
              <a-button type="primary" @click="handleFilterSearch">
                <search-outlined />
                搜索
              </a-button>
              <a-button @click="handleReset">
                <reload-outlined />
                重置
              </a-button>
              <a-button @click="drawerVisible = true">
                <search-outlined />
                高级搜索
              </a-button>
            </a-space>
          </div>
        </div>
      </div>

      <!-- 高级搜索抽屉 -->
      <a-drawer
        title="高级搜索"
        :open="drawerVisible"
        @close="drawerVisible = false"
        :width="480"
        :body-style="{ padding: '16px 24px' }"
        class="advanced-search-drawer"
      >
        <a-form layout="vertical">
          <a-form-item>
            <a-input
              v-model:value="filterForm.detailId"
              placeholder="质检任务明细 ID"
              allow-clear
            />
          </a-form-item>
          <a-form-item>
            <a-input
              v-model:value="filterForm.callId"
              placeholder="通话记录 ID"
              allow-clear
            />
          </a-form-item>
          <a-form-item>
            <a-select
              v-model:value="filterForm.asrStatus"
              placeholder="ASR 识别状态"
              allow-clear
              style="width: 100%"
            >
              <a-select-option value="未完成">未完成</a-select-option>
              <a-select-option value="已完成">已完成</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item v-if="activeTab === 'ai'">
            <a-select
              v-model:value="filterForm.aiStatus"
              placeholder="AI 质检状态"
              allow-clear
              style="width: 100%"
            >
              <a-select-option value="pending">未开始</a-select-option>
              <a-select-option value="completed">已完成</a-select-option>
              <a-select-option value="failed">已失败</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-select
              v-model:value="filterForm.manualStatus"
              placeholder="人工质检状态"
              allow-clear
              style="width: 100%"
            >
              <a-select-option value="pending">未开始</a-select-option>
              <a-select-option value="completed">已完成</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-select
              v-model:value="filterForm.isModified"
              placeholder="是否人工修改"
              allow-clear
              style="width: 100%"
            >
              <a-select-option value="yes">是</a-select-option>
              <a-select-option value="no">否</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-input v-model:value="filterForm.keywordRule" placeholder="关键词匹配质检项" allow-clear style="width: 100%" />
          </a-form-item>
          <a-form-item>
            <a-input v-model:value="filterForm.aiRule" placeholder="AI识别质检项" allow-clear style="width: 100%" />
          </a-form-item>
          <a-form-item>
            <a-input v-model:value="filterForm.manualRule" placeholder="人工标注质检项" allow-clear style="width: 100%" />
          </a-form-item>
          <a-form-item>
            <a-select
              v-model:value="filterForm.auditor"
              placeholder="质检员"
              allow-clear
              style="width: 100%"
            >
              <a-select-option
                v-for="option in auditorOptions"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item v-if="activeTab === 'ai'">
            <div class="score-range-group">
              <a-input-number
                v-model:value="filterForm.aiScoreMin"
                :min="0"
                :max="100"
                placeholder="AI评分最低"
                class="range-input"
                allow-clear
              />
              <span class="range-separator">~</span>
              <a-input-number
                v-model:value="filterForm.aiScoreMax"
                :min="0"
                :max="100"
                placeholder="AI评分最高"
                class="range-input"
                allow-clear
              />
            </div>
          </a-form-item>
          <a-form-item>
            <div class="score-range-group">
              <a-input-number
                v-model:value="filterForm.manualScoreMin"
                :min="0"
                :max="100"
                placeholder="人工评分最低"
                class="range-input"
                allow-clear
              />
              <span class="range-separator">~</span>
              <a-input-number
                v-model:value="filterForm.manualScoreMax"
                :min="0"
                :max="100"
                placeholder="人工评分最高"
                class="range-input"
                allow-clear
              />
            </div>
          </a-form-item>
        </a-form>
        <div class="drawer-footer">
          <a-button @click="handleReset" style="margin-right: 8px">重置</a-button>
          <a-button type="primary" @click="handleFilterSearch">搜索</a-button>
        </div>
      </a-drawer>

      <!-- 数据表格 -->
      <a-card class="table-card">
        <div class="table-header-info">
          <div class="table-header-left">
            <span>共 {{ tableData.length }} 条，已选 {{ selectedRowKeys.length }} 条</span>
          </div>
          <div class="table-header-right">
            <a-button
              type="primary"
              :disabled="selectedRowKeys.length === 0"
              @click="handleBatchAssign"
            >
              批量分配
            </a-button>
          </div>
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
            <!-- ASR 识别状态 -->
            <template v-if="column.key === 'asrStatus'">
              <a-tag :color="record.asrStatus === '已完成' ? 'green' : 'default'" class="status-tag">
                {{ record.asrStatus }}
              </a-tag>
            </template>
            <!-- AI 质检状态 -->
            <template v-else-if="column.key === 'aiStatus'">
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
            <!-- 关键词匹配质检项 -->
            <template v-else-if="column.key === 'keywordRules'">
              <span v-if="record.keywordRules">{{ record.keywordRules }}</span>
              <span v-else>-</span>
            </template>
            <!-- AI 识别质检项 -->
            <template v-else-if="column.key === 'aiRules'">
              <span v-if="record.aiRules">{{ record.aiRules }}</span>
              <span v-else>-</span>
            </template>
            <!-- 人工标注质检项 -->
            <template v-else-if="column.key === 'manualRules'">
              <span v-if="record.manualRules">{{ record.manualRules }}</span>
              <span v-else>-</span>
            </template>
            <!-- AI 质检总结 -->
            <template v-else-if="column.key === 'aiSummary'">
              <span v-if="record.aiSummary">{{ record.aiSummary }}</span>
              <span v-else>-</span>
            </template>
            <!-- 人工质检总结 -->
            <template v-else-if="column.key === 'manualSummary'">
              <span v-if="record.manualSummary">{{ record.manualSummary }}</span>
              <span v-else>-</span>
            </template>
            <!-- AI评分 -->
            <template v-else-if="column.key === 'aiScore'">
              <span v-if="record.aiScore != null" :style="{ color: record.aiScore >= 80 ? '#52c41a' : record.aiScore >= 60 ? '#faad14' : '#ff4d4f', fontWeight: 600 }">{{ record.aiScore }}</span>
              <span v-else>-</span>
            </template>
            <!-- 人工评分 -->
            <template v-else-if="column.key === 'manualScore'">
              <span v-if="record.manualScore != null" :style="{ color: record.manualScore >= 80 ? '#52c41a' : record.manualScore >= 60 ? '#faad14' : '#ff4d4f', fontWeight: 600 }">{{ record.manualScore }}</span>
              <span v-else>-</span>
            </template>
            <!-- 质检员 -->
            <template v-else-if="column.key === 'auditor'">
              <span>{{ record.auditor || '-' }}</span>
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

    <!-- 批量分配弹窗 -->
    <a-modal
      v-model:open="batchAssignVisible"
      title="批量分配"
      ok-text="确认"
      cancel-text="取消"
      @ok="handleBatchAssignConfirm"
      @cancel="handleBatchAssignCancel"
      :ok-button-props="{ disabled: !batchAssignForm.assignee }"
    >
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="已选数据">
          <span>已选择 {{ selectedRowKeys.length }} 条数据</span>
        </a-form-item>
        <a-form-item label="分配给" required>
          <a-select
            v-model:value="batchAssignForm.assignee"
            placeholder="请选择分配的账号"
            allow-clear
          >
            <a-select-option
              v-for="option in assigneeOptions"
              :key="option.value"
              :value="option.value"
            >
              {{ option.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
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
  asrStatus: string
  aiStatus: string
  manualStatus: string
  keywordRules: string
  aiRules: string
  manualRules: string
  aiSummary: string
  manualSummary: string
  isModified: string
  auditor: string
  aiScore?: number
  manualScore?: number
}

interface FilterForm {
  detailId: string
  callId: string
  asrStatus: string | undefined
  aiStatus: string | undefined
  manualStatus: string | undefined
  isModified: string | undefined
  keywordRule: string | undefined
  aiRule: string | undefined
  manualRule: string | undefined
  auditor: string | undefined
  aiScoreMin: number | undefined
  aiScoreMax: number | undefined
  manualScoreMin: number | undefined
  manualScoreMax: number | undefined
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
const drawerVisible = ref(false)
const selectedRowKeys = ref<number[]>([])
const currentTask = ref<any>(null)
const qualityDetailRef = ref<InstanceType<typeof QualityDetailModal>>()

const filterForm = reactive<FilterForm>({
  detailId: '',
  callId: '',
  asrStatus: undefined,
  aiStatus: undefined,
  manualStatus: undefined,
  isModified: undefined,
  keywordRule: undefined,
  aiRule: undefined,
  manualRule: undefined,
  auditor: undefined,
  aiScoreMin: undefined,
  aiScoreMax: undefined,
  manualScoreMin: undefined,
  manualScoreMax: undefined,
})

// 质检员选项
const auditorOptions = [
  { label: '张三', value: '张三' },
  { label: '李四', value: '李四' },
  { label: '王五', value: '王五' },
  { label: 'admin', value: 'admin' },
]

const columns = computed(() => {
  const baseColumns: any[] = [
    {
      title: '质检任务明细 ID',
      dataIndex: 'detailId',
      key: 'detailId',
      width: 150,
      ellipsis: true as any
    },
    {
      title: '通话记录 ID',
      dataIndex: 'callId',
      key: 'callId',
      width: 150,
      ellipsis: true as any
    },
    {
      title: 'ASR 识别状态',
      dataIndex: 'asrStatus',
      key: 'asrStatus',
      width: 120,
      ellipsis: true as any
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
        ellipsis: true as any
      },
      {
        title: '人工质检状态',
        dataIndex: 'manualStatus',
        key: 'manualStatus',
        width: 120,
        ellipsis: true as any
      },
      {
        title: '是否人工修改',
        dataIndex: 'isModified',
        key: 'isModified',
        width: 120,
        ellipsis: true as any
      },
      {
        title: '关键词匹配质检项',
        dataIndex: 'keywordRules',
        key: 'keywordRules',
        width: 160,
        ellipsis: true as any
      },
      {
        title: 'AI 识别质检项',
        dataIndex: 'aiRules',
        key: 'aiRules',
        width: 160,
        ellipsis: true as any
      },
      {
        title: '人工标注质检项',
        dataIndex: 'manualRules',
        key: 'manualRules',
        width: 160,
        ellipsis: true as any
      },
      {
        title: 'AI 质检总结',
        dataIndex: 'aiSummary',
        key: 'aiSummary',
        width: 200,
        ellipsis: true as any
      },
      {
        title: '人工质检总结',
        dataIndex: 'manualSummary',
        key: 'manualSummary',
        width: 200,
        ellipsis: true as any
      },
      {
        title: 'AI评分',
        dataIndex: 'aiScore',
        key: 'aiScore',
        width: 100,
        ellipsis: true as any
      },
      {
        title: '人工评分',
        dataIndex: 'manualScore',
        key: 'manualScore',
        width: 100,
        ellipsis: true as any
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
        ellipsis: true as any
      },
      {
        title: '关键词匹配质检项',
        dataIndex: 'keywordRules',
        key: 'keywordRules',
        width: 160,
        ellipsis: true as any
      },
      {
        title: '人工标注质检项',
        dataIndex: 'manualRules',
        key: 'manualRules',
        width: 160,
        ellipsis: true as any
      },
      {
        title: '人工质检总结',
        dataIndex: 'manualSummary',
        key: 'manualSummary',
        width: 200,
        ellipsis: true as any
      },
      {
        title: '人工评分',
        dataIndex: 'manualScore',
        key: 'manualScore',
        width: 100,
        ellipsis: true as any
      }
    )
  }

  // 审核员列
  baseColumns.push({
    title: '质检员',
    dataIndex: 'auditor',
    key: 'auditor',
    width: 150,
    ellipsis: true as any
  })

  baseColumns.push({
    title: '操作',
    key: 'action',
    width: activeTab.value === 'ai' ? 150 : 100,
    fixed: ('right' as any),
    ellipsis: true as any
  })

  return baseColumns
})

const mockTableData: TableDataItem[] = [
  {
    id: 1,
    detailId: 1001,
    callId: 5001,
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '未开始',
    keywordRules: 'A1',
    aiRules: 'B1',
    manualRules: '',
    aiSummary: '客户表示满意',
    manualSummary: '',
    isModified: '否',
    auditor: '张三',
    aiScore: 90,
    manualScore: undefined,
  },
  {
    id: 2,
    detailId: 1002,
    callId: 5002,
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '已完成',
    keywordRules: 'A2',
    aiRules: '',
    manualRules: 'B1',
    aiSummary: '已按流程操作',
    manualSummary: '坐席表现规范',
    isModified: '是',
    auditor: '李四',
    aiScore: 75,
    manualScore: 80,
  },
  {
    id: 3,
    detailId: 1003,
    callId: 5003,
    asrStatus: '未完成',
    aiStatus: '已失败',
    manualStatus: '未开始',
    keywordRules: '',
    aiRules: '',
    manualRules: '',
    aiSummary: '-',
    manualSummary: '',
    isModified: '否',
    auditor: '王五',
    aiScore: undefined,
    manualScore: undefined,
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
    asrStatus: '已完成',
    aiStatus: '已失败',
    manualStatus: '未开始',
    keywordRules: '',
    aiRules: '',
    manualRules: '',
    aiSummary: '',
    manualSummary: '',
    isModified: '否',
    auditor: '张三',
    manualScore: undefined,
  },
  {
    id: 2,
    detailId: 3483,
    callId: 2679,
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '未开始',
    keywordRules: 'A1',
    aiRules: '',
    manualRules: 'B1, B2',
    aiSummary: '',
    manualSummary: '客户通话过程中表现出较强的投诉倾向，坐席沟通态度良好，但业务解释不够清晰',
    isModified: '是',
    auditor: '李四',
    manualScore: 85,
  },
  {
    id: 3,
    detailId: 3488,
    callId: 2689,
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '未开始',
    keywordRules: 'A2',
    aiRules: '',
    manualRules: '',
    aiSummary: '',
    manualSummary: '坐席未按要求进行风险提示，需要补充合规话术',
    isModified: '否',
    auditor: '王五',
    manualScore: 65,
  },
  {
    id: 4,
    detailId: 3482,
    callId: 2678,
    asrStatus: '未完成',
    aiStatus: '已失败',
    manualStatus: '未开始',
    keywordRules: '',
    aiRules: '',
    manualRules: '',
    aiSummary: '',
    manualSummary: '',
    isModified: '否',
    auditor: 'admin',
    manualScore: undefined,
  },
  {
    id: 5,
    detailId: 3479,
    callId: 2670,
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '已完成',
    keywordRules: 'A3',
    aiRules: '',
    manualRules: 'B2',
    aiSummary: '',
    manualSummary: '客户表现出明确的购买意向，坐席成功引导客户完成产品介绍，建议后续跟进',
    isModified: '是',
    auditor: '张三',
    manualScore: 92,
  },
  {
    id: 6,
    detailId: 3481,
    callId: 2677,
    asrStatus: '未完成',
    aiStatus: '未开始',
    manualStatus: '未开始',
    keywordRules: '',
    aiRules: '',
    manualRules: '',
    aiSummary: '',
    manualSummary: '',
    isModified: '否',
    auditor: '王五',
    manualScore: undefined,
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
    // 根据当前标签页传递任务类型和 ASR 状态
    qualityDetailRef.value.open(activeTab.value, record.asrStatus === '已完成')
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
    asrStatus: undefined,
    aiStatus: undefined,
    manualStatus: undefined,
    isModified: undefined,
    keywordRule: undefined,
    aiRule: undefined,
    manualRule: undefined,
    auditor: undefined,
    aiScoreMin: undefined,
    aiScoreMax: undefined,
    manualScoreMin: undefined,
    manualScoreMax: undefined,
  })
  message.success('已重置搜索条件')
}

const onSelectChange = (keys: (string | number)[]) => {
  selectedRowKeys.value = keys as number[]
}

// 批量分配相关
const batchAssignVisible = ref(false)
const batchAssignForm = reactive({
  assignee: undefined as string | undefined,
})

// 可分配的账号选项（创建任务时勾选的账号）
const assigneeOptions = [
  { label: '张三', value: '张三' },
  { label: '李四', value: '李四' },
  { label: '王五', value: '王五' },
  { label: 'admin', value: 'admin' },
]

// 打开批量分配弹窗
const handleBatchAssign = () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要分配的数据')
    return
  }
  batchAssignForm.assignee = undefined
  batchAssignVisible.value = true
}

// 确认批量分配
const handleBatchAssignConfirm = () => {
  if (!batchAssignForm.assignee) {
    message.warning('请选择分配的账号')
    return
  }

  // 模拟分配操作
  const assignee = batchAssignForm.assignee
  selectedRowKeys.value.forEach(key => {
    const item = tableData.value.find(d => d.id === key)
    if (item) {
      item.auditor = assignee
    }
  })

  message.success(`已将 ${selectedRowKeys.value.length} 条数据分配给 ${assignee}`)
  selectedRowKeys.value = []
  batchAssignVisible.value = false
}

// 取消批量分配
const handleBatchAssignCancel = () => {
  batchAssignForm.assignee = undefined
  batchAssignVisible.value = false
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

/* 评分区间搜索 */
.score-range-group {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}

.range-label {
  font-size: 14px;
  color: #595959;
  white-space: nowrap;
}

.range-input {
  flex: 1;
}

.range-separator {
  color: #8f959e;
  font-size: 14px;
}

/* 高级搜索抽屉行间距 */
.advanced-search-drawer :deep(.ant-form-item) {
  margin-bottom: 8px;
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
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-header-left {
  display: flex;
  align-items: center;
}

.table-header-right {
  display: flex;
  align-items: center;
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

/* 高级搜索抽屉底部按钮 */
.drawer-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 12px 24px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  text-align: right;
  z-index: 1;
}
</style>
