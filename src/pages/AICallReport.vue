<template>
  <div class="ai-call-report">
    <!-- 页面标题区域 -->
    <div class="page-header-section">
      <div class="page-header">
        <div class="header-left">
          <h2 class="page-title">AI 外呼报表</h2>
          <p class="page-description">按不同维度统计 AI 外呼通话相关指标</p>
        </div>
        <a class="header-action" href="#">
          <setting-outlined />
          设置统计维度
        </a>
      </div>
    </div>

    <!-- 搜索区域 -->
    <div class="search-area">
      <a-row :gutter="[16, 16]">
        <a-col :span="6">
          <a-select placeholder="请选择外呼场景" allow-clear style="width: 100%" />
        </a-col>
        <a-col :span="6">
          <a-select placeholder="数据批次类型" allow-clear style="width: 100%" />
        </a-col>
        <a-col :span="6">
          <a-select placeholder="请选择数据批次名称" allow-clear style="width: 100%" />
        </a-col>
        <a-col :span="6">
          <a-select placeholder="请选择管户机构名称" allow-clear style="width: 100%" />
        </a-col>
        <a-col :span="6">
          <a-input placeholder="请输入主叫号码" allow-clear style="width: 100%" />
        </a-col>
        <a-col :span="6">
          <a-range-picker
            v-model:value="dateRange"
            show-time
            format="YYYY-MM-DD HH:mm"
            style="width: 100%"
            :placeholder="['拨打时间开始', '拨打时间结束']"
          />
        </a-col>
        <a-col :span="6">
          <a-space>
            <a-button type="primary">
              <search-outlined />
              搜索
            </a-button>
            <a-button>
              <reload-outlined />
              重置
            </a-button>
          </a-space>
        </a-col>
      </a-row>
    </div>

    <!-- 表格区域 -->
    <div class="table-area">
      <!-- 表格上方工具栏 -->
      <div class="table-toolbar">
        <div class="table-toolbar-left">
          <span class="selection-info">共 {{ total }} 条，已选 {{ selectedRowKeys.length }} 条</span>
        </div>
        <div class="table-toolbar-right">
          <a-space>
            <a-button type="primary" @click="handleExport">
              <download-outlined />
              导出
            </a-button>
            <a-button @click="showColumnSettingModal">
              <setting-outlined />
              列表显示设置
            </a-button>
          </a-space>
        </div>
      </div>

      <!-- 数据表格 -->
      <a-table
        :columns="visibleColumns"
        :data-source="tableDataSource"
        :pagination="pagination"
        row-key="id"
        :loading="loading"
        :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
        :scroll="{ x: 1840 }"
        :locale="{
          pagination: {
            items_per_page: '条/页',
            jump_to: '跳至',
            page: '页',
            total: (total: number) => `共 ${total} 条`,
          },
        }"
        :show-size-changer="true"
      >
        <template #summary>
          <a-table-summary fixed="bottom">
            <a-table-summary-row class="footer-summary-row">
              <a-table-summary-cell>统计</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
              <a-table-summary-cell>2</a-table-summary-cell>
              <a-table-summary-cell>2</a-table-summary-cell>
              <a-table-summary-cell>2</a-table-summary-cell>
              <a-table-summary-cell>2</a-table-summary-cell>
              <a-table-summary-cell>100%</a-table-summary-cell>
              <a-table-summary-cell>--</a-table-summary-cell>
            </a-table-summary-row>
          </a-table-summary>
        </template>
      </a-table>
    </div>

    <!-- 列表显示设置模态框 -->
    <ColumnSettingModal
      ref="columnSettingModalRef"
      page-key="ai-call-report"
      :default-columns="allColumns"
      @save="handleColumnSave"
      @cancel="handleColumnCancel"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  DownloadOutlined,
  SettingOutlined,
} from '@ant-design/icons-vue';
import type { Key } from 'ant-design-vue/es/table/interface';
import * as XLSX from 'xlsx';
import ColumnSettingModal from '../components/ColumnSettingModal.vue';
import type { ColumnConfigItem } from '../utils/columnConfig';

interface ReportItem {
  key: string;
  id: number;
  scene: string;
  batchType: string;
  batchName: string;
  bankCode: string;
  bankName: string;
  orgCode: string;
  aiCallCount: number;
  aiCustomerCount: number;
  aiAnsweredCount: number;
  aiAnsweredCustomerCount: number;
  aiAnswerRate: number;
  callNumber: string;
}

const dateRange = ref<[any, any] | null>(null);
const loading = ref(false);
const total = ref(2);
const selectedRowKeys = ref<Key[]>([]);

// 列表显示设置相关
const columnSettingModalRef = ref<InstanceType<typeof ColumnSettingModal> | null>(null);
const currentColumns = ref<ColumnConfigItem[]>([]);

// 所有列配置（用于显示设置）
const allColumns: ColumnConfigItem[] = [
  {
    key: 'scene',
    title: '外呼场景',
    dataIndex: 'scene',
    width: 320,
    visible: true,
    order: 0,
  },
  {
    key: 'batchType',
    title: '数据批次类型',
    dataIndex: 'batchType',
    width: 150,
    visible: true,
    order: 1,
  },
  {
    key: 'batchName',
    title: '数据批次名称',
    dataIndex: 'batchName',
    width: 250,
    visible: true,
    order: 2,
  },
  {
    key: 'bankCode',
    title: '所属银行',
    dataIndex: 'bankCode',
    width: 120,
    visible: true,
    order: 3,
  },
  {
    key: 'bankName',
    title: '管户机构',
    dataIndex: 'bankName',
    width: 150,
    visible: true,
    order: 4,
  },
  {
    key: 'orgCode',
    title: '管户机构号',
    dataIndex: 'orgCode',
    width: 120,
    visible: true,
    order: 5,
  },
  {
    key: 'aiCallCount',
    title: 'AI 外呼数',
    dataIndex: 'aiCallCount',
    width: 120,
    visible: true,
    order: 6,
  },
  {
    key: 'aiCustomerCount',
    title: 'AI 外呼客户数',
    dataIndex: 'aiCustomerCount',
    width: 150,
    visible: true,
    order: 7,
  },
  {
    key: 'aiAnsweredCount',
    title: 'AI 接通数',
    dataIndex: 'aiAnsweredCount',
    width: 120,
    visible: true,
    order: 8,
  },
  {
    key: 'aiAnsweredCustomerCount',
    title: 'AI 接通客户数',
    dataIndex: 'aiAnsweredCustomerCount',
    width: 150,
    visible: true,
    order: 9,
  },
  {
    key: 'aiAnswerRate',
    title: 'AI 接通率',
    dataIndex: 'aiAnswerRate',
    width: 120,
    visible: true,
    order: 10,
  },
  {
    key: 'callNumber',
    title: '主叫号码',
    dataIndex: 'callNumber',
    width: 150,
    visible: true,
    order: 11,
  },
];

const tableDataSource = computed(() => {
  return [...dataSource];
});

// 根据当前配置计算可见列
const visibleColumns = computed(() => {
  const columnsToUse = currentColumns.value.length > 0 ? currentColumns.value : allColumns;
  const result = columnsToUse
    .filter(col => col.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0)) // 按 order 排序
    .map(col => ({
      title: col.title,
      dataIndex: col.dataIndex,
      key: col.key,
      width: col.width,
    }));
  console.log('[AICallReport] visibleColumns 计算:', {
    currentColumnsLength: currentColumns.value.length,
    columnsToUseLength: columnsToUse.length,
    visibleCount: result.length,
    result
  });
  return result;
});

const dataSource: ReportItem[] = [
  {
    key: '1',
    id: 1,
    scene: '贷款转存 - 接通即转（叶泽伟测试）',
    batchType: '测试批次',
    batchName: '拨测批次 20260306102110',
    bankCode: 'hzbank',
    bankName: '杭州银行',
    orgCode: '2440001',
    aiCallCount: 1,
    aiCustomerCount: 1,
    aiAnsweredCount: 1,
    aiAnsweredCustomerCount: 1,
    aiAnswerRate: 100,
    callNumber: '057111306',
  },
  {
    key: '2',
    id: 2,
    scene: '贷款转存 - 接通即转（叶泽伟测试）',
    batchType: '测试批次',
    batchName: 'XXX-杭州银行',
    bankCode: 'hzbank',
    bankName: '杭州银行',
    orgCode: '2440001',
    aiCallCount: 1,
    aiCustomerCount: 1,
    aiAnsweredCount: 1,
    aiAnsweredCustomerCount: 1,
    aiAnswerRate: 100,
    callNumber: '057111306',
  },
];

const pagination = reactive({
  total: 2,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
  pageSizeOptions: ['10', '20', '50', '100'],
  locale: {
    items_per_page: '条/页',
    jump_to: '跳至',
    page: '页',
  },
});

// 初始化时加载保存的配置
onMounted(() => {
  const stored = localStorage.getItem('column_config_ai-call-report');
  if (stored) {
    try {
      const savedConfig = JSON.parse(stored);
      // 合并配置
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

const onSelectChange = (keys: Key[]) => {
  selectedRowKeys.value = keys;
};

/**
 * 显示列设置模态框
 */
const showColumnSettingModal = () => {
  columnSettingModalRef.value?.open();
};

/**
 * 保存列设置
 */
const handleColumnSave = (columns: ColumnConfigItem[]) => {
  console.log('[AICallReport] handleColumnSave 被调用');
  console.log('[AICallReport] 接收到的 columns:', columns);
  currentColumns.value = columns;
  console.log('[AICallReport] currentColumns 更新后:', currentColumns.value);
};

/**
 * 取消列设置
 */
const handleColumnCancel = () => {
  // 取消时不做任何操作
};

/**
 * 导出 Excel 功能
 */
const handleExport = () => {
  // 准备导出数据（只导出可见列）
  const visibleCols = visibleColumns.value;
  const exportData = dataSource.map(item => {
    const row: Record<string, any> = {};
    visibleCols.forEach(col => {
      const dataIndex = col.dataIndex as keyof ReportItem;
      row[col.title] = item[dataIndex];
    });
    return row;
  });

  // 创建工作表
  const worksheet = XLSX.utils.json_to_sheet(exportData);

  // 设置列宽
  const colWidths = visibleCols.map(col => ({ wch: Math.max(12, (col.width || 100) / 7) }));
  worksheet['!cols'] = colWidths;

  // 创建工作簿
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, 'AI 外呼报表');

  // 生成文件名：AI 外呼报表_YYYYMMDD_HHmmss.xlsx
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');
  const fileName = `AI 外呼报表_${year}${month}${day}_${hours}${minutes}${seconds}.xlsx`;

  // 导出文件
  XLSX.writeFile(workbook, fileName);
};
</script>

<style scoped>
.ai-call-report {
  padding: 0;
}

/* 页面标题区域 */
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

.header-action {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  text-decoration: none;
  font-size: 14px;
}

.header-action:hover {
  color: #40a9ff;
}

/* 搜索区域 */
.search-area {
  padding: 24px 0;
  margin-bottom: 16px;
}

/* 表格区域 */
.table-area {
  background: #fff;
  padding: 16px;
  border-radius: 4px;
}

/* 表格工具栏 */
.table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.table-toolbar-left {
  display: flex;
  align-items: center;
}

.table-toolbar-right {
  display: flex;
  align-items: center;
}

.selection-info {
  font-size: 14px;
  color: #595959;
}

/* 表格样式覆盖 */
.table-area :deep(.ant-table-thead > tr > th) {
  background: #f0f5ff;
  color: #262626;
  font-weight: 600;
}

.table-area :deep(.ant-table-tbody > tr:hover > td) {
  background: #f0f5ff;
}

/* 分页器样式 */
.table-area :deep(.ant-pagination-item) {
  border-color: #d9d9d9;
}

.table-area :deep(.ant-pagination-item-active) {
  border-color: #1890ff;
  border: 1px solid #1890ff;
  background: #1890ff;
}

.table-area :deep(.ant-pagination-item-active a) {
  color: #fff;
}

.table-area :deep(.ant-pagination-options-quick-jumper input) {
  border-color: #d9d9d9;
}

/* 表格底部汇总行样式 */
.footer-summary-row {
  background: #f0f5ff !important;
}

.footer-summary-row .ant-table-cell {
  background: #f0f5ff !important;
  font-weight: 600;
  white-space: nowrap;
}

.footer-summary-row .ant-table-cell:first-child {
  padding-left: 16px;
}
</style>
