<template>
  <div class="customer-management">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section" style="display: none;">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">客户管理</h2>
            <p class="page-description">管理客户信息，支持批量导入、导出和客户数据维护。</p>
          </div>
          <div class="header-right">
            <a-button type="primary" class="create-task-btn" @click="handleAdd">
              <plus-outlined />
              新增客户
            </a-button>
          </div>
        </div>
      </div>

      <!-- 搜索区域和表格区域合并 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-form ref="searchFormRef" layout="vertical">
            <a-row :gutter="16" style="margin-bottom: -12px;">
              <!-- 第一行 -->
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.keyword"
                    placeholder="请输入客户号或客户名称"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.phone"
                    placeholder="请输入手机号码"
                    allow-clear
                    :maxlength="11"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.bankOrgCode"
                    placeholder="请选择银行机构"
                    allow-clear
                    show-search
                  >
                    <a-select-option value="org001">总行营业部</a-select-option>
                    <a-select-option value="org002">北京分行</a-select-option>
                    <a-select-option value="org003">上海分行</a-select-option>
                    <a-select-option value="org004">广州分行</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.seatNo"
                    placeholder="请输入坐席工号或姓名"
                    allow-clear
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="16" style="margin-top: -12px;">
              <!-- 第二行 -->
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
              <a-col :span="6">
                <a-form-item>
                  <a-range-picker
                    v-model:value="searchForm.updateTimeRange"
                    style="width: 100%"
                    allow-clear
                    :placeholder="['更新开始时间', '更新结束时间']"
                    show-time
                    format="YYYY-MM-DD HH:mm:ss"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="12">
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
          <span class="selection-info">共 {{ total }} 条，已选 {{ selectedRowKeys.length }} 条</span>
          <a-button
            type="primary"
            danger
            @click="handleBatchDelete"
            style="margin-left: 12px"
            :disabled="selectedRowKeys.length === 0"
          >
            <delete-outlined />
            批量删除 ({{ selectedRowKeys.length }})
          </a-button>
        </div>
        <div class="table-toolbar-right">
          <a-button @click="handleImport">
            <import-outlined />
            导入
          </a-button>
          <a-button type="primary" @click="handleAdd" style="margin-left: 12px">
            <plus-outlined />
            新增客户
          </a-button>
          <a-button @click="handleAddToGroup" style="margin-left: 12px" :disabled="selectedRowKeys.length === 0">
            <usergroup-add-outlined />
            新增客群
          </a-button>
        </div>
      </div>

      <!-- 数据表格 -->
      <div class="table-area">
        <!-- 表格包装器 -->
        <div class="table-wrapper">
          <a-table
            :columns="columns"
            :data-source="dataSource"
            :pagination="false"
            row-key="id"
            :loading="loading"
            :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
            :scroll="{ x: 1600 }"
            @change="handleTableChange"
          >
            <!-- 客户类型列 -->
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'customerType'">
                <a-tag :color="record.customerType === 'personal' ? 'blue' : 'green'">
                  {{ record.customerType === 'personal' ? '个人客户' : '企业客户' }}
                </a-tag>
              </template>
              <!-- 状态列 -->
              <template v-else-if="column.key === 'status'">
                <a-badge
                  :status="record.status === 'active' ? 'success' : record.status === 'frozen' ? 'error' : 'default'"
                  :text="record.status === 'active' ? '活跃' : record.status === 'frozen' ? '冻结' : ' inactive'"
                />
              </template>
              <!-- 标签列 -->
              <template v-else-if="column.key === 'tags'">
                <div class="tags-container">
                  <a-tag
                    v-for="(tag, index) in record.tagsArray"
                    :key="index"
                    color="processing"
                  >
                    {{ tag }}
                  </a-tag>
                </div>
              </template>
              <!-- 创建时间列 -->
              <template v-else-if="column.key === 'createTime'">
                {{ record.createTime }}
              </template>
              <!-- 更新时间列 -->
              <template v-else-if="column.key === 'updateTime'">
                {{ record.updateTime }}
              </template>
              <!-- 操作列 -->
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

    <!-- 新增/编辑弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEditMode ? '编辑客户' : '新增客户'"
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
          <a-col :span="12">
            <a-form-item label="客户号" name="customerNo">
              <a-input
                v-model:value="formData.customerNo"
                placeholder="请输入客户号"
                :maxlength="50"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="客户名称" name="customerName">
              <a-input
                v-model:value="formData.customerName"
                placeholder="请输入客户名称"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="性别" name="gender">
              <a-select
                v-model:value="formData.gender"
                placeholder="请选择性别"
                allow-clear
              >
                <a-select-option value="male">男</a-select-option>
                <a-select-option value="female">女</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="联系方式" name="phone">
              <a-input
                v-model:value="formData.phone"
                placeholder="请输入手机号码"
                :maxlength="11"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="归属机构" name="bankOrgCode">
              <a-select
                v-model:value="formData.bankOrgCode"
                placeholder="请选择归属机构"
                allow-clear
              >
                <a-select-option value="org001">总行营业部</a-select-option>
                <a-select-option value="org002">北京分行</a-select-option>
                <a-select-option value="org003">上海分行</a-select-option>
                <a-select-option value="org004">广州分行</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="直营坐席" name="seatNo">
              <a-select
                v-model:value="formData.seatNo"
                placeholder="请选择直营坐席"
                allow-clear
                show-search
              >
                <a-select-option value="SEAT0001">坐席 001</a-select-option>
                <a-select-option value="SEAT0002">坐席 002</a-select-option>
                <a-select-option value="SEAT0003">坐席 003</a-select-option>
                <a-select-option value="SEAT0004">坐席 004</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <!-- 标签区域 -->
        <a-divider orientation="left">
          客户标签
          <a-button type="link" size="small" @click="openTagSelector">
            <plus-outlined />
            添加标签
          </a-button>
        </a-divider>

        <!-- 已选择的标签字段展示 -->
        <a-row :gutter="16" v-if="selectedTagFields.length > 0">
          <a-col :span="12" v-for="(field, index) in selectedTagFields" :key="field.key">
            <a-form-item :label="field.label" :name="field.key">
              <a-select
                v-model:value="formData[field.key]"
                mode="multiple"
                :placeholder="'请选择' + field.label"
                style="width: 100%"
                allow-clear
              >
                <a-select-option v-for="option in field.options" :key="option.value" :value="option.value">
                  {{ option.label }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <!-- 标签选择器弹窗 -->
        <a-modal
          v-model:open="tagSelectorVisible"
          title="选择标签字段"
          width="600px"
          ok-text="确定"
          cancel-text="取消"
          @ok="handleTagSelectorOk"
        >
          <a-form layout="vertical">
            <a-alert
              type="info"
              style="margin-bottom: 16px"
              message="请选择需要显示的标签字段，勾选后可在表单中填写对应标签值"
            />
            <a-row :gutter="16">
              <a-col :span="12" v-for="group in tagFieldGroups" :key="group.key">
                <div class="tag-field-group">
                  <div class="tag-field-group-title">{{ group.label }}</div>
                  <a-checkbox
                    v-for="field in group.fields"
                    :key="field.key"
                    v-model:checked="tempSelectedTagFields[field.key]"
                    class="tag-field-item"
                  >
                    {{ field.label }}
                  </a-checkbox>
                </div>
              </a-col>
            </a-row>
          </a-form>
        </a-modal>
      </a-form>
    </a-modal>

    <!-- 导入弹窗 -->
    <a-modal
      v-model:open="importModalVisible"
      title="导入客户"
      width="600px"
      :confirm-loading="importModalConfirmLoading"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleImportOk"
    >
      <a-form layout="vertical">
        <a-alert
          type="info"
          style="margin-bottom: 16px"
          :show-icon="true"
          message="导入说明"
        >
          <template #description>
            <div>1. 请按照模板格式准备 Excel 或 CSV 文件</div>
            <div>2. 必填字段：客户号、客户名称、性别、联系方式、银行机构号、机构名称、直营坐席工号</div>
            <div>3. 性别：男/女；客户类型：personal/enterprise</div>
            <div>4. 支持文件格式：.xlsx, .xls, .csv</div>
          </template>
        </a-alert>
        <a-form-item label="选择文件">
          <input
            ref="fileInputRef"
            type="file"
            accept=".xlsx,.xls,.csv"
            @change="handleFileChange"
            style="width: 100%"
          />
        </a-form-item>

        <a-form-item label="导入选项">
          <a-checkbox v-model:checked="importOptions.overwriteDuplicate">
            覆盖重复客户（根据客户号）
          </a-checkbox>
        </a-form-item>

        <a-divider />

        <a-form-item label="导入预览">
          <a-table
            :columns="importPreviewColumns"
            :data-source="importPreviewData"
            :pagination="false"
            :scroll="{ y: 200 }"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'previewStatus'">
                <a-badge
                  :status="record.status === 'valid' ? 'success' : 'error'"
                  :text="record.status === 'valid' ? '有效' : '无效'"
                />
              </template>
            </template>
          </a-table>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 新增客群弹窗 -->
    <a-modal
      v-model:open="groupModalVisible"
      :title="'新增客群'"
      width="700px"
      :confirm-loading="groupModalConfirmLoading"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleGroupModalOk"
    >
      <a-form
        ref="groupFormRef"
        :model="groupFormData"
        :rules="groupFormRules"
        layout="vertical"
      >
        <!-- 第一步：选择操作类型 -->
        <a-form-item label="操作类型" name="groupOperationType">
          <a-radio-group
            v-model:value="groupFormData.groupOperationType"
            button-style="solid"
            @change="handleGroupOperationTypeChange"
          >
            <a-radio-button value="create">生成新的客群</a-radio-button>
            <a-radio-button value="add">添加到现有客群</a-radio-button>
          </a-radio-group>
        </a-form-item>

        <!-- 生成新的客群 -->
        <template v-if="groupFormData.groupOperationType === 'create'">
          <a-row :gutter="16">
            <a-col :span="24">
              <a-form-item label="客群名称" name="newGroupName">
                <a-input
                  v-model:value="groupFormData.newGroupName"
                  placeholder="请输入客群名称"
                />
              </a-form-item>
            </a-col>
          </a-row>
          <a-row :gutter="16">
            <a-col :span="24">
              <a-form-item label="客群说明" name="newGroupDescription">
                <a-textarea
                  v-model:value="groupFormData.newGroupDescription"
                  placeholder="请输入客群说明"
                  :rows="3"
                />
              </a-form-item>
            </a-col>
          </a-row>
        </template>

        <!-- 添加到现有客群 -->
        <template v-else-if="groupFormData.groupOperationType === 'add'">
          <a-row :gutter="16">
            <a-col :span="24">
              <a-form-item label="选择客群" name="existingGroupId">
                <a-select
                  v-model:value="groupFormData.existingGroupId"
                  placeholder="请选择要添加到的客群（仅显示固定客群）"
                  :options="fixedGroupOptions"
                  show-search
                  :filter-option="filterGroupOption"
                />
              </a-form-item>
            </a-col>
          </a-row>
          <a-alert
            type="info"
            show-icon
            style="margin-top: 12px;"
          >
            <template #message>
              已选择 <strong>{{ selectedRowKeys.length }}</strong> 位客户，将添加到所选客群中
            </template>
          </a-alert>
        </template>

        <a-divider v-if="groupFormData.groupOperationType" />

        <!-- 已选客户数量 -->
        <template v-if="groupFormData.groupOperationType === 'create'">
        <a-alert
          type="info"
          show-icon
        >
          <template #message>
            已选择 <strong>{{ selectedRowKeys.length }}</strong> 位客户
          </template>
        </a-alert>
        </template>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import {
  SearchOutlined,
  PlusOutlined,
  DeleteOutlined,
  ImportOutlined,
  ReloadOutlined,
  UsergroupAddOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnType } from 'ant-design-vue';
import { message, Modal } from 'ant-design-vue';
import type { Dayjs } from 'dayjs';
import Pagination from '@/components/Pagination';

const router = useRouter();

// 搜索表单
const searchFormRef = ref<any>();
const searchForm = reactive({
  keyword: '', // 客户号/客户名称
  phone: '', // 联系方式
  bankOrgCode: undefined as string | undefined, // 银行机构号
  seatNo: '', // 直营坐席工号/姓名
  createTimeRange: undefined as [Dayjs, Dayjs] | undefined, // 创建时间范围
  updateTimeRange: undefined as [Dayjs, Dayjs] | undefined, // 更新时间范围
});

// 表格数据
const dataSource = ref<any[]>([]);
const total = ref(0);
const loading = ref(false);

// 选中的行
const selectedRowKeys = ref<number[]>([]);

// 分页
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

// 表格列配置
const columns: TableColumnType[] = [
  {
    title: '序号',
    dataIndex: 'index',
    key: 'index',
    width: 60,
    align: 'center',
  },
  {
    title: '客户号',
    dataIndex: 'customerNo',
    key: 'customerNo',
    width: 140,
  },
  {
    title: '客户名称',
    dataIndex: 'customerName',
    key: 'customerName',
    width: 120,
  },
  {
    title: '性别',
    dataIndex: 'gender',
    key: 'gender',
    width: 80,
    align: 'center',
  },
  {
    title: '联系方式',
    dataIndex: 'phone',
    key: 'phone',
    width: 130,
  },
  {
    title: '银行机构号',
    dataIndex: 'bankOrgCode',
    key: 'bankOrgCode',
    width: 130,
  },
  {
    title: '机构名称',
    dataIndex: 'orgName',
    key: 'orgName',
    width: 180,
    ellipsis: true,
  },
  {
    title: '直营坐席工号',
    dataIndex: 'seatNo',
    key: 'seatNo',
    width: 120,
  },
  {
    title: '标签',
    dataIndex: 'tags',
    key: 'tags',
    width: 200,
    ellipsis: true,
  },
  {
    title: '备注',
    dataIndex: 'remark',
    key: 'remark',
    width: 200,
    ellipsis: true,
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    key: 'createTime',
    width: 160,
    sorter: true,
  },
  {
    title: '更新时间',
    dataIndex: 'updateTime',
    key: 'updateTime',
    width: 160,
    sorter: true,
  },
  {
    title: '操作',
    dataIndex: 'action',
    key: 'action',
    width: 180,
    align: 'center',
    fixed: 'right',
  },
];

// 弹窗控制
const modalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);

// 新增客群弹窗控制
const groupModalVisible = ref(false);
const groupModalConfirmLoading = ref(false);
const groupFormRef = ref<any>();

// 新增客群表单数据
const groupFormData = ref<any>({
  groupOperationType: 'create', // 'create' 或 'add'
  newGroupName: '',
  newGroupDescription: '',
  existingGroupId: undefined,
});

// 新增客群表单验证规则
const groupFormRules = {
  groupOperationType: [
    { required: true, message: '请选择操作类型', trigger: 'change' },
  ],
  newGroupName: [
    { required: true, message: '请输入客群名称', trigger: 'blur' },
  ],
  existingGroupId: [
    { required: true, message: '请选择客群', trigger: 'change' },
  ],
};

// 固定客群选项（用于添加到现有客群）
const fixedGroupOptions = ref<any[]>([
  { label: '高价值客户群', value: 'group1', type: 'fixed' },
  { label: 'VIP 客户群', value: 'group2', type: 'fixed' },
  { label: '潜力客户群', value: 'group3', type: 'fixed' },
]);

// 表单数据
const formData = ref<any>({
  id: undefined,
  customerNo: '',
  customerName: '',
  gender: undefined,
  phone: '',
  bankOrgCode: undefined,
  seatNo: undefined,
});

// 标签字段定义
const tagFieldDefinitions = {
  tag1: {
    key: 'tag1',
    label: '客户类型',
    options: [
      { value: 'vip', label: 'VIP 客户' },
      { value: 'high_value', label: '高价值客户' },
      { value: 'potential', label: '潜力客户' },
      { value: 'ordinary', label: '普通客户' },
      { value: 'loss_risk', label: '流失风险' },
    ],
  },
  tag2: {
    key: 'tag2',
    label: '跟进信息',
    options: [
      { value: 'follow_status', label: '跟进状态' },
      { value: 'risk_level', label: '风险等级' },
      { value: 'product_intent', label: '产品意向' },
      { value: 'contact_pref', label: '联系偏好' },
    ],
  },
  tag3: {
    key: 'tag3',
    label: '产品信息',
    options: [
      { value: 'deposit', label: '存款' },
      { value: 'loan', label: '贷款' },
      { value: 'wealth', label: '理财' },
      { value: 'insurance', label: '保险' },
      { value: 'fund', label: '基金' },
    ],
  },
  tag4: {
    key: 'tag4',
    label: '联系方式',
    options: [
      { value: 'phone', label: '电话' },
      { value: 'sms', label: '短信' },
      { value: 'wechat', label: '微信' },
      { value: 'email', label: '邮件' },
    ],
  },
};

// 标签字段分组
const tagFieldGroups = [
  {
    key: 'group1',
    label: '基础标签',
    fields: [tagFieldDefinitions.tag1, tagFieldDefinitions.tag2],
  },
  {
    key: 'group2',
    label: '业务标签',
    fields: [tagFieldDefinitions.tag3, tagFieldDefinitions.tag4],
  },
];

// 已选择的标签字段
const selectedTagFields = ref<any[]>([]);

// 临时选择的标签字段（用于弹窗）
const tempSelectedTagFields = ref<Record<string, boolean>>({});

// 标签选择器弹窗
const tagSelectorVisible = ref(false);

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  customerNo: [
    { required: true, message: '请输入客户号', trigger: 'blur' },
    { max: 50, message: '客户号不能超过 50 个字符', trigger: 'blur' },
  ],
  customerName: [
    { required: true, message: '请输入客户名称', trigger: 'blur' },
  ],
  phone: [
    { required: true, message: '请输入联系方式', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' },
  ],
  bankOrgCode: [
    { required: true, message: '请选择归属机构', trigger: 'change' },
  ],
};

// 导入弹窗控制
const importModalVisible = ref(false);
const importModalConfirmLoading = ref(false);
const fileInputRef = ref<any>(null);
const selectedFile = ref<File | null>(null);
const importPreviewData = ref<any[]>([]);
const importOptions = reactive({
  overwriteDuplicate: false,
});

// 导入预览列配置
const importPreviewColumns: TableColumnType[] = [
  {
    title: '客户号',
    dataIndex: 'customerNo',
    key: 'customerNo',
    width: 120,
  },
  {
    title: '客户名称',
    dataIndex: 'customerName',
    key: 'customerName',
    width: 100,
  },
  {
    title: '性别',
    dataIndex: 'gender',
    key: 'gender',
    width: 60,
    align: 'center',
  },
  {
    title: '联系方式',
    dataIndex: 'phone',
    key: 'phone',
    width: 120,
  },
  {
    title: '状态',
    dataIndex: 'previewStatus',
    key: 'previewStatus',
    width: 60,
    align: 'center',
  },
];

// 加载数据
const loadData = () => {
  loading.value = true;
  // TODO: 调用后端 API 获取数据
  // 模拟数据
  setTimeout(() => {
    dataSource.value = Array.from({ length: 10 }, (_, index) => ({
      id: index + 1,
      index: index + 1,
      customerNo: `CUST${String(index + 1).padStart(8, '0')}`,
      customerName: `客户${index + 1}`,
      gender: index % 2 === 0 ? '男' : '女',
      phone: `1380013800${index}`,
      bankOrgCode: `ORG${String(index % 4 + 1).padStart(3, '0')}`,
      orgName: ['总行营业部', '北京分行', '上海分行', '广州分行'][index % 4],
      seatNo: `SEAT${String(index + 1).padStart(4, '0')}`,
      tagsArray: ['VIP 客户', '高价值客户'].slice(0, (index % 2) + 1),
      remark: `这是客户${index + 1}的备注信息`,
      createTime: '2024-01-01 10:00:00',
      updateTime: '2024-01-02 10:00:00',
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
  searchForm.keyword = '';
  searchForm.phone = '';
  searchForm.bankOrgCode = '';
  searchForm.seatNo = '';
  searchForm.createTimeRange = undefined;
  searchForm.updateTimeRange = undefined;
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

// 分页变化
const handlePageChange = () => {
  loadData();
};

// 选择行变化
const onSelectChange = (keys: any[]) => {
  selectedRowKeys.value = keys;
};

// 新增客群
const handleAddToGroup = () => {
  // 重置表单
  groupFormData.value = {
    groupOperationType: 'create',
    newGroupName: '',
    newGroupDescription: '',
    existingGroupId: undefined,
  };
  
  // 加载固定客群选项
  fixedGroupOptions.value = [
    { label: '高价值客户群', value: 'group1', type: 'fixed' },
    { label: 'VIP 客户群', value: 'group2', type: 'fixed' },
    { label: '潜力客户群', value: 'group3', type: 'fixed' },
  ];
  
  groupModalVisible.value = true;
};

// 操作类型变化
const handleGroupOperationTypeChange = () => {
  // 重置表单验证
  groupFormRef.value?.clearValidate();
};

// 过滤客群选项（只显示固定客群）
const filterGroupOption = (input: string, option: any) => {
  return option.label.toLowerCase().includes(input.toLowerCase());
};

// 新增客群弹窗确定
const handleGroupModalOk = async () => {
  try {
    await groupFormRef.value?.validate();
    groupModalConfirmLoading.value = true;
    
    if (groupFormData.value.groupOperationType === 'create') {
      // TODO: 调用后端 API 创建新客群
      setTimeout(() => {
        message.success(`创建新客群"${groupFormData.value.newGroupName}"成功，已添加 ${selectedRowKeys.value.length} 位客户`);
        groupModalVisible.value = false;
        groupModalConfirmLoading.value = false;
      }, 500);
    } else {
      // TODO: 调用后端 API 添加到现有客群
      const selectedGroup = fixedGroupOptions.value.find(g => g.value === groupFormData.value.existingGroupId);
      setTimeout(() => {
        message.success(`已将 ${selectedRowKeys.value.length} 位客户添加到"${selectedGroup?.label}"`);
        groupModalVisible.value = false;
        groupModalConfirmLoading.value = false;
      }, 500);
    }
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 新增
const handleAdd = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    customerNo: '',
    customerName: '',
    gender: undefined,
    phone: '',
    bankOrgCode: undefined,
    seatNo: undefined,
  };
  // 重置已选择的标签字段
  selectedTagFields.value = [];
  modalVisible.value = true;
};

// 编辑
const handleEdit = (record: any) => {
  isEditMode.value = true;
  formData.value = { ...record };
  modalVisible.value = true;
};

// 查看
const handleView = (record: any) => {
  router.push(`/customer-detail/${record.id}`);
};

// 打开标签选择器
const openTagSelector = () => {
  // 初始化临时选择的标签字段
  tempSelectedTagFields.value = {};
  selectedTagFields.value.forEach(field => {
    tempSelectedTagFields.value[field.key] = true;
  });
  tagSelectorVisible.value = true;
};

// 处理标签选择器确定
const handleTagSelectorOk = () => {
  // 根据选择更新标签字段
  selectedTagFields.value = [];
  Object.keys(tempSelectedTagFields.value).forEach(key => {
    if (tempSelectedTagFields.value[key]) {
      const fieldDef = tagFieldDefinitions[key as keyof typeof tagFieldDefinitions];
      if (fieldDef) {
        selectedTagFields.value.push(fieldDef);
        // 初始化表单数据
        if (!formData.value[key]) {
          formData.value[key] = [];
        }
      }
    }
  });
  tagSelectorVisible.value = false;
};

// 删除
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除客户"${record.customerName}"吗？`,
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

// 批量删除
const handleBatchDelete = () => {
  Modal.confirm({
    title: '确认批量删除',
    content: `确定要删除选中的 ${selectedRowKeys.value.length} 条记录吗？`,
    okText: '确定',
    cancelText: '取消',
    okType: 'danger',
    onOk() {
      // TODO: 调用后端 API 批量删除
      message.success('批量删除成功');
      selectedRowKeys.value = [];
      loadData();
    },
  });
};

// 导入
const handleImport = () => {
  importModalVisible.value = true;
  selectedFile.value = null;
  importPreviewData.value = [];
  if (fileInputRef.value) {
    fileInputRef.value.value = '';
  }
};

// 文件选择变化
const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (file) {
    selectedFile.value = file;
    // 解析文件并生成预览数据
    parseFileAndPreview(file);
  }
};

// 解析文件并生成预览数据
const parseFileAndPreview = (file: File) => {
  // TODO: 实际项目中应使用 xlsx 等库解析 Excel 文件
  // 这里模拟解析结果
  const mockPreviewData = Array.from({ length: 3 }, (_, index) => ({
    id: index + 1,
    customerNo: `CUST${String(index + 1).padStart(8, '0')}`,
    customerName: `导入客户${index + 1}`,
    gender: index % 2 === 0 ? '男' : '女',
    phone: `1380013800${index}`,
    status: 'valid',
  }));
  importPreviewData.value = mockPreviewData;
  message.success(`已选择文件：${file.name}，共 ${mockPreviewData.length} 条记录`);
};

// 导入确定
const handleImportOk = async () => {
  if (!selectedFile.value) {
    message.warning('请先选择文件');
    return;
  }

  if (importPreviewData.value.length === 0) {
    message.warning('没有可导入的数据');
    return;
  }

  importModalConfirmLoading.value = true;

  // TODO: 调用后端 API 导入数据
  // 模拟导入过程
  setTimeout(() => {
    const validCount = importPreviewData.value.filter(item => item.status === 'valid').length;
    message.success(`导入成功，共导入 ${validCount} 条记录`);
    importModalVisible.value = false;
    importModalConfirmLoading.value = false;
    selectedFile.value = null;
    importPreviewData.value = [];
    if (fileInputRef.value) {
      fileInputRef.value.value = '';
    }
    loadData();
  }, 1000);
};

// 弹窗确定
const handleModalOk = async () => {
  try {
    await formRef.value?.validate();
    modalConfirmLoading.value = true;
    // TODO: 调用后端 API 保存
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

// 初始化
onMounted(() => {
  loadData();
});
</script>

<style scoped>
.customer-management {
  display: flex;
  flex-direction: column;
}

.quality-wrapper {
  display: flex;
  flex-direction: column;
}

.quality-header-section {
  background: #fff;
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
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
  font-size: 20px;
  font-weight: 600;
  color: #1f2329;
}

.page-description {
  margin: 0;
  font-size: 14px;
  color: #646a73;
}

.header-right {
  flex-shrink: 0;
}

.create-task-btn {
  height: 36px;
}

/* 搜索区域和表格区域 */
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

.table-area {
  flex: 1;
  display: flex;
  flex-direction: column;
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

.table-toolbar-right {
  display: flex;
  align-items: center;
}

.table-wrapper {
  flex: 1;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

/* 标签字段选择器样式 */
.tag-field-group {
  margin-bottom: 16px;
}

.tag-field-group-title {
  font-weight: 600;
  margin-bottom: 8px;
  color: #1f2329;
  font-size: 14px;
}

.tag-field-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

/* 分页 */
.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
