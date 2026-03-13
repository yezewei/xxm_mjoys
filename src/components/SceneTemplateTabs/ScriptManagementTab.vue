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

    <!-- 新建录音包弹窗 -->
    <a-modal
      v-model:open="createAudioPackageModalVisible"
      title="新建录音包"
      width="600px"
      :mask-closable="false"
      @ok="handleCreateAudioPackageSubmit"
      @cancel="handleCreateAudioPackageCancel"
    >
      <a-form
        ref="createAudioPackageFormRef"
        :model="createAudioPackageForm"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item
          label="录音包名称"
          name="packageName"
          :rules="[{ required: true, message: '请输入录音包名称' }]"
        >
          <a-input v-model:value="createAudioPackageForm.packageName" placeholder="请输入录音包名称" />
        </a-form-item>
        <a-form-item
          label="录音师"
          name="recorder"
          :rules="[{ required: true, message: '请输入录音师' }]"
        >
          <a-input v-model:value="createAudioPackageForm.recorder" placeholder="请输入录音师" />
        </a-form-item>
      </a-form>
      <template #footer>
        <a-button @click="handleCreateAudioPackageCancel">取消</a-button>
        <a-button type="primary" @click="handleCreateAudioPackageSubmit">确定</a-button>
      </template>
    </a-modal>

    <!-- 编辑录音包弹窗 -->
    <a-modal
      v-model:open="editAudioPackageModalVisible"
      title="编辑录音包"
      width="600px"
      :mask-closable="false"
      @ok="handleEditAudioPackageSubmit"
      @cancel="handleEditAudioPackageCancel"
    >
      <a-form
        ref="editAudioPackageFormRef"
        :model="editAudioPackageForm"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item
          label="录音包名称"
          name="packageName"
          :rules="[{ required: true, message: '请输入录音包名称' }]"
        >
          <a-input v-model:value="editAudioPackageForm.packageName" placeholder="请输入录音包名称" />
        </a-form-item>
        <a-form-item
          label="录音师"
          name="recorder"
          :rules="[{ required: true, message: '请输入录音师' }]"
        >
          <a-input v-model:value="editAudioPackageForm.recorder" placeholder="请输入录音师" />
        </a-form-item>
      </a-form>
      <template #footer>
        <a-button @click="handleEditAudioPackageCancel">取消</a-button>
        <a-button type="primary" @click="handleEditAudioPackageSubmit">确定</a-button>
      </template>
    </a-modal>

    <!-- 编辑话术弹窗 -->
    <a-modal
      v-model:open="editScriptModalVisible"
      title="编辑话术"
      width="700px"
      :mask-closable="false"
      @ok="handleEditScriptSubmit"
      @cancel="handleEditScriptCancel"
    >
      <a-form
        ref="editScriptFormRef"
        :model="editScriptForm"
        :label-col="{ span: 4 }"
        :wrapper-col="{ span: 19 }"
      >
        <a-form-item
          label="话术文本"
          name="replyText"
          :rules="[{ required: true, message: '请输入话术文本' }]"
        >
          <a-textarea
            v-model:value="editScriptForm.replyText"
            :rows="6"
            placeholder="请输入话术文本"
          />
        </a-form-item>
      </a-form>
      <template #footer>
        <a-button @click="handleEditScriptCancel">取消</a-button>
        <a-button type="primary" @click="handleEditScriptSubmit">确定</a-button>
      </template>
    </a-modal>

    <!-- 导入变量弹窗 -->
    <a-modal
      v-model:open="importVariableModalVisible"
      title="导入变量"
      width="550px"
      :mask-closable="false"
      @cancel="handleImportVariableCancel"
    >
      <div class="import-variable-content" style="padding: 10px 0;">
        <!-- 步骤 1：下载模板 -->
        <div class="import-step" style="margin-bottom: 20px;">
          <div class="step-header" style="display: flex; align-items: center; margin-bottom: 12px;">
            <span class="step-number" style="display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; background: #1890ff; color: #fff; border-radius: 50%; font-size: 12px; font-weight: 500; margin-right: 8px;">1</span>
            <span class="step-title" style="font-size: 14px; font-weight: 500; color: #262626;">下载变量模板</span>
          </div>
          <p style="margin: 0 0 12px 32px; font-size: 13px; color: #595959;">请先下载变量模板文件，按照模板格式填写变量数据</p>
          <a-button type="primary" block @click="handleDownloadVariableTemplate" style="margin-left: 32px; width: calc(100% - 32px);">
            <download-outlined />
            下载变量模板
          </a-button>
        </div>

        <!-- 步骤 2：上传文件 -->
        <div class="import-step">
          <div class="step-header" style="display: flex; align-items: center; margin-bottom: 12px;">
            <span class="step-number" style="display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; background: #52c41a; color: #fff; border-radius: 50%; font-size: 12px; font-weight: 500; margin-right: 8px;">2</span>
            <span class="step-title" style="font-size: 14px; font-weight: 500; color: #262626;">上传变量文件</span>
          </div>
          <p style="margin: 0 0 12px 32px; font-size: 13px; color: #595959;">填写完成后，上传变量文件进行导入</p>
          <a-button block @click="triggerVariableFileSelect" style="margin-left: 32px; width: calc(100% - 32px);">
            <upload-outlined />
            上传变量文件
          </a-button>
        </div>

        <!-- 提示信息 -->
        <a-alert
          type="info"
          style="margin-top: 20px;"
          message="支持格式：.xlsx, .xls, .csv"
          show-icon
        />
      </div>
      <template #footer>
        <a-button @click="handleImportVariableCancel">关闭</a-button>
      </template>
    </a-modal>

    <!-- 隐藏的文件输入框用于上传变量 -->
    <input
      ref="variableFileInputRef"
      type="file"
      accept=".xlsx,.xls,.csv"
      style="display: none"
      @change="handleVariableFileChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { message, Modal } from 'ant-design-vue';
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
  DownloadOutlined,
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

// ==================== 弹窗相关数据 ====================
// 编辑话术弹窗
const editScriptModalVisible = ref(false);
const editScriptFormRef = ref();
const editScriptForm = reactive({
  id: 0,
  replyText: '',
});

// 导入变量弹窗
const importVariableModalVisible = ref(false);
const variableFileInputRef = ref<HTMLInputElement>();

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
  console.log('切换话术子 tab:', key);
  // 切换 tab 时重置搜索条件
  scriptSearchKeyword.value = '';
  audioPackageSearchKeyword.value = '';
  variableSearchKeyword.value = '';
  emit('sub-tab-change', key);
};

// 话术搜索
const handleScriptSearch = () => {
  console.log('搜索话术:', scriptSearchKeyword.value);
  message.info(`搜索：${scriptSearchKeyword.value || '全部'}`);
  // TODO: 实现搜索逻辑
};

// 话术重置
const handleScriptReset = () => {
  scriptSearchKeyword.value = '';
  audioPackageSearchKeyword.value = '';
  variableSearchKeyword.value = '';
  console.log('重置话术搜索');
  message.success('已重置搜索条件');
};

// 批量删除 - 删除所选
const handleBatchDeleteSelected = () => {
  if (selectedScriptRowKeys.value.length === 0) {
    message.warning('请先选择要删除的话术');
    return;
  }
  Modal.confirm({
    title: '删除选中',
    content: `删除后对应话术来源配置的话术文本将被清空，确定要删除选中的 ${selectedScriptRowKeys.value.length} 条话术吗？此操作不可恢复！`,
    okText: '确定',
    cancelText: '取消',
    onOk: () => {
      scriptList.value = scriptList.value.filter(item => !selectedScriptRowKeys.value.includes(item.id));
      selectedScriptRowKeys.value = [];
      scriptTotal.value = scriptList.value.length;
      message.success('删除选中话术成功');
    },
  });
};

// 批量删除 - 删除全部
const handleBatchDeleteAll = () => {
  Modal.confirm({
    title: '删除全部',
    content: '删除后对应话术来源配置的话术文本将被清空，确定要删除全部话术吗？此操作不可恢复！',
    okText: '确定',
    cancelText: '取消',
    onOk: () => {
      scriptList.value = [];
      selectedScriptRowKeys.value = [];
      scriptTotal.value = 0;
      message.success('删除全部话术成功');
    },
  });
};

// 批量导出 - 导出所选
const handleBatchExportSelected = () => {
  if (selectedScriptRowKeys.value.length === 0) {
    message.warning('请先选择要导出的话术');
    return;
  }
  const selectedScripts = scriptList.value.filter(item => selectedScriptRowKeys.value.includes(item.id));
  console.log('导出选中话术:', selectedScripts);
  message.success(`已导出 ${selectedScripts.length} 条话术`);
};

// 批量导出 - 导出全部
const handleBatchExportAll = () => {
  console.log('导出全部话术:', scriptList.value);
  message.success(`已导出 ${scriptList.value.length} 条话术`);
};

// 编辑话术
const handleEditScript = (record: ScriptItem) => {
  console.log('编辑话术:', record);
  editScriptForm.id = record.id;
  editScriptForm.replyText = record.replyText;
  editScriptModalVisible.value = true;
};

// 取消编辑话术
const handleEditScriptCancel = () => {
  editScriptModalVisible.value = false;
  editScriptFormRef.value?.resetFields();
};

// 提交编辑话术
const handleEditScriptSubmit = async () => {
  try {
    await editScriptFormRef.value?.validate();
    // 找到对应的话术并更新
    const record = scriptList.value.find(item => item.id === editScriptForm.id);
    if (record) {
      // 仅当话术内容发生变化时才更新
      if (record.replyText !== editScriptForm.replyText) {
        record.replyText = editScriptForm.replyText;
        // 话术发生变化时重置消保状态为未消保
        record.complianceStatus = '未消保';
        message.success('保存话术成功，内容已更新，消保状态已重置为未消保');
      } else {
        message.info('话术内容未发生变化');
      }
    }
    editScriptModalVisible.value = false;
    editScriptFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 消保通过
const handleCompliancePass = (record: ScriptItem) => {
  record.complianceStatus = '消保通过';
  message.success('已设置为消保通过');
};

// 消保不通过
const handleComplianceReject = (record: ScriptItem) => {
  record.complianceStatus = '消保不通过';
  message.success('已设置为消保不通过');
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
  console.log('话术表格变化:', pagination);
};

// 话术分页变化
const handleScriptPageChange = (page: number, pageSize: number) => {
  scriptPagination.current = page;
  console.log('话术分页变化:', page, pageSize);
};

// 话术每页条数变化
const handleScriptPageSizeChange = (current: number, size: number) => {
  scriptPagination.pageSize = size;
  scriptPagination.current = 1;
  console.log('话术每页条数变化:', current, size);
};

// 新建录音包
const handleCreateAudioPackage = () => {
  createAudioPackageForm.packageName = '';
  createAudioPackageForm.recorder = '';
  createAudioPackageModalVisible.value = true;
};

// 录音包搜索
const handleAudioPackageSearch = () => {
  console.log('搜索录音包:', audioPackageSearchKeyword.value);
  message.info(`搜索：${audioPackageSearchKeyword.value || '全部'}`);
};

// 录音包重置
const handleAudioPackageReset = () => {
  audioPackageSearchKeyword.value = '';
  console.log('重置录音包搜索');
  message.success('已重置搜索条件');
};

// 查看录音包详情
const handleViewAudioPackageDetail = (record: AudioPackageItem) => {
  currentAudioPackage.value = record;
  showAudioDetail.value = true;
  console.log('查看录音包详情:', record);
};

// 编辑录音包
const handleEditAudioPackage = (record: AudioPackageItem) => {
  editAudioPackageForm.id = record.id;
  editAudioPackageForm.packageName = record.packageName;
  editAudioPackageForm.recorder = record.recorder;
  editAudioPackageModalVisible.value = true;
  console.log('编辑录音包:', record);
};

// 设为默认录音包
const handleSetDefaultAudioPackage = (record: AudioPackageItem) => {
  // 将所有录音包的 isDefault 设为 false
  audioPackageList.value.forEach(item => {
    item.isDefault = false;
  });
  // 将当前录音包设为默认
  record.isDefault = true;
  message.success('已设为默认录音包');
};

// 删除录音包
const handleDeleteAudioPackage = (record: AudioPackageItem) => {
  // 至少保留一个录音包
  if (audioPackageList.value.length === 1) {
    message.warning('至少保留一个录音包');
    return;
  }
  console.log('删除录音包:', record);
  const index = audioPackageList.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    audioPackageList.value.splice(index, 1);
    message.success('删除录音包成功');
  }
};

// 返回录音包列表
const handleBackToAudioPackage = () => {
  showAudioDetail.value = false;
  currentAudioPackage.value = null;
};

// 批量导入录音
const handleImportAudio = () => {
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'audio/*';
  input.onchange = (e) => {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      console.log('导入录音文件:', target.files[0]);
      message.success('录音导入成功');
    }
  };
  input.click();
};

// 语音检测
const handleVoiceCheck = () => {
  message.info('开始语音检测...');
  console.log('语音检测');
};

// 触发音频文件选择
const triggerAudioFileSelect = () => {
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'audio/*';
  input.onchange = (e) => {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      console.log('上传录音文件:', target.files[0]);
      message.success('录音上传成功');
    }
  };
  input.click();
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
  console.log('录音包表格变化:', pagination);
};

// 变量搜索
const handleVariableSearch = () => {
  console.log('搜索变量:', variableSearchKeyword.value);
  message.info(`搜索：${variableSearchKeyword.value || '全部'}`);
};

// 导入变量
const handleAddVariable = () => {
  importVariableModalVisible.value = true;
};

// 下载变量模板
const handleDownloadVariableTemplate = () => {
  console.log('下载变量模板');
  // 创建示例模板数据
  const templateData = '变量名，变量值\ncustomerName，张先生\ncardNo，****1234\nloanAmount，50 万\npoints，10000';
  const blob = new Blob([templateData], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = '变量模板.csv';
  link.click();
  URL.revokeObjectURL(link.href);
  message.success('模板下载成功');
};

// 触发变量文件选择
const triggerVariableFileSelect = () => {
  variableFileInputRef.value?.click();
};

// 变量文件变化处理
const handleVariableFileChange = (e: Event) => {
  const target = e.target as HTMLInputElement;
  if (target.files && target.files.length > 0) {
    const file = target.files[0];
    console.log('上传变量文件:', file);
    // TODO: 实现文件解析和导入逻辑
    message.success(`文件"${file.name}"上传成功，正在导入...`);
    // 清空文件输入框，允许重复选择同一文件
    target.value = '';
    importVariableModalVisible.value = false;
  }
};

// 关闭导入变量弹窗
const handleImportVariableCancel = () => {
  importVariableModalVisible.value = false;
};

// 编辑变量值
const handleEditVariableValue = (record: VariableItem) => {
  editingVariableId.value = record.id;
};

// 保存变量值
const handleSaveVariableValue = (record: VariableItem) => {
  console.log('保存变量值:', record.variableName, record.variableValue);
  editingVariableId.value = null;
  message.success('保存变量值成功');
};

// ==================== 录音包弹窗相关数据和方法 ====================
// 新建录音包弹窗
const createAudioPackageModalVisible = ref(false);
const createAudioPackageFormRef = ref();
const createAudioPackageForm = reactive({
  packageName: '',
  recorder: '',
});

// 编辑录音包弹窗
const editAudioPackageModalVisible = ref(false);
const editAudioPackageFormRef = ref();
const editAudioPackageForm = reactive({
  id: 0,
  packageName: '',
  recorder: '',
});

// 取消新建录音包
const handleCreateAudioPackageCancel = () => {
  createAudioPackageModalVisible.value = false;
  createAudioPackageFormRef.value?.resetFields();
};

// 提交新建录音包
const handleCreateAudioPackageSubmit = async () => {
  try {
    await createAudioPackageFormRef.value?.validate();
    const newPackage = {
      id: Date.now(),
      packageName: createAudioPackageForm.packageName,
      recorder: createAudioPackageForm.recorder,
      progressPercent: 0,
      completedCount: 0,
      totalCount: 200,
      uploadStatus: '未完成',
      isDefault: false,
    };
    audioPackageList.value.push(newPackage);
    message.success('新建录音包成功');
    createAudioPackageModalVisible.value = false;
    createAudioPackageFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 取消编辑录音包
const handleEditAudioPackageCancel = () => {
  editAudioPackageModalVisible.value = false;
  editAudioPackageFormRef.value?.resetFields();
};

// 提交编辑录音包
const handleEditAudioPackageSubmit = async () => {
  try {
    await editAudioPackageFormRef.value?.validate();
    const record = audioPackageList.value.find(item => item.id === editAudioPackageForm.id);
    if (record) {
      record.packageName = editAudioPackageForm.packageName;
      record.recorder = editAudioPackageForm.recorder;
    }
    message.success('编辑录音包成功');
    editAudioPackageModalVisible.value = false;
    editAudioPackageFormRef.value?.resetFields();
  } catch (error) {
    console.error('表单验证失败:', error);
  }
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
