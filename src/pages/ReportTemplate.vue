<template>
  <div class="report-template">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">报告模板</h2>
            <p class="page-description">配置定时报告模板，自动生成交叉分析报告并分发。</p>
          </div>
          <div class="header-right">
            <a-button @click="handleBack">
              <arrow-left-outlined />
              返回
            </a-button>
            <a-button type="primary" @click="handleAdd">
              <plus-outlined />
              新增模板
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
              v-model:value="searchForm.templateName"
              placeholder="请输入模板名称"
              allow-clear
              style="width: 240px;"
            />
            <a-select
              v-model:value="searchForm.status"
              placeholder="状态"
              allow-clear
              style="width: 120px;"
            >
              <a-select-option value="enabled">启用</a-select-option>
              <a-select-option value="disabled">停用</a-select-option>
            </a-select>
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
              :scroll="{ x: 1400 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'dimensions'">
                  <a-tag v-for="(dim, index) in record.dimensions" :key="index" color="blue">
                    {{ dim }}
                  </a-tag>
                </template>
                <template v-else-if="column.key === 'indicators'">
                  <a-tag v-for="(ind, index) in record.indicators" :key="index" color="cyan">
                    {{ ind }}
                  </a-tag>
                </template>
                <template v-else-if="column.key === 'scheduleType'">
                  <a-tag color="purple">
                    {{ getScheduleText(record.scheduleType) }}
                  </a-tag>
                </template>
                <template v-else-if="column.key === 'status'">
                  <a-switch
                    v-model:checked="record.statusBool"
                    checked-children="启用"
                    un-checked-children="停用"
                    @change="(checked: boolean) => handleStatusChange(record, checked)"
                  />
                </template>
                <template v-else-if="column.key === 'action'">
                  <a-space>
                    <a-button type="link" size="small" @click="handleView(record)">
                      预览
                    </a-button>
                    <a-button type="link" size="small" @click="handleEdit(record)">
                      编辑
                    </a-button>
                    <a-button type="link" size="small" @click="handleExecute(record)">
                      立即执行
                    </a-button>
                    <a-button type="link" size="small" danger @click="handleDelete(record)">
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

    <!-- 新增/编辑模板弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEditMode ? '编辑模板' : '新增模板'"
      width="900px"
      :confirm-loading="modalConfirmLoading"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleModalOk"
    >
      <a-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        layout="vertical"
      >
        <a-divider orientation="left">基础信息</a-divider>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="模板名称" name="templateName">
              <a-input
                v-model:value="formData.templateName"
                placeholder="请输入模板名称"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="输出格式" name="outputFormat">
              <a-select
                v-model:value="formData.outputFormat"
                placeholder="请选择输出格式"
              >
                <a-select-option value="excel">Excel</a-select-option>
                <a-select-option value="pdf">PDF</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="模板描述" name="description">
              <a-textarea
                v-model:value="formData.description"
                placeholder="请输入模板描述"
                :rows="2"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-divider orientation="left">分析配置</a-divider>
        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="交叉维度" name="dimensions">
              <a-select
                v-model:value="formData.dimensions"
                mode="multiple"
                placeholder="请选择交叉维度（2-5个）"
                :max-tag-count="5"
                style="width: 100%"
              >
                <a-select-opt-group label="客户基础属性">
                  <a-select-option value="age">年龄</a-select-option>
                  <a-select-option value="gender">性别</a-select-option>
                  <a-select-option value="region">地域</a-select-option>
                  <a-select-option value="customerLevel">客户等级</a-select-option>
                  <a-select-option value="channel">渠道</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="业务行为">
                  <a-select-option value="transactionFreq">交易频次</a-select-option>
                  <a-select-option value="activeDays">活跃天数</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="价值分层">
                  <a-select-option value="aum">AUM资产规模</a-select-option>
                  <a-select-option value="riskLevel">风险等级</a-select-option>
                </a-select-opt-group>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="分析指标" name="indicators">
              <a-select
                v-model:value="formData.indicators"
                mode="multiple"
                placeholder="请选择分析指标（1-10个）"
                :max-tag-count="5"
                style="width: 100%"
              >
                <a-select-opt-group label="规模类指标">
                  <a-select-option value="customerTotal">客户总量</a-select-option>
                  <a-select-option value="customerValid">有效客户数</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="资产价值类">
                  <a-select-option value="aumAvg">平均AUM</a-select-option>
                  <a-select-option value="aumTotal">总AUM</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="行为效率类">
                  <a-select-option value="activeRate">月活跃率</a-select-option>
                  <a-select-option value="transactionCount">交易笔数</a-select-option>
                </a-select-opt-group>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-divider orientation="left">定时设置</a-divider>
        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="执行周期" name="scheduleType">
              <a-select
                v-model:value="formData.scheduleType"
                placeholder="请选择执行周期"
              >
                <a-select-option value="daily">每日</a-select-option>
                <a-select-option value="weekly">每周</a-select-option>
                <a-select-option value="monthly">每月</a-select-option>
                <a-select-option value="quarterly">每季度</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="执行时间" name="executeTime">
              <a-time-picker
                v-model:value="formData.executeTime"
                format="HH:mm"
                style="width: 100%"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item
              v-if="formData.scheduleType === 'monthly'"
              label="执行日期"
              name="executeDate"
            >
              <a-select
                v-model:value="formData.executeDate"
                placeholder="请选择执行日期"
              >
                <a-select-option v-for="i in 28" :key="i" :value="String(i)">
                  每月{{ i }}号
                </a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item
              v-else-if="formData.scheduleType === 'weekly'"
              label="执行日期"
              name="executeDate"
            >
              <a-select
                v-model:value="formData.executeDate"
                placeholder="请选择执行日期"
              >
                <a-select-option value="1">周一</a-select-option>
                <a-select-option value="2">周二</a-select-option>
                <a-select-option value="3">周三</a-select-option>
                <a-select-option value="4">周四</a-select-option>
                <a-select-option value="5">周五</a-select-option>
                <a-select-option value="6">周六</a-select-option>
                <a-select-option value="0">周日</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-divider orientation="left">分发设置</a-divider>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="接收人" name="receivers">
              <a-select
                v-model:value="formData.receivers"
                mode="multiple"
                placeholder="请选择接收人"
                style="width: 100%"
              >
                <a-select-option value="user1">张经理</a-select-option>
                <a-select-option value="user2">李经理</a-select-option>
                <a-select-option value="user3">王经理</a-select-option>
                <a-select-option value="dept1">业务管理部</a-select-option>
                <a-select-option value="dept2">风险管理部</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="分发渠道" name="channels">
              <a-checkbox-group v-model:value="formData.channels">
                <a-checkbox value="email">邮件推送</a-checkbox>
                <a-checkbox value="message">站内消息</a-checkbox>
                <a-checkbox value="archive">报告仓库</a-checkbox>
              </a-checkbox-group>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="是否启用" name="isEnabled">
              <a-switch
                v-model:checked="formData.isEnabled"
                checked-children="启用"
                un-checked-children="停用"
              />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>

    <!-- 预览弹窗 -->
    <a-modal
      v-model:open="previewVisible"
      title="报告预览"
      width="900px"
      :footer="null"
    >
      <div class="preview-container">
        <a-spin :spinning="previewLoading">
          <div class="preview-content">
            <h3>{{ previewData.templateName }}</h3>
            <p class="preview-desc">{{ previewData.description }}</p>
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
  PlusOutlined,
  ReloadOutlined,
  SearchOutlined,
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import type { TableColumnType } from 'ant-design-vue';
import Pagination from '@/components/Pagination';

const router = useRouter();

// 搜索表单
const searchForm = reactive({
  templateName: '',
  status: undefined as string | undefined,
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
    title: '模板名称',
    dataIndex: 'templateName',
    key: 'templateName',
    width: 250,
    ellipsis: true,
  },
  {
    title: '维度组合',
    dataIndex: 'dimensions',
    key: 'dimensions',
    width: 200,
  },
  {
    title: '使用指标',
    dataIndex: 'indicators',
    key: 'indicators',
    width: 200,
  },
  {
    title: '执行周期',
    dataIndex: 'scheduleType',
    key: 'scheduleType',
    width: 100,
  },
  {
    title: '接收人',
    dataIndex: 'receiversText',
    key: 'receiversText',
    width: 150,
    ellipsis: true,
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 100,
  },
  {
    title: '最后执行时间',
    dataIndex: 'lastExecuteTime',
    key: 'lastExecuteTime',
    width: 180,
  },
  {
    title: '操作',
    key: 'action',
    width: 250,
    align: 'center',
    fixed: 'right',
  },
];

// 弹窗控制
const modalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);

// 预览弹窗控制
const previewVisible = ref(false);
const previewLoading = ref(false);

// 预览数据
const previewData = ref({
  templateName: '',
  description: '',
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

// 表单数据
const formData = ref({
  id: undefined as number | undefined,
  templateName: '',
  description: '',
  outputFormat: 'excel',
  dimensions: [] as string[],
  indicators: [] as string[],
  scheduleType: 'monthly',
  executeTime: null as any,
  executeDate: '1',
  receivers: [] as string[],
  channels: ['email', 'archive'],
  isEnabled: true,
});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  templateName: [
    { required: true, message: '请输入模板名称', trigger: 'blur' },
  ],
  outputFormat: [
    { required: true, message: '请选择输出格式', trigger: 'change' },
  ],
  dimensions: [
    { required: true, message: '请选择交叉维度', trigger: 'change' },
    { type: 'array', min: 2, max: 5, message: '请选择2-5个维度', trigger: 'change' },
  ],
  indicators: [
    { required: true, message: '请选择分析指标', trigger: 'change' },
    { type: 'array', min: 1, max: 10, message: '请选择1-10个指标', trigger: 'change' },
  ],
  scheduleType: [
    { required: true, message: '请选择执行周期', trigger: 'change' },
  ],
  executeTime: [
    { required: true, message: '请选择执行时间', trigger: 'change' },
  ],
  receivers: [
    { required: true, message: '请选择接收人', trigger: 'change' },
  ],
  channels: [
    { required: true, message: '请选择分发渠道', trigger: 'change' },
  ],
};

// 获取执行周期文本
const getScheduleText = (type: string) => {
  const textMap: Record<string, string> = {
    daily: '每日',
    weekly: '每周',
    monthly: '每月',
    quarterly: '每季度',
  };
  return textMap[type] || type;
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
        templateName: '月度各网点客户等级×AUM交叉分析报告',
        dimensions: ['网点', '客户等级', 'AUM'],
        indicators: ['客户总量', '平均AUM', '月活跃率'],
        scheduleType: 'monthly',
        receiversText: '张经理、业务管理部',
        statusBool: true,
        lastExecuteTime: '2026-07-05 02:00:00',
      },
      {
        id: 2,
        templateName: '周度渠道×产品×活跃度交叉分析报告',
        dimensions: ['渠道', '产品', '活跃度'],
        indicators: ['客户总量', '交易笔数', '接通率'],
        scheduleType: 'weekly',
        receiversText: '李经理、风险管理部',
        statusBool: true,
        lastExecuteTime: '2026-07-08 03:00:00',
      },
      {
        id: 3,
        templateName: '日度客户流失预警分析报告',
        dimensions: ['客户等级', '流失预警', 'AUM'],
        indicators: ['客户总量', '流失客户数', '流失率'],
        scheduleType: 'daily',
        receiversText: '王经理',
        statusBool: false,
        lastExecuteTime: '2026-07-09 02:00:00',
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
  searchForm.templateName = '';
  searchForm.status = undefined;
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

// 新增模板
const handleAdd = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    templateName: '',
    description: '',
    outputFormat: 'excel',
    dimensions: [],
    indicators: [],
    scheduleType: 'monthly',
    executeTime: null,
    executeDate: '1',
    receivers: [],
    channels: ['email', 'archive'],
    isEnabled: true,
  };
  modalVisible.value = true;
};

// 编辑模板
const handleEdit = (record: any) => {
  isEditMode.value = true;
  formData.value = {
    id: record.id,
    templateName: record.templateName,
    description: record.description || '',
    outputFormat: record.outputFormat || 'excel',
    dimensions: [...record.dimensions],
    indicators: [...record.indicators],
    scheduleType: record.scheduleType,
    executeTime: null,
    executeDate: record.executeDate || '1',
    receivers: record.receivers || [],
    channels: record.channels || ['email', 'archive'],
    isEnabled: record.statusBool,
  };
  modalVisible.value = true;
};

// 预览模板
const handleView = (record: any) => {
  previewLoading.value = true;
  previewVisible.value = true;
  previewData.value = {
    templateName: record.templateName,
    description: record.description || '暂无描述',
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

// 立即执行
const handleExecute = (record: any) => {
  Modal.confirm({
    title: '确认执行',
    content: `确定要立即执行模板"${record.templateName}"吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      message.success(`正在执行"${record.templateName}"，请稍候...`);
      // TODO: 调用后端 API 执行
    },
  });
};

// 删除模板
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除模板"${record.templateName}"吗？`,
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

// 状态变化
const handleStatusChange = (record: any, checked: boolean) => {
  // TODO: 调用后端 API 更新状态
  message.success(`模板"${record.templateName}"已${checked ? '启用' : '停用'}`);
};

// 弹窗确定
const handleModalOk = () => {
  formRef.value?.validate().then(() => {
    modalConfirmLoading.value = true;
    // TODO: 调用后端 API 保存
    setTimeout(() => {
      message.success(isEditMode.value ? '修改成功' : '新增成功');
      modalVisible.value = false;
      modalConfirmLoading.value = false;
      loadData();
    }, 500);
  }).catch(() => {
    // 验证失败
  });
};

// 初始化
onMounted(() => {
  loadData();
});
</script>

<style scoped>
.report-template {
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
  margin-bottom: 4px;
}

/* 预览容器 */
.preview-container {
  min-height: 300px;
}

.preview-content h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2329;
}

.preview-desc {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #646a73;
}

:deep(.ant-divider) {
  margin: 16px 0;
}

:deep(.ant-checkbox-wrapper) {
  margin-right: 16px;
}
</style>
