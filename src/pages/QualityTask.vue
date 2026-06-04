<template>
  <div class="quality-inspection-task">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">质检任务</h2>
            <p class="page-description">选择需要质检的通话录音和质检模型，创建 AI 质检和人工质检任务。</p>
          </div>
          <div class="header-right">
            <a-button type="primary" class="create-task-btn" @click="handleCreateTask">
              <plus-outlined />
              新建质检任务
            </a-button>
          </div>
        </div>
      </div>

      <!-- 搜索区域和表格区域合并 -->
      <div class="search-and-table-area">
        <!-- 标签页切换 -->
        <div class="tabs-section">
          <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
            <a-tab-pane key="ai" tab="AI 质检任务" />
            <a-tab-pane key="manual" tab="人工质检任务" />
          </a-tabs>
        </div>

        <!-- 搜索区域 -->
        <div class="search-area">
          <a-form ref="searchFormRef" layout="vertical">
            <a-row :gutter="[16, 0]">
              <!-- 第一行 -->
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.taskName"
                    placeholder="请输入质检任务名称"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.taskId"
                    placeholder="请输入质检任务 ID"
                    allow-clear
                    @press-enter="handleSearch"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.taskDescription"
                    placeholder="请输入任务说明"
                    allow-clear
                  />
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.taskStatus"
                    placeholder="请选择任务状态"
                    allow-clear
                  >
                    <a-select-option value="running">进行中</a-select-option>
                    <a-select-option value="completed">已完成</a-select-option>
                    <a-select-option value="paused">已暂停</a-select-option>
                    <a-select-option value="pending">未开始</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="[16, 0]">
              <!-- 第二行 -->
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.qualityObject"
                    placeholder="请选择质检对象"
                    allow-clear
                  >
                    <a-select-option value="manual_outbound">人工外呼录音</a-select-option>
                    <a-select-option value="ai_assisted">人机协同录音</a-select-option>
                    <a-select-option value="inbound">呼入录音</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.qualityModel"
                    placeholder="请选择质检模型"
                    allow-clear
                  >
                    <a-select-option value="compliance">合规质检</a-select-option>
                    <a-select-option value="service">服务质检</a-select-option>
                    <a-select-option value="sales">销售质检</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6" v-if="activeTab === 'ai'">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.auditor"
                    placeholder="请选择审核员"
                    allow-clear
                  >
                    <a-select-option value="zhangsan">张三</a-select-option>
                    <a-select-option value="lisi">李四</a-select-option>
                    <a-select-option value="wangwu">王五</a-select-option>
                    <a-select-option value="admin">admin</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="6" v-if="activeTab === 'manual'">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.inspector"
                    placeholder="请选择质检员"
                    allow-clear
                  >
                    <a-select-option value="zhangsan">张三</a-select-option>
                    <a-select-option value="lisi">李四</a-select-option>
                    <a-select-option value="wangwu">王五</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
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
          <!-- 表格上方工具栏 -->
          <div class="table-toolbar">
            <div class="table-toolbar-left">
              <span class="selection-info">共 {{ total }} 条</span>
            </div>
          </div>

          <!-- 数据表格 -->
          <div class="table-wrapper">
            <a-table
              :columns="columns"
              :data-source="tableData"
              :pagination="false"
              :scroll="{ x: 1200 }"
              row-key="taskId"
            >
              <template #bodyCell="{ column, record }">
                <!-- 任务状态列 -->
                <template v-if="column.key === 'status'">
                  <a-tag v-if="record.status === 'running'" color="blue">进行中</a-tag>
                  <a-tag v-else-if="record.status === 'paused'" color="orange">已暂停</a-tag>
                  <a-tag v-else-if="record.status === 'completed'" color="green">已完成</a-tag>
                  <a-tag v-else color="default">未开始</a-tag>
                </template>
                <!-- AI 质检进度列 -->
                <template v-else-if="column.key === 'aiProgress'">
                  <div class="progress-cell">
                    <a-progress
                      :percent="record.aiProgressPercent"
                      :status="record.aiProgressPercent === 100 ? 'success' : 'active'"
                      :stroke-width="8"
                      :show-info="false"
                      class="progress-bar"
                    />
                    <span class="progress-text">{{ record.aiProgressPercent }}% ({{ record.aiCompleted }} / {{ record.aiTotal }})</span>
                  </div>
                </template>
                <!-- 人工审核状态/人工质检状态列 -->
                <template v-else-if="column.key === 'auditStatus'">
                  <!-- AI 质检审核状态 -->
                  <a-tag v-if="activeTab === 'ai' && record.auditStatus === 'auditing'" color="blue">进行中</a-tag>
                  <a-tag v-else-if="activeTab === 'ai' && record.auditStatus === 'pending'" color="orange">待审核</a-tag>
                  <a-tag v-else-if="activeTab === 'ai' && record.auditStatus === 'approved'" color="green">已通过</a-tag>
                  <a-tag v-else-if="activeTab === 'ai' && record.auditStatus === 'rejected'" color="red">已驳回</a-tag>
                  <!-- 人工质检状态 -->
                  <a-tag v-else-if="record.auditStatus === 'running'" color="blue">进行中</a-tag>
                  <a-tag v-else-if="record.auditStatus === 'paused'" color="orange">已暂停</a-tag>
                  <a-tag v-else-if="record.auditStatus === 'completed'" color="green">已完成</a-tag>
                  <a-tag v-else color="default">未开始</a-tag>
                </template>
                <!-- 审核员列 -->
                <template v-else-if="column.key === 'auditor'">
                  <div v-if="Array.isArray(record.auditor)" class="auditor-tags">
                    <a-tag v-for="(name, idx) in record.auditor" :key="idx" color="blue">{{ name }}</a-tag>
                  </div>
                  <span v-else>{{ record.auditor }}</span>
                </template>
                <!-- 操作列 -->
                <template v-else-if="column.key === 'action'">
                  <a-space>
                    <a-button type="link" size="small" @click="handleDetail(record)">
                      详情
                    </a-button>
                    <a-button type="link" size="small" @click="handleEdit(record)">
                      编辑
                    </a-button>
                    <a-button type="link" size="small" @click="handleToggleStatus(record)">
                      {{ record.status === 'running' ? '暂停' : '开启' }}
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
            v-model:current="pagination.currentPage"
            v-model:page-size="pagination.pageSize"
            :total="pagination.total"
            @change="handlePageChange"
          />
        </div>
      </div>

      <!-- 新建质检任务弹窗 -->
      <a-modal
        v-model:open="createTaskModalVisible"
        title="新建质检任务"
        width="800px"
        :closable="false"
        :footer="null"
        @cancel="handleCreateCancel"
      >
        <!-- 步骤条 -->
        <a-steps :current="createTaskStep - 1" class="modal-steps">
          <a-step title="填写基本信息" />
          <a-step title="选择质检数据" />
        </a-steps>

        <!-- 步骤 1：基本信息填写 -->
        <a-form
          v-if="createTaskStep === 1"
          ref="createTaskFormRef"
          :model="createTaskForm"
          :rules="createTaskFormRules"
          layout="horizontal"
          :label-col="{ span: 6 }"
          :wrapper-col="{ span: 16 }"
          class="step-form"
        >
          <a-form-item label="质检类型" name="taskType">
            <a-radio-group v-model:value="createTaskForm.taskType" button-style="solid">
              <a-radio-button value="ai">AI 质检</a-radio-button>
              <a-radio-button value="manual">人工质检</a-radio-button>
            </a-radio-group>
          </a-form-item>
          <a-form-item label="任务名称" name="taskName">
            <a-input
              v-model:value="createTaskForm.taskName"
              placeholder="请输入任务名称"
              :maxlength="50"
              show-count
            />
          </a-form-item>
          <a-form-item label="任务说明" name="taskDescription">
            <a-textarea
              v-model:value="createTaskForm.taskDescription"
              placeholder="请输入任务说明"
              :rows="3"
              :maxlength="200"
              show-count
            />
          </a-form-item>
          <a-form-item label="质检模型" name="qualityModel">
            <a-select
              v-model:value="createTaskForm.qualityModel"
              placeholder="请选择质检模型"
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
          <a-form-item label="质检对象" name="qualityObject">
            <a-select
              v-model:value="createTaskForm.qualityObject"
              placeholder="请选择质检对象"
            >
              <a-select-option
                v-for="option in qualityObjectOptions"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="质检员" name="inspector">
            <a-select
              v-model:value="createTaskForm.inspector"
              mode="multiple"
              placeholder="请选择质检员（可多选）"
              :max-tag-count="3"
            >
              <a-select-option
                v-for="option in inspectorOptions"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </a-select-option>
            </a-select>
            <div v-if="createTaskForm.inspector && createTaskForm.inspector.length > 1" class="inspector-tip">
              质检数据将平均分配给 {{ createTaskForm.inspector.length }} 位质检员
            </div>
          </a-form-item>
        </a-form>

        <!-- 步骤 2：选择质检数据 -->
        <div v-else class="step-2-content">
          <!-- 录音类型选择 -->
          <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }">
            <a-form-item label="录音类型">
              <template #label>
                <span class="required-label">*</span> 录音类型
              </template>
              <a-radio-group v-model:value="createTaskForm.recordType">
                <a-radio value="ai_assisted">人机协同录音</a-radio>
                <a-radio value="manual_outbound">人工外呼录音</a-radio>
                <a-radio value="manual_upload">手动上传录音</a-radio>
              </a-radio-group>
            </a-form-item>
          </a-form>

          <!-- 手动上传录音的文件上传区域 -->
          <div v-if="createTaskForm.recordType === 'manual_upload'" class="upload-section">
            <a-upload
              name="file"
              :multiple="true"
              :file-list="fileList"
              :before-upload="beforeUpload"
              :on-remove="handleRemove"
              :on-change="handleChange"
            >
              <a-button type="primary">
                <upload-outlined />
                选择文件
              </a-button>
            </a-upload>
            <p class="upload-tip">支持批量上传录音文件，单个文件大小不超过 100MB</p>
          </div>

          <!-- 提示文字 -->
          <div v-else class="data-range-tip">
            请选择需要质检的已接通通话范围
          </div>

          <!-- 质检范围选择 - 手动上传录音时不显示 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload'" class="quality-scope-section">
            <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }">
              <a-form-item label="质检范围">
                <template #label>
                  <span class="required-label">*</span> 质检范围
                </template>
                <a-radio-group v-model:value="createTaskForm.qualityScope" @change="handleQualityScopeChange">
                  <a-radio value="full">全量质检</a-radio>
                  <a-radio value="sampling">抽检</a-radio>
                </a-radio-group>
              </a-form-item>
            </a-form>
          </div>

          <!-- 条件筛选区域 - 手动上传录音时不显示，抽检模式下隐藏 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload' && createTaskForm.qualityScope === 'full'" class="condition-area">
            <!-- 条件表达式列表 -->
            <div class="expression-list-inline">
              <div
                v-for="(expression, index) in conditionExpressions"
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
                      >
                        <a-select-option value="callTime">通话时间</a-select-option>
                        <a-select-option value="callDuration">通话时长</a-select-option>
                        <a-select-option value="intent">客户意图</a-select-option>
                        <a-select-option value="agent">坐席工号</a-select-option>
                      </a-select>
                      <a-select
                        v-model:value="condition.operator"
                        style="width: 100px"
                        placeholder="操作符"
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
                      />
                      <div v-else class="between-inputs">
                        <a-input
                          v-model:value="condition.value"
                          style="width: 80px"
                          placeholder="最小值"
                        />
                        <span class="between-separator">~</span>
                        <a-input
                          v-model:value="condition.value2"
                          style="width: 80px"
                          placeholder="最大值"
                        />
                      </div>
                      <a-button
                        v-if="expression.conditions.length > 1"
                        type="text"
                        danger
                        @click="handleDeleteCondition(index, cIndex)"
                        class="delete-condition-btn"
                      >
                        <minus-circle-outlined />
                      </a-button>
                      <a-button
                        v-if="cIndex === expression.conditions.length - 1"
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
                <div class="expression-footer" v-if="conditionExpressions.length > 1">
                  <a-button type="text" danger @click="handleDeleteExpression(index)">
                    <delete-outlined />
                    删除表达式
                  </a-button>
                </div>
              </div>
            </div>

            <!-- 添加表达式按钮 -->
            <div class="add-expression-btn-wrapper-inline">
              <a-button @click="handleAddExpression" block dashed>
                <plus-outlined />
                或条件
              </a-button>
            </div>
          </div>

          <!-- 查询数据按钮和结果 - 手动上传录音时不显示，抽检模式下隐藏 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload' && createTaskForm.qualityScope === 'full'" class="query-section">
            <a-button type="link" @click="handleQueryData">
              <search-outlined />
              查询数据
            </a-button>
            <span v-if="queryResult !== null" class="query-result">
              符合条件的数据共 <strong>{{ queryResult }}</strong> 条
            </span>
          </div>

          <!-- 自动追加开关 - 手动上传录音时不显示，抽检模式下隐藏 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload' && createTaskForm.qualityScope === 'full'" class="auto-append-section">
            <div class="switch-row">
              <span class="switch-label">新产生的数据自动追加</span>
              <a-switch v-model:checked="createTaskForm.autoAppend" class="auto-append-switch" />
            </div>
            <div class="switch-tip">
              外呼产生新话单时，若符合上面的条件，自动将该通话加入到任务中
            </div>
          </div>

          <!-- 抽检模式配置区域 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload' && createTaskForm.qualityScope === 'sampling'" class="sampling-config-section">
            <!-- 抽检条数 -->
            <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }">
              <a-form-item label="抽检条数">
                <template #label>
                  <span class="required-label">*</span> 抽检条数
                </template>
                <a-input-number
                  v-model:value="createTaskForm.samplingCount"
                  :min="1"
                  :precision="0"
                  style="width: 200px"
                  placeholder="请输入抽检条数"
                />
              </a-form-item>
            </a-form>

            <!-- 抽检规则 -->
            <div class="sampling-rules-section">
              <div class="sampling-rules-header">
                <span class="sampling-rules-title">抽检规则</span>
                <a-button type="link" @click="handleAddSamplingRule">
                  <plus-outlined />
                  添加规则
                </a-button>
              </div>
              <a-table
                :columns="samplingRuleColumns"
                :data-source="samplingRules"
                :pagination="false"
                row-key="id"
                size="small"
                bordered
              >
                <template #bodyCell="{ column, record, index }">
                  <template v-if="column.key === 'index'">
                    {{ index + 1 }}
                  </template>
                  <template v-else-if="column.key === 'rule'">
                    <a-button type="link" size="small" @click="handleOpenSamplingRuleConfig(record)">
                      <setting-outlined />
                      配置规则
                    </a-button>
                    <span v-if="record.conditions && record.conditions.length > 0 && record.conditions[0].fieldType" class="rule-configured-tag">
                      <check-circle-outlined /> 已配置
                    </span>
                  </template>
                  <template v-else-if="column.key === 'ratio'">
                    <a-input-number
                      v-model:value="record.ratio"
                      :min="0"
                      :max="100"
                      :precision="0"
                      style="width: 80px"
                      placeholder="占比"
                      @change="handleRatioChange"
                    /> %
                  </template>
                  <template v-else-if="column.key === 'count'">
                    {{ samplingCountByRatio(record.ratio) }}
                  </template>
                  <template v-else-if="column.key === 'action'">
                    <a-button type="link" size="small" danger @click="handleDeleteSamplingRule(index)">
                      删除
                    </a-button>
                  </template>
                </template>
              </a-table>
              <div class="ratio-summary" :class="{ 'ratio-error': !isRatioValid }">
                占比合计：{{ totalRatio }}% {{ isRatioValid ? '' : '（占比必须等于100%）' }}
              </div>
            </div>

          </div>

          <!-- 去重规则 - 两种质检范围模式下都显示 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload'" class="dedup-section">
            <a-checkbox v-model:checked="createTaskForm.dedupEnabled" @change="handleDedupChange">
              启用去重规则
            </a-checkbox>
            <div v-if="createTaskForm.dedupEnabled" class="dedup-options">
              <a-radio-group v-model:value="createTaskForm.dedupType">
                <a-radio value="global">全局去重</a-radio>
                <a-radio value="model">同质检模型去重</a-radio>
              </a-radio-group>
              <div class="dedup-descriptions">
                <div class="dedup-desc-item">
                  <span class="dedup-desc-label">全局去重：</span>
                  <span class="dedup-desc-text">加入过质检任务的数据自动进行过滤</span>
                </div>
                <div class="dedup-desc-item">
                  <span class="dedup-desc-label">同质检模型去重：</span>
                  <span class="dedup-desc-text">加入过相同质检模型质检任务的数据自动进行过滤</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 抽检规则配置弹窗 -->
        <a-modal
          v-model:open="samplingRuleModalVisible"
          title="配置抽检规则"
          width="700px"
          :closable="false"
          @cancel="handleSamplingRuleCancel"
        >
          <div class="sampling-rule-modal-content">
            <div class="expression-list-inline">
              <div
                v-for="(expression, index) in currentSamplingRuleConditions"
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
                      >
                        <a-select-option value="callTime">通话时间</a-select-option>
                        <a-select-option value="callDuration">通话时长</a-select-option>
                        <a-select-option value="intent">客户意图</a-select-option>
                        <a-select-option value="agent">坐席工号</a-select-option>
                      </a-select>
                      <a-select
                        v-model:value="condition.operator"
                        style="width: 100px"
                        placeholder="操作符"
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
                      />
                      <div v-else class="between-inputs">
                        <a-input
                          v-model:value="condition.value"
                          style="width: 80px"
                          placeholder="最小值"
                        />
                        <span class="between-separator">~</span>
                        <a-input
                          v-model:value="condition.value2"
                          style="width: 80px"
                          placeholder="最大值"
                        />
                      </div>
                      <a-button
                        v-if="expression.conditions.length > 1"
                        type="text"
                        danger
                        @click="handleDeleteSamplingCondition(index, cIndex)"
                        class="delete-condition-btn"
                      >
                        <minus-circle-outlined />
                      </a-button>
                      <a-button
                        v-if="cIndex === expression.conditions.length - 1"
                        type="text"
                        @click="handleAddSamplingCondition(index)"
                        class="add-condition-btn-inline"
                      >
                        <plus-circle-outlined />
                      </a-button>
                      <span v-if="cIndex < expression.conditions.length - 1" class="condition-connector-inline">且</span>
                    </div>
                  </div>
                </div>
                <div class="expression-footer" v-if="currentSamplingRuleConditions.length > 1">
                  <a-button type="text" danger @click="handleDeleteSamplingExpression(index)">
                    <delete-outlined />
                    删除表达式
                  </a-button>
                </div>
              </div>
            </div>
            <div class="add-expression-btn-wrapper-inline">
              <a-button @click="handleAddSamplingExpression" block dashed>
                <plus-outlined />
                或条件
              </a-button>
            </div>
          </div>
          <template #footer>
            <a-space>
              <a-button @click="handleSamplingRuleCancel">取消</a-button>
              <a-button type="primary" @click="handleSamplingRuleConfirm">确定</a-button>
            </a-space>
          </template>
        </a-modal>

        <div class="modal-footer">
          <a-space>
            <a-button @click="handleCreateCancel">取消</a-button>
            <a-button v-if="createTaskStep === 1" @click="handleCreateNext">
              下一步
            </a-button>
            <a-button v-else @click="handleCreatePrev">
              上一步
            </a-button>
            <a-button v-if="createTaskStep === 2" type="primary" @click="handleCreateConfirm">
              完成
            </a-button>
          </a-space>
        </div>
      </a-modal>

      <!-- 编辑质检任务弹窗 -->
      <a-modal
        v-model:open="editTaskModalVisible"
        title="编辑质检任务"
        width="600px"
        :closable="false"
        @cancel="handleEditCancel"
      >
        <a-form
          ref="editTaskFormRef"
          :model="editTaskForm"
          :rules="editTaskFormRules"
          layout="horizontal"
          :label-col="{ span: 6 }"
          :wrapper-col="{ span: 16 }"
        >
          <a-form-item label="任务 ID">
            <span>{{ editTaskForm.taskId }}</span>
          </a-form-item>
          <a-form-item label="任务名称" name="taskName">
            <a-input
              v-model:value="editTaskForm.taskName"
              placeholder="请输入任务名称"
              :maxlength="50"
              show-count
            />
          </a-form-item>
          <a-form-item label="任务说明" name="taskDescription">
            <a-textarea
              v-model:value="editTaskForm.taskDescription"
              placeholder="请输入任务说明"
              :rows="3"
              :maxlength="200"
              show-count
            />
          </a-form-item>
          <a-form-item label="质检员" name="inspector">
            <a-select
              v-model:value="editTaskForm.inspector"
              placeholder="请选择质检员"
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

        <template #footer>
          <a-space>
            <a-button @click="handleEditCancel">取消</a-button>
            <a-button type="primary" @click="handleEditConfirm">
              保存
            </a-button>
          </a-space>
        </template>
      </a-modal>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { message, Modal } from 'ant-design-vue'
import type { FormInstance, Rule } from 'ant-design-vue/es/form'
import type { UploadFile } from 'ant-design-vue/es/upload'
import Pagination from '@/components/Pagination'
import {
  SearchOutlined,
  ReloadOutlined,
  PlusOutlined,
  UploadOutlined,
  DeleteOutlined,
  PlusCircleOutlined,
  MinusCircleOutlined,
  SettingOutlined,
  CheckCircleOutlined,
} from '@ant-design/icons-vue'

const router = useRouter()

// ============ 类型定义 ============
interface QualityTaskItem {
  taskId: number
  taskName: string
  taskDescription: string
  qualityModel: string
  qualityObject: string
  status: 'running' | 'paused' | 'completed' | 'pending'
  auditStatus: string
  auditor: string
  creator: string
  createdAt: string
  completedAt?: string
  aiProgressPercent: number
  aiCompleted: number
  aiTotal: number
}

interface SearchFormData {
  taskName: string
  taskId: string
  taskDescription: string
  taskStatus: string | undefined
  qualityObject: string | undefined
  qualityModel: string | undefined
  auditor: string | undefined
  inspector: string | undefined
}

interface CreateTaskForm {
  taskType: 'ai' | 'manual'
  taskName: string
  taskDescription: string
  qualityModel: string
  qualityObject: string
  inspector: string[]
  recordType: 'ai_assisted' | 'manual_outbound' | 'manual_upload'
  autoAppend: boolean
  qualityScope: 'full' | 'sampling'
  samplingCount: number | null
  dedupEnabled: boolean
  dedupType: 'global' | 'model'
}

interface EditTaskForm {
  taskId: number
  taskName: string
  taskDescription: string
  inspector: string
}

interface ConditionExpression {
  id: number
  conditions: ConditionItem[]
}

interface ConditionItem {
  id: number
  fieldType: string
  operator: string
  value: string
  value2?: string
}

interface SamplingRule {
  id: number
  conditions: ConditionExpression[]
  ratio: number
}

// ============ 表格列定义 ============
const columns = computed(() => {
  const baseColumns: any[] = [
    { title: '质检任务 ID', dataIndex: 'taskId', key: 'taskId', width: 110, ellipsis: true as any },
    { title: '质检任务名称', dataIndex: 'taskName', key: 'taskName', width: 200, ellipsis: true as any },
    { title: '任务说明', dataIndex: 'taskDescription', key: 'taskDescription', width: 220, ellipsis: true as any },
    { title: '质检模型', dataIndex: 'qualityModel', key: 'qualityModel', width: 150, ellipsis: true as any },
    { title: '质检对象', dataIndex: 'qualityObject', key: 'qualityObject', width: 130, ellipsis: true as any },
    { title: '任务状态', dataIndex: 'status', key: 'status', width: 110, ellipsis: true as any },
  ]

  // AI 质检任务列
  if (activeTab.value === 'ai') {
    baseColumns.push(
      { title: 'AI 质检进度', dataIndex: 'aiProgress', key: 'aiProgress', width: 220, ellipsis: true as any },
      { title: '人工审核状态', dataIndex: 'auditStatus', key: 'auditStatus', width: 110, ellipsis: true as any },
      { title: '审核员', dataIndex: 'auditor', key: 'auditor', width: 110, ellipsis: true as any },
      { title: '创建人', dataIndex: 'creator', key: 'creator', width: 110, ellipsis: true as any },
      { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt', width: 170, ellipsis: true as any },
      { title: '完成时间', dataIndex: 'completedAt', key: 'completedAt', width: 170, ellipsis: true as any }
    )
  } else {
    // 人工质检任务列
    baseColumns.push(
      { title: '人工质检进度', dataIndex: 'aiProgress', key: 'aiProgress', width: 220, ellipsis: true as any },
      { title: '人工质检状态', dataIndex: 'auditStatus', key: 'auditStatus', width: 110, ellipsis: true as any },
      { title: '质检员', dataIndex: 'auditor', key: 'auditor', width: 110, ellipsis: true as any },
      { title: '创建人', dataIndex: 'creator', key: 'creator', width: 110, ellipsis: true as any },
      { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt', width: 170, ellipsis: true as any }
    )
  }

  baseColumns.push({
    title: '操作',
    key: 'action',
    fixed: ('right' as any),
    width: activeTab.value === 'ai' ? 240 : 200,
    ellipsis: true as any
  })

  return baseColumns
})

// ============ 响应式数据 ============
const activeTab = ref<'ai' | 'manual'>('ai')
const total = ref(6)
const searchFormRef = ref<FormInstance>()

// 新建任务弹窗相关
const createTaskModalVisible = ref(false)
const createTaskStep = ref(1)
const createTaskFormRef = ref<FormInstance>()
const createTaskForm = reactive<CreateTaskForm>({
  taskType: 'ai',
  taskName: '',
  taskDescription: '',
  qualityModel: '',
  qualityObject: '',
  inspector: [],
  recordType: 'ai_assisted',
  autoAppend: false,
  qualityScope: 'full',
  samplingCount: null,
  dedupEnabled: false,
  dedupType: 'global',
})

// 编辑任务弹窗相关
const editTaskModalVisible = ref(false)
const editTaskFormRef = ref<FormInstance>()
const editTaskForm = reactive<EditTaskForm>({
  taskId: 0,
  taskName: '',
  taskDescription: '',
  inspector: '',
})

// 编辑任务表单验证规则
const editTaskFormRules: Record<string, Rule[]> = {
  taskName: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  taskDescription: [{ required: true, message: '请输入任务说明', trigger: 'blur' }],
  inspector: [{ required: true, message: '请选择质检员', trigger: 'change' }],
}

// 文件上传相关
const fileList = ref<UploadFile[]>([])

// 条件表达式相关
const conditionExpressions = ref<ConditionExpression[]>([
  {
    id: 1,
    conditions: [
      { id: 1, fieldType: '', operator: '', value: '' },
    ],
  },
])
let expressionIdCounter = 1
let conditionIdCounter = 1
const queryResult = ref<number | null>(null)

// 抽检规则相关
const samplingRules = ref<SamplingRule[]>([])
let samplingRuleIdCounter = 0
let samplingExpressionIdCounter = 0
let samplingConditionIdCounter = 0

// 抽检规则表格列定义
const samplingRuleColumns = [
  { title: '序号', key: 'index', width: 60, align: 'center' as const },
  { title: '规则', key: 'rule', width: 200 },
  { title: '占比', key: 'ratio', width: 120 },
  { title: '数量', key: 'count', width: 100 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 抽检规则配置弹窗相关
const samplingRuleModalVisible = ref(false)
const currentSamplingRuleIndex = ref(-1)
const currentSamplingRuleConditions = ref<ConditionExpression[]>([])

// 占比合计
const totalRatio = computed(() => {
  return samplingRules.value.reduce((sum, rule) => sum + (rule.ratio || 0), 0)
})

// 占比是否有效（必须等于100%）
const isRatioValid = computed(() => {
  return totalRatio.value === 100
})

// 根据占比计算数量
const samplingCountByRatio = (ratio: number) => {
  if (!createTaskForm.samplingCount || !ratio) return 0
  return Math.floor(createTaskForm.samplingCount * ratio / 100)
}

// 文件上传方法
const beforeUpload = (file: UploadFile) => {
  const isAudio = file.type?.startsWith('audio/') || file.name.endsWith('.mp3') || file.name.endsWith('.wav') || file.name.endsWith('.m4a')
  const isLt100M = (file.size ?? 0) / 1024 / 1024 < 100
  
  if (!isAudio) {
    message.error('只能上传音频文件！')
  }
  if (!isLt100M) {
    message.error('文件大小不能超过 100MB！')
  }
  
  return isAudio && isLt100M
}

const handleRemove = (file: UploadFile) => {
  const index = fileList.value.indexOf(file)
  const newFileList = fileList.value.slice(0, index)
  fileList.value = newFileList
}

const handleChange = (info: any) => {
  fileList.value = info.fileList
}

// 条件表达式相关方法
const handleAddExpression = () => {
  expressionIdCounter++
  conditionExpressions.value.push({
    id: expressionIdCounter,
    conditions: [
      { id: ++conditionIdCounter, fieldType: '', operator: '', value: '' },
    ],
  })
}

const handleDeleteExpression = (index: number) => {
  conditionExpressions.value.splice(index, 1)
}

const handleAddCondition = (expressionIndex: number) => {
  conditionIdCounter++
  conditionExpressions.value[expressionIndex].conditions.push({
    id: conditionIdCounter,
    fieldType: '',
    operator: '',
    value: '',
  })
}

const handleDeleteCondition = (expressionIndex: number, conditionIndex: number) => {
  conditionExpressions.value[expressionIndex].conditions.splice(conditionIndex, 1)
}

const handleQueryData = () => {
  console.log('查询条件:', conditionExpressions.value)
  // 模拟查询结果
  queryResult.value = Math.floor(Math.random() * 1000) + 100
  message.success('查询成功')
}

// 质检范围变化处理
const handleQualityScopeChange = () => {
  // 切换时重置相关数据
  if (createTaskForm.qualityScope === 'sampling') {
    samplingRules.value = []
    samplingRuleIdCounter = 0
  }
}

// 添加抽检规则
const handleAddSamplingRule = () => {
  samplingRuleIdCounter++
  samplingRules.value.push({
    id: samplingRuleIdCounter,
    conditions: [
      {
        id: ++samplingExpressionIdCounter,
        conditions: [
          { id: ++samplingConditionIdCounter, fieldType: '', operator: '', value: '' },
        ],
      },
    ],
    ratio: 0,
  })
}

// 删除抽检规则
const handleDeleteSamplingRule = (index: number) => {
  samplingRules.value.splice(index, 1)
}

// 打开抽检规则配置弹窗
const handleOpenSamplingRuleConfig = (record: SamplingRule) => {
  currentSamplingRuleIndex.value = samplingRules.value.findIndex(r => r.id === record.id)
  currentSamplingRuleConditions.value = JSON.parse(JSON.stringify(record.conditions))
  samplingRuleModalVisible.value = true
}

// 取消抽检规则配置
const handleSamplingRuleCancel = () => {
  samplingRuleModalVisible.value = false
  currentSamplingRuleIndex.value = -1
  currentSamplingRuleConditions.value = []
}

// 确认抽检规则配置
const handleSamplingRuleConfirm = () => {
  if (currentSamplingRuleIndex.value >= 0) {
    samplingRules.value[currentSamplingRuleIndex.value].conditions = JSON.parse(JSON.stringify(currentSamplingRuleConditions.value))
  }
  handleSamplingRuleCancel()
  message.success('规则配置已保存')
}

// 添加抽检规则条件表达式
const handleAddSamplingExpression = () => {
  samplingExpressionIdCounter++
  currentSamplingRuleConditions.value.push({
    id: samplingExpressionIdCounter,
    conditions: [
      { id: ++samplingConditionIdCounter, fieldType: '', operator: '', value: '' },
    ],
  })
}

// 删除抽检规则条件表达式
const handleDeleteSamplingExpression = (index: number) => {
  currentSamplingRuleConditions.value.splice(index, 1)
}

// 添加抽检规则条件
const handleAddSamplingCondition = (expressionIndex: number) => {
  samplingConditionIdCounter++
  currentSamplingRuleConditions.value[expressionIndex].conditions.push({
    id: samplingConditionIdCounter,
    fieldType: '',
    operator: '',
    value: '',
  })
}

// 删除抽检规则条件
const handleDeleteSamplingCondition = (expressionIndex: number, conditionIndex: number) => {
  currentSamplingRuleConditions.value[expressionIndex].conditions.splice(conditionIndex, 1)
}

// 占比变化处理
const handleRatioChange = () => {
  // 占比变化时的处理，可以在这里添加校验逻辑
}

// 去重规则变化处理
const handleDedupChange = () => {
  if (!createTaskForm.dedupEnabled) {
    createTaskForm.dedupType = 'global'
  }
}

// 质检模型选项
const qualityModelOptions = [
  { label: '合规质检', value: 'compliance' },
  { label: '营销意向', value: 'marketing' },
  { label: '投诉倾向', value: 'complaint' },
  { label: '服务质检', value: 'service' },
  { label: '销售质检', value: 'sales' },
]

// 质检对象选项
const qualityObjectOptions = [
  { label: '人工外呼录音', value: 'manual_outbound' },
  { label: '人机协同录音', value: 'ai_assisted' },
  { label: '呼入录音', value: 'inbound' },
]

// 质检员选项
const inspectorOptions = [
  { label: '张三', value: 'zhangsan' },
  { label: '李四', value: 'lisi' },
  { label: '王五', value: 'wangwu' },
  { label: '赵六', value: 'zhaoliu' },
]

// 搜索表单数据
const searchForm = reactive<SearchFormData>({
  taskName: '',
  taskId: '',
  taskDescription: '',
  taskStatus: undefined,
  qualityObject: undefined,
  qualityModel: undefined,
  auditor: undefined,
  inspector: undefined,
})

// 分页配置
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 6,
})

// 表单验证规则
const createTaskFormRules: Record<string, Rule[]> = {
  taskType: [{ required: true, message: '请选择质检类型', trigger: 'change' }],
  taskName: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  taskDescription: [{ required: true, message: '请输入任务说明', trigger: 'blur' }],
  qualityModel: [{ required: true, message: '请选择质检模型', trigger: 'change' }],
  qualityObject: [{ required: true, message: '请选择质检对象', trigger: 'change' }],
  inspector: [{ required: true, message: '请选择质检员', trigger: 'change' }],
}

// ============ 模拟数据 ============
const mockData: QualityTaskItem[] = [
  // AI 质检任务数据
  {
    taskId: 27,
    taskName: '2026 年 2 月金融产品合规质检专项',
    taskDescription: '2026 年 2 月金融产品外呼合规性检测专项任务',
    qualityModel: '合规质检',
    qualityObject: '人工外呼录音',
    status: 'paused',
    auditStatus: 'auditing',
    auditor: ['张三', '李四'],
    creator: 'hzy',
    createdAt: '2026-02-09 19:21:35',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 265,
  },
  {
    taskId: 28,
    taskName: '2026 年 2 月营销活动客户意向分析',
    taskDescription: '2026 年 2 月营销活动客户购买意向识别与分析',
    qualityModel: '营销意向',
    qualityObject: '人工外呼录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: ['李四', '王五'],
    creator: 'hzy',
    createdAt: '2026-02-09 19:30:00',
    aiProgressPercent: 25,
    aiCompleted: 50,
    aiTotal: 200,
  },
  {
    taskId: 29,
    taskName: '2026 年 2 月客服投诉专线质检',
    taskDescription: '客服投诉倾向识别与分析专项质检',
    qualityModel: '投诉倾向',
    qualityObject: '人工外呼录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: ['王五'],
    creator: 'hzy',
    createdAt: '2026-02-09 15:32:28',
    aiProgressPercent: 55,
    aiCompleted: 100,
    aiTotal: 180,
  },
  {
    taskId: 25,
    taskName: '2026 年 2 月金融产品合规质检专项',
    taskDescription: '2026 年 2 月金融产品外呼合规性检测专项任务',
    qualityModel: '合规质检',
    qualityObject: '呼入录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: ['admin', '张三'],
    creator: 'hzy',
    createdAt: '2026-02-09 19:03:27',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 293,
  },
  {
    taskId: 24,
    taskName: '2026 年 2 月营销活动客户意向分析',
    taskDescription: '2026 年 2 月营销活动客户购买意向识别与分析',
    qualityModel: '营销意向',
    qualityObject: '人工外呼录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: ['admin'],
    creator: 'hzy',
    createdAt: '2026-02-09 15:32:28',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 18,
  },
  {
    taskId: 23,
    taskName: '2026 年 2 月客服投诉专线质检',
    taskDescription: '客服投诉倾向识别与分析专项质检',
    qualityModel: '投诉倾向',
    qualityObject: '人机协同录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: ['admin'],
    creator: 'hzy',
    createdAt: '2026-02-09 15:31:02',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 106,
  },
  // 人工质检任务数据
  {
    taskId: 30,
    taskName: '2026 年 2 月金融产品合规质检专项',
    taskDescription: '2026 年 2 月金融产品外呼合规性检测专项任务（人工复检）',
    qualityModel: '合规质检（人工）',
    qualityObject: '人机协同录音',
    status: 'running',
    auditStatus: 'running',
    auditor: ['张三', '李四', '王五'],
    creator: 'hzy',
    createdAt: '2026-02-09 19:30:00',
    aiProgressPercent: 60,
    aiCompleted: 60,
    aiTotal: 100,
  },
]

// ============ 计算属性 ============
const tableData = computed(() => {
  let filtered = [...mockData]

  // 根据当前标签页过滤数据
  if (activeTab.value === 'ai') {
    filtered = filtered.filter(item => item.taskId >= 18) // AI 质检任务
  } else {
    filtered = filtered.filter(item => item.taskId === 30) // 人工质检任务
  }

  if (searchForm.taskName) {
    filtered = filtered.filter(item =>
      item.taskName.toLowerCase().includes(searchForm.taskName.toLowerCase())
    )
  }

  if (searchForm.taskId) {
    filtered = filtered.filter(item =>
      item.taskId.toString().includes(searchForm.taskId)
    )
  }

  if (searchForm.taskDescription) {
    filtered = filtered.filter(item =>
      item.taskDescription.toLowerCase().includes(searchForm.taskDescription.toLowerCase())
    )
  }

  if (searchForm.taskStatus) {
    filtered = filtered.filter(item => item.status === searchForm.taskStatus)
  }

  if (searchForm.qualityObject) {
    filtered = filtered.filter(item => item.qualityObject === searchForm.qualityObject)
  }

  if (searchForm.qualityModel) {
    filtered = filtered.filter(item => item.qualityModel === searchForm.qualityModel)
  }

  if (searchForm.auditStatus && activeTab.value === 'ai') {
    filtered = filtered.filter(item => item.auditStatus === searchForm.auditStatus)
  }

  if (searchForm.inspector && activeTab.value === 'manual') {
    filtered = filtered.filter(item => item.creator === searchForm.inspector)
  }

  return filtered
})

// ============ 方法 ============

// 获取质检模型标签
const getQualityModelLabel = (value: string) => {
  const option = qualityModelOptions.find(opt => opt.value === value)
  return option ? option.label : ''
}

// 获取质检对象标签
const getQualityObjectLabel = (value: string) => {
  const option = qualityObjectOptions.find(opt => opt.value === value)
  return option ? option.label : ''
}

// 获取质检员标签
const getInspectorLabel = (value: string) => {
  const option = inspectorOptions.find(opt => opt.value === value)
  return option ? option.label : ''
}

const handleTabChange = (tab: string) => {
  console.log('切换标签页:', tab)
}

const handleSearch = () => {
  console.log('执行搜索:', searchForm)
  message.success('搜索成功')
}

const handleReset = () => {
  if (searchFormRef.value) {
    searchFormRef.value.resetFields()
  }
  Object.assign(searchForm, {
    taskName: '',
    taskId: '',
    taskDescription: '',
    taskStatus: undefined,
    qualityObject: undefined,
    qualityModel: undefined,
    auditor: undefined,
    inspector: undefined,
  })
  message.success('已重置搜索条件')
}

const handleCreateTask = () => {
  createTaskModalVisible.value = true
  createTaskStep.value = 1
}

// 下一步
const handleCreateNext = async () => {
  if (!createTaskFormRef.value) return
  
  try {
    await createTaskFormRef.value.validate()
    createTaskStep.value = 2
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

// 上一步
const handleCreatePrev = () => {
  createTaskStep.value = 1
}

// 取消创建
const handleCreateCancel = () => {
  createTaskModalVisible.value = false
  createTaskStep.value = 1
  if (createTaskFormRef.value) {
    createTaskFormRef.value.resetFields()
  }
  Object.assign(createTaskForm, {
    taskType: 'ai',
    taskName: '',
    taskDescription: '',
    qualityModel: '',
    qualityObject: '',
    inspector: [],
    recordType: 'ai_assisted',
    autoAppend: false,
    qualityScope: 'full',
    samplingCount: null,
    dedupEnabled: false,
    dedupType: 'global',
  })
  fileList.value = []
  // 重置条件表达式
  conditionExpressions.value = [
    {
      id: 1,
      conditions: [
        { id: 1, fieldType: '', operator: '', value: '' },
      ],
    },
  ]
  expressionIdCounter = 1
  conditionIdCounter = 1
  queryResult.value = null
  // 重置抽检规则
  samplingRules.value = []
  samplingRuleIdCounter = 0
  samplingExpressionIdCounter = 0
  samplingConditionIdCounter = 0
}

// 确认创建
const handleCreateConfirm = () => {
  // 抽检模式校验
  if (createTaskForm.qualityScope === 'sampling') {
    // 校验抽检条数
    if (!createTaskForm.samplingCount || createTaskForm.samplingCount <= 0) {
      message.error('请输入有效的抽检条数')
      return
    }

    // 校验是否有抽检规则
    if (samplingRules.value.length === 0) {
      message.error('请至少添加一条抽检规则')
      return
    }

    // 校验占比是否等于100%
    if (!isRatioValid.value) {
      message.error('抽检规则占比合计必须等于100%')
      return
    }

    // 校验每条规则是否已配置
    const unconfiguredRule = samplingRules.value.find(
      rule => !rule.conditions || rule.conditions.length === 0 || !rule.conditions[0].conditions[0].fieldType
    )
    if (unconfiguredRule) {
      message.error('请配置所有抽检规则的条件表达式')
      return
    }

    // 模拟检查满足条件的质检数据是否达到抽检规则要求的数量
    checkSamplingDataAvailable()
  } else {
    // 全量质检模式直接创建
    console.log('创建任务:', createTaskForm)
    message.success('创建成功')
    handleCreateCancel()
  }
}

// 检查抽检数据是否满足要求
const checkSamplingDataAvailable = () => {
  // 模拟：随机生成可用数据量（实际应调用后端接口查询）
  const availableDataCount = Math.floor(Math.random() * 500) + 50

  // 计算各规则需要的数量
  const ruleRequirements = samplingRules.value.map((rule, index) => ({
    index: index + 1,
    ratio: rule.ratio,
    requiredCount: samplingCountByRatio(rule.ratio),
  }))

  const totalRequired = createTaskForm.samplingCount || 0

  if (availableDataCount < totalRequired) {
    // 数据不足，弹窗提示
    const ruleDetails = ruleRequirements.map(r =>
      `规则${r.index}：需要${r.requiredCount}条（占比${r.ratio}%）`
    ).join('\n')

    Modal.confirm({
      title: '质检数据不足',
      content: `当前满足条件的质检数据共 ${availableDataCount} 条，但抽检规则要求共 ${totalRequired} 条，数据不足无法完成抽检任务。\n\n各规则需求：\n${ruleDetails}\n\n是否继续创建任务？`,
      okText: '继续创建',
      cancelText: '取消',
      onOk() {
        console.log('创建任务:', createTaskForm)
        message.success('创建成功')
        handleCreateCancel()
      },
    })
  } else {
    // 数据充足，直接创建
    console.log('创建任务:', createTaskForm)
    message.success('创建成功')
    handleCreateCancel()
  }
}

const handleDetail = (row: QualityTaskItem) => {
  // 跳转到质检任务详情页面，传递任务类型参数（ai 或 manual）
  const taskType = activeTab.value === 'manual' ? 'manual' : 'ai'
  router.push(`/quality-task-detail/${row.taskId}?taskType=${taskType}`)
}

const handleEdit = (row: QualityTaskItem) => {
  editTaskForm.taskId = row.taskId
  editTaskForm.taskName = row.taskName
  editTaskForm.taskDescription = row.taskDescription
  editTaskForm.inspector = row.auditor || row.creator
  editTaskModalVisible.value = true
}

// 取消编辑
const handleEditCancel = () => {
  editTaskModalVisible.value = false
  if (editTaskFormRef.value) {
    editTaskFormRef.value.resetFields()
  }
  Object.assign(editTaskForm, {
    taskId: 0,
    taskName: '',
    taskDescription: '',
    inspector: '',
  })
}

// 确认编辑
const handleEditConfirm = async () => {
  if (!editTaskFormRef.value) return
  
  try {
    await editTaskFormRef.value.validate()
    console.log('编辑任务:', editTaskForm)
    message.success('保存成功')
    handleEditCancel()
  } catch (error) {
    console.error('表单验证失败:', error)
  }
}

const handleToggleStatus = (row: QualityTaskItem) => {
  const action = row.status === 'running' ? '暂停' : '开启'
  
  Modal.confirm({
    title: `${action}任务确认`,
    content: `确定要${action}质检任务 "${row.taskName}" 吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      // 在 mockData 中找到对应的任务并更新状态
      const index = mockData.findIndex(item => item.taskId === row.taskId)
      if (index !== -1) {
        const newStatus = row.status === 'running' ? 'paused' : 'running'
        mockData[index].status = newStatus
        message.success(`已${action}任务`)
      }
    },
  })
}

const handleDelete = (row: QualityTaskItem) => {
  Modal.confirm({
    title: '删除确认',
    content: `确定要删除质检任务 "${row.taskName}" 吗？`,
    okText: '确定',
    cancelText: '取消',
    onOk() {
      message.success('删除成功')
    },
  })
}

// 分页变化
const handlePageChange = (page: number, size: number) => {
  pagination.currentPage = page
  pagination.pageSize = size
  console.log('分页变化:', page, size)
}
</script>

<style scoped>
/* 质检任务内容区域 */
.quality-inspection-task {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.quality-wrapper {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* 页面标题区域 */
.quality-header-section {
  background: #fff;
  border-radius: 4px;
  padding: 16px 24px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.quality-header {
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

/* 新建质检任务按钮 */
.create-task-btn {
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

.create-task-btn .anticon {
  font-size: 14px;
}

.create-task-btn:hover {
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

/* 标签页区域 */
.tabs-section {
  margin-bottom: 16px;
}

.tabs-section :deep(.ant-tabs__header) {
  margin-bottom: 0;
  border-bottom: 1px solid #f0f0f0;
}

/* 搜索区域 */
.search-area {
  padding: 0 0 16px 0;
  margin-bottom: 16px;
}

.search-area :deep(.ant-form-item) {
  margin-bottom: 12px;
}

/* 输入框样式 */
.search-area :deep(.ant-input) {
  font-size: 14px;
  color: #262626;
}

.search-area :deep(.ant-input::placeholder) {
  color: #bfbfbf;
  font-size: 14px;
}

/* 选择框样式 */
.search-area :deep(.ant-select) {
  width: 100%;
}

.search-area :deep(.ant-select-selector) {
  font-size: 14px;
  color: #262626;
}

/* 选择框 placeholder 样式 - 使用多重选择器确保生效 */
.search-area :deep(.ant-select-selection-placeholder) {
  color: #bfbfbf !important;
  font-size: 14px !important;
  opacity: 1 !important;
  visibility: visible !important;
}

/* 搜索按钮间距 */
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

/* 表格工具栏 */
.table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.table-toolbar-left,
.table-toolbar-right {
  display: flex;
  align-items: center;
}

.selection-info {
  font-size: 14px;
  color: #595959;
}

/* 表格包装器 */
.table-wrapper {
  flex: 1;
  overflow: auto;
}

/* 表格样式 */
.table-wrapper :deep(.ant-table) {
  font-size: 14px;
}

/* 表头样式 */
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

/* 表格行 */
.table-wrapper :deep(.ant-table-tbody > tr:hover > td) {
  background-color: #f0f5ff;
}

/* 移除表格边框 */
.table-wrapper :deep(.ant-table) {
  border: none;
}

/* 进度单元格 */
.progress-cell {
  display: flex;
  align-items: center;
  gap: 12px;
  height: 100%;
}

.progress-bar {
  flex: 0 0 120px;
}

.progress-text {
  font-size: 14px;
  color: #262626;
  white-space: nowrap;
}

/* 移除标签动画效果 */
.table-wrapper :deep(.ant-tag) {
  transition: none !important;
  animation: none !important;
}

/* 操作列按钮样式 */
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

/* 操作列间距 */
.table-wrapper :deep(.ant-space) {
  gap: 8px !important;
  display: flex !important;
  align-items: center;
}

/* 操作列单元格垂直居中 */
.table-wrapper :deep(.ant-table-tbody > tr > td:last-child) {
  vertical-align: middle;
}

/* 分页容器 */
.pagination-container {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 16px;
  padding-top: 16px;
}

/* 弹窗步骤条 */
.modal-steps {
  margin-top: 24px;
  margin-bottom: 16px;
}

.modal-steps :deep(.ant-steps-item) {
  padding: 0;
}

/* 步骤表单 */
.step-form {
  padding: 20px 40px;
}

.step-form :deep(.ant-form-item) {
  margin-bottom: 20px;
}

.step-form :deep(.ant-form-item-label) {
  text-align: right;
}

.step-form :deep(.ant-form-item-label > label) {
  height: 32px;
  line-height: 32px;
}

/* 新建任务弹窗步骤 2 样式 */
.step-2-content {
  padding: 10px 40px;
}

.step-2-content :deep(.ant-form-item) {
  margin-bottom: 20px;
}

.step-2-content :deep(.ant-radio-group) {
  display: flex;
  gap: 24px;
}

.step-2-content :deep(.ant-radio) {
  margin-right: 0;
  font-size: 14px;
}

/* 必填标签样式 */
.required-label {
  color: #ff4d4f;
  margin-right: 4px;
}

/* 上传文件区域 */
.upload-section {
  margin: 20px 0;
  padding: 24px;
  background: #fafafa;
  border-radius: 4px;
  text-align: center;
}

.upload-section :deep(.ant-upload) {
  margin-bottom: 12px;
}

.upload-section :deep(.ant-btn) {
  height: 40px;
  padding: 0 24px;
}

.upload-tip {
  margin: 8px 0 0;
  font-size: 13px;
  color: #8c8c8c;
}

/* 条件筛选区域 */
.condition-area {
  background: #f0f5ff;
  border-radius: 4px;
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 24px;
  overflow: hidden;
}

.expression-list-inline {
  display: flex;
  flex-direction: column;
  gap: 16px;
  width: 100%;
}

.expression-item-inline {
  display: flex;
  flex-direction: column;
  gap: 8px;
  position: relative;
}

.expression-item-inline:not(:first-child)::before {
  content: '';
  position: absolute;
  top: -8px;
  left: 0;
  right: 0;
  border-top: 1px dashed #1677ff;
}

.expression-content {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  width: 100%;
}

.condition-list-inline {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
}

.condition-item-inline {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
}

.condition-connector-inline {
  color: #1677ff;
  font-size: 13px;
  font-weight: 600;
  flex-shrink: 0;
}

/* 介于输入框 */
.between-inputs {
  display: flex;
  align-items: center;
  gap: 4px;
}

.between-separator {
  color: #8c8c8c;
  font-size: 14px;
}

.delete-condition-btn,
.add-condition-btn-inline {
  color: #ff4d4f;
  font-size: 18px;
  flex-shrink: 0;
}

.delete-condition-btn:hover,
.add-condition-btn-inline:hover {
  color: #ff7875;
}

.add-condition-btn-inline {
  color: #1677ff;
}

.add-condition-btn-inline:hover {
  color: #4096ff;
}

.expression-footer {
  display: flex;
  justify-content: flex-end;
  padding-top: 4px;
}

.expression-footer :deep(.ant-btn) {
  color: #ff4d4f;
  font-size: 13px;
}

.expression-footer :deep(.ant-btn:hover) {
  color: #ff7875;
}

.add-expression-btn-wrapper-inline {
  margin-top: 4px;
}

/* 查询数据区域 */
.query-section {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
}

.query-section :deep(.ant-btn) {
  font-size: 14px;
  height: auto;
  padding: 4px 8px;
  color: #1677ff;
}

.query-section :deep(.ant-btn:hover) {
  color: #4096ff;
}

.query-result {
  font-size: 14px;
  color: #262626;
}

.query-result strong {
  color: #1677ff;
  font-weight: 600;
}

/* 提示文字 */
.data-range-tip {
  text-align: center;
  color: #8c8c8c;
  font-size: 14px;
  margin: 24px 0;
}

/* 条件筛选区域 */
.condition-area {
  background: #f0f5ff;
  border-radius: 4px;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  min-height: 60px;
}

.add-condition-btn :deep(.ant-btn) {
  font-size: 14px;
  padding: 4px 8px;
}

.add-condition-btn :deep(.anticon) {
  margin-right: 4px;
}

.query-btn :deep(.ant-btn) {
  font-size: 14px;
}

/* 自动追加开关区域 */
.auto-append-section {
  margin-top: 16px;
}

.switch-row {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.switch-label {
  font-size: 14px;
  color: #262626;
  margin-right: 12px;
}

.auto-append-switch {
  margin-left: 8px;
}

.switch-tip {
  font-size: 13px;
  color: #8c8c8c;
  line-height: 1.5;
}

/* 弹窗底部 */
.modal-footer {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

/* 质检范围选择区域 */
.quality-scope-section {
  margin-bottom: 16px;
}

/* 抽检模式配置区域 */
.sampling-config-section {
  background: #f0f5ff;
  border-radius: 4px;
  padding: 16px 24px;
  margin-bottom: 16px;
}

/* 抽检规则区域 */
.sampling-rules-section {
  margin-bottom: 16px;
}

.sampling-rules-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.sampling-rules-title {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
}

.sampling-rules-section :deep(.ant-table) {
  font-size: 14px;
}

.sampling-rules-section :deep(.ant-table-thead > tr > th) {
  background: #e6f4ff;
  font-weight: 600;
  color: #262626;
}

.rule-configured-tag {
  margin-left: 8px;
  color: #52c41a;
  font-size: 12px;
}

/* 占比合计 */
.ratio-summary {
  margin-top: 12px;
  padding: 8px 12px;
  background: #fff;
  border-radius: 4px;
  font-size: 14px;
  color: #262626;
  text-align: right;
}

.ratio-summary.ratio-error {
  color: #ff4d4f;
  background: #fff2f0;
}

/* 去重规则区域 */
.dedup-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px dashed #d9d9d9;
  background: #fafafa;
  border-radius: 4px;
  padding: 16px 24px;
}

.dedup-options {
  margin-top: 12px;
  padding-left: 24px;
}

.dedup-descriptions {
  margin-top: 12px;
  padding: 12px 16px;
  background: #fff;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
}

.dedup-desc-item {
  display: flex;
  align-items: baseline;
  margin-bottom: 8px;
  font-size: 13px;
  line-height: 1.6;
}

.dedup-desc-item:last-child {
  margin-bottom: 0;
}

.dedup-desc-label {
  color: #262626;
  font-weight: 500;
  white-space: nowrap;
}

.dedup-desc-text {
  color: #8c8c8c;
}

/* 抽检规则配置弹窗 */
.sampling-rule-modal-content {
  padding: 16px 0;
}

/* 质检员多选提示 */
.inspector-tip {
  margin-top: 8px;
  color: #1677ff;
  font-size: 13px;
  background: #e6f4ff;
  padding: 6px 12px;
  border-radius: 4px;
}

/* 审核员标签 */
.auditor-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.auditor-tags .ant-tag {
  margin-right: 0;
}
</style>
