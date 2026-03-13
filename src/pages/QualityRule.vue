<template>
  <div class="quality-rule">
    <!-- 顶部提示框 -->
    <div class="alert-section">
      <a-alert
        message="质检员在【AI 质检的人工审核】或【人工质检】时，手动为对话选择触发哪些质检规则"
        type="warning"
        show-icon
        class="quality-alert"
      />
    </div>

    <!-- 表格区域 -->
    <div class="table-area">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <div class="search-item">
          <a-input
            v-model:value="searchForm.keyword"
            placeholder="请输入编号/名称/说明"
            allow-clear
            style="width: 300px"
            @press-enter="handleSearch"
          >
            <template #prefix>
              <search-outlined />
            </template>
          </a-input>
        </div>
        <div class="search-item">
          <a-select
            v-model:value="searchForm.qualityModel"
            placeholder="请选择质检模型"
            allow-clear
            show-search
            :filter-option="false"
            :options="filteredModelOptions"
            option-filter-prop="label"
            style="width: 200px"
            @search="handleModelSearch"
          />
        </div>
        <div class="search-item search-buttons">
          <a-button type="primary" @click="handleSearch">
            搜索
          </a-button>
          <a-button @click="handleReset">
            重置
          </a-button>
        </div>
      </div>

      <!-- 表格上方工具栏 -->
      <div class="table-toolbar">
        <div class="table-toolbar-left">
          <span class="selection-info">共 {{ filteredTotal }} 条，已选 {{ selectedRowKeys.length }} 条</span>
          <a-button
            v-show="selectedRowKeys.length > 0"
            type="primary"
            danger
            size="small"
            @click="handleBatchDelete"
            style="margin-left: 12px"
          >
            <delete-outlined />
            批量删除 ({{ selectedRowKeys.length }})
          </a-button>
        </div>
        <div class="table-toolbar-right">
          <a-button type="primary" @click="handleAddRule">
            <plus-outlined />
            添加质检规则
          </a-button>
        </div>
      </div>

      <!-- 数据表格 -->
      <a-table
        :columns="visibleColumns"
        :data-source="filteredData"
        :pagination="pagination"
        row-key="id"
        :loading="loading"
        :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
        :scroll="{ x: 1200 }"
        :locale="{
          pagination: {
            items_per_page: '条/页',
            jump_to: '跳至',
            page: '页',
            total: (total: number) => `共 ${total} 条`,
          },
        }"
        :show-size-changer="true"
        @change="handleTableChange"
      >
        <!-- 质检规则编号列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'ruleCode'">
            <span class="rule-code">{{ record.ruleCode }}</span>
          </template>
          <!-- 质检模型列 -->
          <template v-else-if="column.key === 'qualityModel'">
            <span>{{ getQualityModelName(record.qualityModelId) }}</span>
          </template>
          <!-- 标签列 -->
          <template v-else-if="column.key === 'tags'">
            <div class="tags-container">
              <a-tag
                v-for="(tag, index) in record.tagsArray"
                :key="index"
                closable
                @close="handleRemoveTag(record, index)"
              >
                {{ tag }}
              </a-tag>
            </div>
          </template>
          <!-- 操作列 -->
          <template v-else-if="column.key === 'action'">
            <a-space>
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

    <!-- 添加/编辑质检规则弹窗 -->
    <a-modal
      v-model:open="ruleModalVisible"
      :title="isEditMode ? '编辑质检规则' : '添加质检规则'"
      width="600px"
      :confirm-loading="modalConfirmLoading"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleRuleModalOk"
    >
      <a-form
        ref="ruleFormRef"
        :model="ruleForm"
        :rules="formRules"
        layout="vertical"
      >
        <a-form-item label="质检规则编号" name="ruleCode">
          <a-input
            v-model:value="ruleForm.ruleCode"
            placeholder="请输入质检规则编号"
            :disabled="isEditMode"
          />
        </a-form-item>
        <a-form-item label="质检规则名称" name="ruleName">
          <a-input
            v-model:value="ruleForm.ruleName"
            placeholder="请输入质检规则名称"
          />
        </a-form-item>
        <a-form-item label="质检规则说明" name="ruleDescription">
          <a-textarea
            v-model:value="ruleForm.ruleDescription"
            placeholder="请输入质检规则说明"
            :rows="4"
          />
        </a-form-item>
        <a-form-item label="质检模型" name="qualityModelId">
          <a-select
            v-model:value="ruleForm.qualityModelId"
            placeholder="请选择质检模型"
            show-search
            :filter-option="false"
            :options="filteredModelOptions"
            option-filter-prop="label"
            @search="handleModelSearch"
          />
        </a-form-item>
        <a-form-item label="标签" name="tags">
          <a-select
            v-model:value="ruleForm.tagsArray"
            mode="tags"
            placeholder="输入标签后按回车保存"
            style="width: 100%"
          />
        </a-form-item>
        <a-form-item label="关键词规则" name="keywordRules">
          <a-textarea
            v-model:value="ruleForm.keywordRules"
            placeholder="请输入关键词规则，每行一个关键词"
            :rows="4"
          />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 批量删除确认对话框 -->
    <a-modal
      v-model:open="batchDeleteModalVisible"
      title="批量删除确认"
      ok-text="确定"
      cancel-text="取消"
      ok-type="danger"
      @ok="confirmBatchDelete"
    >
      <p>确定要删除选中的 <strong>{{ selectedRowKeys.length }}</strong> 条质检规则吗？</p>
      <p style="color: #ff4d4f;">删除后无法恢复，请谨慎操作！</p>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import {
  PlusOutlined,
  SearchOutlined,
  DeleteOutlined,
} from '@ant-design/icons-vue';
import type { Key } from 'ant-design-vue/es/table/interface';
import { message, Modal } from 'ant-design-vue';
import type { FormInstance } from 'ant-design-vue';

// ============ 类型定义 ============
interface QualityRuleItem {
  key: string;
  id: number;
  ruleCode: string;
  ruleName: string;
  ruleDescription: string;
  qualityModelId?: number;
  qualityModelName?: string;
  tags: string;
  tagsArray: string[];
  keywordRules?: string;
}

interface QualityModelOption {
  value: number;
  label: string;
}

// ============ 响应式数据 ============
const loading = ref(false);
const selectedRowKeys = ref<Key[]>([]);

// 搜索表单
const searchForm = reactive({
  keyword: '',
  qualityModel: undefined as number | undefined,
});

// 质检模型选项（用于下拉搜索）
const qualityModelOptions = ref<QualityModelOption[]>([
  { value: 1, label: '合规质检' },
  { value: 2, label: '营销意向' },
  { value: 3, label: '投诉倾向' },
  { value: 4, label: '合规质检（人工）' },
]);

// 过滤后的模型选项（用于搜索）
const filteredModelOptions = ref<QualityModelOption[]>([
  { value: 1, label: '合规质检' },
  { value: 2, label: '营销意向' },
  { value: 3, label: '投诉倾向' },
  { value: 4, label: '合规质检（人工）' },
]);

// 示例数据
const dataSource = ref<QualityRuleItem[]>([
  {
    key: '1',
    id: 1,
    ruleCode: 'A1',
    ruleName: '产品介绍错误',
    ruleDescription: '产品利率、产品收益、产品有效期等相关信息讲解错误。',
    qualityModelId: 1,
    qualityModelName: '合规质检',
    tags: '',
    tagsArray: [],
    keywordRules: '',
  },
  {
    key: '2',
    id: 2,
    ruleCode: 'A2',
    ruleName: '提醒不全',
    ruleDescription: '相关提醒不完整，遗漏、错误；',
    qualityModelId: 1,
    qualityModelName: '合规质检',
    tags: '',
    tagsArray: [],
    keywordRules: '',
  },
  {
    key: '3',
    id: 3,
    ruleCode: 'A3',
    ruleName: '未正面回答',
    ruleDescription: '客户咨询产品利率、收益、有效期等问题时未正面回答客户相关问题；',
    qualityModelId: 1,
    qualityModelName: '合规质检',
    tags: '',
    tagsArray: [],
    keywordRules: '',
  },
  {
    key: '4',
    id: 4,
    ruleCode: 'B1',
    ruleName: '未确认客户身份',
    ruleDescription: '未确认客户身份直接进行业务营销（客户表示为非本人，坐席仍进行营销）',
    qualityModelId: 4,
    qualityModelName: '合规质检（人工）',
    tags: '',
    tagsArray: [],
    keywordRules: '',
  },
  {
    key: '5',
    id: 5,
    ruleCode: 'B2',
    ruleName: '全部信息透露给客户',
    ruleDescription: '念出客户的全部身份证号码、电话号码、或资产情况等',
    qualityModelId: 4,
    qualityModelName: '合规质检（人工）',
    tags: '',
    tagsArray: [],
    keywordRules: '',
  },
]);

// 分页配置
const pagination = reactive({
  current: 1,
  total: 5,
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

// 表单相关
const ruleModalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);
const ruleFormRef = ref<FormInstance>();
const editingRuleId = ref<number | null>(null);

// 表单数据
const ruleForm = reactive({
  ruleCode: '',
  ruleName: '',
  ruleDescription: '',
  qualityModelId: undefined as number | undefined,
  tagsArray: [] as string[],
  keywordRules: '',
});

// 表单验证规则
const formRules = {
  ruleCode: [
    { required: true, message: '请输入质检规则编号', trigger: 'blur' },
  ],
  ruleName: [
    { required: true, message: '请输入质检规则名称', trigger: 'blur' },
  ],
  ruleDescription: [
    { required: true, message: '请输入质检规则说明', trigger: 'blur' },
  ],
  qualityModelId: [
    { required: true, message: '请选择质检模型', trigger: 'change' },
  ],
};

// 批量删除对话框
const batchDeleteModalVisible = ref(false);

// ============ 计算属性 ============
// 表格数据源（根据搜索条件过滤）
const filteredData = computed(() => {
  let result = dataSource.value;

  // 按关键词模糊搜索（编号/名称/说明）
  if (searchForm.keyword) {
    const keyword = searchForm.keyword.toLowerCase();
    result = result.filter(item =>
      item.ruleCode.toLowerCase().includes(keyword) ||
      item.ruleName.toLowerCase().includes(keyword) ||
      item.ruleDescription.toLowerCase().includes(keyword)
    );
  }

  // 按质检模型筛选
  if (searchForm.qualityModel) {
    result = result.filter(item => item.qualityModelId === searchForm.qualityModel);
  }

  return result;
});

// 过滤后的总数
const filteredTotal = computed(() => filteredData.value.length);

// 表格列配置
const visibleColumns = computed(() => [
  {
    title: '质检规则编号',
    dataIndex: 'ruleCode',
    key: 'ruleCode',
    width: 120,
  },
  {
    title: '质检规则名称',
    dataIndex: 'ruleName',
    key: 'ruleName',
    width: 150,
  },
  {
    title: '质检规则说明',
    dataIndex: 'ruleDescription',
    key: 'ruleDescription',
    width: 300,
    ellipsis: true,
  },
  {
    title: '质检模型',
    dataIndex: 'qualityModelName',
    key: 'qualityModel',
    width: 150,
  },
  {
    title: '关键词规则',
    dataIndex: 'keywordRules',
    key: 'keywordRules',
    width: 200,
    ellipsis: true,
  },
  {
    title: '标签',
    dataIndex: 'tags',
    key: 'tags',
    width: 150,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
]);

// ============ 生命周期 ============
onMounted(() => {});

// ============ 方法 ============

// 获取质检模型名称
const getQualityModelName = (modelId?: number): string => {
  if (!modelId) return '';
  const model = qualityModelOptions.value.find(m => m.value === modelId);
  return model ? model.label : '';
};

// 行选择变化
const onSelectChange = (keys: Key[]) => {
  selectedRowKeys.value = keys;
};

// 表格变化处理（分页等）
const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
};

// 搜索
const handleSearch = () => {
  pagination.current = 1;
  selectedRowKeys.value = [];
  message.success('搜索完成');
};

// 重置搜索
const handleReset = () => {
  searchForm.keyword = '';
  searchForm.qualityModel = undefined;
  pagination.current = 1;
  selectedRowKeys.value = [];
  message.success('已重置搜索条件');
};

// 质检模型搜索
const handleModelSearch = (value: string) => {
  if (!value) {
    filteredModelOptions.value = [...qualityModelOptions.value];
  } else {
    filteredModelOptions.value = qualityModelOptions.value.filter(item =>
      item.label.toLowerCase().includes(value.toLowerCase())
    );
  }
};

/**
 * 添加质检规则
 */
const handleAddRule = () => {
  isEditMode.value = false;
  editingRuleId.value = null;
  ruleForm.ruleCode = '';
  ruleForm.ruleName = '';
  ruleForm.ruleDescription = '';
  ruleForm.qualityModelId = undefined;
  ruleForm.tagsArray = [];
  ruleForm.keywordRules = '';
  ruleModalVisible.value = true;
};

/**
 * 编辑质检规则
 */
const handleEdit = (record: QualityRuleItem) => {
  isEditMode.value = true;
  editingRuleId.value = record.id;
  ruleForm.ruleCode = record.ruleCode;
  ruleForm.ruleName = record.ruleName;
  ruleForm.ruleDescription = record.ruleDescription;
  ruleForm.qualityModelId = record.qualityModelId;
  ruleForm.tagsArray = [...record.tagsArray];
  ruleForm.keywordRules = record.keywordRules || '';
  ruleModalVisible.value = true;
};

/**
 * 删除质检规则
 */
const handleDelete = (record: QualityRuleItem) => {
  Modal.confirm({
    title: '删除确认',
    content: `确定要删除质检规则 "${record.ruleName}" 吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      dataSource.value = dataSource.value.filter(item => item.id !== record.id);
      message.success(`已删除 "${record.ruleName}"`);
    },
  });
};

/**
 * 批量删除
 */
const handleBatchDelete = () => {
  batchDeleteModalVisible.value = true;
};

/**
 * 确认批量删除
 */
const confirmBatchDelete = () => {
  const deletedNames: string[] = [];
  dataSource.value = dataSource.value.filter(item => {
    if (selectedRowKeys.value.includes(item.id)) {
      deletedNames.push(item.ruleName);
      return false;
    }
    return true;
  });
  selectedRowKeys.value = [];
  batchDeleteModalVisible.value = false;
  message.success(`已删除 ${deletedNames.length} 条质检规则`);
};

/**
 * 移除标签
 */
const handleRemoveTag = (record: QualityRuleItem, index: number) => {
  record.tagsArray.splice(index, 1);
};

/**
 * 表单确认
 */
const handleRuleModalOk = async () => {
  try {
    await ruleFormRef.value?.validate();
    modalConfirmLoading.value = true;

    if (isEditMode.value && editingRuleId.value !== null) {
      // 编辑模式
      const index = dataSource.value.findIndex(item => item.id === editingRuleId.value);
      if (index !== -1) {
        dataSource.value[index] = {
          ...dataSource.value[index],
          ruleName: ruleForm.ruleName,
          ruleDescription: ruleForm.ruleDescription,
          qualityModelId: ruleForm.qualityModelId,
          qualityModelName: getQualityModelName(ruleForm.qualityModelId),
          tagsArray: [...ruleForm.tagsArray],
          tags: ruleForm.tagsArray.join(','),
          keywordRules: ruleForm.keywordRules,
        };
      }
      message.success('编辑成功');
    } else {
      // 新增模式
      const newId = Math.max(...dataSource.value.map(item => item.id), 0) + 1;
      const newRule: QualityRuleItem = {
        key: String(newId),
        id: newId,
        ruleCode: ruleForm.ruleCode,
        ruleName: ruleForm.ruleName,
        ruleDescription: ruleForm.ruleDescription,
        qualityModelId: ruleForm.qualityModelId,
        qualityModelName: getQualityModelName(ruleForm.qualityModelId),
        tagsArray: [...ruleForm.tagsArray],
        tags: ruleForm.tagsArray.join(','),
        keywordRules: ruleForm.keywordRules,
      };
      dataSource.value.push(newRule);
      message.success('添加成功');
    }

    ruleModalVisible.value = false;
  } catch (error) {
    console.error('表单验证失败:', error);
  } finally {
    modalConfirmLoading.value = false;
  }
};
</script>

<style scoped>
.quality-rule {
  padding: 0;
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* 顶部提示框区域 */
.alert-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.quality-alert {
  background: #fffbe6;
  border-color: #ffe58f;
}

.quality-alert :deep(.ant-alert-warning .ant-alert-message) {
  color: #d48806;
  font-size: 14px;
}

/* 表格区域 */
.table-area {
  background: #fff;
  padding: 16px;
  border-radius: 4px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* 搜索栏 */
.search-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 16px;
  padding: 16px 0;
}

.search-item {
  display: flex;
  align-items: center;
}

.search-buttons {
  gap: 8px;
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

/* 规则编号样式 */
.rule-code {
  font-weight: 600;
  color: #1890ff;
}

/* 操作列按钮样式 */
.table-area :deep(.ant-btn-link) {
  padding: 4px 8px;
  font-size: 14px;
  height: auto;
  line-height: 1;
}

.table-area :deep(.ant-btn-link:not([disabled]):hover) {
  color: #40a9ff;
}

.table-area :deep(.ant-btn-link.ant-btn-dangerous) {
  color: #ff4d4f;
}

.table-area :deep(.ant-btn-link.ant-btn-dangerous:hover) {
  color: #ff7875;
}

/* 固定列样式 */
.table-area :deep(.ant-table-cell-fix-right) {
  background: #fff;
  z-index: 2;
}

.table-area :deep(.ant-table-cell-fix-right-first) {
  box-shadow: -1px 0 0 0 #f0f0f0 inset;
}

.table-area :deep(.ant-table-scrolling .ant-table-cell-fix-right-first) {
  box-shadow: -1px 0 0 0 rgba(0, 0, 0, 0.1) inset;
}

/* 标签容器 */
.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.tags-container :deep(.ant-tag) {
  margin: 0;
}
</style>
