<template>
  <div class="sms-content">
    <div class="sms-scroll-wrapper">
      <!-- 顶部操作区 -->
      <div class="sms-toolbar-section">
        <div class="sms-toolbar-left">
          <a-space>
            <a-input
              v-model:value="smsTemplateNameFilter"
              placeholder="请输入模版名称"
              style="width: 200px"
              @press-enter="handleSmsSearch"
            >
              <template #prefix>
                <search-outlined />
              </template>
            </a-input>
            <a-input
              v-model:value="smsContentFilter"
              placeholder="请输入短信内容"
              style="width: 200px"
              @press-enter="handleSmsSearch"
            >
              <template #prefix>
                <search-outlined />
              </template>
            </a-input>
            <a-button type="primary" @click="handleSmsSearch">
              <search-outlined />
              搜索
            </a-button>
            <a-button @click="handleSmsReset">
              <reload-outlined />
              重置
            </a-button>
          </a-space>
        </div>
        <div class="sms-toolbar-right">
          <a-space>
            <a-button type="primary" @click="handleImportSmsTemplate">
              <upload-outlined />
              导入模版
            </a-button>
            <a-button type="primary" @click="handleCreateSms">
              <plus-outlined />
              新增短信
            </a-button>
          </a-space>
        </div>
      </div>

      <!-- 数据表格 -->
      <div class="sms-list">
        <div class="sms-table-wrapper">
          <a-table
            :columns="smsColumns"
            :data-source="smsList"
            :pagination="false"
            row-key="id"
            size="middle"
            @change="handleSmsTableChange"
            :scroll="{ x: 1200 }"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'id'">
                <span>{{ record.id }}</span>
              </template>
              <template v-if="column.key === 'smsName'">
                <span class="sms-name">{{ record.smsName }}</span>
              </template>
              <template v-if="column.key === 'smsCode'">
                <span class="sms-code">{{ record.smsCode }}</span>
              </template>
              <template v-if="column.key === 'smsContent'">
                <span class="sms-content-text">{{ record.smsContent }}</span>
              </template>
              <template v-if="column.key === 'modifyTime'">
                <span class="modify-time">{{ record.modifyTime }}</span>
              </template>
              <template v-if="column.key === 'action'">
                <a-space :size="8">
                  <a-button type="link" size="small" @click="handleEditSms(record)">
                    <edit-outlined />
                    编辑
                  </a-button>
                  <a-popconfirm
                    title="确定删除该短信？"
                    ok-text="确定"
                    cancel-text="取消"
                    @confirm="handleDeleteSms(record)"
                  >
                    <a-button type="link" size="small" danger>
                      <delete-outlined />
                      删除
                    </a-button>
                  </a-popconfirm>
                </a-space>
              </template>
            </template>
          </a-table>
        </div>
        <!-- 分页 -->
        <div class="sms-pagination">
          <span class="total-text">总共 {{ smsTotal }} 条</span>
          <a-pagination
            v-model:current="smsPagination.current"
            v-model:page-size="smsPagination.pageSize"
            :total="smsPagination.total"
            show-size-changer
            show-quick-jumper
            :show-total="(total: number) => `共 ${total} 条`"
            :page-size-options="['10', '20', '50']"
            :locale="{
              items_per_page: '条/页',
              jump_to: '跳转至',
              page: '页',
            }"
            @change="handleSmsPageChange"
            @show-size-change="handleSmsPageSizeChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import {
  SearchOutlined,
  PlusOutlined,
  UploadOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnsType, TablePaginationConfig } from 'ant-design-vue';

// ==================== 接口定义 ====================
interface SmsItem {
  id: number;
  smsName: string;
  smsCode: string;
  smsContent: string;
  modifyTime: string;
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: number;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: number): void;
  (e: 'sms-search', nameFilter: string, contentFilter: string): void;
  (e: 'sms-reset'): void;
  (e: 'import-sms-template'): void;
  (e: 'create-sms'): void;
  (e: 'edit-sms', sms: SmsItem): void;
  (e: 'delete-sms', sms: SmsItem): void;
}>();

// ==================== 响应式数据 ====================
// 短信模版名称筛选
const smsTemplateNameFilter = ref('');

// 短信内容筛选
const smsContentFilter = ref('');

// 短信列表数据（模拟数据）
const smsList = ref<SmsItem[]>([
  {
    id: 125,
    smsName: '挂机短信',
    smsCode: 'SMS122123',
    smsContent: '这是挂机短信',
    modifyTime: '2026-03-11 16:22:37',
  },
]);

// 短信分页
const smsPagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 1,
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

// 短信总数
const smsTotal = ref(1);

// 短信表格列配置
const smsColumns: TableColumnsType = [
  {
    title: '短信 ID',
    dataIndex: 'id',
    key: 'id',
    width: 80,
  },
  {
    title: '短信名称',
    dataIndex: 'smsName',
    key: 'smsName',
    width: 120,
  },
  {
    title: '短信 CODE',
    dataIndex: 'smsCode',
    key: 'smsCode',
    width: 120,
  },
  {
    title: '短信内容',
    dataIndex: 'smsContent',
    key: 'smsContent',
    width: 300,
    ellipsis: true,
  },
  {
    title: '最后一次修改时间',
    dataIndex: 'modifyTime',
    key: 'modifyTime',
    width: 160,
    sorter: true,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    fixed: 'right' as const,
  },
];

// ==================== 方法 ====================
// 短信搜索
const handleSmsSearch = () => {
  emit('sms-search', smsTemplateNameFilter.value, smsContentFilter.value);
};

// 短信重置
const handleSmsReset = () => {
  smsTemplateNameFilter.value = '';
  smsContentFilter.value = '';
  emit('sms-reset');
};

// 导入短信模版
const handleImportSmsTemplate = () => {
  emit('import-sms-template');
};

// 新建短信
const handleCreateSms = () => {
  emit('create-sms');
};

// 编辑短信
const handleEditSms = (record: SmsItem) => {
  emit('edit-sms', record);
};

// 删除短信
const handleDeleteSms = (record: SmsItem) => {
  emit('delete-sms', record);
};

// 短信表格变化
const handleSmsTableChange = (pagination: TablePaginationConfig) => {
  smsPagination.current = pagination.current;
  smsPagination.pageSize = pagination.pageSize;
  smsPagination.total = pagination.total;
};

// 短信分页变化
const handleSmsPageChange = (page: number, pageSize: number) => {
  console.log('短信分页变化:', page, pageSize);
};

// 短信每页条数变化
const handleSmsPageSizeChange = (current: number, size: number) => {
  console.log('短信每页条数变化:', current, size);
};
</script>

<style scoped>
/* 场景短信内容区域 */
.sms-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  padding: 0;
}

.sms-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
  width: 100%;
}

/* 顶部操作区 */
.sms-toolbar-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-shrink: 0;
  width: 100%;
}

.sms-toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sms-toolbar-right {
  display: flex;
  align-items: center;
}

/* 短信列表 */
.sms-list {
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  flex: 1;
  overflow: hidden;
}

.sms-table-wrapper {
  flex: 1;
  overflow: auto;
  padding: 16px 24px;
}

.sms-table-wrapper :deep(.ant-table) {
  font-size: 13px;
}

.sms-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
}

.sms-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

.sms-code {
  font-size: 13px;
  color: #595959;
  font-family: monospace;
}

.sms-content-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
}

.modify-time {
  font-size: 13px;
  color: #8c8c8c;
}

/* 分页区域 */
.sms-pagination {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 16px;
}

.sms-pagination .total-text {
  font-size: 14px;
  color: #595959;
}

/* 短信滚动条样式 */
.sms-list::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.sms-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.sms-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 4px;
}

.sms-list::-webkit-scrollbar-thumb:hover {
  background: #999;
}
</style>
