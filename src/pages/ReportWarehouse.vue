<template>
  <div class="report-warehouse">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">报告仓库</h2>
            <p class="page-description">查看和下载所有生成的交叉分析报告。</p>
          </div>
          <div class="header-right">
            <a-button @click="handleBack">
              <arrow-left-outlined />
              返回
            </a-button>
            <a-button @click="handleRefresh">
              <reload-outlined />
              刷新
            </a-button>
          </div>
        </div>
      </div>

      <!-- 搜索区域和表格区域 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-space :size="16">
            <a-input
              v-model:value="searchForm.reportName"
              placeholder="请输入报告名称"
              allow-clear
              style="width: 240px;"
            />
            <a-select
              v-model:value="searchForm.templateId"
              placeholder="报告模板"
              allow-clear
              style="width: 200px;"
            >
              <a-select-option value="1">月度各网点客户等级×AUM交叉分析报告</a-select-option>
              <a-select-option value="2">周度渠道×产品×活跃度交叉分析报告</a-select-option>
              <a-select-option value="3">日度客户流失预警分析报告</a-select-option>
            </a-select>
            <a-select
              v-model:value="searchForm.status"
              placeholder="状态"
              allow-clear
              style="width: 120px;"
            >
              <a-select-option value="completed">已完成</a-select-option>
              <a-select-option value="generating">生成中</a-select-option>
              <a-select-option value="failed">失败</a-select-option>
            </a-select>
            <a-range-picker
              v-model:value="searchForm.generateTime"
              style="width: 240px;"
            />
            <a-button @click="handleReset">
              <reload-outlined />
              重置
            </a-button>
            <a-button type="primary" @click="handleSearch">
              <search-outlined />
              搜索
            </a-button>
          </a-space>
        </div>

        <!-- 表格上方工具栏 -->
        <div class="table-toolbar">
          <div class="table-toolbar-left">
            <span class="selection-info">共 {{ total }} 条</span>
          </div>
        </div>

        <!-- 数据表格 -->
        <div class="table-area">
          <div class="table-wrapper">
            <a-table
              :columns="columns"
              :data-source="dataSource"
              :pagination="false"
              row-key="id"
              :loading="loading"
              :scroll="{ x: 1200 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'fileFormat'">
                  <a-tag :color="record.fileFormat === 'excel' ? 'green' : 'red'">
                    {{ record.fileFormat === 'excel' ? 'Excel' : 'PDF' }}
                  </a-tag>
                </template>
                <template v-else-if="column.key === 'status'">
                  <a-badge
                    :status="getStatusBadge(record.status)"
                    :text="getStatusText(record.status)"
                  />
                </template>
                <template v-else-if="column.key === 'action'">
                  <a-space>
                    <a-button
                      type="link"
                      size="small"
                      :disabled="record.status !== 'completed'"
                      @click="handleView(record)"
                    >
                      查看
                    </a-button>
                    <a-button
                      type="link"
                      size="small"
                      :disabled="record.status !== 'completed'"
                      @click="handleDownload(record)"
                    >
                      下载
                    </a-button>
                    <a-button
                      v-if="record.status === 'failed'"
                      type="link"
                      size="small"
                      @click="handleRetry(record)"
                    >
                      重试
                    </a-button>
                    <a-button
                      type="link"
                      size="small"
                      danger
                      @click="handleDelete(record)"
                    >
                      删除
                    </a-button>
                  </a-space>
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

    <!-- 报告预览弹窗 -->
    <a-modal
      v-model:open="previewVisible"
      title="报告预览"
      width="900px"
      :footer="null"
    >
      <div class="preview-container">
        <a-spin :spinning="previewLoading">
          <div class="preview-content">
            <div class="preview-header">
              <h3>{{ previewData.reportName }}</h3>
              <div class="preview-meta">
                <span>模板：{{ previewData.templateName }}</span>
                <span>生成时间：{{ previewData.generateTime }}</span>
                <span>文件格式：{{ previewData.fileFormat === 'excel' ? 'Excel' : 'PDF' }}</span>
              </div>
            </div>
            <a-divider />
            <a-table
              :columns="previewColumns"
              :data-source="previewData.tableData"
              :pagination="false"
              bordered
              size="small"
            />
          </div>
        </a-spin>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import {
  ArrowLeftOutlined,
  ReloadOutlined,
  SearchOutlined,
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import type { TableColumnType } from 'ant-design-vue';
import Pagination from '@/components/Pagination';

const router = useRouter();

// 搜索表单
const searchForm = reactive({
  reportName: '',
  templateId: undefined as string | undefined,
  status: undefined as string | undefined,
  generateTime: undefined as any,
});

// 表格数据
const dataSource = ref<any[]>([]);
const total = ref(0);
const loading = ref(false);

// 分页
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

// 表格列配置
const columns: TableColumnType[] = [
  {
    title: '报告名称',
    dataIndex: 'reportName',
    key: 'reportName',
    width: 300,
    ellipsis: true,
  },
  {
    title: '模板名称',
    dataIndex: 'templateName',
    key: 'templateName',
    width: 250,
    ellipsis: true,
  },
  {
    title: '生成时间',
    dataIndex: 'generateTime',
    key: 'generateTime',
    width: 180,
  },
  {
    title: '文件格式',
    dataIndex: 'fileFormat',
    key: 'fileFormat',
    width: 100,
  },
  {
    title: '文件大小',
    dataIndex: 'fileSize',
    key: 'fileSize',
    width: 100,
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 100,
  },
  {
    title: '操作',
    key: 'action',
    width: 200,
    align: 'center',
    fixed: 'right',
  },
];

// 预览弹窗控制
const previewVisible = ref(false);
const previewLoading = ref(false);

// 预览数据
const previewData = ref({
  reportName: '',
  templateName: '',
  generateTime: '',
  fileFormat: '',
  tableData: [] as any[],
});

// 预览表格列
const previewColumns: TableColumnType[] = [
  { title: '网点', dataIndex: 'branch', key: 'branch' },
  { title: '客户等级', dataIndex: 'customerLevel', key: 'customerLevel' },
  { title: '客户数量', dataIndex: 'customerCount', key: 'customerCount', align: 'right' },
  { title: '占比', dataIndex: 'ratio', key: 'ratio', align: 'right' },
  { title: '平均AUM', dataIndex: 'avgAum', key: 'avgAum', align: 'right' },
];

// 获取状态徽标
const getStatusBadge = (status: string) => {
  const badgeMap: Record<string, string> = {
    completed: 'success',
    generating: 'processing',
    failed: 'error',
  };
  return badgeMap[status] || 'default';
};

// 获取状态文本
const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    completed: '已完成',
    generating: '生成中',
    failed: '失败',
  };
  return textMap[status] || status;
};

// 加载数据
const loadData = () => {
  loading.value = true;
  // TODO: 调用后端 API 获取数据
  // 模拟数据
  setTimeout(() => {
    dataSource.value = [
      {
        id: 1,
        reportName: '月度各网点客户等级×AUM交叉分析报告_202607',
        templateName: '月度各网点客户等级×AUM交叉分析报告',
        generateTime: '2026-07-05 02:15:00',
        fileFormat: 'excel',
        fileSize: '2.5MB',
        status: 'completed',
      },
      {
        id: 2,
        reportName: '周度渠道×产品×活跃度交叉分析报告_20260708',
        templateName: '周度渠道×产品×活跃度交叉分析报告',
        generateTime: '2026-07-08 03:10:00',
        fileFormat: 'excel',
        fileSize: '1.8MB',
        status: 'completed',
      },
      {
        id: 3,
        reportName: '日度客户流失预警分析报告_20260709',
        templateName: '日度客户流失预警分析报告',
        generateTime: '2026-07-09 02:05:00',
        fileFormat: 'pdf',
        fileSize: '3.2MB',
        status: 'completed',
      },
      {
        id: 4,
        reportName: '月度各网点客户等级×AUM交叉分析报告_202606',
        templateName: '月度各网点客户等级×AUM交叉分析报告',
        generateTime: '2026-07-05 02:00:00',
        fileFormat: 'excel',
        fileSize: '-',
        status: 'generating',
      },
      {
        id: 5,
        reportName: '周度渠道×产品×活跃度交叉分析报告_20260701',
        templateName: '周度渠道×产品×活跃度交叉分析报告',
        generateTime: '2026-07-01 03:00:00',
        fileFormat: 'excel',
        fileSize: '-',
        status: 'failed',
      },
    ];
    total.value = dataSource.value.length;
    pagination.total = dataSource.value.length;
    loading.value = false;
  }, 500);
};

// 搜索
const handleSearch = () => {
  pagination.current = 1;
  loadData();
  message.success('搜索成功');
};

// 重置
const handleReset = () => {
  searchForm.reportName = '';
  searchForm.templateId = undefined;
  searchForm.status = undefined;
  searchForm.generateTime = undefined;
  pagination.current = 1;
  loadData();
  message.success('重置成功');
};

// 分页变化
const handlePageChange = () => {
  loadData();
};

// 返回
const handleBack = () => {
  router.push('/customer-analysis');
};

// 刷新
const handleRefresh = () => {
  loadData();
  message.success('刷新成功');
};

// 查看报告
const handleView = (record: any) => {
  previewLoading.value = true;
  previewVisible.value = true;
  previewData.value = {
    reportName: record.reportName,
    templateName: record.templateName,
    generateTime: record.generateTime,
    fileFormat: record.fileFormat,
    tableData: [],
  };

  // 模拟加载预览数据
  setTimeout(() => {
    previewData.value.tableData = [
      { branch: '总行营业部', customerLevel: 'VIP客户', customerCount: 1250, ratio: '8.0%', avgAum: '1,850,000' },
      { branch: '总行营业部', customerLevel: '高价值客户', customerCount: 2380, ratio: '15.2%', avgAum: '720,000' },
      { branch: '城东支行', customerLevel: 'VIP客户', customerCount: 890, ratio: '5.7%', avgAum: '1,650,000' },
      { branch: '城东支行', customerLevel: '普通客户', customerCount: 4520, ratio: '28.8%', avgAum: '120,000' },
    ];
    previewLoading.value = false;
  }, 1000);
};

// 下载报告
const handleDownload = (record: any) => {
  message.success(`正在下载"${record.reportName}"`);
  // TODO: 调用后端 API 下载文件
};

// 重试生成
const handleRetry = (record: any) => {
  Modal.confirm({
    title: '确认重试',
    content: `确定要重新生成报告"${record.reportName}"吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      message.success(`正在重新生成"${record.reportName}"，请稍候...`);
      // TODO: 调用后端 API 重新生成
      loadData();
    },
  });
};

// 删除报告
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除报告"${record.reportName}"吗？`,
    okText: '确定',
    cancelText: '取消',
    okType: 'danger',
    onOk() {
      // TODO: 调用后端 API 删除
      message.success('删除成功');
      loadData();
    },
  });
};

// 初始化
onMounted(() => {
  loadData();
});
</script>

<style scoped>
.report-warehouse {
  min-height: 100%;
  background: #f5f5f5;
}

.quality-wrapper {
  padding: 24px;
}

.quality-header-section {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.quality-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-left {
  flex: 1;
}

.page-title {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
  color: #1f2329;
}

.page-description {
  margin: 0;
  font-size: 14px;
  color: #646a73;
}

.header-right {
  display: flex;
  gap: 12px;
}

/* 搜索区域和表格区域 */
.search-and-table-area {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.search-area {
  margin-bottom: 16px;
}

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

.selection-info {
  color: #646a73;
  font-size: 14px;
}

.table-area {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.table-wrapper {
  flex: 1;
}

.table-wrapper :deep(.ant-table-thead > tr > th) {
  white-space: nowrap;
}

.table-wrapper :deep(.ant-table-tbody > tr > td) {
  white-space: nowrap;
}

:deep(.ant-tag) {
  margin-right: 4px;
}

/* 预览容器 */
.preview-container {
  min-height: 300px;
}

.preview-content {
  padding: 16px;
}

.preview-header h3 {
  margin: 0 0 12px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2329;
}

.preview-meta {
  display: flex;
  gap: 24px;
  font-size: 14px;
  color: #646a73;
}

:deep(.ant-divider) {
  margin: 16px 0;
}
</style>
