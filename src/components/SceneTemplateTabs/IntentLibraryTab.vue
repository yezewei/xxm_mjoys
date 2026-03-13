<template>
  <div class="intent-content">
    <div class="intent-wrapper">
      <!-- 右侧内容区 -->
      <div class="intent-main-content">
        <!-- 顶部操作栏 -->
        <div class="intent-toolbar">
          <div class="toolbar-left">
            <a-space>
              <a-select
                v-model:value="intentMenuFilter"
                placeholder="意图来源"
                style="width: 150px"
                allow-clear
                @change="handleIntentMenuFilterChange"
              >
                <a-select-option value="all">全部</a-select-option>
                <a-select-option value="scene">当前场景意图</a-select-option>
                <a-select-option value="industry">内置行业意图</a-select-option>
                <a-select-option value="common">内置通用意图</a-select-option>
              </a-select>
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
                style="width: 150px"
                allow-clear
              >
                <a-select-option value="肯定">肯定</a-select-option>
                <a-select-option value="否定">否定</a-select-option>
                <a-select-option value="中性">中性</a-select-option>
                <a-select-option value="重复">重复</a-select-option>
              </a-select>
              <a-button type="primary" @click="handleIntentSearch">
                <search-outlined />
                搜索
              </a-button>
              <a-button @click="handleIntentReset">
                <reload-outlined />
                重置
              </a-button>
            </a-space>
          </div>
          <div class="toolbar-right">
            <a-space>
              <a-button type="primary" @click="handleCreateIntent">
                <plus-outlined />
                新建意图
              </a-button>
              <a-button @click="handleReferenceIntent">
                <link-outlined />
                引用意图
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
                  <a class="action-link" @click="handleAddUserQuestion(record)">添加用户问法</a>
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

    <!-- 新建意图弹窗 -->
    <a-modal
      v-model:open="createIntentModalVisible"
      title="新建意图"
      width="600px"
      :footer="null"
      @cancel="handleCreateIntentCancel"
    >
      <a-form
        ref="createIntentFormRef"
        :model="createIntentForm"
        :rules="{
          intentName: [{ required: true, message: '请输入意图名称', trigger: 'blur' }],
          intentType: [{ required: true, message: '请选择意图类型', trigger: 'change' }],
          priority: [{ required: true, message: '请输入优先级', trigger: 'blur' }],
        }"
        layout="vertical"
      >
        <a-form-item label="意图名称" name="intentName">
          <a-input v-model:value="createIntentForm.intentName" placeholder="请输入意图名称" />
        </a-form-item>
        <a-form-item label="意图类型" name="intentType">
          <a-select v-model:value="createIntentForm.intentType" placeholder="请选择意图类型">
            <a-select-option value="肯定">肯定</a-select-option>
            <a-select-option value="否定">否定</a-select-option>
            <a-select-option value="中性">中性</a-select-option>
            <a-select-option value="重复">重复</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="优先级" name="priority">
          <a-input-number v-model:value="createIntentForm.priority" :min="1" :max="10" style="width: 100%" />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleCreateIntentCancel">取消</a-button>
        <a-button type="primary" @click="handleCreateIntentSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 编辑意图弹窗 -->
    <a-modal
      v-model:open="editIntentModalVisible"
      title="编辑意图"
      width="600px"
      :footer="null"
      @cancel="handleEditIntentCancel"
    >
      <a-form
        ref="editIntentFormRef"
        :model="editIntentForm"
        :rules="{
          intentName: [{ required: true, message: '请输入意图名称', trigger: 'blur' }],
          intentType: [{ required: true, message: '请选择意图类型', trigger: 'change' }],
          priority: [{ required: true, message: '请输入优先级', trigger: 'blur' }],
        }"
        layout="vertical"
      >
        <a-form-item label="意图名称" name="intentName">
          <a-input v-model:value="editIntentForm.intentName" placeholder="请输入意图名称" />
        </a-form-item>
        <a-form-item label="意图类型" name="intentType">
          <a-select v-model:value="editIntentForm.intentType" placeholder="请选择意图类型">
            <a-select-option value="肯定">肯定</a-select-option>
            <a-select-option value="否定">否定</a-select-option>
            <a-select-option value="中性">中性</a-select-option>
            <a-select-option value="重复">重复</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="优先级" name="priority">
          <a-input-number v-model:value="editIntentForm.priority" :min="1" :max="10" style="width: 100%" />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleEditIntentCancel">取消</a-button>
        <a-button type="primary" @click="handleEditIntentSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 引用意图弹窗 -->
    <a-modal
      v-model:open="referenceIntentModalVisible"
      title="引用内置意图"
      width="1000px"
      :footer="null"
      @cancel="handleReferenceIntentCancel"
    >
      <div class="reference-intent-content">
        <!-- TAB 切换 -->
        <a-tabs v-model:activeKey="referenceIntentActiveTab">
          <a-tab-pane key="common" tab="通用意图" />
          <a-tab-pane key="industry" tab="行业意图" />
          <a-tab-pane key="all" tab="所有场景意图" />
        </a-tabs>

        <!-- 顶部操作区 -->
        <div class="reference-toolbar">
          <div class="toolbar-left">
            <a-space>
              <a-input
                v-model:value="referenceSearchKeyword"
                placeholder="请输入名称"
                style="width: 200px"
                @press-enter="handleReferenceSearch"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-button type="primary" @click="handleReferenceSearch">
                <search-outlined />
                搜索
              </a-button>
              <a-button @click="handleReferenceSearchReset">
                <reload-outlined />
                重置
              </a-button>
            </a-space>
          </div>
        </div>

        <!-- 已选信息 -->
        <div class="reference-selected-info">
          <span class="selected-count">共{{ referenceIntentList.length }}条，已选 {{ selectedReferenceRowKeys.length }}条</span>
        </div>

        <!-- 数据表格 -->
        <div class="reference-table-wrapper">
          <a-table
            :columns="referenceColumns"
            :data-source="referenceIntentList"
            :pagination="false"
            row-key="id"
            size="middle"
            :row-selection="{
              selectedRowKeys: selectedReferenceRowKeys,
              onChange: onReferenceSelectionChange,
            }"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'patternCount'">
                <span class="pattern-count">{{ record.patternCount }}</span>
              </template>
              <template v-if="column.key === 'remark'">
                <span class="remark-text">{{ record.remark || '-' }}</span>
              </template>
            </template>
          </a-table>
        </div>

        <!-- 分页 -->
        <div class="reference-pagination">
          <a-pagination
            v-model:current="referenceCurrent"
            v-model:page-size="referencePageSize"
            :total="referenceTotal"
            show-size-changer
            show-quick-jumper
            :show-total="(total: number) => `共 ${total} 条`"
            :page-size-options="['10', '20', '50']"
            :locale="{
              items_per_page: '条/页',
              jump_to: '跳转至',
              page: '页',
            }"
            @change="handleReferencePageChange"
            @show-size-change="handleReferencePageSizeChange"
          />
        </div>
      </div>
      <div class="modal-footer">
        <a-button @click="handleReferenceIntentCancel">取消</a-button>
        <a-button type="primary" @click="handleReferenceIntentImport">确定</a-button>
      </div>
    </a-modal>

    <!-- 添加用户问法弹窗 -->
    <a-modal
      v-model:open="addUserQuestionModalVisible"
      title="添加用户问法"
      width="1000px"
      :footer="null"
      @cancel="handleAddUserQuestionCancel"
    >
      <div class="add-user-question-content">
        <a-tabs v-model:activeKey="userQuestionActiveTab">
          <a-tab-pane key="pattern" tab="pattern 语料" />
          <a-tab-pane key="semantic" tab="语义槽" />
        </a-tabs>

        <!-- 语料库内容 -->
        <div v-if="userQuestionActiveTab === 'pattern'" class="pattern-content">
          <div class="pattern-toolbar">
            <div class="toolbar-left">
              <a-input
                v-model:value="patternSearchKeyword"
                placeholder="关键词查询"
                class="search-input-large"
                allow-clear
                @press-enter="handlePatternSearch"
              >
                <template #suffix>
                  <search-outlined style="cursor: pointer" />
                </template>
              </a-input>
              <a-button type="primary" @click="handlePatternSearch">
                <search-outlined />
                搜索
              </a-button>
            </div>
            <div class="toolbar-right">
              <a-space>
                <a-button @click="handleOpenAddPatternModal">
                  <plus-outlined />
                  新增语料
                </a-button>
                <a-button danger @click="handleBatchDeletePattern">
                  批量删除
                </a-button>
                <a-button @click="handleSemanticTest">
                  语义测试
                </a-button>
              </a-space>
            </div>
          </div>
          <div class="pattern-table-wrapper">
            <a-table
              :columns="patternColumns"
              :data-source="patternList"
              :pagination="patternPagination"
              row-key="id"
              size="middle"
              :row-selection="{
                selectedRowKeys: selectedPatternRowKeys,
                onChange: onPatternSelectChange,
              }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'patternText'">
                  <div v-if="editingPatternId === record.id" class="pattern-edit-wrapper">
                    <a-input
                      v-model:value="record.patternText"
                      style="width: 100%"
                      @press-enter="handleSavePatternEdit(record)"
                      @blur="handleSavePatternEdit(record)"
                    />
                  </div>
                  <span v-else :class="['pattern-text', { 'pattern-text-highlight': record.id === patternList[0]?.id }]">{{ record.patternText }}</span>
                </template>
                <template v-if="column.key === 'action'">
                  <a class="delete-icon-btn" @click="handleDeletePattern(record)">
                    <delete-outlined />
                  </a>
                </template>
              </template>
            </a-table>
          </div>
        </div>

        <!-- 语义槽内容 -->
        <div v-else-if="userQuestionActiveTab === 'semantic'" class="semantic-content">
          <div class="semantic-table-wrapper">
            <a-table
              :columns="semanticColumns"
              :data-source="semanticSlotList"
              :pagination="semanticPagination"
              row-key="id"
              size="middle"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'slotName'">
                  <span :class="['semantic-slot-name', `color-${record.color}`]">{{ record.slotName }}</span>
                </template>
                <template v-if="column.key === 'slotValue'">
                  <a-tag color="blue" class="binding-tag">{{ record.slotValue }}</a-tag>
                </template>
                <template v-if="column.key === 'action'">
                  <a class="delete-icon-btn" @click="handleDeleteSemanticSlot(record)">
                    <delete-outlined />
                  </a>
                </template>
              </template>
            </a-table>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <a-button @click="handleAddUserQuestionCancel">取消</a-button>
        <a-button type="primary" @click="handleSaveUserQuestion">保存</a-button>
      </div>
    </a-modal>

    <!-- 新增语料弹窗 -->
    <a-modal
      v-model:open="addPatternModalVisible"
      title="新增语料"
      width="600px"
      :footer="null"
      @cancel="handleAddPatternModalCancel"
    >
      <a-form
        ref="addPatternFormRef"
        :model="addPatternForm"
        :rules="{
          patternText: [{ required: true, message: '请输入语料内容', trigger: 'blur' }],
        }"
        layout="vertical"
      >
        <a-form-item label="语料内容" name="patternText">
          <a-textarea
            v-model:value="addPatternForm.patternText"
            :rows="6"
            placeholder="请输入语料，每行一条"
          />
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleAddPatternModalCancel">取消</a-button>
        <a-button type="primary" @click="handleAddPatternSubmit">保存</a-button>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { message } from 'ant-design-vue';
import {
  SearchOutlined,
  PlusOutlined,
  LinkOutlined,
  DeleteOutlined,
  ReloadOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnsType, TablePaginationConfig } from 'ant-design-vue';
import type { FormInstance } from 'ant-design-vue';

// ==================== 接口定义 ====================
interface IntentItem {
  id: number;
  intentName: string;
  intentType: string;
  priority: number;
  updateTime: string;
}

interface ReferenceIntentItem {
  id: number;
  intentName: string;
  status: string;
  patternCount: number;
  remark?: string;
}

interface PatternItem {
  id: number;
  patternText: string;
}

interface SemanticSlotItem {
  id: number;
  slotName: string;
  slotValue: string;
  color: string;
}

// ==================== Props 和 Emits ====================
const emit = defineEmits<{
  (e: 'select-menu', key: string): void;
  (e: 'search', keyword: string, type: string): void;
  (e: 'reset'): void;
  (e: 'add-user-question', intent: IntentItem): void;
  (e: 'edit-intent', intent: IntentItem): void;
  (e: 'delete-intent', intent: IntentItem): void;
}>();

// ==================== 响应式数据 ====================
// 意图来源筛选
const intentMenuFilter = ref('all');

// 搜索相关
const intentSearchKeyword = ref('');
const intentTypeFilter = ref('');

// 分页相关
const intentPagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 5,
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

// ==================== 新建/编辑意图弹窗相关 ====================
// 新建意图弹窗
const createIntentModalVisible = ref(false);
const createIntentFormRef = ref<FormInstance>();
const createIntentForm = reactive({
  intentName: '',
  intentType: '',
  priority: 1,
});

// 编辑意图弹窗
const editIntentModalVisible = ref(false);
const editIntentFormRef = ref<FormInstance>();
const editIntentForm = reactive({
  id: 0,
  intentName: '',
  intentType: '',
  priority: 1,
});
const currentEditIntent = ref<IntentItem | null>(null);

// ==================== 引用意图弹窗相关 ====================
const referenceIntentModalVisible = ref(false);
const referenceIntentActiveTab = ref('common');
const referenceSearchKeyword = ref('');
const referenceStatusFilter = ref('');
const selectedReferenceRowKeys = ref<number[]>([]);
const referenceCurrent = ref(1);
const referencePageSize = ref(10);
const referenceTotal = ref(6);

// 引用意图列表数据（模拟数据）
const referenceIntentList = ref<ReferenceIntentItem[]>([
  { id: 118334, intentName: 'sys.否定', status: '启用', patternCount: 433 },
  { id: 118336, intentName: 'sys.肯定', status: '启用', patternCount: 318 },
  { id: 118339, intentName: 'sys.中性 - 继续', status: '启用', patternCount: 132 },
  { id: 118340, intentName: 'sys.重复', status: '启用', patternCount: 68 },
  { id: 118711, intentName: 'sys.不太了解', status: '停用', patternCount: 38, remark: '调整为通用 QA：com.不太了解' },
  { id: 166284, intentName: 'sys.确认', status: '停用', patternCount: 1, remark: '测试的' },
]);

// 引用意图表格列配置
const referenceColumns: TableColumnsType = [
  {
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    width: 100,
  },
  {
    title: '意图名称',
    dataIndex: 'intentName',
    key: 'intentName',
    width: 300,
  },
  {
    title: 'pattern 数量',
    dataIndex: 'patternCount',
    key: 'patternCount',
    width: 120,
  },
  {
    title: '备注',
    dataIndex: 'remark',
    key: 'remark',
    width: 350,
  },
];

// ==================== 添加用户问法相关 ====================
const addUserQuestionModalVisible = ref(false);
const currentAddUserQuestionIntent = ref<IntentItem | null>(null);
const userQuestionActiveTab = ref('pattern');
const patternSearchKeyword = ref('');
const selectedPatternRowKeys = ref<number[]>([]);
const patternList = ref<PatternItem[]>([]);
const semanticSlotList = ref<SemanticSlotItem[]>([]);
const addPatternModalVisible = ref(false);
const addPatternFormRef = ref<FormInstance>();
const addPatternForm = reactive({ patternText: '' });
const editingPatternId = ref<number | null>(null);

// Pattern 语料表格列配置
const patternColumns: TableColumnsType = [
  {
    title: 'pattern 语料',
    dataIndex: 'patternText',
    key: 'patternText',
    width: 700,
  },
  {
    title: '操作',
    key: 'action',
    width: 80,
    align: 'center',
  },
];

// 语义槽表格列配置
const semanticColumns: TableColumnsType = [
  {
    title: '语义槽',
    dataIndex: 'slotName',
    key: 'slotName',
    width: 300,
  },
  {
    title: '绑定词库',
    dataIndex: 'slotValue',
    key: 'slotValue',
    width: 450,
  },
  {
    title: '操作',
    key: 'action',
    width: 80,
    align: 'center',
  },
];

// Pattern 分页配置
const patternPagination = ref<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 0,
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

// 语义槽分页配置
const semanticPagination = ref<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 0,
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

// ==================== 方法 ====================
// 意图来源筛选变化
const handleIntentMenuFilterChange = () => {
  console.log('意图来源筛选变化:', intentMenuFilter.value);
  emit('select-menu', intentMenuFilter.value);
};

// 意图搜索
const handleIntentSearch = () => {
  emit('search', intentSearchKeyword.value, intentTypeFilter.value);
};

// 意图重置
const handleIntentReset = () => {
  intentSearchKeyword.value = '';
  intentTypeFilter.value = '';
  intentMenuFilter.value = 'all';
  emit('reset');
};

// 新建意图
const handleCreateIntent = () => {
  createIntentForm.intentName = '';
  createIntentForm.intentType = '';
  createIntentForm.priority = 1;
  createIntentModalVisible.value = true;
};

// 取消新建意图
const handleCreateIntentCancel = () => {
  createIntentModalVisible.value = false;
  createIntentFormRef.value?.resetFields();
};

// 提交新建意图
const handleCreateIntentSubmit = async () => {
  try {
    await createIntentFormRef.value?.validate();
    const newIntent: IntentItem = {
      id: Date.now(),
      intentName: createIntentForm.intentName,
      intentType: createIntentForm.intentType,
      priority: createIntentForm.priority,
      updateTime: new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      }).replace(/\//g, '-'),
    };
    intentList.value.push(newIntent);
    message.success('新建意图成功');
    createIntentModalVisible.value = false;
    createIntentFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 编辑意图
const handleEditIntent = (intent: IntentItem) => {
  currentEditIntent.value = intent;
  editIntentForm.id = intent.id;
  editIntentForm.intentName = intent.intentName;
  editIntentForm.intentType = intent.intentType;
  editIntentForm.priority = intent.priority;
  editIntentModalVisible.value = true;
};

// 取消编辑意图
const handleEditIntentCancel = () => {
  editIntentModalVisible.value = false;
  editIntentFormRef.value?.resetFields();
  currentEditIntent.value = null;
};

// 提交编辑意图
const handleEditIntentSubmit = async () => {
  try {
    await editIntentFormRef.value?.validate();
    if (currentEditIntent.value) {
      currentEditIntent.value.intentName = editIntentForm.intentName;
      currentEditIntent.value.intentType = editIntentForm.intentType;
      currentEditIntent.value.priority = editIntentForm.priority;
      currentEditIntent.value.updateTime = new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      }).replace(/\//g, '-');
    }
    message.success('保存意图成功');
    editIntentModalVisible.value = false;
    editIntentFormRef.value?.resetFields();
    currentEditIntent.value = null;
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 删除意图
const handleDeleteIntent = (intent: IntentItem) => {
  const index = intentList.value.findIndex(item => item.id === intent.id);
  if (index !== -1) {
    intentList.value.splice(index, 1);
    message.success('删除意图成功');
  }
};

// 引用意图
const handleReferenceIntent = () => {
  referenceIntentModalVisible.value = true;
  selectedReferenceRowKeys.value = [];
  referenceIntentActiveTab.value = 'common';
  referenceSearchKeyword.value = '';
  referenceStatusFilter.value = '';
};

// 取消引用意图
const handleReferenceIntentCancel = () => {
  referenceIntentModalVisible.value = false;
  selectedReferenceRowKeys.value = [];
};

// 引用意图搜索
const handleReferenceSearch = () => {
  console.log('搜索引用意图:', referenceSearchKeyword.value);
  message.info(`搜索：${referenceSearchKeyword.value || '全部'}`);
};

// 引用意图重置
const handleReferenceSearchReset = () => {
  referenceSearchKeyword.value = '';
  message.success('已重置搜索条件');
};

// 引用意图选择变化
const onReferenceSelectionChange = (selectedRowKeys: (string | number)[]) => {
  selectedReferenceRowKeys.value = selectedRowKeys as number[];
};

// 引用意图分页变化
const handleReferencePageChange = (page: number) => {
  referenceCurrent.value = page;
};

// 引用意图每页条数变化
const handleReferencePageSizeChange = (_current: number, size: number) => {
  referencePageSize.value = size;
  referenceCurrent.value = 1;
};

// 引用意图导入
const handleReferenceIntentImport = () => {
  if (selectedReferenceRowKeys.value.length === 0) {
    message.warning('请至少选择一个意图');
    return;
  }
  console.log('导入选中的意图:', selectedReferenceRowKeys.value);
  message.success(`已导入 ${selectedReferenceRowKeys.value.length} 条意图`);
  referenceIntentModalVisible.value = false;
  selectedReferenceRowKeys.value = [];
};

// 意图表格变化
const handleIntentTableChange = (pagination: TablePaginationConfig) => {
  intentPagination.current = pagination.current;
  intentPagination.pageSize = pagination.pageSize;
  intentPagination.total = pagination.total;
  console.log('意图表格分页变化:', pagination);
};

// ==================== 添加用户问法相关 ====================
// 添加用户问法
const handleAddUserQuestion = (intent: IntentItem) => {
  currentAddUserQuestionIntent.value = intent;
  addUserQuestionModalVisible.value = true;
  // 重置数据
  userQuestionActiveTab.value = 'pattern';
  patternSearchKeyword.value = '';
  selectedPatternRowKeys.value = [];
  // 初始化语料数据
  patternList.value = [
    { id: 1, patternText: '你他妈.*打电话给我' },
    { id: 2, patternText: '你他妈.*打我电话' },
    { id: 3, patternText: '我现在.{0,1}电话录 [着] 音' },
    { id: 4, patternText: '不要给我 [有 | 推销] 任何 [的] 推销' },
    { id: 5, patternText: '我不 (接受 | 要) 任何 [的] 推销' },
    { id: 6, patternText: '对你们 [银行](很 | 好 | 非常)(失望 | 不满 | 不满意)' },
    { id: 7, patternText: '找 (消保 | 银监会 | 保监会 | 银保监会)' },
    { id: 8, patternText: '[在 | 去 | 要](一二三 | 幺二三|123).{0,4}(查 | 看 | 查看 | 查询)[一] 下' },
  ];
  // 初始化语义槽数据
  semanticSlotList.value = [
    { id: 1, slotName: '你', slotValue: '@com.你', color: 'green' },
    { id: 2, slotName: '什么', slotValue: '@com.什么', color: 'green' },
    { id: 3, slotName: '语气词', slotValue: '@com.语气词', color: 'pink' },
    { id: 4, slotName: '办理', slotValue: '@com.办理', color: 'purple' },
    { id: 5, slotName: '你', slotValue: '@com.你', color: 'blue' },
    { id: 6, slotName: '什么', slotValue: '@com.什么', color: 'orange' },
    { id: 7, slotName: '语气词', slotValue: '@com.语气词', color: 'cyan' },
    { id: 8, slotName: '办理', slotValue: '@com.办理', color: 'purple' },
  ];
  console.log('添加用户问法:', intent);
};

// 取消添加用户问法
const handleAddUserQuestionCancel = () => {
  addUserQuestionModalVisible.value = false;
  currentAddUserQuestionIntent.value = null;
  userQuestionActiveTab.value = 'pattern';
};

// 保存用户问法
const handleSaveUserQuestion = () => {
  console.log('保存用户问法');
  message.success('保存用户问法成功');
  addUserQuestionModalVisible.value = false;
};

// 打开新增语料弹窗
const handleOpenAddPatternModal = () => {
  addPatternForm.patternText = '';
  addPatternModalVisible.value = true;
};

// 取消新增语料
const handleAddPatternModalCancel = () => {
  addPatternModalVisible.value = false;
  addPatternFormRef.value?.resetFields();
};

// 提交新增语料
const handleAddPatternSubmit = async () => {
  try {
    await addPatternFormRef.value?.validate();
    const lines = addPatternForm.patternText.split('\n').filter(line => line.trim());
    if (lines.length === 0) {
      message.warning('请输入至少一条语料');
      return;
    }
    lines.forEach((line, index) => {
      patternList.value.push({
        id: Date.now() + index,
        patternText: line.trim(),
      });
    });
    message.success(`新增 ${lines.length} 条语料成功`);
    addPatternModalVisible.value = false;
    addPatternFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 批量删除语料
const handleBatchDeletePattern = () => {
  if (selectedPatternRowKeys.value.length === 0) {
    message.warning('请先选择要删除的语料');
    return;
  }
  patternList.value = patternList.value.filter(item => !selectedPatternRowKeys.value.includes(item.id));
  selectedPatternRowKeys.value = [];
  message.success('批量删除语料成功');
};

// 删除语料
const handleDeletePattern = (record: PatternItem) => {
  const index = patternList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    patternList.value.splice(index, 1);
    message.success('删除语料成功');
  }
};

// 语料搜索
const handlePatternSearch = () => {
  console.log('搜索语料:', patternSearchKeyword.value);
  message.info(`搜索：${patternSearchKeyword.value || '全部'}`);
};

// 语义测试
const handleSemanticTest = () => {
  message.info('开始语义测试...');
  console.log('语义测试');
};

// 语料选择变化
const onPatternSelectChange = (selectedRowKeys: (string | number)[]) => {
  selectedPatternRowKeys.value = selectedRowKeys as number[];
};

// 删除语义槽
const handleDeleteSemanticSlot = (record: SemanticSlotItem) => {
  const index = semanticSlotList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    semanticSlotList.value.splice(index, 1);
    message.success('删除语义槽成功');
  }
};

// 编辑语料
const handleSavePatternEdit = (record: PatternItem) => {
  editingPatternId.value = null;
  console.log('保存语料编辑:', record);
  message.success('保存语料成功');
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
  overflow: hidden;
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

/* 弹窗底部按钮 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

/* 引用意图内容 */
.reference-intent-content {
  display: flex;
  flex-direction: column;
}

.reference-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.reference-selected-info {
  display: flex;
  justify-content: flex-end;
  padding: 8px 0 4px;
}

.selected-count {
  font-size: 14px;
  color: #595959;
}

.reference-table-wrapper {
  max-height: 400px;
  overflow-y: auto;
}

.reference-pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

/* pattern 数量 */
.pattern-count {
  color: #1890ff;
}

/* 备注文本 */
.remark-text {
  color: #8c8c8c;
  font-size: 13px;
}

/* 添加用户问法内容 */
.add-user-question-content {
  display: flex;
  flex-direction: column;
}

.pattern-content,
.semantic-content {
  display: flex;
  flex-direction: column;
}

.pattern-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.toolbar-left,
.toolbar-right {
  display: flex;
  align-items: center;
}

.toolbar-left .search-input-large {
  width: 280px;
  margin-right: 12px;
}

.pattern-table-wrapper,
.semantic-table-wrapper {
  max-height: 500px;
  overflow-y: auto;
}

.pattern-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
}

.pattern-text-highlight {
  color: #1890ff;
}

.pattern-edit-wrapper {
  width: 100%;
}

/* 删除图标按钮 */
.delete-icon-btn {
  color: #ff4d4f;
  font-size: 16px;
  cursor: pointer;
  transition: color 0.3s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.delete-icon-btn:hover {
  color: #ff7875;
}

/* 语义槽名称样式 */
.semantic-slot-name {
  font-size: 14px;
  position: relative;
  display: inline-block;
  padding-bottom: 2px;
}

.semantic-slot-name.color-green {
  border-bottom: 2px solid #52c41a;
}

.semantic-slot-name.color-pink {
  border-bottom: 2px solid #eb2f96;
}

.semantic-slot-name.color-purple {
  border-bottom: 2px solid #722ed1;
}

.semantic-slot-name.color-blue {
  border-bottom: 2px solid #1890ff;
}

.semantic-slot-name.color-orange {
  border-bottom: 2px solid #fa8c16;
}

.semantic-slot-name.color-cyan {
  border-bottom: 2px solid #13c2c2;
}

.binding-tag {
  font-family: monospace;
}
</style>
