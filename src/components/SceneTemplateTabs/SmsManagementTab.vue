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

    <!-- 新增/编辑短信弹窗 -->
    <a-modal
      v-model:open="smsModalVisible"
      :title="smsModalTitle"
      width="600px"
      :footer="null"
      @cancel="handleSmsModalCancel"
    >
      <a-form
        ref="smsFormRef"
        :model="smsForm"
        :rules="smsFormRules"
        layout="vertical"
      >
        <a-form-item label="短信名称" name="smsName">
          <a-input
            v-model:value="smsForm.smsName"
            placeholder="请输入短信名称"
            maxlength="50"
            show-count
          />
        </a-form-item>
        <a-form-item label="短信 CODE" name="smsCode">
          <a-input
            v-model:value="smsForm.smsCode"
            placeholder="请输入短信 CODE，如：SMS123456"
            maxlength="50"
          />
        </a-form-item>
        <a-form-item label="短信内容" name="smsContent">
          <a-textarea
            v-model:value="smsForm.smsContent"
            placeholder="请输入短信内容，支持变量如：${cust_name}、${sys.bank} 等"
            :rows="6"
            maxlength="500"
            show-count
          />
          <div class="form-tip">
            提示：可使用变量 ${cust_name}（客户姓名）、${sys.bank}（银行名称）等
          </div>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleSmsModalCancel">取消</a-button>
        <a-button type="primary" @click="handleSmsModalOk">
          <save-outlined />
          保存
        </a-button>
      </div>
    </a-modal>

    <!-- 导入模版弹窗 -->
    <a-modal
      v-model:open="importTemplateModalVisible"
      title="引用模版"
      width="900px"
      :footer="null"
      @cancel="handleImportTemplateModalCancel"
    >
      <div class="import-template-content">
        <!-- 搜索栏 -->
        <div class="import-template-search">
          <a-space>
            <a-input
              v-model:value="importTemplateNameFilter"
              placeholder="请输入模版名称"
              style="width: 200px"
              @press-enter="handleImportTemplateSearch"
            />
            <a-input
              v-model:value="importTemplateContentFilter"
              placeholder="请输入模版内容"
              style="width: 200px"
              @press-enter="handleImportTemplateSearch"
            />
            <a-button type="primary" @click="handleImportTemplateSearch">
              <search-outlined />
              搜索
            </a-button>
            <a-button @click="handleImportTemplateReset">
              <reload-outlined />
              重置
            </a-button>
          </a-space>
          <a class="go-to-sms-link" @click="handleGoToSmsManagement">
            未找到合适模版，去场景短信添加
          </a>
        </div>

        <!-- 已选提示 -->
        <div class="import-template-selected-info">
          共{{ templateListTotal }}条，已选{{ selectedTemplateIds.length }}条
        </div>

        <!-- 模版列表表格 -->
        <div class="import-template-table">
          <a-table
            :columns="templateColumns"
            :data-source="templateList"
            :pagination="false"
            row-key="id"
            size="middle"
            :scroll="{ y: 400 }"
            :row-selection="{
              selectedRowKeys: selectedTemplateIds,
              onChange: onTemplateSelectionChange,
            }"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'templateName'">
                <span class="template-name">{{ record.templateName }}</span>
              </template>
              <template v-if="column.key === 'templateCode'">
                <span class="template-code">{{ record.templateCode }}</span>
              </template>
              <template v-if="column.key === 'templateContent'">
                <span class="template-content-text">{{ record.templateContent }}</span>
              </template>
              <template v-if="column.key === 'modifyTime'">
                <span class="modify-time">{{ record.modifyTime }}</span>
              </template>
            </template>
          </a-table>
        </div>

        <!-- 分页 -->
        <div class="import-template-pagination">
          <a-pagination
            v-model:current="templatePagination.current"
            v-model:page-size="templatePagination.pageSize"
            :total="templatePagination.total"
            show-size-changer
            show-quick-jumper
            :show-total="(total: number) => `总共 ${total} 条`"
            :page-size-options="['10', '20', '50']"
            :locale="{
              items_per_page: '条/页',
              jump_to: '跳转至',
              page: '页',
            }"
            @change="handleTemplatePageChange"
            @show-size-change="handleTemplatePageSizeChange"
          />
        </div>

        <!-- 底部按钮 -->
        <div class="import-template-footer">
          <a-button @click="handleImportTemplateModalCancel">取消</a-button>
          <a-button type="primary" @click="handleImportTemplateConfirm">
            导入
          </a-button>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import { message } from 'ant-design-vue';
import type { FormInstance, Rule } from 'ant-design-vue/es/form';
import {
  SearchOutlined,
  PlusOutlined,
  UploadOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
  SaveOutlined,
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

interface TemplateItem {
  id: number;
  templateName: string;
  templateCode: string;
  templateContent: string;
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
  (e: 'import-sms-template', templates: TemplateItem[]): void;
  (e: 'create-sms', sms?: SmsItem): void;
  (e: 'edit-sms', sms: SmsItem): void;
  (e: 'delete-sms', sms: SmsItem): void;
  (e: 'save-sms', sms: SmsItem): void;
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
  {
    id: 126,
    smsName: '开场白介绍',
    smsCode: 'SMS002',
    smsContent: '您好，这里是${sys.bank}，来电是想邀请您参加我们最新的活动，您可以登录我们官网进查看活动详情。',
    modifyTime: '2024-12-31 14:26:04',
  },
]);

// 短信分页
const smsPagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 2,
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
const smsTotal = ref(2);

// 新增/编辑短信弹窗
const smsModalVisible = ref(false);
const smsModalTitle = ref('新增短信');
const smsFormRef = ref<FormInstance>();
const smsForm = reactive({
  id: 0,
  smsName: '',
  smsCode: '',
  smsContent: '',
});

const smsFormRules: Record<string, Rule[]> = {
  smsName: [
    { required: true, message: '请输入短信名称', trigger: 'blur' },
    { max: 50, message: '短信名称不能超过 50 个字符', trigger: 'blur' },
  ],
  smsCode: [
    { required: true, message: '请输入短信 CODE', trigger: 'blur' },
    { max: 50, message: '短信 CODE 不能超过 50 个字符', trigger: 'blur' },
  ],
  smsContent: [
    { required: true, message: '请输入短信内容', trigger: 'blur' },
    { max: 500, message: '短信内容不能超过 500 个字符', trigger: 'blur' },
  ],
};

// 导入模版弹窗
const importTemplateModalVisible = ref(false);
const importTemplateNameFilter = ref('');
const importTemplateContentFilter = ref('');

// 模版列表数据（模拟数据）
const templateList = ref<TemplateItem[]>([
  {
    id: 1,
    templateName: '43',
    templateCode: '34',
    templateContent: '今天${cust_name},在 Java8 中，CompletableFuture 提供了非常强大的 Future 的扩展功能，可以帮助我们简化异步编程的复杂性，并且提供了函数式编程的能力，可以通过回调的方式处理计算结果，也提供了转换和组合 CompletableFuture 的方法。',
    modifyTime: '2024-07-12 10:01:54',
  },
  {
    id: 2,
    templateName: '场景通用模板 1',
    templateCode: '123',
    templateContent: 'hi，方服务',
    modifyTime: '2024-07-12 17:00:02',
  },
  {
    id: 3,
    templateName: '测试',
    templateCode: '123',
    templateContent: '测试短信',
    modifyTime: '2024-09-09 10:33:41',
  },
  {
    id: 4,
    templateName: '通用模板',
    templateCode: 'SMS122123',
    templateContent: '这是一个短信',
    modifyTime: '2024-11-04 16:47:56',
  },
  {
    id: 5,
    templateName: '开场白介绍',
    templateCode: 'SMS002',
    templateContent: '您好，这里是${sys.bank}，来电是想邀请您参加我们最新的活动，您可以登录我们官网进查看活动详情。',
    modifyTime: '2024-12-31 14:26:04',
  },
  {
    id: 6,
    templateName: '恒丰银行 POC',
    templateCode: '恒丰银行 POC',
    templateContent: '【poc 短信】：恒丰银行代销理财新恒梦钱包 5 号 G 理财产品，1 元起购，低风险，申赎灵活，收益表现突出，详见 https://XXXXXX。理财非存款，产品有风险，投资须谨慎。详询 95395，拒收请回复 R',
    modifyTime: '2025-06-18 16:10:46',
  },
]);

// 模版分页
const templatePagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 6,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `总共 ${total} 条`,
  pageSizeOptions: ['10', '20', '50'],
  locale: {
    items_per_page: '条/页',
    jump_to: '跳转至',
    page: '页',
  },
});

// 模版总数
const templateListTotal = ref(6);

// 已选择的模版 ID 列表
const selectedTemplateIds = ref<number[]>([]);

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

// 导入模版表格列配置
const templateColumns: TableColumnsType = [
  {
    title: '',
    key: 'checkbox',
    width: 50,
  },
  {
    title: '模版名称',
    dataIndex: 'templateName',
    key: 'templateName',
    width: 120,
  },
  {
    title: '模版 CODE',
    dataIndex: 'templateCode',
    key: 'templateCode',
    width: 120,
  },
  {
    title: '模版内容',
    dataIndex: 'templateContent',
    key: 'templateContent',
    width: 500,
    ellipsis: true,
  },
  {
    title: '最后一次修改时间',
    dataIndex: 'modifyTime',
    key: 'modifyTime',
    width: 160,
    sorter: true,
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
  selectedTemplateIds.value = [];
  importTemplateNameFilter.value = '';
  importTemplateContentFilter.value = '';
  importTemplateModalVisible.value = true;
};

// 新建短信
const handleCreateSms = () => {
  smsModalTitle.value = '新增短信';
  smsForm.id = 0;
  smsForm.smsName = '';
  smsForm.smsCode = '';
  smsForm.smsContent = '';
  smsModalVisible.value = true;
};

// 编辑短信
const handleEditSms = (record: SmsItem) => {
  smsModalTitle.value = '编辑短信';
  smsForm.id = record.id;
  smsForm.smsName = record.smsName;
  smsForm.smsCode = record.smsCode;
  smsForm.smsContent = record.smsContent;
  smsModalVisible.value = true;
};

// 删除短信
const handleDeleteSms = (record: SmsItem) => {
  const index = smsList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    smsList.value.splice(index, 1);
    smsTotal.value = smsList.value.length;
    message.success('删除短信成功');
  }
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

// 短信弹窗取消
const handleSmsModalCancel = () => {
  smsModalVisible.value = false;
  smsFormRef.value?.resetFields();
};

// 短信弹窗确认
const handleSmsModalOk = async () => {
  try {
    await smsFormRef.value?.validate();
    const smsData: SmsItem = {
      id: smsForm.id || Date.now(),
      smsName: smsForm.smsName,
      smsCode: smsForm.smsCode,
      smsContent: smsForm.smsContent,
      modifyTime: new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      }).replace(/\//g, '-'),
    };

    if (smsForm.id === 0) {
      // 新增
      smsList.value.push(smsData);
      smsTotal.value = smsList.value.length;
      message.success('新增短信成功');
    } else {
      // 编辑
      const index = smsList.value.findIndex(item => item.id === smsForm.id);
      if (index !== -1) {
        smsList.value[index] = smsData;
        message.success('编辑短信成功');
      }
    }

    smsModalVisible.value = false;
    smsFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 导入模版搜索
const handleImportTemplateSearch = () => {
  console.log('导入模版搜索:', importTemplateNameFilter.value, importTemplateContentFilter.value);
  // TODO: 实现搜索逻辑
};

// 导入模版重置
const handleImportTemplateReset = () => {
  importTemplateNameFilter.value = '';
  importTemplateContentFilter.value = '';
  handleImportTemplateSearch();
};

// 去场景短信管理
const handleGoToSmsManagement = () => {
  console.log('去场景短信管理');
  // TODO: 跳转到场景短信管理页面
};

// 模版选择变化
const onTemplateSelectionChange = (selectedRowKeys: (string | number)[]) => {
  selectedTemplateIds.value = selectedRowKeys as number[];
};

// 导入模版分页变化
const handleTemplatePageChange = (page: number, pageSize: number) => {
  console.log('模版分页变化:', page, pageSize);
};

// 模版每页条数变化
const handleTemplatePageSizeChange = (current: number, size: number) => {
  console.log('模版每页条数变化:', current, size);
};

// 导入模版弹窗取消
const handleImportTemplateModalCancel = () => {
  importTemplateModalVisible.value = false;
  selectedTemplateIds.value = [];
};

// 导入模版确认
const handleImportTemplateConfirm = () => {
  if (selectedTemplateIds.value.length === 0) {
    message.warning('请至少选择一个模版');
    return;
  }

  const selectedTemplates = templateList.value.filter(t =>
    selectedTemplateIds.value.includes(t.id)
  );

  console.log('导入的模版:', selectedTemplates);
  emit('import-sms-template', selectedTemplates);

  // 将选中的模版添加到短信列表中
  selectedTemplates.forEach(template => {
    const exists = smsList.value.some(s => smsList.value.some(s => s.smsCode === template.templateCode));
    if (!exists) {
      smsList.value.push({
        id: Date.now() + template.id,
        smsName: template.templateName,
        smsCode: template.templateCode,
        smsContent: template.templateContent,
        modifyTime: template.modifyTime,
      });
    }
  });

  smsTotal.value = smsList.value.length;
  message.success(`成功导入 ${selectedTemplates.length} 个模版`);
  importTemplateModalVisible.value = false;
  selectedTemplateIds.value = [];
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

/* 弹窗底部按钮 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
}

.form-tip {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
}

/* ==================== 导入模版弹窗样式 ==================== */
.import-template-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.import-template-search {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
}

.go-to-sms-link {
  color: #1890ff;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s;
}

.go-to-sms-link:hover {
  color: #40a9ff;
}

.import-template-selected-info {
  font-size: 13px;
  color: #595959;
}

.import-template-table {
  border: 1px solid #f0f0f0;
  border-radius: 4px;
}

.import-template-table :deep(.ant-table) {
  font-size: 13px;
}

.import-template-table :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
}

.template-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

.template-code {
  font-size: 13px;
  color: #595959;
  font-family: monospace;
}

.template-content-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
}

.import-template-pagination {
  display: flex;
  justify-content: flex-end;
  padding: 8px 0;
}

.import-template-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}
</style>
