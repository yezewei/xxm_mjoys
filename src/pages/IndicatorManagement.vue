<template>
  <div class="indicator-management">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">指标管理</h2>
            <p class="page-description">管理交叉分析指标体系，统一指标口径和计算逻辑。</p>
          </div>
          <div class="header-right">
            <a-button @click="handleBack">
              <arrow-left-outlined />
              返回
            </a-button>
            <a-button @click="handleGroupManage">
              <folder-outlined />
              指标分组
            </a-button>
            <a-button type="primary" @click="handleAdd">
              <plus-outlined />
              新增指标
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
              v-model:value="searchForm.indicatorName"
              placeholder="请输入指标名称"
              allow-clear
              style="width: 200px;"
            />
            <a-input
              v-model:value="searchForm.indicatorCode"
              placeholder="请输入指标编码"
              allow-clear
              style="width: 200px;"
            />
            <a-select
              v-model:value="searchForm.groupId"
              placeholder="指标分组"
              allow-clear
              style="width: 150px;"
            >
              <a-select-option value="1">规模类指标</a-select-option>
              <a-select-option value="2">资产价值类</a-select-option>
              <a-select-option value="3">行为效率类</a-select-option>
              <a-select-option value="4">经营收益类</a-select-option>
              <a-select-option value="5">对比类指标</a-select-option>
            </a-select>
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
                <template v-if="column.key === 'indicatorType'">
                  <a-tag :color="getTypeColor(record.indicatorType)">
                    {{ getTypeText(record.indicatorType) }}
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
                <template v-else-if="column.key === 'isSensitive'">
                  <a-tag v-if="record.isSensitive" color="warning">是</a-tag>
                  <span v-else>否</span>
                </template>
                <template v-else-if="column.key === 'action'">
                  <a-space>
                    <a-button type="link" size="small" @click="handleView(record)">
                      查看
                    </a-button>
                    <a-button type="link" size="small" @click="handleEdit(record)">
                      编辑
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

    <!-- 新增/编辑指标弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isViewMode ? '查看指标' : isEditMode ? '编辑指标' : '新增指标'"
      width="800px"
      :confirm-loading="modalConfirmLoading"
      :footer="isViewMode ? null : undefined"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleModalOk"
    >
      <a-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        layout="vertical"
        :disabled="isViewMode"
      >
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="指标名称" name="indicatorName">
              <a-input
                v-model:value="formData.indicatorName"
                placeholder="请输入指标名称"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="指标编码" name="indicatorCode">
              <a-input
                v-model:value="formData.indicatorCode"
                placeholder="请输入指标编码（英文）"
                :disabled="isEditMode"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="指标分组" name="groupId">
              <a-select
                v-model:value="formData.groupId"
                placeholder="请选择指标分组"
              >
                <a-select-option value="1">规模类指标</a-select-option>
                <a-select-option value="2">资产价值类</a-select-option>
                <a-select-option value="3">行为效率类</a-select-option>
                <a-select-option value="4">经营收益类</a-select-option>
                <a-select-option value="5">对比类指标</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="指标类型" name="indicatorType">
              <a-select
                v-model:value="formData.indicatorType"
                placeholder="请选择指标类型"
              >
                <a-select-option value="scale">规模类</a-select-option>
                <a-select-option value="asset">资产价值类</a-select-option>
                <a-select-option value="behavior">行为效率类</a-select-option>
                <a-select-option value="profit">经营收益类</a-select-option>
                <a-select-option value="compare">对比类</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="计算逻辑" name="calcLogic">
              <a-textarea
                v-model:value="formData.calcLogic"
                placeholder="请输入计算逻辑描述"
                :rows="3"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="数据来源" name="dataSource">
              <a-input
                v-model:value="formData.dataSource"
                placeholder="请输入数据来源表/接口"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="单位" name="unit">
              <a-input
                v-model:value="formData.unit"
                placeholder="请输入指标单位（元、个、%等）"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="小数位数" name="decimal">
              <a-input-number
                v-model:value="formData.decimal"
                :min="0"
                :max="4"
                placeholder="小数位数"
                style="width: 100%"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="是否脱敏" name="isSensitive">
              <a-switch v-model:checked="formData.isSensitive" />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="状态" name="status">
              <a-switch
                v-model:checked="formData.statusBool"
                checked-children="启用"
                un-checked-children="停用"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="指标说明" name="description">
              <a-textarea
                v-model:value="formData.description"
                placeholder="请输入指标详细说明"
                :rows="3"
              />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>

    <!-- 指标分组管理弹窗 -->
    <a-modal
      v-model:open="groupModalVisible"
      title="指标分组管理"
      width="600px"
      :footer="null"
    >
      <a-table
        :columns="groupColumns"
        :data-source="groupData"
        :pagination="false"
        size="small"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'action'">
            <a-space>
              <a-button type="link" size="small" @click="handleEditGroup(record)">
                编辑
              </a-button>
              <a-button type="link" size="small" danger @click="handleDeleteGroup(record)">
                删除
              </a-button>
            </a-space>
          </template>
        </template>
      </a-table>
      <div style="margin-top: 16px; text-align: right;">
        <a-button type="primary" @click="handleAddGroup">
          <plus-outlined />
          新增分组
        </a-button>
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
  FolderOutlined,
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';
import type { TableColumnType } from 'ant-design-vue';
import Pagination from '@/components/Pagination';

const router = useRouter();

// 搜索表单
const searchForm = reactive({
  indicatorName: '',
  indicatorCode: '',
  groupId: undefined as string | undefined,
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
    title: '指标名称',
    dataIndex: 'indicatorName',
    key: 'indicatorName',
    width: 150,
    ellipsis: true,
  },
  {
    title: '指标编码',
    dataIndex: 'indicatorCode',
    key: 'indicatorCode',
    width: 150,
  },
  {
    title: '指标分组',
    dataIndex: 'groupName',
    key: 'groupName',
    width: 120,
  },
  {
    title: '指标类型',
    dataIndex: 'indicatorType',
    key: 'indicatorType',
    width: 100,
  },
  {
    title: '计算逻辑',
    dataIndex: 'calcLogic',
    key: 'calcLogic',
    width: 200,
    ellipsis: true,
  },
  {
    title: '数据来源',
    dataIndex: 'dataSource',
    key: 'dataSource',
    width: 120,
  },
  {
    title: '单位',
    dataIndex: 'unit',
    key: 'unit',
    width: 80,
  },
  {
    title: '是否脱敏',
    dataIndex: 'isSensitive',
    key: 'isSensitive',
    width: 80,
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
    width: 180,
    align: 'center',
    fixed: 'right',
  },
];

// 弹窗控制
const modalVisible = ref(false);
const isEditMode = ref(false);
const isViewMode = ref(false);
const modalConfirmLoading = ref(false);

// 分组弹窗控制
const groupModalVisible = ref(false);

// 表单数据
const formData = ref({
  id: undefined as number | undefined,
  indicatorName: '',
  indicatorCode: '',
  groupId: undefined as string | undefined,
  indicatorType: undefined as string | undefined,
  calcLogic: '',
  dataSource: '',
  unit: '',
  decimal: 2,
  isSensitive: false,
  statusBool: true,
  description: '',
});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  indicatorName: [
    { required: true, message: '请输入指标名称', trigger: 'blur' },
  ],
  indicatorCode: [
    { required: true, message: '请输入指标编码', trigger: 'blur' },
  ],
  groupId: [
    { required: true, message: '请选择指标分组', trigger: 'change' },
  ],
  indicatorType: [
    { required: true, message: '请选择指标类型', trigger: 'change' },
  ],
  calcLogic: [
    { required: true, message: '请输入计算逻辑', trigger: 'blur' },
  ],
  dataSource: [
    { required: true, message: '请输入数据来源', trigger: 'blur' },
  ],
};

// 分组表格列
const groupColumns: TableColumnType[] = [
  {
    title: '分组名称',
    dataIndex: 'groupName',
    key: 'groupName',
  },
  {
    title: '分组编码',
    dataIndex: 'groupCode',
    key: 'groupCode',
  },
  {
    title: '指标数量',
    dataIndex: 'indicatorCount',
    key: 'indicatorCount',
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    align: 'center',
  },
];

// 分组数据
const groupData = ref([
  { id: 1, groupName: '规模类指标', groupCode: 'scale', indicatorCount: 5 },
  { id: 2, groupName: '资产价值类', groupCode: 'asset', indicatorCount: 5 },
  { id: 3, groupName: '行为效率类', groupCode: 'behavior', indicatorCount: 5 },
  { id: 4, groupName: '经营收益类', groupCode: 'profit', indicatorCount: 3 },
  { id: 5, groupName: '对比类指标', groupCode: 'compare', indicatorCount: 5 },
]);

// 获取类型颜色
const getTypeColor = (type: string) => {
  const colorMap: Record<string, string> = {
    scale: 'blue',
    asset: 'cyan',
    behavior: 'green',
    profit: 'orange',
    compare: 'purple',
  };
  return colorMap[type] || 'default';
};

// 获取类型文本
const getTypeText = (type: string) => {
  const textMap: Record<string, string> = {
    scale: '规模类',
    asset: '资产价值类',
    behavior: '行为效率类',
    profit: '经营收益类',
    compare: '对比类',
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
        indicatorName: '客户总量',
        indicatorCode: 'customer_total',
        groupName: '规模类指标',
        indicatorType: 'scale',
        calcLogic: '统计所有客户数量',
        dataSource: '客户表',
        unit: '个',
        decimal: 0,
        isSensitive: false,
        statusBool: true,
        description: '系统中所有客户的总数',
      },
      {
        id: 2,
        indicatorName: '有效客户数',
        indicatorCode: 'customer_valid',
        groupName: '规模类指标',
        indicatorType: 'scale',
        calcLogic: '统计有效客户数量（状态=有效）',
        dataSource: '客户表',
        unit: '个',
        decimal: 0,
        isSensitive: false,
        statusBool: true,
        description: '状态为有效的客户数量',
      },
      {
        id: 3,
        indicatorName: '平均AUM',
        indicatorCode: 'aum_avg',
        groupName: '资产价值类',
        indicatorType: 'asset',
        calcLogic: 'SUM(AUM)/COUNT(客户)',
        dataSource: '资产表',
        unit: '元',
        decimal: 2,
        isSensitive: true,
        statusBool: true,
        description: '客户平均资产规模',
      },
      {
        id: 4,
        indicatorName: '月活跃率',
        indicatorCode: 'active_rate',
        groupName: '行为效率类',
        indicatorType: 'behavior',
        calcLogic: '月活跃客户数/总客户数',
        dataSource: '行为表',
        unit: '%',
        decimal: 2,
        isSensitive: false,
        statusBool: true,
        description: '月活跃客户占比',
      },
      {
        id: 5,
        indicatorName: '人均贡献',
        indicatorCode: 'contribution_avg',
        groupName: '经营收益类',
        indicatorType: 'profit',
        calcLogic: 'SUM(贡献)/COUNT(客户)',
        dataSource: '收益表',
        unit: '元',
        decimal: 2,
        isSensitive: true,
        statusBool: true,
        description: '客户人均贡献收益',
      },
      {
        id: 6,
        indicatorName: '同比',
        indicatorCode: 'yoy',
        groupName: '对比类指标',
        indicatorType: 'compare',
        calcLogic: '(本期-去年同期)/去年同期',
        dataSource: '计算得出',
        unit: '%',
        decimal: 2,
        isSensitive: false,
        statusBool: true,
        description: '与去年同期对比增长率',
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
  searchForm.indicatorName = '';
  searchForm.indicatorCode = '';
  searchForm.groupId = undefined;
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

// 新增指标
const handleAdd = () => {
  isEditMode.value = false;
  isViewMode.value = false;
  formData.value = {
    id: undefined,
    indicatorName: '',
    indicatorCode: '',
    groupId: undefined,
    indicatorType: undefined,
    calcLogic: '',
    dataSource: '',
    unit: '',
    decimal: 2,
    isSensitive: false,
    statusBool: true,
    description: '',
  };
  modalVisible.value = true;
};

// 编辑指标
const handleEdit = (record: any) => {
  isEditMode.value = true;
  isViewMode.value = false;
  formData.value = {
    id: record.id,
    indicatorName: record.indicatorName,
    indicatorCode: record.indicatorCode,
    groupId: record.groupId,
    indicatorType: record.indicatorType,
    calcLogic: record.calcLogic,
    dataSource: record.dataSource,
    unit: record.unit,
    decimal: record.decimal,
    isSensitive: record.isSensitive,
    statusBool: record.statusBool,
    description: record.description,
  };
  modalVisible.value = true;
};

// 查看指标
const handleView = (record: any) => {
  isViewMode.value = true;
  isEditMode.value = false;
  formData.value = {
    id: record.id,
    indicatorName: record.indicatorName,
    indicatorCode: record.indicatorCode,
    groupId: record.groupId,
    indicatorType: record.indicatorType,
    calcLogic: record.calcLogic,
    dataSource: record.dataSource,
    unit: record.unit,
    decimal: record.decimal,
    isSensitive: record.isSensitive,
    statusBool: record.statusBool,
    description: record.description,
  };
  modalVisible.value = true;
};

// 删除指标
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除指标"${record.indicatorName}"吗？`,
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
  message.success(`指标"${record.indicatorName}"已${checked ? '启用' : '停用'}`);
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

// 指标分组管理
const handleGroupManage = () => {
  groupModalVisible.value = true;
};

// 新增分组
const handleAddGroup = () => {
  message.info('新增分组功能开发中');
};

// 编辑分组
const handleEditGroup = (record: any) => {
  message.info(`编辑分组"${record.groupName}"功能开发中`);
};

// 删除分组
const handleDeleteGroup = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除分组"${record.groupName}"吗？`,
    okText: '确定',
    cancelText: '取消',
    okType: 'danger',
    onOk() {
      message.success('删除成功');
    },
  });
};

// 初始化
onMounted(() => {
  loadData();
});
</script>

<style scoped>
.indicator-management {
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
</style>
