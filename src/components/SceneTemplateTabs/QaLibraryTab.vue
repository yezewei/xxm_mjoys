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
            >
              <template #bodyCell="{ column, record, index }">
                <template v-if="column.key === 'index'">
                  <span>{{ index + 1 }}</span>
                </template>
                <template v-if="column.key === 'replyText'">
                  <span class="reply-text">{{ record.replyText }}</span>
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

    <!-- 新建 QA 弹窗 -->
    <a-modal
      v-model:open="createQaModalVisible"
      title="新建场景 QA"
      width="800px"
      :footer="null"
      @cancel="handleCreateQaCancel"
    >
      <a-form
        ref="createQaFormRef"
        :model="createQaForm"
        :rules="{
          question: [{ required: true, message: '请输入 QA 名称', trigger: 'blur' }],
          followProcess: [{ required: true, message: '请输入后续流程', trigger: 'blur' }],
          qaStatus: [{ required: true, message: '请选择 QA 状态', trigger: 'change' }],
          intentType: [{ required: true, message: '请选择意向类型', trigger: 'change' }],
        }"
        layout="vertical"
      >
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="QA 名称" name="question">
              <a-input v-model:value="createQaForm.question" placeholder="请输入 QA 名称" />
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="后续流程" name="followProcess">
              <a-input v-model:value="createQaForm.followProcess" placeholder="请输入后续流程" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="QA 状态" name="qaStatus">
              <a-select v-model:value="createQaForm.qaStatus" placeholder="请选择 QA 状态">
                <a-select-option value="启用">启用</a-select-option>
                <a-select-option value="停用">停用</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="意向类型" name="intentType">
              <a-select v-model:value="createQaForm.intentType" placeholder="请选择意向类型">
                <a-select-option value="正向">正向</a-select-option>
                <a-select-option value="负向">负向</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>
        <a-divider style="margin: 16px 0" />
        <div style="margin-bottom: 12px; font-weight: 500;">
          回复内容
          <span style="color: #ff4d4f; font-weight: normal; font-size: 12px; margin-left: 8px;">（至少添加一条回复）</span>
          <a-button type="link" size="small" @click="handleAddNewReply" style="padding-left: 8px;">
            <plus-outlined />
            新增回复
          </a-button>
        </div>
        <div class="reply-input-list">
          <div
            v-for="(_, index) in createQaForm.replies"
            :key="index"
            class="reply-input-item"
          >
            <div class="reply-input-content">
              <div class="textarea-with-action">
                <a-textarea
                  v-model:value="createQaForm.replies[index].replyText"
                  placeholder="请输入回复内容"
                  :rows="3"
                />
                <a class="ai-generate-btn-small" @click="handleAiGenerateReply(index)">
                  <thunderbolt-outlined />
                  AI 生成
                </a>
              </div>
              <div class="reply-actions">
                <a
                  v-if="createQaForm.replies.length > 1"
                  class="delete-reply-btn"
                  @click="handleDeleteReplyInput(index)"
                >
                  <delete-outlined />
                  删除
                </a>
              </div>
            </div>
          </div>
        </div>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleCreateQaCancel">取消</a-button>
        <a-button type="primary" @click="handleCreateQaSubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 编辑回复弹窗 -->
    <a-modal
      v-model:open="editReplyModalVisible"
      title="编辑回复"
      width="800px"
      :footer="null"
      @cancel="handleEditReplyCancel"
    >
      <a-form
        ref="editReplyFormRef"
        :model="editReplyForm"
        :rules="{
          replyText: [{ required: true, message: '请输入回复内容', trigger: 'blur' }],
        }"
        layout="vertical"
      >
        <a-form-item label="回复内容" name="replyText">
          <div class="textarea-with-action">
            <a-textarea
              v-model:value="editReplyForm.replyText"
              placeholder="请输入回复内容"
              :rows="6"
            />
            <a class="ai-generate-btn" @click="handleAiGenerateEditReply">
              <thunderbolt-outlined />
              AI 生成
            </a>
          </div>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleEditReplyCancel">取消</a-button>
        <a-button type="primary" @click="handleEditReplySubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 新增回复弹窗 -->
    <a-modal
      v-model:open="addReplyModalVisible"
      title="新增回复"
      width="800px"
      :footer="null"
      @cancel="handleAddReplyCancel"
    >
      <a-form
        ref="addReplyFormRef"
        :model="addReplyForm"
        :rules="{
          replyText: [{ required: true, message: '请输入回复内容', trigger: 'blur' }],
        }"
        layout="vertical"
      >
        <a-form-item label="回复内容" name="replyText">
          <div class="textarea-with-action">
            <a-textarea
              v-model:value="addReplyForm.replyText"
              placeholder="请输入回复内容"
              :rows="6"
            />
            <a class="ai-generate-btn" @click="handleAiGenerateAddReply">
              <thunderbolt-outlined />
              AI 生成
            </a>
          </div>
        </a-form-item>
      </a-form>
      <div class="modal-footer">
        <a-button @click="handleAddReplyCancel">取消</a-button>
        <a-button type="primary" @click="handleAddReplySubmit">保存</a-button>
      </div>
    </a-modal>

    <!-- 引用 QA 弹窗 -->
    <a-modal
      v-model:open="referenceQaModalVisible"
      title="引用通用/行业 QA"
      width="900px"
      :footer="null"
      @cancel="handleReferenceQaCancel"
    >
      <div class="reference-qa-content">
        <div class="reference-toolbar">
          <a-space>
            <a-select v-model:value="referenceQaType" placeholder="全部" style="width: 150px">
              <a-select-option value="all">全部</a-select-option>
              <a-select-option value="common">通用 QA</a-select-option>
              <a-select-option value="industry">行业 QA</a-select-option>
            </a-select>
            <a-input
              v-model:value="referenceSearchKeyword"
              placeholder="请输入 QA 名称搜索"
              style="width: 250px"
              @press-enter="handleReferenceSearch"
            >
              <template #prefix>
                <search-outlined />
              </template>
            </a-input>
            <a-button type="primary" @click="handleReferenceSearch">搜索</a-button>
            <a-button @click="handleReferenceSearchReset">重置</a-button>
          </a-space>
        </div>
        <div class="reference-selected-info">
          <span class="selected-count">已选择 {{ selectedReferenceRowKeys.length }} 条 QA</span>
        </div>
        <div class="reference-table-wrapper">
          <a-table
            :columns="referenceColumns"
            :data-source="referenceQaList"
            :pagination="false"
            row-key="id"
            size="middle"
            :row-selection="{
              selectedRowKeys: selectedReferenceRowKeys,
              onChange: onReferenceSelectionChange,
            }"
          >
          </a-table>
        </div>
        <div class="reference-pagination">
          <a-checkbox v-model:checked="referenceSelectAll" @change="onReferenceSelectAll">全选</a-checkbox>
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
        <a-button @click="handleReferenceQaCancel">关闭</a-button>
        <a-button type="primary" @click="handleReferenceQaImport">导入</a-button>
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
                <a-button @click="handleReportPattern">
                  上报语料
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
                      ref="editInputRef"
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
          <div class="semantic-toolbar">
            <div class="toolbar-left">
              <a-space>
                <a-button type="primary" @click="handleSemanticTest">
                  语义测试
                </a-button>
              </a-space>
            </div>
          </div>
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

    <!-- 上报语料确认弹窗 -->
    <a-modal
      v-model:open="reportPatternConfirmVisible"
      title="上报语料"
      :footer="null"
      @cancel="handleReportPatternCancel"
    >
      <div class="report-pattern-content">
        <p>上报语料将进入异常看板，摸象公司定期分析并用于优化通用/行业 QA 模型。请确保语料准确无误。</p>
      </div>
      <div class="modal-footer">
        <a-button @click="handleReportPatternCancel">取消</a-button>
        <a-button type="primary" @click="handleReportPatternConfirm">确认上报</a-button>
      </div>
    </a-modal>

    <!-- QA 库新手引导弹窗 -->
    <QaGuideModal
      :visible="qaGuideVisible"
      :steps="qaGuideSteps"
      @close="handleQaGuideClose"
      @finish="handleQaGuideFinish"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, watch } from 'vue';
import { message } from 'ant-design-vue';
import {
  SearchOutlined,
  PlusOutlined,
  LinkOutlined,
  WarningOutlined,
  DeleteOutlined,
  QuestionCircleOutlined,
  MessageOutlined,
  ThunderboltOutlined,
  CloseOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnsType } from 'ant-design-vue';
import type { FormInstance } from 'ant-design-vue';
import QaGuideModal from '../QaGuideModal.vue';

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

// 新建 QA 表单接口
interface CreateQaForm {
  question: string;
  followProcess: string;
  qaStatus: '启用' | '停用';
  intentType: '正向' | '负向';
  replies: { replyText: string }[];
}

// 编辑回复表单接口
interface EditReplyForm {
  id: number;
  replyText: string;
}

// 新增回复表单接口
interface AddReplyForm {
  replyText: string;
}

// 引用 QA 列表项接口
interface ReferenceQaItem {
  id: number;
  qaName: string;
  similarCount: number;
}

// 用户问法语料接口
interface PatternItem {
  id: number;
  patternText: string;
}

// 语义槽接口
interface SemanticSlotItem {
  id: number;
  slotName: string;
  slotValue: string;
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: string;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void;
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

// ==================== 模态框相关数据 ====================
// 新建 QA 模态框
const createQaModalVisible = ref(false);
const createQaFormRef = ref<FormInstance>();
const createQaForm = ref<CreateQaForm>({
  question: '',
  followProcess: '',
  qaStatus: '启用',
  intentType: '正向',
  replies: [],
});

// 编辑回复模态框
const editReplyModalVisible = ref(false);
const editReplyFormRef = ref<FormInstance>();
const editReplyForm = ref<EditReplyForm>({
  id: 0,
  replyText: '',
});
const currentEditQa = ref<QaItem | null>(null);

// 新增回复模态框
const addReplyModalVisible = ref(false);
const addReplyFormRef = ref<FormInstance>();
const addReplyForm = ref<AddReplyForm>({
  replyText: '',
});
const currentAddQa = ref<QaItem | null>(null);

// 引用 QA 模态框
const referenceQaModalVisible = ref(false);
const referenceQaType = ref('all');
const referenceSearchKeyword = ref('');
const referenceSelectAll = ref(false);
const selectedReferenceRowKeys = ref<number[]>([]);
const referenceCurrent = ref(1);
const referencePageSize = ref(10);
const referenceTotal = ref(88);

// 引用 QA 列表数据
const referenceQaList = ref<ReferenceQaItem[]>([
  { id: 118337, qaName: 'com.是骗子吗', similarCount: 150 },
  { id: 118338, qaName: 'com.是正规的吗', similarCount: 150 },
  { id: 118341, qaName: 'com.为什么不是官方电话', similarCount: 150 },
  { id: 118342, qaName: 'yh.叫什么名字', similarCount: 150 },
  { id: 118343, qaName: 'com.在忙', similarCount: 150 },
  { id: 118344, qaName: 'yh.银行地址', similarCount: 150 },
  { id: 118345, qaName: 'yh.你加我微信吧', similarCount: 150 },
  { id: 118346, qaName: 'yh.你发个短信给我', similarCount: 150 },
  { id: 118347, qaName: 'yh.是机器人吗', similarCount: 150 },
  { id: 118348, qaName: 'com.打很多次了', similarCount: 150 },
]);

// 添加用户问法模态框
const addUserQuestionModalVisible = ref(false);
const currentAddUserQuestionQa = ref<QaItem | null>(null);
const userQuestionActiveTab = ref('pattern');
const patternSearchKeyword = ref('');
const selectedPatternRowKeys = ref<number[]>([]);
const patternList = ref<PatternItem[]>([]);
const semanticSlotList = ref<SemanticSlotItem[]>([]);
const addPatternModalVisible = ref(false);
const addPatternFormRef = ref<FormInstance>();
const addPatternForm = ref({ patternText: '' });
const reportPatternConfirmVisible = ref(false);
const editingPatternId = ref<number | null>(null);
const editInputRef = ref<any>();

// QA 引导相关
const qaGuideVisible = ref(false);
const qaGuideCompleted = ref(false);

// QA 引导步骤配置
const qaGuideSteps = [
  {
    title: '引用通用/行业 QA',
    content: '点击"引用通用/行业 QA"按钮，引用当前场景涉及的行业/通用 QA，快速丰富应答库。',
    targetSelector: '.qa-toolbar .reference-qa-btn',
  },
  {
    title: '编辑回复',
    content: '在 QA 卡片中点击"新增回复"按钮，编辑行业/通用 QA 的回复内容，使其更符合当前场景需求。',
    targetSelector: '.qa-card:first-child .add-reply-btn',
  },
  {
    title: '创建场景 QA',
    content: '点击"新建场景 QA"按钮，创建当前场景专属的 QA 和对应回复，满足特定业务需求。',
    targetSelector: '.qa-toolbar .create-scene-qa-btn',
  },
  {
    title: '添加用户问法',
    content: '点击场景 QA 卡片中的"添加用户问法"按钮，维护场景对应的 pattern 语料，提升识别准确率。',
    targetSelector: '.qa-card:first-child .add-user-question-btn',
  },
  {
    title: '语料维护说明',
    content: '当通用/行业 QA 缺失语料时，可创建同名场景 QA 维护语料后上报，用于模型优化。场景模板 QA 库展示基于当前模板创建的场景中的所有 QA。',
    targetSelector: '.qa-content',
  },
];

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
    width: 750,
    ellipsis: false,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    fixed: 'right' as const,
  },
]);

// ==================== 引用 QA 表格列配置 ====================
const referenceColumns = computed<TableColumnsType>(() => [
  {
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    width: 100,
  },
  {
    title: 'QA 名称',
    dataIndex: 'qaName',
    key: 'qaName',
    width: 400,
  },
  {
    title: '相似问数量',
    dataIndex: 'similarCount',
    key: 'similarCount',
    width: 120,
  },
]);

// ==================== Pattern 语料表格列配置 ====================
const patternColumns = computed<TableColumnsType>(() => [
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
]);

// ==================== 语义槽表格列配置 ====================
const semanticColumns = computed<TableColumnsType>(() => [
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
    width: 400,
  },
  {
    title: '操作',
    key: 'action',
    width: 80,
    align: 'center',
  },
]);

// ==================== Pattern 分页配置 ====================
const patternPagination = ref({
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

// ==================== 语义槽分页配置 ====================
const semanticPagination = ref({
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
  message.info(`搜索：${searchKeyword.value || '全部'}`);
  // TODO: 实现搜索逻辑
};

// 重置
const handleReset = () => {
  searchKeyword.value = '';
  qaTypeFilter.value = 'all';
  message.success('已重置搜索条件');
};

// ==================== 新建 QA 相关 ====================
// 新建 QA
const handleCreateQa = () => {
  createQaModalVisible.value = true;
};

// 取消新建 QA
const handleCreateQaCancel = () => {
  createQaModalVisible.value = false;
  createQaFormRef.value?.resetFields();
  createQaForm.value.question = '';
  createQaForm.value.replies = [];
};

// 新增回复输入框（新建 QA 弹窗中）
const handleAddNewReply = () => {
  createQaForm.value.replies.push({ replyText: '' });
};

// 删除回复输入框（新建 QA 弹窗中）
const handleDeleteReplyInput = (index: number) => {
  createQaForm.value.replies.splice(index, 1);
};

// AI 生成回复（新建 QA 列表中的回复）
const handleAiGenerateReply = (index: number) => {
  console.log('AI 生成回复，索引:', index);
  message.loading('AI 正在生成回复...', 1.5);
  setTimeout(() => {
    createQaForm.value.replies[index].replyText = '这是 AI 生成的回复内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// 提交新建 QA
const handleCreateQaSubmit = async () => {
  try {
    await createQaFormRef.value?.validate();
    if (createQaForm.value.replies.length === 0) {
      message.error('请至少添加一条回复');
      return;
    }
    // 检查所有回复是否都填写了
    const emptyReplies = createQaForm.value.replies.filter(r => !r.replyText || r.replyText.trim() === '');
    if (emptyReplies.length > 0) {
      message.error('请填写所有回复内容');
      return;
    }
    console.log('新建 QA 表单数据:', createQaForm.value);
    // TODO: 实现新建 QA 保存逻辑
    message.success('新建 QA 成功');
    createQaModalVisible.value = false;
    createQaFormRef.value?.resetFields();
    createQaForm.value.question = '';
    createQaForm.value.replies = [];
  } catch (error) {
    console.log('表单验证失败:', error);
  }
};

// ==================== 引用 QA 相关 ====================
// 引用 QA
const handleReferenceQa = () => {
  referenceQaModalVisible.value = true;
  selectedReferenceRowKeys.value = [];
};

const handleReferenceQaCancel = () => {
  referenceQaModalVisible.value = false;
  selectedReferenceRowKeys.value = [];
};

const handleReferenceSearch = () => {
  console.log('搜索:', referenceSearchKeyword.value);
  message.info(`搜索：${referenceSearchKeyword.value || '全部'}`);
};

const handleReferenceSearchReset = () => {
  referenceSearchKeyword.value = '';
  message.success('已重置搜索条件');
};

const onReferenceSelectionChange = (selectedRowKeys: number[]) => {
  selectedReferenceRowKeys.value = selectedRowKeys;
  referenceSelectAll.value = selectedRowKeys.length === referenceQaList.value.length;
};

const onReferenceSelectAll = (e: Event) => {
  const checked = (e.target as HTMLInputElement).checked;
  if (checked) {
    selectedReferenceRowKeys.value = referenceQaList.value.map(item => item.id);
  } else {
    selectedReferenceRowKeys.value = [];
  }
};

const handleReferencePageChange = (page: number) => {
  console.log('页码变化:', page);
};

const handleReferencePageSizeChange = (_current: number, size: number) => {
  console.log('每页条数变化:', size);
};

const handleReferenceQaImport = () => {
  console.log('导入选中的 QA:', selectedReferenceRowKeys.value);
  if (selectedReferenceRowKeys.value.length === 0) {
    message.warning('请至少选择一个 QA');
    return;
  }
  message.success(`已导入${selectedReferenceRowKeys.value.length}条 QA`);
  referenceQaModalVisible.value = false;
  selectedReferenceRowKeys.value = [];
};

// ==================== 异常检测 ====================
// 异常检测
const handleExceptionCheck = () => {
  // 模拟检测后显示无异常提示
  message.success('QA 配置无异常');
};

// ==================== 显示操作引导 ====================
// 显示 QA 引导
const showQaGuide = () => {
  console.log('显示 QA 引导');
  qaGuideVisible.value = true;
};

// 隐藏 QA 引导
const hideQaGuide = () => {
  qaGuideVisible.value = false;
};

// 完成 QA 引导
const handleQaGuideFinish = () => {
  qaGuideCompleted.value = true;
  hideQaGuide();
  message.success('引导完成！');
};

// 关闭 QA 引导
const handleQaGuideClose = () => {
  hideQaGuide();
};

// 监听 QA 引导 visible 变化
watch(() => qaGuideVisible.value, (newVal) => {
  if (newVal) {
    console.log('QA 引导已显示');
  }
});

// ==================== 添加用户问法相关 ====================
// 添加用户问法
const handleAddUserQuestion = (qa: QaItem) => {
  currentAddUserQuestionQa.value = qa;
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
    { id: 8, patternText: '[在 | 我] 睡觉.{0,3}[你] 给我转到.{0,2}(银监会 | 保监会 | 银保监会)' },
    { id: 9, patternText: '给我转到.{0,2}(银监会 | 保监会 | 银保监会)' },
    { id: 10, patternText: '(在 | 去 | 要)(一二三 | 幺二三|123).{0,4}(查 | 看 | 查看 | 查询)[一] 下' },
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
  console.log('添加用户问法:', qa);
};

// 取消添加用户问法
const handleAddUserQuestionCancel = () => {
  addUserQuestionModalVisible.value = false;
  currentAddUserQuestionQa.value = null;
  userQuestionActiveTab.value = 'pattern';
};

// 打开新增语料弹窗
const handleOpenAddPatternModal = () => {
  addPatternForm.value.patternText = '';
  addPatternModalVisible.value = true;
};

// 取消新增语料
const handleAddPatternModalCancel = () => {
  addPatternModalVisible.value = false;
  addPatternFormRef.value?.resetFields();
};

// 上报语料
const handleReportPattern = () => {
  reportPatternConfirmVisible.value = true;
};

// 取消上报语料
const handleReportPatternCancel = () => {
  reportPatternConfirmVisible.value = false;
};

// 确认上报语料
const handleReportPatternConfirm = async () => {
  // 校验有无勾选 pattern 语料
  if (selectedPatternRowKeys.value.length === 0) {
    message.warning('请至少选择一条要上报的语料');
    return;
  }
  reportPatternConfirmVisible.value = false;
  message.success(`成功上报 ${selectedPatternRowKeys.value.length} 条语料`);
  // TODO: 实现上报语料的实际逻辑
  console.log('上报语料 ID:', selectedPatternRowKeys.value);
  // 清空已选择
  selectedPatternRowKeys.value = [];
};

// 提交新增语料
const handleAddPatternSubmit = async () => {
  try {
    await addPatternFormRef.value?.validate();
    const lines = addPatternForm.value.patternText.split('\n').filter(line => line.trim());
    if (lines.length === 0) {
      message.warning('请输入至少一条语料');
      return;
    }
    lines.forEach(line => {
      patternList.value.push({
        id: Date.now() + Math.random(),
        patternText: line.trim(),
      });
    });
    message.success(`成功添加${lines.length}条语料`);
    addPatternModalVisible.value = false;
    addPatternFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 删除 pattern
const handleDeletePattern = (record: PatternItem) => {
  const index = patternList.value.findIndex(item => item.id === record.id);
  if (index > -1) {
    patternList.value.splice(index, 1);
    message.success('删除成功');
  }
};

// 批量删除 pattern
const handleBatchDeletePattern = () => {
  if (selectedPatternRowKeys.value.length === 0) {
    message.warning('请先选择要删除的语料');
    return;
  }
  patternList.value = patternList.value.filter(item => !selectedPatternRowKeys.value.includes(item.id));
  selectedPatternRowKeys.value = [];
  message.success(`已删除语料`);
};

// 语义测试
const handleSemanticTest = () => {
  message.info('语义测试功能开发中...');
};

// 语音检测
const handleVoiceDetection = () => {
  message.info('语音检测功能开发中...');
};

// 保存用户问法
const handleSaveUserQuestion = () => {
  console.log('保存用户问法:', {
    qa: currentAddUserQuestionQa.value,
    patterns: patternList.value,
    semanticSlots: semanticSlotList.value,
  });
  message.success('保存成功');
  addUserQuestionModalVisible.value = false;
};

// pattern 表格变化
const handlePatternTableChange = (pagination: any) => {
  patternPagination.value.current = pagination.current;
  patternPagination.value.pageSize = pagination.pageSize;
};

// pattern 选择变化
const onPatternSelectChange = (selectedRowKeys: number[]) => {
  selectedPatternRowKeys.value = selectedRowKeys;
};

// 删除语义槽
const handleDeleteSemanticSlot = (record: SemanticSlotItem) => {
  const index = semanticSlotList.value.findIndex(item => item.id === record.id);
  if (index > -1) {
    semanticSlotList.value.splice(index, 1);
    message.success('删除成功');
  }
};

// 语义槽表格变化
const handleSemanticSlotTableChange = (pagination: any) => {
  semanticPagination.value.current = pagination.current;
  semanticPagination.value.pageSize = pagination.pageSize;
};

// pattern 搜索
const handlePatternSearch = () => {
  console.log('搜索 pattern:', patternSearchKeyword.value);
  message.info('搜索功能开发中...');
};

// 编辑 pattern
const handleEditPattern = (record: PatternItem) => {
  console.log('点击编辑 pattern:', record.id);
  editingPatternId.value = record.id;
  // 下一步聚焦输入框，需要在 DOM 更新后
  nextTick(() => {
    if (editInputRef.value && editInputRef.value.focus) {
      editInputRef.value.focus();
    }
  });
};

// 保存 pattern 编辑
const handleSavePatternEdit = (record: PatternItem) => {
  console.log('保存 pattern 编辑:', record.patternText);
  if (!record.patternText || record.patternText.trim() === '') {
    message.warning('语料内容不能为空');
    return;
  }
  // TODO: 实现保存逻辑
  editingPatternId.value = null;
  message.success('保存成功');
};

// ==================== 新增回复相关 ====================
// 新增回复
const handleAddReply = (qa: QaItem) => {
  currentAddQa.value = qa;
  addReplyForm.value.replyText = '';
  addReplyModalVisible.value = true;
};

// 取消新增回复
const handleAddReplyCancel = () => {
  addReplyModalVisible.value = false;
  addReplyFormRef.value?.resetFields();
  currentAddQa.value = null;
};

// AI 生成新增回复
const handleAiGenerateAddReply = () => {
  console.log('AI 生成新增回复');
  message.loading('AI 正在生成回复...', 1.5);
  setTimeout(() => {
    addReplyForm.value.replyText = '这是 AI 生成的回复内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// 提交新增回复
const handleAddReplySubmit = async () => {
  try {
    await addReplyFormRef.value?.validate();
    console.log('新增回复表单数据:', addReplyForm.value);
    console.log('所属 QA:', currentAddQa.value);
    // TODO: 实现新增回复保存逻辑
    if (currentAddQa.value) {
      const newReply: ReplyItem = {
        id: Date.now(),
        replyText: addReplyForm.value.replyText,
        scene: '当前模板新增',
      };
      currentAddQa.value.replies.push(newReply);
    }
    message.success('新增回复成功');
    addReplyModalVisible.value = false;
    addReplyFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// ==================== 编辑回复相关 ====================
// 编辑回复
const handleEditReply = (reply: ReplyItem) => {
  editReplyForm.value.id = reply.id;
  editReplyForm.value.replyText = reply.replyText;
  // 查找当前 QA
  for (const qa of qaList.value) {
    const found = qa.replies.find(r => r.id === reply.id);
    if (found) {
      currentEditQa.value = qa;
      break;
    }
  }
  editReplyModalVisible.value = true;
};

// 取消编辑回复
const handleEditReplyCancel = () => {
  editReplyModalVisible.value = false;
  editReplyFormRef.value?.resetFields();
};

// AI 生成编辑回复
const handleAiGenerateEditReply = () => {
  console.log('AI 生成编辑回复');
  message.loading('AI 正在生成回复...', 1.5);
  setTimeout(() => {
    editReplyForm.value.replyText = '这是 AI 生成的回复内容示例。您可以根据实际需求调整或重新生成。';
    message.success('AI 生成成功');
  }, 1500);
};

// 提交编辑回复
const handleEditReplySubmit = async () => {
  try {
    await editReplyFormRef.value?.validate();
    console.log('编辑回复表单数据:', editReplyForm.value);
    // TODO: 实现编辑回复保存逻辑
    if (currentEditQa.value) {
      const replyIndex = currentEditQa.value.replies.findIndex(r => r.id === editReplyForm.value.id);
      if (replyIndex !== -1) {
        currentEditQa.value.replies[replyIndex] = {
          id: editReplyForm.value.id,
          replyText: editReplyForm.value.replyText,
          scene: currentEditQa.value.replies[replyIndex].scene,
        };
      }
    }
    message.success('编辑回复成功');
    editReplyModalVisible.value = false;
    editReplyFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// ==================== 删除相关 ====================
// 删除回复
const handleDeleteReply = (reply: ReplyItem, qa: QaItem) => {
  console.log('删除回复:', reply);
  // TODO: 实现删除回复逻辑
  const replyIndex = qa.replies.findIndex(r => r.id === reply.id);
  if (replyIndex !== -1) {
    qa.replies.splice(replyIndex, 1);
  }
  message.success('删除回复成功');
};

// 删除 QA
const handleDeleteQa = (qa: QaItem) => {
  console.log('删除 QA:', qa);
  const qaIndex = qaList.value.findIndex(item => item.id === qa.id);
  if (qaIndex !== -1) {
    qaList.value.splice(qaIndex, 1);
  }
  message.success('删除 QA 成功');
};

// ==================== 分页相关 ====================
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

// ==================== 生命周期 ====================
onMounted(() => {
  console.log('QaLibraryTab 组件已挂载');
});
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

/* 模态框底部按钮 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

/* 回复输入组 */
.reply-input-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reply-input-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  background: #fafafa;
  border-radius: 4px;
}

.reply-input-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reply-input-content {
  position: relative;
}

.reply-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
  margin-top: 8px;
}

.add-reply-link {
  color: #1890ff;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
}

.add-reply-link:hover {
  color: #40a9ff;
}

/* AI 生成按钮样式 */
.ai-generate-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border-radius: 4px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.ai-generate-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  color: #fff;
}

.ai-generate-btn:active {
  transform: translateY(0);
}

.delete-reply-btn {
  color: #ff4d4f;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  transition: all 0.3s ease;
}

.delete-reply-btn:hover {
  color: #ff7875;
}

/* 带操作按钮的文本域 */
.textarea-with-action {
  position: relative;
}

.textarea-with-action :deep(.ant-input-textarea) {
  padding-right: 100px;
}

.textarea-with-action .ai-generate-btn {
  position: absolute;
  right: 8px;
  bottom: 8px;
  z-index: 1;
}

.textarea-with-action .ai-generate-btn-small {
  position: absolute;
  right: 8px;
  bottom: 8px;
  z-index: 1;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 10px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 6px rgba(102, 126, 234, 0.3);
}

.textarea-with-action .ai-generate-btn-small:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(102, 126, 234, 0.4);
  color: #fff;
}

/* 引用 QA 内容 */
.reference-qa-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reference-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.reference-selected-info {
  display: flex;
  justify-content: flex-end;
  padding: 8px 0;
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
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-top: 1px solid #f0f0f0;
}

.reference-pagination :deep(.ant-checkbox-wrapper) {
  margin-right: 16px;
}

/* 添加用户问法内容 */
.add-user-question-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pattern-content,
.semantic-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pattern-toolbar,
.semantic-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
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

/* 绑定词库标签 */
.binding-tag {
  display: inline-block;
  font-size: 13px;
  padding: 2px 12px;
}

/* 上报语料内容 */
.report-pattern-content {
  padding: 16px 0;
}

/* 语料库操作链接 */
.pattern-content :deep(.ant-table-tbody > tr > td) {
  vertical-align: middle;
}

/* 语义槽操作链接 */
.semantic-content :deep(.ant-table-tbody > tr > td) {
  vertical-align: middle;
}
</style>
