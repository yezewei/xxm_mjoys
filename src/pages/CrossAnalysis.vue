<template>
  <div class="cross-analysis">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">交叉分析</h2>
            <p class="page-description">多维度自由组合交叉分析，深度洞察客户群体特征。</p>
          </div>
          <div class="header-right">
            <a-button @click="handleBack">
              <arrow-left-outlined />
              返回
            </a-button>
            <a-button type="primary" @click="handleCreate">
              <plus-outlined />
              新建分析
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
              v-model:value="searchForm.analysisName"
              placeholder="请输入分析名称"
              allow-clear
              style="width: 240px;"
            />
            <a-select
              v-model:value="searchForm.status"
              placeholder="状态"
              allow-clear
              style="width: 150px;"
            >
              <a-select-option value="draft">草稿</a-select-option>
              <a-select-option value="saved">已保存</a-select-option>
              <a-select-option value="published">已发布</a-select-option>
            </a-select>
            <a-range-picker
              v-model:value="searchForm.createTime"
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
                <template v-else-if="column.key === 'status'">
                  <a-badge
                    :status="getStatusBadge(record.status)"
                    :text="getStatusText(record.status)"
                  />
                </template>
                <template v-else-if="column.key === 'action'">
                  <a-space>
                    <a-button type="link" size="small" @click="handleView(record)">
                      查看
                    </a-button>
                    <a-button type="link" size="small" @click="handleEdit(record)">
                      编辑
                    </a-button>
                    <a-button type="link" size="small" @click="handleExecute(record)">
                      执行
                    </a-button>
                    <a-button type="link" size="small" @click="handleExport(record)">
                      导出
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

    <!-- 新建/编辑分析弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEditMode ? '编辑分析' : '新建分析'"
      width="800px"
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
        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="分析名称" name="analysisName">
              <a-input
                v-model:value="formData.analysisName"
                placeholder="请输入分析名称"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="分析描述" name="description">
              <a-textarea
                v-model:value="formData.description"
                placeholder="请输入分析描述"
                :rows="3"
              />
            </a-form-item>
          </a-col>
        </a-row>

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
                  <a-select-option value="occupation">职业</a-select-option>
                  <a-select-option value="region">地域</a-select-option>
                  <a-select-option value="customerLevel">客户等级</a-select-option>
                  <a-select-option value="openTime">开户时间</a-select-option>
                  <a-select-option value="channel">渠道</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="业务行为">
                  <a-select-option value="transactionFreq">交易频次</a-select-option>
                  <a-select-option value="transactionAmount">交易金额</a-select-option>
                  <a-select-option value="activeDays">活跃天数</a-select-option>
                  <a-select-option value="businessType">业务类型</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="价值分层">
                  <a-select-option value="aum">AUM资产规模</a-select-option>
                  <a-select-option value="riskLevel">风险等级</a-select-option>
                  <a-select-option value="lossRisk">流失预警</a-select-option>
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
                  <a-select-option value="customerNew">新增客户数</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="资产价值类">
                  <a-select-option value="aumAvg">平均AUM</a-select-option>
                  <a-select-option value="aumTotal">总AUM</a-select-option>
                  <a-select-option value="wealthBalance">理财保有量</a-select-option>
                </a-select-opt-group>
                <a-select-opt-group label="行为效率类">
                  <a-select-option value="activeRate">月活跃率</a-select-option>
                  <a-select-option value="transactionCount">交易笔数</a-select-option>
                  <a-select-option value="answerRate">接通率</a-select-option>
                </a-select-opt-group>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
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
  analysisName: '',
  status: undefined as string | undefined,
  createTime: undefined as any,
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
    title: '分析名称',
    dataIndex: 'analysisName',
    key: 'analysisName',
    width: 250,
    ellipsis: true,
  },
  {
    title: '维度组合',
    dataIndex: 'dimensions',
    key: 'dimensions',
    width: 250,
  },
  {
    title: '使用指标',
    dataIndex: 'indicators',
    key: 'indicators',
    width: 200,
  },
  {
    title: '创建人',
    dataIndex: 'creator',
    key: 'creator',
    width: 100,
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 100,
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    key: 'createTime',
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

// 表单数据
const formData = ref({
  id: undefined as number | undefined,
  analysisName: '',
  description: '',
  dimensions: [] as string[],
  indicators: [] as string[],
});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  analysisName: [
    { required: true, message: '请输入分析名称', trigger: 'blur' },
  ],
  dimensions: [
    { required: true, message: '请选择交叉维度', trigger: 'change' },
    { type: 'array', min: 2, max: 5, message: '请选择2-5个维度', trigger: 'change' },
  ],
  indicators: [
    { required: true, message: '请选择分析指标', trigger: 'change' },
    { type: 'array', min: 1, max: 10, message: '请选择1-10个指标', trigger: 'change' },
  ],
};

// 获取状态徽标
const getStatusBadge = (status: string) => {
  const badgeMap: Record<string, string> = {
    draft: 'default',
    saved: 'success',
    published: 'processing',
  };
  return badgeMap[status] || 'default';
};

// 获取状态文本
const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    draft: '草稿',
    saved: '已保存',
    published: '已发布',
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
        analysisName: '月度各网点客户等级×AUM交叉分析',
        dimensions: ['网点', '客户等级', 'AUM'],
        indicators: ['客户总量', '平均AUM', '月活跃率'],
        creator: '张经理',
        status: 'published',
        createTime: '2026-07-09 10:30:00',
      },
      {
        id: 2,
        analysisName: '渠道×产品×活跃度交叉分析',
        dimensions: ['渠道', '产品', '活跃度'],
        indicators: ['客户总量', '交易笔数', '接通率'],
        creator: '李经理',
        status: 'saved',
        createTime: '2026-07-08 15:20:00',
      },
      {
        id: 3,
        analysisName: '年龄×性别×交易频次交叉分析',
        dimensions: ['年龄', '性别', '交易频次'],
        indicators: ['客户总量', '交易笔数', '户均交易金额'],
        creator: '王经理',
        status: 'draft',
        createTime: '2026-07-08 09:00:00',
      },
      {
        id: 4,
        analysisName: '地域×客户等级×风险等级交叉分析',
        dimensions: ['地域', '客户等级', '风险等级'],
        indicators: ['客户总量', '总AUM', '理财保有量'],
        creator: '张经理',
        status: 'published',
        createTime: '2026-07-07 14:00:00',
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
  searchForm.analysisName = '';
  searchForm.status = undefined;
  searchForm.createTime = undefined;
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

// 新建分析
const handleCreate = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    analysisName: '',
    description: '',
    dimensions: [],
    indicators: [],
  };
  modalVisible.value = true;
};

// 编辑分析
const handleEdit = (record: any) => {
  isEditMode.value = true;
  formData.value = {
    id: record.id,
    analysisName: record.analysisName,
    description: record.description || '',
    dimensions: [...record.dimensions],
    indicators: [...record.indicators],
  };
  modalVisible.value = true;
};

// 查看分析
const handleView = (record: any) => {
  router.push(`/customer-analysis/cross/${record.id}`);
};

// 执行分析
const handleExecute = (record: any) => {
  message.success(`正在执行"${record.analysisName}"，请稍候...`);
  // TODO: 调用后端 API 执行分析
};

// 导出分析
const handleExport = (record: any) => {
  message.success(`导出"${record.analysisName}"成功`);
  // TODO: 调用后端 API 导出
};

// 删除分析
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除分析"${record.analysisName}"吗？`,
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

// 弹窗确定
const handleModalOk = () => {
  formRef.value?.validate().then(() => {
    modalConfirmLoading.value = true;
    // TODO: 调用后端 API 保存
    setTimeout(() => {
      message.success(isEditMode.value ? '修改成功' : '新建成功');
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
.cross-analysis {
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
</style>
