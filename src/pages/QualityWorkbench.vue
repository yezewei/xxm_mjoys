<template>
  <div class="quality-inspection-workbench">
    <a-row :gutter="16" class="main-container">
      <!-- 左侧任务列表区域 -->
      <a-col :span="6" class="left-panel" v-show="!leftPanelCollapsed">
        <div class="task-list-container">
          <!-- 折叠按钮 -->
          <div class="collapse-btn" @click="toggleLeftPanel" title="收起任务列表">
            <LeftOutlined />
          </div>
          
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

      <!-- 展开按钮（当左侧收起时显示） -->
      <div v-show="leftPanelCollapsed" class="expand-btn-wrapper" @click="toggleLeftPanel" title="展开任务列表">
        <div class="expand-btn">
          <RightOutlined />
        </div>
      </div>

      <!-- 右侧详情区域 -->
      <a-col :span="18" class="right-panel" :class="{ 'right-panel-full': leftPanelCollapsed }">
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
                <span class="item-label">质检数据范围：</span>
                <a class="data-range-link" @click="dataRangeVisible = true">查看</a>
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
                  <SearchOutlined />
                  搜索
                </a-button>
                <a-button @click="handleReset">
                  <ReloadOutlined />
                  重置
                </a-button>
                <a-button @click="drawerVisible = true">
                  <SearchOutlined />
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
            <template v-if="getTaskType(currentTask) === 'ai'">
              <a-form-item>
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
            </template>
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
              <a-input
                v-model:value="filterForm.keywordRule"
                placeholder="关键词匹配质检项"
                allow-clear
              />
            </a-form-item>
            <template v-if="getTaskType(currentTask) === 'ai'">
              <a-form-item>
                <a-input
                  v-model:value="filterForm.aiRule"
                  placeholder="AI 识别质检项"
                  allow-clear
                />
              </a-form-item>
            </template>
            <a-form-item>
              <a-input
                v-model:value="filterForm.manualRule"
                placeholder="人工标注质检项"
                allow-clear
              />
            </a-form-item>
            <template v-if="getTaskType(currentTask) === 'ai'">
              <a-form-item>
                <a-select
                  v-model:value="filterForm.auditor"
                  placeholder="审核员"
                  allow-clear
                  style="width: 100%"
                >
                  <a-select-option value="zhangsan">张三</a-select-option>
                  <a-select-option value="lisi">李四</a-select-option>
                  <a-select-option value="wangwu">王五</a-select-option>
                  <a-select-option value="admin">admin</a-select-option>
                </a-select>
              </a-form-item>
            </template>
            <template v-else>
              <a-form-item>
                <a-select
                  v-model:value="filterForm.inspector"
                  placeholder="质检员"
                  allow-clear
                  style="width: 100%"
                >
                  <a-select-option value="zhangsan">张三</a-select-option>
                  <a-select-option value="lisi">李四</a-select-option>
                  <a-select-option value="wangwu">王五</a-select-option>
                  <a-select-option value="zhaoliu">赵六</a-select-option>
                </a-select>
              </a-form-item>
            </template>
            <template v-if="getTaskType(currentTask) === 'ai'">
              <a-form-item>
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
            </template>
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
              showTotal: (total: number) => `共 ${total} 条`,
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
              <!-- 审核员 -->
              <template v-else-if="column.key === 'auditor'">
                <span>{{ record.auditor || '-' }}</span>
              </template>
              <!-- 质检员 -->
              <template v-else-if="column.key === 'inspector'">
                <span>{{ record.inspector || '-' }}</span>
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
    
    <!-- 质检数据范围弹窗 -->
    <a-modal
      v-model:open="dataRangeVisible"
      title="质检数据范围"
      :footer="null"
      width="640px"
    >
      <div class="data-range-content">
        <!-- 质检范围 -->
        <div class="data-range-section">
          <div class="section-label">质检范围</div>
          <div class="section-value">{{ currentTask?.qualityScope === 'sampling' ? '部分抽检' : '全量质检' }}</div>
        </div>

        <!-- 录音类型 -->
        <div class="data-range-section">
          <div class="section-label">录音类型</div>
          <div class="section-value">{{ getRecordTypeLabel(currentTask?.recordType) }}</div>
        </div>

        <!-- 条件筛选 -->
        <div class="data-range-section" v-if="currentTask?.conditionExpressions?.length">
          <div class="section-label">条件筛选</div>
          <div class="condition-expressions">
            <div
              v-for="(expr, eIndex) in currentTask.conditionExpressions"
              :key="eIndex"
              class="condition-expression-item"
            >
              <div class="expression-conditions">
                <span
                  v-for="(cond, cIndex) in expr.conditions"
                  :key="cIndex"
                >
                  <span class="condition-field">{{ getFieldTypeLabel(cond.fieldType) }}</span>
                  <span class="condition-operator">{{ getOperatorLabel(cond.operator) }}</span>
                  <span class="condition-value">{{ cond.value }}{{ cond.value2 ? ` ~ ${cond.value2}` : '' }}</span>
                  <span v-if="cIndex < expr.conditions.length - 1" class="condition-connector">且</span>
                </span>
              </div>
              <span v-if="eIndex < currentTask.conditionExpressions.length - 1" class="expression-connector">或</span>
            </div>
          </div>
        </div>

        <!-- 自动追加新数据 -->
        <div class="data-range-section" v-if="currentTask?.autoAppend">
          <div class="section-label">自动追加新数据</div>
          <div class="auto-append-info">
            <div class="append-item">
              <span class="append-label">执行时间：</span>
              <span class="append-value">每天 {{ currentTask.autoAppendExecTime || '08:00' }} 点</span>
            </div>
            <div class="append-item">
              <span class="append-label">查询时间范围：</span>
              <span class="append-value">
                {{ currentTask.autoAppendStartType === 'today' ? '当天' : '昨天' }} {{ currentTask.autoAppendRangeStart || '00:00' }}
                ~
                {{ currentTask.autoAppendEndType === 'today' ? '当天' : '昨天' }} {{ currentTask.autoAppendRangeEnd || '23:59' }}
              </span>
            </div>
          </div>
        </div>

        <!-- 抽检配置 -->
        <div class="data-range-section" v-if="currentTask?.qualityScope === 'sampling'">
          <div class="section-label">抽检配置</div>
          <div class="sampling-info">
            <div class="sampling-item">
              <span class="sampling-label">采样数量：</span>
              <span class="sampling-value">
                <template v-if="currentTask.allocationMethod === 'total'">按总户数 {{ currentTask.allocationValue || '-' }}条</template>
                <template v-else-if="currentTask.allocationMethod === 'ratio'">按比例 {{ currentTask.allocationValue || '-' }}%</template>
                <template v-else-if="currentTask.allocationMethod === 'perPerson'">按人均数量每人 {{ currentTask.allocationValue || '-' }}条</template>
                <template v-else>-</template>
              </span>
            </div>
            <div class="sampling-item">
              <span class="sampling-label">抽样方式：</span>
              <span class="sampling-value">{{ getSamplingMethodLabel(currentTask.samplingMethod) }}</span>
            </div>
            <div class="sampling-item" v-if="currentTask.samplingMethod === 'ratio'">
              <span class="sampling-label">抽样维度：</span>
              <span class="sampling-value">
                {{ getSamplingDimensionLabel(currentTask.samplingDimensionType) }}
                <template v-if="currentTask.samplingDimensionDetails?.length">
                  <span class="dimension-detail">{{ getSamplingDimensionDetailText(currentTask) }}</span>
                </template>
              </span>
            </div>
          </div>
        </div>
      </div>
    </a-modal>

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
interface ScoreDeduction {
  ruleCode: string
  ruleDesc: string
  maxDeduct: number
}

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
  scoreDeductions?: ScoreDeduction[]
  qualityScope?: 'full' | 'sampling'
  recordType?: string
  conditionExpressions?: Array<{
    conditions: Array<{
      fieldType: string
      operator: string
      value: string
      value2?: string
    }>
  }>
  autoAppend?: boolean
  autoAppendExecTime?: string
  autoAppendStartType?: 'today' | 'yesterday'
  autoAppendRangeStart?: string
  autoAppendEndType?: 'today' | 'yesterday'
  autoAppendRangeEnd?: string
  allocationMethod?: 'total' | 'ratio' | 'perPerson'
  allocationValue?: number
  samplingMethod?: 'average' | 'ratio'
  samplingDimensionType?: 'scene' | 'agent' | 'callDuration'
  samplingDimensionDetails?: { name: string; value: number }[]
}

// 允许 TaskItem 为 null 的类型
type TaskItemNullable = TaskItem | null;

interface TableDataItem {
  id: number
  detailId: number
  callId: number
  agent: string
  asrStatus: '未完成' | '已完成'
  aiStatus: '未开始' | '已完成' | '已失败'
  manualStatus: '未开始' | '已完成'
  keywordRules: string
  aiRules: string
  manualRules: string
  aiSummary?: string
  manualSummary?: string
  isModified?: '是' | '否'
  auditor?: string
  inspector?: string
  aiScore?: number
  manualScore?: number
}

interface FilterForm {
  detailId: string
  callId: string
  agent: string | undefined
  asrStatus: string | undefined
  aiStatus: string | undefined
  manualStatus: string | undefined
  isModified: string | undefined
  keywordRule: string | undefined
  aiRule: string | undefined
  manualRule: string | undefined
  auditor: string | undefined
  inspector: string | undefined
  aiScoreMin: number | undefined
  aiScoreMax: number | undefined
  manualScoreMin: number | undefined
  manualScoreMax: number | undefined
}

// ============ 左侧任务列表状态 ============
const searchKeyword = ref('')
const activeTab = ref<'todo' | 'all'>('todo')
const selectedTaskId = ref<number | null>(27)
const currentPage = ref(1)
const totalTasks = ref(4)
const leftPanelCollapsed = ref(false)
const drawerVisible = ref(false)
const dataRangeVisible = ref(false)

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
    description: '2026 年 2 月金融产品外呼合规性检测专项任务',
    scoreDeductions: [
      { ruleCode: 'A1', ruleDesc: '产品利率、收益、有效期等信息讲解错误', maxDeduct: 5 },
      { ruleCode: 'A2', ruleDesc: '相关提醒不完整，遗漏或错误', maxDeduct: 5 },
      { ruleCode: 'A3', ruleDesc: '未正面回答客户产品咨询问题', maxDeduct: 10 },
      { ruleCode: 'B1', ruleDesc: '未确认客户身份直接进行业务营销', maxDeduct: 10 },
      { ruleCode: 'B2', ruleDesc: '泄露客户个人信息（身份证、电话、资产等）', maxDeduct: 15 }
    ],
    qualityScope: 'sampling',
    recordType: 'ai_assisted',
    conditionExpressions: [
      {
        conditions: [
          { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' },
        ]
      },
      {
        conditions: [
          { fieldType: 'callDuration', operator: '>', value: '60' },
          { fieldType: 'intent', operator: 'contains', value: '金融产品' },
        ]
      }
    ],
    autoAppend: true,
    autoAppendExecTime: '09:00',
    autoAppendStartType: 'yesterday',
    autoAppendRangeStart: '08:00',
    autoAppendEndType: 'today',
    autoAppendRangeEnd: '20:00',
    allocationMethod: 'total',
    allocationValue: 100,
    samplingMethod: 'average',
    samplingDimensionType: 'scene',
    samplingDimensionDetails: [
      { name: '贷款转存-接通即转', value: 40 },
      { name: '存款营销-到期提醒', value: 30 },
      { name: '信用卡推广-新客', value: 30 },
    ],
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
    description: '2026 年 2 月营销活动客户购买意向识别与分析',
    scoreDeductions: [
      { ruleCode: 'A1', ruleDesc: '产品利率、收益、有效期等信息讲解错误', maxDeduct: 5 },
      { ruleCode: 'A2', ruleDesc: '相关提醒不完整，遗漏或错误', maxDeduct: 5 },
      { ruleCode: 'B2', ruleDesc: '泄露客户个人信息（身份证、电话、资产等）', maxDeduct: 15 }
    ],
    qualityScope: 'full',
    recordType: 'manual_outbound',
    conditionExpressions: [
      {
        conditions: [
          { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' },
          { fieldType: 'agent', operator: '=', value: '营销坐席' },
        ]
      }
    ],
    autoAppend: true,
    autoAppendExecTime: '08:00',
    autoAppendStartType: 'today',
    autoAppendRangeStart: '00:00',
    autoAppendEndType: 'today',
    autoAppendRangeEnd: '23:59',
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
    description: '客服投诉专线通话质量监测与客户情绪分析',
    scoreDeductions: [
      { ruleCode: 'A1', ruleDesc: '产品利率、收益、有效期等信息讲解错误', maxDeduct: 5 },
      { ruleCode: 'A3', ruleDesc: '未正面回答客户产品咨询问题', maxDeduct: 10 },
      { ruleCode: 'B1', ruleDesc: '未确认客户身份直接进行业务营销', maxDeduct: 10 }
    ],
    qualityScope: 'sampling',
    recordType: 'manual_outbound',
    conditionExpressions: [
      {
        conditions: [
          { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' },
        ]
      }
    ],
    autoAppend: false,
    allocationMethod: 'ratio',
    allocationValue: 15,
    samplingMethod: 'ratio',
    samplingDimensionType: 'agent',
    samplingDimensionDetails: [
      { name: '张三', value: 20 },
      { name: '李四', value: 30 },
      { name: '王五', value: 25 },
      { name: '赵六', value: 25 },
    ],
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
    description: '新入职坐席服务规范与合规性人工专项质检',
    scoreDeductions: [
      { ruleCode: 'A1', ruleDesc: '产品利率、收益、有效期等信息讲解错误', maxDeduct: 5 },
      { ruleCode: 'A2', ruleDesc: '相关提醒不完整，遗漏或错误', maxDeduct: 5 },
      { ruleCode: 'A3', ruleDesc: '未正面回答客户产品咨询问题', maxDeduct: 10 },
      { ruleCode: 'B1', ruleDesc: '未确认客户身份直接进行业务营销', maxDeduct: 10 },
      { ruleCode: 'B2', ruleDesc: '泄露客户个人信息（身份证、电话、资产等）', maxDeduct: 15 }
    ],
    qualityScope: 'full',
    recordType: 'manual_outbound',
    conditionExpressions: [
      {
        conditions: [
          { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' },
          { fieldType: 'agent', operator: '=', value: '新入职坐席' },
        ]
      }
    ],
    autoAppend: true,
    autoAppendExecTime: '08:00',
    autoAppendStartType: 'today',
    autoAppendRangeStart: '00:00',
    autoAppendEndType: 'today',
    autoAppendRangeEnd: '23:59',
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
  asrStatus: undefined,
  aiStatus: undefined,
  manualStatus: undefined,
  isModified: undefined,
  keywordRule: undefined,
  aiRule: undefined,
  manualRule: undefined,
  auditor: undefined,
  inspector: undefined,
  aiScoreMin: undefined,
  aiScoreMax: undefined,
  manualScoreMin: undefined,
  manualScoreMax: undefined,
})

// ============ 表格列定义 ============
const columns = computed(() => {
  const baseColumns: any[] = [
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
      title: 'ASR 识别状态',
      dataIndex: 'asrStatus',
      key: 'asrStatus',
      width: 120
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
        title: '关键词匹配质检项',
        dataIndex: 'keywordRules',
        key: 'keywordRules',
        width: 160
      },
      {
        title: 'AI 识别质检项',
        dataIndex: 'aiRules',
        key: 'aiRules',
        width: 160
      },
      {
        title: '人工标注质检项',
        dataIndex: 'manualRules',
        key: 'manualRules',
        width: 160
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
        width: 100
      },
      {
        title: '人工评分',
        dataIndex: 'manualScore',
        key: 'manualScore',
        width: 100
      },
      {
        title: '审核员',
        dataIndex: 'auditor',
        key: 'auditor',
        width: 100
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
        title: '关键词匹配质检项',
        dataIndex: 'keywordRules',
        key: 'keywordRules',
        width: 160
      },
      {
        title: '人工标注质检项',
        dataIndex: 'manualRules',
        key: 'manualRules',
        width: 160
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
        width: 100
      },
      {
        title: '质检员',
        dataIndex: 'inspector',
        key: 'inspector',
        width: 100
      }
    )
  }

  baseColumns.push({
    title: '操作',
    key: 'action',
    width: currentTask.value && getTaskType(currentTask.value) === 'ai' ? 150 : 100,
    fixed: ('right' as any)
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
    inspector: '张三',
    aiScore: undefined,
    manualScore: undefined,
  },
  {
    id: 2,
    detailId: 3483,
    callId: 2679,
    agent: '李四',
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '未开始',
    keywordRules: 'A1',
    aiRules: 'B1, B2',
    manualRules: '',
    aiSummary: '客户通话过程中表现出较强的投诉倾向，坐席沟通态度良好，但业务解释不够清晰',
    manualSummary: '',
    isModified: '是',
    auditor: '李四',
    inspector: '李四',
    aiScore: 80,
    manualScore: undefined,
  },
  {
    id: 3,
    detailId: 3488,
    callId: 2689,
    agent: '王五',
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '未开始',
    keywordRules: 'A2',
    aiRules: '',
    manualRules: 'B1',
    aiSummary: '坐席未按要求进行风险提示，需要补充合规话术',
    manualSummary: '',
    isModified: '否',
    auditor: '王五',
    inspector: '王五',
    aiScore: 65,
    manualScore: undefined,
  },
  {
    id: 4,
    detailId: 3482,
    callId: 2678,
    agent: '赵六',
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
    inspector: '赵六',
    aiScore: undefined,
    manualScore: undefined,
  },
  {
    id: 5,
    detailId: 3479,
    callId: 2670,
    agent: '孙七',
    asrStatus: '已完成',
    aiStatus: '已完成',
    manualStatus: '已完成',
    keywordRules: 'A3',
    aiRules: 'B2',
    manualRules: 'A1',
    aiSummary: '客户表现出明确的购买意向，坐席成功引导客户完成产品介绍，建议后续跟进',
    manualSummary: '坐席表现良好，话术规范',
    isModified: '是',
    auditor: '张三',
    inspector: '孙七',
    aiScore: 90,
    manualScore: 85,
  },
  {
    id: 6,
    detailId: 3481,
    callId: 2677,
    agent: '周八',
    asrStatus: '未完成',
    aiStatus: '未开始',
    manualStatus: '未开始',
    keywordRules: '',
    aiRules: '',
    manualRules: '',
    aiSummary: '',
    manualSummary: '',
    isModified: '否',
    auditor: 'admin',
    inspector: '周八',
    aiScore: undefined,
    manualScore: undefined,
  }
])

// ============ 选中行 ============
const selectedRowKeys = ref<number[]>([])

// ============ 质检详情弹窗 ============
const qualityDetailRef = ref()

// ============ 方法 ============
// 获取任务类型
const getTaskType = (task: TaskItemNullable): 'ai' | 'manual' => {
  if (!task) return 'ai';
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
    qualityDetailRef.value.open(taskType, record.asrStatus === '已完成')
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
  filterForm.asrStatus = undefined
  filterForm.aiStatus = undefined
  filterForm.manualStatus = undefined
  filterForm.isModified = undefined
  filterForm.keywordRule = undefined
  filterForm.aiRule = undefined
  filterForm.manualRule = undefined
  filterForm.auditor = undefined
  filterForm.inspector = undefined
  filterForm.aiScoreMin = undefined
  filterForm.aiScoreMax = undefined
  filterForm.manualScoreMin = undefined
  filterForm.manualScoreMax = undefined
}

const handleFilterSearch = () => {
  console.log('筛选条件:', filterForm)
}

const onSelectChange = (selectedKeys: number[]) => {
  selectedRowKeys.value = selectedKeys
}

// 数据范围弹窗辅助函数
const getRecordTypeLabel = (type: string | undefined) => {
  if (!type) return '-'
  const map: Record<string, string> = {
    ai_assisted: '人机协同录音',
    manual_outbound: '人工外呼录音',
    manual_upload: '手动上传录音',
  }
  return map[type] || '-'
}

const getFieldTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    callTime: '通话时间',
    callDuration: '通话时长',
    intent: '客户意图',
    agent: '坐席工号',
  }
  return map[type] || type
}

const getOperatorLabel = (operator: string) => {
  const map: Record<string, string> = {
    '=': '等于',
    '>': '大于',
    '<': '小于',
    '>=': '大于等于',
    '<=': '小于等于',
    '!=': '不等于',
    'contains': '包含',
    'between': '介于',
  }
  return map[operator] || operator
}

const getAllocationMethodLabel = (method: string) => {
  const map: Record<string, string> = {
    total: '按总户数',
    ratio: '按比例',
    perPerson: '按人均数量',
  }
  return map[method] || '-'
}

const getSamplingMethodLabel = (method: string | undefined) => {
  if (!method) return '-'
  const map: Record<string, string> = {
    average: '平均采样',
    ratio: '按比例采样',
  }
  return map[method] || '-'
}

const getSamplingDimensionLabel = (dimension: string | undefined) => {
  if (!dimension) return '-'
  const map: Record<string, string> = {
    scene: '按场景',
    agent: '按坐席',
    callDuration: '按通话时长',
  }
  return map[dimension] || '-'
}

const getSamplingDimensionDetailText = (task: TaskItem) => {
  if (!task.samplingDimensionDetails?.length) return ''
  const unit = task.samplingDimensionType === 'callDuration' ? '秒' : '%'
  return task.samplingDimensionDetails.map(d => `${d.name} ${d.value}${unit}`).join('、')
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
  position: relative;
}

/* 左侧面板样式 */
.left-panel {
  height: 100%;
  overflow: visible;
  position: relative;
  transition: none;
}

/* 展开按钮 wrapper - 左侧收起时显示在工作台页面左侧 */
.expand-btn-wrapper {
  position: absolute;
  left: -8px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 10;
}

/* 展开按钮 - 与折叠按钮样式保持一致 */
.expand-btn {
  width: 13px;
  height: 36px;
  background: #1677ff;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  transition: all 0.3s;
}

.expand-btn:hover {
  background: #4096ff;
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

/* 折叠按钮 */
.collapse-btn {
  position: absolute;
  top: 50%;
  right: -12px;
  transform: translateY(-50%);
  width: 13px;
  height: 36px;
  background: #1677ff;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  z-index: 10;
  transition: all 0.3s;
}

.collapse-btn:hover {
  background: #4096ff;
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
  transition: none;
}

.right-panel-full {
  flex: 1;
  max-width: 100%;
  padding-left: 24px;
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

/* 数据范围弹窗样式 */
.data-range-link {
  color: #1677ff;
  cursor: pointer;
  font-size: 14px;
}

.data-range-link:hover {
  color: #4096ff;
  text-decoration: underline;
}

.data-range-content {
  padding: 8px 0;
}

.data-range-section {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.data-range-section:last-child {
  border-bottom: none;
}

.section-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 8px;
}

.section-value {
  font-size: 14px;
  color: #595959;
}

.condition-expressions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.condition-expression-item {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.expression-conditions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.condition-field {
  color: #1677ff;
  font-weight: 500;
}

.condition-operator {
  color: #8c8c8c;
  margin: 0 4px;
}

.condition-value {
  color: #262626;
}

.condition-connector {
  color: #8c8c8c;
  margin: 0 8px;
}

.expression-connector {
  color: #ff4d4f;
  font-weight: 500;
  margin: 0 8px;
}

.auto-append-info,
.sampling-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.append-item,
.sampling-item {
  display: flex;
  align-items: center;
}

.append-label,
.sampling-label {
  color: #8c8c8c;
  font-size: 14px;
  min-width: 100px;
}

.append-value,
.sampling-value {
  color: #262626;
  font-size: 14px;
}

.dimension-detail {
  display: block;
  margin-top: 4px;
  color: #8c8c8c;
  font-size: 13px;
}
</style>
