<template>
  <div class="sampling-rule-page">
    <div class="sampling-rule-wrapper">
      <!-- 顶部信息栏 -->
      <div class="sampling-header-section">
        <div class="sampling-header">
          <div class="header-left">
            <h2 class="page-title">抽检规则</h2>
            <p class="page-description">维护和查看抽检任务生成的规则列表，配置抽检策略自动生成质检任务。</p>
          </div>
          <div class="header-right">
            <a-button type="primary" class="create-btn" @click="handleCreate">
              <plus-outlined />
              新建抽检规则
            </a-button>
          </div>
        </div>
      </div>

      <!-- 搜索和表格区域 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-form layout="vertical">
            <a-row :gutter="[16, 0]">
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.ruleName"
                    placeholder="请输入规则名称"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.dataType"
                    placeholder="请选择数据类型"
                    allow-clear
                  >
                    <a-select-option value="ai_assisted">人机协同录音</a-select-option>
                    <a-select-option value="manual_outbound">人工外呼录音</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.samplingMethod"
                    placeholder="请选择采样方式"
                    allow-clear
                  >
                    <a-select-option value="average">平均采样</a-select-option>
                    <a-select-option value="ratio">按比例采样</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.status"
                    placeholder="请选择状态"
                    allow-clear
                  >
                    <a-select-option value="enabled">已启用</a-select-option>
                    <a-select-option value="disabled">已停用</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="[16, 0]">
              <a-col :span="6">
                <a-form-item>
                  <a-space class="search-btn-space">
                    <a-button @click="handleReset">
                      <reload-outlined />
                      重置
                    </a-button>
                    <a-button type="primary" @click="handleSearch">
                      <search-outlined />
                      搜索
                    </a-button>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
          </a-form>
        </div>

        <!-- 表格区域 -->
        <div class="table-area">
          <div class="table-toolbar">
            <div class="table-toolbar-left">
              <span class="selection-info">共 {{ total }} 条</span>
            </div>
          </div>

          <div class="table-wrapper">
            <a-table
              :columns="columns"
              :data-source="tableData"
              :pagination="false"
              :scroll="{ x: 1400 }"
              row-key="ruleId"
            >
              <template #bodyCell="{ column, record }">
                <template v-if="column.key === 'ruleId'">
                  <span class="rule-id">{{ record.ruleId }}</span>
                </template>
                <template v-else-if="column.key === 'dataType'">
                  <a-tag v-if="record.dataType === 'ai_assisted'" color="blue">人机协同录音</a-tag>
                  <a-tag v-else color="cyan">人工外呼录音</a-tag>
                </template>
                <template v-else-if="column.key === 'samplingMethod'">
                  <span v-if="record.samplingMethod === 'average'">平均采样</span>
                  <span v-else>按比例采样</span>
                </template>
                <template v-else-if="column.key === 'allocationMethod'">
                  <span v-if="record.allocationMethod === 'total'">按总数 {{ record.allocationValue }} 条</span>
                  <span v-else-if="record.allocationMethod === 'ratio'">按比例 {{ record.allocationValue }}%</span>
                  <span v-else>人均 {{ record.allocationValue }} 条</span>
                </template>
                <template v-else-if="column.key === 'schedule'">
                  <span>{{ getScheduleLabel(record) }}</span>
                </template>
                <template v-else-if="column.key === 'status'">
                  <a-switch
                    :checked="record.status === 'enabled'"
                    size="small"
                    @change="(checked: boolean) => handleToggleStatus(record, checked)"
                  />
                </template>
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

          <Pagination
            v-model:current="pagination.currentPage"
            v-model:page-size="pagination.pageSize"
            :total="pagination.total"
            @change="handlePageChange"
          />
        </div>
      </div>
    </div>

    <!-- 新建/编辑抽检规则弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="isViewMode ? '查看抽检规则' : (isEditMode ? '编辑抽检规则' : '新建抽检规则')"
      width="960px"
      :closable="false"
      :footer="null"
      @cancel="handleCancel"
    >
      <!-- 步骤条 -->
      <a-steps :current="currentStep - 1" class="modal-steps">
        <a-step title="规则基本信息" />
        <a-step title="数据抽样规则" />
        <a-step title="任务创建规则" />
      </a-steps>

      <!-- 步骤 1：规则基本信息 -->
      <div v-if="currentStep === 1" class="step-content">
        <div class="step-section-title">规则基本信息</div>
        <div class="step-section-desc">设置规则的名称、质检对象和分配对象</div>
        <a-form
          ref="step1FormRef"
          :model="formData"
          :rules="step1Rules"
          layout="horizontal"
          :label-col="{ span: 6 }"
          :wrapper-col="{ span: 16 }"
          class="step-form"
        >
          <a-form-item label="规则名称" name="ruleName">
            <a-input
              v-model:value="formData.ruleName"
              placeholder="请输入规则名称"
              :maxlength="50"
              show-count
              :disabled="isViewMode"
            />
          </a-form-item>
          <a-form-item label="规则说明" name="ruleDescription">
            <a-textarea
              v-model:value="formData.ruleDescription"
              placeholder="请输入规则说明"
              :rows="3"
              :maxlength="200"
              show-count
              :disabled="isViewMode"
            />
          </a-form-item>
          <a-form-item label="质检方式">
            <template #label>
              <span class="required-label">*</span> 质检方式
            </template>
            <a-radio-group v-model:value="formData.inspectType" :disabled="isViewMode">
              <a-radio value="ai">AI 质检</a-radio>
              <a-radio value="manual">人工质检</a-radio>
            </a-radio-group>
          </a-form-item>
          <a-form-item label="质检模型">
            <template #label>
              <span class="required-label">*</span> 质检模型
            </template>
            <a-select
              v-model:value="formData.qualityModel"
              placeholder="请选择质检模型"
              :disabled="isViewMode"
            >
              <a-select-option
                v-for="option in qualityModelOptions"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="分配对象">
            <template #label>
              <span class="required-label">*</span> 分配对象
            </template>
            <a-select
              v-model:value="formData.inspectors"
              mode="multiple"
              placeholder="请选择质检员（可多选）"
              :max-tag-count="5"
              style="width: 100%"
              :disabled="isViewMode"
            >
              <a-select-option
                v-for="option in inspectorOptions"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-form>
      </div>

      <!-- 步骤 2：数据抽样规则 -->
      <div v-else-if="currentStep === 2" class="step-content">
        <div class="step-section-title">数据抽样规则</div>
        <div class="step-section-desc">配置采样数量、数据范围条件和抽样方式</div>

        <!-- 采样数量 -->
        <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }" class="step-form">
          <a-form-item label="采样数量">
            <template #label>
              <span class="required-label">*</span> 采样数量
            </template>
            <a-radio-group v-model:value="formData.allocationMethod" :disabled="isViewMode">
              <a-radio value="total">按总数</a-radio>
              <a-radio value="ratio">按比例</a-radio>
              <a-radio value="perPerson">人均数量</a-radio>
            </a-radio-group>
          </a-form-item>

          <a-form-item v-if="formData.allocationMethod === 'total'" label="取数总数量">
            <a-input-number v-model:value="formData.allocationValue" :min="1" :precision="0" style="width: 200px" placeholder="请输入总数量" :disabled="isViewMode" />
            <span class="quota-unit">条</span>
            <div class="quota-tip">从符合条件的数据中抽取固定数量的录音作为抽检样本</div>
          </a-form-item>

          <a-form-item v-else-if="formData.allocationMethod === 'ratio'" label="抽取百分比">
            <a-input-number v-model:value="formData.allocationValue" :min="1" :max="100" :precision="0" style="width: 200px" placeholder="请输入百分比" :disabled="isViewMode" />
            <span class="quota-unit">%</span>
            <div class="quota-tip">按符合条件的数据总量的百分比抽取，实际数量随数据量浮动</div>
          </a-form-item>

          <a-form-item v-else label="每人分配数量">
            <a-input-number v-model:value="formData.allocationValue" :min="1" :precision="0" style="width: 200px" placeholder="请输入每人数量" :disabled="isViewMode" />
            <span class="quota-unit">条/人</span>
            <div class="quota-tip">每位质检员分配固定数量的录音，总抽检量 = 每人数量 × 质检员人数</div>
          </a-form-item>
        </a-form>

        <a-divider />

        <!-- 条件表达式 -->
        <div class="step-section-subtitle">数据范围条件</div>
        <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }">
          <a-form-item label="质检对象">
            <template #label>
              <span class="required-label">*</span> 质检对象
            </template>
            <a-radio-group v-model:value="formData.dataType" :disabled="isViewMode">
              <a-radio value="ai_assisted">人机协同录音</a-radio>
              <a-radio value="manual_outbound">人工外呼录音</a-radio>
            </a-radio-group>
          </a-form-item>
        </a-form>
        <div class="data-range-tip">请选择需要抽检的已接通通话范围</div>

        <div class="condition-area">
          <div class="expression-list-inline">
            <div
              v-for="(expression, index) in formData.conditionExpressions"
              :key="expression.id"
              class="expression-item-inline"
            >
              <div class="expression-content">
                <div class="condition-list-inline">
                  <div
                    v-for="(condition, cIndex) in expression.conditions"
                    :key="condition.id"
                    class="condition-item-inline"
                  >
                    <a-select
                      v-model:value="condition.fieldType"
                      style="width: 140px"
                      placeholder="字段类型"
                      :disabled="isViewMode"
                    >
                      <a-select-option value="callTime">通话时间</a-select-option>
                      <a-select-option value="callDuration">通话时长</a-select-option>
                      <a-select-option value="intent">客户意图</a-select-option>
                      <a-select-option value="agent">坐席工号</a-select-option>
                      <a-select-option value="scene">场景</a-select-option>
                    </a-select>
                    <a-select
                      v-model:value="condition.operator"
                      style="width: 100px"
                      placeholder="操作符"
                      :disabled="isViewMode"
                    >
                      <a-select-option value="=">=</a-select-option>
                      <a-select-option value=">">&gt;</a-select-option>
                      <a-select-option value="<">&lt;</a-select-option>
                      <a-select-option value="contains">包含</a-select-option>
                      <a-select-option v-if="condition.fieldType === 'callTime' || condition.fieldType === 'callDuration'" value="between">介于</a-select-option>
                    </a-select>
                    <a-input
                      v-if="condition.operator !== 'between'"
                      v-model:value="condition.value"
                      style="width: 180px"
                      placeholder="请输入值"
                      :disabled="isViewMode"
                    />
                    <div v-else class="between-inputs">
                      <a-input
                        v-model:value="condition.value"
                        style="width: 80px"
                        placeholder="最小值"
                        :disabled="isViewMode"
                      />
                      <span class="between-separator">~</span>
                      <a-input
                        v-model:value="condition.value2"
                        style="width: 80px"
                        placeholder="最大值"
                        :disabled="isViewMode"
                      />
                    </div>
                    <a-button
                      v-if="expression.conditions.length > 1 && !isViewMode"
                      type="text"
                      danger
                      @click="handleDeleteCondition(index, cIndex)"
                      class="delete-condition-btn"
                    >
                      <minus-circle-outlined />
                    </a-button>
                    <a-button
                      v-if="cIndex === expression.conditions.length - 1 && !isViewMode"
                      type="text"
                      @click="handleAddCondition(index)"
                      class="add-condition-btn-inline"
                    >
                      <plus-circle-outlined />
                    </a-button>
                    <span v-if="cIndex < expression.conditions.length - 1" class="condition-connector-inline">且</span>
                  </div>
                </div>
              </div>
              <div class="expression-footer" v-if="formData.conditionExpressions.length > 1 && !isViewMode">
                <a-button type="text" danger @click="handleDeleteExpression(index)">
                  <delete-outlined />
                  删除表达式
                </a-button>
              </div>
            </div>
          </div>
          <div v-if="!isViewMode" class="add-expression-btn-wrapper-inline">
            <a-button @click="handleAddExpression" block dashed>
              <plus-outlined />
              或条件
            </a-button>
          </div>
        </div>

        <a-divider />

        <!-- 抽样规则 -->
        <div class="step-section-subtitle">抽样方式</div>

        <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }">
          <a-form-item label="采样方式">
            <template #label>
              <span class="required-label">*</span> 采样方式
            </template>
            <a-radio-group v-model:value="formData.samplingMethod" :disabled="isViewMode">
              <a-radio value="average">平均采样</a-radio>
              <a-radio value="ratio">按比例采样</a-radio>
            </a-radio-group>
          </a-form-item>
        </a-form>

        <!-- 平均采样 -->
        <div v-if="formData.samplingMethod === 'average'" class="sampling-option-area">
          <a-alert
            message="系统默认会对每个场景、每个坐席的数据中平均抽样"
            type="info"
            show-icon
            class="sampling-tip-alert"
          />
        </div>

        <!-- 按比例采样 -->
        <div v-else-if="formData.samplingMethod === 'ratio'" class="sampling-option-area">
          <div class="ratio-sampling-config">
            <div class="dimension-section">
              <div class="dimension-label">采样维度</div>
              <a-select
                v-model:value="formData.samplingDimension"
                style="width: 200px"
                placeholder="选择维度"
                :disabled="isViewMode"
                @change="handleDimensionChange"
              >
                <a-select-option value="scene">按场景</a-select-option>
                <a-select-option value="agent">按坐席</a-select-option>
                <a-select-option value="callDuration">按通话时长</a-select-option>
              </a-select>
            </div>

            <a-alert
              v-if="formData.samplingDimension === 'scene'"
              message="各场景被抽中的录音数量符合预先设定的比例，且每个坐席被抽中的录音数量尽可能相等"
              type="info"
              show-icon
              class="dimension-tip-alert"
            />
            <a-alert
              v-else-if="formData.samplingDimension === 'agent'"
              message="各坐席被抽中的录音数量符合预先设定的比例，且每个场景被抽中的录音数量尽可能相等"
              type="info"
              show-icon
              class="dimension-tip-alert"
            />
            <a-alert
              v-else
              message="每个场景、每个坐席被抽中的录音数量尽可能相等"
              type="info"
              show-icon
              class="dimension-tip-alert"
            />

            <!-- 按场景 -->
            <div v-if="formData.samplingDimension === 'scene'" class="dimension-table-area">
              <a-table
                :columns="sceneColumns"
                :data-source="formData.sceneItems"
                :pagination="false"
                row-key="id"
                size="small"
                bordered
                class="dimension-table"
              >
                <template #bodyCell="{ column, record: item, index: itemIndex }">
                  <template v-if="column.key === 'sceneName'">
                    <a-select
                      v-model:value="item.sceneName"
                      placeholder="请选择场景"
                      size="small"
                      style="width: 100%"
                      show-search
                      :filter-option="(input: string, option: any) => option.label.toLowerCase().includes(input.toLowerCase())"
                      :disabled="isViewMode"
                    >
                      <a-select-option
                        v-for="scene in sceneOptions"
                        :key="scene.value"
                        :value="scene.value"
                        :label="scene.label"
                      >
                        {{ scene.label }}
                      </a-select-option>
                    </a-select>
                  </template>
                  <template v-else-if="column.key === 'ratio'">
                    <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" :disabled="isViewMode" /> %
                  </template>
                  <template v-else-if="column.key === 'action'">
                    <a-button v-if="!isViewMode" type="link" size="small" danger @click="handleDeleteSceneItem(itemIndex)">删除</a-button>
                  </template>
                </template>
              </a-table>
              <div class="dimension-table-footer">
                <a-button v-if="!isViewMode" type="link" size="small" @click="handleAddSceneItem">
                  <plus-outlined /> 添加场景
                </a-button>
                <span class="ratio-total" :class="{ 'ratio-error': sceneRatioTotal > 100 }">
                  合计：{{ sceneRatioTotal }}%
                </span>
              </div>
            </div>

            <!-- 按坐席 -->
            <div v-else-if="formData.samplingDimension === 'agent'" class="dimension-table-area">
              <a-table
                :columns="agentColumns"
                :data-source="formData.agentItems"
                :pagination="false"
                row-key="id"
                size="small"
                bordered
                class="dimension-table"
              >
                <template #bodyCell="{ column, record: item, index: itemIndex }">
                  <template v-if="column.key === 'agentId'">
                    <a-select
                      v-model:value="item.agentId"
                      placeholder="请选择坐席"
                      size="small"
                      style="width: 100%"
                      show-search
                      :filter-option="(input: string, option: any) => option.label.toLowerCase().includes(input.toLowerCase())"
                      :disabled="isViewMode"
                    >
                      <a-select-option
                        v-for="agent in agentOptions"
                        :key="agent.value"
                        :value="agent.value"
                        :label="agent.label"
                      >
                        {{ agent.label }}
                      </a-select-option>
                    </a-select>
                  </template>
                  <template v-else-if="column.key === 'ratio'">
                    <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" :disabled="isViewMode" /> %
                  </template>
                  <template v-else-if="column.key === 'action'">
                    <a-button v-if="!isViewMode" type="link" size="small" danger @click="handleDeleteAgentItem(itemIndex)">删除</a-button>
                  </template>
                </template>
              </a-table>
              <div class="dimension-table-footer">
                <a-button v-if="!isViewMode" type="link" size="small" @click="handleAddAgentItem">
                  <plus-outlined /> 添加坐席
                </a-button>
                <span class="ratio-total" :class="{ 'ratio-error': agentRatioTotal > 100 }">
                  合计：{{ agentRatioTotal }}%
                </span>
              </div>
            </div>

            <!-- 按通话时长 -->
            <div v-else-if="formData.samplingDimension === 'callDuration'" class="dimension-table-area">
              <a-table
                :columns="durationColumns"
                :data-source="formData.durationItems"
                :pagination="false"
                row-key="id"
                size="small"
                bordered
                class="dimension-table"
              >
                <template #bodyCell="{ column, record: item, index: itemIndex }">
                  <template v-if="column.key === 'range'">
                    <a-input-number v-model:value="item.minDuration" :min="0" :precision="0" size="small" style="width: 80px" placeholder="秒" :disabled="isViewMode" />
                    <span class="range-separator">~</span>
                    <a-input-number v-model:value="item.maxDuration" :min="0" :precision="0" size="small" style="width: 80px" placeholder="秒" :disabled="isViewMode" />
                    <span class="range-unit">秒</span>
                  </template>
                  <template v-else-if="column.key === 'ratio'">
                    <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" :disabled="isViewMode" /> %
                  </template>
                  <template v-else-if="column.key === 'action'">
                    <a-button v-if="!isViewMode" type="link" size="small" danger @click="handleDeleteDurationItem(itemIndex)">删除</a-button>
                  </template>
                </template>
              </a-table>
              <div class="dimension-table-footer">
                <a-button v-if="!isViewMode" type="link" size="small" @click="handleAddDurationItem">
                  <plus-outlined /> 添加区间
                </a-button>
                <span class="ratio-total" :class="{ 'ratio-error': durationRatioTotal > 100 }">
                  合计：{{ durationRatioTotal }}%
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 步骤 3：任务创建规则 -->
      <div v-else-if="currentStep === 3" class="step-content">
        <div class="step-section-title">任务创建规则</div>
        <div class="step-section-desc">配置定时创建任务的执行计划和有效期</div>
        <a-form layout="horizontal" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }" class="step-form">
          <a-form-item label="执行频率">
            <span class="fixed-value">每日</span>
          </a-form-item>

          <a-form-item label="执行时间">
            <a-time-picker v-model:value="formData.schedule.executeTimeValue" format="HH:mm" style="width: 200px" placeholder="选择执行时间" :disabled="isViewMode" />
          </a-form-item>

          <a-form-item label="数据时间偏移">
            <a-radio-group v-model:value="formData.schedule.dataOffsetMode" :disabled="isViewMode" style="margin-bottom: 8px">
              <a-radio value="days">按天偏移</a-radio>
              <a-radio value="timeRange">精确时间范围</a-radio>
            </a-radio-group>
            <div v-if="formData.schedule.dataOffsetMode === 'days'" class="offset-row">
              <span class="offset-prefix">固定抓取</span>
              <a-input-number v-model:value="formData.schedule.dataOffset" :min="0" :max="30" :precision="0" style="width: 80px" :disabled="isViewMode" />
              <span class="offset-suffix">日前的数据</span>
            </div>
            <div v-else class="offset-range-row">
              <span class="offset-prefix">抓取当天</span>
              <a-time-picker v-model:value="formData.schedule.dataStartTime" format="HH:mm" placeholder="开始时间" style="width: 120px" :disabled="isViewMode" :allow-clear="false" />
              <span class="date-separator">至</span>
              <a-time-picker v-model:value="formData.schedule.dataEndTime" format="HH:mm" placeholder="结束时间" style="width: 120px" :disabled="isViewMode" :allow-clear="false" />
              <span class="offset-suffix">的外呼数据</span>
            </div>
            <div class="offset-preview">{{ scheduleDescription }}</div>
          </a-form-item>

          <a-form-item label="有效期">
            <div class="schedule-date-range">
              <a-date-picker v-model:value="formData.schedule.startDateValue" format="YYYY-MM-DD" placeholder="开始日期" style="width: 160px" :disabled="isViewMode" />
              <span class="date-separator">至</span>
              <a-date-picker v-if="!formData.schedule.permanent" v-model:value="formData.schedule.endDateValue" format="YYYY-MM-DD" placeholder="结束日期" style="width: 160px" :disabled="isViewMode" />
              <a-checkbox v-model:checked="formData.schedule.permanent" style="margin-left: 12px" :disabled="isViewMode">永久有效</a-checkbox>
            </div>
          </a-form-item>

          <a-form-item label="启用状态">
            <a-switch v-model:checked="formData.enabled" :disabled="isViewMode" />
            <span class="strategy-status-text">{{ formData.enabled ? '启用' : '停用' }}</span>
          </a-form-item>
        </a-form>

      </div>

      <!-- 底部按钮 -->
      <div class="modal-footer">
        <a-space>
          <a-button @click="handleCancel">{{ isViewMode ? '关闭' : '取消' }}</a-button>
          <template v-if="!isViewMode">
            <a-button v-if="currentStep > 1" @click="handlePrev">上一步</a-button>
            <a-button v-if="currentStep === 3" type="primary" @click="handleConfirm">完成</a-button>
            <a-button v-else type="primary" @click="handleNext">下一步</a-button>
          </template>
        </a-space>
      </div>
    </a-modal>

    <!-- 查看规则概览弹窗 -->
    <a-modal
      v-model:open="viewModalVisible"
      title="查看抽检规则"
      width="800px"
      :footer="null"
      @cancel="viewModalVisible = false"
    >
      <div v-if="viewRecord" class="view-overview-content">
        <!-- 基本信息 -->
        <div class="view-section">
          <div class="view-section-title">规则基本信息</div>
          <div class="overview-grid">
            <div class="overview-item">
              <span class="overview-label">规则名称</span>
              <span class="overview-value">{{ viewRecord.ruleName }}</span>
            </div>
            <div class="overview-item">
              <span class="overview-label">规则说明</span>
              <span class="overview-value">{{ viewRecord.ruleDescription }}</span>
            </div>
            <div class="overview-item">
              <span class="overview-label">质检方式</span>
              <span class="overview-value">{{ viewRecord.inspectType === 'ai' ? 'AI 质检' : '人工质检' }}</span>
            </div>
            <div class="overview-item">
              <span class="overview-label">质检模型</span>
              <span class="overview-value">{{ qualityModelOptions.find(o => o.value === viewRecord!.qualityModel)?.label || viewRecord.qualityModel }}</span>
            </div>
            <div class="overview-item">
              <span class="overview-label">数据类型</span>
              <span class="overview-value">
                <a-tag v-if="viewRecord.dataType === 'ai_assisted'" color="blue">人机协同录音</a-tag>
                <a-tag v-else color="cyan">人工外呼录音</a-tag>
              </span>
            </div>
            <div class="overview-item">
              <span class="overview-label">分配质检员</span>
              <span class="overview-value">{{ viewRecord.inspectorCount }} 人</span>
            </div>
          </div>
        </div>

        <a-divider />

        <!-- 数据抽样规则 -->
        <div class="view-section">
          <div class="view-section-title">数据抽样规则</div>
          <div class="overview-grid">
            <div class="overview-item">
              <span class="overview-label">采样方式</span>
              <span class="overview-value">{{ viewRecord.samplingMethod === 'average' ? '平均采样' : '按比例采样' }}</span>
            </div>
            <div class="overview-item">
              <span class="overview-label">分配方式</span>
              <span class="overview-value">
                <template v-if="viewRecord.allocationMethod === 'total'">按总数 {{ viewRecord.allocationValue }} 条</template>
                <template v-else-if="viewRecord.allocationMethod === 'ratio'">按比例 {{ viewRecord.allocationValue }}%</template>
                <template v-else>人均 {{ viewRecord.allocationValue }} 条</template>
              </span>
            </div>
          </div>
        </div>

        <a-divider />

        <!-- 任务创建规则 -->
        <div class="view-section">
          <div class="view-section-title">任务创建规则</div>
          <div class="overview-grid">
            <div class="overview-item">
              <span class="overview-label">执行频率</span>
              <span class="overview-value">{{ getViewScheduleLabel(viewRecord) }}</span>
            </div>
            <div class="overview-item">
              <span class="overview-label">数据时间偏移</span>
              <span class="overview-value">
                <template v-if="viewRecord.dataOffsetMode === 'timeRange'">
                  当天 {{ viewRecord.dataStartTime || '未设置' }} ~ {{ viewRecord.dataEndTime || '未设置' }}
                </template>
                <template v-else>
                  T-{{ viewRecord.dataOffset }} 日
                </template>
              </span>
            </div>
            <div class="overview-item">
              <span class="overview-label">有效期</span>
              <span class="overview-value">
                <template v-if="viewRecord.permanent">永久有效</template>
                <template v-else>{{ viewRecord.startDate }} 至 {{ viewRecord.endDate || '未设置' }}</template>
              </span>
            </div>
            <div class="overview-item">
              <span class="overview-label">启用状态</span>
              <span class="overview-value">
                <a-switch :checked="viewRecord.status === 'enabled'" size="small" disabled />
              </span>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <a-button @click="viewModalVisible = false">关闭</a-button>
      </template>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { message, Modal } from 'ant-design-vue'
import type { FormInstance, Rule } from 'ant-design-vue/es/form'
import Pagination from '@/components/Pagination'
import {
  SearchOutlined,
  ReloadOutlined,
  PlusOutlined,
  DeleteOutlined,
  PlusCircleOutlined,
  MinusCircleOutlined,
} from '@ant-design/icons-vue'

// ============ 类型定义 ============
interface ConditionItem {
  id: number
  fieldType: string
  operator: string
  value: string
  value2?: string
}

interface ConditionExpression {
  id: number
  conditions: ConditionItem[]
}

interface SceneItem {
  id: number
  sceneName: string
  ratio: number
}

interface AgentItem {
  id: number
  agentId: string
  ratio: number
}

interface DurationItem {
  id: number
  minDuration: number | null
  maxDuration: number | null
  ratio: number
}

interface ScheduleData {
  dataOffsetMode: 'days' | 'timeRange'
  dataOffset: number
  dataStartTime: any
  dataEndTime: any
  permanent: boolean
  executeTimeValue: any
  startDateValue: any
  endDateValue: any
}

interface SamplingRuleItem {
  ruleId: number
  ruleName: string
  ruleDescription: string
  inspectType: 'ai' | 'manual'
  qualityModel: string
  dataType: string
  samplingMethod: string
  allocationMethod: string
  allocationValue: number
  executeTime: string
  dataOffsetMode: 'days' | 'timeRange'
  dataOffset: number
  dataStartTime: string | null
  dataEndTime: string | null
  startDate: string
  endDate: string | null
  permanent: boolean
  status: 'enabled' | 'disabled'
  inspectorCount: number
  createdAt: string
}

interface FormData {
  ruleName: string
  ruleDescription: string
  inspectType: string
  qualityModel: string
  dataType: string
  conditionExpressions: ConditionExpression[]
  samplingMethod: string
  samplingDimension: string
  sceneItems: SceneItem[]
  agentItems: AgentItem[]
  durationItems: DurationItem[]
  allocationMethod: string
  allocationValue: number | null
  inspectors: string[]
  schedule: ScheduleData
  enabled: boolean
}


// ============ 列表相关 ============
const columns = [
  { title: '规则 ID', dataIndex: 'ruleId', key: 'ruleId', width: 90 },
  { title: '规则名称', dataIndex: 'ruleName', key: 'ruleName', width: 200, ellipsis: true },
  { title: '规则说明', dataIndex: 'ruleDescription', key: 'ruleDescription', width: 220, ellipsis: true },
  { title: '数据类型', dataIndex: 'dataType', key: 'dataType', width: 140 },
  { title: '采样方式', dataIndex: 'samplingMethod', key: 'samplingMethod', width: 110 },
  { title: '分配规则', dataIndex: 'allocationMethod', key: 'allocationMethod', width: 150 },
  { title: '执行计划', dataIndex: 'schedule', key: 'schedule', width: 180, ellipsis: true },
  { title: '状态', dataIndex: 'status', key: 'status', width: 80 },
  { title: '质检员', dataIndex: 'inspectorCount', key: 'inspectorCount', width: 80 },
  { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt', width: 170 },
  { title: '操作', key: 'action', fixed: 'right' as any, width: 180 },
]

const searchForm = reactive({
  ruleName: '',
  dataType: undefined as string | undefined,
  samplingMethod: undefined as string | undefined,
  status: undefined as string | undefined,
})

const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 8,
})

const total = computed(() => pagination.total)

const inspectorOptions = [
  { label: '张三', value: 'zhangsan' },
  { label: '李四', value: 'lisi' },
  { label: '王五', value: 'wangwu' },
  { label: '赵六', value: 'zhaoliu' },
  { label: 'admin', value: 'admin' },
]

const qualityModelOptions = [
  { label: '合规质检', value: 'compliance' },
  { label: '营销意向', value: 'marketing' },
  { label: '投诉倾向', value: 'complaint' },
  { label: '服务质检', value: 'service' },
  { label: '销售质检', value: 'sales' },
]

const sceneOptions = [
  { label: '信用卡开卡', value: 'credit_card_activate' },
  { label: '信用卡促活', value: 'credit_card_promote' },
  { label: '信用卡账单分期', value: 'credit_card_installment' },
  { label: '贷款转存', value: 'loan_transfer' },
  { label: '贷款审批通知', value: 'loan_approval' },
  { label: '活期理财', value: 'demand_finance' },
  { label: '定期理财', value: 'fixed_finance' },
  { label: '资产提升', value: 'asset_upgrade' },
  { label: '存款营销', value: 'deposit_marketing' },
  { label: '保险营销', value: 'insurance_marketing' },
  { label: '客户回访', value: 'customer_callback' },
  { label: '投诉处理', value: 'complaint_handling' },
]

const agentOptions = [
  { label: 'A001 - 张三', value: 'A001' },
  { label: 'A002 - 李四', value: 'A002' },
  { label: 'A003 - 王五', value: 'A003' },
  { label: 'A004 - 赵六', value: 'A004' },
  { label: 'A005 - 孙七', value: 'A005' },
  { label: 'A006 - 周八', value: 'A006' },
  { label: 'A007 - 吴九', value: 'A007' },
  { label: 'A008 - 郑十', value: 'A008' },
]

// 模拟数据
const mockData: SamplingRuleItem[] = [
  {
    ruleId: 1001,
    ruleName: '2026年Q1金融合规抽检',
    ruleDescription: '针对金融产品外呼录音的合规性抽检，覆盖信用卡和贷款业务',
    inspectType: 'ai',
    qualityModel: 'compliance',
    dataType: 'ai_assisted',
    samplingMethod: 'ratio',
    allocationMethod: 'total',
    allocationValue: 500,
    executeTime: '09:00',
    dataOffsetMode: 'days',
    dataOffset: 1,
    dataStartTime: null,
    dataEndTime: null,
    startDate: '2026-01-01',
    endDate: '2026-03-31',
    permanent: false,
    status: 'enabled',
    inspectorCount: 3,
    createdAt: '2026-01-05 10:00:00',
  },
  {
    ruleId: 1002,
    ruleName: '营销话术合规抽检',
    ruleDescription: '针对营销类外呼的话术合规性抽检',
    inspectType: 'manual',
    qualityModel: 'sales',
    dataType: 'manual_outbound',
    samplingMethod: 'average',
    allocationMethod: 'ratio',
    allocationValue: 10,
    executeTime: '08:30',
    dataOffsetMode: 'days',
    dataOffset: 2,
    dataStartTime: null,
    dataEndTime: null,
    startDate: '2026-02-01',
    endDate: null,
    permanent: true,
    status: 'enabled',
    inspectorCount: 2,
    createdAt: '2026-02-01 14:30:00',
  },
  {
    ruleId: 1003,
    ruleName: '投诉专线质量抽检',
    ruleDescription: '投诉倾向录音质量抽检，每人每日分配定量',
    inspectType: 'ai',
    qualityModel: 'complaint',
    dataType: 'ai_assisted',
    samplingMethod: 'ratio',
    allocationMethod: 'perPerson',
    allocationValue: 20,
    executeTime: '10:00',
    dataOffsetMode: 'timeRange',
    dataOffset: 1,
    dataStartTime: '08:00',
    dataEndTime: '18:00',
    startDate: '2026-03-01',
    endDate: '2026-06-30',
    permanent: false,
    status: 'enabled',
    inspectorCount: 4,
    createdAt: '2026-03-01 09:00:00',
  },
  {
    ruleId: 1004,
    ruleName: '新员工入职质检抽检',
    ruleDescription: '新入职坐席通话质量抽检规则',
    inspectType: 'manual',
    qualityModel: 'service',
    dataType: 'manual_outbound',
    samplingMethod: 'average',
    allocationMethod: 'total',
    allocationValue: 200,
    executeTime: '08:00',
    dataOffsetMode: 'days',
    dataOffset: 3,
    dataStartTime: null,
    dataEndTime: null,
    startDate: '2026-04-01',
    endDate: null,
    permanent: true,
    status: 'enabled',
    inspectorCount: 2,
    createdAt: '2026-04-01 11:00:00',
  },
  {
    ruleId: 1005,
    ruleName: '信用卡业务合规抽检',
    ruleDescription: '信用卡相关外呼录音合规性抽检',
    inspectType: 'ai',
    qualityModel: 'compliance',
    dataType: 'ai_assisted',
    samplingMethod: 'ratio',
    allocationMethod: 'ratio',
    allocationValue: 15,
    executeTime: '09:30',
    dataOffsetMode: 'timeRange',
    dataOffset: 1,
    dataStartTime: '09:00',
    dataEndTime: '20:00',
    startDate: '2026-01-15',
    endDate: '2026-12-31',
    permanent: false,
    status: 'disabled',
    inspectorCount: 3,
    createdAt: '2026-01-15 16:00:00',
  },
  {
    ruleId: 1006,
    ruleName: '贷款业务话术抽检',
    ruleDescription: '贷款类外呼话术合规性抽检',
    inspectType: 'manual',
    qualityModel: 'marketing',
    dataType: 'manual_outbound',
    samplingMethod: 'ratio',
    allocationMethod: 'total',
    allocationValue: 300,
    executeTime: '07:00',
    dataOffsetMode: 'days',
    dataOffset: 2,
    dataStartTime: null,
    dataEndTime: null,
    startDate: '2026-05-01',
    endDate: null,
    permanent: true,
    status: 'enabled',
    inspectorCount: 2,
    createdAt: '2026-05-01 08:00:00',
  },
  {
    ruleId: 1007,
    ruleName: '理财业务风险抽检',
    ruleDescription: '理财产品外呼风险提示合规抽检',
    inspectType: 'ai',
    qualityModel: 'compliance',
    dataType: 'ai_assisted',
    samplingMethod: 'average',
    allocationMethod: 'perPerson',
    allocationValue: 15,
    executeTime: '10:30',
    dataOffsetMode: 'days',
    dataOffset: 5,
    dataStartTime: null,
    dataEndTime: null,
    startDate: '2026-03-01',
    endDate: '2026-09-30',
    permanent: false,
    status: 'enabled',
    inspectorCount: 3,
    createdAt: '2026-03-01 13:00:00',
  },
  {
    ruleId: 1008,
    ruleName: '保险业务合规抽检',
    ruleDescription: '保险产品外呼合规性抽检规则',
    inspectType: 'manual',
    qualityModel: 'service',
    dataType: 'manual_outbound',
    samplingMethod: 'ratio',
    allocationMethod: 'total',
    allocationValue: 400,
    executeTime: '08:00',
    dataOffsetMode: 'days',
    dataOffset: 1,
    dataStartTime: null,
    dataEndTime: null,
    startDate: '2026-06-01',
    endDate: null,
    permanent: true,
    status: 'enabled',
    inspectorCount: 4,
    createdAt: '2026-06-01 09:00:00',
  },
]

const tableData = computed(() => {
  let filtered = [...mockData]
  if (searchForm.ruleName) {
    filtered = filtered.filter(item =>
      item.ruleName.toLowerCase().includes(searchForm.ruleName.toLowerCase())
    )
  }
  if (searchForm.dataType) {
    filtered = filtered.filter(item => item.dataType === searchForm.dataType)
  }
  if (searchForm.samplingMethod) {
    filtered = filtered.filter(item => item.samplingMethod === searchForm.samplingMethod)
  }
  if (searchForm.status) {
    filtered = filtered.filter(item => item.status === searchForm.status)
  }
  return filtered
})

const getScheduleLabel = (record: SamplingRuleItem) => {
  let desc = `每天 ${record.executeTime}`
  if (record.dataOffsetMode === 'timeRange') {
    desc += ` (${record.dataStartTime || '?'}~${record.dataEndTime || '?'})`
  } else {
    desc += ` T-${record.dataOffset}`
  }
  return desc
}

const getViewScheduleLabel = (record: SamplingRuleItem) => {
  let desc = `每天 ${record.executeTime}`
  if (record.dataOffsetMode === 'timeRange') {
    desc += `，抓取当天 ${record.dataStartTime || '未设置'}~${record.dataEndTime || '未设置'} 的数据`
  } else {
    desc += `，T-${record.dataOffset} 日`
  }
  return desc
}

// ============ 弹窗相关 ============
const modalVisible = ref(false)
const viewModalVisible = ref(false)
const viewRecord = ref<SamplingRuleItem | null>(null)
const currentStep = ref(1)
const isEditMode = ref(false)
const isViewMode = ref(false)
const editingRuleId = ref<number | null>(null)
const step1FormRef = ref<FormInstance>()

let conditionIdCounter = 0
let expressionIdCounter = 0
let sceneIdCounter = 0
let agentIdCounter = 0
let durationIdCounter = 0

const createDefaultFormData = (): FormData => ({
  ruleName: '',
  ruleDescription: '',
  inspectType: 'ai',
  qualityModel: undefined as unknown as string,
  dataType: 'ai_assisted',
  conditionExpressions: [
    {
      id: ++expressionIdCounter,
      conditions: [
        { id: ++conditionIdCounter, fieldType: '', operator: '', value: '' },
      ],
    },
  ],
  samplingMethod: 'average',
  samplingDimension: 'scene',
  sceneItems: [{ id: ++sceneIdCounter, sceneName: '', ratio: 0 }],
  agentItems: [{ id: ++agentIdCounter, agentId: '', ratio: 0 }],
  durationItems: [{ id: ++durationIdCounter, minDuration: null, maxDuration: null, ratio: 0 }],
  allocationMethod: 'total',
  allocationValue: null,
  inspectors: [],
  schedule: {
    dataOffsetMode: 'days',
    dataOffset: 1,
    dataStartTime: null,
    dataEndTime: null,
    permanent: true,
    executeTimeValue: null,
    startDateValue: null,
    endDateValue: null,
  },
  enabled: true,
})

const formData = reactive<FormData>(createDefaultFormData())

const step1Rules: Record<string, Rule[]> = {
  ruleName: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  ruleDescription: [{ required: true, message: '请输入规则说明', trigger: 'blur' }],
}

// 抽样维度表格列
const sceneColumns = [
  { title: '场景名称', key: 'sceneName', width: 200 },
  { title: '占比', key: 'ratio', width: 140 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

const agentColumns = [
  { title: '坐席工号', key: 'agentId', width: 200 },
  { title: '占比', key: 'ratio', width: 140 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

const durationColumns = [
  { title: '时长区间', key: 'range', width: 240 },
  { title: '占比', key: 'ratio', width: 140 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 占比合计
const sceneRatioTotal = computed(() =>
  formData.sceneItems.reduce((sum, item) => sum + (item.ratio || 0), 0)
)
const agentRatioTotal = computed(() =>
  formData.agentItems.reduce((sum, item) => sum + (item.ratio || 0), 0)
)
const durationRatioTotal = computed(() =>
  formData.durationItems.reduce((sum, item) => sum + (item.ratio || 0), 0)
)

// 调度描述
const scheduleDescription = computed(() => {
  let desc = '每天'
  if (formData.schedule.dataOffsetMode === 'timeRange') {
    const start = formData.schedule.dataStartTime ? formData.schedule.dataStartTime.format('HH:mm') : '未设置'
    const end = formData.schedule.dataEndTime ? formData.schedule.dataEndTime.format('HH:mm') : '未设置'
    desc += ` 抓取当天 ${start}~${end} 的数据`
  } else {
    desc += ` 生成T-${formData.schedule.dataOffset}日的抽检任务`
  }
  return desc
})

// ============ 列表操作 ============
const handleSearch = () => {
  message.success('搜索成功')
}

const handleReset = () => {
  searchForm.ruleName = ''
  searchForm.dataType = undefined
  searchForm.samplingMethod = undefined
  searchForm.status = undefined
  message.success('已重置搜索条件')
}

const handlePageChange = (page: number, size: number) => {
  pagination.currentPage = page
  pagination.pageSize = size
}

const handleCreate = () => {
  isEditMode.value = false
  isViewMode.value = false
  editingRuleId.value = null
  currentStep.value = 1
  resetFormData()
  modalVisible.value = true
}

const handleView = (record: SamplingRuleItem) => {
  viewRecord.value = record
  viewModalVisible.value = true
}

const handleEdit = (record: SamplingRuleItem) => {
  isEditMode.value = true
  isViewMode.value = false
  editingRuleId.value = record.ruleId
  currentStep.value = 1
  fillFormData(record)
  modalVisible.value = true
}

const handleDelete = (record: SamplingRuleItem) => {
  Modal.confirm({
    title: '删除确认',
    content: `确定要删除抽检规则 "${record.ruleName}" 吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      message.success('删除成功')
    },
  })
}

const handleToggleStatus = (record: SamplingRuleItem, checked: boolean) => {
  record.status = checked ? 'enabled' : 'disabled'
  message.success(checked ? '已启用' : '已停用')
}

// ============ 弹窗操作 ============
const resetFormData = () => {
  const defaults = createDefaultFormData()
  Object.assign(formData, defaults)
  conditionIdCounter = 0
  expressionIdCounter = 0
  sceneIdCounter = 0
  agentIdCounter = 0
  durationIdCounter = 0
  // 重新生成初始 ID
  expressionIdCounter++
  conditionIdCounter++
  sceneIdCounter++
  agentIdCounter++
  durationIdCounter++
  formData.conditionExpressions = [{
    id: expressionIdCounter,
    conditions: [{ id: conditionIdCounter, fieldType: '', operator: '', value: '' }],
  }]
  formData.sceneItems = [{ id: sceneIdCounter, sceneName: '', ratio: 0 }]
  formData.agentItems = [{ id: agentIdCounter, agentId: '', ratio: 0 }]
  formData.durationItems = [{ id: durationIdCounter, minDuration: null, maxDuration: null, ratio: 0 }]
}

const fillFormData = (record: SamplingRuleItem) => {
  formData.ruleName = record.ruleName
  formData.ruleDescription = record.ruleDescription
  formData.inspectType = 'ai'
  formData.qualityModel = ''
  formData.dataType = record.dataType
  formData.samplingMethod = record.samplingMethod
  formData.allocationMethod = record.allocationMethod
  formData.allocationValue = record.allocationValue
  formData.inspectors = []
  formData.schedule.dataOffsetMode = record.dataOffsetMode
  formData.schedule.dataOffset = record.dataOffset
  formData.schedule.dataStartTime = null
  formData.schedule.dataEndTime = null
  formData.schedule.permanent = record.permanent
  formData.enabled = record.status === 'enabled'
  formData.schedule.executeTimeValue = null
  formData.schedule.startDateValue = null
  formData.schedule.endDateValue = null
}

const handleCancel = () => {
  modalVisible.value = false
  currentStep.value = 1
  isEditMode.value = false
  isViewMode.value = false
  editingRuleId.value = null
}

const handleNext = async () => {
  if (currentStep.value === 1) {
    if (!step1FormRef.value) return
    try {
      await step1FormRef.value.validate()
    } catch {
      return
    }
    if (!formData.qualityModel) {
      message.error('请选择质检模型')
      return
    }
    if (formData.inspectors.length === 0) {
      message.error('请选择分配对象')
      return
    }
    currentStep.value++
  } else if (currentStep.value === 2) {
    if (!formData.dataType) {
      message.error('请选择质检对象')
      return
    }
    if (!formData.allocationValue) {
      message.error('请设置采样数量')
      return
    }
    if (formData.samplingMethod === 'ratio') {
      const total = formData.samplingDimension === 'scene'
        ? sceneRatioTotal.value
        : formData.samplingDimension === 'agent'
          ? agentRatioTotal.value
          : durationRatioTotal.value
      if (total !== 100) {
        message.error('占比总和必须等于 100%')
        return
      }
    }
    currentStep.value++
  }
}

const handlePrev = () => {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

const handleConfirm = () => {
  if (!formData.ruleName) {
    message.error('请输入规则名称')
    return
  }
  if (isEditMode.value) {
    console.log('编辑抽检规则:', editingRuleId.value, formData)
    message.success('抽检规则更新成功')
  } else {
    console.log('创建抽检规则:', formData)
    message.success('抽检规则创建成功')
  }
  handleCancel()
}

// ============ 条件表达式操作 ============
const handleAddExpression = () => {
  expressionIdCounter++
  formData.conditionExpressions.push({
    id: expressionIdCounter,
    conditions: [{ id: ++conditionIdCounter, fieldType: '', operator: '', value: '' }],
  })
}

const handleDeleteExpression = (index: number) => {
  formData.conditionExpressions.splice(index, 1)
}

const handleAddCondition = (expressionIndex: number) => {
  conditionIdCounter++
  formData.conditionExpressions[expressionIndex].conditions.push({
    id: conditionIdCounter,
    fieldType: '',
    operator: '',
    value: '',
  })
}

const handleDeleteCondition = (expressionIndex: number, conditionIndex: number) => {
  formData.conditionExpressions[expressionIndex].conditions.splice(conditionIndex, 1)
}

// ============ 抽样维度操作 ============
const handleDimensionChange = () => {
  // 切换维度时不做额外处理
}

// 按场景
const handleAddSceneItem = () => {
  sceneIdCounter++
  formData.sceneItems.push({ id: sceneIdCounter, sceneName: '', ratio: 0 })
}

const handleDeleteSceneItem = (index: number) => {
  formData.sceneItems.splice(index, 1)
}

// 按坐席
const handleAddAgentItem = () => {
  agentIdCounter++
  formData.agentItems.push({ id: agentIdCounter, agentId: '', ratio: 0 })
}

const handleDeleteAgentItem = (index: number) => {
  formData.agentItems.splice(index, 1)
}

// 按通话时长
const handleAddDurationItem = () => {
  durationIdCounter++
  formData.durationItems.push({ id: durationIdCounter, minDuration: null, maxDuration: null, ratio: 0 })
}

const handleDeleteDurationItem = (index: number) => {
  formData.durationItems.splice(index, 1)
}
</script>

<style scoped>
.sampling-rule-page {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.sampling-rule-wrapper {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* 页面标题区域 */
.sampling-header-section {
  background: #fff;
  border-radius: 4px;
  padding: 16px 24px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.sampling-header {
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
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  margin: 0;
}

.page-description {
  font-size: 14px;
  color: #595959;
  margin: 0;
}

.header-right {
  display: flex;
  align-items: center;
}

.create-btn {
  background: #1677ff;
  border-color: #1677ff;
  color: #fff;
  padding: 6px 16px;
  font-size: 14px;
  border-radius: 4px;
  font-weight: 400;
  transition: all 0.3s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  height: 32px;
  line-height: 1;
}

.create-btn .anticon {
  font-size: 14px;
}

.create-btn:hover {
  background: #4096ff;
  border-color: #4096ff;
  color: #fff;
}

/* 搜索和表格合并区域 */
.search-and-table-area {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 搜索区域 */
.search-area {
  padding: 0 0 16px 0;
  margin-bottom: 16px;
}

.search-area :deep(.ant-form-item) {
  margin-bottom: 12px;
}

.search-area :deep(.ant-input) {
  font-size: 14px;
  color: #262626;
}

.search-area :deep(.ant-input::placeholder) {
  color: #bfbfbf;
  font-size: 14px;
}

.search-area :deep(.ant-select) {
  width: 100%;
}

.search-area :deep(.ant-select-selector) {
  font-size: 14px;
  color: #262626;
}

.search-area :deep(.ant-select-selection-placeholder) {
  color: #bfbfbf !important;
  font-size: 14px !important;
  opacity: 1 !important;
  visibility: visible !important;
}

.search-btn-space {
  display: flex;
  gap: 8px;
}

/* 表格区域 */
.table-area {
  flex: 1;
  padding: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
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
  font-size: 14px;
  color: #595959;
}

.table-wrapper {
  flex: 1;
  overflow: auto;
}

.table-wrapper :deep(.ant-table) {
  font-size: 14px;
}

.table-wrapper :deep(.ant-table-thead > tr > th) {
  background: #f0f5ff;
  font-weight: 600;
  color: #262626;
  border-bottom: 1px solid #ebeef5;
  height: 45px;
}

.table-wrapper :deep(.ant-table-thead > tr > th .ant-table-cell) {
  color: #262626;
  font-weight: 600;
}

.table-wrapper :deep(.ant-table-tbody > tr > td) {
  height: 45px;
}

.table-wrapper :deep(.ant-table-tbody > tr > td .ant-table-cell) {
  color: #262626;
  white-space: nowrap;
}

.table-wrapper :deep(.ant-table-tbody > tr:hover > td) {
  background-color: #f0f5ff;
}

.table-wrapper :deep(.ant-table) {
  border: none;
}

.table-wrapper :deep(.ant-tag) {
  transition: none !important;
  animation: none !important;
}

.table-wrapper :deep(.ant-btn-link) {
  padding: 4px 8px;
  font-size: 14px;
  height: auto;
  line-height: 1;
  background: transparent;
  border: none;
  border-radius: 4px;
  transition: all 0.3s;
  text-align: center;
  font-weight: 400;
}

.table-wrapper :deep(.ant-btn-link:not([disabled]):hover) {
  color: #40a9ff;
}

.table-wrapper :deep(.ant-btn-link.ant-btn-dangerous) {
  color: #ff4d4f;
}

.table-wrapper :deep(.ant-btn-link.ant-btn-dangerous:hover) {
  color: #ff7875;
}

.table-wrapper :deep(.ant-space) {
  gap: 8px !important;
  display: flex !important;
  align-items: center;
}

.rule-id {
  font-family: 'SF Mono', 'Monaco', 'Menlo', 'Courier New', monospace;
  color: #1677ff;
}

/* 弹窗步骤条 */
.modal-steps {
  margin-bottom: 24px;
}

/* 步骤内容 */
.step-content {
  min-height: 300px;
}

.step-section-title {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 4px;
}

.step-section-subtitle {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 4px;
}

.step-section-desc {
  font-size: 14px;
  color: #8c8c8c;
  margin-bottom: 20px;
}

.step-form {
  margin-top: 16px;
}

.required-label {
  color: #ff4d4f;
  margin-right: 4px;
}

.data-range-tip {
  font-size: 14px;
  color: #595959;
  margin-bottom: 16px;
  padding-left: 8px;
}

/* 条件表达式区域 */
.condition-area {
  margin-top: 8px;
}

.expression-list-inline {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.expression-item-inline {
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  padding: 12px;
  background: #fafafa;
}

.expression-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.condition-list-inline {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.condition-item-inline {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.between-inputs {
  display: flex;
  align-items: center;
  gap: 4px;
}

.between-separator {
  color: #8c8c8c;
}

.delete-condition-btn {
  color: #ff4d4f;
  padding: 4px;
}

.add-condition-btn-inline {
  color: #1677ff;
  padding: 4px;
}

.condition-connector-inline {
  color: #8c8c8c;
  font-size: 13px;
  margin: 0 4px;
}

.expression-footer {
  margin-top: 8px;
  border-top: 1px solid #e8e8e8;
  padding-top: 8px;
}

.add-expression-btn-wrapper-inline {
  margin-top: 12px;
}

/* 采样方式选项区域 */
.sampling-option-area {
  margin-top: 16px;
}

.sampling-tip-alert {
  margin-top: 8px;
}

.ratio-sampling-config {
  margin-top: 8px;
}

.dimension-section {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.dimension-label {
  font-size: 14px;
  color: #262626;
  font-weight: 500;
}

.dimension-tip-alert {
  margin-bottom: 16px;
}

.dimension-table-area {
  margin-top: 8px;
}

.dimension-table {
  margin-bottom: 8px;
}

.dimension-table :deep(.ant-table-thead > tr > th) {
  background: #f0f5ff;
  font-weight: 600;
  color: #262626;
}

.dimension-table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.ratio-total {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}

.ratio-total.ratio-error {
  color: #ff4d4f;
}

.range-separator {
  margin: 0 4px;
  color: #8c8c8c;
}

.range-unit {
  margin-left: 4px;
  color: #8c8c8c;
  font-size: 13px;
}

/* 配额单位 */
.quota-unit {
  margin-left: 8px;
  color: #8c8c8c;
  font-size: 13px;
}

.quota-tip {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
  line-height: 1.5;
}

/* 偏移行 */
.offset-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.offset-range-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.offset-prefix,
.offset-suffix {
  color: #595959;
  font-size: 14px;
}

.offset-preview {
  margin-top: 4px;
  color: #8c8c8c;
  font-size: 13px;
}

/* 日期范围 */
.schedule-date-range {
  display: flex;
  align-items: center;
  gap: 8px;
}

.date-separator {
  color: #8c8c8c;
}

/* 策略状态文字 */
.strategy-status-text {
  margin-left: 8px;
  color: #595959;
  font-size: 14px;
}

.fixed-value {
  color: #595959;
  font-size: 14px;
}

/* 策略概览卡片 */
.strategy-overview {
  margin-top: 24px;
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  padding: 16px;
  background: #fafafa;
}

.overview-title {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 12px;
}

.overview-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.overview-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.overview-label {
  font-size: 12px;
  color: #8c8c8c;
}

.overview-value {
  font-size: 14px;
  color: #262626;
}

/* 弹窗底部 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

/* 查看规则概览弹窗 */
.view-overview-content {
  padding: 8px 0;
}

.view-section {
  margin-bottom: 0;
}

.view-section-title {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 16px;
}
</style>
