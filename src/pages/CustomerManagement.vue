<template>
  <div class="customer-management">
    <!-- 表格区域 -->
    <div class="table-area">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <div class="search-item">
          <a-input
            v-model:value="searchForm.keyword"
            placeholder="请输入客户号/客户名称/联系方式"
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
            v-model:value="searchForm.bankOrgCode"
            placeholder="请选择银行机构"
            allow-clear
            style="width: 200px"
          >
            <a-select-option value="org001">总行营业部</a-select-option>
            <a-select-option value="org002">北京分行</a-select-option>
            <a-select-option value="org003">上海分行</a-select-option>
            <a-select-option value="org004">广州分行</a-select-option>
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
            新增客户
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
        :scroll="{ x: 1600 }"
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
      :title="isEditMode ? '编辑客户' : '新增客户'"
      width="700px"
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
                placeholder="请输入联系方式"
                :maxlength="11"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="银行机构号" name="bankOrgCode">
              <a-select
                v-model:value="formData.bankOrgCode"
                placeholder="请选择银行机构"
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
            <a-form-item label="机构名称" name="orgName">
              <a-input
                v-model:value="formData.orgName"
                placeholder="请输入机构名称"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="直营坐席工号" name="seatNo">
              <a-input
                v-model:value="formData.seatNo"
                placeholder="请输入直营坐席工号"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="标签" name="tags">
              <a-select
                v-model:value="formData.tags"
                mode="multiple"
                placeholder="请选择标签"
                style="width: 100%"
                allow-clear
              >
                <a-select-option value="vip">VIP 客户</a-select-option>
                <a-select-option value="potential">潜力客户</a-select-option>
                <a-select-option value="high_value">高价值客户</a-select-option>
                <a-select-option value="new">新客户</a-select-option>
                <a-select-option value="loss_risk">流失风险</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="备注" name="remark">
          <a-textarea
            v-model:value="formData.remark"
            placeholder="请输入备注信息"
            :rows="3"
          />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 查看详情弹窗 -->
    <a-modal
      v-model:open="viewModalVisible"
      title="客户详情"
      width="700px"
      :footer="null"
    >
      <a-descriptions bordered :column="2">
        <a-descriptions-item label="客户号">
          {{ viewData.customerNo }}
        </a-descriptions-item>
        <a-descriptions-item label="客户名称">
          {{ viewData.customerName }}
        </a-descriptions-item>
        <a-descriptions-item label="性别">
          {{ viewData.gender }}
        </a-descriptions-item>
        <a-descriptions-item label="联系方式">
          {{ viewData.phone }}
        </a-descriptions-item>
        <a-descriptions-item label="银行机构号">
          {{ viewData.bankOrgCode }}
        </a-descriptions-item>
        <a-descriptions-item label="机构名称">
          {{ viewData.orgName }}
        </a-descriptions-item>
        <a-descriptions-item label="直营坐席工号">
          {{ viewData.seatNo }}
        </a-descriptions-item>
        <a-descriptions-item label="标签">
          <div class="tags-container">
            <a-tag
              v-for="(tag, index) in viewData.tagsArray"
              :key="index"
              color="processing"
            >
              {{ tag }}
            </a-tag>
          </div>
        </a-descriptions-item>
        <a-descriptions-item label="备注" :span="2">
          {{ viewData.remark || '-' }}
        </a-descriptions-item>
        <a-descriptions-item label="创建时间" :span="2">
          {{ viewData.createTime }}
        </a-descriptions-item>
        <a-descriptions-item label="更新时间" :span="2">
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
  bankOrgCode: '',
});

// 表格数据
const dataSource = ref<any[]>([]);
const total = ref(0);
const loading = ref(false);

// 选中的行
const selectedRowKeys = ref<reactive[]>([]);

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
const viewModalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);

// 表单数据
const formData = ref<any>({
  id: undefined,
  customerNo: '',
  customerName: '',
  gender: '',
  phone: '',
  bankOrgCode: '',
  orgName: '',
  seatNo: '',
  tags: [],
  remark: '',
});

// 查看详情数据
const viewData = ref<any>({});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  customerNo: [
    { required: true, message: '请输入客户号', trigger: 'blur' },
  ],
  customerName: [
    { required: true, message: '请输入客户名称', trigger: 'blur' },
  ],
  gender: [
    { required: true, message: '请选择性别', trigger: 'change' },
  ],
  phone: [
    { required: true, message: '请输入联系方式', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' },
  ],
  bankOrgCode: [
    { required: true, message: '请选择银行机构', trigger: 'change' },
  ],
  orgName: [
    { required: true, message: '请输入机构名称', trigger: 'blur' },
  ],
  seatNo: [
    { required: true, message: '请输入直营坐席工号', trigger: 'blur' },
  ],
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
  searchForm.bankOrgCode = '';
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
const onSelectChange = (selectedRowKeys: any[]) => {
  selectedRowKeys.value = selectedRowKeys;
};

// 新增
const handleAdd = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    customerNo: '',
    customerName: '',
    gender: '',
    phone: '',
    bankOrgCode: '',
    orgName: '',
    seatNo: '',
    tags: [],
    remark: '',
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
.customer-management {
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

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
</style>
