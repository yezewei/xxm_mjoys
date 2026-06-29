<template>
  <div class="manual-call-record">
    <div class="quality-wrapper">
      <!-- 页面标题区域 -->
      <div class="page-header-section">
        <div class="page-header">
          <div class="header-left">
            <h2 class="page-title">人工外呼记录</h2>
            <p class="page-description">记录坐席主动发起的人工外呼通话记录，支持查看对话详情与 ASR 识别结果。</p>
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
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.hangupBy"
                    placeholder="请选择挂断方"
                    allow-clear
                  >
                    <a-select-option value="坐席挂断">坐席挂断</a-select-option>
                    <a-select-option value="客户挂断">客户挂断</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="16" style="margin-top: -12px;">
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.seatExtNum"
                    placeholder="请输入坐席分机号"
                    allow-clear
                    @press-enter="handleSearch"
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
                    <a-select-option value="1">已接通</a-select-option>
                    <a-select-option value="0">未接通</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
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
              :scroll="{ x: 2200 }"
              @change="handleTableChange"
            >
              <!-- 通话状态列 -->
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'callStatus'">
                  <a-badge
                    :status="record.callStatus === '已接通' ? 'success' : 'error'"
                    :text="record.callStatus"
                  />
                </template>
                <!-- 挂断方列 -->
                <template v-else-if="column.key === 'hangupBy'">
                  <a-tag :color="record.hangupBy === '坐席挂断' ? 'blue' : 'green'">
                    {{ record.hangupBy }}
                  </a-tag>
                </template>
                <!-- 通话时长列 -->
                <template v-else-if="column.key === 'callDuration'">
                  {{ formatDuration(record.callDuration) }}
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
      page-key="manual-call-record"
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
          <div
            v-for="(item, index) in asrDialogList"
            :key="index"
            class="chat-row"
            :class="item.role === 'seat' ? 'chat-row-left' : 'chat-row-right'"
          >
            <!-- 坐席：头像在左 -->
            <template v-if="item.role === 'seat'">
              <div class="chat-avatar">
                <a-avatar :size="40" style="background-color: #1890ff">
                  <template #icon><UserOutlined /></template>
                </a-avatar>
              </div>
              <div class="chat-bubble-wrap">
                <div class="chat-name">
                  <span>坐席</span>
                  <a-tooltip v-if="item.endpoint">
                    <template #title>
                      端点检测：VAD 响应 {{ item.endpoint.vadDuration }}ms
                    </template>
                    <a-tag class="asr-endpoint-tag" color="blue" size="small">
                      <span class="asr-endpoint-dot"></span>端点检测
                    </a-tag>
                  </a-tooltip>
                  <a-tag v-if="item.confidence" class="asr-confidence-tag" size="small">
                    置信度 {{ item.confidence }}%
                  </a-tag>
                </div>
                <div class="chat-bubble chat-bubble-left">
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
                  <div v-if="item.annotations && item.annotations.length > 0" class="asr-processed-mark">
                    <check-circle-outlined /> 后处理
                  </div>
                </div>
                <div class="asr-meta">
                  <span class="asr-time">{{ item.time }}</span>
                  <span class="asr-punctuation-tag">智能断句</span>
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
                  <div v-if="item.annotations && item.annotations.length > 0" class="asr-processed-mark">
                    <check-circle-outlined /> 后处理
                  </div>
                </div>
                <div class="asr-meta">
                  <span class="asr-time">{{ item.time }}</span>
                  <span class="asr-punctuation-tag">智能断句</span>
                </div>
              </div>
            </template>
          </div>
          <template v-if="asrDialogList.length === 0">
            <div v-if="isInAsrQueue(detailRecord)" class="asr-converting-tip">
              <check-circle-outlined style="color: #52c41a" />
              <span>已加入语音转文本队列，等待识别</span>
            </div>
            <div v-else class="asr-empty-tip">
              <a-empty description="暂无 ASR 数据" />
              <a-button type="primary" @click="handleAsrConvert(detailRecord!)">
                <audio-outlined />
                语音转文本
              </a-button>
            </div>
          </template>
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
  dialTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  callerPhoneNum: '',
  calleePhoneNum: '',
  hangupBy: undefined as string | undefined,
  seatExtNum: '',
  callStatus: undefined as string | undefined,
  scene: undefined as string | undefined,
});

// 表格数据接口
interface ReportItem {
  callUuid: string;
  callRecordPath: string;
  callerPhoneNum: string;
  calleePhoneNum: string;
  calleeArea: string;
  customerName: string;
  seatExtNum: string;
  scene: string;
  dialTime: string;
  seatAnswerTime: string;
  custAnswerTime: string;
  hangupTime: string;
  hangupBy: string;
  callStatus: string;
  callDuration: number;
  intentResult: string;
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
  { key: 'callRecordPath', title: '通话录音路径', dataIndex: 'callRecordPath', width: 220, visible: true, order: 1 },
  { key: 'callerPhoneNum', title: '主叫号码', dataIndex: 'callerPhoneNum', width: 140, visible: true, order: 2 },
  { key: 'calleePhoneNum', title: '被叫号码', dataIndex: 'calleePhoneNum', width: 140, visible: true, order: 3 },
  { key: 'calleeArea', title: '被叫归属地', dataIndex: 'calleeArea', width: 120, visible: true, order: 4 },
  { key: 'customerName', title: '客户姓名', dataIndex: 'customerName', width: 100, visible: true, order: 5 },
  { key: 'seatExtNum', title: '坐席分机号', dataIndex: 'seatExtNum', width: 120, visible: true, order: 6 },
  { key: 'scene', title: '外呼场景', dataIndex: 'scene', width: 120, visible: true, order: 7 },
  { key: 'dialTime', title: '拨打时间', dataIndex: 'dialTime', width: 180, visible: true, order: 8 },
  { key: 'seatAnswerTime', title: '坐席接听时间', dataIndex: 'seatAnswerTime', width: 180, visible: true, order: 9 },
  { key: 'custAnswerTime', title: '客户接听时间', dataIndex: 'custAnswerTime', width: 180, visible: true, order: 10 },
  { key: 'hangupTime', title: '挂断时间', dataIndex: 'hangupTime', width: 180, visible: true, order: 11 },
  { key: 'hangupBy', title: '挂断方', dataIndex: 'hangupBy', width: 100, visible: true, order: 12 },
  { key: 'callStatus', title: '通话状态', dataIndex: 'callStatus', width: 100, visible: true, order: 13 },
  { key: 'callDuration', title: '通话时长', dataIndex: 'callDuration', width: 110, visible: true, order: 14 },
  { key: 'intentResult', title: '意向结果', dataIndex: 'intentResult', width: 120, visible: true, order: 15 },
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

// 详情字段定义
const detailFields = [
  { key: 'callUuid', label: '通话ID' },
  { key: 'callerPhoneNum', label: '主叫号码' },
  { key: 'calleePhoneNum', label: '被叫号码' },
  { key: 'calleeArea', label: '被叫归属地' },
  { key: 'customerName', label: '客户姓名' },
  { key: 'seatExtNum', label: '坐席分机号' },
  { key: 'scene', label: '外呼场景' },
  { key: 'dialTime', label: '拨打时间' },
  { key: 'seatAnswerTime', label: '坐席接听时间' },
  { key: 'custAnswerTime', label: '客户接听时间' },
  { key: 'hangupTime', label: '挂断时间' },
  { key: 'hangupBy', label: '挂断方' },
  { key: 'callStatus', label: '通话状态' },
  { key: 'callDuration', label: '通话时长', format: 'duration' as const },
  { key: 'intentResult', label: '意向结果' },
  { key: 'callRecordPath', label: '通话录音路径' },
];

const getDetailFieldValue = (record: ReportItem | null, field: typeof detailFields[number]) => {
  if (!record) return '-';
  const value = (record as any)[field.key];
  if (value === undefined || value === null || value === '') return '-';
  if (field.format === 'duration') return formatDuration(value);
  return String(value);
};

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

interface AsrItem {
  role: 'seat' | 'customer';
  time: string;
  text: string;
  confidence: number;
  endpoint?: AsrEndpoint;
  annotations?: AsrAnnotation[];
}
const asrDialogList = ref<AsrItem[]>([]);

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
  const stored = localStorage.getItem('column_config_manual-call-record');
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
    dataSource.value = Array.from({ length: 15 }, (_, index) => {
      const scenes = ['贷款转存', '信用卡营销', '理财推荐', '客户回访'];
      const intentResults = ['有意向', '无意向', '待跟进', '已成交', '拒绝'];
      return {
        callUuid: `CALL-20260627-${String(index + 1).padStart(3, '0')}`,
        callRecordPath: `/records/2026/06/27/${String(index + 1).padStart(3, '0')}.wav`,
        callerPhoneNum: `021-6666${String(1000 + index).slice(1)}`,
        calleePhoneNum: `138${String(10000000 + index * 1111).slice(0, 8)}`,
        calleeArea: ['上海', '北京', '广州', '深圳', '杭州'][index % 5],
        customerName: ['张三', '李四', '王五', '赵六', '钱七'][index % 5],
        seatExtNum: `8${String(100 + index)}`,
        scene: scenes[index % 4],
        dialTime: `2026-06-27 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:30`,
        seatAnswerTime: `2026-06-27 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:35`,
        custAnswerTime: index % 3 === 0 ? '-' : `2026-06-27 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:42`,
        hangupTime: `2026-06-27 ${String(9 + (index % 8)).padStart(2, '0')}:${String(18 + index).padStart(2, '0')}:20`,
        hangupBy: ['坐席挂断', '客户挂断'][index % 2],
        callStatus: index % 3 === 0 ? '未接通' : '已接通',
        callDuration: [158, 30, 457, 210, 95, 300, 180, 45, 520, 130, 60, 390, 240, 75, 480][index],
        intentResult: intentResults[index % 5],
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
  searchForm.dialTimeRange = undefined;
  searchForm.callerPhoneNum = '';
  searchForm.calleePhoneNum = '';
  searchForm.hangupBy = undefined;
  searchForm.seatExtNum = '';
  searchForm.callStatus = undefined;
  searchForm.scene = undefined;
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
const handleColumnCancel = () => {
  // 取消时不做任何操作
};

// 查看对话详情
const handleViewDetail = (record: ReportItem) => {
  detailRecord.value = record;
  // 未接通的通话没有ASR数据
  if (record.callStatus === '未接通') {
    asrDialogList.value = [];
    detailModalVisible.value = true;
    return;
  }
  // TODO: 调用后端 API 获取 ASR 对话文本
  asrDialogList.value = [
    {
      role: 'seat',
      time: '00:00:05',
      text: '您好，这里是XX银行客户服务中心，请问是张先生吗？',
      confidence: 98,
      endpoint: { vadDuration: 120, isEndpoint: true },
    },
    {
      role: 'customer',
      time: '00:00:08',
      text: '是的，我是。',
      confidence: 96,
      endpoint: { vadDuration: 85, isEndpoint: true },
    },
    {
      role: 'seat',
      time: '00:00:12',
      text: '张先生您好，您在我行有一笔理财产品即将到期，想跟您确认一下续期意向。',
      confidence: 94,
      endpoint: { vadDuration: 150, isEndpoint: true },
      annotations: [
        { type: 'replace' as const, start: 16, end: 18, original: '一齐', value: '一起' },
      ],
    },
    {
      role: 'customer',
      time: '00:00:18',
      text: '哦好的，是什么产品？',
      confidence: 93,
      endpoint: { vadDuration: 92, isEndpoint: true },
    },
    {
      role: 'seat',
      time: '00:00:22',
      text: '是您去年购买的稳健型理财产品，年化收益是百分之四点五，到期日是下个月十五号。',
      confidence: 95,
      endpoint: { vadDuration: 180, isEndpoint: true },
      annotations: [
        { type: 'highlight' as const, start: 10, end: 14, original: '稳健型理财', value: '稳健型理财' },
        { type: 'number' as const, start: 19, end: 26, original: '百分之四点五', value: '4.5%' },
        { type: 'number' as const, start: 32, end: 36, original: '十五号', value: '15号' },
      ],
    },
    {
      role: 'customer',
      time: '00:00:30',
      text: '收益还可以，我想了解一下新的产品有什么选择。',
      confidence: 95,
      endpoint: { vadDuration: 110, isEndpoint: true },
    },
    {
      role: 'seat',
      time: '00:00:35',
      text: '好的，目前我们有几款新产品，我可以发短信给您详细介绍，您看方便吗？',
      confidence: 97,
      endpoint: { vadDuration: 280, isEndpoint: true },
    },
    {
      role: 'customer',
      time: '00:00:40',
      text: '好的，可以的，谢谢。',
      confidence: 97,
      endpoint: { vadDuration: 75, isEndpoint: true },
    },
  ];
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
  XLSX.utils.book_append_sheet(wb, ws, '人工外呼记录');
  XLSX.writeFile(wb, '人工外呼记录.xlsx');
  exportModalVisible.value = false;
  message.success('导出成功');
};
</script>

<style scoped>
.manual-call-record {
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
  color: #555;
}

:deep(.ant-table-row:hover td) {
  background: #f0f7ff;
}

:deep(.ant-table) {
  border-radius: 0 0 6px 6px;
}

:deep(.ant-pagination) {
  margin: 16px 0;
}

/* 对话详情弹窗 - 通话信息区域 */
.detail-info-section {
  border-bottom: 1px solid #f0f0f0;
}

.detail-info-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  cursor: pointer;
  background: #fafafa;
  transition: background 0.2s;
}

.detail-info-header:hover {
  background: #f0f0f0;
}

.detail-info-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.detail-info-toggle {
  color: #999;
}

.detail-info-body {
  padding: 12px 20px 16px;
}

.detail-field-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px 24px;
}

.detail-field-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-field-label {
  font-size: 12px;
  color: #999;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
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
  color: #52c41a;
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
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.chat-name {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.chat-name-right {
  justify-content: flex-end;
}

.chat-bubble {
  padding: 10px 14px;
  border-radius: 8px;
  font-size: 13px;
  line-height: 1.6;
  word-break: break-word;
}

.chat-bubble-left {
  background: #fff;
  color: #333;
  border: 1px solid #e8e8e8;
  border-top-left-radius: 2px;
}

.chat-bubble-right {
  background: #1890ff;
  color: #fff;
  border-top-right-radius: 2px;
}

/* ASR 标注样式 */
.asr-annotation {
  position: relative;
  cursor: pointer;
  border-bottom: 1px dashed;
}

.asr-ann-badge {
  font-size: 10px;
  padding: 0 4px;
  border-radius: 3px;
  margin-left: 2px;
  vertical-align: super;
}

.asr-ann-replace {
  border-color: #faad14;
  background: rgba(250, 173, 20, 0.1);
}

.asr-ann-replace .asr-ann-badge {
  background: #faad14;
  color: #fff;
}

.asr-ann-highlight {
  border-color: #ff4d4f;
  background: rgba(255, 77, 79, 0.1);
}

.asr-ann-highlight .asr-ann-badge {
  background: #ff4d4f;
  color: #fff;
}

.asr-ann-number {
  border-color: #722ed1;
  background: rgba(114, 46, 209, 0.1);
}

.asr-ann-number .asr-ann-badge {
  background: #722ed1;
  color: #fff;
}

.asr-processed-mark {
  font-size: 11px;
  color: #52c41a;
  margin-top: 4px;
}

.asr-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 4px;
}

.asr-time {
  font-size: 11px;
  color: #bbb;
}

.asr-confidence-tag {
  font-size: 11px;
  margin: 0;
}

.asr-endpoint-tag {
  font-size: 11px;
  margin: 0;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.asr-endpoint-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
  display: inline-block;
}

.asr-punctuation-tag {
  font-size: 10px;
  color: #999;
  border: 1px solid #e8e8e8;
  padding: 0 4px;
  border-radius: 3px;
}

/* 底部录音播放 */
.chat-audio-bar {
  padding: 12px 20px;
  border-top: 1px solid #f0f0f0;
  background: #fff;
}
</style>
