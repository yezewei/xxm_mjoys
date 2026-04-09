<template>
  <div class="data-market">
    <!-- 顶部导航区域 -->
    <div class="page-header-section">
      <div class="page-header">
        <div class="header-left">
          <h2 class="page-title">数据市场</h2>
        </div>
        <a class="header-action" @click="handleSettings">
          <setting-outlined />
          数据市场设置
        </a>
      </div>
    </div>

    <!-- Tab 切换区域 -->
    <div class="tab-section">
      <a-tabs v-model:activeKey="activeTab" :animated="false">
        <a-tab-pane key="subscription" tab="数据订阅">
          <!-- 说明和流程图区域 -->
          <div class="info-flow-section">
            <!-- 收起状态提示 -->
            <div v-if="isCollapsed" class="collapsed-hint" @click="toggleCollapse">
              <down-outlined class="hint-icon" />
              <span class="hint-text">数据订阅说明与流程</span>
              <span class="hint-subtext">点击展开查看详情</span>
              <up-outlined class="expand-icon" />
            </div>

            <!-- 展开内容 -->
            <div v-show="!isCollapsed" class="expanded-content">
              <!-- 顶部操作栏 -->
              <div class="content-header">
                <span class="content-title">数据订阅说明</span>
                <a class="collapse-btn" @click="toggleCollapse">
                  <up-outlined />
                  收起
                </a>
              </div>

              <!-- 说明区域 -->
              <div class="info-section">
                <div class="info-item">
                  <span class="info-label">数据订阅：</span>
                  <span class="info-content">
                    系统将会按设置周期，自动生成前一个周期时间段的数据文件在存储在预设的服务器地址中；您可以通过下载文件的方式获取数据，并用于其他业务系统中。
                  </span>
                </div>
                <div class="info-item">
                  <span class="info-label">文件服务器地址：</span>
                  <span class="info-content file-path">
                    摸象应用服务器 ip:/data/mjoys/xxm-api-data/sync_data/data_market/subscription/
                  </span>
                </div>
                <div class="info-item">
                  <span class="info-label">文件命名规则：</span>
                  <span class="info-content">
                    按分钟生成文件名，数据类型 + 开始日期/时间～结束时间（例如：AI 通话记录 2025 年 04 月 01 日 00 时 00 分~00 时 05 分）；按天生成文件名，数据类型 + 数据日期（例如：AI 通话记录 2025 年 04 月 01 日）
                  </span>
                </div>
              </div>

              <!-- 流程图区域 -->
              <div class="flow-chart-section">
                <div class="flow-title">数据订阅流程</div>
                <div class="flow-chart">
                  <div class="flow-step">
                    <div class="step-icon database-icon">
                      <database-outlined />
                    </div>
                    <div class="step-label">订阅数据</div>
                  </div>
                  <div class="flow-connector">
                    <div class="connector-line"></div>
                    <div class="connector-text">定期生成数据文件</div>
                  </div>
                  <div class="flow-step">
                    <div class="step-icon file-icon">
                      <file-outlined />
                    </div>
                    <div class="step-label">文件服务器</div>
                  </div>
                  <div class="flow-connector">
                    <div class="connector-line"></div>
                  </div>
                  <div class="flow-step">
                    <div class="step-icon download-icon">
                      <download-outlined />
                    </div>
                    <div class="step-label">下载文件</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 数据表格区域 -->
          <div class="table-section">
            <!-- 操作栏 -->
            <div class="table-toolbar">
              <div class="table-toolbar-right">
                <a-button type="primary" @click="handleCreateRule">
                  <plus-outlined />
                  新建订阅规则
                </a-button>
              </div>
            </div>
            <a-table
              :columns="columns"
              :data-source="tableData"
              :pagination="false"
              row-key="id"
              :scroll="{ x: 1800 }"
              :bordered="true"
            >
              <!-- 订阅规则名称列自定义渲染 -->
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'ruleName'">
                  <span class="rule-name-text">{{ record.ruleName }}</span>
                </template>

                <!-- 数据类型列 -->
                <template v-else-if="column.key === 'dataType'">
                  <span class="data-type-text">{{ record.dataType }}</span>
                </template>

                <!-- 数据字段列 - Tag 样式 -->
                <template v-else-if="column.key === 'dataFields'">
                  <div class="field-tags-container">
                    <a-tag
                      v-for="(field, index) in record.dataFields"
                      :key="index"
                      class="field-tag"
                    >
                      {{ field }}
                    </a-tag>
                  </div>
                </template>

                <!-- 订阅范围列 -->
                <template v-else-if="column.key === 'subscriptionRange'">
                  <span class="subscription-range-text">
                    {{ record.subscriptionRange || '暂无限制' }}
                  </span>
                </template>

                <!-- 文件生成时间列 -->
                <template v-else-if="column.key === 'generateTime'">
                  <span class="generate-time-text">{{ record.generateTime }}</span>
                </template>

                <!-- 订阅状态列 - 开关 -->
                <template v-else-if="column.key === 'subscriptionStatus'">
                  <a-switch
                    v-model:checked="record.enabled"
                    checked-children="开启"
                    un-checked-children="停用"
                  />
                </template>

                <!-- 操作列 -->
                <template v-else-if="column.key === 'action'">
                  <div class="action-buttons">
                    <a class="action-btn" @click="handleEditRule(record)">编辑</a>
                    <a-divider type="vertical" />
                    <a-popconfirm
                      title="确定要删除该订阅规则吗？"
                      ok-text="确定"
                      cancel-text="取消"
                      @confirm="handleDelete(record)"
                    >
                      <a class="action-btn delete-btn">删除</a>
                    </a-popconfirm>
                  </div>
                </template>
              </template>
            </a-table>
          </div>
        </a-tab-pane>
        <a-tab-pane key="reissue" tab="数据补发">
          <!-- 说明和流程图区域 -->
          <div class="info-flow-section">
            <!-- 收起状态提示 -->
            <div v-if="isReissueCollapsed" class="collapsed-hint" @click="toggleReissueCollapse">
              <down-outlined class="hint-icon" />
              <span class="hint-text">数据补发说明与流程</span>
              <span class="hint-subtext">点击展开查看详情</span>
              <up-outlined class="expand-icon" />
            </div>

            <!-- 展开内容 -->
            <div v-show="!isReissueCollapsed" class="expanded-content">
              <!-- 顶部操作栏 -->
              <div class="content-header">
                <span class="content-title">数据补发说明</span>
                <a class="collapse-btn" @click="toggleReissueCollapse">
                  <up-outlined />
                  收起
                </a>
              </div>

              <!-- 说明区域 -->
              <div class="info-section">
                <div class="info-item">
                  <span class="info-label">数据补发：</span>
                  <span class="info-content">
                    系统支持对历史产生的业务数据进行补发，选择需要补发的数据类型和需要补发的数据范围，系统生成文件，可在系统"下载任务"中下载。
                  </span>
                </div>
                <div class="info-item">
                  <span class="info-label">文件服务器地址：</span>
                  <span class="info-content file-path">
                    摸象应用服务器 ip:/data/mjoys/xxm-api-data/sync_data/data_market/reissue/
                  </span>
                </div>
                <div class="info-item">
                  <span class="info-label">文件命名规则：</span>
                  <span class="info-content">
                    数据补发 + 数据类型 + 生成日期 + 流水号（例如：补发数据 AI 外呼记录 202505010001）
                  </span>
                </div>
              </div>

              <!-- 流程图区域 -->
              <div class="flow-chart-section">
                <div class="flow-title">数据补发流程</div>
                <div class="flow-chart">
                  <div class="flow-step">
                    <div class="step-icon select-icon">
                      <appstore-outlined />
                    </div>
                    <div class="step-label">选择补发数据</div>
                  </div>
                  <div class="flow-connector">
                    <div class="connector-line"></div>
                    <div class="connector-text">系统生成文件</div>
                  </div>
                  <div class="flow-step">
                    <div class="step-icon task-icon">
                      <unordered-list-outlined />
                    </div>
                    <div class="step-label">下载任务中心</div>
                  </div>
                  <div class="flow-connector">
                    <div class="connector-line"></div>
                  </div>
                  <div class="flow-step">
                    <div class="step-icon download-icon">
                      <download-outlined />
                    </div>
                    <div class="step-label">下载文件</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 数据补发表格 -->
          <div class="table-section">
            <a-table
              :columns="reissueColumns"
              :data-source="reissueTableData"
              :pagination="false"
              row-key="id"
              :scroll="{ x: 1800 }"
              :bordered="true"
            >
              <!-- 数据类型列自定义渲染 -->
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'dataType'">
                  <span class="data-type-text">{{ record.dataType }}</span>
                </template>

                <!-- 数据字段列 - Tag 样式 -->
                <template v-else-if="column.key === 'dataFields'">
                  <div class="field-tags-container">
                    <a-tag
                      v-for="(field, index) in record.dataFields"
                      :key="index"
                      class="field-tag"
                    >
                      {{ field }}
                    </a-tag>
                  </div>
                </template>

                <!-- 操作列 -->
                <template v-else-if="column.key === 'action'">
                  <a-button type="primary" @click="handleReissue(record)">
                    数据补发
                  </a-button>
                </template>
              </template>
            </a-table>
          </div>
        </a-tab-pane>
      </a-tabs>
    </div>

    <!-- 新建/编辑订阅规则对话框 -->
    <a-modal
      v-model:open="createRuleModalVisible"
      :title="isEditMode ? '编辑订阅规则' : '新建订阅规则'"
      @ok="handleCreateRuleConfirm"
      @cancel="handleCreateRuleCancel"
      width="700px"
    >
      <a-form :model="createRuleForm" layout="vertical">
        <a-form-item
          label="订阅规则名称"
          name="ruleName"
          :rules="[{ required: true, message: '请输入订阅规则名称' }]"
        >
          <a-input
            v-model:value="createRuleForm.ruleName"
            placeholder="请输入订阅规则名称"
          />
        </a-form-item>
        <a-form-item
          label="订阅数据类型"
          name="dataType"
          :rules="[{ required: true, message: '请选择订阅数据类型' }]"
        >
          <a-select
            v-model:value="createRuleForm.dataType"
            placeholder="请选择订阅数据类型"
            @change="handleDataTypeChange"
          >
            <a-select-option value="AI 外呼记录">AI 外呼记录</a-select-option>
            <a-select-option value="人工外呼记录">人工外呼记录</a-select-option>
            <a-select-option value="人工跟进记录">人工跟进记录</a-select-option>
            <a-select-option value="免打扰名单">免打扰名单</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="订阅数据范围" name="subscriptionRange">
          <div class="range-section">
            <div class="range-hint">若不设置条件，默认所有数据都订阅</div>
            <div class="condition-groups">
              <div
                v-for="(group, groupIndex) in createRuleForm.conditionGroups"
                :key="groupIndex"
                class="condition-group"
              >
                <div class="condition-group-header" v-if="groupIndex > 0">
                  <span class="or-divider">或者</span>
                </div>
                <div class="condition-list">
                  <div
                    v-for="(condition, conditionIndex) in group.conditions"
                    :key="conditionIndex"
                    class="condition-item"
                  >
                    <a-select
                      v-model:value="condition.field"
                      placeholder="选择字段"
                      class="condition-field"
                      :options="getCurrentFieldsOptions"
                    />
                    <a-select
                      v-model:value="condition.operator"
                      placeholder="运算符"
                      class="condition-operator"
                    >
                      <a-select-option value="=">= 等于</a-select-option>
                      <a-select-option value="!=">≠ 不等于</a-select-option>
                      <a-select-option value="contains">包含</a-select-option>
                      <a-select-option value="notContains">不包含</a-select-option>
                      <a-select-option value=">">&gt; 大于</a-select-option>
                      <a-select-option value=">=">&gt;= 大于等于</a-select-option>
                      <a-select-option value="<">&lt; 小于</a-select-option>
                      <a-select-option value="<=">&lt;= 小于等于</a-select-option>
                    </a-select>
                    <a-input
                      v-model:value="condition.value"
                      placeholder="输入值"
                      class="condition-value"
                    />
                    <a-button
                      type="text"
                      danger
                      @click="removeCondition(groupIndex, conditionIndex)"
                      class="remove-condition"
                    >
                      <delete-outlined />
                    </a-button>
                    <a
                      v-if="conditionIndex === group.conditions.length - 1"
                      class="add-and-condition-btn"
                      @click="addAndCondition(groupIndex)"
                    >
                      <plus-outlined />
                      且条件
                    </a>
                  </div>
                </div>
                <a-button
                  type="text"
                  danger
                  @click="removeGroup(groupIndex)"
                  class="remove-group-btn"
                  v-if="createRuleForm.conditionGroups.length > 1"
                >
                  <delete-outlined />
                </a-button>
              </div>
              <a class="add-or-condition-btn" @click="addOrCondition">
                <plus-outlined />
                或条件
              </a>
            </div>
          </div>
        </a-form-item>
        <a-form-item
          label="文件生成时间"
          name="generateTime"
          :rules="[{ required: true, message: '请选择文件生成时间' }]"
        >
          <a-select
            v-model:value="createRuleForm.generateTime"
            placeholder="请选择文件生成时间"
          >
            <a-select-option value="每 5 分钟">每 5 分钟</a-select-option>
            <a-select-option value="每 10 分钟">每 10 分钟</a-select-option>
            <a-select-option value="每 30 分钟">每 30 分钟</a-select-option>
            <a-select-option value="每 1 小时">每 1 小时</a-select-option>
            <a-select-option value="每 1 天">每 1 天</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import {
  SettingOutlined,
  DatabaseOutlined,
  FileOutlined,
  DownloadOutlined,
  EditOutlined,
  DownOutlined,
  UpOutlined,
  PlusOutlined,
  DeleteOutlined,
  AppstoreOutlined,
  UnorderedListOutlined,
} from '@ant-design/icons-vue';
import type { TableColumnsType } from 'ant-design-vue';

// Tab 激活状态
const activeTab = ref('subscription');

// 收起/展开状态，默认收起
const isCollapsed = ref(true);
const isReissueCollapsed = ref(true);

/**
 * 切换收起/展开状态
 */
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
};

/**
 * 切换数据补发收起/展开状态
 */
const toggleReissueCollapse = () => {
  isReissueCollapsed.value = !isReissueCollapsed.value;
};

// 是否编辑模式
const isEditMode = ref(false);

// 新建/编辑订阅规则对话框
const createRuleModalVisible = ref(false);

// 条件组数据结构
interface Condition {
  field: string;
  operator: string;
  value: string;
}

interface ConditionGroup {
  conditions: Condition[];
}

// 数据类型字段定义
const aiCallFields = [
  'AI 外呼记录 ID', '场景 ID', '场景编号', '场景名称', '任务 ID', '数据批次名称',
  '任务明细 ID', '批次 ID', '数据来源', '批次详情 ID', '主叫号码', '拨打号码',
  '机构编号', '所属机构名称', '客户原始所属直营坐席工号', '客户原始所属直营坐席账号',
  '客户原始所属直营坐席名称', '客户当前所属直营坐席工号', '客户当前所属直营坐席账号',
  '客户当前所属直营坐席名称', '通话状态', '接通状态中文', '拨打时间', '接机时间',
  '挂断时间', '通话时长', '振铃时长', '意向分类', '意向分类描述', '通话标签',
  '通话轮次', '按键输入', '录音地址', '扩展信息', '任务完成状态', '执行日志',
  '联系方式类型', '数据上传人员', '拨打次数', '通话类型', '转接状态', '实体标签',
  'AI 通话时长', '转接等待时长', '人工通话时长', '跟进状态', '回流检测状态',
  '下发状态', '备注', '被叫运营商', '被叫归属地', '企微账号', '加粉状态',
  '验证信息', '对话标签', '模型分类',
];

const manualCallFields = [
  '人工外呼记录 ID', 'AI 外呼记录 ID', '坐席跟进任务 ID', '场景 ID', '场景编号',
  '场景名称', '任务 ID', '数据批次名称', '任务明细 ID', '批次 ID', '客户来源',
  '数据来源', '拨打号码', '机构编号', '所属机构名称', '客户原始所属直营坐席工号',
  '客户原始所属直营坐席账号', '客户原始所属直营坐席名称', '客户当前所属直营坐席工号',
  '客户当前所属直营坐席账号', '客户当前所属直营坐席名称', '通话状态', '拨打时间',
  '接机时间', '挂断时间', '客户振铃时长', '通话时长', '录音地址', '扩展信息',
  '跟进结果',
];

const manualFollowUpFields = [
  '坐席跟进任务记录 ID', '坐席跟进任务 ID', '人工外呼记录 ID', 'AI 外呼记录 ID',
  '场景 ID', '场景编号', '场景名称', '任务 ID', '数据批次名称', '任务明细 ID',
  '批次 ID', '客户来源', '数据来源', '拨打号码', '机构编号', '所属机构名称',
  '跟进时间', '任务分配时间', '客户原始所属直营坐席工号', '客户原始所属直营坐席账号',
  '客户原始所属直营坐席名称', '客户当前所属直营坐席工号', '客户当前所属直营坐席账号',
  '客户当前所属直营坐席名称', '跟进结果', '跟进备注', '跟进标签', '扩展信息',
];

// 免打扰名单字段
const dncFields = [
  '手机号', '用户 ID', '添加时间', '添加来源', '过期时间', '备注',
];

// 数据类型与字段的映射
const dataTypeFieldsMap: Record<string, string[]> = {
  'AI 外呼记录': aiCallFields,
  '人工外呼记录': manualCallFields,
  '人工跟进记录': manualFollowUpFields,
  '免打扰名单': dncFields,
};

const createRuleForm = reactive({
  id: null as number | null,
  ruleName: '',
  dataType: '',
  subscriptionRange: '',
  generateTime: '',
  conditionGroups: [] as ConditionGroup[],
});

// 初始化条件组
const initConditionGroups = () => {
  createRuleForm.conditionGroups = [{ conditions: [{ field: '', operator: '=', value: '' }] }];
};

// 获取当前数据类型的字段选项
const getCurrentFieldsOptions = computed(() => {
  const fields = dataTypeFieldsMap[createRuleForm.dataType] || [];
  return fields.map(field => ({
    label: field,
    value: field,
  }));
});

// 添加且条件
const addAndCondition = (groupIndex: number) => {
  createRuleForm.conditionGroups[groupIndex].conditions.push({
    field: '',
    operator: '=',
    value: '',
  });
};

// 删除条件
const removeCondition = (groupIndex: number, conditionIndex: number) => {
  const group = createRuleForm.conditionGroups[groupIndex];
  if (group.conditions.length > 1) {
    group.conditions.splice(conditionIndex, 1);
  } else {
    // 如果组内只有一个条件，删除整个组
    if (createRuleForm.conditionGroups.length > 1) {
      createRuleForm.conditionGroups.splice(groupIndex, 1);
    }
  }
};

// 添加或条件组
const addOrCondition = () => {
  createRuleForm.conditionGroups.push({
    conditions: [{ field: '', operator: '=', value: '' }],
  });
};

// 删除条件组
const removeGroup = (groupIndex: number) => {
  if (createRuleForm.conditionGroups.length > 1) {
    createRuleForm.conditionGroups.splice(groupIndex, 1);
  }
};

// 构建订阅范围表达式（支持或条件）
const buildRangeExpression = () => {
  const groups = createRuleForm.conditionGroups.filter(g => g.conditions.length > 0 && g.conditions.some(c => c.field && c.value));
  
  if (groups.length === 0) {
    return '';
  }
  
  const groupExpressions = groups.map(group => {
    const expressions = group.conditions
      .filter(c => c.field && c.value)
      .map(cond => {
        const operatorText = {
          '=': '等于',
          '!=': '不等于',
          'contains': '包含',
          'notContains': '不包含',
          '>': '大于',
          '>=': '大于等于',
          '<': '小于',
          '<=': '小于等于',
        }[cond.operator] || cond.operator;
        
        return `【${cond.field}】${operatorText} "${cond.value}"`;
      });
    
    return expressions.join(' 且 ');
  });
  
  return groupExpressions.join(' 或 ');
};

// 解析订阅范围表达式为条件组
const parseRangeExpression = (expression: string): ConditionGroup[] => {
  if (!expression) {
    return [{ conditions: [{ field: '', operator: '=', value: '' }] }];
  }
  
  // 先按"或"分割成组
  const orParts = expression.split(' 或 ');
  const groups: ConditionGroup[] = [];
  
  for (const orPart of orParts) {
    const conditions: Condition[] = [];
    const andParts = orPart.split(' 且 ');
    
    for (const andPart of andParts) {
      const match = andPart.match(/【(.+?)】(.+?) "(.+)"/);
      if (match) {
        const [, field, operatorText, value] = match;
        const operatorMap: Record<string, string> = {
          '等于': '=',
          '不等于': '!=',
          '包含': 'contains',
          '不包含': 'notContains',
          '大于': '>',
          '大于等于': '>=',
          '小于': '<',
          '小于等于': '<=',
        };
        conditions.push({
          field,
          operator: operatorMap[operatorText] || '=',
          value,
        });
      }
    }
    
    if (conditions.length > 0) {
      groups.push({ conditions });
    }
  }
  
  return groups.length > 0 ? groups : [{ conditions: [{ field: '', operator: '=', value: '' }] }];
};

// 订阅表格列定义
const columns: TableColumnsType = [
  {
    title: '订阅规则名称',
    dataIndex: 'ruleName',
    key: 'ruleName',
    width: 180,
    fixed: 'left',
  },
  {
    title: '数据类型',
    dataIndex: 'dataType',
    key: 'dataType',
    width: 150,
  },
  {
    title: '数据字段',
    dataIndex: 'dataFields',
    key: 'dataFields',
    width: 800,
    ellipsis: true,
  },
  {
    title: '订阅范围',
    dataIndex: 'subscriptionRange',
    key: 'subscriptionRange',
    width: 200,
  },
  {
    title: '文件生成时间',
    dataIndex: 'generateTime',
    key: 'generateTime',
    width: 150,
  },
  {
    title: '订阅状态',
    dataIndex: 'subscriptionStatus',
    key: 'subscriptionStatus',
    width: 120,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right',
  },
];

// 订阅表格数据
const tableData = [
  {
    id: 1,
    ruleName: 'AI 外呼数据订阅',
    dataType: 'AI 外呼记录',
    dataFields: aiCallFields,
    subscriptionRange: '',
    generateTime: '每 1 天',
    enabled: true,
  },
  {
    id: 2,
    ruleName: '人工外呼数据订阅',
    dataType: '人工外呼记录',
    dataFields: manualCallFields,
    subscriptionRange: '',
    generateTime: '每 1 天',
    enabled: true,
  },
  {
    id: 3,
    ruleName: '人工跟进数据订阅',
    dataType: '人工跟进记录',
    dataFields: manualFollowUpFields,
    subscriptionRange: '【跟进结果】包含"持续跟进"',
    generateTime: '每 1 天',
    enabled: false,
  },
];

// 数据补发表格列定义
const reissueColumns: TableColumnsType = [
  {
    title: '数据类型',
    dataIndex: 'dataType',
    key: 'dataType',
    width: 150,
    fixed: 'left',
  },
  {
    title: '数据字段',
    dataIndex: 'dataFields',
    key: 'dataFields',
    width: 1200,
    ellipsis: true,
  },
  {
    title: '操作',
    key: 'action',
    width: 150,
    fixed: 'right',
  },
];

// 数据补发表格数据
const reissueTableData = [
  {
    id: 1,
    dataType: 'AI 外呼记录',
    dataFields: aiCallFields,
  },
  {
    id: 2,
    dataType: '人工外呼记录',
    dataFields: manualCallFields,
  },
  {
    id: 3,
    dataType: '人工跟进记录',
    dataFields: manualFollowUpFields,
  },
];

// 自增 ID
let nextId = 4;

/**
 * 处理设置按钮点击
 */
const handleSettings = () => {
  // TODO: 实现设置功能
  console.log('打开数据市场设置');
};

/**
 * 处理新建订阅规则
 */
const handleCreateRule = () => {
  isEditMode.value = false;
  createRuleForm.id = null;
  createRuleForm.ruleName = '';
  createRuleForm.dataType = '';
  createRuleForm.subscriptionRange = '';
  createRuleForm.generateTime = '';
  createRuleForm.conditions = [];
  createRuleModalVisible.value = true;
};

/**
 * 处理编辑订阅规则
 */
const handleEditRule = (record: any) => {
  isEditMode.value = true;
  createRuleForm.id = record.id;
  createRuleForm.ruleName = record.ruleName;
  createRuleForm.dataType = record.dataType;
  createRuleForm.subscriptionRange = record.subscriptionRange || '';
  createRuleForm.generateTime = record.generateTime;
  createRuleForm.conditions = parseRangeExpression(record.subscriptionRange || '');
  createRuleModalVisible.value = true;
};

/**
 * 处理数据类型变化
 */
const handleDataTypeChange = () => {
  // 数据类型变化时，清空条件
  createRuleForm.conditions = [];
  console.log('选择的数据类型:', createRuleForm.dataType);
};

/**
 * 确认新建/编辑订阅规则
 */
const handleCreateRuleConfirm = () => {
  if (!createRuleForm.ruleName || !createRuleForm.dataType || !createRuleForm.generateTime) {
    // TODO: 使用 message.error 提示
    console.log('请填写必填项');
    return;
  }

  const subscriptionRange = buildRangeExpression();

  if (isEditMode.value && createRuleForm.id !== null) {
    // 编辑模式
    const record = tableData.find(item => item.id === createRuleForm.id);
    if (record) {
      record.ruleName = createRuleForm.ruleName;
      record.dataType = createRuleForm.dataType;
      record.dataFields = dataTypeFieldsMap[createRuleForm.dataType] || [];
      record.subscriptionRange = subscriptionRange;
      record.generateTime = createRuleForm.generateTime;
    }
    // TODO: 调用 API 更新
    console.log('更新订阅规则:', record);
  } else {
    // 新建模式
    const newRule = {
      id: nextId++,
      ruleName: createRuleForm.ruleName,
      dataType: createRuleForm.dataType,
      dataFields: dataTypeFieldsMap[createRuleForm.dataType] || [],
      subscriptionRange: subscriptionRange,
      generateTime: createRuleForm.generateTime,
      enabled: true,
    };
    tableData.push(newRule);
    // TODO: 调用 API 创建
    console.log('创建订阅规则:', newRule);
  }

  createRuleModalVisible.value = false;
};

/**
 * 取消新建/编辑订阅规则
 */
const handleCreateRuleCancel = () => {
  createRuleModalVisible.value = false;
  createRuleForm.id = null;
  createRuleForm.ruleName = '';
  createRuleForm.dataType = '';
  createRuleForm.subscriptionRange = '';
  createRuleForm.generateTime = '';
  createRuleForm.conditions = [];
};

/**
 * 处理数据补发
 */
const handleReissue = (record: any) => {
  // TODO: 实现数据补发功能
  console.log('数据补发:', record.dataType);
  // 这里可以打开一个对话框，让用户选择数据范围和时间范围
};

/**
 * 处理取消订阅
 */
const handleUnsubscribe = (record: any) => {
  // TODO: 调用 API 取消订阅
  console.log('取消订阅:', record.dataType);
  record.subscribed = false;
};

/**
 * 处理订阅数据
 */
const handleSubscribe = (record: any) => {
  // TODO: 调用 API 订阅
  console.log('订阅数据:', record.dataType);
  record.subscribed = true;
};

/**
 * 处理状态变化
 */
const handleStatusChange = (record: any) => {
  // TODO: 调用 API 更新状态
  console.log('切换状态:', record.ruleName, '启用:', record.enabled);
};

/**
 * 处理启用/停用切换
 */
const handleToggleStatus = (record: any) => {
  record.enabled = !record.enabled;
  // TODO: 调用 API 更新状态
  console.log('切换状态:', record.ruleName, '启用:', record.enabled);
};

/**
 * 处理删除
 */
const handleDelete = (record: any) => {
  // TODO: 调用 API 删除
  console.log('删除订阅规则:', record.ruleName);
  const index = tableData.findIndex(item => item.id === record.id);
  if (index > -1) {
    tableData.splice(index, 1);
  }
};
</script>

<style scoped>
.data-market {
  padding: 0;
  background: #fff;
  min-height: 100%;
}

/* 顶部导航区域 */
.page-header-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #787676;
  margin: 0;
}

.header-action {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  text-decoration: none;
  font-size: 14px;
  cursor: pointer;
}

.header-action:hover {
  color: #40a9ff;
}

/* Tab 切换区域 */
.tab-section {
  background: #fff;
  padding: 16px 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.tab-section :deep(.ant-tabs-nav) {
  margin-bottom: 24px;
}

.tab-section :deep(.ant-tabs-tab-btn) {
  font-size: 15px;
  font-weight: 500;
}

.disabled-tab {
  color: rgba(0, 0, 0, 0.25);
  cursor: not-allowed;
}

/* 说明和流程图整合区域 */
.info-flow-section {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 20px 24px;
  margin-bottom: 24px;
}

/* 收起状态提示 */
.collapsed-hint {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: #f5f5f5;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.collapsed-hint:hover {
  background: #e6f4ff;
}

.hint-icon {
  font-size: 16px;
  color: #1890ff;
}

.hint-text {
  flex: 1;
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.hint-subtext {
  font-size: 12px;
  color: #999;
}

.expand-icon {
  font-size: 14px;
  color: #1890ff;
}

/* 展开内容区域 */
.expanded-content {
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 内容顶部操作栏 */
.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e8e8e8;
}

.content-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.collapse-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  font-size: 13px;
  cursor: pointer;
  text-decoration: none;
}

.collapse-btn:hover {
  color: #40a9ff;
}

/* 流程图标题 */
.flow-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  text-align: center;
  margin-bottom: 20px;
}

/* 说明区域 */
.info-section {
  background: #f0f5ff;
  border: 1px solid #d6e4ff;
  border-radius: 4px;
  padding: 16px 20px;
  margin-bottom: 24px;
}

.info-item {
  display: flex;
  align-items: flex-start;
  margin-bottom: 12px;
  line-height: 1.8;
}

.info-item:last-child {
  margin-bottom: 0;
}

.info-label {
  font-weight: 600;
  color: #1d3ed6;
  flex-shrink: 0;
  min-width: 120px;
}

.info-content {
  color: #333;
  flex: 1;
}

.file-path {
  font-family: 'Courier New', monospace;
  background: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  border: 1px solid #d9d9d9;
  word-break: break-all;
}

/* 流程图区域 */
.flow-chart-section {
  margin-bottom: 24px;
  padding: 32px 0;
}

.flow-chart {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.flow-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.step-icon {
  width: 64px;
  height: 64px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.database-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.file-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.download-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.step-label {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.flow-connector {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.connector-line {
  width: 60px;
  height: 2px;
  background: linear-gradient(to right, #d9d9d9, #1890ff);
  position: relative;
}

.connector-line::after {
  content: '';
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  border-left: 6px solid #1890ff;
  border-top: 4px solid transparent;
  border-bottom: 4px solid transparent;
}

.connector-text {
  font-size: 12px;
  color: #1890ff;
  white-space: nowrap;
}

/* 表格区域 */
.table-section {
  margin-top: 16px;
}

/* 表格工具栏 */
.table-toolbar {
  margin-bottom: 16px;
  display: flex;
  justify-content: flex-end;
}

.table-toolbar-right {
  display: flex;
  gap: 12px;
}

.table-section :deep(.ant-table) {
  font-size: 14px;
}

.table-section :deep(.ant-table-thead > tr > th) {
  background: #f0f5ff;
  color: #262626;
  font-weight: 600;
  border-color: #e8e8e8;
}

.table-section :deep(.ant-table-tbody > tr:hover > td) {
  background: #f0f5ff;
}

.table-section :deep(.ant-table-cell) {
  border-color: #e8e8e8;
}

/* 数据类型文本 */
.data-type-text {
  font-weight: 500;
  color: #333;
}

/* 字段标签容器 */
.field-tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  max-height: 200px;
  overflow-y: auto;
}

.field-tag {
  margin: 0;
  font-size: 12px;
  background: #e6f4ff;
  border-color: #91caff;
  color: #0958d9;
}

/* 订阅范围文本 */
.subscription-range-text {
  color: #333;
}

/* 文件生成时间文本 */
.generate-time-text {
  color: #333;
}

/* 订阅按钮 */
.subscribe-btn {
  background: #1890ff;
  border-color: #1890ff;
}

.subscribe-btn:hover {
  background: #40a9ff;
  border-color: #40a9ff;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  align-items: center;
  gap: 8px;
}

.action-btn {
  color: #1890ff;
  cursor: pointer;
  font-size: 13px;
}

.action-btn:hover {
  color: #40a9ff;
}

.enable-btn {
  color: #52c41a;
}

.enable-btn:hover {
  color: #73d13d;
}

.delete-btn {
  color: #ff4d4f;
}

.delete-btn:hover {
  color: #ff7875;
}

/* 订阅范围条件区域 */
.range-section {
  width: 100%;
}

.range-hint {
  font-size: 13px;
  color: #999;
  margin-bottom: 12px;
}

.condition-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.condition-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.condition-field {
  flex: 2;
  min-width: 150px;
}

.condition-operator {
  flex: 1;
  min-width: 100px;
}

.condition-value {
  flex: 2;
  min-width: 150px;
}

.remove-condition {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 4px 8px;
}

.add-condition-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  font-size: 13px;
  cursor: pointer;
  padding: 8px 0;
}

.add-condition-btn:hover {
  color: #40a9ff;
}

/* 条件分组样式 */
.condition-groups {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.condition-group {
  background: #fafafa;
  border-radius: 4px;
  padding: 16px;
  position: relative;
}

.condition-group-header {
  margin-bottom: 12px;
}

.or-divider {
  display: inline-block;
  padding: 4px 12px;
  background: #f0f5ff;
  color: #1890ff;
  border-radius: 4px;
  font-size: 13px;
  font-weight: 500;
}

.remove-group-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  color: #ff4d4f;
}

.remove-group-btn:hover {
  color: #ff7875;
}

.add-or-condition-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  font-size: 13px;
  cursor: pointer;
  padding: 8px 0;
  margin-top: 8px;
}

.add-or-condition-btn:hover {
  color: #40a9ff;
}

/* 数据补发说明区域 */
.reissue-info-section {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 20px 24px;
  margin-bottom: 24px;
}

/* 数据补发流程图区域 */
.reissue-flow-section {
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 32px 24px;
  margin-bottom: 24px;
}

/* 选择补发数据图标样式 */
.select-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* 下载任务中心图标样式 */
.task-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

/* 响应式设计 */
@media (max-width: 1400px) {
  .flow-chart {
    gap: 12px;
  }

  .step-icon {
    width: 56px;
    height: 56px;
    font-size: 24px;
  }

  .connector-line {
    width: 40px;
  }
}

@media (max-width: 1200px) {
  .flow-chart {
    flex-direction: column;
    gap: 24px;
  }

  .flow-connector {
    transform: rotate(90deg);
  }

  .connector-line {
    width: 40px;
    height: 2px;
  }

  .connector-text {
    transform: rotate(-90deg);
  }
}
</style>
