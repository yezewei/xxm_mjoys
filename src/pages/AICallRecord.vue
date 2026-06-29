<template>
  <div class="ai-call-record">
    <div class="quality-wrapper">
      <!-- 页面标题区域 -->
      <div class="page-header-section">
        <div class="page-header">
          <div class="header-left">
            <h2 class="page-title">AI 外呼记录</h2>
            <p class="page-description">记录 AI 机器人自动外呼的通话明细，支持查看对话详情与 ASR 识别结果。</p>
          </div>
        </div>
      </div>

      <!-- 搜索区域和表格区域合并 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-form ref="searchFormRef" layout="vertical">
            <a-row :gutter="16" style="margin-bottom: -12px;">
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.scene"
                    placeholder="请选择外呼场景"
                    allow-clear
                  >
                    <a-select-option value="贷款转存">贷款转存</a-select-option>
                    <a-select-option value="信用卡营销">信用卡营销</a-select-option>
                    <a-select-option value="理财推荐">理财推荐</a-select-option>
                    <a-select-option value="客户回访">客户回访</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.batchName"
                    placeholder="请输入数据批次名称"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.callerPhoneNum"
                    placeholder="请输入主叫号码"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.calleePhoneNum"
                    placeholder="请输入被叫号码"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="16" style="margin-top: -12px;">
              <a-col :span="6">
                <a-form-item>
                  <a-range-picker
                    v-model:value="searchForm.dialTimeRange"
                    style="width: 100%"
                    allow-clear
                    :placeholder="['拨打开始时间', '拨打结束时间']"
                    show-time
                    format="YYYY-MM-DD HH:mm:ss"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.callStatus"
                    placeholder="请选择通话状态"
                    allow-clear
                  >
                    <a-select-option value="已接通">已接通</a-select-option>
                    <a-select-option value="未接通">未接通</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.transferStatus"
                    placeholder="请选择转人工状态"
                    allow-clear
                  >
                    <a-select-option value="已转人工">已转人工</a-select-option>
                    <a-select-option value="未转人工">未转人工</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-space class="search-btn-space">
                    <a-button @click="handleReset">
                      <reload-outlined />
                      重置
                    </a-button>
                    <a-button type="primary" @click="handleSearch">
                      <search-outlined />
                      搜索
                    </a-button>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
          </a-form>
        </div>

        <!-- 表格上方工具栏 -->
        <div class="table-toolbar">
          <div class="table-toolbar-left">
            <span class="selection-info">共 {{ total }} 条，已选 {{ selectedRowKeys.length }} 条</span>
          </div>
          <div class="table-toolbar-right">
            <a-button @click="openExportModal">
              <file-excel-outlined />
              导出 Excel
            </a-button>
            <a-button @click="showColumnSetting" style="margin-left: 12px">
              <setting-outlined />
              列表显示设置
            </a-button>
          </div>
        </div>

        <!-- 数据表格 -->
        <div class="table-area">
          <div class="table-wrapper">
            <a-table
              :columns="visibleColumns"
              :data-source="dataSource"
              :pagination="false"
              :loading="loading"
              row-key="callUuid"
              :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
              :scroll="{ x: 2400 }"
              @change="handleTableChange"
            >
              <template #bodyCell="{ column, record }">
                <!-- 通话状态列 -->
                <template v-if="column.key === 'callStatus'">
                  <a-badge
                    :status="record.callStatus === '已接通' ? 'success' : 'error'"
                    :text="record.callStatus"
                  />
                </template>
                <!-- 转人工状态列 -->
                <template v-else-if="column.key === 'transferStatus'">
                  <a-tag :color="record.transferStatus === '已转人工' ? 'orange' : 'default'">
                    {{ record.transferStatus }}
                  </a-tag>
                </template>
                <!-- 通话时长列 -->
                <template v-else-if="column.key === 'callDuration'">
                  {{ formatDuration(record.callDuration) }}
                </template>
                <!-- 意图识别列 -->
                <template v-else-if="column.key === 'intentResult'">
                  <a-tag v-if="record.intentResult && record.intentResult !== '-'" color="blue">
                    {{ record.intentResult }}
                  </a-tag>
                  <span v-else>-</span>
                </template>
                <!-- 操作列 -->
                <template v-else-if="column.key === 'action'">
                  <a-button type="link" size="small" @click="handleViewDetail(record)">
                    对话详情
                  </a-button>
                </template>
              </template>
            </a-table>
          </div>

          <!-- 分页 -->
          <Pagination
            v-model:current="pagination.current"
            v-model:page-size="pagination.pageSize"
            :total="pagination.total"
            @change="handlePageChange"
          />
        </div>
      </div>
    </div>

    <!-- 列设置弹窗 -->
    <ColumnSettingModal
      ref="columnSettingModalRef"
      page-key="ai-call-record"
      :default-columns="allColumns"
      @save="handleColumnSave"
      @cancel="handleColumnCancel"
    />

    <!-- 对话详情弹窗 -->
    <a-modal
      v-model:open="detailModalVisible"
      title="对话详情"
      width="800px"
      :footer="null"
      :body-style="{ padding: 0, display: 'flex', flexDirection: 'column', height: '640px' }"
    >
      <!-- 通话字段信息区域 -->
      <div class="detail-info-section">
        <div class="detail-info-header" @click="detailExpanded = !detailExpanded">
          <span class="detail-info-title">通话信息</span>
          <span class="detail-info-toggle">
            <UpOutlined v-if="detailExpanded" style="font-size: 10px" />
            <DownOutlined v-else style="font-size: 10px" />
          </span>
        </div>
        <div v-show="detailExpanded" class="detail-info-body">
          <div class="detail-field-grid">
            <div
              v-for="field in detailFields"
              :key="field.key"
              class="detail-field-item"
            >
              <span class="detail-field-label">{{ field.label }}</span>
              <span class="detail-field-value">{{ getDetailFieldValue(detailRecord, field) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 对话区域 -->
      <div class="chat-container">
        <div class="chat-messages">
          <!-- AI 对话部分 -->
          <div class="chat-section">
            <div class="chat-section-header">
              <robot-outlined style="color: #722ed1; margin-right: 6px" />
              <span>AI 对话</span>
            </div>
            <div class="chat-section-content">
              <div
                v-for="(item, index) in aiDialogList"
                :key="'ai-' + index"
                class="chat-row"
                :class="item.role === 'robot' ? 'chat-row-left' : 'chat-row-right'"
              >
                <!-- 机器人：头像在左 -->
                <template v-if="item.role === 'robot'">
                  <div class="chat-avatar">
                    <a-avatar :size="40" style="background-color: #722ed1">
                      <template #icon><RobotOutlined /></template>
                    </a-avatar>
                  </div>
                  <div class="chat-bubble-wrap">
                    <div class="chat-name">
                      <span>AI 机器人</span>
                    </div>
                    <div class="chat-bubble chat-bubble-left">{{ item.text }}</div>
                    <div class="asr-meta">
                      <span class="asr-time">{{ item.time }}</span>
                    </div>
                  </div>
                </template>
                <!-- 客户：头像在右 -->
                <template v-else>
                  <div class="chat-bubble-wrap chat-bubble-wrap-right">
                    <div class="chat-name chat-name-right">
                      <a-tag v-if="item.confidence" class="asr-confidence-tag" size="small">
                        置信度 {{ item.confidence }}%
                      </a-tag>
                      <a-tooltip v-if="item.endpoint">
                        <template #title>
                          端点检测：VAD 响应 {{ item.endpoint.vadDuration }}ms
                        </template>
                        <a-tag class="asr-endpoint-tag" color="green" size="small">
                          <span class="asr-endpoint-dot"></span>端点检测
                        </a-tag>
                      </a-tooltip>
                      <span>客户</span>
                    </div>
                    <div class="chat-bubble chat-bubble-right">
                      <template v-for="(seg, si) in getTextSegments(item)" :key="si">
                        <span v-if="seg.type === 'text'">{{ seg.content }}</span>
                        <a-tooltip v-else>
                          <template #title>
                            <span>{{ seg.tooltip }}</span>
                          </template>
                          <span :class="['asr-annotation', getAnnotationClass(seg.type)]">
                            {{ seg.content }}
                            <span class="asr-ann-badge">{{ getAnnotationLabel(seg.type) }}</span>
                          </span>
                        </a-tooltip>
                      </template>
                      <div v-if="item.annotations && item.annotations.length > 0" class="asr-processed-mark asr-processed-mark-green">
                        <check-circle-outlined /> 后处理
                      </div>
                    </div>
                    <div class="asr-meta asr-meta-right">
                      <span class="asr-punctuation-tag">智能断句</span>
                      <span class="asr-time">{{ item.time }}</span>
                    </div>
                    <!-- 语义分析标签 -->
                    <div v-if="item.semantic" class="semantic-section">
                      <div class="semantic-row" v-if="item.semantic.intentTag">
                        <span class="semantic-label">意图</span>
                        <a-tag color="blue" size="small">{{ item.semantic.intentTag }}</a-tag>
                      </div>
                      <div class="semantic-row" v-if="item.semantic.keywords && item.semantic.keywords.length > 0">
                        <span class="semantic-label">关键词</span>
                        <a-tag v-for="kw in item.semantic.keywords" :key="kw" size="small" class="semantic-kw-tag">{{ kw }}</a-tag>
                      </div>
                      <div class="semantic-row" v-if="item.semantic.contextRef">
                        <span class="semantic-label">上下文</span>
                        <span class="semantic-context">{{ item.semantic.contextRef }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="chat-avatar">
                    <a-avatar :size="40" style="background-color: #52c41a">
                      <template #icon><UserOutlined /></template>
                    </a-avatar>
                  </div>
                </template>
              </div>
            </div>
          </div>

          <!-- 分隔线 -->
          <div v-if="aiDialogList.length > 0" class="chat-section-divider">
            <div class="divider-line"></div>
            <span class="divider-text">转接人工</span>
            <div class="divider-line"></div>
          </div>

          <!-- 人工对话部分 -->
          <div class="chat-section">
            <div class="chat-section-header">
              <user-outlined style="color: #1890ff; margin-right: 6px" />
              <span>人工对话</span>
            </div>
            <div class="chat-section-content">
              <div
                v-for="(item, index) in manualAsrDialogList"
                :key="'manual-' + index"
                class="chat-row"
                :class="item.role === 'agent' ? 'chat-row-left' : 'chat-row-right'"
              >
                <!-- 坐席：头像在左 -->
                <template v-if="item.role === 'agent'">
                  <div class="chat-avatar">
                    <a-avatar :size="40" style="background-color: #1890ff">
                      <template #icon><UserOutlined /></template>
                    </a-avatar>
                  </div>
                  <div class="chat-bubble-wrap">
                    <div class="chat-name">
                      <span>人工坐席</span>
                    </div>
                    <div class="chat-bubble chat-bubble-left">{{ item.text }}</div>
                    <div class="asr-meta">
                      <span class="asr-time">{{ item.time }}</span>
                    </div>
                  </div>
                </template>
                <!-- 客户：头像在右 -->
                <template v-else>
                  <div class="chat-bubble-wrap chat-bubble-wrap-right">
                    <div class="chat-name chat-name-right">
                      <span>客户</span>
                    </div>
                    <div class="chat-bubble chat-bubble-right">{{ item.text }}</div>
                    <div class="asr-meta asr-meta-right">
                      <span class="asr-time">{{ item.time }}</span>
                    </div>
                  </div>
                  <div class="chat-avatar">
                    <a-avatar :size="40" style="background-color: #52c41a">
                      <template #icon><UserOutlined /></template>
                    </a-avatar>
                  </div>
                </template>
              </div>

              <!-- 人工对话为空时的提示 -->
              <template v-if="manualAsrDialogList.length === 0">
                <div v-if="isManualInAsrQueue(detailRecord)" class="asr-converting-tip">
                  <check-circle-outlined style="color: #52c41a" />
                  <span>已加入语音转文本队列，等待识别</span>
                </div>
                <div v-else class="asr-empty-tip">
                  <a-empty description="暂无通话文本数据" />
                  <a-button type="primary" @click="handleManualAsrConvert(detailRecord!)">
                    <audio-outlined />
                    语音转文本
                  </a-button>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>

      <!-- 底部录音播放 -->
      <div class="chat-audio-bar">
        <audio
          v-if="detailRecord"
          :src="detailRecord.callRecordPath"
          controls
          style="width: 100%; height: 36px"
        >
          您的浏览器不支持音频播放
        </audio>
      </div>
    </a-modal>

    <!-- 导出字段选择弹窗 -->
    <a-modal
      v-model:open="exportModalVisible"
      title="导出 Excel"
      width="500px"
      ok-text="导出"
      cancel-text="取消"
      @ok="handleExportExcel"
    >
      <a-alert
        type="info"
        show-icon
        style="margin-bottom: 16px"
        message="请选择需要导出的字段"
      />
      <div style="margin-bottom: 12px;">
        <a-checkbox
          :checked="exportFieldKeys.length === exportFieldOptions.length"
          :indeterminate="exportFieldKeys.length > 0 && exportFieldKeys.length < exportFieldOptions.length"
          @change="handleExportCheckAll"
        >
          全选
        </a-checkbox>
      </div>
      <a-checkbox-group
        v-model:value="exportFieldKeys"
        :options="exportFieldOptions"
        style="display: flex; flex-direction: column; gap: 8px;"
      />
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  SettingOutlined,
  FileExcelOutlined,
  UserOutlined,
  RobotOutlined,
  DownOutlined,
  UpOutlined,
  CheckCircleOutlined,
  AudioOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnType } from 'ant-design-vue';
import { message } from 'ant-design-vue';
import type { Dayjs } from 'dayjs';
import Pagination from '@/components/Pagination';
import ColumnSettingModal from '../components/ColumnSettingModal.vue';
import type { ColumnConfigItem } from '../utils/columnConfig';
import * as XLSX from 'xlsx';

// 搜索表单
const searchFormRef = ref<any>();
const searchForm = reactive({
  scene: undefined as string | undefined,
  batchName: '',
  callerPhoneNum: '',
  calleePhoneNum: '',
  dialTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  callStatus: undefined as string | undefined,
  transferStatus: undefined as string | undefined,
});

// 表格数据接口
interface ReportItem {
  callUuid: string;
  callRecordPath: string;
  scene: string;
  batchName: string;
  robotName: string;
  callerPhoneNum: string;
  calleePhoneNum: string;
  calleeArea: string;
  customerName: string;
  dialTime: string;
  answerTime: string;
  hangupTime: string;
  callDuration: number;
  callStatus: string;
  answerResult: string;
  intentResult: string;
  transferStatus: string;
}

// 表格数据
const dataSource = ref<ReportItem[]>([]);
const total = ref(0);
const loading = ref(false);

// 选中的行
const selectedRowKeys = ref<string[]>([]);

// 分页
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

// 列表显示设置相关
const columnSettingModalRef = ref<InstanceType<typeof ColumnSettingModal> | null>(null);
const currentColumns = ref<ColumnConfigItem[]>([]);

// 定义所有列
const allColumns: ColumnConfigItem[] = [
  { key: 'callUuid', title: '通话ID', dataIndex: 'callUuid', width: 200, visible: true, order: 0 },
  { key: 'scene', title: '外呼场景', dataIndex: 'scene', width: 180, visible: true, order: 1 },
  { key: 'batchName', title: '数据批次名称', dataIndex: 'batchName', width: 200, visible: true, order: 2 },
  { key: 'robotName', title: '机器人名称', dataIndex: 'robotName', width: 130, visible: true, order: 3 },
  { key: 'callerPhoneNum', title: '主叫号码', dataIndex: 'callerPhoneNum', width: 140, visible: true, order: 4 },
  { key: 'calleePhoneNum', title: '被叫号码', dataIndex: 'calleePhoneNum', width: 140, visible: true, order: 5 },
  { key: 'calleeArea', title: '被叫归属地', dataIndex: 'calleeArea', width: 120, visible: true, order: 6 },
  { key: 'customerName', title: '客户姓名', dataIndex: 'customerName', width: 110, visible: true, order: 7 },
  { key: 'dialTime', title: '拨打时间', dataIndex: 'dialTime', width: 180, visible: true, order: 8 },
  { key: 'answerTime', title: '接通时间', dataIndex: 'answerTime', width: 180, visible: true, order: 9 },
  { key: 'hangupTime', title: '挂断时间', dataIndex: 'hangupTime', width: 180, visible: true, order: 10 },
  { key: 'callDuration', title: '通话时长', dataIndex: 'callDuration', width: 110, visible: true, order: 11 },
  { key: 'callStatus', title: '通话状态', dataIndex: 'callStatus', width: 100, visible: true, order: 12 },
  { key: 'answerResult', title: '接通结果', dataIndex: 'answerResult', width: 120, visible: true, order: 13 },
  { key: 'intentResult', title: '意图识别', dataIndex: 'intentResult', width: 120, visible: true, order: 14 },
  { key: 'transferStatus', title: '转人工状态', dataIndex: 'transferStatus', width: 110, visible: true, order: 15 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 120, visible: true, order: 16 },
];

// 对话详情弹窗相关状态
const detailModalVisible = ref(false);
const detailRecord = ref<ReportItem | null>(null);
const detailExpanded = ref(true);

// 语音转文本队列
const asrQueue = ref<Set<string>>(new Set());

const handleAsrConvert = (record: ReportItem) => {
  asrQueue.value.add(record.callUuid);
};

const isInAsrQueue = (record: ReportItem | null) => {
  return record ? asrQueue.value.has(record.callUuid) : false;
};

// 人工对话语音转文本队列
const manualAsrQueue = ref<Set<string>>(new Set());

const handleManualAsrConvert = (record: ReportItem) => {
  manualAsrQueue.value.add(record.callUuid);
};

const isManualInAsrQueue = (record: ReportItem | null) => {
  return record ? manualAsrQueue.value.has(record.callUuid) : false;
};

// 详情字段定义
const detailFields = [
  { key: 'callUuid', label: '通话ID' },
  { key: 'scene', label: '外呼场景' },
  { key: 'batchName', label: '数据批次名称' },
  { key: 'robotName', label: '机器人名称' },
  { key: 'callerPhoneNum', label: '主叫号码' },
  { key: 'calleePhoneNum', label: '被叫号码' },
  { key: 'calleeArea', label: '被叫归属地' },
  { key: 'customerName', label: '客户姓名' },
  { key: 'dialTime', label: '拨打时间' },
  { key: 'answerTime', label: '接通时间' },
  { key: 'hangupTime', label: '挂断时间' },
  { key: 'callDuration', label: '通话时长', format: 'duration' as const },
  { key: 'callStatus', label: '通话状态' },
  { key: 'answerResult', label: '接通结果' },
  { key: 'intentResult', label: '意图识别' },
  { key: 'transferStatus', label: '转人工状态' },
  { key: 'callRecordPath', label: '通话录音路径' },
];

const getDetailFieldValue = (record: ReportItem | null, field: typeof detailFields[number]) => {
  if (!record) return '-';
  const value = (record as any)[field.key];
  if (value === undefined || value === null || value === '') return '-';
  if (field.format === 'duration') return formatDuration(value);
  return String(value);
};

// ASR 相关类型定义
interface AsrAnnotation {
  type: 'replace' | 'highlight' | 'number';
  start: number;
  end: number;
  original: string;
  value: string;
}

interface AsrEndpoint {
  vadDuration: number;
  isEndpoint: boolean;
}

interface SemanticAnalysis {
  intentTag: string;
  keywords: string[];
  contextRef?: string;
}

interface AsrItem {
  role: 'robot' | 'customer';
  time: string;
  text: string;
  confidence: number;
  endpoint?: AsrEndpoint;
  annotations?: AsrAnnotation[];
  semantic?: SemanticAnalysis;
}
const asrDialogList = ref<AsrItem[]>([]);

// AI 对话和人工对话分开存储
const aiDialogList = ref<AsrItem[]>([]);
const manualAsrDialogList = ref<AsrItem[]>([]);

interface TextSegment {
  type: 'text' | 'replace' | 'highlight' | 'number';
  content: string;
  tooltip?: string;
  original?: string;
}

const getTextSegments = (item: AsrItem): TextSegment[] => {
  if (!item.annotations || item.annotations.length === 0) {
    return [{ type: 'text', content: item.text }];
  }
  const segments: TextSegment[] = [];
  let cursor = 0;
  const sorted = [...item.annotations].sort((a, b) => a.start - b.start);
  for (const ann of sorted) {
    if (ann.start > cursor) {
      segments.push({ type: 'text', content: item.text.slice(cursor, ann.start) });
    }
    const tooltip = ann.type === 'replace'
      ? `原文：${ann.original} → 修正：${ann.value}`
      : ann.type === 'number'
        ? `原文：${ann.original} → 规整：${ann.value}`
        : ann.original;
    segments.push({
      type: ann.type,
      content: ann.value,
      tooltip,
      original: ann.original,
    });
    cursor = ann.end;
  }
  if (cursor < item.text.length) {
    segments.push({ type: 'text', content: item.text.slice(cursor) });
  }
  return segments;
};

const getAnnotationLabel = (type: AsrAnnotation['type']): string => {
  const map: Record<string, string> = { replace: '词语修正', highlight: '敏感标注', number: '数字规整' };
  return map[type] || type;
};

const getAnnotationClass = (type: AsrAnnotation['type']): string => {
  const map: Record<string, string> = { replace: 'asr-ann-replace', highlight: 'asr-ann-highlight', number: 'asr-ann-number' };
  return map[type] || '';
};

// 导出弹窗相关状态
const exportModalVisible = ref(false);
const exportFieldKeys = ref<string[]>([]);
const exportFieldOptions = computed(() => {
  const cols = visibleColumns.value.map(col => ({
    label: col.title as string,
    value: col.dataIndex as string,
  }));
  return cols;
});

// 打开导出弹窗
const openExportModal = () => {
  exportFieldKeys.value = exportFieldOptions.value.map(opt => opt.value);
  exportModalVisible.value = true;
};

// 全选/取消全选
const handleExportCheckAll = (e: any) => {
  if (e.target.checked) {
    exportFieldKeys.value = exportFieldOptions.value.map(opt => opt.value);
  } else {
    exportFieldKeys.value = [];
  }
};

// 根据当前配置计算可见列
const visibleColumns = computed(() => {
  const columnsToUse = currentColumns.value.length > 0 ? currentColumns.value : allColumns;
  return columnsToUse
    .filter(col => col.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(col => ({
      title: col.title,
      dataIndex: col.dataIndex,
      key: col.key,
      width: col.width,
      align: col.key === 'action' ? 'center' as const : undefined,
      fixed: col.key === 'action' ? 'right' as const : undefined,
    }));
});

// 初始化时加载保存的列配置
onMounted(() => {
  const stored = localStorage.getItem('column_config_ai-call-record');
  if (stored) {
    try {
      const savedConfig = JSON.parse(stored);
      const merged = savedConfig.map((s: ColumnConfigItem) => {
        const defaultCol = allColumns.find(c => c.key === s.key);
        return {
          key: s.key,
          title: s.title,
          dataIndex: s.dataIndex,
          width: s.width || defaultCol?.width,
          visible: s.visible !== undefined ? s.visible : true,
          order: s.order !== undefined ? s.order : defaultCol?.order || 0,
        };
      });
      currentColumns.value = merged.sort((a: ColumnConfigItem, b: ColumnConfigItem) => a.order - b.order);
    } catch (e) {
      console.warn('加载列配置失败:', e);
    }
  }
});

// 格式化通话时长
const formatDuration = (seconds: number): string => {
  if (seconds < 60) return `${seconds}秒`;
  const min = Math.floor(seconds / 60);
  const sec = seconds % 60;
  return `${min}分${sec}秒`;
};

// 加载数据
const loadData = () => {
  loading.value = true;
  // TODO: 调用后端 API 获取数据
  setTimeout(() => {
    const scenes = ['贷款转存', '信用卡营销', '理财推荐', '客户回访'];
    const robots = ['小象助手-贷款版', '小象助手-信用卡版', '小象助手-理财版', '小象助手-回访版'];
    const intents = ['有意向', '无意向', '需跟进', '已拒绝', '-'];
    const answerResults = ['本人接听', '他人接听', '语音信箱', '空号', '关机'];
    dataSource.value = Array.from({ length: 15 }, (_, index) => {
      const sceneIdx = index % 4;
      const mobile = `138${String(10000000 + index * 1111111).slice(0, 8)}`;
      const isAnswered = index % 3 !== 0;
      return {
        callUuid: `AI-CALL-${String(index + 1).padStart(6, '0')}`,
        callRecordPath: `/records/ai/2026/05/08/${String(index + 1).padStart(3, '0')}.wav`,
        scene: scenes[sceneIdx],
        batchName: `批次-${scenes[sceneIdx]}-20260508`,
        robotName: robots[sceneIdx],
        callerPhoneNum: `0571-8888${String(1000 + index).slice(1)}`,
        calleePhoneNum: mobile,
        calleeArea: ['上海', '北京', '广州', '深圳', '杭州'][index % 5],
        customerName: ['张三', '李四', '王五', '赵六', '钱七'][index % 5],
        dialTime: `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:30`,
        answerTime: isAnswered ? `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:35` : '-',
        hangupTime: `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(18 + index).padStart(2, '0')}:20`,
        callDuration: isAnswered ? [158, 30, 457, 210, 95, 300, 180, 45, 520, 130, 60][index % 11] : 0,
        callStatus: isAnswered ? '已接通' : '未接通',
        answerResult: isAnswered ? answerResults[index % 3] : answerResults[3 + (index % 2)],
        intentResult: isAnswered ? intents[index % 5] : '-',
        transferStatus: isAnswered && index % 5 === 0 ? '已转人工' : '未转人工',
      };
    });
    total.value = 150;
    pagination.total = 150;
    loading.value = false;
  }, 500);
};

// 初始化加载
loadData();

// 搜索
const handleSearch = () => {
  pagination.current = 1;
  loadData();
  message.success('搜索成功');
};

// 重置
const handleReset = () => {
  searchForm.scene = undefined;
  searchForm.batchName = '';
  searchForm.callerPhoneNum = '';
  searchForm.calleePhoneNum = '';
  searchForm.dialTimeRange = undefined;
  searchForm.callStatus = undefined;
  searchForm.transferStatus = undefined;
  pagination.current = 1;
  loadData();
  message.success('重置成功');
};

// 表格变化
const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  loadData();
};

// 分页变化
const handlePageChange = () => {
  loadData();
};

// 选择行变化
const onSelectChange = (keys: string[]) => {
  selectedRowKeys.value = keys;
};

// 打开列设置弹窗
const showColumnSetting = () => {
  columnSettingModalRef.value?.open();
};

// 列设置保存回调
const handleColumnSave = (columns: ColumnConfigItem[]) => {
  currentColumns.value = columns;
};

// 列设置取消回调
const handleColumnCancel = () => {};

// 查看对话详情
const handleViewDetail = (record: ReportItem) => {
  detailRecord.value = record;
  // 未接通的通话没有ASR数据
  if (record.answerResult === '空号' || record.answerResult === '关机') {
    aiDialogList.value = [];
    manualAsrDialogList.value = [];
    detailModalVisible.value = true;
    return;
  }
  // TODO: 调用后端 API 获取 ASR 对话文本
  // AI 对话部分（始终有数据）
  aiDialogList.value = [
    // ── 第一轮：开场确认身份 ──
    {
      role: 'robot',
      time: '00:00:03',
      text: '您好，我是XX银行的智能客服小象，请问是张三先生吗？',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:00:06',
      text: '嗯，是我。',
      confidence: 95,
      endpoint: { vadDuration: 80, isEndpoint: true },
      semantic: {
        intentTag: '确认身份',
        keywords: ['是'],
      },
    },
    // ── 第二轮：AI 引出业务，客户残缺意图表达 ──
    {
      role: 'robot',
      time: '00:00:10',
      text: '张先生您好，您在我行有一笔个人消费贷款即将到期，想跟您确认一下续贷事宜。',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:00:16',
      text: '贷款？什么贷款来着…就是之前那个嘛。',
      confidence: 91,
      endpoint: { vadDuration: 95, isEndpoint: true },
      annotations: [
        { type: 'replace' as const, start: 10, end: 12, original: '辣是', value: '就是' },
      ],
      semantic: {
        intentTag: '残缺追问',
        keywords: ['贷款', '之前'],
        contextRef: '关联上文「个人消费贷款」，补充指代消解',
      },
    },
    // ── 第三轮：AI 基于上下文补全信息 ──
    {
      role: 'robot',
      time: '00:00:22',
      text: '您去年三月申请的那笔，金额三十万元，年化利率百分之四点三五，到期日是下个月二十号。您还有印象吗？',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:00:30',
      text: '哦哦，想起来了，那个利率…能不能再低点？',
      confidence: 93,
      endpoint: { vadDuration: 110, isEndpoint: true },
      semantic: {
        intentTag: '议价咨询',
        keywords: ['利率', '低'],
        contextRef: '承接上文「年化利率4.35%」，延续利率话题',
      },
    },
    // ── 第四轮：AI 识别议价意图并引导 ──
    {
      role: 'robot',
      time: '00:00:36',
      text: '理解您的想法。目前续贷可以享受老客户专属优惠，利率最低可至百分之三点八五，比上次降了零点五个百分点。您看这个方案可以吗？',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:00:45',
      text: '嗯…还行吧，那个…还款方式呢，能不能长一点？',
      confidence: 89,
      endpoint: { vadDuration: 130, isEndpoint: true },
      annotations: [
        { type: 'replace' as const, start: 15, end: 17, original: '那格', value: '那个' },
      ],
      semantic: {
        intentTag: '条件咨询',
        keywords: ['还款方式', '长'],
        contextRef: '上文已讨论利率，客户主动转入还款期限话题',
      },
    },
    // ── 第五轮：AI 基于上下文理解"长一点"指期限 ──
    {
      role: 'robot',
      time: '00:00:52',
      text: '可以的，续贷支持延长至三十六期，每月还款压力会小很多。以三十万为例，月供大约八千六百元左右。',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:01:00',
      text: '那行，差不多，就这个吧。',
      confidence: 94,
      endpoint: { vadDuration: 88, isEndpoint: true },
      semantic: {
        intentTag: '表达意向',
        keywords: ['这个'],
        contextRef: '指代上文「三十六期方案」，残缺代词消解',
      },
    },
    // ── 第六轮：AI 确认意向并推进 ──
    {
      role: 'robot',
      time: '00:01:05',
      text: '好的，那为您登记续贷意向。请问您方便近期到网点办理手续吗？需要携带身份证和银行卡。',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:01:12',
      text: '最近有点忙…能不能线上弄？',
      confidence: 92,
      endpoint: { vadDuration: 105, isEndpoint: true },
      semantic: {
        intentTag: '变更渠道',
        keywords: ['线上'],
        contextRef: '上文提议「到网点」，客户反向提出线上需求',
      },
    },
    // ── 第七轮：AI 灵活应对变更需求 ──
    {
      role: 'robot',
      time: '00:01:18',
      text: '当然可以，我们支持手机银行线上办理续贷。稍后会把操作链接以短信发到您手机上，按提示操作即可。',
      confidence: 0,
    },
    {
      role: 'customer',
      time: '00:01:25',
      text: '好的好的，那就这样，谢谢啊。',
      confidence: 96,
      endpoint: { vadDuration: 78, isEndpoint: true },
      semantic: {
        intentTag: '确认结束',
        keywords: ['谢谢'],
        contextRef: '多轮讨论达成一致，客户主动结束对话',
      },
    },
    // ── 第八轮：AI 结束语，转人工 ──
    {
      role: 'robot',
      time: '00:01:29',
      text: '不客气，我这边帮您转接人工坐席，为您办理后续手续，请稍等。',
      confidence: 0,
    },
  ];

  // 人工对话部分（可能没有ASR数据）
  // 模拟：部分记录有人工对话，部分没有
  const hasManualDialog = Math.random() > 0.5;
  if (hasManualDialog) {
    manualAsrDialogList.value = [
      {
        role: 'agent',
        time: '00:01:35',
        text: '张先生您好，我是客服专员小李，刚才AI已经跟我说了您的情况，我来帮您办理续贷手续。',
      },
      {
        role: 'customer',
        time: '00:01:40',
        text: '好的，需要什么材料吗？',
      },
      {
        role: 'agent',
        time: '00:01:45',
        text: '您需要准备好身份证和银行卡，我这边先帮您核实一下信息。请问您的身份证尾号是？',
      },
      {
        role: 'customer',
        time: '00:01:52',
        text: '1234',
      },
      {
        role: 'agent',
        time: '00:02:00',
        text: '好的，信息已核实。续贷申请已经为您提交，预计3个工作日内会有审批结果，届时会短信通知您。',
      },
      {
        role: 'customer',
        time: '00:02:08',
        text: '好的，谢谢。',
      },
      {
        role: 'agent',
        time: '00:02:12',
        text: '不客气，祝您生活愉快，再见。',
      },
    ];
  } else {
    manualAsrDialogList.value = [];
  }

  detailModalVisible.value = true;
};

// 导出 Excel
const handleExportExcel = () => {
  if (exportFieldKeys.value.length === 0) {
    message.warning('请至少选择一个导出字段');
    return;
  }
  const headers = exportFieldKeys.value.map(key => {
    const opt = exportFieldOptions.value.find(o => o.value === key);
    return opt ? opt.label : key;
  });
  const rows = dataSource.value.map(item =>
    exportFieldKeys.value.map(key => (item as any)[key] ?? '')
  );
  const wsData = [headers, ...rows];
  const ws = XLSX.utils.aoa_to_sheet(wsData);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'AI外呼记录');
  XLSX.writeFile(wb, 'AI外呼记录.xlsx');
  exportModalVisible.value = false;
  message.success('导出成功');
};
</script>

<style scoped>
.ai-call-record {
  padding: 0;
}

.quality-wrapper {
  background: #fff;
  border-radius: 8px;
}

.page-header-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #787676;
  margin: 0;
}

.page-description {
  font-size: 14px;
  color: #8c8c8c;
  margin: 0;
}

.search-and-table-area {
  background: #fff;
}

.search-area {
  background: #fff;
  border-radius: 6px;
  padding: 16px 20px 4px;
  margin-bottom: 0;
  border: 1px solid #f0f0f0;
}

.search-btn-space {
  display: flex;
  gap: 8px;
}

.table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
}

.table-toolbar-left {
  display: flex;
  align-items: center;
}

.selection-info {
  font-size: 13px;
  color: #666;
}

.table-toolbar-right {
  display: flex;
  align-items: center;
  gap: 0;
}

.table-area {
  background: #fff;
}

.table-wrapper {
  background: #fff;
}

:deep(.ant-table) {
  font-size: 13px;
}

:deep(.ant-table-thead > tr > th) {
  background: #f5f7fa;
  font-weight: 500;
  color: #333;
  white-space: nowrap;
}

:deep(.ant-table-tbody > tr > td) {
  white-space: nowrap;
}

/* 对话详情弹窗 - 通话信息区域 */
.detail-info-section {
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;
}

.detail-info-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  cursor: pointer;
  user-select: none;
}

.detail-info-header:hover {
  background: #fafafa;
}

.detail-info-title {
  font-size: 13px;
  font-weight: 600;
  color: #333;
}

.detail-info-toggle {
  color: #999;
  font-size: 12px;
}

.detail-info-body {
  max-height: 180px;
  overflow-y: auto;
  padding: 0 16px 12px;
}

.detail-info-body::-webkit-scrollbar {
  width: 6px;
}

.detail-info-body::-webkit-scrollbar-thumb {
  background: #d9d9d9;
  border-radius: 3px;
}

.detail-info-body::-webkit-scrollbar-track {
  background: transparent;
}

.detail-field-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px 24px;
}

.detail-field-item {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.detail-field-label {
  font-size: 12px;
  color: #999;
  line-height: 1;
  margin-bottom: 4px;
}

.detail-field-value {
  font-size: 13px;
  color: #333;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 语音转文本提示样式 */
.asr-empty-tip {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  padding: 40px 0;
}

.asr-converting-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 60px 0;
  color: #1890ff;
  font-size: 14px;
}

/* 对话详情弹窗 - 聊天样式 */
.chat-container {
  flex: 1;
  overflow-y: auto;
  padding: 20px 16px;
  background: #f5f5f5;
}

.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.chat-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chat-section-header {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: #fafafa;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  color: #333;
  border-left: 3px solid #722ed1;
}

.chat-section-header:has(.anticon-user) {
  border-left-color: #1890ff;
}

.chat-section-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chat-section-divider {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
}

.divider-line {
  flex: 1;
  height: 1px;
  background: #e8e8e8;
}

.divider-text {
  font-size: 12px;
  color: #999;
  white-space: nowrap;
}

.chat-row {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.chat-row-left {
  flex-direction: row;
}

.chat-row-right {
  flex-direction: row;
  justify-content: flex-end;
}

.chat-avatar {
  flex-shrink: 0;
}

.chat-bubble-wrap {
  max-width: 70%;
}

.chat-bubble-wrap-right {
  text-align: right;
}

.chat-name {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.chat-name-right {
  justify-content: flex-end;
}

.chat-bubble {
  padding: 10px 14px;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.6;
  color: #333;
  word-break: break-word;
}

.chat-bubble-left {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-top-left-radius: 2px;
}

.chat-bubble-right {
  background: #95ec69;
  border: 1px solid #84d65a;
  border-top-right-radius: 2px;
}

.chat-audio-bar {
  padding: 12px 16px;
  border-top: 1px solid #f0f0f0;
  background: #fff;
  flex-shrink: 0;
}

/* ASR 特性标签 */
.asr-endpoint-tag {
  font-size: 11px !important;
  line-height: 18px !important;
  padding: 0 5px !important;
  margin-left: 6px;
  vertical-align: middle;
}

.asr-endpoint-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
  margin-right: 3px;
  vertical-align: middle;
  animation: asr-pulse 1.5s ease-in-out infinite;
}

@keyframes asr-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.asr-confidence-tag {
  font-size: 11px !important;
  line-height: 18px !important;
  padding: 0 5px !important;
  margin-left: 4px;
  color: #8c8c8c !important;
  background: #f5f5f5 !important;
  border-color: #e8e8e8 !important;
  vertical-align: middle;
}

/* ASR 后处理标注 */
.asr-annotation {
  position: relative;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  padding-bottom: 1px;
  transition: background 0.2s;
}

.asr-annotation:hover {
  background: rgba(0, 0, 0, 0.04);
  border-radius: 2px;
}

.asr-ann-replace {
  border-bottom-color: #fa8c16;
  color: #fa8c16;
}

.asr-ann-highlight {
  border-bottom-color: #722ed1;
  color: #722ed1;
  background: rgba(114, 46, 209, 0.06);
}

.asr-ann-number {
  border-bottom-color: #1890ff;
  color: #1890ff;
}

.asr-ann-badge {
  font-size: 9px;
  line-height: 1;
  padding: 1px 3px;
  border-radius: 2px;
  vertical-align: super;
  margin-left: 1px;
  font-weight: 500;
}

.asr-ann-replace .asr-ann-badge {
  background: #fff7e6;
  color: #fa8c16;
}

.asr-ann-highlight .asr-ann-badge {
  background: #f9f0ff;
  color: #722ed1;
}

.asr-ann-number .asr-ann-badge {
  background: #e6f7ff;
  color: #1890ff;
}

/* 后处理标记 */
.asr-processed-mark {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  font-size: 11px;
  color: #52c41a;
  margin-top: 6px;
  padding-top: 5px;
  border-top: 1px dashed #e8e8e8;
}

.asr-processed-mark-green {
  color: #389e0d;
}

/* 气泡下方元信息 */
.asr-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 4px;
}

.asr-meta-right {
  justify-content: flex-end;
}

.asr-time {
  font-size: 11px;
  color: #bbb;
}

.asr-punctuation-tag {
  font-size: 10px;
  color: #52c41a;
  background: #f6ffed;
  border: 1px solid #b7eb8f;
  border-radius: 2px;
  padding: 0 4px;
  line-height: 16px;
}

/* 语义分析区域 */
.semantic-section {
  margin-top: 6px;
  padding: 6px 10px;
  background: #fafafa;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  font-size: 12px;
}

.semantic-row {
  display: flex;
  align-items: center;
  gap: 6px;
  line-height: 22px;
}

.semantic-row + .semantic-row {
  margin-top: 2px;
}

.semantic-label {
  color: #999;
  flex-shrink: 0;
  font-size: 11px;
  min-width: 32px;
}

.semantic-kw-tag {
  background: #fff7e6 !important;
  border-color: #ffd591 !important;
  color: #d46b08 !important;
  font-size: 11px !important;
}

.semantic-context {
  color: #8c8c8c;
  font-size: 11px;
  font-style: italic;
}
</style>
