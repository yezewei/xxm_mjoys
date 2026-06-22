<template>
  <div class="data-lake">
    <div class="quality-wrapper">
      <!-- Tab 切换区域 -->
      <div class="tab-section">
        <a-tabs v-model:activeKey="activeTab" :animated="false" @change="handleTabChange">
          <!-- ============ Tab 1: AI 外呼批次 ============ -->
          <a-tab-pane key="aiBatch" tab="AI 外呼批次">
            <div class="search-and-table-area">
              <div class="search-area">
                <a-form layout="vertical">
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="aiSearch.batchName" placeholder="请输入数据批次名称" allow-clear @press-enter="handleAiSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="aiSearch.callerNumber" placeholder="请输入主叫号码" allow-clear @press-enter="handleAiSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-select v-model:value="aiSearch.dataStatus" placeholder="请选择数据状态" allow-clear>
                          <a-select-option value="待确认">待确认</a-select-option>
                          <a-select-option value="已确认">已确认</a-select-option>
                          <a-select-option value="已撤回">已撤回</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="aiSearch.uploadTimeRange" style="width: 100%" allow-clear :placeholder="['上传开始时间', '上传结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="aiSearch.executeTimeRange" style="width: 100%" allow-clear :placeholder="['执行开始时间', '执行结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-space class="search-btn-space">
                          <a-button @click="handleAiReset"><reload-outlined />重置</a-button>
                          <a-button type="primary" @click="handleAiSearch"><search-outlined />搜索</a-button>
                        </a-space>
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>

              <div class="table-toolbar">
                <div class="table-toolbar-left">
                  <span class="selection-info">共 {{ aiTotal }} 条，已选 {{ aiSelectedKeys.length }} 条</span>
                </div>
                <div class="table-toolbar-right">
                  <a-button @click="openExportModal('ai')"><file-excel-outlined />导出 Excel</a-button>
                  <a-button style="margin-left: 12px" @click="showColumnSetting('ai')"><setting-outlined />列表显示设置</a-button>
                </div>
              </div>

              <div class="table-area">
                <div class="table-wrapper">
                  <a-table
                    :columns="aiVisibleColumns"
                    :data-source="aiDataSource"
                    :pagination="false"
                    :loading="aiLoading"
                    row-key="id"
                    :row-selection="{ selectedRowKeys: aiSelectedKeys, onChange: (keys: string[]) => { aiSelectedKeys = keys } }"
                    :scroll="{ x: 2000 }"
                    @change="(pag: any) => { aiPagination.current = pag.current; aiPagination.pageSize = pag.pageSize; loadAiData() }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'batchName'">
                        <a class="batch-link">{{ record.batchName }}</a>
                      </template>
                      <template v-else-if="column.key === 'totalNum'">
                        <span style="font-weight: 500;">{{ record.totalNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'validNum'">
                        <span style="color: #52c41a;">{{ record.validNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'invalidNum'">
                        <span :style="{ color: record.invalidNum > 0 ? '#ff4d4f' : '#999' }">{{ record.invalidNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'dataStatus'">
                        <a-tag :color="record.dataStatus === '已确认' ? 'green' : record.dataStatus === '待确认' ? 'orange' : 'default'">
                          {{ record.dataStatus }}
                        </a-tag>
                      </template>
                      <template v-else-if="column.key === 'progress'">
                        <a-progress :percent="record.progress" :size="'small'" :status="record.progress === 100 ? 'success' : 'active'" />
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-space>
                          <a-button type="link" size="small">查看详情</a-button>
                          <a-button type="link" size="small" v-if="record.dataStatus === '待确认'" style="color: #52c41a;">确认</a-button>
                          <a-button type="link" size="small" v-if="record.dataStatus === '已确认'" style="color: #faad14;">撤回</a-button>
                        </a-space>
                      </template>
                    </template>
                  </a-table>
                </div>
                <Pagination v-model:current="aiPagination.current" v-model:page-size="aiPagination.pageSize" :total="aiPagination.total" @change="loadAiData" />
              </div>
            </div>
          </a-tab-pane>

          <!-- ============ Tab 2: 人工外呼批次 ============ -->
          <a-tab-pane key="manualBatch" tab="人工外呼批次">
            <div class="search-and-table-area">
              <div class="search-area">
                <a-form layout="vertical">
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="manualSearch.batchName" placeholder="请输入数据批次名称" allow-clear @press-enter="handleManualSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="manualSearch.seatName" placeholder="请输入坐席名称" allow-clear @press-enter="handleManualSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-select v-model:value="manualSearch.taskStatus" placeholder="请选择任务状态" allow-clear>
                          <a-select-option value="待执行">待执行</a-select-option>
                          <a-select-option value="执行中">执行中</a-select-option>
                          <a-select-option value="已完成">已完成</a-select-option>
                          <a-select-option value="已取消">已取消</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="manualSearch.uploadTimeRange" style="width: 100%" allow-clear :placeholder="['上传开始时间', '上传结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="manualSearch.executeTimeRange" style="width: 100%" allow-clear :placeholder="['执行开始时间', '执行结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-space class="search-btn-space">
                          <a-button @click="handleManualReset"><reload-outlined />重置</a-button>
                          <a-button type="primary" @click="handleManualSearch"><search-outlined />搜索</a-button>
                        </a-space>
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>

              <div class="table-toolbar">
                <div class="table-toolbar-left">
                  <span class="selection-info">共 {{ manualTotal }} 条，已选 {{ manualSelectedKeys.length }} 条</span>
                </div>
                <div class="table-toolbar-right">
                  <a-button @click="openExportModal('manual')"><file-excel-outlined />导出 Excel</a-button>
                  <a-button style="margin-left: 12px" @click="showColumnSetting('manual')"><setting-outlined />列表显示设置</a-button>
                </div>
              </div>

              <div class="table-area">
                <div class="table-wrapper">
                  <a-table
                    :columns="manualVisibleColumns"
                    :data-source="manualDataSource"
                    :pagination="false"
                    :loading="manualLoading"
                    row-key="id"
                    :row-selection="{ selectedRowKeys: manualSelectedKeys, onChange: (keys: string[]) => { manualSelectedKeys = keys } }"
                    :scroll="{ x: 2200 }"
                    @change="(pag: any) => { manualPagination.current = pag.current; manualPagination.pageSize = pag.pageSize; loadManualData() }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'batchName'">
                        <a class="batch-link">{{ record.batchName }}</a>
                      </template>
                      <template v-else-if="column.key === 'totalNum'">
                        <span style="font-weight: 500;">{{ record.totalNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'completedNum'">
                        <span style="color: #52c41a;">{{ record.completedNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'pendingNum'">
                        <span :style="{ color: record.pendingNum > 0 ? '#faad14' : '#999' }">{{ record.pendingNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'invalidNum'">
                        <span :style="{ color: record.invalidNum > 0 ? '#ff4d4f' : '#999' }">{{ record.invalidNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'taskStatus'">
                        <a-badge :status="record.taskStatus === '已完成' ? 'success' : record.taskStatus === '执行中' ? 'processing' : record.taskStatus === '待执行' ? 'warning' : 'default'" :text="record.taskStatus" />
                      </template>
                      <template v-else-if="column.key === 'completionRate'">
                        <a-progress :percent="record.completionRate" :size="'small'" :stroke-color="record.completionRate === 100 ? '#52c41a' : '#1890ff'" />
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-space>
                          <a-button type="link" size="small">查看详情</a-button>
                          <a-button type="link" size="small" v-if="record.taskStatus === '待执行'" style="color: #52c41a;">分配坐席</a-button>
                          <a-button type="link" size="small" v-if="record.taskStatus === '待执行'" style="color: #ff4d4f;">取消</a-button>
                        </a-space>
                      </template>
                    </template>
                  </a-table>
                </div>
                <Pagination v-model:current="manualPagination.current" v-model:page-size="manualPagination.pageSize" :total="manualPagination.total" @change="loadManualData" />
              </div>
            </div>
          </a-tab-pane>

          <!-- ============ Tab 3: 待绑定批次 ============ -->
          <a-tab-pane key="pendingBind" tab="待绑定批次">
            <div class="search-and-table-area">
              <div class="search-area">
                <a-form layout="vertical">
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="pendingSearch.batchName" placeholder="请输入数据批次名称" allow-clear @press-enter="handlePendingSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="pendingSearch.uploader" placeholder="请输入上传人" allow-clear @press-enter="handlePendingSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-select v-model:value="pendingSearch.bindStatus" placeholder="请选择绑定状态" allow-clear>
                          <a-select-option value="待绑定">待绑定</a-select-option>
                          <a-select-option value="已绑定">已绑定</a-select-option>
                          <a-select-option value="已过期">已过期</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="pendingSearch.uploadTimeRange" style="width: 100%" allow-clear :placeholder="['上传开始时间', '上传结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="pendingSearch.expireTimeRange" style="width: 100%" allow-clear :placeholder="['过期开始时间', '过期结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-space class="search-btn-space">
                          <a-button @click="handlePendingReset"><reload-outlined />重置</a-button>
                          <a-button type="primary" @click="handlePendingSearch"><search-outlined />搜索</a-button>
                        </a-space>
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>

              <div class="table-toolbar">
                <div class="table-toolbar-left">
                  <span class="selection-info">共 {{ pendingTotal }} 条，已选 {{ pendingSelectedKeys.length }} 条</span>
                </div>
                <div class="table-toolbar-right">
                  <a-button @click="openExportModal('pending')"><file-excel-outlined />导出 Excel</a-button>
                  <a-button style="margin-left: 12px" @click="showColumnSetting('pending')"><setting-outlined />列表显示设置</a-button>
                </div>
              </div>

              <div class="table-area">
                <div class="table-wrapper">
                  <a-table
                    :columns="pendingVisibleColumns"
                    :data-source="pendingDataSource"
                    :pagination="false"
                    :loading="pendingLoading"
                    row-key="id"
                    :row-selection="{ selectedRowKeys: pendingSelectedKeys, onChange: (keys: string[]) => { pendingSelectedKeys = keys } }"
                    :scroll="{ x: 1800 }"
                    @change="(pag: any) => { pendingPagination.current = pag.current; pendingPagination.pageSize = pag.pageSize; loadPendingData() }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'batchName'">
                        <a class="batch-link">{{ record.batchName }}</a>
                      </template>
                      <template v-else-if="column.key === 'totalNum'">
                        <span style="font-weight: 500;">{{ record.totalNum }}</span>
                      </template>
                      <template v-else-if="column.key === 'bindStatus'">
                        <a-tag :color="record.bindStatus === '待绑定' ? 'orange' : record.bindStatus === '已绑定' ? 'green' : 'default'">
                          {{ record.bindStatus }}
                        </a-tag>
                      </template>
                      <template v-else-if="column.key === 'expireTime'">
                        <span :style="{ color: isExpired(record.expireTime) ? '#ff4d4f' : '#333' }">{{ record.expireTime }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-space>
                          <a-button type="link" size="small">查看详情</a-button>
                          <a-button type="link" size="small" v-if="record.bindStatus === '待绑定'" style="color: #1890ff;">绑定任务</a-button>
                          <a-button type="link" size="small" v-if="record.bindStatus === '待绑定'" style="color: #fa8c16;">导出数据</a-button>
                        </a-space>
                      </template>
                    </template>
                  </a-table>
                </div>
                <Pagination v-model:current="pendingPagination.current" v-model:page-size="pendingPagination.pageSize" :total="pendingPagination.total" @change="loadPendingData" />
              </div>
            </div>
          </a-tab-pane>

          <!-- ============ Tab 4: 上传失败批次 ============ -->
          <a-tab-pane key="uploadFailed" tab="上传失败批次">
            <div class="search-and-table-area">
              <div class="search-area">
                <a-form layout="vertical">
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="failedSearch.batchName" placeholder="请输入数据批次名称" allow-clear @press-enter="handleFailedSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="failedSearch.uploader" placeholder="请输入上传人" allow-clear @press-enter="handleFailedSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-select v-model:value="failedSearch.errorType" placeholder="请选择错误类型" allow-clear>
                          <a-select-option value="格式错误">格式错误</a-select-option>
                          <a-select-option value="字段缺失">字段缺失</a-select-option>
                          <a-select-option value="号码无效">号码无效</a-select-option>
                          <a-select-option value="数据重复">数据重复</a-select-option>
                          <a-select-option value="文件超大">文件超大</a-select-option>
                          <a-select-option value="编码异常">编码异常</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="failedSearch.uploadTimeRange" style="width: 100%" allow-clear :placeholder="['上传开始时间', '上传结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-space class="search-btn-space">
                          <a-button @click="handleFailedReset"><reload-outlined />重置</a-button>
                          <a-button type="primary" @click="handleFailedSearch"><search-outlined />搜索</a-button>
                        </a-space>
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>

              <div class="table-toolbar">
                <div class="table-toolbar-left">
                  <span class="selection-info">共 {{ failedTotal }} 条，已选 {{ failedSelectedKeys.length }} 条</span>
                </div>
                <div class="table-toolbar-right">
                  <a-button @click="openExportModal('failed')"><file-excel-outlined />导出 Excel</a-button>
                  <a-button style="margin-left: 12px" @click="showColumnSetting('failed')"><setting-outlined />列表显示设置</a-button>
                </div>
              </div>

              <div class="table-area">
                <div class="table-wrapper">
                  <a-table
                    :columns="failedVisibleColumns"
                    :data-source="failedDataSource"
                    :pagination="false"
                    :loading="failedLoading"
                    row-key="id"
                    :row-selection="{ selectedRowKeys: failedSelectedKeys, onChange: (keys: string[]) => { failedSelectedKeys = keys } }"
                    :scroll="{ x: 1800 }"
                    @change="(pag: any) => { failedPagination.current = pag.current; failedPagination.pageSize = pag.pageSize; loadFailedData() }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'batchName'">
                        <a class="batch-link">{{ record.batchName }}</a>
                      </template>
                      <template v-else-if="column.key === 'errorType'">
                        <a-tag color="red">{{ record.errorType }}</a-tag>
                      </template>
                      <template v-else-if="column.key === 'errorDetail'">
                        <a-tooltip placement="topLeft">
                          <template #title>
                            <span>{{ record.errorDetail }}</span>
                          </template>
                          <span class="error-detail-text">{{ record.errorDetail }}</span>
                        </a-tooltip>
                      </template>
                      <template v-else-if="column.key === 'retryCount'">
                        <span :style="{ color: record.retryCount >= 3 ? '#ff4d4f' : '#333' }">{{ record.retryCount }}</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <a-space>
                          <a-button type="link" size="small">查看详情</a-button>
                          <a-button type="link" size="small" style="color: #fa8c16;">重新上传</a-button>
                          <a-button type="link" size="small" style="color: #ff4d4f;">删除</a-button>
                        </a-space>
                      </template>
                    </template>
                  </a-table>
                </div>
                <Pagination v-model:current="failedPagination.current" v-model:page-size="failedPagination.pageSize" :total="failedPagination.total" @change="loadFailedData" />
              </div>
            </div>
          </a-tab-pane>

          <!-- ============ Tab 5: 免打扰名单 ============ -->
          <a-tab-pane key="dnd" tab="免打扰名单">
            <div class="search-and-table-area">
              <div class="search-area">
                <a-form layout="vertical">
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="dndSearch.phoneNumber" placeholder="请输入手机号码" allow-clear @press-enter="handleDndSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-select v-model:value="dndSearch.addMethod" placeholder="请选择添加方式" allow-clear>
                          <a-select-option value="手动添加">手动添加</a-select-option>
                          <a-select-option value="批量导入">批量导入</a-select-option>
                          <a-select-option value="系统自动">系统自动</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-select v-model:value="dndSearch.source" placeholder="请选择来源" allow-clear>
                          <a-select-option value="API上传">API上传</a-select-option>
                          <a-select-option value="AI外呼">AI外呼</a-select-option>
                          <a-select-option value="手动创建">手动创建</a-select-option>
                          <a-select-option value="批量导入">批量导入</a-select-option>
                          <a-select-option value="工作台添加">工作台添加</a-select-option>
                        </a-select>
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="dndSearch.sourceReason" placeholder="请输入来源原因" allow-clear @press-enter="handleDndSearch" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="dndSearch.orgName" placeholder="请输入机构名称" allow-clear @press-enter="handleDndSearch" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="dndSearch.addTimeRange" style="width: 100%" allow-clear :placeholder="['添加开始时间', '添加结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-range-picker v-model:value="dndSearch.releaseTimeRange" style="width: 100%" allow-clear :placeholder="['解除开始时间', '解除结束时间']" show-time format="YYYY-MM-DD HH:mm:ss" />
                      </a-form-item>
                    </a-col>
                    <a-col :span="6">
                      <a-form-item>
                        <a-input v-model:value="dndSearch.remark" placeholder="请输入备注关键词" allow-clear @press-enter="handleDndSearch" />
                      </a-form-item>
                    </a-col>
                  </a-row>
                  <a-row :gutter="16">
                    <a-col :span="6">
                      <a-form-item>
                        <a-space class="search-btn-space">
                          <a-button @click="handleDndReset"><reload-outlined />重置</a-button>
                          <a-button type="primary" @click="handleDndSearch"><search-outlined />搜索</a-button>
                        </a-space>
                      </a-form-item>
                    </a-col>
                  </a-row>
                </a-form>
              </div>

              <div class="table-toolbar">
                <div class="table-toolbar-left">
                  <span class="selection-info">共 {{ dndTotal }} 条，已选 {{ dndSelectedKeys.length }} 条</span>
                  <a-popconfirm title="确定批量删除选中的免打扰记录吗？" @confirm="handleDndBatchRemove" ok-text="确定" cancel-text="取消">
                    <a-button type="primary" danger style="margin-left: 12px;" :disabled="dndSelectedKeys.length === 0">
                      <delete-outlined />
                      批量删除
                    </a-button>
                  </a-popconfirm>
                  <a-upload :show-upload-list="false" accept=".xlsx,.xls,.csv" :before-upload="handleDndImport" style="display: inline-block; margin-left: 12px;">
                    <a-button>
                      <import-outlined />
                      导入免打扰名单
                    </a-button>
                  </a-upload>
                  <a-button style="margin-left: 12px;" @click="handleDndExport">
                    <file-excel-outlined />
                    导出免打扰名单
                  </a-button>
                </div>
                <div class="table-toolbar-right">
                  <a-button @click="showColumnSetting('dnd')"><setting-outlined />列表显示设置</a-button>
                </div>
              </div>

              <div class="table-area">
                <div class="table-wrapper">
                  <a-table
                    :columns="dndVisibleColumns"
                    :data-source="dndDataSource"
                    :pagination="false"
                    :loading="dndLoading"
                    row-key="id"
                    :row-selection="{ selectedRowKeys: dndSelectedKeys, onChange: (keys: string[]) => { dndSelectedKeys = keys } }"
                    :scroll="{ x: 2000 }"
                    @change="(pag: any) => { dndPagination.current = pag.current; dndPagination.pageSize = pag.pageSize; loadDndData() }"
                  >
                    <template #bodyCell="{ column, record }">
                      <template v-if="column.key === 'phoneNumber'">
                        <span style="font-family: monospace;">{{ record.phoneNumber }}</span>
                      </template>
                      <template v-else-if="column.key === 'source'">
                        <a-tag :color="record.source === 'AI外呼' ? 'blue' : record.source === 'API上传' ? 'purple' : record.source === '批量导入' ? 'cyan' : record.source === '工作台添加' ? 'green' : 'orange'">
                          {{ record.source }}
                        </a-tag>
                      </template>
                      <template v-else-if="column.key === 'sourceReason'">
                        <span>{{ record.sourceReason }}</span>
                      </template>
                      <template v-else-if="column.key === 'addMethod'">
                        <a-tag :color="record.addMethod === '手动添加' ? 'green' : record.addMethod === '批量导入' ? 'blue' : 'orange'">
                          {{ record.addMethod }}
                        </a-tag>
                      </template>
                      <template v-else-if="column.key === 'orgName'">
                        <span>{{ record.orgName }}</span>
                      </template>
                      <template v-else-if="column.key === 'approvalStatus'">
                        <a-tag :color="record.approvalStatus === '审批通过' ? 'green' : record.approvalStatus === '审批不通过' ? 'red' : 'orange'">
                          {{ record.approvalStatus }}
                        </a-tag>
                      </template>
                      <template v-else-if="column.key === 'releaseTime'">
                        <span :style="{ color: record.releaseTime === '永久' ? '#ff4d4f' : '' }">{{ record.releaseTime }}</span>
                      </template>
                      <template v-else-if="column.key === 'remark'">
                        <a-tooltip v-if="record.remark" placement="topLeft">
                          <template #title><span>{{ record.remark }}</span></template>
                          <span class="remark-text">{{ record.remark }}</span>
                        </a-tooltip>
                        <span v-else style="color: #ccc;">-</span>
                      </template>
                      <template v-else-if="column.key === 'action'">
                        <div style="display: flex; align-items: center; gap: 4px; white-space: nowrap;">
                          <a-button type="link" size="small">查看外呼记录</a-button>
                          <a-button type="link" size="small">编辑</a-button>
                          <a-popconfirm title="确定删除该免打扰记录吗？" @confirm="handleDndRemove(record)" ok-text="确定" cancel-text="取消">
                            <a-button type="link" size="small" style="color: #ff4d4f;">删除</a-button>
                          </a-popconfirm>
                          <a-button type="link" size="small" style="color: #1890ff;" @click="handleDndApproval(record)">
                            {{ record.approvalStatus === '待审批' ? '审批' : '修改审批结果' }}
                          </a-button>
                        </div>
                      </template>
                    </template>
                  </a-table>
                </div>
                <Pagination v-model:current="dndPagination.current" v-model:page-size="dndPagination.pageSize" :total="dndPagination.total" @change="loadDndData" />
              </div>
            </div>
          </a-tab-pane>
        </a-tabs>
      </div>
    </div>

    <!-- 列设置弹窗 -->
    <ColumnSettingModal
      ref="columnSettingModalRef"
      :page-key="`data-lake-${activeTab}`"
      :default-columns="currentSettingColumns"
      @save="handleColumnSave"
      @cancel="handleColumnCancel"
    />

    <!-- 导出字段选择弹窗 -->
    <a-modal
      v-model:open="exportModalVisible"
      title="导出 Excel"
      width="500px"
      ok-text="导出"
      cancel-text="取消"
      @ok="handleExportExcel"
    >
      <a-alert type="info" show-icon style="margin-bottom: 16px" message="请选择需要导出的字段" />
      <div style="margin-bottom: 12px;">
        <a-checkbox
          :checked="exportFieldKeys.length === exportFieldOptions.length"
          :indeterminate="exportFieldKeys.length > 0 && exportFieldKeys.length < exportFieldOptions.length"
          @change="handleExportCheckAll"
        >全选</a-checkbox>
      </div>
      <a-checkbox-group
        v-model:value="exportFieldKeys"
        :options="exportFieldOptions"
        style="display: flex; flex-direction: column; gap: 8px;"
      />
    </a-modal>

    <!-- 审批弹窗 -->
    <a-modal
      v-model:open="approvalModalVisible"
      title="审批操作"
      width="420px"
      :footer="null"
    >
      <div style="text-align: center; padding: 20px 0;">
        <p style="margin-bottom: 20px; font-size: 15px;">请对 <b>{{ approvalRecord?.phoneNumber }}</b> 的免打扰申请选择审批结果</p>
        <a-space size="large">
          <a-button type="primary" @click="handleApprovalResult('审批通过')">审批通过</a-button>
          <a-button danger @click="handleApprovalResult('审批不通过')">审批不通过</a-button>
        </a-space>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  SettingOutlined,
  FileExcelOutlined,
  DeleteOutlined,
  ImportOutlined,
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { Dayjs } from 'dayjs';
import Pagination from '@/components/Pagination';
import ColumnSettingModal from '../components/ColumnSettingModal.vue';
import type { ColumnConfigItem } from '../utils/columnConfig';
import * as XLSX from 'xlsx';

// ============================================================
// 通用工具函数
// ============================================================
const formatNum = (num: number): string => {
  if (num >= 10000) return (num / 10000).toFixed(1) + '万';
  return String(num);
};

const isExpired = (dateStr: string): boolean => {
  return new Date(dateStr).getTime() < Date.now();
};

// ============================================================
// Tab 状态
// ============================================================
const activeTab = ref('aiBatch');

const handleTabChange = () => {
  const loadMap: Record<string, () => void> = {
    aiBatch: loadAiData,
    manualBatch: loadManualData,
    pendingBind: loadPendingData,
    failedBatch: loadFailedData,
    dnd: loadDndData,
  };
  loadMap[activeTab.value]?.();
};

// ============================================================
// Tab 1: AI 外呼批次
// ============================================================
interface AiBatchItem {
  id: string;
  batchName: string;
  callerNumber: string;
  totalNum: number;
  validNum: number;
  invalidNum: number;
  dataStatus: string;
  progress: number;
  uploadTime: string;
  executeStartTime: string;
  uploader: string;
  scene: string;
}

const aiSearch = reactive({
  batchName: '',
  callerNumber: '',
  dataStatus: undefined as string | undefined,
  uploadTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  executeTimeRange: undefined as [Dayjs, Dayjs] | undefined,
});

const aiDataSource = ref<AiBatchItem[]>([]);
const aiTotal = ref(0);
const aiLoading = ref(false);
const aiSelectedKeys = ref<string[]>([]);
const aiPagination = reactive({ current: 1, pageSize: 10, total: 0 });

const allAiColumns: ColumnConfigItem[] = [
  { key: 'id', title: '批次编号', dataIndex: 'id', width: 180, visible: true, order: 0 },
  { key: 'batchName', title: '数据批次名称', dataIndex: 'batchName', width: 220, visible: true, order: 1 },
  { key: 'scene', title: '外呼场景', dataIndex: 'scene', width: 130, visible: true, order: 2 },
  { key: 'callerNumber', title: '主叫号码', dataIndex: 'callerNumber', width: 140, visible: true, order: 3 },
  { key: 'totalNum', title: '数据总数', dataIndex: 'totalNum', width: 100, visible: true, order: 4 },
  { key: 'validNum', title: '有效数据', dataIndex: 'validNum', width: 100, visible: true, order: 5 },
  { key: 'invalidNum', title: '无效数据', dataIndex: 'invalidNum', width: 100, visible: true, order: 6 },
  { key: 'dataStatus', title: '数据状态', dataIndex: 'dataStatus', width: 100, visible: true, order: 7 },
  { key: 'progress', title: '执行进度', dataIndex: 'progress', width: 150, visible: true, order: 8 },
  { key: 'uploadTime', title: '上传时间', dataIndex: 'uploadTime', width: 180, visible: true, order: 9 },
  { key: 'executeStartTime', title: '执行时间', dataIndex: 'executeStartTime', width: 180, visible: true, order: 10 },
  { key: 'uploader', title: '上传人', dataIndex: 'uploader', width: 100, visible: true, order: 11 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 200, visible: true, order: 12 },
];

const aiColumnConfig = ref<ColumnConfigItem[]>([]);
const aiVisibleColumns = computed(() => {
  const cols = aiColumnConfig.value.length > 0 ? aiColumnConfig.value : allAiColumns;
  return cols
    .filter(c => c.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(c => ({
      title: c.title,
      dataIndex: c.dataIndex,
      key: c.key,
      width: c.width,
      align: c.key === 'action' ? 'center' as const : undefined,
      fixed: c.key === 'action' ? 'right' as const : undefined,
    }));
});

const loadAiData = () => {
  aiLoading.value = true;
  setTimeout(() => {
    const scenes = ['贷款转存', '信用卡营销', '理财推荐', '客户回访'];
    const statuses = ['待确认', '已确认', '已撤回'];
    aiDataSource.value = Array.from({ length: 12 }, (_, i) => ({
      id: `AI-BAT-${String(i + 1).padStart(5, '0')}`,
      batchName: `批次-${scenes[i % 4]}-2026050${(i % 9) + 1}`,
      callerNumber: `0571-8888${String(1000 + i).slice(1)}`,
      totalNum: 500 + i * 100,
      validNum: 480 + i * 95,
      invalidNum: 20 + i * 5,
      dataStatus: statuses[i % 3],
      progress: [100, 100, 78, 45, 100, 0, 100, 60, 30, 100, 90, 50][i],
      uploadTime: `2026-05-${String(1 + i).padStart(2, '0')} 09:${String(30 + i).padStart(2, '0')}:00`,
      executeStartTime: i >= 5 ? '-' : `2026-05-${String(1 + i).padStart(2, '0')} 10:00:00`,
      uploader: ['张三', '李四', '王五', '赵六'][i % 4],
      scene: scenes[i % 4],
    }));
    aiTotal.value = 120;
    aiPagination.total = 120;
    aiLoading.value = false;
  }, 400);
};

const handleAiSearch = () => { aiPagination.current = 1; loadAiData(); message.success('搜索成功'); };
const handleAiReset = () => {
  aiSearch.batchName = '';
  aiSearch.callerNumber = '';
  aiSearch.dataStatus = undefined;
  aiSearch.uploadTimeRange = undefined;
  aiSearch.executeTimeRange = undefined;
  aiPagination.current = 1;
  loadAiData();
  message.success('重置成功');
};

// ============================================================
// Tab 2: 人工外呼批次
// ============================================================
interface ManualBatchItem {
  id: string;
  batchName: string;
  seatName: string;
  totalNum: number;
  completedNum: number;
  pendingNum: number;
  invalidNum: number;
  taskStatus: string;
  completionRate: number;
  uploadTime: string;
  executeStartTime: string;
  scene: string;
  uploader: string;
}

const manualSearch = reactive({
  batchName: '',
  seatName: '',
  taskStatus: undefined as string | undefined,
  uploadTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  executeTimeRange: undefined as [Dayjs, Dayjs] | undefined,
});

const manualDataSource = ref<ManualBatchItem[]>([]);
const manualTotal = ref(0);
const manualLoading = ref(false);
const manualSelectedKeys = ref<string[]>([]);
const manualPagination = reactive({ current: 1, pageSize: 10, total: 0 });

const allManualColumns: ColumnConfigItem[] = [
  { key: 'id', title: '批次编号', dataIndex: 'id', width: 180, visible: true, order: 0 },
  { key: 'batchName', title: '数据批次名称', dataIndex: 'batchName', width: 220, visible: true, order: 1 },
  { key: 'scene', title: '外呼场景', dataIndex: 'scene', width: 130, visible: true, order: 2 },
  { key: 'seatName', title: '执行坐席', dataIndex: 'seatName', width: 120, visible: true, order: 3 },
  { key: 'totalNum', title: '数据总数', dataIndex: 'totalNum', width: 100, visible: true, order: 4 },
  { key: 'completedNum', title: '已完成', dataIndex: 'completedNum', width: 90, visible: true, order: 5 },
  { key: 'pendingNum', title: '待执行', dataIndex: 'pendingNum', width: 90, visible: true, order: 6 },
  { key: 'invalidNum', title: '无效数据', dataIndex: 'invalidNum', width: 100, visible: true, order: 7 },
  { key: 'taskStatus', title: '任务状态', dataIndex: 'taskStatus', width: 110, visible: true, order: 8 },
  { key: 'completionRate', title: '完成率', dataIndex: 'completionRate', width: 140, visible: true, order: 9 },
  { key: 'uploadTime', title: '上传时间', dataIndex: 'uploadTime', width: 180, visible: true, order: 10 },
  { key: 'executeStartTime', title: '执行时间', dataIndex: 'executeStartTime', width: 180, visible: true, order: 11 },
  { key: 'uploader', title: '上传人', dataIndex: 'uploader', width: 100, visible: true, order: 12 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 180, visible: true, order: 13 },
];

const manualColumnConfig = ref<ColumnConfigItem[]>([]);
const manualVisibleColumns = computed(() => {
  const cols = manualColumnConfig.value.length > 0 ? manualColumnConfig.value : allManualColumns;
  return cols
    .filter(c => c.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(c => ({
      title: c.title,
      dataIndex: c.dataIndex,
      key: c.key,
      width: c.width,
      align: c.key === 'action' ? 'center' as const : undefined,
      fixed: c.key === 'action' ? 'right' as const : undefined,
    }));
});

const loadManualData = () => {
  manualLoading.value = true;
  setTimeout(() => {
    const scenes = ['贷款转存', '信用卡营销', '理财推荐', '客户回访'];
    const statuses = ['待执行', '执行中', '已完成', '已取消'];
    const seats = ['张伟', '王芳', '刘洋', '陈静', '周磊'];
    manualDataSource.value = Array.from({ length: 10 }, (_, i) => {
      const total = 200 + i * 50;
      const completed = Math.floor(total * [0, 0.3, 0.6, 1, 0.8, 0, 0.1, 0.45, 1, 0.7][i]);
      return {
        id: `MA-BAT-${String(i + 1).padStart(5, '0')}`,
        batchName: `人工批次-${scenes[i % 4]}-202605${String(10 + i).padStart(2, '0')}`,
        seatName: seats[i % 5],
        totalNum: total,
        completedNum: completed,
        pendingNum: total - completed - Math.floor(total * 0.05),
        invalidNum: Math.floor(total * 0.05),
        taskStatus: statuses[i % 4],
        completionRate: Math.round((completed / total) * 100),
        uploadTime: `2026-05-${String(10 + i).padStart(2, '0')} 14:00:00`,
        executeStartTime: i >= 6 ? '-' : `2026-05-${String(10 + i).padStart(2, '0')} 15:00:00`,
        scene: scenes[i % 4],
        uploader: ['张三', '李四', '王五'][i % 3],
      };
    });
    manualTotal.value = 96;
    manualPagination.total = 96;
    manualLoading.value = false;
  }, 400);
};

const handleManualSearch = () => { manualPagination.current = 1; loadManualData(); message.success('搜索成功'); };
const handleManualReset = () => {
  manualSearch.batchName = '';
  manualSearch.seatName = '';
  manualSearch.taskStatus = undefined;
  manualSearch.uploadTimeRange = undefined;
  manualSearch.executeTimeRange = undefined;
  manualPagination.current = 1;
  loadManualData();
  message.success('重置成功');
};

// ============================================================
// Tab 3: 待绑定批次
// ============================================================
interface PendingBindItem {
  id: string;
  batchName: string;
  totalNum: number;
  bindStatus: string;
  uploadTime: string;
  expireTime: string;
  uploader: string;
  dataSource: string;
  remark: string;
}

const pendingSearch = reactive({
  batchName: '',
  uploader: '',
  bindStatus: undefined as string | undefined,
  uploadTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  expireTimeRange: undefined as [Dayjs, Dayjs] | undefined,
});

const pendingDataSource = ref<PendingBindItem[]>([]);
const pendingTotal = ref(0);
const pendingLoading = ref(false);
const pendingSelectedKeys = ref<string[]>([]);
const pendingPagination = reactive({ current: 1, pageSize: 10, total: 0 });

const allPendingColumns: ColumnConfigItem[] = [
  { key: 'id', title: '批次编号', dataIndex: 'id', width: 180, visible: true, order: 0 },
  { key: 'batchName', title: '数据批次名称', dataIndex: 'batchName', width: 220, visible: true, order: 1 },
  { key: 'totalNum', title: '数据总数', dataIndex: 'totalNum', width: 100, visible: true, order: 2 },
  { key: 'bindStatus', title: '绑定状态', dataIndex: 'bindStatus', width: 100, visible: true, order: 3 },
  { key: 'dataSource', title: '数据来源', dataIndex: 'dataSource', width: 130, visible: true, order: 4 },
  { key: 'uploadTime', title: '上传时间', dataIndex: 'uploadTime', width: 180, visible: true, order: 5 },
  { key: 'expireTime', title: '过期时间', dataIndex: 'expireTime', width: 180, visible: true, order: 6 },
  { key: 'uploader', title: '上传人', dataIndex: 'uploader', width: 100, visible: true, order: 7 },
  { key: 'remark', title: '备注', dataIndex: 'remark', width: 200, visible: true, order: 8 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 200, visible: true, order: 9 },
];

const pendingColumnConfig = ref<ColumnConfigItem[]>([]);
const pendingVisibleColumns = computed(() => {
  const cols = pendingColumnConfig.value.length > 0 ? pendingColumnConfig.value : allPendingColumns;
  return cols
    .filter(c => c.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(c => ({
      title: c.title,
      dataIndex: c.dataIndex,
      key: c.key,
      width: c.width,
      align: c.key === 'action' ? 'center' as const : undefined,
      fixed: c.key === 'action' ? 'right' as const : undefined,
    }));
});

const loadPendingData = () => {
  pendingLoading.value = true;
  setTimeout(() => {
    const statuses = ['待绑定', '待绑定', '已绑定', '已过期'];
    const sources = ['客户申请', '系统标记', '人工添加'];
    pendingDataSource.value = Array.from({ length: 8 }, (_, i) => ({
      id: `PB-BAT-${String(i + 1).padStart(5, '0')}`,
      batchName: `待绑定批次-${String(i + 1).padStart(3, '0')}`,
      totalNum: 300 + i * 60,
      bindStatus: statuses[i % 4],
      dataSource: sources[i % 3],
      uploadTime: `2026-05-${String(5 + i).padStart(2, '0')} 16:00:00`,
      expireTime: i >= 6 ? `2026-06-${String(1 + i).padStart(2, '0')} 00:00:00` : `2026-05-${String(20 + i).padStart(2, '0')} 00:00:00`,
      uploader: ['王芳', '刘洋', '陈静'][i % 3],
      remark: i === 0 ? '来自外部渠道导入的客户数据' : i === 3 ? '季度营销活动数据包' : '',
    }));
    pendingTotal.value = 65;
    pendingPagination.total = 65;
    pendingLoading.value = false;
  }, 400);
};

const handlePendingSearch = () => { pendingPagination.current = 1; loadPendingData(); message.success('搜索成功'); };
const handlePendingReset = () => {
  pendingSearch.batchName = '';
  pendingSearch.uploader = '';
  pendingSearch.bindStatus = undefined;
  pendingSearch.uploadTimeRange = undefined;
  pendingSearch.expireTimeRange = undefined;
  pendingPagination.current = 1;
  loadPendingData();
  message.success('重置成功');
};

// ============================================================
// Tab 4: 上传失败批次
// ============================================================
interface FailedBatchItem {
  id: string;
  batchName: string;
  fileName: string;
  errorType: string;
  errorDetail: string;
  uploadTime: string;
  uploader: string;
  fileSize: string;
  retryCount: number;
}

const failedSearch = reactive({
  batchName: '',
  uploader: '',
  errorType: undefined as string | undefined,
  uploadTimeRange: undefined as [Dayjs, Dayjs] | undefined,
});

const failedDataSource = ref<FailedBatchItem[]>([]);
const failedTotal = ref(0);
const failedLoading = ref(false);
const failedSelectedKeys = ref<string[]>([]);
const failedPagination = reactive({ current: 1, pageSize: 10, total: 0 });

const allFailedColumns: ColumnConfigItem[] = [
  { key: 'id', title: '批次编号', dataIndex: 'id', width: 180, visible: true, order: 0 },
  { key: 'batchName', title: '数据批次名称', dataIndex: 'batchName', width: 220, visible: true, order: 1 },
  { key: 'fileName', title: '上传文件名', dataIndex: 'fileName', width: 200, visible: true, order: 2 },
  { key: 'errorType', title: '错误类型', dataIndex: 'errorType', width: 110, visible: true, order: 3 },
  { key: 'errorDetail', title: '错误详情', dataIndex: 'errorDetail', width: 260, visible: true, order: 4 },
  { key: 'fileSize', title: '文件大小', dataIndex: 'fileSize', width: 100, visible: true, order: 5 },
  { key: 'uploadTime', title: '上传时间', dataIndex: 'uploadTime', width: 180, visible: true, order: 6 },
  { key: 'uploader', title: '上传人', dataIndex: 'uploader', width: 100, visible: true, order: 7 },
  { key: 'retryCount', title: '重试次数', dataIndex: 'retryCount', width: 90, visible: true, order: 8 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 200, visible: true, order: 9 },
];

const failedColumnConfig = ref<ColumnConfigItem[]>([]);
const failedVisibleColumns = computed(() => {
  const cols = failedColumnConfig.value.length > 0 ? failedColumnConfig.value : allFailedColumns;
  return cols
    .filter(c => c.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(c => ({
      title: c.title,
      dataIndex: c.dataIndex,
      key: c.key,
      width: c.width,
      align: c.key === 'action' ? 'center' as const : undefined,
      fixed: c.key === 'action' ? 'right' as const : undefined,
    }));
});

const loadFailedData = () => {
  failedLoading.value = true;
  setTimeout(() => {
    const errors = ['格式错误', '字段缺失', '号码无效', '数据重复', '文件超大', '编码异常'];
    const details = [
      '文件第3行格式异常，缺少必填字段「手机号码」',
      '文件缺少「客户姓名」列，请检查表头',
      '第15-28行存在14个无效手机号码（非11位数字）',
      '批次数据与已有批次 BAT-00012 存在87条重复记录',
      '文件大小258MB，超过单次上传限制200MB',
      '文件编码为GBK，系统仅支持UTF-8编码',
    ];
    failedDataSource.value = Array.from({ length: 6 }, (_, i) => ({
      id: `FL-BAT-${String(i + 1).padStart(5, '0')}`,
      batchName: `失败批次-${String(i + 1).padStart(3, '0')}`,
      fileName: `外呼数据_202605${10 + i}.xlsx`,
      errorType: errors[i],
      errorDetail: details[i],
      fileSize: ['12.5MB', '3.2MB', '45.8MB', '28.1MB', '258MB', '8.7MB'][i],
      uploadTime: `2026-05-${String(10 + i).padStart(2, '0')} 11:${String(20 + i * 5).padStart(2, '0')}:00`,
      uploader: ['张三', '李四', '王五', '赵六', '钱七', '孙八'][i],
      retryCount: [1, 0, 2, 3, 0, 1][i],
    }));
    failedTotal.value = 42;
    failedPagination.total = 42;
    failedLoading.value = false;
  }, 400);
};

const handleFailedSearch = () => { failedPagination.current = 1; loadFailedData(); message.success('搜索成功'); };
const handleFailedReset = () => {
  failedSearch.batchName = '';
  failedSearch.uploader = '';
  failedSearch.errorType = undefined;
  failedSearch.uploadTimeRange = undefined;
  failedPagination.current = 1;
  loadFailedData();
  message.success('重置成功');
};

// ============================================================
// Tab 5: 免打扰名单
// ============================================================
interface DndItem {
  id: string;
  phoneNumber: string;
  addMethod: string;
  source: string;
  sourceReason: string;
  orgName: string;
  addTime: string;
  releaseTime: string;
  operator: string;
  remark: string;
  approvalStatus: string;
}

const dndSearch = reactive({
  phoneNumber: '',
  addMethod: undefined as string | undefined,
  source: undefined as string | undefined,
  sourceReason: '',
  orgName: '',
  addTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  releaseTimeRange: undefined as [Dayjs, Dayjs] | undefined,
  remark: '',
});

const dndDataSource = ref<DndItem[]>([]);
const dndTotal = ref(0);
const dndLoading = ref(false);
const dndSelectedKeys = ref<string[]>([]);
const dndPagination = reactive({ current: 1, pageSize: 10, total: 0 });

const allDndColumns: ColumnConfigItem[] = [
  { key: 'id', title: 'ID', dataIndex: 'id', width: 150, visible: true, order: 0 },
  { key: 'phoneNumber', title: '联系方式', dataIndex: 'phoneNumber', width: 140, visible: true, order: 1 },
  { key: 'addMethod', title: '添加方式', dataIndex: 'addMethod', width: 110, visible: true, order: 2 },
  { key: 'source', title: '来源', dataIndex: 'source', width: 110, visible: true, order: 3 },
  { key: 'sourceReason', title: '添加原因', dataIndex: 'sourceReason', width: 150, visible: true, order: 4 },
  { key: 'orgName', title: '机构名称', dataIndex: 'orgName', width: 140, visible: true, order: 5 },
  { key: 'addTime', title: '添加时间', dataIndex: 'addTime', width: 180, visible: true, order: 6 },
  { key: 'releaseTime', title: '解除时间', dataIndex: 'releaseTime', width: 180, visible: true, order: 7 },
  { key: 'operator', title: '添加人', dataIndex: 'operator', width: 100, visible: true, order: 8 },
  { key: 'remark', title: '备注', dataIndex: 'remark', width: 200, visible: true, order: 9 },
  { key: 'approvalStatus', title: '审批状态', dataIndex: 'approvalStatus', width: 120, visible: true, order: 10 },
  { key: 'action', title: '操作', dataIndex: 'action', width: 320, visible: true, order: 11 },
];

const dndColumnConfig = ref<ColumnConfigItem[]>([]);
const dndVisibleColumns = computed(() => {
  const cols = dndColumnConfig.value.length > 0 ? dndColumnConfig.value : allDndColumns;
  return cols
    .filter(c => c.visible)
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .map(c => ({
      title: c.title,
      dataIndex: c.dataIndex,
      key: c.key,
      width: c.width,
      align: c.key === 'action' ? 'center' as const : undefined,
      fixed: c.key === 'action' ? 'right' as const : undefined,
    }));
});

const loadDndData = () => {
  dndLoading.value = true;
  setTimeout(() => {
    const sources = ['API上传', 'AI外呼', '手动创建', '批量导入', '工作台添加'];
    const statuses = ['待审批', '审批通过', '审批不通过'];
    const reasons = ['客户主动申请', '多次投诉标记', '监管合规要求', '逾期催收屏蔽', '特殊客户保护', '司法冻结', '公安协查', '同业投诉'];
    const methods = ['手动添加', '批量导入', '系统自动'];
    const orgs = ['象小秘总行', '华东分行', '华南分行', '华北分行', '西南分行', '华中分行', '西北分行'];
    const prefixes = ['138', '139', '150', '186', '177', '199', '155', '188'];
    const remarks = [
      '客户明确要求不再拨打', '已投诉，标记为免打扰', '客户已办理其他银行产品',
      '多次拒接，避免骚扰', '客户身体原因无法接听', '号码已过户给他人',
      '监管要求暂停外呼', '客户配偶要求停止联系', '已进入诉讼流程',
      '客户反馈信息有误', '号码为空号/停机', '客户已还清欠款',
    ];
    dndDataSource.value = Array.from({ length: 30 }, (_, i) => ({
      id: `DND-${String(i + 1).padStart(6, '0')}`,
      phoneNumber: `${prefixes[i % 8]}${String(10000000 + i * 3333333).slice(0, 8)}`,
      addMethod: methods[i % 3],
      source: sources[i % 4],
      sourceReason: reasons[i % 8],
      orgName: orgs[i % 7],
      addTime: `2026-${String(1 + (i % 6)).padStart(2, '0')}-${String(1 + (i % 28)).padStart(2, '0')} ${String(8 + (i % 10)).padStart(2, '0')}:${String((i * 7) % 60).padStart(2, '0')}:00`,
      releaseTime: i % 4 === 0 ? '永久' : `2026-${String(7 + (i % 4)).padStart(2, '0')}-${String(1 + (i % 28)).padStart(2, '0')} 00:00:00`,
      operator: ['管理员', '系统', '王芳', '刘洋', '赵敏', '陈刚'][i % 6],
      remark: remarks[i % 12],
      approvalStatus: statuses[i % 3],
    }));
    dndTotal.value = 128;
    dndPagination.total = 128;
    dndLoading.value = false;
  }, 400);
};

const handleDndSearch = () => { dndPagination.current = 1; loadDndData(); message.success('搜索成功'); };
const handleDndReset = () => {
  dndSearch.phoneNumber = '';
  dndSearch.addMethod = undefined;
  dndSearch.source = undefined;
  dndSearch.sourceReason = '';
  dndSearch.orgName = '';
  dndSearch.addTimeRange = undefined;
  dndSearch.releaseTimeRange = undefined;
  dndSearch.remark = '';
  dndPagination.current = 1;
  loadDndData();
  message.success('重置成功');
};

const handleDndRemove = (record: DndItem) => {
  dndDataSource.value = dndDataSource.value.filter(item => item.id !== record.id);
  dndTotal.value -= 1;
  dndPagination.total -= 1;
  message.success(`已将 ${record.phoneNumber} 移出免打扰名单`);
};

const handleDndBatchRemove = () => {
  const count = dndSelectedKeys.value.length;
  dndDataSource.value = dndDataSource.value.filter(item => !dndSelectedKeys.value.includes(item.id));
  dndTotal.value -= count;
  dndPagination.total -= count;
  dndSelectedKeys.value = [];
  message.success(`已批量删除 ${count} 条记录`);
};

const approvalModalVisible = ref(false);
const approvalRecord = ref<DndItem | null>(null);
const handleDndApproval = (record: DndItem) => {
  approvalRecord.value = record;
  approvalModalVisible.value = true;
};
const handleApprovalResult = (result: string) => {
  if (approvalRecord.value) {
    const item = dndDataSource.value.find(d => d.id === approvalRecord.value!.id);
    if (item) item.approvalStatus = result;
    message.success(`已将 ${approvalRecord.value.phoneNumber} 审批为「${result}」`);
  }
  approvalModalVisible.value = false;
  approvalRecord.value = null;
};

const handleDndImport = (file: File) => {
  // TODO: 调用后端 API 上传文件
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const data = new Uint8Array(e.target?.result as ArrayBuffer);
      const workbook = XLSX.read(data, { type: 'array' });
      const sheet = workbook.Sheets[workbook.SheetNames[0]];
      const rows = XLSX.utils.sheet_to_json<string[]>(sheet, { header: 1 });
      const count = Math.max(0, rows.length - 1);
      message.success(`导入成功，共解析 ${count} 条免打扰记录`);
      loadDndData();
    } catch {
      message.error('文件解析失败，请检查文件格式');
    }
  };
  reader.readAsArrayBuffer(file);
  return false;
};

const handleDndExport = () => {
  const headers = ['ID', '联系方式', '添加方式', '来源', '添加原因', '机构名称', '添加时间', '解除时间', '添加人', '备注', '审批状态'];
  const rows = dndDataSource.value.map(item => [
    item.id,
    item.phoneNumber,
    item.addMethod,
    item.source,
    item.sourceReason,
    item.orgName,
    item.addTime,
    item.releaseTime,
    item.operator,
    item.remark,
    item.approvalStatus,
  ]);
  const ws = XLSX.utils.aoa_to_sheet([headers, ...rows]);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, '免打扰名单');
  XLSX.writeFile(wb, `免打扰名单_${new Date().toISOString().slice(0, 10)}.xlsx`);
  message.success('导出成功');
};

// ============================================================
// 通用：列设置
// ============================================================
const columnSettingModalRef = ref<InstanceType<typeof ColumnSettingModal> | null>(null);

const tabColumnsMap: Record<string, { all: ColumnConfigItem[]; config: typeof aiColumnConfig }> = {
  aiBatch:      { all: allAiColumns,      config: aiColumnConfig },
  manualBatch:  { all: allManualColumns,   config: manualColumnConfig },
  pendingBind:  { all: allPendingColumns,  config: pendingColumnConfig },
  uploadFailed: { all: allFailedColumns,   config: failedColumnConfig },
  dnd:          { all: allDndColumns,      config: dndColumnConfig },
};

const currentSettingColumns = computed(() => {
  const entry = tabColumnsMap[activeTab.value];
  return entry && entry.config.value.length > 0 ? entry.config.value : (entry?.all ?? allAiColumns);
});

const showColumnSetting = (_tab: string) => {
  columnSettingModalRef.value?.open();
};

const handleColumnSave = (columns: ColumnConfigItem[]) => {
  const entry = tabColumnsMap[activeTab.value];
  if (entry) entry.config.value = columns;
};

const handleColumnCancel = () => {};

// ============================================================
// 通用：导出 Excel
// ============================================================
const exportModalVisible = ref(false);
const exportFieldKeys = ref<string[]>([]);
const exportFieldOptions = computed(() => {
  const entry = tabColumnsMap[activeTab.value];
  if (!entry) return [];
  const cols = entry.config.value.length > 0 ? entry.config.value : entry.all;
  return cols.filter(c => c.key !== 'action').map(c => ({ label: c.title, value: c.dataIndex }));
});

let currentExportTab = '';

const openExportModal = (tab: string) => {
  currentExportTab = tab;
  exportFieldKeys.value = exportFieldOptions.value.map(opt => opt.value);
  exportModalVisible.value = true;
};

const handleExportCheckAll = (e: any) => {
  if (e.target.checked) {
    exportFieldKeys.value = exportFieldOptions.value.map(opt => opt.value);
  } else {
    exportFieldKeys.value = [];
  }
};

const handleExportExcel = () => {
  if (exportFieldKeys.value.length === 0) {
    message.warning('请至少选择一个导出字段');
    return;
  }
  const headers = exportFieldKeys.value.map(key => {
    const opt = exportFieldOptions.value.find(o => o.value === key);
    return opt ? opt.label : key;
  });

  const dataSourceMap: Record<string, any[]> = {
    ai: aiDataSource.value,
    manual: manualDataSource.value,
    pending: pendingDataSource.value,
    failed: failedDataSource.value,
    dnd: dndDataSource.value,
  };

  const tabNameMap: Record<string, string> = {
    ai: 'AI外呼批次',
    manual: '人工外呼批次',
    pending: '待绑定批次',
    failed: '上传失败批次',
    dnd: '免打扰名单',
  };

  const rows = (dataSourceMap[currentExportTab] || []).map(item =>
    exportFieldKeys.value.map(key => (item as any)[key] ?? '')
  );
  const wsData = [headers, ...rows];
  const ws = XLSX.utils.aoa_to_sheet(wsData);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, tabNameMap[currentExportTab] || '数据');
  XLSX.writeFile(wb, `${tabNameMap[currentExportTab] || '数据湖'}_${new Date().toISOString().slice(0, 10)}.xlsx`);
  exportModalVisible.value = false;
  message.success('导出成功');
};

// ============================================================
// 初始化加载
// ============================================================
onMounted(() => {
  loadAiData();
});
</script>

<style scoped>
.data-lake {
  padding: 0;
}

.quality-wrapper {
  background: #fff;
  border-radius: 8px;
}

.tab-section {
  background: #fff;
  padding: 0 24px;
}

.tab-section :deep(.ant-tabs-nav) {
  margin-bottom: 0;
}

.search-and-table-area {
  padding-top: 16px;
}

.search-area {
  background: #fff;
  border-radius: 6px;
  padding: 16px 0 4px;
}

.search-area :deep(.ant-row) {
  margin-bottom: 0;
}

.search-area :deep(.ant-form-item) {
  margin-bottom: 12px;
}

.search-btn-space {
  display: flex;
  gap: 8px;
}

.table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
}

.table-toolbar-left {
  display: flex;
  align-items: center;
}

.selection-info {
  font-size: 13px;
  color: #666;
}

.table-toolbar-right {
  display: flex;
  align-items: center;
  gap: 0;
}

.table-area {
  background: #fff;
}

.table-wrapper {
  background: #fff;
}

:deep(.ant-table) {
  font-size: 13px;
}

:deep(.ant-table-thead > tr > th) {
  background: #f5f7fa;
  font-weight: 500;
  color: #333;
  white-space: nowrap;
}

:deep(.ant-table-tbody > tr > td) {
  white-space: nowrap;
}

.batch-link {
  color: #1890ff;
  cursor: pointer;
}

.batch-link:hover {
  color: #40a9ff;
}

.error-detail-text {
  display: inline-block;
  max-width: 240px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #ff4d4f;
  font-size: 12px;
}

.remark-text {
  display: inline-block;
  max-width: 180px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #666;
  font-size: 12px;
}
</style>
