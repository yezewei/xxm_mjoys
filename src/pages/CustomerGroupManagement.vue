<template>
  <div class="customer-group-management">
    <!-- 表格区域 -->
    <div class="table-area">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <div class="search-item">
          <a-input
            v-model:value="searchForm.keyword"
            placeholder="请输入数据批次 ID/名称"
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
            v-model:value="searchForm.uploadStatus"
            placeholder="请选择上传状态"
            allow-clear
            style="width: 150px"
          >
            <a-select-option value="success">上传成功</a-select-option>
            <a-select-option value="processing">上传中</a-select-option>
            <a-select-option value="failed">上传失败</a-select-option>
          </a-select>
        </div>
        <div class="search-item">
          <a-select
            v-model:value="searchForm.batchType"
            placeholder="请选择批次类型"
            allow-clear
            style="width: 150px"
          >
            <a-select-option value="import">导入</a-select-option>
            <a-select-option value="manual">手动</a-select-option>
            <a-select-option value="api">API</a-select-option>
          </a-select>
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
          <a-button @click="handleExport">
            <export-outlined />
            导出
          </a-button>
          <a-button type="primary" @click="handleAdd" style="margin-left: 12px">
            <plus-outlined />
            新增数据批次
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
        :row-selection="{ selectedRowKeys, onChange: onSelectChange }"
        :scroll="{ x: 2000 }"
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
        <!-- 客群类型列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'groupType'">
            <a-tag :color="getGroupTypeColor(record.groupType)">
              {{ getGroupTypeName(record.groupType) }}
            </a-tag>
          </template>
          <!-- 上传状态列 -->
          <template v-else-if="column.key === 'uploadStatus'">
            <a-badge
              :status="record.uploadStatus === 'success' ? 'success' : record.uploadStatus === 'processing' ? 'processing' : 'error'"
              :text="record.uploadStatus === 'success' ? '上传成功' : record.uploadStatus === 'processing' ? '上传中' : '上传失败'"
            />
          </template>
          <!-- 状态列 -->
          <template v-else-if="column.key === 'status'">
            <a-badge
              :status="record.status === 'active' ? 'success' : record.status === 'inactive' ? 'default' : 'error'"
              :text="record.status === 'active' ? '启用' : record.status === 'inactive' ? '停用' : '删除'"
            />
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

    <!-- 新增/编辑弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isEditMode ? '编辑数据批次' : '新增数据批次'"
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
          <a-col :span="8">
            <a-form-item label="数据批次 ID" name="batchId">
              <a-input
                v-model:value="formData.batchId"
                placeholder="请输入数据批次 ID"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="数据批次名称" name="batchName">
              <a-input
                v-model:value="formData.batchName"
                placeholder="请输入数据批次名称"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="批次所属机构名称" name="orgName">
              <a-input
                v-model:value="formData.orgName"
                placeholder="请输入批次所属机构名称"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="上传时间" name="uploadTime">
              <a-date-picker
                v-model:value="formData.uploadTime"
                placeholder="请选择上传时间"
                show-time
                style="width: 100%"
                format="YYYY-MM-DD HH:mm:ss"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="场景编号" name="sceneCode">
              <a-input
                v-model:value="formData.sceneCode"
                placeholder="请输入场景编号"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="场景名称" name="sceneName">
              <a-input
                v-model:value="formData.sceneName"
                placeholder="请输入场景名称"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="条线" name="line">
              <a-input
                v-model:value="formData.line"
                placeholder="请输入条线"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="任务 ID" name="taskId">
              <a-input
                v-model:value="formData.taskId"
                placeholder="请输入任务 ID"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="任务总数量" name="taskTotal">
              <a-input-number
                v-model:value="formData.taskTotal"
                placeholder="请输入任务总数量"
                style="width: 100%"
                :min="0"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="数据批次说明" name="batchDescription">
              <a-textarea
                v-model:value="formData.batchDescription"
                placeholder="请输入数据批次说明"
                :rows="2"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="场景所属机构" name="sceneOrg">
              <a-input
                v-model:value="formData.sceneOrg"
                placeholder="请输入场景所属机构"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="数据来源" name="dataSource">
              <a-select
                v-model:value="formData.dataSource"
                placeholder="请选择数据来源"
              >
                <a-select-option value="import">导入</a-select-option>
                <a-select-option value="manual">手动录入</a-select-option>
                <a-select-option value="api">API 接口</a-select-option>
                <a-select-option value="system">系统生成</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="批次类型" name="batchType">
              <a-select
                v-model:value="formData.batchType"
                placeholder="请选择批次类型"
              >
                <a-select-option value="import">导入</a-select-option>
                <a-select-option value="manual">手动</a-select-option>
                <a-select-option value="api">API</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="数据上传人员" name="uploadUser">
              <a-input
                v-model:value="formData.uploadUser"
                placeholder="请输入数据上传人员"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="数据总量" name="dataTotal">
              <a-input-number
                v-model:value="formData.dataTotal"
                placeholder="请输入数据总量"
                style="width: 100%"
                :min="0"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="去重后数据总量" name="uniqueDataTotal">
              <a-input-number
                v-model:value="formData.uniqueDataTotal"
                placeholder="请输入去重后数据总量"
                style="width: 100%"
                :min="0"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="已拨打数据量" name="calledDataTotal">
              <a-input-number
                v-model:value="formData.calledDataTotal"
                placeholder="请输入已拨打数据量"
                style="width: 100%"
                :min="0"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="联系方式类型" name="contactType">
              <a-select
                v-model:value="formData.contactType"
                placeholder="请选择联系方式类型"
              >
                <a-select-option value="phone">手机号</a-select-option>
                <a-select-option value="tel">固话</a-select-option>
                <a-select-option value="both">两者都有</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="上传状态" name="uploadStatus">
              <a-select
                v-model:value="formData.uploadStatus"
                placeholder="请选择上传状态"
              >
                <a-select-option value="success">上传成功</a-select-option>
                <a-select-option value="processing">上传中</a-select-option>
                <a-select-option value="failed">上传失败</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="开始拨打日期" name="startCallDate">
              <a-date-picker
                v-model:value="formData.startCallDate"
                placeholder="请选择开始拨打日期"
                show-time
                style="width: 100%"
                format="YYYY-MM-DD HH:mm:ss"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="结束拨打日期" name="endCallDate">
              <a-date-picker
                v-model:value="formData.endCallDate"
                placeholder="请选择结束拨打日期"
                show-time
                style="width: 100%"
                format="YYYY-MM-DD HH:mm:ss"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="8">
            <a-form-item label="免打扰名单数量" name="dncListTotal">
              <a-input-number
                v-model:value="formData.dncListTotal"
                placeholder="请输入免打扰名单数量"
                style="width: 100%"
                :min="0"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="防骚扰数量" name="antiHarassmentTotal">
              <a-input-number
                v-model:value="formData.antiHarassmentTotal"
                placeholder="请输入防骚扰数量"
                style="width: 100%"
                :min="0"
              />
            </a-form-item>
          </a-col>
          <a-col :span="8">
            <a-form-item label="状态" name="status">
              <a-select
                v-model:value="formData.status"
                placeholder="请选择状态"
              >
                <a-select-option value="active">启用</a-select-option>
                <a-select-option value="inactive">停用</a-select-option>
                <a-select-option value="deleted">删除</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>

    <!-- 查看详情弹窗 -->
    <a-modal
      v-model:open="viewModalVisible"
      title="数据批次详情"
      width="1200px"
      :footer="null"
    >
      <a-descriptions bordered :column="3">
        <a-descriptions-item label="数据批次 ID">
          {{ viewData.batchId }}
        </a-descriptions-item>
        <a-descriptions-item label="数据批次名称">
          {{ viewData.batchName }}
        </a-descriptions-item>
        <a-descriptions-item label="批次所属机构名称">
          {{ viewData.orgName }}
        </a-descriptions-item>
        <a-descriptions-item label="上传时间">
          {{ viewData.uploadTime }}
        </a-descriptions-item>
        <a-descriptions-item label="场景编号">
          {{ viewData.sceneCode }}
        </a-descriptions-item>
        <a-descriptions-item label="场景名称">
          {{ viewData.sceneName }}
        </a-descriptions-item>
        <a-descriptions-item label="条线">
          {{ viewData.line }}
        </a-descriptions-item>
        <a-descriptions-item label="任务 ID">
          {{ viewData.taskId }}
        </a-descriptions-item>
        <a-descriptions-item label="任务总数量">
          {{ viewData.taskTotal }}
        </a-descriptions-item>
        <a-descriptions-item label="数据批次说明" :span="3">
          {{ viewData.batchDescription || '-' }}
        </a-descriptions-item>
        <a-descriptions-item label="场景所属机构">
          {{ viewData.sceneOrg }}
        </a-descriptions-item>
        <a-descriptions-item label="数据来源">
          {{ viewData.dataSource }}
        </a-descriptions-item>
        <a-descriptions-item label="批次类型">
          {{ viewData.batchType }}
        </a-descriptions-item>
        <a-descriptions-item label="数据上传人员">
          {{ viewData.uploadUser }}
        </a-descriptions-item>
        <a-descriptions-item label="数据总量">
          {{ viewData.dataTotal }}
        </a-descriptions-item>
        <a-descriptions-item label="去重后数据总量">
          {{ viewData.uniqueDataTotal }}
        </a-descriptions-item>
        <a-descriptions-item label="已拨打数据量">
          {{ viewData.calledDataTotal }}
        </a-descriptions-item>
        <a-descriptions-item label="联系方式类型">
          {{ viewData.contactType }}
        </a-descriptions-item>
        <a-descriptions-item label="上传状态">
          {{ viewData.uploadStatus }}
        </a-descriptions-item>
        <a-descriptions-item label="开始拨打日期">
          {{ viewData.startCallDate }}
        </a-descriptions-item>
        <a-descriptions-item label="结束拨打日期">
          {{ viewData.endCallDate }}
        </a-descriptions-item>
        <a-descriptions-item label="免打扰名单数量">
          {{ viewData.dncListTotal }}
        </a-descriptions-item>
        <a-descriptions-item label="防骚扰数量">
          {{ viewData.antiHarassmentTotal }}
        </a-descriptions-item>
        <a-descriptions-item label="状态">
          {{ viewData.status }}
        </a-descriptions-item>
        <a-descriptions-item label="创建时间" :span="3">
          {{ viewData.createTime }}
        </a-descriptions-item>
        <a-descriptions-item label="更新时间" :span="3">
          {{ viewData.updateTime }}
        </a-descriptions-item>
      </a-descriptions>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import {
  SearchOutlined,
  PlusOutlined,
  DeleteOutlined,
  ExportOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnType } from 'ant-design-vue';
import { message, Modal } from 'ant-design-vue';

// 搜索表单
const searchForm = reactive({
  keyword: '',
  uploadStatus: '',
  batchType: '',
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
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `共 ${total} 条`,
});

// 表格列配置
const columns: TableColumnType[] = [
  {
    title: '序号',
    dataIndex: 'index',
    key: 'index',
    width: 60,
    align: 'center',
    fixed: 'left',
  },
  {
    title: '数据批次 ID',
    dataIndex: 'batchId',
    key: 'batchId',
    width: 140,
  },
  {
    title: '数据批次名称',
    dataIndex: 'batchName',
    key: 'batchName',
    width: 150,
    ellipsis: true,
  },
  {
    title: '批次所属机构名称',
    dataIndex: 'orgName',
    key: 'orgName',
    width: 150,
    ellipsis: true,
  },
  {
    title: '上传时间',
    dataIndex: 'uploadTime',
    key: 'uploadTime',
    width: 160,
  },
  {
    title: '场景编号',
    dataIndex: 'sceneCode',
    key: 'sceneCode',
    width: 120,
  },
  {
    title: '场景名称',
    dataIndex: 'sceneName',
    key: 'sceneName',
    width: 150,
    ellipsis: true,
  },
  {
    title: '条线',
    dataIndex: 'line',
    key: 'line',
    width: 100,
  },
  {
    title: '任务 ID',
    dataIndex: 'taskId',
    key: 'taskId',
    width: 120,
  },
  {
    title: '任务总数量',
    dataIndex: 'taskTotal',
    key: 'taskTotal',
    width: 100,
    align: 'center',
  },
  {
    title: '数据批次说明',
    dataIndex: 'batchDescription',
    key: 'batchDescription',
    width: 180,
    ellipsis: true,
  },
  {
    title: '场景所属机构',
    dataIndex: 'sceneOrg',
    key: 'sceneOrg',
    width: 150,
    ellipsis: true,
  },
  {
    title: '数据来源',
    dataIndex: 'dataSource',
    key: 'dataSource',
    width: 120,
  },
  {
    title: '批次类型',
    dataIndex: 'batchType',
    key: 'batchType',
    width: 100,
    align: 'center',
  },
  {
    title: '数据上传人员',
    dataIndex: 'uploadUser',
    key: 'uploadUser',
    width: 120,
  },
  {
    title: '数据总量',
    dataIndex: 'dataTotal',
    key: 'dataTotal',
    width: 100,
    align: 'center',
  },
  {
    title: '去重后数据总量',
    dataIndex: 'uniqueDataTotal',
    key: 'uniqueDataTotal',
    width: 120,
    align: 'center',
  },
  {
    title: '已拨打数据量',
    dataIndex: 'calledDataTotal',
    key: 'calledDataTotal',
    width: 120,
    align: 'center',
  },
  {
    title: '联系方式类型',
    dataIndex: 'contactType',
    key: 'contactType',
    width: 120,
  },
  {
    title: '上传状态',
    dataIndex: 'uploadStatus',
    key: 'uploadStatus',
    width: 100,
    align: 'center',
  },
  {
    title: '开始拨打日期',
    dataIndex: 'startCallDate',
    key: 'startCallDate',
    width: 160,
  },
  {
    title: '结束拨打日期',
    dataIndex: 'endCallDate',
    key: 'endCallDate',
    width: 160,
  },
  {
    title: '免打扰名单数量',
    dataIndex: 'dncListTotal',
    key: 'dncListTotal',
    width: 120,
    align: 'center',
  },
  {
    title: '防骚扰数量',
    dataIndex: 'antiHarassmentTotal',
    key: 'antiHarassmentTotal',
    width: 120,
    align: 'center',
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 80,
    align: 'center',
    fixed: 'right',
  },
];

// 弹窗控制
const modalVisible = ref(false);
const viewModalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);

// 表单数据
const formData = ref<any>({
  id: undefined,
  batchId: '',
  batchName: '',
  orgName: '',
  uploadTime: undefined,
  sceneCode: '',
  sceneName: '',
  line: '',
  taskId: '',
  taskTotal: 0,
  batchDescription: '',
  sceneOrg: '',
  dataSource: '',
  batchType: '',
  uploadUser: '',
  dataTotal: 0,
  uniqueDataTotal: 0,
  calledDataTotal: 0,
  contactType: '',
  uploadStatus: '',
  startCallDate: undefined,
  endCallDate: undefined,
  dncListTotal: 0,
  antiHarassmentTotal: 0,
  status: 'active',
});

// 查看详情数据
const viewData = ref<any>({
  customerList: [],
});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  batchId: [
    { required: true, message: '请输入数据批次 ID', trigger: 'blur' },
  ],
  batchName: [
    { required: true, message: '请输入数据批次名称', trigger: 'blur' },
  ],
  orgName: [
    { required: true, message: '请输入批次所属机构名称', trigger: 'blur' },
  ],
  sceneCode: [
    { required: true, message: '请输入场景编号', trigger: 'blur' },
  ],
  sceneName: [
    { required: true, message: '请输入场景名称', trigger: 'blur' },
  ],
  dataSource: [
    { required: true, message: '请选择数据来源', trigger: 'change' },
  ],
  batchType: [
    { required: true, message: '请选择批次类型', trigger: 'change' },
  ],
  uploadUser: [
    { required: true, message: '请输入数据上传人员', trigger: 'blur' },
  ],
  contactType: [
    { required: true, message: '请选择联系方式类型', trigger: 'change' },
  ],
  uploadStatus: [
    { required: true, message: '请选择上传状态', trigger: 'change' },
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' },
  ],
};

// 获取客群类型颜色
const getGroupTypeColor = (type: string) => {
  const colorMap: Record<string, string> = {
    high_value: 'red',
    potential: 'orange',
    common: 'blue',
    loss: 'gray',
  };
  return colorMap[type] || 'default';
};

// 获取客群类型名称
const getGroupTypeName = (type: string) => {
  const nameMap: Record<string, string> = {
    high_value: '高价值客群',
    potential: '潜力客群',
    common: '普通客群',
    loss: '流失客群',
  };
  return nameMap[type] || type;
};

// 加载数据
const loadData = () => {
  loading.value = true;
  // TODO: 调用后端 API 获取数据
  // 模拟数据
  setTimeout(() => {
    dataSource.value = Array.from({ length: 10 }, (_, index) => ({
      id: index + 1,
      index: index + 1,
      batchId: `BATCH${String(index + 1).padStart(8, '0')}`,
      batchName: `数据批次${index + 1}`,
      orgName: ['总行营业部', '北京分行', '上海分行', '广州分行'][index % 4],
      uploadTime: '2024-01-01 10:00:00',
      sceneCode: `SCENE${String(index + 1).padStart(4, '0')}`,
      sceneName: `场景${index + 1}`,
      line: ['个人金融', '公司业务', '信用卡'][index % 3],
      taskId: `TASK${String(index + 1).padStart(6, '0')}`,
      taskTotal: Math.floor(Math.random() * 10000) + 1000,
      batchDescription: `这是数据批次${index + 1}的说明信息`,
      sceneOrg: ['总行营业部', '北京分行', '上海分行', '广州分行'][index % 4],
      dataSource: ['import', 'manual', 'api', 'system'][index % 4],
      batchType: ['import', 'manual', 'api'][index % 3],
      uploadUser: `用户${index + 1}`,
      dataTotal: Math.floor(Math.random() * 10000) + 1000,
      uniqueDataTotal: Math.floor(Math.random() * 9000) + 900,
      calledDataTotal: Math.floor(Math.random() * 5000) + 500,
      contactType: ['phone', 'tel', 'both'][index % 3],
      uploadStatus: ['success', 'processing', 'failed'][index % 3],
      startCallDate: '2024-01-02 09:00:00',
      endCallDate: '2024-01-10 18:00:00',
      dncListTotal: Math.floor(Math.random() * 100),
      antiHarassmentTotal: Math.floor(Math.random() * 50),
      status: ['active', 'inactive', 'deleted'][index % 3],
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
  searchForm.uploadStatus = '';
  searchForm.batchType = '';
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

// 选择行变化
const onSelectChange = (keys: any[]) => {
  selectedRowKeys.value = keys;
};

// 新增
const handleAdd = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    batchId: '',
    batchName: '',
    orgName: '',
    uploadTime: undefined,
    sceneCode: '',
    sceneName: '',
    line: '',
    taskId: '',
    taskTotal: 0,
    batchDescription: '',
    sceneOrg: '',
    dataSource: '',
    batchType: '',
    uploadUser: '',
    dataTotal: 0,
    uniqueDataTotal: 0,
    calledDataTotal: 0,
    contactType: '',
    uploadStatus: '',
    startCallDate: undefined,
    endCallDate: undefined,
    dncListTotal: 0,
    antiHarassmentTotal: 0,
    status: 'active',
  };
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
  viewData.value = { ...record };
  viewModalVisible.value = true;
};

// 删除
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除数据批次"${record.batchName}"吗？`,
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

// 导出
const handleExport = () => {
  message.success('导出成功');
  // TODO: 调用后端 API 导出数据
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
.customer-group-management {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.table-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 4px;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid #f0f0f0;
}

.search-item {
  display: flex;
  align-items: center;
}

.search-buttons {
  gap: 8px;
}

.table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #f0f0f0;
}

.table-toolbar-left {
  display: flex;
  align-items: center;
}

.selection-info {
  color: #666;
  font-size: 14px;
}

.table-toolbar-right {
  display: flex;
  align-items: center;
}

.customer-list-section {
  margin-top: 16px;
}

.customer-list-section :deep(.ant-divider) {
  margin: 16px 0;
}
</style>
