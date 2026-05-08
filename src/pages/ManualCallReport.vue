<template>
  <div class="manual-call-report">
    <div class="quality-wrapper">
      <!-- 页面标题区域 -->
      <div class="page-header-section">
        <div class="page-header">
          <div class="header-left">
            <h2 class="page-title">人工通信接口外呼记录</h2>
            <p class="page-description">记录外部系统通过调用"人工外呼通信接口"，产生的人工外呼记录。</p>
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
                    v-model:value="searchForm.dialMethod"
                    placeholder="请选择外呼发起方式"
                    allow-clear
                  >
                    <a-select-option value="坐席分机">坐席分机</a-select-option>
                    <a-select-option value="坐席手机">坐席手机</a-select-option>
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
              :scroll="{ x: 2000 }"
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
      v-model:visible="columnSettingVisible"
      :columns="allColumns"
      :column-order="columnOrder"
      :visible-column-keys="visibleColumnKeys"
      @apply="handleColumnSettingApply"
    />

    <!-- 对话详情弹窗 -->
    <a-modal
      v-model:open="detailModalVisible"
      title="对话详情"
      width="700px"
      :footer="null"
      :body-style="{ padding: 0, display: 'flex', flexDirection: 'column', height: '560px' }"
    >
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
                <div class="chat-name">坐席</div>
                <div class="chat-bubble chat-bubble-left">{{ item.text }}</div>
              </div>
            </template>
            <!-- 客户：头像在右 -->
            <template v-else>
              <div class="chat-bubble-wrap chat-bubble-wrap-right">
                <div class="chat-name chat-name-right">客户</div>
                <div class="chat-bubble chat-bubble-right">{{ item.text }}</div>
              </div>
              <div class="chat-avatar">
                <a-avatar :size="40" style="background-color: #52c41a">
                  <template #icon><UserOutlined /></template>
                </a-avatar>
              </div>
            </template>
          </div>
          <a-empty v-if="asrDialogList.length === 0" description="暂无 ASR 数据" />
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
import { ref, computed, reactive } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  SettingOutlined,
  FileExcelOutlined,
  UserOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnType } from 'ant-design-vue';
import { message } from 'ant-design-vue';
import type { Dayjs } from 'dayjs';
import Pagination from '@/components/Pagination';
import ColumnSettingModal from '../components/ColumnSettingModal.vue';
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
  dialMethod: undefined as string | undefined,
});

// 表格数据接口
interface ReportItem {
  callUuid: string;
  callRecordPath: string;
  callerPhoneNum: string;
  calleePhoneNum: string;
  calleeArea: string;
  seatExtNum: string;
  seatMobile: string;
  dialMethod: string;
  dialTime: string;
  seatAnswerTime: string;
  custAnswerTime: string;
  hangupTime: string;
  hangupBy: string;
  callStatus: string;
  callDuration: number;
  dialContent: string;
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

// 定义所有列
const allColumns: TableColumnType[] = [
  { title: '通话ID', dataIndex: 'callUuid', key: 'callUuid', width: 200 },
  { title: '通话录音路径', dataIndex: 'callRecordPath', key: 'callRecordPath', width: 220 },
  { title: '主叫号码', dataIndex: 'callerPhoneNum', key: 'callerPhoneNum', width: 140 },
  { title: '被叫号码', dataIndex: 'calleePhoneNum', key: 'calleePhoneNum', width: 140 },
  { title: '被叫归属地', dataIndex: 'calleeArea', key: 'calleeArea', width: 120 },
  { title: '坐席分机号', dataIndex: 'seatExtNum', key: 'seatExtNum', width: 120 },
  { title: '坐席手机号', dataIndex: 'seatMobile', key: 'seatMobile', width: 140 },
  { title: '外呼发起方式', dataIndex: 'dialMethod', key: 'dialMethod', width: 130 },
  { title: '拨打时间', dataIndex: 'dialTime', key: 'dialTime', width: 180 },
  { title: '坐席接听时间', dataIndex: 'seatAnswerTime', key: 'seatAnswerTime', width: 180 },
  { title: '客户接听时间', dataIndex: 'custAnswerTime', key: 'custAnswerTime', width: 180 },
  { title: '挂断时间', dataIndex: 'hangupTime', key: 'hangupTime', width: 180 },
  { title: '挂断方', dataIndex: 'hangupBy', key: 'hangupBy', width: 100 },
  { title: '通话状态', dataIndex: 'callStatus', key: 'callStatus', width: 100 },
  { title: '通话时长', dataIndex: 'callDuration', key: 'callDuration', width: 110 },
  { title: '拨号内容', dataIndex: 'dialContent', key: 'dialContent', width: 300 },
  { title: '操作', dataIndex: 'action', key: 'action', width: 120, align: 'center', fixed: 'right' },
];

// 列设置相关状态
const columnSettingVisible = ref(false);

// 对话详情弹窗相关状态
const detailModalVisible = ref(false);
const detailRecord = ref<ReportItem | null>(null);
interface AsrItem {
  role: 'seat' | 'customer';
  time: string;
  text: string;
}
const asrDialogList = ref<AsrItem[]>([]);

// 导出弹窗相关状态
const exportModalVisible = ref(false);
const exportFieldKeys = ref<string[]>([]);
const exportFieldOptions = computed(() => {
  const cols = visibleColumns.value.map(col => ({
    label: col.title as string,
    value: col.dataIndex as string,
  }));
  // 追加"对话内容"
  cols.push({ label: '对话内容', value: 'dialContent' });
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
const STORAGE_KEY = 'column_config_manual-call-report';
const savedConfig = localStorage.getItem(STORAGE_KEY);
const defaultVisibleKeys = ['callUuid', 'callerPhoneNum', 'calleePhoneNum', 'calleeArea', 'seatExtNum', 'seatMobile', 'dialMethod', 'dialTime', 'seatAnswerTime', 'custAnswerTime', 'hangupTime', 'hangupBy', 'callStatus', 'callDuration'];
const defaultOrder = allColumns.map(col => col.dataIndex as string);

const visibleColumnKeys = ref<string[]>(
  savedConfig ? JSON.parse(savedConfig).visibleKeys : defaultVisibleKeys
);
const columnOrder = ref<string[]>(
  savedConfig ? JSON.parse(savedConfig).order : defaultOrder
);

// 计算可见列（按顺序），操作列始终显示
const visibleColumns = computed(() => {
  const keySet = new Set(visibleColumnKeys.value);
  const ordered = columnOrder.value
    .filter(key => keySet.has(key))
    .map(key => allColumns.find(col => col.dataIndex === key))
    .filter(Boolean) as TableColumnType[];
  allColumns.forEach(col => {
    if (keySet.has(col.dataIndex as string) && !ordered.find(c => c.dataIndex === col.dataIndex)) {
      ordered.push(col);
    }
  });
  // 操作列始终追加在最后
  const actionCol = allColumns.find(col => col.key === 'action');
  if (actionCol && !ordered.find(c => c.key === 'action')) {
    ordered.push(actionCol);
  }
  return ordered;
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
      const isExt = index % 2 === 0;
      const mobile = `139${String(80000000 + index * 1111).slice(0, 8)}`;
      return {
        callUuid: `CALL-20260508-${String(index + 1).padStart(3, '0')}`,
        callRecordPath: `/records/2026/05/08/${String(index + 1).padStart(3, '0')}.wav`,
        callerPhoneNum: isExt ? `021-5555${String(1000 + index).slice(1)}` : mobile,
        calleePhoneNum: `138${String(10000000 + index * 1111).slice(0, 8)}`,
        calleeArea: ['上海', '北京', '广州', '深圳', '杭州'][index % 5],
        seatExtNum: isExt ? `8${String(100 + index)}` : '-',
        seatMobile: isExt ? '-' : mobile,
        dialMethod: isExt ? '坐席分机' : '坐席手机',
        dialTime: `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:30`,
        seatAnswerTime: `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:35`,
        custAnswerTime: index % 3 === 0 ? '-' : `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(15 + index).padStart(2, '0')}:42`,
        hangupTime: `2026-05-08 ${String(9 + (index % 8)).padStart(2, '0')}:${String(18 + index).padStart(2, '0')}:20`,
        hangupBy: ['坐席挂断', '客户挂断'][index % 2],
        callStatus: index % 3 === 0 ? '未接通' : '已接通',
        callDuration: [158, 30, 457, 210, 95, 300, 180, 45, 520, 130, 60, 390, 240, 75, 480][index],
        dialContent: [
          '客户咨询理财产品到期续期事宜',
          '信用卡账单提醒',
          '贷款还款提醒及还款方案沟通',
          '保险产品推荐',
          '基金定投收益汇报',
          '客户投诉处理跟进',
          '新开户资料补充通知',
          'VIP 客户专属活动邀请',
          '房贷利率调整通知',
          '信用卡额度提升邀请',
          '理财产品到期提醒',
          '客户回访满意度调查',
          '贷款审批进度通知',
          '账户异常交易提醒',
          '贵宾服务升级通知',
        ][index],
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
  searchForm.dialMethod = undefined;
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
  columnSettingVisible.value = true;
};

// 查看对话详情
const handleViewDetail = (record: ReportItem) => {
  detailRecord.value = record;
  // TODO: 调用后端 API 获取 ASR 对话文本
  asrDialogList.value = [
    { role: 'seat', time: '00:00:05', text: '您好，这里是XX银行客户服务中心，请问是张先生吗？' },
    { role: 'customer', time: '00:00:08', text: '是的，我是。' },
    { role: 'seat', time: '00:00:12', text: '张先生您好，您在我行有一笔理财产品即将到期，想跟您确认一下续期意向。' },
    { role: 'customer', time: '00:00:18', text: '哦好的，是什么产品？' },
    { role: 'seat', time: '00:00:22', text: '是您去年购买的稳健型理财产品，年化收益4.5%，到期日是下个月15号。' },
    { role: 'customer', time: '00:00:30', text: '收益还可以，我想了解一下新的产品有什么选择。' },
    { role: 'seat', time: '00:00:35', text: '好的，目前我们有几款新产品，我可以发短信给您详细介绍，您看方便吗？' },
    { role: 'customer', time: '00:00:40', text: '好的，可以的，谢谢。' },
  ];
  detailModalVisible.value = true;
};

// 列设置应用回调
const handleColumnSettingApply = (newVisibleKeys: string[], newOrder: string[]) => {
  visibleColumnKeys.value = newVisibleKeys;
  columnOrder.value = newOrder;
  localStorage.setItem(
    STORAGE_KEY,
    JSON.stringify({ visibleKeys: newVisibleKeys, order: newOrder })
  );
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
  XLSX.utils.book_append_sheet(wb, ws, '人工通信接口外呼记录');
  XLSX.writeFile(wb, '人工通信接口外呼记录.xlsx');
  exportModalVisible.value = false;
  message.success('导出成功');
};
</script>

<style scoped>
.manual-call-report {
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
  text-align: right;
}

.chat-name {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}

.chat-name-right {
  text-align: right;
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
</style>
