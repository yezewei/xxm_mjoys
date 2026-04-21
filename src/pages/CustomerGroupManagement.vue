<template>
  <div class="customer-group-management">
    <div class="quality-wrapper">
      <!-- 搜索区域和表格区域合并 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-form ref="searchFormRef" layout="vertical">
            <a-row :gutter="16" style="margin-bottom: -12px;">
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.groupName"
                    placeholder="请输入客群名称"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.groupType"
                    placeholder="请选择客群类型"
                    allow-clear
                  >
                    <a-select-option value="fixed">固定客群</a-select-option>
                    <a-select-option value="rule">规则客群</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.creator"
                    placeholder="请输入创建人"
                    allow-clear
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-range-picker
                    v-model:value="searchForm.createTimeRange"
                    style="width: 100%"
                    allow-clear
                    :placeholder="['创建开始时间', '创建结束时间']"
                    show-time
                    format="YYYY-MM-DD HH:mm:ss"
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="16" style="margin-top: -12px;">
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
            <span class="selection-info">共 {{ total }} 条</span>
          </div>
          <div class="table-toolbar-right">
            <a-button @click="handleCreateBatch">
              <file-add-outlined />
              创建任务批次
            </a-button>
            <a-button type="primary" @click="handleAdd" style="margin-left: 12px">
              <plus-outlined />
              新增客群
            </a-button>
          </div>
        </div>

        <!-- 数据表格 -->
        <a-table
          :columns="columns"
          :data-source="dataSource"
          :pagination="pagination"
          row-key="id"
          :loading="loading"
          :scroll="{ x: 1200 }"
          :show-size-changer="true"
          @change="handleTableChange"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'groupType'">
              <a-tag :color="record.groupType === 'fixed' ? 'blue' : 'green'">
                {{ record.groupType === 'fixed' ? '固定客群' : '规则客群' }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a-button type="link" size="small" @click="handleView(record)">查看</a-button>
                <a-button type="link" size="small" @click="handleEdit(record)">编辑</a-button>
                <a-button type="link" size="small" danger @click="handleDelete(record)">删除</a-button>
              </a-space>
            </template>
          </template>
        </a-table>
      </div>
    </div>

    <!-- 新增/编辑弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEditMode ? '编辑客群' : '新增客群'"
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
        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="客群名称" name="groupName">
              <a-input
                v-model:value="formData.groupName"
                placeholder="请输入客群名称"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="客群说明" name="groupDescription">
              <a-textarea
                v-model:value="formData.groupDescription"
                placeholder="请输入客群的描述信息"
                :rows="3"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <!-- 圈客条件配置区域 -->
        <a-divider orientation="left">圈客条件</a-divider>

        <a-form-item
          label="圈客条件"
          name="conditions"
          :rules="[{ required: true, message: '请至少添加一个圈客条件', trigger: 'change' }]"
        >
          <div class="expression-container">
            <!-- 表达式列表 -->
            <div v-for="(expression, exprIndex) in formData.conditions" :key="expression.id" class="expression-item">
              <!-- 表达式标题 -->
              <div class="expression-header">
                <span class="expression-title">表达式{{ Number(exprIndex) + 1 }}</span>
                <a-divider style="margin: 0;" />
              </div>
              
              <!-- 条件列表 -->
              <div class="condition-list">
                <div
                  v-for="(condition, conditionIndex) in expression.conditions"
                  :key="condition.id"
                  class="condition-row"
                >
                  <!-- 条件标签 -->
                  <div class="condition-label">
                    条件{{ Number(conditionIndex) + 1 }}:
                  </div>
                  
                  <!-- 条件内容 -->
                  <a-select
                    v-model:value="condition.conditionItem"
                    placeholder="请选择条件"
                    style="width: 180px"
                    @change="handleConditionItemChange(condition)"
                  >
                    <a-select-option
                      v-for="item in getAllConditionItems()"
                      :key="item.value"
                      :value="item.value"
                    >
                      {{ item.label }}
                    </a-select-option>
                  </a-select>
                  
                  <a-select
                    v-model:value="condition.operator"
                    placeholder="操作符"
                    style="width: 120px"
                    @change="handleOperatorChange(condition)"
                  >
                    <a-select-option
                      v-for="op in getOperators(condition.conditionItem)"
                      :key="op.value"
                      :value="op.value"
                    >
                      {{ op.label }}
                    </a-select-option>
                  </a-select>
                  
                  <!-- 值输入区域 -->
                  <div class="condition-value-wrapper">
                    <!-- 枚举类型输入 -->
                    <a-select
                      v-if="getValueInputType(condition.conditionItem, condition.operator) === 'select'"
                      v-model:value="condition.value"
                      placeholder="请输入值"
                      style="width: 200px"
                      :mode="condition.operator === 'include' ? 'multiple' : undefined"
                      allow-clear
                    >
                      <a-select-option
                        v-for="opt in getEnumValues(condition.conditionItem)"
                        :key="opt.value"
                        :value="opt.value"
                      >
                        {{ opt.label }}
                      </a-select-option>
                    </a-select>

                    <!-- 数字输入 -->
                    <a-input-number
                      v-else-if="getValueInputType(condition.conditionItem, condition.operator) === 'number'"
                      v-model:value="condition.value"
                      placeholder="请输入值"
                      style="width: 200px"
                      :min="0"
                      allow-clear
                    />

                    <!-- 数字范围输入 -->
                    <a-space v-else-if="getValueInputType(condition.conditionItem, condition.operator) === 'range'">
                      <a-input-number
                        v-model:value="condition.valueMin"
                        placeholder="最小值"
                        style="width: 100px"
                        :min="0"
                        allow-clear
                      />
                      <span style="color: #999;">至</span>
                      <a-input-number
                        v-model:value="condition.valueMax"
                        placeholder="最大值"
                        style="width: 100px"
                        :min="0"
                        allow-clear
                      />
                    </a-space>

                    <!-- 默认文本输入 -->
                    <a-input
                      v-else
                      v-model:value="condition.value"
                      placeholder="请输入值"
                      style="width: 200px"
                      allow-clear
                    />
                  </div>
                  
                  <!-- 操作按钮 -->
                  <div class="condition-actions">
                    <a-button
                      v-if="Number(conditionIndex) === expression.conditions.length - 1"
                      type="link"
                      size="small"
                      class="add-condition-btn"
                      @click="handleAddConditionToExpression(Number(exprIndex))"
                    >
                      <plus-outlined />
                      添加条件
                    </a-button>
                    <a-button
                      type="link"
                      size="small"
                      danger
                      @click="handleDeleteCondition(Number(exprIndex), Number(conditionIndex))"
                    >
                      <minus-circle-outlined />
                      删除
                    </a-button>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 新增表达式按钮 -->
            <a-button type="dashed" @click="handleAddExpression" class="add-expression-btn">
              <plus-outlined />
              新增表达式
            </a-button>
          </div>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 查看详情弹窗 -->
    <a-modal
      v-model:open="viewModalVisible"
      title="客群详情"
      width="800px"
      :footer="null"
    >
      <a-descriptions bordered :column="2">
        <a-descriptions-item label="客群编号">{{ viewData.groupNo }}</a-descriptions-item>
        <a-descriptions-item label="客群名称">{{ viewData.groupName }}</a-descriptions-item>
        <a-descriptions-item label="客群说明" :span="2">{{ viewData.groupDescription || '-' }}</a-descriptions-item>
        <a-descriptions-item label="创建人">{{ viewData.creator || '-' }}</a-descriptions-item>
        <a-descriptions-item label="创建时间">{{ viewData.createTime }}</a-descriptions-item>
      </a-descriptions>
    </a-modal>

    <!-- 创建任务批次弹窗 -->
    <a-modal
      v-model:open="batchModalVisible"
      title="创建任务批次"
      width="800px"
      :confirm-loading="batchModalConfirmLoading"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleBatchModalOk"
    >
      <a-form
        ref="batchFormRef"
        :model="batchFormData"
        :rules="batchFormRules"
        layout="vertical"
      >
        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="数据批次名称" name="batchName">
              <a-input
                v-model:value="batchFormData.batchName"
                placeholder="请输入数据批次名称（50 字符内）"
                :maxlength="50"
                show-count
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="数据批次类型" name="batchType">
              <a-select
                v-model:value="batchFormData.batchType"
                placeholder="请选择数据批次类型"
              >
                <a-select-option value="test">测试批次</a-select-option>
                <a-select-option value="formal">正式批次</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="批次所属机构" name="orgId">
              <a-tree-select
                v-model:value="batchFormData.orgId"
                placeholder="请选择批次所属机构"
                :tree-data="orgTreeData"
                :field-names="{ label: 'name', value: 'id', children: 'children' }"
                show-search
                style="width: 100%"
                allow-clear
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="24">
            <a-form-item label="数据批次说明" name="batchDescription">
              <a-textarea
                v-model:value="batchFormData.batchDescription"
                placeholder="请输入数据批次说明信息"
                :rows="3"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="任务类型" name="taskType">
              <a-select
                v-model:value="batchFormData.taskType"
                placeholder="请选择任务类型"
              >
                <a-select-option value="manual">人工外呼</a-select-option>
                <a-select-option value="ai">AI 外呼</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="场景" name="sceneId">
              <a-select
                v-model:value="batchFormData.sceneId"
                placeholder="请选择场景"
                :options="sceneOptions"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="客群" name="groupId">
              <a-select
                v-model:value="batchFormData.groupId"
                placeholder="请选择客群"
                :options="groupOptions"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="任务标签" name="taskTag">
              <a-select
                v-model:value="batchFormData.taskTag"
                mode="multiple"
                placeholder="请选择任务标签（可多选）"
                :options="tagOptions"
                :max-tag-count="3"
              />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import {
  SearchOutlined,
  PlusOutlined,
  DeleteOutlined,
  ReloadOutlined,
  InfoCircleOutlined,
  MinusCircleOutlined,
  FileAddOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnType } from 'ant-design-vue';
import { message, Modal } from 'ant-design-vue';

// 搜索表单引用
const searchFormRef = ref<any>();

// 搜索表单
const searchForm = reactive({
  groupName: '',
  groupType: '',
  creator: '',
  createTimeRange: undefined as [any, any] | undefined,
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
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
});

// 表格列配置
const columns: TableColumnType[] = [
  { title: '客群编号', dataIndex: 'groupNo', key: 'groupNo', width: 140, ellipsis: true },
  { title: '客群名称', dataIndex: 'groupName', key: 'groupName', width: 150, ellipsis: true },
  { title: '客群说明', dataIndex: 'groupDescription', key: 'groupDescription', width: 200, ellipsis: true },
  { title: '客群类型', dataIndex: 'groupType', key: 'groupType', width: 100, align: 'center' },
  { title: '创建人', dataIndex: 'creator', key: 'creator', width: 120, ellipsis: true },
  { title: '创建时间', dataIndex: 'createTime', key: 'createTime', width: 160, sorter: true },
  { title: '操作', dataIndex: 'action', key: 'action', width: 180, align: 'center', fixed: 'right' },
];

// 弹窗控制
const modalVisible = ref(false);
const viewModalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);

// 创建任务批次弹窗控制
const batchModalVisible = ref(false);
const batchModalConfirmLoading = ref(false);
const batchFormRef = ref<any>();

// 创建任务批次表单数据
const batchFormData = ref<any>({
  batchName: '',
  batchType: '',
  batchDescription: '',
  orgId: '',
  taskType: '',
  sceneId: '',
  groupId: '',
  taskTag: [] as string[],
});

// 创建任务批次表单验证规则
const batchFormRules = {
  batchName: [
    { required: true, message: '请输入数据批次名称', trigger: 'blur' },
    { max: 50, message: '批次名称不能超过 50 个字符', trigger: 'blur' },
  ],
  batchType: [
    { required: true, message: '请选择数据批次类型', trigger: 'change' },
  ],
  orgId: [
    { required: true, message: '请选择批次所属机构', trigger: 'change' },
  ],
  taskType: [
    { required: true, message: '请选择任务类型', trigger: 'change' },
  ],
  sceneId: [
    { required: true, message: '请选择场景', trigger: 'change' },
  ],
  groupId: [
    { required: true, message: '请选择客群', trigger: 'change' },
  ],
  taskTag: [
    { required: true, message: '请选择任务标签', trigger: 'change' },
  ],
};

// 机构树数据
const orgTreeData = ref<any[]>([
  { id: '1', name: '总行', children: [
    { id: '1-1', name: '北京分行' },
    { id: '1-2', name: '上海分行' },
    { id: '1-3', name: '广州分行' },
  ]},
  { id: '2', name: '信用卡中心', children: [] },
]);

// 场景选项
const sceneOptions = ref<any[]>([
  { label: '场景 A', value: 'scene-a' },
  { label: '场景 B', value: 'scene-b' },
  { label: '场景 C', value: 'scene-c' },
]);

// 客群选项
const groupOptions = ref<any[]>([]);

// 任务标签选项（来自客户标签定义）
const tagOptions = ref<any[]>([
  { label: '客户等级', value: 'customer_level' },
  { label: '跟进状态', value: 'follow_status' },
  { label: '风险等级', value: 'risk_level' },
  { label: '产品意向', value: 'product_intention' },
  { label: '备注说明', value: 'remark' },
  { label: '联系偏好', value: 'contact_preference' },
]);

// 条件项接口
interface ConditionItem {
  id: string;
  conditionItem: string;
  operator: string;
  value?: any;
  valueMin?: number;
  valueMax?: number;
}

// 表达式接口
interface Expression {
  id: string;
  conditions: ConditionItem[];
  nextLogic?: 'AND' | 'OR';
}

// 表单数据
const formData = ref<any>({
  id: undefined,
  groupName: '',
  groupDescription: '',
  conditions: [] as Expression[],
});

// 查看详情数据
const viewData = ref<any>({});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  groupName: [{ required: true, message: '请输入客群名称', trigger: 'blur' }],
};

// 条件项配置
const CONDITION_ITEMS: Array<{ value: string; label: string; valueType: string }> = [
  { value: 'gender', label: '性别', valueType: 'enum' },
  { value: 'ageRange', label: '年龄范围', valueType: 'range' },
  { value: 'region', label: '地区', valueType: 'enum' },
  { value: 'customerTag', label: '客户标签', valueType: 'enum' },
  { value: 'callCount', label: '近 N 天拨打次数', valueType: 'number' },
  { value: 'contactCount', label: '近 N 天联系次数', valueType: 'number' },
  { value: 'valueLevel', label: '客户价值等级', valueType: 'enum' },
  { value: 'assetScale', label: '资产规模', valueType: 'number' },
];

// 操作符配置
const OPERATORS: Record<string, Array<{ value: string; label: string }>> = {
  gender: [
    { value: 'eq', label: '等于' },
    { value: 'neq', label: '不等于' },
    { value: 'include', label: '包含' },
  ],
  ageRange: [{ value: 'between', label: '介于' }],
  region: [
    { value: 'eq', label: '等于' },
    { value: 'neq', label: '不等于' },
    { value: 'include', label: '包含' },
  ],
  customerTag: [
    { value: 'eq', label: '等于' },
    { value: 'neq', label: '不等于' },
    { value: 'include', label: '包含' },
  ],
  callCount: [
    { value: 'gt', label: '大于' },
    { value: 'lt', label: '小于' },
    { value: 'eq', label: '等于' },
  ],
  contactCount: [
    { value: 'gt', label: '大于' },
    { value: 'lt', label: '小于' },
    { value: 'eq', label: '等于' },
  ],
  valueLevel: [
    { value: 'eq', label: '等于' },
    { value: 'neq', label: '不等于' },
    { value: 'include', label: '包含' },
  ],
  assetScale: [
    { value: 'gt', label: '大于' },
    { value: 'lt', label: '小于' },
    { value: 'eq', label: '等于' },
  ],
};

// 枚举值配置
const ENUM_VALUES: Record<string, Array<{ value: string; label: string }>> = {
  gender: [
    { value: 'male', label: '男' },
    { value: 'female', label: '女' },
  ],
  region: [
    { value: 'beijing', label: '北京' },
    { value: 'shanghai', label: '上海' },
    { value: 'guangzhou', label: '广州' },
    { value: 'shenzhen', label: '深圳' },
    { value: 'other', label: '其他' },
  ],
  customerTag: [
    { value: 'vip', label: 'VIP 客户' },
    { value: 'potential', label: '潜力客户' },
    { value: 'common', label: '普通客户' },
    { value: 'inactive', label: '沉睡客户' },
  ],
  valueLevel: [
    { value: 'high', label: '高价值' },
    { value: 'medium', label: '中价值' },
    { value: 'low', label: '低价值' },
  ],
};

// 获取所有条件项
const getAllConditionItems = () => {
  return CONDITION_ITEMS;
};

// 获取操作符列表
const getOperators = (conditionItem: string) => {
  return OPERATORS[conditionItem] || [];
};

// 获取枚举值列表
const getEnumValues = (conditionItem: string) => {
  return ENUM_VALUES[conditionItem] || [];
};

// 获取值输入类型
const getValueInputType = (conditionItem: string, operator: string) => {
  const itemConfig = CONDITION_ITEMS.find(item => item.value === conditionItem);
  if (!itemConfig) return 'text';
  if (operator === 'between') return 'range';
  if (itemConfig.valueType === 'enum') return 'select';
  if (itemConfig.valueType === 'number') return 'number';
  return 'text';
};

// 生成唯一 ID
const generateId = () => {
  return `item_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

// 创建默认条件
const createDefaultCondition = (): ConditionItem => ({
  id: generateId(),
  conditionItem: 'gender',
  operator: 'eq',
  value: undefined,
  valueMin: undefined,
  valueMax: undefined,
});

// 创建默认表达式
const createDefaultExpression = (): Expression => ({
  id: generateId(),
  conditions: [createDefaultCondition()],
  nextLogic: 'AND',
});

// 新增表达式
const handleAddExpression = () => {
  if (!formData.value.conditions) {
    formData.value.conditions = [];
  }
  formData.value.conditions.push(createDefaultExpression());
};

// 在表达式中添加条件
const handleAddConditionToExpression = (exprIndex: number) => {
  formData.value.conditions[exprIndex].conditions.push(createDefaultCondition());
};

// 删除条件
const handleDeleteCondition = (exprIndex: number, conditionIndex: number) => {
  const expression = formData.value.conditions[exprIndex];
  if (expression.conditions.length === 1) {
    message.warning('每个表达式至少保留一个条件');
    return;
  }
  expression.conditions.splice(conditionIndex, 1);
};

// 条件项变化
const handleConditionItemChange = (condition: ConditionItem) => {
  const ops = getOperators(condition.conditionItem);
  if (ops.length > 0) {
    condition.operator = ops[0].value;
  }
  condition.value = undefined;
  condition.valueMin = undefined;
  condition.valueMax = undefined;
};

// 操作符变化
const handleOperatorChange = (condition: ConditionItem) => {
  condition.value = undefined;
  condition.valueMin = undefined;
  condition.valueMax = undefined;
};

// 加载数据
const loadData = () => {
  loading.value = true;
  setTimeout(() => {
    dataSource.value = Array.from({ length: 10 }, (_, index) => ({
      id: index + 1,
      groupNo: `GRP${String(index + 1).padStart(8, '0')}`,
      groupName: `客群${index + 1}`,
      groupDescription: `这是客群${index + 1}的描述信息`,
      groupType: index % 2 === 0 ? 'fixed' : 'rule',
      creator: `用户${index + 1}`,
      createTime: '2024-01-01 10:00:00',
    }));
    total.value = 100;
    pagination.total = 100;
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
  searchForm.groupName = '';
  searchForm.groupType = '';
  searchForm.creator = '';
  searchForm.createTimeRange = undefined;
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

// 新增
const handleAdd = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    groupName: '',
    groupDescription: '',
    conditions: [createDefaultExpression()],
  };
  modalVisible.value = true;
};

// 编辑
const handleEdit = (record: any) => {
  isEditMode.value = true;
  formData.value = {
    ...record,
    conditions: record.conditions || [createDefaultExpression()],
  };
  modalVisible.value = true;
};

// 查看
const handleView = (record: any) => {
  viewData.value = { ...record };
  viewModalVisible.value = true;
};

// 删除
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除客群"${record.groupName}"吗？`,
    okText: '确定',
    cancelText: '取消',
    okType: 'danger',
    onOk() {
      message.success('删除成功');
      loadData();
    },
  });
};

// 创建任务批次
const handleCreateBatch = () => {
  // 加载客群列表作为选项
  groupOptions.value = dataSource.value.map((item: any) => ({
    label: item.groupName,
    value: item.id,
  }));
  
  batchFormData.value = {
    batchName: '',
    batchType: '',
    batchDescription: '',
    orgId: '',
    taskType: '',
    sceneId: '',
    groupId: '',
    taskTag: [],
  };
  batchModalVisible.value = true;
};

// 弹窗确定
const handleModalOk = async () => {
  try {
    await formRef.value?.validate();

    if (!formData.value.conditions || formData.value.conditions.length === 0) {
      message.error('请至少添加一个圈客条件');
      return;
    }

    for (const expression of formData.value.conditions) {
      for (const condition of expression.conditions) {
        const inputType = getValueInputType(condition.conditionItem, condition.operator);
        if (inputType === 'range') {
          if (condition.valueMin === undefined || condition.valueMax === undefined) {
            message.error('请完整填写条件范围值');
            return;
          }
        } else {
          if (condition.value === undefined || condition.value === '') {
            message.error('请完整填写所有条件值');
            return;
          }
        }
      }
    }

    modalConfirmLoading.value = true;
    setTimeout(() => {
      message.success(isEditMode.value ? '编辑成功' : '新增成功');
      modalVisible.value = false;
      modalConfirmLoading.value = false;
      loadData();
    }, 500);
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 批次弹窗确定
const handleBatchModalOk = async () => {
  try {
    await batchFormRef.value?.validate();
    batchModalConfirmLoading.value = true;
    // TODO: 调用后端 API 创建任务批次
    setTimeout(() => {
      message.success('创建任务批次成功');
      batchModalVisible.value = false;
      batchModalConfirmLoading.value = false;
    }, 500);
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.customer-group-management {
  display: flex;
  flex-direction: column;
}

.quality-wrapper {
  display: flex;
  flex-direction: column;
}

.search-and-table-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  margin: 16px;
  margin-top: 0px;
  border-radius: 4px;
  padding: 24px;
  overflow: auto;
}

.search-area {
  margin-bottom: 8px;
}

.search-btn-space {
  float: right;
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

/* 表达式容器 */
.expression-container {
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  background: #fafafa;
}

/* 表达式项 */
.expression-item {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  margin-bottom: 16px;
}

.expression-item:last-child {
  margin-bottom: 0;
}

/* 表达式标题 */
.expression-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
}

.expression-title {
  font-weight: 600;
  color: #1f2329;
  font-size: 14px;
  margin-right: 12px;
  white-space: nowrap;
}

.expression-header :deep(.ant-divider) {
  margin: 0;
  flex: 1;
}

/* 条件列表 */
.condition-list {
  background: #f5f5f5;
  border-radius: 4px;
  padding: 12px;
}

/* 条件行 */
.condition-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.condition-row:last-child {
  margin-bottom: 0;
}

.condition-label {
  min-width: 60px;
  color: #646a73;
  font-size: 14px;
}

.condition-value-wrapper {
  flex: 1;
  min-width: 200px;
}

.condition-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.add-condition-btn {
  color: #1890ff;
}

/* 新增表达式按钮 */
.add-expression-btn {
  width: 100%;
  margin-top: 16px;
  border-color: #d9d9d9;
}

.add-expression-btn:hover {
  border-color: #40a9ff;
  color: #40a9ff;
}
</style>
