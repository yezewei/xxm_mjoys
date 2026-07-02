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
            <a-space>
              <a-button type="primary" class="create-task-btn" @click="handleCreateTask">
                <plus-outlined />
                新建质检任务
              </a-button>
            </a-space>
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
              <a-col :span="6">
                <a-form-item>
                  <a-input
                    v-model:value="searchForm.keyword"
                    placeholder="请输入任务名称/ID/说明"
                    allow-clear
                    @press-enter="handleSearch"
                  >
                    <template #prefix>
                      <search-outlined />
                    </template>
                  </a-input>
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
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.qualityScope"
                    placeholder="请选择质检范围"
                    allow-clear
                  >
                    <a-select-option value="full">全量质检</a-select-option>
                    <a-select-option value="sampling">部分抽检</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
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
            </a-row>
            <a-row :gutter="[16, 0]">
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
              <a-col :span="6">
                <a-form-item>
                  <a-select
                    v-model:value="searchForm.autoAppend"
                    placeholder="请选择数据追加"
                    allow-clear
                  >
                    <a-select-option value="true">开启</a-select-option>
                    <a-select-option value="false">关闭</a-select-option>
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
        width="900px"
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
        <div v-else-if="createTaskStep === 2" class="step-2-content">
          <div class="data-range-tip">
            请选择需要质检的已接通通话范围
          </div>
          <div class="section-box">
            <!-- 录音类型选择 -->
            <div class="record-type-section">
              <div
                class="record-type-card"
                :class="{ active: createTaskForm.recordType === 'ai_assisted' }"
                @click="createTaskForm.recordType = 'ai_assisted'"
              >
                人机协同录音
                <check-circle-filled v-if="createTaskForm.recordType === 'ai_assisted'" class="record-type-check" />
              </div>
              <div
                class="record-type-card"
                :class="{ active: createTaskForm.recordType === 'manual_outbound' }"
                @click="createTaskForm.recordType = 'manual_outbound'"
              >
                人工外呼录音
                <check-circle-filled v-if="createTaskForm.recordType === 'manual_outbound'" class="record-type-check" />
              </div>
              <div
                class="record-type-card"
                :class="{ active: createTaskForm.recordType === 'manual_upload' }"
                @click="createTaskForm.recordType = 'manual_upload'"
              >
                手动上传录音
                <check-circle-filled v-if="createTaskForm.recordType === 'manual_upload'" class="record-type-check" />
              </div>
            </div>

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

            <!-- 条件筛选区域 - 手动上传录音时不显示 -->
            <template v-if="createTaskForm.recordType !== 'manual_upload'">
              <div class="condition-area">
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

              <!-- 自动追加新数据 -->
              <div class="auto-append-section">
                <div class="auto-append-header">
                  <div class="auto-append-label">自动追加新数据</div>
                  <a-switch v-model:checked="createTaskForm.autoAppend" />
                </div>
                <div v-if="createTaskForm.autoAppend" class="auto-append-content">
                  <div class="auto-append-tip">
                    开启后，系统将按照配置的时间规则自动查询并追加符合条件的新数据到质检任务中
                  </div>
                  <div class="auto-append-sentence">
                    每天
                    <a-time-picker v-model:value="createTaskForm.autoAppendExecTime" format="HH:mm" :placeholder="'执行时间'" style="width: 100px" />
                    点查询
                    <a-select v-model:value="createTaskForm.autoAppendStartType" style="width: 70px">
                      <a-select-option value="today">当天</a-select-option>
                      <a-select-option value="yesterday">昨天</a-select-option>
                    </a-select>
                    <a-time-picker v-model:value="createTaskForm.autoAppendRangeStart" format="HH:mm" :placeholder="'开始时间'" style="width: 100px" />
                    ~
                    <a-select v-model:value="createTaskForm.autoAppendEndType" style="width: 70px">
                      <a-select-option value="today">当天</a-select-option>
                      <a-select-option value="yesterday">昨天</a-select-option>
                    </a-select>
                    <a-time-picker v-model:value="createTaskForm.autoAppendRangeEnd" format="HH:mm" :placeholder="'结束时间'" style="width: 100px" />
                    时间段内满足条件的数据加入质检任务
                  </div>
                </div>
              </div>

              <!-- 数据去重 - 暂时隐藏 -->
              <!-- <div class="dedup-section">
                <div class="dedup-header">
                  <div class="dedup-label">数据去重</div>
                  <a-switch v-model:checked="createTaskForm.dedupEnabled" />
                </div>
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
              </div> -->
            </template>
          </div>

          <!-- 质检范围选择 - 手动上传录音时不显示 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload'" class="quality-scope-section">
            <div class="quality-scope-cards">
              <div
                class="scope-card"
                :class="{ active: createTaskForm.qualityScope === 'full' }"
                @click="createTaskForm.qualityScope = 'full'; handleQualityScopeChange()"
              >
                <div class="scope-card-info">
                  <div class="scope-card-title">全量质检</div>
                  <div class="scope-card-desc">对符合条件的全部数据进行质检</div>
                </div>
                <check-circle-filled v-if="createTaskForm.qualityScope === 'full'" class="scope-card-check" />
              </div>
              <div
                class="scope-card"
                :class="{ active: createTaskForm.qualityScope === 'sampling' }"
                @click="createTaskForm.qualityScope = 'sampling'; handleQualityScopeChange()"
              >
                <div class="scope-card-info">
                  <div class="scope-card-title">部分抽检</div>
                  <div class="scope-card-desc">按规则抽样部分数据进行质检</div>
                </div>
                <check-circle-filled v-if="createTaskForm.qualityScope === 'sampling'" class="scope-card-check" />
              </div>
            </div>
          </div>

          <!-- 质检数量 -->
          <div v-if="createTaskForm.recordType !== 'manual_upload'" class="quality-count-section">
            <div class="quality-count-label">质检数量</div>

            <!-- 全量质检 - 自动查询 -->
            <div v-if="createTaskForm.qualityScope === 'full'" class="quality-count-content">
              <a-button type="link" @click="handleQueryData" :loading="queryLoading">
                <search-outlined />
                查询数据
              </a-button>
              <span v-if="queryResult !== null" class="query-result">
                已查询到 <strong>{{ queryResult }}</strong> 条数据
              </span>
            </div>

            <!-- 部分抽检 - 采样数量配置 -->
            <div v-if="createTaskForm.qualityScope === 'sampling'" class="quality-count-content">
              <div class="sampling-query-row">
                <a-button type="link" @click="handleQueryData" :loading="queryLoading">
                  <search-outlined />
                  查询数据
                </a-button>
                <span v-if="queryResult !== null" class="query-result">
                  符合条件 <strong>{{ queryResult }}</strong> 条数据
                </span>
              </div>
              <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }" class="step-form">
                <a-form-item label="采样数量">
                  <template #label>
                    <span class="required-label">*</span> 采样数量
                  </template>
                  <a-radio-group v-model:value="createTaskForm.allocationMethod">
                    <a-radio value="total">按总数</a-radio>
                    <a-radio value="ratio">按比例</a-radio>
                    <a-radio value="perPerson">人均数量</a-radio>
                  </a-radio-group>
                </a-form-item>

                <a-form-item v-if="createTaskForm.allocationMethod === 'total'" label="取数总数量">
                  <a-input-number v-model:value="createTaskForm.allocationValue" :min="1" :precision="0" style="width: 200px" placeholder="请输入总数量" />
                  <span class="quota-unit">条</span>
                  <div class="quota-tip">从符合条件的数据中抽取固定数量的录音作为抽检样本</div>
                </a-form-item>

                <a-form-item v-else-if="createTaskForm.allocationMethod === 'ratio'" label="抽取百分比">
                  <a-input-number v-model:value="createTaskForm.allocationValue" :min="1" :max="100" :precision="0" style="width: 200px" placeholder="请输入百分比" />
                  <span class="quota-unit">%</span>
                  <div class="quota-tip">按符合条件的数据总量的百分比抽取，实际数量随数据量浮动</div>
                  <div v-if="queryResult !== null && createTaskForm.allocationValue" class="quota-calc">
                    预计抽检 <strong>{{ Math.floor(queryResult * createTaskForm.allocationValue / 100) }}</strong> 条
                  </div>
                </a-form-item>

                <a-form-item v-else label="每人分配数量">
                  <a-input-number v-model:value="createTaskForm.allocationValue" :min="1" :precision="0" style="width: 200px" placeholder="请输入每人数量" />
                  <span class="quota-unit">条/人</span>
                  <div class="quota-tip">每位质检员分配固定数量的录音，总抽检量 = 每人数量 × 质检员人数</div>
                  <div v-if="createTaskForm.allocationValue && createTaskForm.inspector?.length" class="quota-calc">
                    预计抽检 <strong>{{ createTaskForm.allocationValue * createTaskForm.inspector.length }}</strong> 条
                  </div>
                </a-form-item>
              </a-form>
            </div>
          </div>

          <!-- 部分抽检 - 抽样方式 - 手动上传录音时不显示 -->
          <template v-if="createTaskForm.recordType !== 'manual_upload' && createTaskForm.qualityScope === 'sampling'">
            <div class="sampling-method-section">
              <div class="sampling-method-label">抽样方式</div>

            <a-form layout="horizontal" :label-col="{ span: 4 }" :wrapper-col="{ span: 18 }">
              <a-form-item label="采样方式">
                <template #label>
                  <span class="required-label">*</span> 采样方式
                </template>
                <a-radio-group v-model:value="createTaskForm.samplingMethod">
                  <a-radio value="average">平均采样</a-radio>
                  <a-radio value="ratio">按比例采样</a-radio>
                </a-radio-group>
              </a-form-item>
            </a-form>

            <!-- 平均采样 -->
            <div v-if="createTaskForm.samplingMethod === 'average'" class="sampling-option-area">
              <a-alert
                message="系统默认会对每个场景、每个坐席的数据中平均抽样"
                type="info"
                show-icon
                class="sampling-tip-alert"
              />
            </div>

            <!-- 按比例采样 -->
            <div v-else-if="createTaskForm.samplingMethod === 'ratio'" class="sampling-option-area">
              <div class="ratio-sampling-config">
                <div class="dimension-section">
                  <div class="dimension-label">采样维度</div>
                  <a-select
                    v-model:value="createTaskForm.samplingDimension"
                    style="width: 200px"
                    placeholder="选择维度"
                  >
                    <a-select-option value="scene">按场景</a-select-option>
                    <a-select-option value="agent">按坐席</a-select-option>
                    <a-select-option value="callDuration">按通话时长</a-select-option>
                  </a-select>
                </div>

                <!-- 总抽检数量提示 -->
                <div v-if="totalSamplingCount > 0" class="total-sampling-count-tip">
                  总抽检数量：<strong>{{ totalSamplingCount }}</strong> 条
                </div>

                <a-alert
                  v-if="createTaskForm.samplingDimension === 'scene'"
                  message="各场景被抽中的录音数量符合预先设定的比例，且每个坐席被抽中的录音数量尽可能相等"
                  type="info"
                  show-icon
                  class="dimension-tip-alert"
                />
                <a-alert
                  v-else-if="createTaskForm.samplingDimension === 'agent'"
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
                <div v-if="createTaskForm.samplingDimension === 'scene'" class="dimension-table-area">
                  <a-table
                    :columns="sceneColumns"
                    :data-source="samplingSceneItems"
                    :pagination="false"
                    size="small"
                    bordered
                    class="dimension-table"
                  >
                    <template #bodyCell="{ column, record: item, index: itemIndex }">
                      <template v-if="column.key === 'group'">
                        组{{ itemIndex + 1 }}
                      </template>
                      <template v-else-if="column.key === 'sceneName'">
                        <a-select
                          v-model:value="item.sceneName"
                          placeholder="请选择场景"
                          size="small"
                          style="width: 100%"
                          show-search
                          :filter-option="(input: string, option: any) => option.label.toLowerCase().includes(input.toLowerCase())"
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
                        <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" /> %
                      </template>
                      <template v-else-if="column.key === 'samplingCount'">
                        <span class="sampling-count-value">{{ samplingCountByRatio(item.ratio || 0) }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-button type="link" size="small" danger @click="handleDeleteSamplingSceneItem(itemIndex)">删除</a-button>
                      </template>
                    </template>
                  </a-table>
                  <div class="dimension-table-footer">
                    <a-button type="link" size="small" @click="handleAddSamplingSceneItem">
                      <plus-outlined /> 添加场景
                    </a-button>
                    <span class="ratio-total" :class="{ 'ratio-error': samplingSceneRatioTotal > 100 }">
                      合计：{{ samplingSceneRatioTotal }}%
                    </span>
                  </div>
                </div>

                <!-- 按坐席 -->
                <div v-else-if="createTaskForm.samplingDimension === 'agent'" class="dimension-table-area">
                  <a-table
                    :columns="agentColumns"
                    :data-source="samplingAgentItems"
                    :pagination="false"
                    size="small"
                    bordered
                    class="dimension-table"
                  >
                    <template #bodyCell="{ column, record: item, index: itemIndex }">
                      <template v-if="column.key === 'group'">
                        组{{ itemIndex + 1 }}
                      </template>
                      <template v-else-if="column.key === 'agentId'">
                        <a-select
                          v-model:value="item.agentId"
                          placeholder="请选择坐席"
                          size="small"
                          style="width: 100%"
                          show-search
                          :filter-option="(input: string, option: any) => option.label.toLowerCase().includes(input.toLowerCase())"
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
                        <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" /> %
                      </template>
                      <template v-else-if="column.key === 'samplingCount'">
                        <span class="sampling-count-value">{{ samplingCountByRatio(item.ratio || 0) }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-button type="link" size="small" danger @click="handleDeleteSamplingAgentItem(itemIndex)">删除</a-button>
                      </template>
                    </template>
                  </a-table>
                  <div class="dimension-table-footer">
                    <a-button type="link" size="small" @click="handleAddSamplingAgentItem">
                      <plus-outlined /> 添加坐席
                    </a-button>
                    <span class="ratio-total" :class="{ 'ratio-error': samplingAgentRatioTotal > 100 }">
                      合计：{{ samplingAgentRatioTotal }}%
                    </span>
                  </div>
                </div>

                <!-- 按通话时长 -->
                <div v-else-if="createTaskForm.samplingDimension === 'callDuration'" class="dimension-table-area">
                  <a-table
                    :columns="durationColumns"
                    :data-source="samplingDurationItems"
                    :pagination="false"
                    size="small"
                    bordered
                    class="dimension-table"
                  >
                    <template #bodyCell="{ column, record: item, index: itemIndex }">
                      <template v-if="column.key === 'group'">
                        组{{ itemIndex + 1 }}
                      </template>
                      <template v-else-if="column.key === 'range'">
                        <a-input-number v-model:value="item.minDuration" :min="0" :precision="0" size="small" style="width: 80px" placeholder="秒" />
                        <span class="range-separator">~</span>
                        <a-input-number v-model:value="item.maxDuration" :min="0" :precision="0" size="small" style="width: 80px" placeholder="秒" />
                        <span class="range-unit">秒</span>
                      </template>
                      <template v-else-if="column.key === 'ratio'">
                        <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" /> %
                      </template>
                      <template v-else-if="column.key === 'samplingCount'">
                        <span class="sampling-count-value">{{ samplingCountByRatio(item.ratio || 0) }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-button type="link" size="small" danger @click="handleDeleteSamplingDurationItem(itemIndex)">删除</a-button>
                      </template>
                    </template>
                  </a-table>
                  <div class="dimension-table-footer">
                    <a-button type="link" size="small" @click="handleAddSamplingDurationItem">
                      <plus-outlined /> 添加区间
                    </a-button>
                    <span class="ratio-total" :class="{ 'ratio-error': samplingDurationRatioTotal > 100 }">
                      合计：{{ samplingDurationRatioTotal }}%
                    </span>
                  </div>
                </div>
              </div>
            </div>
            </div>
          </template>
        </div>

        <div class="modal-footer">
          <a-space>
            <a-button @click="handleCreateCancel">取消</a-button>
            <a-button
              v-if="createTaskStep > 1"
              @click="handleCreatePrev"
            >
              上一步
            </a-button>
            <a-button
              v-if="isLastStep"
              type="primary"
              @click="handleCreateConfirm"
            >
              完成
            </a-button>
            <a-button
              v-else
              type="primary"
              @click="handleCreateNext"
            >
              下一步
            </a-button>
          </a-space>
        </div>
      </a-modal>

      <!-- 新建抽检规则弹窗 -->
      <a-modal
        v-model:open="samplingRuleModalVisible"
        title="新建抽检规则"
        width="900px"
        :closable="false"
        :footer="null"
        @cancel="handleSamplingRuleCancel"
      >
        <!-- 步骤条 -->
        <a-steps :current="samplingRuleStep - 1" class="modal-steps">
          <a-step title="数据范围" />
          <a-step title="抽样维度" />
          <a-step title="配额上限" />
          <a-step title="调度计划" />
          <a-step title="命名保存" />
        </a-steps>

        <!-- 步骤 1：选择数据范围 -->
        <div v-if="samplingRuleStep === 1" class="step-sampling-content">
          <div class="step-section-title">选择数据范围</div>
          <div class="step-section-desc">确定本次抽检的数据源，支持叠加筛选条件</div>
          <div class="data-range-filters">
            <div
              v-for="(filter, index) in dataRangeFilters"
              :key="filter.id"
              class="filter-row"
            >
              <a-select
                v-model:value="filter.field"
                style="width: 160px"
                placeholder="选择字段"
                @change="handleFilterFieldChange(filter)"
              >
                <a-select-option value="timeRange">时间范围</a-select-option>
                <a-select-option value="businessType">业务类型</a-select-option>
                <a-select-option value="callDirection">呼叫方向</a-select-option>
                <a-select-option value="customTag">自定义标签</a-select-option>
              </a-select>

              <template v-if="filter.field === 'timeRange'">
                <a-range-picker
                  v-model:value="filter.value"
                  style="width: 280px"
                  format="YYYY-MM-DD"
                  :placeholder="['开始日期', '结束日期']"
                />
              </template>
              <template v-else-if="filter.field === 'businessType'">
                <a-select
                  v-model:value="filter.value"
                  style="width: 200px"
                  placeholder="选择业务类型"
                  mode="multiple"
                  :max-tag-count="2"
                >
                  <a-select-option value="credit_card">信用卡</a-select-option>
                  <a-select-option value="loan">贷款</a-select-option>
                  <a-select-option value="finance">理财</a-select-option>
                  <a-select-option value="deposit">存款</a-select-option>
                  <a-select-option value="insurance">保险</a-select-option>
                </a-select>
              </template>
              <template v-else-if="filter.field === 'callDirection'">
                <a-select
                  v-model:value="filter.value"
                  style="width: 160px"
                  placeholder="选择方向"
                >
                  <a-select-option value="outbound">外呼</a-select-option>
                  <a-select-option value="inbound">呼入</a-select-option>
                </a-select>
              </template>
              <template v-else-if="filter.field === 'customTag'">
                <a-input
                  v-model:value="filter.value"
                  style="width: 200px"
                  placeholder="输入标签名称"
                />
              </template>

              <a-button
                type="text"
                danger
                @click="handleDeleteDataRangeFilter(index)"
                class="delete-filter-btn"
              >
                <minus-circle-outlined />
              </a-button>
            </div>
          </div>
          <a-button
            type="dashed"
            block
            @click="handleAddDataRangeFilter"
            class="add-filter-btn"
          >
            <plus-outlined />
            添加筛选条件
          </a-button>
          <div class="filter-preview" v-if="dataRangeFilters.length > 0">
            <span class="filter-preview-label">数据预览：</span>
            <a-button type="link" size="small" @click="handlePreviewData">
              <search-outlined />
              查询符合条件的数据量
            </a-button>
            <span v-if="dataPreviewCount !== null" class="filter-preview-count">
              共 <strong>{{ dataPreviewCount }}</strong> 条
            </span>
          </div>
        </div>

        <!-- 步骤 2：配置抽样维度 -->
        <div v-else-if="samplingRuleStep === 2" class="step-sampling-content">
          <div class="step-section-title">配置抽样维度</div>
          <div class="step-section-desc">按维度依次抽选，后置维度在前置结果基础上抽样</div>

          <div class="dimension-list">
            <div
              v-for="(dimension, dIndex) in samplingDimensions"
              :key="dimension.id"
              class="dimension-card"
            >
              <div class="dimension-card-header">
                <div class="dimension-card-title">
                  <span class="dimension-index">{{ dIndex + 1 }}</span>
                  <a-select
                    v-model:value="dimension.type"
                    style="width: 140px"
                    placeholder="维度类型"
                    @change="handleDimensionTypeChange(dimension)"
                  >
                    <a-select-option value="scene">按场景</a-select-option>
                    <a-select-option value="agent">按坐席</a-select-option>
                    <a-select-option value="callDuration">按通话时长</a-select-option>
                    <a-select-option value="custom">自定义</a-select-option>
                  </a-select>
                  <a-input
                    v-if="dimension.type === 'custom'"
                    v-model:value="dimension.customLabel"
                    style="width: 120px; margin-left: 8px"
                    placeholder="维度名称"
                  />
                </div>
                <div class="dimension-card-actions">
                  <span class="mutual-exclusive-label">互斥</span>
                  <a-switch
                    v-model:checked="dimension.mutualExclusive"
                    size="small"
                    class="mutual-exclusive-switch"
                  />
                  <a-button
                    v-if="samplingDimensions.length > 1"
                    type="text"
                    danger
                    size="small"
                    @click="handleDeleteDimension(dIndex)"
                  >
                    <delete-outlined />
                  </a-button>
                </div>
              </div>

              <div class="dimension-card-body">
                <!-- 按场景 -->
                <template v-if="dimension.type === 'scene'">
                  <div class="dimension-config-label">抽样方式：比例抽取</div>
                  <a-table
                    :columns="sceneColumns"
                    :data-source="dimension.sceneItems"
                    :pagination="false"
                    row-key="id"
                    size="small"
                    bordered
                    class="dimension-table"
                  >
                    <template #bodyCell="{ column, record: item, index: itemIndex }">
                      <template v-if="column.key === 'group'">
                        组{{ itemIndex + 1 }}
                      </template>
                      <template v-else-if="column.key === 'sceneName'">
                        <a-input v-model:value="item.sceneName" placeholder="场景名称" size="small" />
                      </template>
                      <template v-else-if="column.key === 'ratio'">
                        <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" /> %
                      </template>
                      <template v-else-if="column.key === 'samplingCount'">
                        <span class="sampling-count-value">{{ samplingCountByRatio(item.ratio || 0) }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-button type="link" size="small" danger @click="handleDeleteSceneItem(dIndex, itemIndex)">删除</a-button>
                      </template>
                    </template>
                  </a-table>
                  <div class="dimension-table-footer">
                    <a-button type="link" size="small" @click="handleAddSceneItem(dIndex)">
                      <plus-outlined /> 添加场景
                    </a-button>
                    <span class="scene-ratio-total" :class="{ 'ratio-error': getDimensionSceneRatio(dIndex) > 100 }">
                      合计：{{ getDimensionSceneRatio(dIndex) }}%
                    </span>
                  </div>
                  <div class="dimension-option-row">
                    <a-checkbox v-model:checked="dimension.sceneAutoRemaining">
                      剩余未分配比例自动归入「其他」
                    </a-checkbox>
                  </div>
                </template>

                <!-- 按坐席 -->
                <template v-else-if="dimension.type === 'agent'">
                  <div class="dimension-config-label">
                    抽样方式：
                    <a-radio-group v-model:value="dimension.samplingMethod" size="small" class="inline-radio-group">
                      <a-radio value="count">数量抽取</a-radio>
                    </a-radio-group>
                  </div>
                  <a-radio-group v-model:value="dimension.agentMode" size="small" class="agent-mode-radio">
                    <a-radio value="list">按坐席列表</a-radio>
                    <a-radio value="group">按坐席分组</a-radio>
                  </a-radio-group>

                  <template v-if="dimension.agentMode === 'list'">
                    <a-table
                      :columns="agentListColumns"
                      :data-source="dimension.agentList"
                      :pagination="false"
                      row-key="id"
                      size="small"
                      bordered
                      class="dimension-table"
                    >
                      <template #bodyCell="{ column, record: item, index: itemIndex }">
                        <template v-if="column.key === 'group'">
                          组{{ itemIndex + 1 }}
                        </template>
                        <template v-else-if="column.key === 'agentId'">
                          <a-input v-model:value="item.agentId" placeholder="坐席工号" size="small" />
                        </template>
                        <template v-else-if="column.key === 'count'">
                          <a-input-number v-model:value="item.count" :min="1" :precision="0" size="small" style="width: 80px" />
                        </template>
                        <template v-else-if="column.key === 'action'">
                          <a-button type="link" size="small" danger @click="handleDeleteAgentItem(dIndex, itemIndex)">删除</a-button>
                        </template>
                      </template>
                    </a-table>
                    <div class="dimension-table-footer">
                      <a-button type="link" size="small" @click="handleAddAgentItem(dIndex)">
                        <plus-outlined /> 添加坐席
                      </a-button>
                      <span class="count-total">
                        合计：{{ agentListTotalCount }} 条
                      </span>
                    </div>
                  </template>

                  <template v-else>
                    <a-table
                      :columns="agentGroupColumns"
                      :data-source="dimension.agentGroups"
                      :pagination="false"
                      row-key="id"
                      size="small"
                      bordered
                      class="dimension-table"
                    >
                      <template #bodyCell="{ column, record: item, index: itemIndex }">
                        <template v-if="column.key === 'group'">
                          组{{ itemIndex + 1 }}
                        </template>
                        <template v-else-if="column.key === 'groupName'">
                          <a-input v-model:value="item.groupName" placeholder="分组名称（如：初级客服）" size="small" />
                        </template>
                        <template v-else-if="column.key === 'count'">
                          <a-input-number v-model:value="item.count" :min="1" :precision="0" size="small" style="width: 80px" /> 条/人
                        </template>
                        <template v-else-if="column.key === 'action'">
                          <a-button type="link" size="small" danger @click="handleDeleteAgentGroup(dIndex, itemIndex)">删除</a-button>
                        </template>
                      </template>
                    </a-table>
                    <div class="dimension-table-footer">
                      <a-button type="link" size="small" @click="handleAddAgentGroup(dIndex)">
                        <plus-outlined /> 添加分组
                      </a-button>
                      <span class="count-total">
                        合计：{{ agentGroupTotalCount }} 条
                      </span>
                    </div>
                  </template>
                </template>

                <!-- 按通话时长 -->
                <template v-else-if="dimension.type === 'callDuration'">
                  <div class="dimension-config-label">抽样方式：比例抽取（按区间分段）</div>
                  <a-table
                    :columns="durationColumns"
                    :data-source="dimension.durationIntervals"
                    :pagination="false"
                    row-key="id"
                    size="small"
                    bordered
                    class="dimension-table"
                  >
                    <template #bodyCell="{ column, record: item, index: itemIndex }">
                      <template v-if="column.key === 'group'">
                        组{{ itemIndex + 1 }}
                      </template>
                      <template v-else-if="column.key === 'range'">
                        <a-input-number v-model:value="item.minDuration" :min="0" :precision="0" size="small" style="width: 80px" placeholder="秒" />
                        <span class="range-separator">~</span>
                        <a-input-number v-model:value="item.maxDuration" :min="0" :precision="0" size="small" style="width: 80px" placeholder="秒" />
                        <span class="range-unit">秒</span>
                      </template>
                      <template v-else-if="column.key === 'ratio'">
                        <a-input-number v-model:value="item.ratio" :min="0" :max="100" :precision="0" size="small" style="width: 80px" /> %
                      </template>
                      <template v-else-if="column.key === 'samplingCount'">
                        <span class="sampling-count-value">{{ samplingCountByRatio(item.ratio || 0) }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-button type="link" size="small" danger @click="handleDeleteDurationInterval(dIndex, itemIndex)">删除</a-button>
                      </template>
                    </template>
                  </a-table>
                  <div class="dimension-table-footer">
                    <a-button type="link" size="small" @click="handleAddDurationInterval(dIndex)">
                      <plus-outlined /> 添加区间
                    </a-button>
                    <span class="scene-ratio-total" :class="{ 'ratio-error': getDimensionDurationRatio(dIndex) > 100 }">
                      合计：{{ getDimensionDurationRatio(dIndex) }}%
                    </span>
                  </div>
                  <div class="duration-chart-preview" v-if="dimension.durationIntervals.length > 0">
                    <div class="chart-bar-wrapper">
                      <div
                        v-for="(item, idx) in dimension.durationIntervals"
                        :key="item.id"
                        class="chart-bar-segment"
                        :style="{ width: item.ratio + '%', backgroundColor: chartColors[idx % chartColors.length] }"
                      >
                        <span v-if="item.ratio >= 10">{{ item.ratio }}%</span>
                      </div>
                    </div>
                    <div class="chart-legend">
                      <span
                        v-for="(item, idx) in dimension.durationIntervals"
                        :key="item.id"
                        class="chart-legend-item"
                      >
                        <span class="chart-legend-dot" :style="{ backgroundColor: chartColors[idx % chartColors.length] }"></span>
                        {{ item.minDuration || 0 }}s~{{ item.maxDuration || '∞' }}s
                      </span>
                    </div>
                  </div>
                </template>

                <!-- 自定义维度 -->
                <template v-else-if="dimension.type === 'custom'">
                  <div class="dimension-config-label">
                    抽样方式：
                    <a-radio-group v-model:value="dimension.samplingMethod" size="small" class="inline-radio-group">
                      <a-radio value="ratio">比例抽取</a-radio>
                      <a-radio value="count">数量抽取</a-radio>
                    </a-radio-group>
                  </div>
                  <div class="custom-dimension-placeholder">
                    <a-input placeholder="自定义维度配置（预留扩展）" disabled />
                  </div>
                </template>
              </div>
            </div>
          </div>

          <a-button type="dashed" block @click="handleAddDimension" class="add-dimension-btn">
            <plus-outlined />
            添加抽样维度
          </a-button>

          <div class="estimated-total">
            <span class="estimated-label">预计抽检总数：</span>
            <span class="estimated-value">{{ estimatedSamplingTotal }}</span>
            <span v-if="globalQuotas.taskTotalMax && estimatedSamplingTotal > globalQuotas.taskTotalMax" class="estimated-warning">
              ⚠ 已超过任务上限 {{ globalQuotas.taskTotalMax }} 条
            </span>
          </div>
        </div>

        <!-- 步骤 3：设置全局配额与上限 -->
        <div v-else-if="samplingRuleStep === 3" class="step-sampling-content">
          <div class="step-section-title">设置全局配额与上限</div>
          <div class="step-section-desc">配置质检员工作量和任务规模限制</div>

          <a-form layout="horizontal" :label-col="{ span: 8 }" :wrapper-col="{ span: 14 }" class="quota-form">
            <a-form-item label="每人每日最大处理量">
              <a-input-number v-model:value="globalQuotas.inspectorDailyMax" :min="1" :precision="0" style="width: 200px" placeholder="如 100" />
              <span class="quota-unit">条/人/日</span>
              <div class="quota-hint">系统自动约束任务分配时每位质检员的工作量上限</div>
            </a-form-item>

            <a-form-item label="单次任务总上限">
              <a-input-number v-model:value="globalQuotas.taskTotalMax" :min="1" :precision="0" style="width: 200px" placeholder="如 5000" />
              <span class="quota-unit">条</span>
              <div class="quota-hint">防止任务过载，抽检总数不得超过此上限</div>
              <div v-if="globalQuotas.taskTotalMax && estimatedSamplingTotal > globalQuotas.taskTotalMax" class="quota-error">
                当前预计抽检 {{ estimatedSamplingTotal }} 条，已超过上限
              </div>
            </a-form-item>

            <a-form-item label="每维度最小命中量">
              <a-input-number v-model:value="globalQuotas.dimensionMinCount" :min="0" :precision="0" style="width: 200px" placeholder="如 3" />
              <span class="quota-unit">条（可选）</span>
              <div class="quota-hint">避免小样本被遗漏，每个抽样维度至少命中此数量</div>
            </a-form-item>
          </a-form>
        </div>

        <!-- 步骤 4：设置调度计划 -->
        <div v-else-if="samplingRuleStep === 4" class="step-sampling-content">
          <div class="step-section-title">设置调度计划</div>
          <div class="step-section-desc">配置抽检任务的自动执行计划</div>

          <a-form layout="horizontal" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }" class="schedule-form">
            <a-form-item label="执行频率">
              <a-radio-group v-model:value="scheduleConfig.frequency">
                <a-radio value="daily">每日</a-radio>
                <a-radio value="weekly">每周</a-radio>
                <a-radio value="monthly">每月</a-radio>
              </a-radio-group>
            </a-form-item>

            <a-form-item v-if="scheduleConfig.frequency === 'weekly'" label="执行日期">
              <a-checkbox-group v-model:value="scheduleConfig.weekDays">
                <a-checkbox :value="1">周一</a-checkbox>
                <a-checkbox :value="2">周二</a-checkbox>
                <a-checkbox :value="3">周三</a-checkbox>
                <a-checkbox :value="4">周四</a-checkbox>
                <a-checkbox :value="5">周五</a-checkbox>
                <a-checkbox :value="6">周六</a-checkbox>
                <a-checkbox :value="0">周日</a-checkbox>
              </a-checkbox-group>
            </a-form-item>

            <a-form-item v-if="scheduleConfig.frequency === 'monthly'" label="执行日期">
              <a-select
                v-model:value="scheduleConfig.monthDays"
                mode="multiple"
                style="width: 100%"
                placeholder="选择每月几号执行"
                :max-tag-count="5"
              >
                <a-select-option v-for="d in 28" :key="d" :value="d">{{ d }}号</a-select-option>
              </a-select>
            </a-form-item>

            <a-form-item label="执行时间">
              <a-time-picker v-model:value="scheduleConfig.executeTimeValue" format="HH:mm" style="width: 200px" :placeholder="'选择执行时间'" />
            </a-form-item>

            <a-form-item label="生效时间">
              <div class="schedule-date-range">
                <a-date-picker v-model:value="scheduleConfig.startDateValue" format="YYYY-MM-DD" placeholder="开始日期" style="width: 160px" />
                <span class="date-separator">至</span>
                <a-date-picker v-if="!scheduleConfig.permanent" v-model:value="scheduleConfig.endDateValue" format="YYYY-MM-DD" placeholder="结束日期" style="width: 160px" />
                <a-checkbox v-model:checked="scheduleConfig.permanent" style="margin-left: 12px">永久有效</a-checkbox>
              </div>
            </a-form-item>

            <a-form-item label="数据时间偏移">
              <div class="offset-row">
                <span class="offset-prefix">固定抓取</span>
                <a-input-number v-model:value="scheduleConfig.dataOffset" :min="0" :max="30" :precision="0" style="width: 80px" />
                <span class="offset-suffix">日前的数据</span>
              </div>
              <div class="offset-preview">{{ scheduleDescription }}</div>
            </a-form-item>
          </a-form>
        </div>

        <!-- 步骤 5：命名与保存 -->
        <div v-else-if="samplingRuleStep === 5" class="step-sampling-content">
          <div class="step-section-title">命名与保存</div>
          <div class="step-section-desc">确认策略配置并保存</div>

          <a-form layout="horizontal" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }" class="naming-form">
            <a-form-item label="策略名称">
              <a-input v-model:value="samplingRuleForm.taskName" placeholder="请输入策略名称" :maxlength="50" show-count />
            </a-form-item>
            <a-form-item label="策略描述">
              <a-textarea v-model:value="samplingRuleForm.taskDescription" placeholder="请输入策略描述" :rows="3" :maxlength="200" show-count />
            </a-form-item>
            <a-form-item label="启用状态">
              <a-switch v-model:checked="samplingRuleForm.strategyEnabled" />
              <span class="strategy-status-text">{{ samplingRuleForm.strategyEnabled ? '启用' : '停用' }}</span>
            </a-form-item>
          </a-form>

          <!-- 策略概览卡片 -->
          <div class="strategy-overview">
            <div class="overview-title">策略概览</div>
            <div class="overview-grid">
              <div class="overview-item">
                <span class="overview-label">筛选条件</span>
                <span class="overview-value">{{ dataRangeFilters.filter(f => f.field).length }} 个条件</span>
              </div>
              <div class="overview-item">
                <span class="overview-label">抽样维度</span>
                <span class="overview-value">{{ samplingDimensions.length }} 个维度</span>
              </div>
              <div class="overview-item">
                <span class="overview-label">预计抽检量</span>
                <span class="overview-value">{{ estimatedSamplingTotal }} 条</span>
              </div>
              <div class="overview-item">
                <span class="overview-label">执行频率</span>
                <span class="overview-value">{{ scheduleDescription }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 底部按钮 -->
        <div class="modal-footer">
          <a-space>
            <a-button @click="handleSamplingRuleCancel">取消</a-button>
            <a-button v-if="samplingRuleStep > 1" @click="handleSamplingRulePrev">上一步</a-button>
            <a-button v-if="samplingRuleStep === 5" type="primary" @click="handleSamplingRuleConfirm">完成</a-button>
            <a-button v-else type="primary" @click="handleSamplingRuleNext">下一步</a-button>
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
  ExperimentOutlined,
  CheckCircleFilled,
} from '@ant-design/icons-vue'

const router = useRouter()

// ============ 类型定义 ============
interface QualityTaskItem {
  taskId: number
  taskName: string
  taskDescription: string
  qualityModel: string
  qualityObject: string
  qualityScope: 'full' | 'sampling'
  autoAppend: boolean
  status: 'running' | 'paused' | 'completed' | 'pending'
  auditStatus: string
  auditor: string | string[]
  creator: string
  createdAt: string
  completedAt?: string
  aiProgressPercent: number
  aiCompleted: number
  aiTotal: number
}

interface SearchFormData {
  keyword: string
  taskStatus: string | undefined
  qualityObject: string | undefined
  qualityModel: string | undefined
  qualityScope: string | undefined
  autoAppend: string | undefined
  auditor: string | undefined
  inspector: string | undefined
}

interface CreateTaskForm {
  taskType: 'ai' | 'manual'
  taskName: string
  taskDescription: string
  qualityModel: string | undefined
  qualityObject: string | undefined
  inspector: string[]
  recordType: 'ai_assisted' | 'manual_outbound' | 'manual_upload'
  autoAppend: boolean
  autoAppendExecTime: any
  autoAppendStartType: 'today' | 'yesterday'
  autoAppendRangeStart: any
  autoAppendEndType: 'today' | 'yesterday'
  autoAppendRangeEnd: any
  qualityScope: 'full' | 'sampling'
  samplingCount: number | null
  allocationMethod: 'total' | 'ratio' | 'perPerson'
  allocationValue: number | null
  samplingMethod: 'average' | 'ratio'
  samplingDimension: 'scene' | 'agent' | 'callDuration'
  dedupEnabled: boolean
  dedupType: 'global' | 'model'
  strategyEnabled: boolean
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

// ============ 抽检策略相关类型定义 ============
interface DataRangeFilter {
  id: number
  field: string
  operator: string
  value: string
  value2?: string
}

interface SceneDimensionItem {
  id: number
  sceneName: string
  ratio: number
}

interface AgentDimensionItem {
  id: number
  agentId: string
  count: number
}

interface AgentGroupItem {
  id: number
  groupName: string
  count: number
}

interface DurationInterval {
  id: number
  minDuration: number | null
  maxDuration: number | null
  ratio: number
}

interface SamplingDimension {
  id: number
  type: 'scene' | 'agent' | 'callDuration' | 'custom'
  samplingMethod: 'ratio' | 'count'
  mutualExclusive: boolean
  sceneItems: SceneDimensionItem[]
  sceneAutoRemaining: boolean
  agentMode: 'list' | 'group'
  agentList: AgentDimensionItem[]
  agentGroups: AgentGroupItem[]
  durationIntervals: DurationInterval[]
  customLabel: string
}

interface GlobalQuotas {
  inspectorDailyMax: number | null
  taskTotalMax: number | null
  dimensionMinCount: number | null
}

interface ScheduleConfig {
  frequency: 'daily' | 'weekly' | 'monthly'
  weekDays: number[]
  monthDays: number[]
  executeTime: string
  startDate: string
  endDate: string | null
  permanent: boolean
  dataOffset: number
  [key: string]: any
}

// ============ 部分抽检 - 抽样维度数据 ============
const samplingSceneItems = ref<Array<{ sceneName: string | undefined; ratio: number | null }>>([
  { sceneName: undefined, ratio: null },
])

const samplingAgentItems = ref<Array<{ agentId: string | undefined; ratio: number | null }>>([
  { agentId: undefined, ratio: null },
])

const samplingDurationItems = ref<Array<{ minDuration: number | null; maxDuration: number | null; ratio: number | null }>>([
  { minDuration: null, maxDuration: null, ratio: null },
])

// 按坐席表格列
const agentColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '坐席', key: 'agentId', width: 200 },
  { title: '比例', key: 'ratio', width: 140 },
  { title: '抽检条数', key: 'samplingCount', width: 120 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 比例合计计算
const samplingSceneRatioTotal = computed(() => {
  return samplingSceneItems.value.reduce((sum, item) => sum + (item.ratio || 0), 0)
})

const samplingAgentRatioTotal = computed(() => {
  return samplingAgentItems.value.reduce((sum, item) => sum + (item.ratio || 0), 0)
})

const samplingDurationRatioTotal = computed(() => {
  return samplingDurationItems.value.reduce((sum, item) => sum + (item.ratio || 0), 0)
})

// 抽样维度 CRUD
const handleAddSamplingSceneItem = () => {
  samplingSceneItems.value.push({ sceneName: undefined, ratio: null })
}

const handleDeleteSamplingSceneItem = (index: number) => {
  samplingSceneItems.value.splice(index, 1)
}

const handleAddSamplingAgentItem = () => {
  samplingAgentItems.value.push({ agentId: undefined, ratio: null })
}

const handleDeleteSamplingAgentItem = (index: number) => {
  samplingAgentItems.value.splice(index, 1)
}

const handleAddSamplingDurationItem = () => {
  samplingDurationItems.value.push({ minDuration: null, maxDuration: null, ratio: null })
}

const handleDeleteSamplingDurationItem = (index: number) => {
  samplingDurationItems.value.splice(index, 1)
}

// ============ 表格列定义 ============
const columns = computed(() => {
  const baseColumns: any[] = [
    { title: '质检任务 ID', dataIndex: 'taskId', key: 'taskId', width: 110, ellipsis: true as any },
    { title: '质检任务名称', dataIndex: 'taskName', key: 'taskName', width: 200, ellipsis: true as any },
    { title: '任务说明', dataIndex: 'taskDescription', key: 'taskDescription', width: 220, ellipsis: true as any },
    { title: '质检模型', dataIndex: 'qualityModel', key: 'qualityModel', width: 150, ellipsis: true as any },
    {
      title: '质检范围',
      dataIndex: 'qualityScope',
      key: 'qualityScope',
      width: 110,
      ellipsis: true as any,
      customRender: ({ text }: { text: string }) => getQualityScopeLabel(text),
    },
    {
      title: '数据追加',
      dataIndex: 'autoAppend',
      key: 'autoAppend',
      width: 100,
      ellipsis: true as any,
      customRender: ({ text }: { text: boolean }) => text ? '开启' : '关闭',
    },
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
  qualityModel: undefined,
  qualityObject: undefined,
  inspector: [],
  recordType: 'ai_assisted',
  autoAppend: false,
  autoAppendExecTime: null,
  autoAppendStartType: 'yesterday',
  autoAppendRangeStart: null,
  autoAppendEndType: 'today',
  autoAppendRangeEnd: null,
  qualityScope: 'full',
  samplingCount: null,
  allocationMethod: 'total',
  allocationValue: null,
  samplingMethod: 'average',
  samplingDimension: 'scene',
  dedupEnabled: false,
  dedupType: 'global',
  strategyEnabled: true,
})

// 抽检规则弹窗相关
const samplingRuleModalVisible = ref(false)
const samplingRuleStep = ref(1)
const samplingRuleForm = reactive({
  taskType: 'ai' as 'ai' | 'manual',
  taskName: '',
  taskDescription: '',
  qualityModel: '',
  qualityObject: '',
  inspector: [] as string[],
  strategyEnabled: true,
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
const queryLoading = ref(false)

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
  if (!createTaskForm.allocationValue || !ratio) return 0
  
  // 根据分配方式计算总抽检数量
  let totalCount = 0
  if (createTaskForm.allocationMethod === 'total') {
    // 按总数：直接使用用户输入的值
    totalCount = createTaskForm.allocationValue
  } else if (createTaskForm.allocationMethod === 'ratio') {
    // 按比例：总数 = 查询结果 × 百分比 / 100
    if (!queryResult.value) return 0
    totalCount = Math.floor(queryResult.value * createTaskForm.allocationValue / 100)
  } else if (createTaskForm.allocationMethod === 'perPerson') {
    // 人均数量：总数 = 每人数量 × 质检员人数
    const inspectorCount = createTaskForm.inspector?.length || 1
    totalCount = createTaskForm.allocationValue * inspectorCount
  }
  
  // 根据比例计算当前行的抽检条数
  return Math.floor(totalCount * ratio / 100)
}

// 计算总抽检数量（用于显示）
const totalSamplingCount = computed(() => {
  if (!createTaskForm.allocationValue) return 0
  
  if (createTaskForm.allocationMethod === 'total') {
    return createTaskForm.allocationValue
  } else if (createTaskForm.allocationMethod === 'ratio') {
    if (!queryResult.value) return 0
    return Math.floor(queryResult.value * createTaskForm.allocationValue / 100)
  } else if (createTaskForm.allocationMethod === 'perPerson') {
    const inspectorCount = createTaskForm.inspector?.length || 1
    return createTaskForm.allocationValue * inspectorCount
  }
  return 0
})

// ============ 抽检策略 - 数据范围筛选 ============
const dataRangeFilters = ref<DataRangeFilter[]>([
  { id: 1, field: 'timeRange', operator: 'between', value: '' },
])
let dataRangeFilterIdCounter = 1
const dataPreviewCount = ref<number | null>(null)

// ============ 抽检策略 - 抽样维度 ============
let dimensionIdCounter = 1
let sceneItemIdCounter = 1
let agentItemIdCounter = 1
let agentGroupIdCounter = 1
let durationIntervalIdCounter = 1

const samplingDimensions = ref<SamplingDimension[]>([
  {
    id: 1,
    type: 'scene',
    samplingMethod: 'ratio',
    mutualExclusive: true,
    sceneItems: [{ id: 1, sceneName: '', ratio: 0 }],
    sceneAutoRemaining: true,
    agentMode: 'list',
    agentList: [{ id: 1, agentId: '', count: 1 }],
    agentGroups: [{ id: 1, groupName: '', count: 1 }],
    durationIntervals: [{ id: 1, minDuration: null, maxDuration: null, ratio: 0 }],
    customLabel: '',
  },
])

const chartColors = ['#1677ff', '#52c41a', '#faad14', '#ff4d4f', '#722ed1', '#13c2c2', '#eb2f96', '#fa8c16']

// 场景选项
const sceneOptions = [
  { label: '场景A', value: '场景A' },
  { label: '场景B', value: '场景B' },
  { label: '场景C', value: '场景C' },
  { label: '场景D', value: '场景D' },
]

// 坐席选项
const agentOptions = [
  { label: '张三', value: '张三' },
  { label: '李四', value: '李四' },
  { label: '王五', value: '王五' },
  { label: '赵六', value: '赵六' },
]

// 按场景表格列
const sceneColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '场景名称', key: 'sceneName', width: 200 },
  { title: '比例', key: 'ratio', width: 140 },
  { title: '抽检条数', key: 'samplingCount', width: 120 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按坐席列表表格列
const agentListColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '坐席工号', key: 'agentId', width: 200 },
  { title: '抽取条数', key: 'count', width: 140 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按坐席分组表格列
const agentGroupColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '分组名称', key: 'groupName', width: 200 },
  { title: '每人抽取', key: 'count', width: 160 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按通话时长表格列
const durationColumns = [
  { title: '组别', key: 'group', width: 80 },
  { title: '时长区间', key: 'range', width: 240 },
  { title: '比例', key: 'ratio', width: 140 },
  { title: '抽检条数', key: 'samplingCount', width: 120 },
  { title: '操作', key: 'action', width: 80, align: 'center' as const },
]

// 按坐席总抽取条数计算
const agentListTotalCount = computed(() => {
  return samplingAgentItems.value.reduce((sum, item) => sum + (item.count || 0), 0)
})

const agentGroupTotalCount = computed(() => {
  return samplingAgentItems.value.reduce((sum, item) => sum + (item.count || 0), 0)
})

// ============ 抽检策略 - 全局配额 ============
const globalQuotas = reactive<GlobalQuotas>({
  inspectorDailyMax: null,
  taskTotalMax: null,
  dimensionMinCount: null,
})

// ============ 抽检策略 - 调度计划 ============
const scheduleConfig = reactive<ScheduleConfig>({
  frequency: 'daily',
  weekDays: [],
  monthDays: [],
  executeTime: '',
  startDate: '',
  endDate: null,
  permanent: true,
  dataOffset: 1,
  executeTimeValue: null as any,
  startDateValue: null as any,
  endDateValue: null as any,
})

// ============ 抽检策略 - 计算属性 ============
const isLastStep = computed(() => {
  return createTaskStep.value === 2
})

const estimatedSamplingTotal = computed(() => {
  if (samplingDimensions.value.length === 0) return 0
  const firstDimension = samplingDimensions.value[0]
  if (firstDimension.type === 'scene') {
    return firstDimension.sceneItems.reduce((sum, item) => sum + (item.ratio || 0), 0)
  }
  if (firstDimension.type === 'agent') {
    if (firstDimension.agentMode === 'list') {
      return firstDimension.agentList.reduce((sum, item) => sum + (item.count || 0), 0)
    }
    return firstDimension.agentGroups.reduce((sum, item) => sum + (item.count || 0), 0)
  }
  if (firstDimension.type === 'callDuration') {
    return firstDimension.durationIntervals.reduce((sum, item) => sum + (item.ratio || 0), 0)
  }
  return 0
})

const scheduleDescription = computed(() => {
  const freqMap: Record<string, string> = { daily: '每天', weekly: '每周', monthly: '每月' }
  let desc = freqMap[scheduleConfig.frequency] || '每天'
  if (scheduleConfig.frequency === 'weekly' && scheduleConfig.weekDays.length > 0) {
    const dayNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    desc += ' ' + scheduleConfig.weekDays.map(d => dayNames[d]).join('、')
  }
  if (scheduleConfig.frequency === 'monthly' && scheduleConfig.monthDays.length > 0) {
    desc += ' ' + scheduleConfig.monthDays.map(d => d + '号').join('、')
  }
  desc += ` 生成T-${scheduleConfig.dataOffset}日的抽检任务`
  return desc
})

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
  queryLoading.value = true
  queryResult.value = null
  setTimeout(() => {
    queryResult.value = Math.floor(Math.random() * 1000) + 100
    queryLoading.value = false
  }, 600)
}

// 质检范围变化处理
const handleQualityScopeChange = () => {
  if (createTaskForm.qualityScope === 'sampling') {
    samplingRules.value = []
    samplingRuleIdCounter = 0
    createTaskForm.allocationMethod = 'total'
    createTaskForm.allocationValue = null
    createTaskForm.samplingMethod = 'average'
    createTaskForm.samplingDimension = 'scene'
    samplingSceneItems.value = [{ sceneName: undefined, ratio: null }]
    samplingAgentItems.value = [{ agentId: undefined, ratio: null }]
    samplingDurationItems.value = [{ minDuration: null, maxDuration: null, ratio: null }]
    queryResult.value = null
  } else {
    handleQueryData()
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
  keyword: '',
  taskStatus: undefined,
  qualityObject: undefined,
  qualityModel: undefined,
  qualityScope: undefined,
  autoAppend: undefined,
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
    qualityScope: 'full',
    autoAppend: true,
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
    qualityScope: 'sampling',
    autoAppend: false,
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
    qualityScope: 'sampling',
    autoAppend: true,
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
    qualityScope: 'full',
    autoAppend: false,
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
    qualityScope: 'full',
    autoAppend: true,
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
    qualityScope: 'sampling',
    autoAppend: false,
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
    qualityScope: 'full',
    autoAppend: true,
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

  // 关键词搜索（任务名称/ID/说明）
  if (searchForm.keyword) {
    const kw = searchForm.keyword.toLowerCase()
    filtered = filtered.filter(item =>
      item.taskName.toLowerCase().includes(kw) ||
      item.taskId.toString().includes(kw) ||
      item.taskDescription.toLowerCase().includes(kw)
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

  if (searchForm.qualityScope) {
    filtered = filtered.filter(item => item.qualityScope === searchForm.qualityScope)
  }

  if (searchForm.autoAppend !== undefined) {
    const appendValue = searchForm.autoAppend === 'true'
    filtered = filtered.filter(item => item.autoAppend === appendValue)
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

// 获取质检范围标签
const getQualityScopeLabel = (value: string) => {
  const map: Record<string, string> = {
    full: '全量质检',
    sampling: '部分抽检',
  }
  return map[value] || value
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
    keyword: '',
    taskStatus: undefined,
    qualityObject: undefined,
    qualityModel: undefined,
    qualityScope: undefined,
    autoAppend: undefined,
    auditor: undefined,
    inspector: undefined,
  })
  message.success('已重置搜索条件')
}

const handleCreateTask = () => {
  createTaskModalVisible.value = true
  createTaskStep.value = 1
}

const handleCreateSamplingRule = () => {
  samplingRuleModalVisible.value = true
  samplingRuleStep.value = 1
}

const handleSamplingRuleNext = () => {
  if (samplingRuleStep.value < 5) {
    samplingRuleStep.value++
  }
}

const handleSamplingRulePrev = () => {
  if (samplingRuleStep.value > 1) {
    samplingRuleStep.value--
  }
}

const handleSamplingRuleCancel = () => {
  samplingRuleModalVisible.value = false
  samplingRuleStep.value = 1
  Object.assign(samplingRuleForm, {
    taskType: 'ai',
    taskName: '',
    taskDescription: '',
    qualityModel: '',
    qualityObject: '',
    inspector: [],
    strategyEnabled: true,
  })
  dataRangeFilters.value = [{ id: 1, field: 'timeRange', operator: 'between', value: '' }]
  dataRangeFilterIdCounter = 1
  dataPreviewCount.value = null
  samplingDimensions.value = [{
    id: 1, type: 'scene', samplingMethod: 'ratio', mutualExclusive: true,
    sceneItems: [{ id: 1, sceneName: '', ratio: 0 }], sceneAutoRemaining: true,
    agentMode: 'list', agentList: [{ id: 1, agentId: '', count: 1 }],
    agentGroups: [{ id: 1, groupName: '', count: 1 }],
    durationIntervals: [{ id: 1, minDuration: null, maxDuration: null, ratio: 0 }],
    customLabel: '',
  }]
  dimensionIdCounter = 1
  Object.assign(globalQuotas, { inspectorDailyMax: null, taskTotalMax: null, dimensionMinCount: null })
  Object.assign(scheduleConfig, {
    frequency: 'daily', weekDays: [], monthDays: [], executeTime: '',
    startDate: '', endDate: null, permanent: true, dataOffset: 1,
    executeTimeValue: null, startDateValue: null, endDateValue: null,
  })
}

const handleSamplingRuleConfirm = () => {
  if (samplingDimensions.value.length === 0) {
    message.error('请至少添加一个抽样维度')
    return
  }
  if (!samplingRuleForm.taskName) {
    message.error('请输入策略名称')
    return
  }
  console.log('创建抽检规则:', samplingRuleForm)
  message.success('抽检规则创建成功')
  handleSamplingRuleCancel()
}

// 下一步
const handleCreateNext = async () => {
  if (createTaskStep.value === 1) {
    if (!createTaskFormRef.value) return
    try {
      await createTaskFormRef.value.validate()
      createTaskStep.value = 2
    } catch (error) {
      console.error('表单验证失败:', error)
    }
  } else {
    createTaskStep.value++
  }
}

// 上一步
const handleCreatePrev = () => {
  if (createTaskStep.value > 1) {
    createTaskStep.value--
  }
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
    qualityModel: undefined,
    qualityObject: undefined,
    inspector: [],
    recordType: 'ai_assisted',
    autoAppend: false,
    dedupEnabled: false,
    dedupType: 'global',
  })
  fileList.value = []
}

// 确认创建
const handleCreateConfirm = () => {
  console.log('创建任务:', createTaskForm)
  message.success('创建成功')
  handleCreateCancel()
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
  editTaskForm.inspector = Array.isArray(row.auditor) ? row.auditor[0] : (row.auditor || row.creator)
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

// ============ 抽检策略 - 数据范围筛选方法 ============
const handleAddDataRangeFilter = () => {
  dataRangeFilterIdCounter++
  dataRangeFilters.value.push({
    id: dataRangeFilterIdCounter,
    field: '',
    operator: '',
    value: '',
  })
}

const handleDeleteDataRangeFilter = (index: number) => {
  dataRangeFilters.value.splice(index, 1)
}

const handleFilterFieldChange = (filter: DataRangeFilter) => {
  filter.value = ''
  filter.value2 = ''
  dataPreviewCount.value = null
}

const handlePreviewData = () => {
  dataPreviewCount.value = Math.floor(Math.random() * 5000) + 200
  message.success('数据查询完成')
}

// ============ 抽检策略 - 抽样维度方法 ============
const handleAddDimension = () => {
  dimensionIdCounter++
  samplingDimensions.value.push({
    id: dimensionIdCounter,
    type: 'scene',
    samplingMethod: 'ratio',
    mutualExclusive: true,
    sceneItems: [{ id: ++sceneItemIdCounter, sceneName: '', ratio: 0 }],
    sceneAutoRemaining: true,
    agentMode: 'list',
    agentList: [{ id: ++agentItemIdCounter, agentId: '', count: 1 }],
    agentGroups: [{ id: ++agentGroupIdCounter, groupName: '', count: 1 }],
    durationIntervals: [{ id: ++durationIntervalIdCounter, minDuration: null, maxDuration: null, ratio: 0 }],
    customLabel: '',
  })
}

const handleDeleteDimension = (dIndex: number) => {
  samplingDimensions.value.splice(dIndex, 1)
}

const handleDimensionTypeChange = (dimension: SamplingDimension) => {
  dimension.samplingMethod = dimension.type === 'agent' ? 'count' : 'ratio'
}

// 按场景
const handleAddSceneItem = (dIndex: number) => {
  sceneItemIdCounter++
  samplingDimensions.value[dIndex].sceneItems.push({
    id: sceneItemIdCounter,
    sceneName: '',
    ratio: 0,
  })
}

const handleDeleteSceneItem = (dIndex: number, itemIndex: number) => {
  samplingDimensions.value[dIndex].sceneItems.splice(itemIndex, 1)
}

const getDimensionSceneRatio = (dIndex: number) => {
  return samplingDimensions.value[dIndex].sceneItems.reduce((sum, item) => sum + (item.ratio || 0), 0)
}

// 按坐席
const handleAddAgentItem = (dIndex: number) => {
  agentItemIdCounter++
  samplingDimensions.value[dIndex].agentList.push({
    id: agentItemIdCounter,
    agentId: '',
    count: 1,
  })
}

const handleDeleteAgentItem = (dIndex: number, itemIndex: number) => {
  samplingDimensions.value[dIndex].agentList.splice(itemIndex, 1)
}

const handleAddAgentGroup = (dIndex: number) => {
  agentGroupIdCounter++
  samplingDimensions.value[dIndex].agentGroups.push({
    id: agentGroupIdCounter,
    groupName: '',
    count: 1,
  })
}

const handleDeleteAgentGroup = (dIndex: number, itemIndex: number) => {
  samplingDimensions.value[dIndex].agentGroups.splice(itemIndex, 1)
}

// 按通话时长
const handleAddDurationInterval = (dIndex: number) => {
  durationIntervalIdCounter++
  samplingDimensions.value[dIndex].durationIntervals.push({
    id: durationIntervalIdCounter,
    minDuration: null,
    maxDuration: null,
    ratio: 0,
  })
}

const handleDeleteDurationInterval = (dIndex: number, itemIndex: number) => {
  samplingDimensions.value[dIndex].durationIntervals.splice(itemIndex, 1)
}

const getDimensionDurationRatio = (dIndex: number) => {
  return samplingDimensions.value[dIndex].durationIntervals.reduce((sum, item) => sum + (item.ratio || 0), 0)
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

.section-box {
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  padding: 16px 20px;
  margin-bottom: 16px;
  background: #fafafa;
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

/* 质检范围选择 */
.quality-scope-section {
  padding: 12px 0 4px;
}

.quality-scope-cards {
  display: flex;
  gap: 16px;
}

/* 质检数量 */
.quality-count-section {
  margin-top: 16px;
  padding: 16px 20px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fafafa;
}

.quality-count-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 12px;
}

.quality-count-content {
  /* content area */
}

/* 抽样方式 */
.sampling-method-section {
  margin-top: 16px;
  padding: 16px 20px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fafafa;
}

.sampling-method-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 12px;
}

/* 录音类型选择 */
.record-type-section {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.record-type-card {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 8px 16px;
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #fff;
  font-size: 13px;
  color: #595959;
}

.record-type-card:hover {
  border-color: #91caff;
  color: #1677ff;
}

.record-type-card.active {
  border-color: #1677ff;
  color: #1677ff;
  background: #f0f7ff;
}

.record-type-check {
  font-size: 14px;
  color: #1677ff;
}

.scope-cards {
  display: flex;
  gap: 12px;
}

.scope-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  border: 2px solid #e8e8e8;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: #fff;
  position: relative;
}

.scope-card:hover {
  border-color: #91caff;
  background: #f0f7ff;
}

.scope-card.active {
  border-color: #1677ff;
  background: #e6f4ff;
  box-shadow: 0 0 0 1px rgba(22, 119, 255, 0.1);
}

.scope-card-info {
  flex: 1;
  min-width: 0;
}

.scope-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 4px;
}

.scope-card.active .scope-card-title {
  color: #1677ff;
}

.scope-card-desc {
  font-size: 12px;
  color: #8c8c8c;
  line-height: 1.4;
}

.scope-card-check {
  font-size: 20px;
  color: #1677ff;
  flex-shrink: 0;
}

.step-section-subtitle {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 4px;
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

/* 总抽检数量提示 */
.total-sampling-count-tip {
  margin-bottom: 16px;
  padding: 8px 12px;
  background: #f6ffed;
  border: 1px solid #b7eb8f;
  border-radius: 4px;
  font-size: 14px;
  color: #52c41a;
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

.count-total {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}

.ratio-total.ratio-error {
  color: #ff4d4f;
}

/* 抽检条数 */
.sampling-count-value {
  font-size: 14px;
  color: #1677ff;
  font-weight: 500;
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

.quota-calc {
  font-size: 13px;
  color: #52c41a;
  margin-top: 4px;
  padding: 4px 8px;
  background: #f6ffed;
  border-radius: 4px;
  display: inline-block;
}

.sampling-query-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
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
  color: #333;
  font-size: 14px;
  font-weight: 500;
  margin: 0 0 8px;
}

/* 条件筛选区域 */
.condition-area {
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  padding: 16px 20px;
  margin-bottom: 0;
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
  padding: 16px 20px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fafafa;
}

.auto-append-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.auto-append-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
}

.auto-append-content {
  margin-top: 12px;
}

.auto-append-tip {
  font-size: 13px;
  color: #8c8c8c;
  line-height: 1.5;
  margin-bottom: 12px;
}

.auto-append-sentence {
  font-size: 14px;
  color: #262626;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px;
  line-height: 32px;
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

/* 数据去重区域 */
.dedup-section {
  margin-top: 16px;
  padding: 16px 20px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fafafa;
}

.dedup-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.dedup-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
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

/* 质检范围提示 */
.scope-tip {
  font-size: 12px;
  color: #8c8c8c;
  margin-top: 4px;
}

/* 抽检模式步骤内容 */
.step-sampling-content {
  padding: 10px 20px;
  min-height: 300px;
}

.step-section-title {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 4px;
}

.step-section-desc {
  font-size: 13px;
  color: #8c8c8c;
  margin-bottom: 20px;
}

/* 数据范围筛选 */
.data-range-filters {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 12px;
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.delete-filter-btn {
  font-size: 18px;
  color: #ff4d4f;
  flex-shrink: 0;
}

.add-filter-btn {
  margin-bottom: 16px;
}

.filter-preview {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #f0f5ff;
  border-radius: 4px;
  margin-top: 4px;
}

.filter-preview-label {
  font-size: 14px;
  color: #595959;
}

.filter-preview-count {
  font-size: 14px;
  color: #262626;
}

.filter-preview-count strong {
  color: #1677ff;
  font-weight: 600;
}

/* 抽样维度 */
.dimension-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 12px;
}

.dimension-card {
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background: #fff;
  overflow: hidden;
}

.dimension-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #f0f5ff;
  border-bottom: 1px solid #e8e8e8;
}

.dimension-card-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.dimension-index {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #1677ff;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
}

.dimension-card-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.mutual-exclusive-label {
  font-size: 12px;
  color: #8c8c8c;
}

.dimension-card-body {
  padding: 16px;
}

.dimension-config-label {
  font-size: 13px;
  color: #595959;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.inline-radio-group {
  display: inline-flex;
}

.agent-mode-radio {
  margin-bottom: 12px;
}

.dimension-table {
  margin-bottom: 8px;
}

.dimension-table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.scene-ratio-total {
  font-size: 13px;
  color: #595959;
}

.dimension-option-row {
  margin-top: 8px;
}

.range-separator {
  margin: 0 4px;
  color: #8c8c8c;
}

.range-unit {
  margin-left: 4px;
  font-size: 12px;
  color: #8c8c8c;
}

.add-dimension-btn {
  margin-bottom: 16px;
}

.estimated-total {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #f6ffed;
  border: 1px solid #b7eb8f;
  border-radius: 4px;
}

.estimated-label {
  font-size: 14px;
  color: #595959;
}

.estimated-value {
  font-size: 18px;
  font-weight: 600;
  color: #52c41a;
}

.estimated-warning {
  font-size: 13px;
  color: #ff4d4f;
  margin-left: 8px;
}

/* 通话时长饼图预览 */
.duration-chart-preview {
  margin-top: 12px;
  padding: 12px;
  background: #fafafa;
  border-radius: 4px;
}

.chart-bar-wrapper {
  display: flex;
  height: 24px;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
}

.chart-bar-segment {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  min-width: 2px;
  transition: width 0.3s;
}

.chart-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.chart-legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #595959;
}

.chart-legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.custom-dimension-placeholder {
  max-width: 300px;
}

/* 全局配额表单 */
.quota-form {
  padding: 10px 0;
}

.quota-unit {
  margin-left: 8px;
  font-size: 13px;
  color: #8c8c8c;
}

.quota-hint {
  font-size: 12px;
  color: #bfbfbf;
  margin-top: 4px;
}

.quota-error {
  font-size: 13px;
  color: #ff4d4f;
  margin-top: 4px;
  background: #fff2f0;
  padding: 4px 8px;
  border-radius: 4px;
}

/* 调度计划表单 */
.schedule-form {
  padding: 10px 0;
}

.schedule-date-range {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.date-separator {
  color: #8c8c8c;
}

.offset-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.offset-prefix,
.offset-suffix {
  font-size: 14px;
  color: #595959;
}

.offset-preview {
  margin-top: 8px;
  padding: 8px 12px;
  background: #f0f5ff;
  border-radius: 4px;
  font-size: 13px;
  color: #1677ff;
}

/* 命名与保存 */
.naming-form {
  padding: 10px 0;
}

.strategy-status-text {
  margin-left: 12px;
  font-size: 14px;
  color: #595959;
}

/* 策略概览卡片 */
.strategy-overview {
  margin-top: 16px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  overflow: hidden;
}

.overview-title {
  padding: 10px 16px;
  background: #f0f5ff;
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  border-bottom: 1px solid #e8e8e8;
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0;
}

.overview-item {
  display: flex;
  padding: 10px 16px;
  border-bottom: 1px solid #f0f0f0;
  border-right: 1px solid #f0f0f0;
}

.overview-item:nth-child(even) {
  border-right: none;
}

.overview-label {
  font-size: 13px;
  color: #8c8c8c;
  width: 80px;
  flex-shrink: 0;
}

.overview-value {
  font-size: 13px;
  color: #262626;
  font-weight: 500;
}
</style>
