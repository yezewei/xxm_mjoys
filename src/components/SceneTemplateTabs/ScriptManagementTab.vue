<template>
  <div class="script-content">
    <div class="script-scroll-wrapper">
      <!-- 话术管理子标签页 -->
      <div class="script-sub-tabs">
        <a-tabs v-model:activeKey="scriptSubTabKey" @change="handleScriptSubTabChange">
          <a-tab-pane key="compliance" data-tab-key="compliance" tab="话术消保" />
          <a-tab-pane key="audio" data-tab-key="audio" tab="话术录音" />
          <a-tab-pane key="variable" data-tab-key="variable" tab="话术变量" />
        </a-tabs>
      </div>

      <!-- 话术消保内容 -->
      <div v-if="scriptSubTabKey === 'compliance'" class="script-sub-content">
        <!-- 顶部操作区 -->
        <div class="script-toolbar-section">
          <div class="script-toolbar-left">
            <a-space>
              <a-input
                v-model:value="scriptSearchKeyword"
                placeholder="请输入话术文本搜索"
                style="width: 200px"
                @press-enter="handleScriptSearch"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-button type="primary" @click="handleScriptSearch">
                <search-outlined />
                搜索
              </a-button>
              <a-button @click="handleScriptReset">
                <reload-outlined />
                重置
              </a-button>
            </a-space>
          </div>
          <div class="script-toolbar-right">
            <a-space>
              <a-dropdown trigger="click">
                <a-button>
                  批量删除 <down-outlined />
                </a-button>
                <template #overlay>
                  <a-menu>
                    <a-menu-item key="delete-selected" @click="handleBatchDeleteSelected">
                      删除所选
                    </a-menu-item>
                    <a-menu-item key="delete-all" @click="handleBatchDeleteAll">
                      删除全部
                    </a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
              <a-dropdown trigger="click">
                <a-button>
                  批量导出 <down-outlined />
                </a-button>
                <template #overlay>
                  <a-menu>
                    <a-menu-item key="export-selected" @click="handleBatchExportSelected">
                      导出所选
                    </a-menu-item>
                    <a-menu-item key="export-all" @click="handleBatchExportAll">
                      导出全部
                    </a-menu-item>
                  </a-menu>
                </template>
              </a-dropdown>
            </a-space>
          </div>
        </div>

        <!-- 数据表格 -->
        <div class="script-list">
          <div class="script-table-wrapper">
            <a-table
              :columns="scriptColumns"
              :data-source="scriptList"
              :pagination="false"
              row-key="id"
              size="middle"
              :row-selection="{ selectedRowKeys: selectedScriptRowKeys, onChange: onScriptSelectChange }"
              @change="handleScriptTableChange"
              :scroll="{ x: 1000 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'uid'">
                  <span>{{ record.uid }}</span>
                </template>
                <template v-if="column.key === 'replyText'">
                  <span class="script-reply-text">{{ record.replyText }}</span>
                </template>
                <template v-if="column.key === 'variableValue'">
                  <span>{{ record.variableValue || '-' }}</span>
                </template>
                <template v-if="column.key === 'complianceStatus'">
                  <a-tag :color="getComplianceStatusColor(record.complianceStatus)">
                    {{ record.complianceStatus || '未消保' }}
                  </a-tag>
                </template>
                <template v-if="column.key === 'action'">
                  <a-space :size="8">
                    <a-button type="link" size="small" @click="handleEditScript(record)">
                      <edit-outlined />
                      编辑
                    </a-button>
                    <template v-if="record.complianceStatus === '未消保'">
                      <a-dropdown trigger="click">
                        <a-button type="link" size="small">
                          话术消保 <down-outlined />
                        </a-button>
                        <template #overlay>
                          <a-menu>
                            <a-menu-item key="pass" @click="handleCompliancePass(record)" class="compliance-pass">
                              <check-circle-outlined />
                              <span class="pass-text">消保通过</span>
                            </a-menu-item>
                            <a-menu-item key="reject" @click="handleComplianceReject(record)" class="compliance-reject">
                              <close-circle-outlined />
                              <span class="reject-text">消保不通过</span>
                            </a-menu-item>
                          </a-menu>
                        </template>
                      </a-dropdown>
                    </template>
                  </a-space>
                </template>
              </template>
            </a-table>
          </div>
          <!-- 分页 -->
          <div class="script-pagination">
            <span class="selected-count">共 {{ scriptTotal }} 条，已选择 {{ selectedScriptRowKeys.length }} 条</span>
            <a-pagination
              v-model:current="scriptPagination.current"
              v-model:page-size="scriptPagination.pageSize"
              :total="scriptPagination.total"
              show-size-changer
              show-quick-jumper
              :show-total="(total: number) => `共 ${total} 条`"
              :page-size-options="['10', '20', '50']"
              :locale="{
                items_per_page: '条/页',
                jump_to: '跳转至',
                page: '页',
              }"
              @change="handleScriptPageChange"
              @show-size-change="handleScriptPageSizeChange"
            />
          </div>
        </div>
      </div>

      <!-- 话术录音内容 -->
      <div v-else-if="scriptSubTabKey === 'audio'" class="script-sub-content">
        <!-- 录音包列表页面 -->
        <div v-if="!showAudioDetail" class="audio-package-list">
          <!-- 顶部操作区 -->
          <div class="script-toolbar-section">
            <div class="script-toolbar-left">
              <a-space>
                <a-input
                  v-model:value="audioPackageSearchKeyword"
                  placeholder="请输入录音包名称搜索"
                  style="width: 200px"
                  @press-enter="handleAudioPackageSearch"
                >
                  <template #prefix>
                    <search-outlined />
                  </template>
                </a-input>
                <a-button type="primary" @click="handleAudioPackageSearch">
                  <search-outlined />
                  搜索
                </a-button>
                <a-button @click="handleAudioPackageReset">
                  <reload-outlined />
                  重置
                </a-button>
              </a-space>
            </div>
            <div class="script-toolbar-right">
              <a-space>
                <a-button type="primary" @click="handleCreateAudioPackage">
                  <plus-outlined />
                  新建录音包
                </a-button>
              </a-space>
            </div>
          </div>

          <!-- 录音包列表表格 -->
          <div class="script-list">
            <div class="script-table-wrapper">
              <a-table
                :columns="audioPackageColumns"
                :data-source="audioPackageList"
                :pagination="audioPackagePagination"
                row-key="id"
                size="middle"
                @change="handleAudioPackageTableChange"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'packageName'">
                    <span>{{ record.packageName }}</span>
                    <a-tag v-if="record.isDefault" color="blue" style="margin-left: 8px;">默认</a-tag>
                  </template>
                  <template v-if="column.key === 'recorder'">
                    <span>{{ record.recorder }}</span>
                  </template>
                  <template v-if="column.key === 'progress'">
                    <div class="progress-cell">
                      <a-progress :percent="record.progressPercent" :stroke-color="record.progressPercent === 100 ? '#52c41a' : '#1890ff'" :show-info="false" style="width: 100px;" />
                      <span class="progress-text">{{ record.progressPercent }}% ({{ record.completedCount }}/{{ record.totalCount }})</span>
                    </div>
                  </template>
                  <template v-if="column.key === 'uploadStatus'">
                    <a-tag :color="record.uploadStatus === '已完成' ? 'green' : 'default'">
                      {{ record.uploadStatus }}
                    </a-tag>
                  </template>
                  <template v-if="column.key === 'action'">
                    <a-space :size="8">
                      <a-button type="link" size="small" @click="handleViewAudioPackageDetail(record)">
                        详情
                      </a-button>
                      <a-button type="link" size="small" @click="handleEditAudioPackage(record)">
                        编辑
                      </a-button>
                      <a-button
                        type="link"
                        size="small"
                        @click="handleSetDefaultAudioPackage(record)"
                        v-if="!record.isDefault"
                      >
                        设为默认
                      </a-button>
                      <a-popconfirm
                        title="确定删除该录音包？"
                        ok-text="确定"
                        cancel-text="取消"
                        @confirm="handleDeleteAudioPackage(record)"
                      >
                        <a-button
                          type="link"
                          size="small"
                          danger
                          :disabled="audioPackageList.length === 1"
                        >
                          删除
                        </a-button>
                      </a-popconfirm>
                    </a-space>
                  </template>
                </template>
              </a-table>
            </div>
          </div>
        </div>

        <!-- 录音详情页面 -->
        <div v-else class="audio-detail-list">
          <!-- 顶部操作区 -->
          <div class="script-toolbar-section">
            <div class="script-toolbar-left">
              <a-space>
                <a-button @click="handleBackToAudioPackage">
                  <left-outlined />
                  返回录音包列表
                </a-button>
                <a-divider type="vertical" />
                <span class="current-package-name">当前录音包：{{ currentAudioPackage?.packageName || '' }}</span>
              </a-space>
            </div>
            <div class="script-toolbar-right">
              <a-space>
                <a-button @click="handleImportAudio">
                  <upload-outlined />
                  批量导入录音
                </a-button>
                <a-button @click="handleVoiceCheck">语音检测</a-button>
              </a-space>
            </div>
          </div>

          <!-- 录音列表表格 -->
          <div class="script-list">
            <div class="script-table-wrapper">
              <a-table
                :columns="audioColumns"
                :data-source="scriptList"
                :pagination="false"
                row-key="id"
                size="middle"
                :scroll="{ x: 1000 }"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'uid'">
                    <span>{{ record.uid }}</span>
                  </template>
                  <template v-if="column.key === 'replyText'">
                    <span class="script-reply-text">{{ record.replyText }}</span>
                  </template>
                  <template v-if="column.key === 'recordFileName'">
                    <span>{{ record.recordFileName }}</span>
                  </template>
                  <template v-if="column.key === 'audio'">
                    <audio
                      v-if="record.audioUrl"
                      :src="record.audioUrl"
                      controls
                      style="height: 32px;"
                      @error="(e) => handleAudioError(e, record)"
                    >
                      您的浏览器不支持音频播放
                    </audio>
                    <span v-else style="color: #999;">暂无录音</span>
                  </template>
                  <template v-if="column.key === 'audioUploadStatus'">
                    <a-tag :color="record.audioUploadStatus === '已上传' ? 'green' : 'default'">
                      {{ record.audioUploadStatus || '未上传' }}
                    </a-tag>
                  </template>
                  <template v-if="column.key === 'action'">
                    <a-space :size="8">
                      <a-button type="link" size="small" @click="triggerAudioFileSelect">
                        <upload-outlined />
                        上传录音
                      </a-button>
                    </a-space>
                  </template>
                </template>
              </a-table>
            </div>
          </div>
        </div>
      </div>

      <!-- 话术变量内容 -->
      <div v-else-if="scriptSubTabKey === 'variable'" class="script-sub-content">
        <!-- 顶部操作区 -->
        <div class="script-toolbar-section">
          <div class="script-toolbar-left">
            <a-space>
              <a-input
                v-model:value="variableSearchKeyword"
                placeholder="请输入变量名搜索"
                style="width: 200px"
                @press-enter="handleVariableSearch"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-button type="primary" @click="handleVariableSearch">
                <search-outlined />
                搜索
              </a-button>
              <a-button @click="handleScriptReset">
                <reload-outlined />
                重置
              </a-button>
            </a-space>
          </div>
          <div class="script-toolbar-right">
            <a-space>
              <a-button type="primary" @click="handleAddVariable">
                <plus-outlined />
                导入变量
              </a-button>
            </a-space>
          </div>
        </div>

        <!-- 变量列表表格 -->
        <div class="script-list">
          <div class="script-table-wrapper">
            <a-table
              :columns="variableColumns"
              :data-source="variableList"
              :pagination="false"
              row-key="id"
              size="middle"
              :scroll="{ x: 1000 }"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'variableName'">
                  <span class="variable-name">{{ record.variableName }}</span>
                </template>
                <template v-if="column.key === 'variableValue'">
                  <a-input
                    v-if="editingVariableId === record.id"
                    v-model:value="record.variableValue"
                    placeholder="请输入变量值，多个值用半角分号 ; 分隔"
                    style="width: 100%"
                    @press-enter="handleSaveVariableValue(record)"
                  />
                  <span v-else class="variable-value-text" @click="handleEditVariableValue(record)">
                    {{ record.variableValue || '-' }}
                  </span>
                </template>
                <template v-if="column.key === 'action'">
                  <a-space :size="8">
                    <a-button
                      v-if="editingVariableId === record.id"
                      type="link"
                      size="small"
                      @click="handleSaveVariableValue(record)"
                    >
                      保存
                    </a-button>
                    <a-button
                      v-else
                      type="link"
                      size="small"
                      @click="handleEditVariableValue(record)"
                    >
                      编辑
                    </a-button>
                  </a-space>
                </template>
              </template>
            </a-table>
          </div>
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
  DownOutlined,
  EditOutlined,
  ReloadOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  UploadOutlined,
  LeftOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnsType, TablePaginationConfig } from 'ant-design-vue';

// ==================== 接口定义 ====================
interface ScriptItem {
  id: number;
  uid: number;
  replyText: string;
  variableValue?: string;
  recordFileName: string;
  audioUrl: string;
  complianceStatus?: '消保通过' | '消保不通过' | '未消保';
  audioUploadStatus?: '已上传' | '未上传';
  source?: string;
}

interface AudioPackageItem {
  id: number;
  packageName: string;
  recorder: string;
  progressPercent: number;
  completedCount: number;
  totalCount: number;
  uploadStatus: string;
  isDefault: boolean;
}

interface VariableItem {
  id: number;
  variableName: string;
  variableValue: string;
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: string;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void;
  (e: 'sub-tab-change', key: string): void;
  (e: 'script-search', keyword: string): void;
  (e: 'script-reset'): void;
  (e: 'batch-delete-selected'): void;
  (e: 'batch-delete-all'): void;
  (e: 'batch-export-selected'): void;
  (e: 'batch-export-all'): void;
  (e: 'edit-script', script: ScriptItem): void;
  (e: 'compliance-pass', script: ScriptItem): void;
  (e: 'compliance-reject', script: ScriptItem): void;
  (e: 'create-audio-package'): void;
  (e: 'audio-package-search', keyword: string): void;
  (e: 'audio-package-reset'): void;
  (e: 'view-audio-package-detail', pkg: AudioPackageItem): void;
  (e: 'edit-audio-package', pkg: AudioPackageItem): void;
  (e: 'set-default-audio-package', pkg: AudioPackageItem): void;
  (e: 'delete-audio-package', pkg: AudioPackageItem): void;
  (e: 'back-to-audio-package'): void;
  (e: 'import-audio'): void;
  (e: 'voice-check'): void;
  (e: 'trigger-audio-file-select'): void;
  (e: 'add-variable'): void;
  (e: 'variable-search', keyword: string): void;
  (e: 'edit-variable-value', variable: VariableItem): void;
  (e: 'save-variable-value', variable: VariableItem): void;
}>();

// ==================== 响应式数据 ====================
// 话术管理子 tab
const scriptSubTabKey = ref('compliance');

// 话术搜索关键词
const scriptSearchKeyword = ref('');

// 选中的话术行
const selectedScriptRowKeys = ref<number[]>([]);

// 话术列表数据（模拟数据）
const scriptList = ref<ScriptItem[]>([
  {
    id: 1,
    uid: 1,
    replyText: '您好，您建行卡内有小额定期存款可以转出，请登录中国建设银行 APP 点击转账进入定活互转然后点击定期转活期，即可操作，祝您生活愉快，再见！',
    variableValue: '',
    recordFileName: 'nlg_2',
    audioUrl: '',
    complianceStatus: '未消保',
    audioUploadStatus: '未上传',
    source: '主流程',
  },
  {
    id: 2,
    uid: 2,
    replyText: '尊敬的客户您好，这里是建行客服中心，关于您之前咨询的理财产品，我们最近有新活动，年化收益率最高可达 4.5%，有兴趣了解一下吗？',
    variableValue: '{customerName: 张先生}',
    recordFileName: 'nlg_3',
    audioUrl: '/audio/nlg_3.mp3',
    complianceStatus: '消保通过',
    audioUploadStatus: '已上传',
    source: 'QA.你是哪个银行',
  },
  {
    id: 3,
    uid: 3,
    replyText: '您好，这里是建行信用卡中心，检测到您的信用卡账单已逾期，请尽快还款，否则将影响您的个人征信记录。',
    variableValue: '{cardNo: ****1234}',
    recordFileName: 'nlg_4',
    audioUrl: '/audio/nlg_4.mp3',
    complianceStatus: '消保不通过',
    audioUploadStatus: '已上传',
    source: 'QA.信用卡逾期怎么办',
  },
  {
    id: 4,
    uid: 4,
    replyText: '尊敬的客户，感谢您使用建行服务，您的贷款申请已审批通过，请携带有效身份证件到就近网点办理签约手续。',
    variableValue: '{loanAmount: 50 万}',
    recordFileName: 'nlg_5',
    audioUrl: '',
    complianceStatus: '消保通过',
    audioUploadStatus: '未上传',
    source: '主流程',
  },
  {
    id: 5,
    uid: 5,
    replyText: '您好，建行提醒您，您的信用卡积分即将到期，请尽快登录建行手机银行兑换精美礼品，过期将自动清零。',
    variableValue: '{points: 10000}',
    recordFileName: 'nlg_6',
    audioUrl: '/audio/nlg_6.mp3',
    complianceStatus: '未消保',
    audioUploadStatus: '已上传',
    source: 'QA.积分兑换',
  },
]);

// 话术分页
const scriptPagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 5,
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

// 话术总数
const scriptTotal = ref(5);

// 录音包列表数据（模拟数据）
const audioPackageList = ref<AudioPackageItem[]>([
  { id: 1, packageName: '默认录音', recorder: '录音师 XXX', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: true },
  { id: 2, packageName: '坐席 1 线下录音', recorder: '坐席 1', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 3, packageName: '坐席 1 声音复刻生成录音', recorder: '坐席 1', progressPercent: 100, completedCount: 100, totalCount: 200, uploadStatus: '已完成', isDefault: false },
  { id: 4, packageName: '坐席 2 声音复刻生成录音', recorder: '坐席 2', progressPercent: 0, completedCount: 0, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 5, packageName: '坐席 3 声音复刻生成录音', recorder: '坐席 3', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 6, packageName: '坐席 4 声音复刻生成录音', recorder: '坐席 4', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
  { id: 7, packageName: '坐席 5 声音复刻生成录音', recorder: '坐席 5', progressPercent: 50, completedCount: 100, totalCount: 200, uploadStatus: '未完成', isDefault: false },
]);

// 录音包分页
const audioPackagePagination = reactive<TablePaginationConfig>({
  current: 1,
  pageSize: 10,
  total: 7,
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

// 录音包搜索关键词
const audioPackageSearchKeyword = ref('');

// 当前选中的录音包
const currentAudioPackage = ref<AudioPackageItem | null>(null);

// 是否显示录音详情列表
const showAudioDetail = ref(false);

// 当前正在编辑的变量 ID
const editingVariableId = ref<number | null>(null);

// 变量搜索关键词
const variableSearchKeyword = ref('');

// 变量列表数据（模拟数据）
const variableList = ref<VariableItem[]>([
  { id: 1, variableName: 'customerName', variableValue: '张先生' },
  { id: 2, variableName: 'cardNo', variableValue: '****1234' },
  { id: 3, variableName: 'loanAmount', variableValue: '50 万' },
  { id: 4, variableName: 'points', variableValue: '10000' },
  { id: 5, variableName: 'productRate', variableValue: '4.5%' },
]);

// ==================== 表格列配置 ====================
// 话术表格列配置
const scriptColumns: TableColumnsType = [
  {
    title: 'uid',
    dataIndex: 'uid',
    key: 'uid',
    width: 70,
    fixed: 'left' as const,
  },
  {
    title: '话术来源',
    dataIndex: 'source',
    key: 'source',
    width: 120,
  },
  {
    title: '话术文本',
    dataIndex: 'replyText',
    key: 'replyText',
    width: 350,
    ellipsis: true,
  },
  {
    title: '变量值',
    dataIndex: 'variableValue',
    key: 'variableValue',
    width: 100,
  },
  {
    title: '消保状态',
    dataIndex: 'complianceStatus',
    key: 'complianceStatus',
    width: 100,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
];

// 录音表格列配置
const audioColumns: TableColumnsType = [
  {
    title: 'uid',
    dataIndex: 'uid',
    key: 'uid',
    width: 70,
    fixed: 'left' as const,
  },
  {
    title: '话术文本',
    dataIndex: 'replyText',
    key: 'replyText',
    width: 300,
    ellipsis: true,
  },
  {
    title: '录音文件名',
    dataIndex: 'recordFileName',
    key: 'recordFileName',
    width: 150,
  },
  {
    title: '录音上传状态',
    dataIndex: 'audioUploadStatus',
    key: 'audioUploadStatus',
    width: 100,
  },
  {
    title: '话术录音',
    key: 'audio',
    width: 300,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
];

// 录音包表格列配置
const audioPackageColumns: TableColumnsType = [
  {
    title: '录音包名称',
    dataIndex: 'packageName',
    key: 'packageName',
    width: 200,
  },
  {
    title: '录音师',
    dataIndex: 'recorder',
    key: 'recorder',
    width: 150,
  },
  {
    title: '录音进度',
    dataIndex: 'progress',
    key: 'progress',
    width: 250,
  },
  {
    title: '录音上传状态',
    dataIndex: 'uploadStatus',
    key: 'uploadStatus',
    width: 120,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right' as const,
  },
];

// 变量表格列配置
const variableColumns: TableColumnsType = [
  {
    title: '变量名',
    dataIndex: 'variableName',
    key: 'variableName',
    width: 200,
  },
  {
    title: '变量值',
    dataIndex: 'variableValue',
    key: 'variableValue',
    width: 400,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    fixed: 'right' as const,
  },
];

// ==================== 方法 ====================
// 获取消保状态颜色
const getComplianceStatusColor = (status?: string): string => {
  const colorMap: Record<string, string> = {
    '消保通过': 'green',
    '消保不通过': 'red',
    '未消保': 'default',
  };
  return colorMap[status || '未消保'] || 'default';
};

// 话术子 tab 变化
const handleScriptSubTabChange = (key: string) => {
  emit('sub-tab-change', key);
};

// 话术搜索
const handleScriptSearch = () => {
  emit('script-search', scriptSearchKeyword.value);
};

// 话术重置
const handleScriptReset = () => {
  scriptSearchKeyword.value = '';
  variableSearchKeyword.value = '';
  audioPackageSearchKeyword.value = '';
  emit('script-reset');
};

// 批量删除所选
const handleBatchDeleteSelected = () => {
  emit('batch-delete-selected');
};

// 批量删除全部
const handleBatchDeleteAll = () => {
  emit('batch-delete-all');
};

// 批量导出所选
const handleBatchExportSelected = () => {
  emit('batch-export-selected');
};

// 批量导出全部
const handleBatchExportAll = () => {
  emit('batch-export-all');
};

// 编辑话术
const handleEditScript = (record: ScriptItem) => {
  emit('edit-script', record);
};

// 消保通过
const handleCompliancePass = (record: ScriptItem) => {
  emit('compliance-pass', record);
};

// 消保不通过
const handleComplianceReject = (record: ScriptItem) => {
  emit('compliance-reject', record);
};

// 话术表格行选择变化
const onScriptSelectChange = (selectedRowKeys: (string | number)[]) => {
  selectedScriptRowKeys.value = selectedRowKeys as number[];
};

// 话术表格变化
const handleScriptTableChange = (pagination: TablePaginationConfig) => {
  scriptPagination.current = pagination.current;
  scriptPagination.pageSize = pagination.pageSize;
  scriptPagination.total = pagination.total;
};

// 话术分页变化
const handleScriptPageChange = (page: number, pageSize: number) => {
  console.log('话术分页变化:', page, pageSize);
};

// 话术每页条数变化
const handleScriptPageSizeChange = (current: number, size: number) => {
  console.log('话术每页条数变化:', current, size);
};

// 新建录音包
const handleCreateAudioPackage = () => {
  emit('create-audio-package');
};

// 录音包搜索
const handleAudioPackageSearch = () => {
  emit('audio-package-search', audioPackageSearchKeyword.value);
};

// 录音包重置
const handleAudioPackageReset = () => {
  audioPackageSearchKeyword.value = '';
  emit('audio-package-reset');
};

// 查看录音包详情
const handleViewAudioPackageDetail = (record: AudioPackageItem) => {
  currentAudioPackage.value = record;
  showAudioDetail.value = true;
  emit('view-audio-package-detail', record);
};

// 编辑录音包
const handleEditAudioPackage = (record: AudioPackageItem) => {
  emit('edit-audio-package', record);
};

// 设为默认录音包
const handleSetDefaultAudioPackage = (record: AudioPackageItem) => {
  emit('set-default-audio-package', record);
};

// 删除录音包
const handleDeleteAudioPackage = (record: AudioPackageItem) => {
  emit('delete-audio-package', record);
};

// 返回录音包列表
const handleBackToAudioPackage = () => {
  showAudioDetail.value = false;
  currentAudioPackage.value = null;
  emit('back-to-audio-package');
};

// 批量导入录音
const handleImportAudio = () => {
  emit('import-audio');
};

// 语音检测
const handleVoiceCheck = () => {
  emit('voice-check');
};

// 触发音频文件选择
const triggerAudioFileSelect = () => {
  emit('trigger-audio-file-select');
};

// 音频播放错误处理
const handleAudioError = (e: Event, record: ScriptItem) => {
  console.error('音频播放错误:', e, record);
};

// 录音包表格变化
const handleAudioPackageTableChange = (pagination: TablePaginationConfig) => {
  audioPackagePagination.current = pagination.current;
  audioPackagePagination.pageSize = pagination.pageSize;
  audioPackagePagination.total = pagination.total;
};

// 变量搜索
const handleVariableSearch = () => {
  emit('variable-search', variableSearchKeyword.value);
};

// 导入变量
const handleAddVariable = () => {
  emit('add-variable');
};

// 编辑变量值
const handleEditVariableValue = (record: VariableItem) => {
  editingVariableId.value = record.id;
  emit('edit-variable-value', record);
};

// 保存变量值
const handleSaveVariableValue = (record: VariableItem) => {
  editingVariableId.value = null;
  emit('save-variable-value', record);
};
</script>

<style scoped>
/* 话术管理内容区域 */
.script-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
  padding: 0;
}

.script-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
  width: 100%;
}

/* 话术管理子标签页 */
.script-sub-tabs {
  background: #fff;
  padding: 0 24px;
  margin-bottom: 16px;
}

.script-sub-tabs :deep(.ant-tabs-nav) {
  margin: 0;
}

.script-sub-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 录音包列表和录音详情列表 */
.audio-package-list,
.audio-detail-list {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 进度条单元格 */
.progress-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-cell .progress-text {
  font-size: 13px;
  color: #595959;
  white-space: nowrap;
}

/* 当前录音包名称 */
.current-package-name {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

/* 顶部操作区 */
.script-toolbar-section {
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

.script-toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.script-toolbar-right {
  display: flex;
  align-items: center;
}

/* 话术列表 */
.script-list {
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  flex: 1;
  min-height: 0;
  overflow: hidden;
  padding: 16px 0;
}

.script-table-wrapper {
  flex: 1;
  overflow: auto;
  min-height: 0;
  padding: 0 16px;
}

.script-list :deep(.ant-table) {
  font-size: 13px;
}

.script-list :deep(.ant-table-wrapper) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.script-list :deep(.ant-table-container) {
  flex: 1;
  overflow: auto;
}

.script-list :deep(.ant-table-thead > tr > th) {
  background: #fafafa;
  font-weight: 500;
  white-space: nowrap;
}

.script-list :deep(.ant-table-fixed-right) {
  position: sticky;
  right: 0;
  z-index: 10;
  background: #fff;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.1);
}

.script-list :deep(.ant-table-cell-fix-right) {
  background: #fff;
}

.script-reply-text {
  display: block;
  white-space: normal;
  line-height: 1.6;
  color: #333;
  max-height: 100px;
  overflow-y: auto;
}

.variable-name {
  font-family: monospace;
  color: #1890ff;
  background: #f0f5ff;
  padding: 2px 6px;
  border-radius: 3px;
}

.variable-value-text {
  cursor: pointer;
  color: #595959;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
}

.variable-value-text:hover {
  background: #f5f5f5;
  color: #1890ff;
}

.script-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: transparent;
  padding: 8px 16px;
  flex-shrink: 0;
}

.script-pagination .selected-count {
  color: #666;
  font-size: 13px;
}

/* 消保下拉菜单样式 */
.compliance-pass {
  color: #52c41a !important;
}

.compliance-pass .pass-text {
  color: #52c41a;
}

.compliance-reject {
  color: #ff4d4f !important;
}

.compliance-reject .reject-text {
  color: #ff4d4f;
}

/* 话术管理滚动条样式 */
.script-list::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.script-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.script-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 4px;
}

.script-list::-webkit-scrollbar-thumb:hover {
  background: #999;
}
</style>
