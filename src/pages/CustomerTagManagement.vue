<template>
  <div class="customer-tag-management">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">客户标签管理</h2>
            <p class="page-description">管理客户标签字段，定义标签类型和字典值。</p>
          </div>
          <div class="header-right">
            <a-button type="primary" @click="handleAdd">
              <plus-outlined />
              新增标签
            </a-button>
          </div>
        </div>
      </div>

      <!-- 搜索区域和表格区域合并 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-space :size="16">
            <a-input
              v-model:value="searchForm.fieldName"
              placeholder="请输入标签名称"
              allow-clear
              @press-enter="handleSearch"
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
          <!-- 表格包装器 -->
          <div class="table-wrapper">
            <a-table
              :columns="columns"
              :data-source="dataSource"
              :pagination="false"
              row-key="id"
              :loading="loading"
              :scroll="{ x: 1200 }"
              @change="handleTableChange"
            >
              <template #bodyCell="{ column, record }">
                <!-- 字段类型列 -->
                <template v-if="column.key === 'fieldType'">
                  <span>
                    {{ record.fieldType === 'text' ? '文本输入' : record.fieldType === 'single' ? '单选' : '多选' }}
                  </span>
                </template>
                <!-- 是否必填列 -->
                <template v-else-if="column.key === 'required'">
                  <span>{{ record.required ? '是' : '否' }}</span>
                </template>
                <!-- 字典列 -->
                <template v-else-if="column.key === 'dictionary'">
                  <div class="tags-container" v-if="record.dictionary && record.dictionary.length > 0">
                    <a-tag
                      v-for="(tag, index) in record.dictionary"
                      :key="index"
                      color="processing"
                    >
                      {{ tag }}
                    </a-tag>
                  </div>
                  <span v-else style="color: #999;">-</span>
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
      :title="isEditMode ? '编辑标签' : '新增标签'"
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
            <a-form-item label="标签名称" name="fieldName">
              <a-input
                v-model:value="formData.fieldName"
                placeholder="请输入标签名称"
              />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="标签提示" name="fieldTip">
              <a-input
                v-model:value="formData.fieldTip"
                placeholder="请输入标签提示"
              />
            </a-form-item>
          </a-col>
        </a-row>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="标签类型" name="fieldType">
              <a-select
                v-model:value="formData.fieldType"
                placeholder="请选择标签类型"
                @change="handleFieldTypeChange"
              >
                <a-select-option value="text">文本输入</a-select-option>
                <a-select-option value="single">单选</a-select-option>
                <a-select-option value="multiple">多选</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item
          label="字典"
          name="dictionary"
          v-if="formData.fieldType === 'single' || formData.fieldType === 'multiple'"
        >
          <a-select
            v-model:value="formData.dictionary"
            mode="tags"
            placeholder="请输入字典值，按回车确认"
            style="width: 100%"
            :max-tag-count="5"
          >
          </a-select>
          <div class="form-tip">
            单选/多选标签需要设置字典值，每行一个选项，按回车确认
          </div>
        </a-form-item>
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
  ReloadOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnType } from 'ant-design-vue';
import { message, Modal } from 'ant-design-vue';
import Pagination from '@/components/Pagination';

const router = useRouter();

// 搜索表单
const searchForm = reactive({
  fieldName: '',
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
    title: '标签名称',
    dataIndex: 'fieldName',
    key: 'fieldName',
    width: 150,
    ellipsis: true,
  },
  {
    title: '标签提示',
    dataIndex: 'fieldTip',
    key: 'fieldTip',
    width: 150,
    ellipsis: true,
  },
  {
    title: '标签类型',
    dataIndex: 'fieldType',
    key: 'fieldType',
    width: 100,
  },
  {
    title: '字典',
    dataIndex: 'dictionary',
    key: 'dictionary',
    width: 500,
  },
  {
    title: '最后修改时间',
    dataIndex: 'updateTime',
    key: 'updateTime',
    width: 180,
    sorter: true,
  },
  {
    title: '操作',
    dataIndex: 'action',
    key: 'action',
    width: 120,
    align: 'center',
    fixed: 'right',
  },
];

// 弹窗控制
const modalVisible = ref(false);
const isEditMode = ref(false);
const modalConfirmLoading = ref(false);

// 表单数据
const formData = ref<any>({
  id: undefined,
  fieldName: '',
  fieldTip: '',
  fieldType: 'text',
  dictionary: [] as string[],
});

// 表单引用
const formRef = ref<any>();

// 表单验证规则
const formRules = {
  fieldName: [
    { required: true, message: '请输入标签名称', trigger: 'blur' },
  ],
  fieldTip: [
    { required: true, message: '请输入标签提示', trigger: 'blur' },
  ],
  fieldType: [
    { required: true, message: '请选择标签类型', trigger: 'change' },
  ],
};

// 字段类型变化
const handleFieldTypeChange = (value: string) => {
  if (value === 'text') {
    formData.value.dictionary = [];
  }
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
        fieldName: '客户等级',
        fieldTip: '请选择客户等级',
        fieldType: 'single',
        dictionary: ['VIP 客户', '高价值客户', '潜力客户', '普通客户', '流失风险'],
        updateTime: '2025-04-16 17:13:51',
      },
      {
        id: 2,
        fieldName: '跟进状态',
        fieldTip: '请选择跟进状态',
        fieldType: 'multiple',
        dictionary: ['会到网点', '办理中', '再联系', '已联系', '考虑中', '已加微信', '已拒绝', '不符合条件', '已办理过'],
        updateTime: '2025-04-15 14:30:22',
      },
      {
        id: 3,
        fieldName: '风险等级',
        fieldTip: '请选择风险等级',
        fieldType: 'single',
        dictionary: ['高风险', '中风险', '低风险', '无风险'],
        updateTime: '2025-04-10 09:15:33',
      },
      {
        id: 4,
        fieldName: '产品意向',
        fieldTip: '请选择产品意向',
        fieldType: 'multiple',
        dictionary: ['存款', '贷款', '理财', '保险', '基金', '信用卡'],
        updateTime: '2025-04-08 16:45:12',
      },
      {
        id: 5,
        fieldName: '备注说明',
        fieldTip: '请输入备注说明',
        fieldType: 'text',
        dictionary: [],
        updateTime: '2025-04-05 11:20:45',
      },
      {
        id: 6,
        fieldName: '联系偏好',
        fieldTip: '请选择联系偏好',
        fieldType: 'single',
        dictionary: ['电话', '短信', '微信', '邮件', '上门'],
        updateTime: '2025-04-01 10:00:00',
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
  searchForm.fieldName = '';
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

// 新增
const handleAdd = () => {
  isEditMode.value = false;
  formData.value = {
    id: undefined,
    fieldName: '',
    fieldTip: '',
    fieldType: 'text',
    dictionary: [],
  };
  modalVisible.value = true;
};

// 编辑
const handleEdit = (record: any) => {
  isEditMode.value = true;
  formData.value = {
    ...record,
    dictionary: record.dictionary || [],
  };
  modalVisible.value = true;
};

// 删除
const handleDelete = (record: any) => {
  Modal.confirm({
    title: '确认删除',
    content: `确定要删除标签"${record.fieldName}"吗？`,
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
      message.success(isEditMode.value ? '修改成功' : '新增成功');
      modalVisible.value = false;
      modalConfirmLoading.value = false;
      loadData();
    }, 500);
  }).catch(() => {
    // 验证失败
  });
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.customer-tag-management {
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
  height: 32px;
  padding: 4px 15px;
  font-size: 14px;
}

/* 搜索区域和表格区域 */
.search-and-table-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  margin: 16px;
  border-radius: 4px;
  padding: 24px;
  overflow: auto;
}

.search-area {
  margin-bottom: 16px;
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

.table-wrapper :deep(.ant-table-thead > tr > th) {
  white-space: nowrap;
}

.table-wrapper :deep(.ant-table-tbody > tr > td) {
  white-space: nowrap;
}

.table-wrapper :deep(.ant-table-tbody > tr > td:last-child) {
  white-space: nowrap;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

/* 分页 */
.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.form-tip {
  margin-top: 4px;
  font-size: 12px;
  color: #999;
}
</style>
