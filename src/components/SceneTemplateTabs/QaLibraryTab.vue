<template>
  <div class="qa-content">
    <div class="qa-scroll-wrapper">
      <!-- 顶部操作区 -->
      <div class="toolbar-section qa-toolbar">
        <div class="toolbar-left">
          <a-space>
            <a-select
              v-model:value="qaTypeFilter"
              placeholder="全部"
              style="width: 150px"
              allow-clear
              @change="handleQaTypeChange"
            >
              <a-select-option value="all">全部</a-select-option>
              <a-select-option value="scene">场景 QA</a-select-option>
              <a-select-option value="industry">行业 QA</a-select-option>
              <a-select-option value="common">通用 QA</a-select-option>
            </a-select>
            <a-input
              v-model:value="searchKeyword"
              placeholder="请输入问题关键词搜索"
              style="width: 280px"
              @press-enter="handleSearch"
            >
              <template #prefix>
                <search-outlined />
              </template>
            </a-input>
            <a-button type="primary" @click="handleSearch">搜索</a-button>
            <a-button @click="handleReset">重置</a-button>
          </a-space>
        </div>
        <div class="toolbar-right">
          <a-space>
            <a-button type="primary" class="create-scene-qa-btn" @click="handleCreateQa">
              <plus-outlined />
              新建场景 QA
            </a-button>
            <a-dropdown trigger="click">
              <a-button class="reference-qa-btn" @click="handleReferenceQa">
                <link-outlined />
                引用通用/行业 QA
              </a-button>
            </a-dropdown>
            <a-button @click="handleExceptionCheck">
              <warning-outlined />
              异常检测
            </a-button>
            <a-button class="operation-guide-btn" @click="showQaGuide">
              <question-circle-outlined />
              操作引导
            </a-button>
          </a-space>
        </div>
      </div>

      <!-- QA 卡片列表 -->
      <div class="qa-list">
        <div
          v-for="qa in qaList"
          :key="qa.id"
          class="qa-card"
        >
          <!-- 卡片头部 -->
          <div class="qa-card-header">
            <div class="header-left">
              <span class="qa-id">ID: {{ qa.id }}</span>
              <span class="qa-question">{{ qa.question }}</span>
              <a-tag :color="getQaTypeColor(qa.qaType)">{{ qa.qaType }}</a-tag>
              <span class="qa-process">后续流程：{{ qa.followProcess }}</span>
              <a-tag :color="qa.intentType === '正向' ? 'green' : 'red'">
                {{ qa.intentType }}
              </a-tag>
            </div>
            <div class="header-right">
              <a-space>
                <a-button
                  v-if="qa.qaType === '场景 QA'"
                  type="link"
                  size="small"
                  class="add-user-question-btn"
                  @click="handleAddUserQuestion(qa)"
                >
                  <message-outlined />
                  添加用户问法
                </a-button>
                <a-button type="link" size="small" class="add-reply-btn" @click="handleAddReply(qa)">
                  <plus-outlined />
                  新增回复
                </a-button>
                <a-popconfirm
                  title="确定删除该 QA？"
                  ok-text="确定"
                  cancel-text="取消"
                  @confirm="handleDeleteQa(qa)"
                >
                  <a-button type="link" size="small" class="delete-qa-btn">
                    <delete-outlined />
                    删除 QA
                  </a-button>
                </a-popconfirm>
              </a-space>
            </div>
          </div>

          <!-- 回复列表表格 -->
          <div class="reply-table-wrapper">
            <a-table
              :columns="replyColumns"
              :data-source="qa.replies"
              :pagination="false"
              row-key="id"
              size="small"
              :scroll="{ x: 1000 }"
            >
              <template #bodyCell="{ column, record, index }">
                <template v-if="column.key === 'index'">
                  <span>{{ index + 1 }}</span>
                </template>
                <template v-if="column.key === 'replyText'">
                  <span class="reply-text">{{ record.replyText }}</span>
                </template>
                <template v-if="column.key === 'scene'">
                  <span class="scene-text">{{ record.scene }}</span>
                </template>
                <template v-if="column.key === 'action'">
                  <a-space>
                    <a class="action-link" @click="handleEditReply(record)">编辑</a>
                    <a-popconfirm
                      title="确定删除该回复？"
                      ok-text="确定"
                      cancel-text="取消"
                      @confirm="handleDeleteReply(record, qa)"
                    >
                      <a class="action-link delete-link">删除</a>
                    </a-popconfirm>
                  </a-space>
                </template>
              </template>
            </a-table>
          </div>
        </div>

        <!-- 空状态 -->
        <a-empty v-if="qaList.length === 0" description="暂无 QA 数据" />
      </div>

      <!-- 分页 -->
      <div class="pagination-section">
        <a-pagination
          v-model:current="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          show-size-changer
          show-quick-jumper
          :show-total="(total: number) => `共 ${total} 条`"
          :page-size-options="['10', '20', '50']"
          :locale="{
            items_per_page: '条/页',
            jump_to: '跳转至',
            page: '页',
          }"
          @change="handlePageChange"
          @show-size-change="handlePageSizeChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import {
  SearchOutlined,
  PlusOutlined,
  LinkOutlined,
  WarningOutlined,
  DeleteOutlined,
  QuestionCircleOutlined,
  MessageOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnsType } from 'ant-design-vue';

// ==================== 接口定义 ====================
interface ReplyItem {
  id: number;
  replyText: string;
  scene: string;
}

interface QaItem {
  id: number;
  question: string;
  qaType: '场景 QA' | '行业 QA' | '通用 QA';
  followProcess: string;
  intentType: '正向' | '负向';
  description: string;
  replies: ReplyItem[];
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: string;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void;
  (e: 'create-qa'): void;
  (e: 'reference-qa'): void;
  (e: 'exception-check'): void;
  (e: 'show-guide'): void;
  (e: 'add-user-question', qa: QaItem): void;
  (e: 'add-reply', qa: QaItem): void;
  (e: 'delete-qa', qa: QaItem): void;
  (e: 'edit-reply', reply: ReplyItem): void;
  (e: 'delete-reply', reply: ReplyItem, qa: QaItem): void;
}>();

// ==================== 响应式数据 ====================
// 筛选相关
const qaTypeFilter = ref('all');

// 搜索相关
const searchKeyword = ref('');

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(12);

// QA 列表数据（模拟数据）
const qaList = ref<QaItem[]>([
  {
    id: 1001,
    question: '如何办理信用卡激活？',
    qaType: '场景 QA',
    followProcess: '信用卡激活流程',
    intentType: '正向',
    description: '用户咨询信用卡激活的具体操作步骤',
    replies: [
      {
        id: 1,
        replyText: '您好，办理信用卡激活非常简单。您可以通过以下几种方式进行激活：1. 拨打信用卡背面的客服热线，按照语音提示操作；2. 登录手机银行 APP，在信用卡页面点击激活；3. 前往就近的银行网点，由工作人员协助激活。请问您想选择哪种方式呢？',
        scene: '当前模板新增',
      },
      {
        id: 2,
        replyText: '激活信用卡需要您提供以下信息：身份证号码、信用卡卡号、预留手机号码。请确保您提供的信息与办卡时填写的信息一致。',
        scene: '信用卡激活',
      },
    ],
  },
  {
    id: 1002,
    question: '账户被冻结了怎么办？',
    qaType: '场景 QA',
    followProcess: '账户解冻流程',
    intentType: '负向',
    description: '用户账户被冻结后的处理流程',
    replies: [
      {
        id: 3,
        replyText: '您好，账户被冻结可能是由于以下原因：1. 多次输入错误密码；2. 账户存在异常交易；3. 长时间未使用。请您先不要着急，我们可以帮您核实具体原因并指导您进行解冻操作。',
        scene: '账户回访',
      },
    ],
  },
  {
    id: 1003,
    question: '存款到期后如何续存？',
    qaType: '行业 QA',
    followProcess: '存款续存流程',
    intentType: '正向',
    description: '存款到期后的续存操作指引',
    replies: [
      {
        id: 4,
        replyText: '您的存款即将到期，我们提供多种续存方式供您选择：1. 自动转存：到期后自动按原期限和当日挂牌利率转存；2. 手动续存：您可前往网点或通过手机银行选择新的存款产品。建议您提前联系我们，我们可以为您推荐更优惠的续存方案。',
        scene: '存款到期续存',
      },
      {
        id: 5,
        replyText: '目前我行推出的大额存单产品利率较基准上浮 45%，期限灵活，起点金额 20 万元。如果您有续存需求，我可以为您详细介绍。',
        scene: '当前模板新增',
      },
    ],
  },
  {
    id: 1004,
    question: '如何申请个人贷款？',
    qaType: '场景 QA',
    followProcess: '个人贷款申请流程',
    intentType: '正向',
    description: '用户咨询个人信用贷款申请条件和流程',
    replies: [
      {
        id: 6,
        replyText: '您好，申请个人贷款需要满足以下条件：1. 年满 18 周岁，具有完全民事行为能力；2. 有稳定的工作和收入来源；3. 信用记录良好。您可以携带身份证、收入证明等材料前往网点办理，也可以通过手机银行在线申请。',
        scene: '个人信用贷款',
      },
      {
        id: 7,
        replyText: '目前我行个人信用贷款年化利率最低 3.85%，最高可贷 30 万元，期限最长 3 年。审批通过后，资金实时到账，支持随借随还，按日计息。',
        scene: '当前模板新增',
      },
    ],
  },
  {
    id: 1005,
    question: '手机银行如何绑定银行卡？',
    qaType: '通用 QA',
    followProcess: '手机银行绑卡流程',
    intentType: '正向',
    description: '用户咨询手机银行绑定银行卡的操作方法',
    replies: [
      {
        id: 8,
        replyText: '您好，绑定银行卡的步骤如下：1. 登录手机银行 APP；2. 点击"我的"页面；3. 选择"银行卡管理"；4. 点击"添加银行卡"；5. 输入卡号、预留手机号等信息完成验证。整个过程大约需要 2-3 分钟。',
        scene: '手机银行开通',
      },
    ],
  },
  {
    id: 1006,
    question: '如何查询账户余额？',
    qaType: '通用 QA',
    followProcess: '余额查询流程',
    intentType: '正向',
    description: '用户查询账户余额的多种方式',
    replies: [
      {
        id: 9,
        replyText: '您可以通过以下方式查询余额：1. 手机银行：登录后点击"账户管理"即可查看；2. 网上银行：登录个人网银查询；3. 电话银行：拨打客服热线按语音提示操作；4. 网点查询：携带身份证前往就近网点。',
        scene: '当前模板新增',
      },
      {
        id: 10,
        replyText: '建议您开通手机银行余额变动提醒服务，账户资金变动会实时推送短信通知，方便您随时掌握账户动态。',
        scene: '手机银行促活',
      },
    ],
  },
]);

// 回复表格列配置
const replyColumns = computed<TableColumnsType>(() => [
  {
    title: '序号',
    dataIndex: 'id',
    key: 'index',
    width: 60,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  {
    title: '回复文本',
    dataIndex: 'replyText',
    key: 'replyText',
    width: 600,
    ellipsis: false,
  },
  {
    title: '场景',
    dataIndex: 'scene',
    key: 'scene',
    width: 150,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    fixed: 'right' as const,
  },
]);

// ==================== 方法 ====================
// 获取 QA 类型颜色
const getQaTypeColor = (qaType: string): string => {
  const colorMap: Record<string, string> = {
    '场景 QA': 'blue',
    '行业 QA': 'green',
    '通用 QA': 'purple',
  };
  return colorMap[qaType] || 'default';
};

// QA 类型筛选变化
const handleQaTypeChange = (value: string) => {
  console.log('QA 类型筛选变化:', value);
  // TODO: 实现筛选逻辑
};

// 搜索
const handleSearch = () => {
  console.log('搜索关键词:', searchKeyword.value);
  // TODO: 实现搜索逻辑
};

// 重置
const handleReset = () => {
  searchKeyword.value = '';
  qaTypeFilter.value = 'all';
  // TODO: 实现重置逻辑
};

// 新建 QA
const handleCreateQa = () => {
  emit('create-qa');
};

// 引用 QA
const handleReferenceQa = () => {
  emit('reference-qa');
};

// 异常检测
const handleExceptionCheck = () => {
  emit('exception-check');
};

// 显示操作引导
const showQaGuide = () => {
  emit('show-guide');
};

// 添加用户问法
const handleAddUserQuestion = (qa: QaItem) => {
  emit('add-user-question', qa);
};

// 新增回复
const handleAddReply = (qa: QaItem) => {
  emit('add-reply', qa);
};

// 删除 QA
const handleDeleteQa = (qa: QaItem) => {
  emit('delete-qa', qa);
};

// 编辑回复
const handleEditReply = (reply: ReplyItem) => {
  emit('edit-reply', reply);
};

// 删除回复
const handleDeleteReply = (reply: ReplyItem, qa: QaItem) => {
  emit('delete-reply', reply, qa);
};

// 分页变化
const handlePageChange = (page: number, pageSize: number) => {
  console.log('分页变化:', page, pageSize);
  // TODO: 实现分页逻辑
};

// 每页条数变化
const handlePageSizeChange = (current: number, size: number) => {
  console.log('每页条数变化:', current, size);
  // TODO: 实现分页逻辑
};
</script>

<style scoped>
/* QA 库内容区域 */
.qa-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.qa-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  min-height: 0;
}

/* 顶部操作区 */
.toolbar-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-shrink: 0;
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toolbar-right {
  display: flex;
  align-items: center;
}

/* 操作引导按钮样式 */
.operation-guide-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: #fff !important;
  border: none !important;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.operation-guide-btn:hover {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4) !important;
  transform: translateY(-1px) !important;
  color: #fff !important;
}

/* QA 卡片列表 */
.qa-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.qa-card {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  overflow: visible;
}

/* 卡片头部 */
.qa-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.qa-id {
  font-size: 12px;
  color: #8c8c8c;
}

.qa-question {
  font-size: 15px;
  font-weight: 500;
  color: #262626;
}

.qa-process {
  font-size: 14px;
  color: #595959;
}

/* 回复表格区域 */
.reply-table-wrapper {
  padding: 16px 20px;
}

.reply-table-wrapper :deep(.ant-table) {
  font-size: 13px;
}

.reply-table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
}

.reply-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
}

.scene-text {
  color: #1890ff;
}

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

/* 删除 QA 按钮样式 */
.delete-qa-btn {
  color: #ff4d4f;
}

.delete-qa-btn:hover {
  color: #ff7875;
}

/* 分页区域 */
.pagination-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: flex-end;
}

/* 滚动条样式 */
.qa-list::-webkit-scrollbar {
  width: 6px;
}

.qa-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.qa-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.qa-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
