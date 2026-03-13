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
            <el-button class="create-task-btn" @click="handleCreateTask">
              <el-icon><Plus /></el-icon>
              新建质检任务
            </el-button>
          </div>
        </div>
      </div>

      <!-- 标签页切换 -->
      <div class="tabs-section">
        <el-tabs v-model="activeTab" @tab-change="handleTabChange">
          <el-tab-pane label="AI 质检任务" name="ai" />
          <el-tab-pane label="人工质检任务" name="manual" />
        </el-tabs>
      </div>

      <!-- 搜索区域和表格区域合并 -->
      <div class="search-and-table-area">
        <!-- 搜索区域 -->
        <div class="search-area">
          <el-form :model="searchForm" ref="searchFormRef" label-width="0">
            <el-row :gutter="16">
              <!-- 第一行 -->
              <el-col :span="6">
                <el-form-item>
                  <el-input
                    v-model="searchForm.taskName"
                    placeholder="请输入质检任务名称"
                    clearable
                  />
                </el-form-item>
              </el-col>
              <el-col :span="6">
                <el-form-item>
                  <el-input
                    v-model="searchForm.taskId"
                    placeholder="请输入质检任务 ID"
                    clearable
                  />
                </el-form-item>
              </el-col>
              <el-col :span="6">
                <el-form-item>
                  <el-input
                    v-model="searchForm.taskDescription"
                    placeholder="请输入任务说明"
                    clearable
                  />
                </el-form-item>
              </el-col>
              <el-col :span="6">
                <el-form-item>
                  <el-select
                    v-model="searchForm.taskStatus"
                    placeholder="请选择任务状态"
                    clearable
                    style="width: 100%"
                  >
                    <el-option label="进行中" value="running" />
                    <el-option label="已完成" value="completed" />
                    <el-option label="已暂停" value="paused" />
                    <el-option label="未开始" value="pending" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="16">
              <!-- 第二行 -->
              <el-col :span="6">
                <el-form-item>
                  <el-select
                    v-model="searchForm.qualityObject"
                    placeholder="请选择质检对象"
                    clearable
                    style="width: 100%"
                  >
                    <el-option label="人工外呼录音" value="manual_outbound" />
                    <el-option label="人机协同录音" value="ai_assisted" />
                    <el-option label="呼入录音" value="inbound" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="6">
                <el-form-item>
                  <el-select
                    v-model="searchForm.qualityModel"
                    placeholder="请选择质检模型"
                    clearable
                    style="width: 100%"
                  >
                    <el-option label="合规质检" value="compliance" />
                    <el-option label="服务质检" value="service" />
                    <el-option label="销售质检" value="sales" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="6" v-if="activeTab === 'ai'">
                <el-form-item>
                  <el-select
                    v-model="searchForm.auditStatus"
                    placeholder="请选择人工审核状态"
                    clearable
                    style="width: 100%"
                  >
                    <el-option label="待审核" value="pending" />
                    <el-option label="审核中" value="auditing" />
                    <el-option label="已通过" value="approved" />
                    <el-option label="已驳回" value="rejected" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="6" v-if="activeTab === 'manual'">
                <el-form-item>
                  <el-select
                    v-model="searchForm.inspector"
                    placeholder="请选择质检员"
                    clearable
                    style="width: 100%"
                  >
                    <el-option label="张三" value="zhangsan" />
                    <el-option label="李四" value="lisi" />
                    <el-option label="王五" value="wangwu" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="6">
                <el-form-item>
                  <el-space class="search-btn-space">
                    <el-button class="reset-btn" @click="handleReset">
                      <el-icon><Refresh /></el-icon>
                      重置
                    </el-button>
                    <el-button class="search-btn" @click="handleSearch">
                      <el-icon><Search /></el-icon>
                      搜索
                    </el-button>
                  </el-space>
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
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
            <el-table
              :data="tableData"
              :loading="loading"
              style="width: 100%"
              v-loading="loading"
            >
              <el-table-column prop="taskId" label="质检任务 ID" min-width="110" />
              <el-table-column prop="taskName" label="质检任务名称" min-width="200" />
              <el-table-column prop="taskDescription" label="任务说明" min-width="220" show-overflow-tooltip />
              <el-table-column prop="qualityModel" label="质检模型" min-width="150" />
              <el-table-column prop="qualityObject" label="质检对象" min-width="130" />
              
              <!-- AI 质检任务特有列 -->
              <el-table-column v-if="activeTab === 'ai'" prop="status" label="任务状态" min-width="110">
                <template #default="{ row }">
                  <el-tag v-if="row.status === 'running'" type="primary" size="small">进行中</el-tag>
                  <el-tag v-else-if="row.status === 'paused'" type="warning" size="small">已暂停</el-tag>
                  <el-tag v-else-if="row.status === 'completed'" type="success" size="small">已完成</el-tag>
                  <el-tag v-else type="info" size="small">未开始</el-tag>
                </template>
              </el-table-column>
              <el-table-column v-if="activeTab === 'ai'" prop="aiProgress" label="AI 质检进度" min-width="220">
                <template #default="{ row }">
                  <div class="progress-cell">
                    <el-progress
                      :percentage="row.aiProgressPercent"
                      :status="row.aiProgressPercent === 100 ? 'success' : ''"
                      :stroke-width="8"
                      :show-text="false"
                      class="progress-bar"
                    />
                    <span class="progress-text">{{ row.aiProgressPercent }}% ({{ row.aiCompleted }} / {{ row.aiTotal }})</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column v-if="activeTab === 'ai'" prop="auditStatus" label="人工审核状态" min-width="110">
                <template #default="{ row }">
                  <el-tag v-if="row.auditStatus === 'auditing'" type="primary" size="small">进行中</el-tag>
                  <el-tag v-else-if="row.auditStatus === 'pending'" type="warning" size="small">待审核</el-tag>
                  <el-tag v-else-if="row.auditStatus === 'approved'" type="success" size="small">已通过</el-tag>
                  <el-tag v-else-if="row.auditStatus === 'rejected'" type="danger" size="small">已驳回</el-tag>
                  <el-tag v-else type="info" size="small">-</el-tag>
                </template>
              </el-table-column>
              <el-table-column v-if="activeTab === 'ai'" prop="auditor" label="审核员" min-width="110" />
              <el-table-column v-if="activeTab === 'ai'" prop="creator" label="创建人" min-width="110" />
              <el-table-column v-if="activeTab === 'ai'" prop="createdAt" label="创建时间" min-width="170" />
              <el-table-column v-if="activeTab === 'ai'" prop="completedAt" label="完成时间" min-width="170" />
              
              <el-table-column label="操作" fixed="right" width="240">
                <template #default="{ row }">
                  <el-space>
                    <el-button link type="primary" @click="handleDetail(row)">
                      详情
                    </el-button>
                    <el-button link type="primary" @click="handleEdit(row)">
                      编辑
                    </el-button>
                    <el-button link type="primary" @click="handleToggleStatus(row)">
                      {{ row.status === 'running' ? '暂停' : '开启' }}
                    </el-button>
                    <el-button link type="danger" @click="handleDelete(row)">
                      删除
                    </el-button>
                  </el-space>
                </template>
              </el-table-column>
            </el-table>
          </div>

          <!-- 分页 -->
          <div class="pagination-container">
            <el-pagination
              v-model:current-page="pagination.currentPage"
              v-model:page-size="pagination.pageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="pagination.total"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance } from 'element-plus'

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
  taskStatus: string
  qualityObject: string
  qualityModel: string
  auditStatus: string
  auditor: string
  inspector: string
}

// ============ 响应式数据 ============
const activeTab = ref<'ai' | 'manual'>('ai')
const loading = ref(false)
const total = ref(6)
const searchFormRef = ref<FormInstance>()

// 搜索表单数据
const searchForm = reactive<SearchFormData>({
  taskName: '',
  taskId: '',
  taskDescription: '',
  taskStatus: '',
  qualityObject: '',
  qualityModel: '',
  auditStatus: '',
  auditor: '',
  inspector: '',
})

// 分页配置
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 6,
})

// ============ 模拟数据 ============
const mockData: QualityTaskItem[] = [
  // AI 质检任务数据
  {
    taskId: 27,
    taskName: 'test2026.2.9_19:20',
    taskDescription: 'test2026.2.9_19:20',
    qualityModel: '合规质检',
    qualityObject: '人工外呼录音',
    status: 'paused',
    auditStatus: 'auditing',
    auditor: 'yezewei',
    creator: 'hzy',
    createdAt: '2026-02-09 19:21:35',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 265,
  },
  {
    taskId: 26,
    taskName: 'test2026.2.9_19:15',
    taskDescription: 'test2026.2.9_19:15',
    qualityModel: '合规质检',
    qualityObject: '人机协同录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: 'hzy111',
    creator: 'hzy',
    createdAt: '2026-02-09 19:18:34',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 18,
  },
  {
    taskId: 25,
    taskName: '合规检查_20260208',
    taskDescription: '每日例行合规质检任务',
    qualityModel: '合规质检',
    qualityObject: '呼入录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: 'admin',
    creator: 'hzy',
    createdAt: '2026-02-09 19:03:27',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 293,
  },
  {
    taskId: 24,
    taskName: '服务质量检查_0207',
    taskDescription: '客服服务质量专项质检',
    qualityModel: '服务质检',
    qualityObject: '人工外呼录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: 'admin',
    creator: 'hzy',
    createdAt: '2026-02-09 15:32:28',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 18,
  },
  {
    taskId: 23,
    taskName: '销售话术质检_0206',
    taskDescription: '销售话术规范性检查',
    qualityModel: '销售质检',
    qualityObject: '人机协同录音',
    status: 'running',
    auditStatus: 'auditing',
    auditor: 'admin',
    creator: 'hzy',
    createdAt: '2026-02-09 15:31:02',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 106,
  },
  // 人工质检任务数据
  {
    taskId: 28,
    taskName: '人工质检任务',
    taskDescription: '人工质检任务',
    qualityModel: '合规质检（人工）',
    qualityObject: '人机协同录音',
    status: 'running',
    auditStatus: '',
    auditor: '',
    creator: 'hzy',
    createdAt: '2026-02-09 19:30:00',
    aiProgressPercent: 0,
    aiCompleted: 0,
    aiTotal: 0,
  },
]

// ============ 计算属性 ============
const tableData = computed(() => {
  let filtered = [...mockData]

  // 根据当前标签页过滤数据
  if (activeTab.value === 'ai') {
    filtered = filtered.filter(item => item.taskId >= 18) // AI 质检任务
  } else {
    filtered = filtered.filter(item => item.taskId === 28) // 人工质检任务
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

  if (searchForm.auditor && activeTab.value === 'ai') {
    filtered = filtered.filter(item => item.auditor === searchForm.auditor)
  }

  if (searchForm.inspector && activeTab.value === 'manual') {
    filtered = filtered.filter(item => item.creator === searchForm.inspector)
  }

  return filtered
})

// ============ 生命周期 ============
onMounted(() => {
  // 页面加载时的初始化
})

// ============ 方法 ============

const handleTabChange = (tab: 'ai' | 'manual') => {
  console.log('切换标签页:', tab)
}

const handleSearch = () => {
  console.log('执行搜索:', searchForm)
  ElMessage.success('搜索成功')
}

const handleReset = () => {
  if (searchFormRef.value) {
    searchFormRef.value.resetFields()
  }
  Object.assign(searchForm, {
    taskName: '',
    taskId: '',
    taskDescription: '',
    taskStatus: '',
    qualityObject: '',
    qualityModel: '',
    auditStatus: '',
    auditor: '',
    inspector: '',
  })
  ElMessage.success('已重置搜索条件')
}

const handleCreateTask = () => {
  ElMessage.info('新建质检任务')
}

const handleDetail = (row: QualityTaskItem) => {
  ElMessage.info(`查看任务 ${row.taskId} 详情`)
}

const handleEdit = (row: QualityTaskItem) => {
  ElMessage.info(`编辑任务 ${row.taskId}`)
}

const handleToggleStatus = (row: QualityTaskItem) => {
  const action = row.status === 'running' ? '暂停' : '开启'
  ElMessage.success(`已${action}任务 ${row.taskId}`)
}

const handleDelete = (row: QualityTaskItem) => {
  ElMessageBox.confirm(
    `确定要删除质检任务 "${row.taskName}" 吗？`,
    '删除确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(() => {
    ElMessage.success('删除成功')
  }).catch(() => {})
}

const handleSizeChange = (size: number) => {
  pagination.pageSize = size
}

const handleCurrentChange = (page: number) => {
  pagination.currentPage = page
}
</script>

<style scoped>
/* 质检任务内容区域 */
.quality-inspection-task {
  height: calc(100vh - 64px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f7fa;
  padding: 16px;
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
  margin-bottom: 12px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
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
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.page-description {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.header-right {
  display: flex;
  align-items: center;
}

/* 新建质检任务按钮 - 蓝色背景白色文字 */
.create-task-btn {
  background: #1677ff;
  border-color: #1677ff;
  color: #fff;
  padding: 8px 20px;
  border-radius: 4px;
  font-size: 14px;
  transition: all 0.3s;
}

.create-task-btn:hover {
  background: #4096ff;
  border-color: #4096ff;
  color: #fff;
}

.create-task-btn .el-icon,
.create-task-btn span {
  color: #fff;
}

/* 标签页区域 */
.tabs-section {
  background: #fff;
  padding: 0 24px;
  margin-bottom: 12px;
  border-radius: 4px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
}

.tabs-section :deep(.el-tabs__header) {
  margin-bottom: 0;
}

/* 搜索和表格合并区域 */
.search-and-table-area {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 搜索区域 */
.search-area {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.search-area :deep(.el-form-item) {
  margin-bottom: 16px;
}

.search-area :deep(.el-form-item__content) {
  width: 100%;
}

/* 搜索按钮间距 */
.search-btn-space {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.search-btn-space .el-button {
  padding: 8px 20px;
  font-size: 14px;
  border-radius: 4px;
  transition: all 0.3s;
  min-width: 90px;
}

/* 搜索按钮 - 蓝色背景白色文字 */
.search-btn-space .search-btn {
  background: #1677ff;
  border-color: #1677ff;
  color: #fff;
}

.search-btn-space .search-btn:hover {
  background: #4096ff;
  border-color: #4096ff;
  color: #fff;
}

.search-btn-space .search-btn .el-icon,
.search-btn-space .search-btn span {
  color: #fff;
}

/* 重置按钮 - 白色背景黑色文字 */
.search-btn-space .reset-btn {
  background: #fff;
  border-color: #d9d9d9;
  color: #333;
}

.search-btn-space .reset-btn:hover {
  background: #fff;
  border-color: #1677ff;
  color: #1677ff;
}

.search-btn-space .reset-btn .el-icon {
  color: #333;
}

.search-btn-space .reset-btn:hover .el-icon {
  color: #1677ff;
}

/* 表格区域 */
.table-area {
  flex: 1;
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 表格工具栏 */
.table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
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
.table-wrapper :deep(.el-table) {
  font-size: 14px;
}

/* 表头样式 - 浅蓝色背景 */
.table-wrapper :deep(.el-table__header th) {
  background: #f0f5ff;
  font-weight: 600;
  color: #303133;
  border-bottom: 1px solid #ebeef5;
  height: 45px;
}

.table-wrapper :deep(.el-table__header .cell) {
  color: #303133;
  font-weight: 600;
}

.table-wrapper :deep(.el-table__body tr) {
  height: 45px;
}

.table-wrapper :deep(.el-table__body .cell) {
  line-height: 45px;
  color: #333;
  white-space: nowrap;
}

/* 表格行 */
.table-wrapper :deep(.el-table__row) {
  background-color: #fff;
}

.table-wrapper :deep(.el-table__row:hover) {
  background-color: #f5f7fa;
}

/* 移除表格边框 */
.table-wrapper :deep(.el-table--border) {
  border: none;
}

.table-wrapper :deep(.el-table__inner-wrapper::after) {
  display: none;
}

.table-wrapper :deep(.el-table th, .el-table td) {
  border-right: none;
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
  color: #333;
  white-space: nowrap;
}

/* 操作列按钮样式 - 参考场景管理 */
.table-wrapper :deep(.el-button--link) {
  padding: 4px 8px;
  font-size: 14px;
  height: auto;
  line-height: 1;
  background: transparent;
  border: none;
  border-radius: 4px;
  transition: all 0.3s;
  text-align: center;
}

.table-wrapper :deep(.el-button--link.el-button--primary) {
  color: #1890ff;
}

.table-wrapper :deep(.el-button--link.el-button--primary:hover) {
  color: #40a9ff;
  background-color: rgba(24, 144, 255, 0.1);
}

.table-wrapper :deep(.el-button--link.el-button--danger) {
  color: #ff4d4f;
}

.table-wrapper :deep(.el-button--link.el-button--danger:hover) {
  color: #ff7875;
  background-color: rgba(255, 77, 79, 0.1);
}

/* 操作列间距 */
.table-wrapper :deep(.el-space) {
  gap: 8px !important;
  display: flex !important;
  align-items: center;
}

/* 操作列单元格垂直居中 */
.table-wrapper :deep(.el-table__body td:last-child) {
  vertical-align: middle;
}

.table-wrapper :deep(.el-table__body tr td:last-child .el-space) {
  display: flex;
  align-items: center;
  height: 100%;
}

/* 分页容器 */
.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
  padding-top: 16px;
}
</style>
