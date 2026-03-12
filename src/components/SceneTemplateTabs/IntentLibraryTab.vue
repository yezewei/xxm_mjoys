<template>
  <div class="intent-content">
    <div class="intent-wrapper">
      <!-- 左侧菜单 -->
      <div class="intent-sidebar">
        <div
          v-for="menu in intentMenus"
          :key="menu.key"
          :class="['menu-item', { active: selectedIntentMenu === menu.key }]"
          @click="handleSelectIntentMenu(menu.key)"
        >
          {{ menu.name }}
        </div>
      </div>

      <!-- 右侧内容区 -->
      <div class="intent-main-content">
        <!-- 顶部操作栏 -->
        <div class="intent-toolbar">
          <div class="toolbar-left">
            <a-space>
              <a-input
                v-model:value="intentSearchKeyword"
                placeholder="请输入意图名称"
                style="width: 240px"
                @press-enter="handleIntentSearch"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-select
                v-model:value="intentTypeFilter"
                placeholder="请选择意图类型"
                style="width: 200px"
              >
                <a-select-option value="肯定">肯定</a-select-option>
                <a-select-option value="否定">否定</a-select-option>
                <a-select-option value="中性">中性</a-select-option>
                <a-select-option value="重复">重复</a-select-option>
              </a-select>
              <a-button type="primary" @click="handleIntentSearch">搜索</a-button>
              <a-button @click="handleIntentReset">重置</a-button>
            </a-space>
          </div>
          <div class="toolbar-right">
            <a-space>
              <a-button type="primary" ghost @click="handleCreateIntent">
                新建场景意图
              </a-button>
              <a-button type="primary" ghost @click="handleReferenceIntent">
                引用通用/行业意图
              </a-button>
            </a-space>
          </div>
        </div>

        <!-- 数据表格 -->
        <div class="intent-table-wrapper">
          <a-table
            :columns="intentColumns"
            :data-source="intentList"
            :pagination="intentPagination"
            row-key="id"
            size="middle"
            @change="handleIntentTableChange"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'action'">
                <a-space>
                  <a class="action-link" @click="handleCorpusManage(record)">语料管理</a>
                  <a class="action-link" @click="handleEditIntent(record)">编辑</a>
                  <a-popconfirm
                    title="确定删除该意图？"
                    ok-text="确定"
                    cancel-text="取消"
                    @confirm="handleDeleteIntent(record)"
                  >
                    <a class="action-link delete-link">删除</a>
                  </a-popconfirm>
                </a-space>
              </template>
            </template>
          </a-table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { SearchOutlined } from '@ant-design/icons-vue';
import type { TableColumnsType, TablePaginationConfig } from 'ant-design-vue';

// ==================== 接口定义 ====================
interface IntentItem {
  id: number;
  intentName: string;
  intentType: string;
  priority: number;
  updateTime: string;
}

interface IntentMenu {
  key: string;
  name: string;
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: string;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void;
  (e: 'select-menu', key: string): void;
  (e: 'search', keyword: string, type: string): void;
  (e: 'reset'): void;
  (e: 'create-intent'): void;
  (e: 'reference-intent'): void;
  (e: 'corpus-manage', intent: IntentItem): void;
  (e: 'edit-intent', intent: IntentItem): void;
  (e: 'delete-intent', intent: IntentItem): void;
}>();

// ==================== 响应式数据 ====================
// 左侧菜单配置
const intentMenus: IntentMenu[] = [
  { key: 'all', name: '全部' },
  { key: 'scene', name: '当前场景意图' },
  { key: 'industry', name: '内置行业意图' },
  { key: 'common', name: '内置通用意图' },
];

// 当前选中的菜单
const selectedIntentMenu = ref('all');

// 搜索相关
const intentSearchKeyword = ref('');
const intentTypeFilter = ref('');

// 分页相关
const intentPagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 7,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
  pageSizeOptions: ['10', '20', '50'],
  locale: {
    items_per_page: '条/页',
    jump_to: '跳转至',
    page: '页',
  },
});

// 意图列表数据（模拟数据）
const intentList = ref<IntentItem[]>([
  { id: 1, intentName: 'sys.重复', intentType: '重复', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 2, intentName: 'sys.肯定', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 3, intentName: 'sys.确认', intentType: '肯定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 4, intentName: 'sys.否定', intentType: '否定', priority: 1, updateTime: '2025-12-15 16:52:11' },
  { id: 5, intentName: 'sys.中性 - 继续', intentType: '中性', priority: 1, updateTime: '2025-12-15 16:52:11' },
]);

// 意图表格列配置
const intentColumns: TableColumnsType = [
  {
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    width: 80,
  },
  {
    title: '意图名称',
    dataIndex: 'intentName',
    key: 'intentName',
    width: 200,
  },
  {
    title: '意图类型',
    dataIndex: 'intentType',
    key: 'intentType',
    width: 120,
  },
  {
    title: '优先级',
    dataIndex: 'priority',
    key: 'priority',
    width: 100,
  },
  {
    title: '修改时间',
    dataIndex: 'updateTime',
    key: 'updateTime',
    width: 180,
  },
  {
    title: '操作',
    key: 'action',
    width: 200,
    fixed: 'right' as const,
  },
];

// ==================== 方法 ====================
// 选择意图菜单
const handleSelectIntentMenu = (key: string) => {
  selectedIntentMenu.value = key;
  emit('select-menu', key);
};

// 意图搜索
const handleIntentSearch = () => {
  emit('search', intentSearchKeyword.value, intentTypeFilter.value);
};

// 意图重置
const handleIntentReset = () => {
  intentSearchKeyword.value = '';
  intentTypeFilter.value = '';
  selectedIntentMenu.value = 'all';
  emit('reset');
};

// 新建意图
const handleCreateIntent = () => {
  emit('create-intent');
};

// 引用意图
const handleReferenceIntent = () => {
  emit('reference-intent');
};

// 语料管理
const handleCorpusManage = (intent: IntentItem) => {
  emit('corpus-manage', intent);
};

// 编辑意图
const handleEditIntent = (intent: IntentItem) => {
  emit('edit-intent', intent);
};

// 删除意图
const handleDeleteIntent = (intent: IntentItem) => {
  emit('delete-intent', intent);
};

// 意图表格变化
const handleIntentTableChange = (pagination: TablePaginationConfig) => {
  intentPagination.current = pagination.current;
  intentPagination.pageSize = pagination.pageSize;
  intentPagination.total = pagination.total;
  console.log('意图表格分页变化:', pagination);
  // TODO: 实现数据加载逻辑
};
</script>

<style scoped>
/* 意图库内容区域 */
.intent-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.intent-wrapper {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow: hidden;
}

/* 左侧菜单 */
.intent-sidebar {
  width: 180px;
  background: #fff;
  border-radius: 4px;
  padding: 12px 0;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.intent-sidebar .menu-item {
  padding: 12px 24px;
  font-size: 14px;
  color: #595959;
  cursor: pointer;
  transition: all 0.3s;
  border-left: 3px solid transparent;
}

.intent-sidebar .menu-item:hover {
  background: #f5f5f5;
}

.intent-sidebar .menu-item.active {
  background: #e6f7ff;
  color: #1890ff;
  border-left-color: #1890ff;
  font-weight: 500;
}

/* 右侧内容区 */
.intent-main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 顶部操作栏 */
.intent-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.toolbar-left,
.toolbar-right {
  display: flex;
  align-items: center;
}

/* 表格区域 */
.intent-table-wrapper {
  padding: 16px 20px;
}

.intent-table-wrapper :deep(.ant-table) {
  font-size: 13px;
}

.intent-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
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

.delete-link {
  color: #ff4d4f;
}

.delete-link:hover {
  color: #ff7875;
}
</style>
