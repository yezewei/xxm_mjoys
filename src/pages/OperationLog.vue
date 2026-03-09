<template>
  <div class="operation-log">
    <!-- 顶部标签页 -->
    <div class="tabs-header">
      <div class="tab-list">
        <div 
          class="tab-item" 
          :class="{ 'tab-item-active': activeTab === 'operation' }"
          @click="activeTab = 'operation'"
        >
          操作记录
        </div>
        <div 
          class="tab-item"
          :class="{ 'tab-item-active': activeTab === 'login' }"
          @click="activeTab = 'login'"
        >
          登录日志
        </div>
      </div>
    </div>

    <!-- 搜索区域 -->
    <div class="search-area">
      <a-row :gutter="[16, 16]">
        <!-- 第一行 -->
        <a-col :span="6">
          <a-range-picker
            v-model:value="searchForm.dateRange"
            format="YYYY-MM-DD"
            style="width: 100%"
            :placeholder="['开始日期', '结束日期']"
          />
        </a-col>
        <a-col :span="6">
          <a-input
            v-model:value="searchForm.operator"
            placeholder="操作人"
            allow-clear
            style="width: 100%"
          />
        </a-col>
        <a-col :span="6">
          <a-select
            v-model:value="searchForm.operatorRole"
            placeholder="操作人角色"
            allow-clear
            style="width: 100%"
          >
            <a-select-option value="platform_admin">平台管理员</a-select-option>
            <a-select-option value="org_admin">机构管理员</a-select-option>
            <a-select-option value="user">普通用户</a-select-option>
          </a-select>
        </a-col>
        <a-col :span="6">
          <a-select
            v-model:value="searchForm.operationType"
            placeholder="操作类型"
            allow-clear
            style="width: 100%"
          >
            <a-select-option value="script_management">话术管理</a-select-option>
            <a-select-option value="user_management">用户管理</a-select-option>
            <a-select-option value="role_management">角色管理</a-select-option>
            <a-select-option value="system_config">系统配置</a-select-option>
          </a-select>
        </a-col>
        <!-- 第二行 -->
        <a-col :span="6">
          <a-input
            v-model:value="searchForm.operationContent"
            placeholder="操作内容"
            allow-clear
            style="width: 100%"
          />
        </a-col>
        <a-col :span="6">
          <a-input
            v-model:value="searchForm.orgName"
            placeholder="请输入机构名称"
            allow-clear
            style="width: 100%"
          />
        </a-col>
        <a-col :span="6">
          <a-input
            v-model:value="searchForm.operationObject"
            placeholder="操作对象"
            allow-clear
            style="width: 100%"
          />
        </a-col>
        <a-col :span="6">
          <a-space>
            <a-button type="primary" @click="handleSearch">
              <search-outlined />
              搜索
            </a-button>
            <a-button @click="handleReset">
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
          <span class="total-count">共{{ total }}条</span>
        </div>
      </div>

      <!-- 数据表格 -->
      <a-table
        :columns="columns"
        :data-source="tableDataSource"
        :pagination="pagination"
        row-key="id"
        :loading="loading"
        :scroll="{ x: 1400 }"
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
        <!-- 操作列自定义渲染 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'action'">
            <a class="action-link" @click="handleViewDetail(record)">
              点击查看
            </a>
          </template>
          <template v-else-if="column.dataIndex === 'operationType'">
            {{ getOperationTypeLabel(record.operationType) }}
          </template>
        </template>
      </a-table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons-vue';

// ==================== 接口定义 ====================

interface OperationLogItem {
  key: string;
  id: number;
  operator: string;
  operatorRole: string;
  orgName: string;
  operationTime: string;
  operationType: string;
  operationContent: string;
  operationObject: string;
  ipAddress: string;
}

interface SearchFormType {
  dateRange: [any, any] | null;
  operator: string | null;
  operatorRole: string | null;
  operationType: string | null;
  operationContent: string | null;
  orgName: string | null;
  operationObject: string | null;
}

// ==================== 状态定义 ====================

const activeTab = ref('operation');
const loading = ref(false);
const total = ref(603734);

const searchForm = reactive<SearchFormType>({
  dateRange: null,
  operator: null,
  operatorRole: null,
  operationType: null,
  operationContent: null,
  orgName: null,
  operationObject: null,
});

// ==================== 列配置 ====================

const columns = [
  {
    title: '操作人',
    dataIndex: 'operator',
    key: 'operator',
    width: 120,
    sorter: true,
  },
  {
    title: '操作人角色',
    dataIndex: 'operatorRole',
    key: 'operatorRole',
    width: 150,
    sorter: true,
  },
  {
    title: '所属机构',
    dataIndex: 'orgName',
    key: 'orgName',
    width: 150,
    sorter: true,
  },
  {
    title: '操作时间',
    dataIndex: 'operationTime',
    key: 'operationTime',
    width: 180,
    sorter: true,
  },
  {
    title: '操作类型',
    dataIndex: 'operationType',
    key: 'operationType',
    width: 120,
    sorter: true,
  },
  {
    title: '操作内容',
    dataIndex: 'operationContent',
    key: 'operationContent',
    width: 150,
    ellipsis: true,
  },
  {
    title: '操作对象',
    dataIndex: 'operationObject',
    key: 'operationObject',
    width: 120,
  },
  {
    title: 'IP 地址',
    dataIndex: 'ipAddress',
    key: 'ipAddress',
    width: 140,
  },
  {
    title: '接口',
    dataIndex: 'action',
    key: 'action',
    width: 100,
    fixed: 'right' as const,
  },
];

// ==================== 模拟数据 ====================

const dataSource: OperationLogItem[] = [
  {
    key: '1',
    id: 1,
    operator: '王小',
    operatorRole: '平台管理员',
    orgName: '系统平台',
    operationTime: '2026-03-06 14:55:11',
    operationType: 'script_management',
    operationContent: '删除 QA',
    operationObject: '话术:-1',
    ipAddress: '192.168.1.100',
  },
  {
    key: '2',
    id: 2,
    operator: '王小',
    operatorRole: '平台管理员',
    orgName: '系统平台',
    operationTime: '2026-03-06 13:50:56',
    operationType: 'script_management',
    operationContent: '删除 QA',
    operationObject: '话术:-1',
    ipAddress: '192.168.1.100',
  },
  {
    key: '3',
    id: 3,
    operator: '王小',
    operatorRole: '平台管理员',
    orgName: '系统平台',
    operationTime: '2026-03-06 13:50:51',
    operationType: 'script_management',
    operationContent: '删除 QA',
    operationObject: '话术:-1',
    ipAddress: '192.168.1.100',
  },
  {
    key: '4',
    id: 4,
    operator: '王小',
    operatorRole: '平台管理员',
    orgName: '系统平台',
    operationTime: '2026-03-06 13:50:47',
    operationType: 'script_management',
    operationContent: '删除 QA',
    operationObject: '话术:-1',
    ipAddress: '192.168.1.100',
  },
  {
    key: '5',
    id: 5,
    operator: '王小',
    operatorRole: '平台管理员',
    orgName: '系统平台',
    operationTime: '2026-03-06 13:50:40',
    operationType: 'script_management',
    operationContent: '删除 QA',
    operationObject: '话术:-1',
    ipAddress: '192.168.1.100',
  },
  {
    key: '6',
    id: 6,
    operator: '王小',
    operatorRole: '平台管理员',
    orgName: '系统平台',
    operationTime: '2026-03-06 13:50:35',
    operationType: 'script_management',
    operationContent: '删除 QA',
    operationObject: '话术:-1',
    ipAddress: '192.168.1.100',
  },
];

// ==================== 计算属性 ====================

const tableDataSource = computed(() => {
  return [...dataSource];
});

const pagination = reactive({
  total: 603734,
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

// ==================== 辅助函数 ====================

/**
 * 获取操作类型标签
 */
const getOperationTypeLabel = (type: string): string => {
  const labelMap: Record<string, string> = {
    script_management: '话术管理',
    user_management: '用户管理',
    role_management: '角色管理',
    system_config: '系统配置',
  };
  return labelMap[type] || type;
};

// ==================== 事件处理 ====================

/**
 * 搜索
 */
const handleSearch = () => {
  loading.value = true;
  console.log('搜索条件:', searchForm);
  setTimeout(() => {
    loading.value = false;
  }, 500);
};

/**
 * 重置
 */
const handleReset = () => {
  searchForm.dateRange = null;
  searchForm.operator = null;
  searchForm.operatorRole = null;
  searchForm.operationType = null;
  searchForm.operationContent = null;
  searchForm.orgName = null;
  searchForm.operationObject = null;
  handleSearch();
};

/**
 * 查看详情
 */
const handleViewDetail = (record: OperationLogItem) => {
  console.log('查看详情:', record);
  // TODO: 实现查看详情逻辑
};
</script>

<style scoped>
.operation-log {
  padding: 0;
}

/* 顶部标签页 */
.tabs-header {
  background: #fff;
  padding: 0 24px;
  border-bottom: 1px solid #f0f0f0;
}

.tab-list {
  display: flex;
  gap: 32px;
}

.tab-item {
  padding: 16px 0;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  position: relative;
  transition: color 0.3s;
}

.tab-item:hover {
  color: #1890ff;
}

.tab-item-active {
  color: #1890ff;
  font-weight: 500;
}

.tab-item-active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: #1890ff;
}

/* 搜索区域 */
.search-area {
  background: #fff;
  padding: 24px 24px 0;
  border-bottom: 1px solid #f0f0f0;
}

/* 表格区域 */
.table-area {
  background: #fff;
  padding: 16px 24px;
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

.total-count {
  font-size: 14px;
  color: #333;
}

/* 操作链接 */
.action-link {
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
}

.action-link:hover {
  color: #40a9ff;
}

/* 表格样式覆盖 */
.table-area :deep(.ant-table-thead > tr > th) {
  background: #e6f4ff;
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
</style>
