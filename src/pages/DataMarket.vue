<template>
  <div class="data-market">
    <!-- 顶部导航区域 -->
    <div class="page-header-section">
      <div class="page-header">
        <div class="header-left">
          <h2 class="page-title">数据市场</h2>
        </div>
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
              :key="subscriptionTableKey"
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
                    <template v-for="(field, index) in record.dataFields" :key="index">
                      <a-tag
                        v-if="record.dataType === '免打扰名单' || index < 8 || record.expandedFields"
                        class="field-tag"
                      >
                        {{ field }}
                      </a-tag>
                    </template>
                    <a-tag
                      v-if="record.dataType !== '免打扰名单' && record.dataFields.length > 8"
                      class="expand-tag"
                      @click.stop="toggleFieldExpand(record)"
                    >
                      {{ record.expandedFields ? '收起' : `+${record.dataFields.length - 8} 更多` }}
                    </a-tag>
                  </div>
                </template>

                <!-- 字段分割符列 -->
                <template v-else-if="column.key === 'delimiter'">
                  <span class="delimiter-text">
                    {{ getDelimiterLabel(record.delimiter, record.customDelimiter) }}
                  </span>
                </template>

                <!-- 边界标识符列 -->
                <template v-else-if="column.key === 'quoteChar'">
                  <span class="quote-char-text">
                    {{ getQuoteCharLabel(record.quoteChar) }}
                  </span>
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
              :key="reissueTableKey"
            >
              <!-- 数据类型列自定义渲染 -->
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'dataType'">
                  <span class="data-type-text">{{ record.dataType }}</span>
                </template>

                <!-- 数据字段列 - Tag 样式 -->
                <template v-else-if="column.key === 'dataFields'">
                  <div class="field-tags-container">
                    <template v-for="(field, index) in record.dataFields" :key="index">
                      <a-tag
                        v-if="record.dataType === '免打扰名单' || index < 8 || record.expandedFields"
                        class="field-tag"
                      >
                        {{ field }}
                      </a-tag>
                    </template>
                    <a-tag
                      v-if="record.dataType !== '免打扰名单' && record.dataFields.length > 8"
                      class="expand-tag"
                      @click.stop="toggleFieldExpand(record)"
                    >
                      {{ record.expandedFields ? '收起' : `+${record.dataFields.length - 8} 更多` }}
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
      ok-text="确定"
      cancel-text="取消"
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
            <a-select-option value="短信发送记录">短信发送记录</a-select-option>
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
                <div class="condition-group-header">
                  <span class="or-divider" v-if="groupIndex > 0">或者</span>
                  <a-button
                    v-if="createRuleForm.conditionGroups.length > 1"
                    type="text"
                    danger
                    @click="removeGroup(groupIndex)"
                    class="remove-group-btn"
                  >
                    <delete-outlined />
                  </a-button>
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
                      @change="handleFieldChange(groupIndex, conditionIndex)"
                    />
                    <a-select
                      v-model:value="condition.operator"
                      placeholder="请选择运算符"
                      class="condition-operator"
                      :disabled="!condition.field || getCurrentFieldOperators(condition.field).length === 0"
                      :allow-clear="true"
                    >
                      <a-select-option
                        v-for="op in getCurrentFieldOperators(condition.field)"
                        :key="op"
                        :value="op"
                      >
                        {{ getOperatorLabel(op) }}
                      </a-select-option>
                    </a-select>
                    <!-- 下拉多选 -->
                    <a-select
                      v-if="getCurrentFieldValueType(condition.field) === 'multiSelect'"
                      v-model:value="condition.value"
                      mode="multiple"
                      :placeholder="getValuePlaceholder(condition.field)"
                      class="condition-value condition-multi-select"
                      :disabled="!condition.operator"
                      :maxTagCount="getMaxTagCount(condition.field)"
                      :maxTagPlaceholder="getMaxTagPlaceholder"
                    >
                      <a-select-option
                        v-for="opt in getCurrentFieldOptions(condition.field)"
                        :key="opt"
                        :value="opt"
                      >
                        {{ opt }}
                      </a-select-option>
                    </a-select>
                    <!-- 机构树选择 (暂用普通下拉代替) -->
                    <a-select
                      v-else-if="getCurrentFieldValueType(condition.field) === 'tree'"
                      v-model:value="condition.value"
                      mode="multiple"
                      :placeholder="getValuePlaceholder(condition.field)"
                      class="condition-value condition-multi-select"
                      :disabled="!condition.operator"
                      :maxTagCount="getMaxTagCount(condition.field)"
                      :maxTagPlaceholder="getMaxTagPlaceholder"
                    >
                      <a-select-option
                        v-for="opt in getCurrentFieldOptions(condition.field)"
                        :key="opt"
                        :value="opt"
                      >
                        {{ opt }}
                      </a-select-option>
                    </a-select>
                    <!-- 数值类型输入 -->
                    <a-input-number
                      v-else-if="getCurrentFieldValueType(condition.field) === 'number'"
                      v-model:value="condition.value"
                      placeholder="请输入数值"
                      class="condition-value"
                      :disabled="!condition.operator"
                    />
                    <!-- 文本类型输入 -->
                    <a-input
                      v-else
                      v-model:value="condition.value"
                      :placeholder="getValuePlaceholder(condition.field)"
                      class="condition-value"
                      :disabled="!condition.operator"
                    />
                    <a-button
                      v-if="group.conditions.length > 1"
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
              </div>
              <a class="add-or-condition-btn" @click="addOrCondition">
                <plus-outlined />
                或条件
              </a>
            </div>
          </div>
        </a-form-item>
        
        <!-- 字段分割符配置 -->
        <a-form-item
          label="字段分割符配置"
          name="delimiter"
          :rules="[{ required: true, message: '请选择字段分割符' }]"
        >
          <a-radio-group v-model:value="createRuleForm.delimiter">
            <a-radio value="tab">制表符</a-radio>
            <a-radio value="comma">逗号</a-radio>
            <a-radio value="semicolon">分号</a-radio>
            <a-radio value="custom">自定义</a-radio>
          </a-radio-group>
          <a-input
            v-if="createRuleForm.delimiter === 'custom'"
            v-model:value="createRuleForm.customDelimiter"
            placeholder="请输入自定义分割符"
            style="width: 100px; margin-top: 8px;"
            maxlength="1"
          />
        </a-form-item>
        
        <!-- 字段边界标识符 -->
        <a-form-item
          label="字段边界标识符"
          name="quoteChar"
          :rules="[{ required: true, message: '请选择字段边界标识符' }]"
        >
          <a-radio-group v-model:value="createRuleForm.quoteChar">
            <a-radio value="double">英文双引号</a-radio>
            <a-radio value="single">英文单引号</a-radio>
          </a-radio-group>
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

    <!-- 数据补发对话框 -->
    <a-modal
      v-model:open="reissueModalVisible"
      title="数据补发"
      width="700px"
      ok-text="生成文件"
      cancel-text="取消"
      @ok="handleReissueConfirm"
      @cancel="handleReissueCancel"
    >
      <a-form :model="reissueForm" layout="vertical">
        <div class="reissue-hint">
          补发范围：若不设置条件，默认补发所选时间段内所有数据
        </div>
        <div class="condition-section">
          <a class="add-condition-link" @click="addReissueOrCondition">
            <plus-outlined />
            添加条件
          </a>
          <div class="condition-groups">
            <div
              v-for="(group, groupIndex) in reissueForm.conditionGroups"
              :key="groupIndex"
              class="condition-group"
            >
              <div class="condition-group-header">
                <span class="or-divider" v-if="groupIndex > 0">或者</span>
                <a-button
                  v-if="reissueForm.conditionGroups.length > 1"
                  type="text"
                  danger
                  @click="removeReissueGroup(groupIndex)"
                  class="remove-group-btn"
                >
                  <delete-outlined />
                </a-button>
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
                    :options="getReissueFieldsOptions"
                    @change="handleReissueFieldChange(groupIndex, conditionIndex)"
                  />
                  <a-select
                    v-model:value="condition.operator"
                    placeholder="请选择运算符"
                    class="condition-operator"
                    :disabled="!condition.field || getReissueFieldOperators(condition.field).length === 0"
                    :allow-clear="true"
                  >
                    <a-select-option
                      v-for="op in getReissueFieldOperators(condition.field)"
                      :key="op"
                      :value="op"
                    >
                      {{ getOperatorLabel(op) }}
                    </a-select-option>
                  </a-select>
                  <!-- 下拉多选 -->
                  <a-select
                    v-if="getReissueFieldValueType(condition.field) === 'multiSelect'"
                    v-model:value="condition.value"
                    mode="multiple"
                    :placeholder="getReissueValuePlaceholder(condition.field)"
                    class="condition-value condition-multi-select"
                    :disabled="!condition.operator"
                    :maxTagCount="getReissueMaxTagCount(condition.field)"
                    :maxTagPlaceholder="getMaxTagPlaceholder"
                  >
                    <a-select-option
                      v-for="opt in getReissueFieldOptions(condition.field)"
                      :key="opt"
                      :value="opt"
                    >
                      {{ opt }}
                    </a-select-option>
                  </a-select>
                  <!-- 机构树选择 (暂用普通下拉代替) -->
                  <a-select
                    v-else-if="getReissueFieldValueType(condition.field) === 'tree'"
                    v-model:value="condition.value"
                    mode="multiple"
                    :placeholder="getReissueValuePlaceholder(condition.field)"
                    class="condition-value condition-multi-select"
                    :disabled="!condition.operator"
                    :maxTagCount="getReissueMaxTagCount(condition.field)"
                    :maxTagPlaceholder="getMaxTagPlaceholder"
                  >
                    <a-select-option
                      v-for="opt in getReissueFieldOptions(condition.field)"
                      :key="opt"
                      :value="opt"
                    >
                      {{ opt }}
                    </a-select-option>
                  </a-select>
                  <!-- 数值类型输入 -->
                  <a-input-number
                    v-else-if="getReissueFieldValueType(condition.field) === 'number'"
                    v-model:value="condition.value"
                    placeholder="请输入数值"
                    class="condition-value"
                    :disabled="!condition.operator"
                  />
                  <!-- 文本类型输入 -->
                  <a-input
                    v-else
                    v-model:value="condition.value"
                    :placeholder="getReissueValuePlaceholder(condition.field)"
                    class="condition-value"
                    :disabled="!condition.operator"
                  />
                  <a-button
                    v-if="group.conditions.length > 1 || groupIndex > 0"
                    type="text"
                    danger
                    @click="removeReissueCondition(groupIndex, conditionIndex)"
                    class="remove-condition"
                  >
                    <delete-outlined />
                  </a-button>
                  <a
                    v-if="conditionIndex === group.conditions.length - 1"
                    class="add-and-condition-btn"
                    @click="addReissueAndCondition(groupIndex)"
                  >
                    <plus-outlined />
                    且条件
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 字段分割符配置 -->
        <a-form-item
          label="字段分割符配置"
          name="delimiter"
          :rules="[{ required: true, message: '请选择字段分割符' }]"
        >
          <a-radio-group v-model:value="reissueForm.delimiter">
            <a-radio value="tab">制表符</a-radio>
            <a-radio value="comma">逗号</a-radio>
            <a-radio value="semicolon">分号</a-radio>
            <a-radio value="custom">自定义</a-radio>
          </a-radio-group>
          <a-input
            v-if="reissueForm.delimiter === 'custom'"
            v-model:value="reissueForm.customDelimiter"
            placeholder="请输入自定义分割符"
            style="width: 100px; margin-top: 8px;"
            maxlength="1"
          />
        </a-form-item>

        <!-- 字段边界标识符 -->
        <a-form-item
          label="字段边界标识符"
          name="quoteChar"
          :rules="[{ required: true, message: '请选择字段边界标识符' }]"
        >
          <a-radio-group v-model:value="reissueForm.quoteChar">
            <a-radio value="double">英文双引号</a-radio>
            <a-radio value="single">英文单引号</a-radio>
          </a-radio-group>
        </a-form-item>

        <a-form-item
          label="补发日期范围"
          name="dateRange"
        >
          <a-range-picker
            v-model:value="reissueForm.dateRange"
            class="date-range-picker"
            :format="'YYYY-MM-DD'"
            placeholder="补发开始日期"
          >
            <template #separator>
              <span>至</span>
            </template>
            <template #placeholder>
              <div class="range-placeholder">
                <span>补发开始日期</span>
                <span class="separator">至</span>
                <span>补发结束日期</span>
              </div>
            </template>
          </a-range-picker>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import { Modal } from 'ant-design-vue';
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

// 表格刷新 key
const subscriptionTableKey = ref(0);
const reissueTableKey = ref(0);

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

// 数据补发对话框
const reissueModalVisible = ref(false);

// 当前补发的数据类型
const currentReissueDataType = ref('');

// 条件组数据结构
interface Condition {
  field: string;
  operator: string;
  value: string;
}

interface ConditionGroup {
  conditions: Condition[];
}

// 字段配置接口
interface FieldConfig {
  field: string;
  operators?: string[]; // 判断符，为空表示不可选
  valueType?: 'text' | 'number' | 'select' | 'tree' | 'multiSelect'; // 值类型
  options?: string[]; // 下拉选项
}

// AI 通话记录字段配置 (根据图片)
const aiCallFieldConfigs: FieldConfig[] = [
  { field: '场景 ID', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['场景 ID1', '场景 ID2', '场景 ID3'] },
  { field: '场景名称', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '任务名称', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '批次名称', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '所属机构名称', operators: ['=', '!=', 'contains'], valueType: 'tree' },
  { field: '所属客户经理', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['客户经理 1', '客户经理 2', '客户经理 3'] },
  { field: '拨打状态', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['已接通', '未知原因', '无人接听', '空号', '停机', '无法接通', '占线/拒接', '留言', '关机', '线路异常'] },
  { field: '通话时长 S', operators: ['>', '<'], valueType: 'number' },
  { field: '意向分类', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['有意向', '可能有意向', '无意向'] },
  { field: '通话轮次', operators: ['>', '<'], valueType: 'number' },
  { field: 'AI 拨打详情 ID', operators: [] },
  { field: '场景编号', operators: [] },
  { field: '任务 ID', operators: [] },
  { field: '任务明细 ID', operators: [] },
  { field: '批次 ID', operators: [] },
  { field: '数据来源', operators: [] },
  { field: '批次详情 id', operators: [] },
  { field: '主叫号码', operators: [] },
  { field: '拨打号码', operators: [] },
  { field: '机构编号', operators: [] },
  { field: '拨打时间', operators: [] },
  { field: '接机时间', operators: [] },
  { field: '挂断时间', operators: [] },
  { field: '接通状态中文', operators: [] },
  { field: '振铃时长', operators: [] },
  { field: '意向分类描述', operators: [] },
  { field: '通话标签', operators: [] },
  { field: '按键输入', operators: [] },
  { field: '录音地址', operators: [] },
  { field: '是否加入黑名单', operators: [] },
  { field: '扩展信息', operators: [] },
  { field: '对话执行日志', operators: [] },
  { field: '任务完成状态', operators: [] },
];

// 人工外呼记录字段配置 (根据图片)
const manualCallFieldConfigs: FieldConfig[] = [
  { field: '场景 ID', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['场景 ID1', '场景 ID2', '场景 ID3'] },
  { field: '场景名称', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '坐席任务来源', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['未知', '平台上传', 'NFT 上传', 'API 上传'] },
  { field: '客户来源', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['未知', '人工导入', 'AI 外呼', 'AI 外呼转人工', 'API 上传', 'AI 外呼主动介入'] },
  { field: '客户所属机构名称', operators: ['=', '!=', 'contains'], valueType: 'tree' },
  { field: '所属客户经理', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['客户经理 1', '客户经理 2', '客户经理 3'] },
  { field: '拨打状态', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['未接通', '已接通'] },
  { field: '通话时长 S', operators: ['>', '<'], valueType: 'number' },
  { field: '人工拨打详情 ID', operators: [] },
  { field: 'AI 拨打详情 ID', operators: [] },
  { field: '坐席任务 ID', operators: [] },
  { field: '场景编号', operators: [] },
  { field: '任务 ID', operators: [] },
  { field: '任务明细 ID', operators: [] },
  { field: '拨打号码', operators: [] },
  { field: '客户所属机构编号', operators: [] },
  { field: '拨打时间', operators: [] },
  { field: '接机时间', operators: [] },
  { field: '挂断时间', operators: [] },
  { field: '振铃时长', operators: [] },
  { field: '录音地址', operators: [] },
  { field: '扩展信息', operators: [] },
];

// 人工跟进记录字段配置 (根据图片)
const manualFollowUpFieldConfigs: FieldConfig[] = [
  { field: '场景 ID', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['场景 ID1', '场景 ID2', '场景 ID3'] },
  { field: '场景名称', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '坐席任务来源', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['未知', '平台上传', 'NFT 上传', 'API 上传'] },
  { field: '客户所属机构名称', operators: ['=', '!=', 'contains'], valueType: 'tree' },
  { field: '所属客户经理', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['客户经理 1', '客户经理 2', '客户经理 3'] },
  { field: '跟进结果', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['待跟进', '持续跟进', '明确拒绝', '明确转化'] },
  { field: '跟进坐席 (客户经理) 平台用户名', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['用户名 1', '用户名 2', '用户名 3'] },
  { field: '坐席任务跟进记录 ID', operators: [] },
  { field: '坐席任务 ID', operators: [] },
  { field: '场景编号', operators: [] },
  { field: '任务 ID', operators: [] },
  { field: '任务名称', operators: [] },
  { field: '任务明细 ID', operators: [] },
  { field: '拨打号码', operators: [] },
  { field: '客户所属机构编号', operators: [] },
  { field: '扩展信息', operators: [] },
  { field: '跟进备注', operators: [] },
  { field: '跟进标签', operators: [] },
  { field: '跟进坐席 (客户经理) 行方工号', operators: [] },
  { field: 'AI 拨打详情 ID', operators: [] },
  { field: '人工拨打详情 ID', operators: [] },
];

// 免打扰名单字段配置
const dncFieldConfigs: FieldConfig[] = [
  { field: '联系方式', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '添加方式', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['手动添加', '自动添加'] },
  { field: '来源', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['AI 外呼', '免打扰名单 - 批量导入', '免打扰名单 - 单个新增', '电话工作台', 'API'] },
  { field: '添加原因', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['连续拒绝', '投诉骂人', '要求勿扰'] },
  { field: '机构名称', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '拨打时间', operators: [] },
  { field: '添加时间', operators: [] },
  { field: '解除时间', operators: [] },
  { field: '添加人', operators: [] },
  { field: '备注', operators: [] },
];

// 短信发送记录字段配置 (根据图片)
const smsRecordFieldConfigs: FieldConfig[] = [
  { field: '操作人', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['操作员 1', '操作员 2', '操作员 3'] },
  { field: '模版名称', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['模版 1', '模版 2', '模版 3'] },
  { field: '短信内容', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '手机号码', operators: ['=', '!=', 'contains'], valueType: 'text' },
  { field: '发送时间', operators: [] },
  { field: '状态', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['发送成功', '发送失败'] },
  { field: '失败原因', operators: ['=', '!=', 'contains'], valueType: 'multiSelect', options: ['号码空号', '号码停机', '发送超时', '内容敏感', '其他原因'] },
];

// 获取字段名称列表 (用于下拉选择)
const aiCallFields = aiCallFieldConfigs.map(c => c.field);
const manualCallFields = manualCallFieldConfigs.map(c => c.field);
const manualFollowUpFields = manualFollowUpFieldConfigs.map(c => c.field);
const dncFields = dncFieldConfigs.map(c => c.field);
const smsRecordFields = smsRecordFieldConfigs.map(c => c.field);

// 数据类型与字段配置的映射
const dataTypeFieldConfigsMap: Record<string, FieldConfig[]> = {
  'AI 外呼记录': aiCallFieldConfigs,
  '人工外呼记录': manualCallFieldConfigs,
  '人工跟进记录': manualFollowUpFieldConfigs,
  '免打扰名单': dncFieldConfigs,
  '短信发送记录': smsRecordFieldConfigs,
};

// 数据类型与字段的映射
const dataTypeFieldsMap: Record<string, string[]> = {
  'AI 外呼记录': aiCallFields,
  '人工外呼记录': manualCallFields,
  '人工跟进记录': manualFollowUpFields,
  '免打扰名单': dncFields,
  '短信发送记录': smsRecordFields,
};

// 判断符映射表
const operatorMap: Record<string, string> = {
  '=': '等于',
  '!=': '不等于',
  'contains': '包含',
  'notContains': '不包含',
  '>': '大于',
  '>=': '大于等于',
  '<': '小于',
  '<=': '小于等于',
};

// 反向判断符映射表
const reverseOperatorMap: Record<string, string> = {
  '等于': '=',
  '不等于': '!=',
  '包含': 'contains',
  '不包含': 'notContains',
  '大于': '>',
  '大于等于': '>=',
  '小于': '<',
  '小于等于': '<=',
};

const createRuleForm = reactive({
  id: null as number | null,
  ruleName: '',
  dataType: '',
  subscriptionRange: '',
  generateTime: '',
  delimiter: 'comma' as string, // 默认逗号
  customDelimiter: '' as string,
  quoteChar: 'single' as string, // 默认英文单引号
  conditionGroups: [] as ConditionGroup[],
});

// 数据补发表单
const reissueForm = reactive({
  dataType: '',
  conditionGroups: [] as ConditionGroup[],
  dateRange: [] as any[],
  delimiter: 'comma' as string, // 默认逗号
  customDelimiter: '' as string,
  quoteChar: 'single' as string, // 默认英文单引号
});

// 初始化条件组
const initConditionGroups = () => {
  createRuleForm.conditionGroups = [{ conditions: [{ field: '', operator: '=', value: '' }] }];
};

// 初始化补发条件组
const initReissueConditionGroups = () => {
  reissueForm.conditionGroups = [{ conditions: [] }];
};

// 获取当前数据类型的字段选项
const getCurrentFieldsOptions = computed(() => {
  const fieldConfigs = getCurrentFieldConfigs.value;
  // 只显示有判断符的字段（operators 数组不为空）
  return fieldConfigs
    .filter(config => config.operators && config.operators.length > 0) // 过滤掉没有判断符的字段
    .map(config => ({
      label: config.field,
      value: config.field,
    }));
});

// 获取补发字段选项
const getReissueFieldsOptions = computed(() => {
  const fieldConfigs = dataTypeFieldConfigsMap[currentReissueDataType.value] || [];
  return fieldConfigs
    .filter(config => config.operators && config.operators.length > 0)
    .map(config => ({
      label: config.field,
      value: config.field,
    }));
});

// 获取当前数据类型的字段配置
const getCurrentFieldConfigs = computed(() => {
  return dataTypeFieldConfigsMap[createRuleForm.dataType] || [];
});

// 根据字段名获取字段配置
const getFieldConfig = (fieldName: string): FieldConfig | undefined => {
  return getCurrentFieldConfigs.value.find(config => config.field === fieldName);
};

// 获取补发字段配置
const getReissueFieldConfig = (fieldName: string): FieldConfig | undefined => {
  const fieldConfigs = dataTypeFieldConfigsMap[currentReissueDataType.value] || [];
  return fieldConfigs.find(config => config.field === fieldName);
};

// 获取当前字段可用的判断符
const getCurrentFieldOperators = (fieldName: string): string[] => {
  if (!fieldName || !createRuleForm.dataType) return [];
  const config = getFieldConfig(fieldName);
  return config?.operators || [];
};

// 获取分割符显示标签
const getDelimiterLabel = (delimiter: string, customDelimiter?: string): string => {
  const labelMap: Record<string, string> = {
    'tab': '制表符',
    'comma': '逗号',
    'semicolon': '分号',
    'custom': customDelimiter || '自定义',
  };
  return labelMap[delimiter] || delimiter;
};

// 获取边界标识符显示标签
const getQuoteCharLabel = (quoteChar: string): string => {
  const labelMap: Record<string, string> = {
    'double': '英文双引号',
    'single': '英文单引号',
  };
  return labelMap[quoteChar] || quoteChar;
};

// 获取补发字段判断符
const getReissueFieldOperators = (fieldName: string): string[] => {
  if (!fieldName || !currentReissueDataType.value) return [];
  const config = getReissueFieldConfig(fieldName);
  return config?.operators || [];
};

// 获取判断符显示标签
const getOperatorLabel = (operator: string): string => {
  const labelMap: Record<string, string> = {
    '=': '等于',
    '!=': '不等于',
    'contains': '包含',
    'notContains': '不包含',
    '>': '大于',
    '>=': '大于等于',
    '<': '小于',
    '<=': '小于等于',
  };
  return labelMap[operator] || operator;
};

// 获取当前字段的值类型
const getCurrentFieldValueType = (fieldName: string): string => {
  if (!fieldName || !createRuleForm.dataType) return 'text';
  const config = getFieldConfig(fieldName);
  return config?.valueType || 'text';
};

// 获取补发字段值类型
const getReissueFieldValueType = (fieldName: string): string => {
  if (!fieldName || !currentReissueDataType.value) return 'text';
  const config = getReissueFieldConfig(fieldName);
  return config?.valueType || 'text';
};

// 获取当前字段的选项
const getCurrentFieldOptions = (fieldName: string): string[] => {
  if (!fieldName || !createRuleForm.dataType) return [];
  const config = getFieldConfig(fieldName);
  return config?.options || [];
};

// 获取补发字段选项
const getReissueFieldOptions = (fieldName: string): string[] => {
  if (!fieldName || !currentReissueDataType.value) return [];
  const config = getReissueFieldConfig(fieldName);
  return config?.options || [];
};

// 获取值的占位符提示
const getValuePlaceholder = (fieldName: string): string => {
  const config = getFieldConfig(fieldName);
  if (!config) return '输入值';

  switch (config.valueType) {
    case 'text':
      return '文本输入，输入关键词';
    case 'number':
      return '数值输入';
    case 'multiSelect':
    case 'tree':
      return '下拉多选，请选择';
    default:
      return '输入值';
  }
};

// 获取补发值占位符
const getReissueValuePlaceholder = (fieldName: string): string => {
  const config = getReissueFieldConfig(fieldName);
  if (!config) return '输入值';

  switch (config.valueType) {
    case 'text':
      return '文本输入，输入关键词';
    case 'number':
      return '数值输入';
    case 'multiSelect':
    case 'tree':
      return '下拉多选，请选择';
    default:
      return '输入值';
  }
};

// 获取最大显示标签数量
const getMaxTagCount = (fieldName: string): number => {
  const options = getCurrentFieldOptions(fieldName);
  // 根据选项数量动态设置，最多显示 2 个，其余用 +X 表示
  if (options.length <= 2) {
    return options.length;
  }
  return 2;
};

// 获取补发最大显示标签数量
const getReissueMaxTagCount = (fieldName: string): number => {
  const options = getReissueFieldOptions(fieldName);
  if (options.length <= 2) {
    return options.length;
  }
  return 2;
};

// 自定义超出显示数量的占位符
const getMaxTagPlaceholder = (omittedValues: string[]) => {
  return `+ ${omittedValues.length} ...`;
};

// 处理字段变化，清空运算符和值
const handleFieldChange = (groupIndex: number, conditionIndex: number) => {
  const condition = createRuleForm.conditionGroups[groupIndex].conditions[conditionIndex];
  // 字段变化时，清空运算符和值
  condition.operator = '';
  condition.value = '';
};

// 处理补发字段变化
const handleReissueFieldChange = (groupIndex: number, conditionIndex: number) => {
  const condition = reissueForm.conditionGroups[groupIndex].conditions[conditionIndex];
  condition.operator = '';
  condition.value = '';
};

// 添加且条件
const addAndCondition = (groupIndex: number) => {
  createRuleForm.conditionGroups[groupIndex].conditions.push({
    field: '',
    operator: '=',
    value: '',
  });
};

// 添加补发且条件
const addReissueAndCondition = (groupIndex: number) => {
  reissueForm.conditionGroups[groupIndex].conditions.push({
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

// 删除补发条件
const removeReissueCondition = (groupIndex: number, conditionIndex: number) => {
  const group = reissueForm.conditionGroups[groupIndex];
  if (group.conditions.length > 1) {
    group.conditions.splice(conditionIndex, 1);
  } else {
    if (reissueForm.conditionGroups.length > 1) {
      reissueForm.conditionGroups.splice(groupIndex, 1);
    }
  }
};

// 添加或条件组
const addOrCondition = () => {
  createRuleForm.conditionGroups.push({
    conditions: [{ field: '', operator: '=', value: '' }],
  });
};

// 添加补发或条件组
const addReissueOrCondition = () => {
  reissueForm.conditionGroups.push({
    conditions: [{ field: '', operator: '=', value: '' }],
  });
};

// 添加补发条件
const addReissueCondition = () => {
  if (reissueForm.conditionGroups.length === 0) {
    reissueForm.conditionGroups = [{ conditions: [{ field: '', operator: '', value: '' }] }];
  } else {
    reissueForm.conditionGroups[0].conditions.push({
      field: '',
      operator: '',
      value: '',
    });
  }
};

// 删除条件组
const removeGroup = (groupIndex: number) => {
  if (createRuleForm.conditionGroups.length > 1) {
    createRuleForm.conditionGroups.splice(groupIndex, 1);
  }
};

// 删除补发条件组
const removeReissueGroup = (groupIndex: number) => {
  if (reissueForm.conditionGroups.length > 1) {
    reissueForm.conditionGroups.splice(groupIndex, 1);
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
    width: 600,
    ellipsis: true,
  },
  {
    title: '字段分割符',
    dataIndex: 'delimiter',
    key: 'delimiter',
    width: 120,
  },
  {
    title: '边界标识符',
    dataIndex: 'quoteChar',
    key: 'quoteChar',
    width: 120,
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

// 订阅表格数据 - 使用 ref 包装以确保响应式
const tableData = ref([
  {
    id: 1,
    ruleName: 'AI 外呼数据订阅',
    dataType: 'AI 外呼记录',
    dataFields: aiCallFields,
    subscriptionRange: '',
    generateTime: '每 1 天',
    delimiter: 'comma',
    quoteChar: 'single',
    enabled: true,
    expandedFields: false,
  },
  {
    id: 2,
    ruleName: '人工外呼数据订阅',
    dataType: '人工外呼记录',
    dataFields: manualCallFields,
    subscriptionRange: '',
    generateTime: '每 1 天',
    delimiter: 'comma',
    quoteChar: 'single',
    enabled: true,
    expandedFields: false,
  },
  {
    id: 3,
    ruleName: '人工跟进数据订阅',
    dataType: '人工跟进记录',
    dataFields: manualFollowUpFields,
    subscriptionRange: '【跟进结果】包含"持续跟进"',
    generateTime: '每 1 天',
    delimiter: 'comma',
    quoteChar: 'single',
    enabled: false,
    expandedFields: false,
  },
  {
    id: 4,
    ruleName: '短信发送记录订阅',
    dataType: '短信发送记录',
    dataFields: smsRecordFields,
    subscriptionRange: '',
    generateTime: '每 1 天',
    delimiter: 'comma',
    quoteChar: 'single',
    enabled: true,
    expandedFields: false,
  },
]);

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

// 数据补发表格数据 - 使用 ref 包装以确保响应式
const reissueTableData = ref([
  {
    id: 1,
    dataType: 'AI 外呼记录',
    dataFields: aiCallFields,
    expandedFields: false,
  },
  {
    id: 2,
    dataType: '人工外呼记录',
    dataFields: manualCallFields,
    expandedFields: false,
  },
  {
    id: 3,
    dataType: '人工跟进记录',
    dataFields: manualFollowUpFields,
    expandedFields: false,
  },
  {
    id: 4,
    dataType: '免打扰名单',
    dataFields: dncFields,
    expandedFields: false,
  },
  {
    id: 5,
    dataType: '短信发送记录',
    dataFields: smsRecordFields,
    expandedFields: false,
  },
]);

// 自增 ID
let nextId = 5;

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
    const record = tableData.value.find(item => item.id === createRuleForm.id);
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
    tableData.value.push(newRule);
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
 * 切换字段展开/收起状态
 */
const toggleFieldExpand = (record: any) => {
  // 先在订阅表格中查找
  let index = tableData.value.findIndex(item => item.id === record.id);
  if (index !== -1) {
    tableData.value[index].expandedFields = !tableData.value[index].expandedFields;
    // 强制刷新订阅表格
    subscriptionTableKey.value++;
  } else {
    // 如果没找到，在补发表格中查找
    index = reissueTableData.value.findIndex(item => item.id === record.id);
    if (index !== -1) {
      reissueTableData.value[index].expandedFields = !reissueTableData.value[index].expandedFields;
      // 强制刷新补发表格
      reissueTableKey.value++;
    }
  }
};

/**
 * 处理数据补发
 */
const handleReissue = (record: any) => {
  // 设置当前补发的数据类型
  currentReissueDataType.value = record.dataType;
  // 初始化补发表单
  reissueForm.dataType = record.dataType;
  reissueForm.dateRange = [];
  initReissueConditionGroups();
  // 打开对话框
  reissueModalVisible.value = true;
};

/**
 * 确认数据补发
 */
const handleReissueConfirm = () => {
  // 未填写补发日期范围时，弹出二次确认
  if (!reissueForm.dateRange || reissueForm.dateRange.length !== 2) {
    Modal.confirm({
      title: '提示',
      content: '不填写补发日期范围，默认将补发历史全量数据，确认继续？',
      okText: '确认',
      cancelText: '取消',
      onOk: () => {
        // TODO: 调用 API 生成文件
        console.log('生成文件:', {
          dataType: reissueForm.dataType,
          dateRange: reissueForm.dateRange,
          conditions: reissueForm.conditionGroups,
        });
        
        reissueModalVisible.value = false;
      },
    });
    return;
  }
  
  // TODO: 调用 API 生成文件
  console.log('生成文件:', {
    dataType: reissueForm.dataType,
    dateRange: reissueForm.dateRange,
    conditions: reissueForm.conditionGroups,
  });
  
  reissueModalVisible.value = false;
};

/**
 * 取消数据补发
 */
const handleReissueCancel = () => {
  reissueModalVisible.value = false;
  reissueForm.dataType = '';
  reissueForm.dateRange = [];
  reissueForm.conditionGroups = [];
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
  const index = tableData.value.findIndex(item => item.id === record.id);
  if (index > -1) {
    tableData.value.splice(index, 1);
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

/* 展开/收起标签 */
.expand-tag {
  margin: 0;
  font-size: 12px;
  background: #f5f5f5;
  border-color: #d9d9d9;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
}

.expand-tag:hover {
  background: #e6f4ff;
  border-color: #91caff;
  color: #1890ff;
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
  margin-left: 4px;
}

.add-condition-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  font-size: 13px;
  cursor: pointer;
  padding: 8px 0;
  margin-left: 8px;
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
  display: flex;
  justify-content: space-between;
  align-items: center;
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
  color: #ff4d4f;
  font-size: 16px;
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

/* 数据补发对话框样式 */
.reissue-hint {
  font-size: 14px;
  color: #666;
  margin-bottom: 16px;
  padding: 12px 16px;
  background: #f5f5f5;
  border-radius: 4px;
}

.condition-section {
  margin-bottom: 20px;
}

.add-condition-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  font-size: 14px;
  cursor: pointer;
  margin-bottom: 16px;
}

.add-condition-link:hover {
  color: #40a9ff;
}

.date-range-picker {
  width: 100%;
}

.range-placeholder {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  color: #bfbfbf;
}

.range-placeholder .separator {
  margin: 0 8px;
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
