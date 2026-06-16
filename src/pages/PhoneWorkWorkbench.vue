<template>
  <div class="phone-work-workbench">
    <div class="main-container">
      <!-- 左侧任务卡片区域 -->
      <div class="left-panel" v-show="!leftPanelCollapsed" style="width: 300px;">
        <div class="task-list-container">
          <!-- 折叠按钮 -->
          <div class="collapse-btn" @click="toggleLeftPanel" title="收起任务列表">
            <LeftOutlined />
          </div>

          <!-- 搜索框 -->
          <div class="search-box">
            <a-input-search
              v-model:value="searchKeyword"
              placeholder="请输入场景名称或编号"
              enter-button="搜索"
              @search="handleSearch"
              class="scene-search"
            />
          </div>

          <!-- 标签切换 -->
          <div class="tab-switch">
            <a-radio-group v-model:value="activeTab" button-style="solid">
              <a-radio-button value="active">开启中</a-radio-button>
              <a-radio-button value="closed">已关闭</a-radio-button>
              <a-radio-button value="expired">已过期</a-radio-button>
              <a-radio-button value="all">全部</a-radio-button>
            </a-radio-group>
          </div>

          <!-- 排序选择 -->
          <div class="sort-bar">
            <span class="sort-label">排序：</span>
            <a-select v-model:value="sortBy" style="flex: 1">
              <a-select-option value="assignTime">按最新任务分配时间</a-select-option>
              <a-select-option value="collabType">按场景人机协同类型</a-select-option>
            </a-select>
            <a-tooltip placement="topLeft" :overlayStyle="{ maxWidth: '420px' }">
              <template #title>
                <div style="white-space: normal;" v-if="sortBy === 'assignTime'">
                  1、按照当前场景下的最新任务分配时间排序，最近有分配任务的场景优先排在最上边<br/>
                  2、如果场景没有下发过任务，默认按照场景创建时间倒序
                </div>
                <div style="white-space: normal;" v-else>
                  排序逻辑：<br/>
                  1、开启人机协同的「作业中」场景<br/>
                  2、开启人机协同的「作业时间不满足」场景<br/>
                  3、未开启人机协同的「作业中」场景<br/>
                  4、未开启人机协同的「作业时间不满足」场景<br/>
                  5、其他状态场景<br/>
                  同类型场景按创建时间倒序
                </div>
              </template>
              <InfoCircleOutlined style="color: #8f959e; cursor: pointer;" />
            </a-tooltip>
          </div>

          <!-- 场景卡片列表 -->
          <div class="scene-card-list">
            <div
              v-for="scene in filteredSceneList"
              :key="scene.id"
              class="scene-card"
              :class="{ 'active': selectedSceneId === scene.id }"
              @click="selectScene(scene)"
            >
              <div class="scene-header">
                <div class="scene-title">{{ scene.name }}</div>
                <a-tag :color="getStatusColor(scene.status)" class="scene-status-tag">{{ scene.statusLabel }}</a-tag>
              </div>
              <div class="scene-info">
                <div class="info-row">
                  <span class="label">场景编号：</span>
                  <span class="value">{{ scene.code }}</span>
                </div>
                <div class="info-row">
                  <span class="label">外呼时段：</span>
                  <span class="value">{{ scene.callTimeRange }}</span>
                </div>
              </div>
              <div class="scene-footer">
                <span class="pending-count">近30天待跟进：{{ scene.pendingCount }}条</span>
                <span class="total-count-tag">共 {{ scene.totalCount }} 条</span>
              </div>
            </div>
          </div>

          <!-- 底部分页 -->
          <div class="pagination-box">
            <span class="total-count">共 {{ totalScenes }} 个场景</span>
            <a-pagination
              v-model:current="currentPage"
              :total="totalScenes"
              :pageSize="10"
              show-less-items
              size="small"
            />
          </div>
        </div>
      </div>

      <!-- 展开按钮（当左侧收起时显示） -->
      <div v-show="leftPanelCollapsed" class="expand-btn-wrapper" @click="toggleLeftPanel" title="展开任务列表">
        <div class="expand-btn">
          <RightOutlined />
        </div>
      </div>

      <!-- 右侧详情区域 -->
      <div class="right-panel" :class="{ 'right-panel-full': leftPanelCollapsed }">
        <!-- 筛选区域 -->
        <div class="filter-card">
          <div class="intent-toolbar">
            <div class="toolbar-left">
              <a-space>
                <a-select
                  v-model:value="selectedTimeRange"
                  style="width: 120px"
                >
                  <a-select-option v-for="range in timeRanges" :key="range.value" :value="range.value">{{ range.label }}</a-select-option>
                </a-select>
                <a-select
                  v-model:value="filterForm.followStatus"
                  placeholder="跟进状态"
                  allow-clear
                  style="width: 130px"
                >
                  <a-select-option value="all">全部</a-select-option>
                  <a-select-option value="pending">待跟进</a-select-option>
                  <a-select-option value="following">持续跟进</a-select-option>
                  <a-select-option value="converted">明确转化</a-select-option>
                  <a-select-option value="rejected">明确拒绝</a-select-option>
                </a-select>
                <a-button type="primary" @click="handleFilterSearch">
                  <SearchOutlined />
                  搜索
                </a-button>
                <a-button @click="handleReset">
                  <ReloadOutlined />
                  重置
                </a-button>
                <a-button @click="drawerVisible = true">
                  <SearchOutlined />
                  高级搜索
                </a-button>
              </a-space>
            </div>
          </div>
        </div>

        <!-- 高级搜索抽屉 -->
        <a-drawer
          title="高级搜索"
          :open="drawerVisible"
          @close="drawerVisible = false"
          :width="480"
          :body-style="{ padding: '16px 24px' }"
        >
          <a-form layout="vertical">
            <a-form-item label="场景名称">
              <a-input v-model:value="advancedForm.sceneName" placeholder="请输入场景名称" allow-clear />
            </a-form-item>
            <a-form-item label="场景编号">
              <a-input v-model:value="advancedForm.sceneCode" placeholder="请输入场景编号" allow-clear />
            </a-form-item>
            <a-form-item label="客户名称">
              <a-input v-model:value="advancedForm.customerName" placeholder="请输入客户名称" allow-clear />
            </a-form-item>
            <a-form-item label="联系方式">
              <a-input v-model:value="advancedForm.phone" placeholder="请输入联系方式" allow-clear />
            </a-form-item>
            <a-form-item label="直营坐席账号">
              <a-input v-model:value="advancedForm.seatAccount" placeholder="请输入坐席账号" allow-clear />
            </a-form-item>
            <a-form-item label="跟进状态">
              <a-select v-model:value="advancedForm.followStatus" placeholder="请选择跟进状态" allow-clear style="width: 100%">
                <a-select-option value="pending">待跟进</a-select-option>
                <a-select-option value="following">持续跟进</a-select-option>
                <a-select-option value="converted">明确转化</a-select-option>
                <a-select-option value="rejected">明确拒绝</a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="跟进结果">
              <a-select v-model:value="advancedForm.followResult" placeholder="请选择跟进结果" allow-clear style="width: 100%">
                <a-select-option value="pending">待跟进</a-select-option>
                <a-select-option value="following">持续跟进</a-select-option>
                <a-select-option value="converted">明确转化</a-select-option>
                <a-select-option value="rejected">明确拒绝</a-select-option>
              </a-select>
            </a-form-item>
          </a-form>
          <div class="drawer-footer">
            <a-button @click="handleAdvancedReset" style="margin-right: 8px">重置</a-button>
            <a-button type="primary" @click="handleAdvancedSearch">搜索</a-button>
          </div>
        </a-drawer>

        <!-- 右侧客户数据表格 -->
        <a-card class="table-card">
          <div class="intent-toolbar">
            <div class="toolbar-left">
              <a-space>
                <a-button @click="handleBatchExport">
                  <ExportOutlined /> 批量导出
                </a-button>
                <a-button @click="handleBatchAssign">
                  <TeamOutlined /> 批量分配
                </a-button>
                <a-button danger @click="handleBatchDelete">
                  <DeleteOutlined /> 批量删除
                </a-button>
                <a-button @click="handleBatchSms">
                  <MessageOutlined /> 批量发送短信
                </a-button>
              </a-space>
            </div>
            <div class="toolbar-right">
              <a-button @click="handleColumnSetting">
                <SettingOutlined /> 列表显示设置
              </a-button>
            </div>
          </div>
          <div class="table-header-info">
            <span>共 {{ rightTableData.length }} 条，已选 {{ selectedRowKeys.length }} 条</span>
          </div>
          <a-table
            :columns="rightColumns"
            :data-source="rightTableData"
            :row-selection="{
              selectedRowKeys: selectedRowKeys,
              onChange: onSelectChange
            }"
            :pagination="{
              pageSize: 10,
              showSizeChanger: true,
              showQuickJumper: true,
              showTotal: (total: number) => `共 ${total} 条`,
              locale: {
                items_per_page: '条/页',
                jump_to: '前往',
                page: '页'
              }
            }"
            :scroll="{ x: 1200 }"
            row-key="id"
            class="workbench-table"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'followResult'">
                <a-tag :color="record.followResult === '待跟进' ? 'orange' : record.followResult === '明确转化' ? 'green' : record.followResult === '明确拒绝' ? 'red' : 'blue'">
                  {{ record.followResult }}
                </a-tag>
              </template>
              <template v-else-if="column.key === 'isManualReach'">
                <a-tag :color="record.isManualReach === '是' ? 'green' : 'default'">{{ record.isManualReach }}</a-tag>
              </template>
              <template v-else-if="column.key === 'isManualCall'">
                <a-tag :color="record.isManualCall === '是' ? 'green' : 'default'">{{ record.isManualCall }}</a-tag>
              </template>
              <template v-else-if="column.key === 'assignHistory'">
                <a class="action-link">{{ record.assignHistory }}</a>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space>
                  <a class="action-link" @click="handleFollow(record)">去跟进</a>
                  <a class="action-link" @click="handleCall(record)">呼叫</a>
                  <a-dropdown>
                    <a class="action-link">更多 <DownOutlined /></a>
                    <template #overlay>
                      <a-menu>
                        <a-menu-item @click="handleViewDetail(record)">查看详情</a-menu-item>
                        <a-menu-item @click="handleTransfer(record)">转人工</a-menu-item>
                      </a-menu>
                    </template>
                  </a-dropdown>
                </a-space>
              </template>
            </template>
          </a-table>
        </a-card>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { message, Modal } from 'ant-design-vue'
import {
  LeftOutlined,
  RightOutlined,
  ReloadOutlined,
  SearchOutlined,
  DownOutlined,
  ExportOutlined,
  TeamOutlined,
  DeleteOutlined,
  MessageOutlined,
  SettingOutlined,
  InfoCircleOutlined
} from '@ant-design/icons-vue'

// ============ 类型定义 ============
interface SceneItem {
  id: number
  name: string
  code: string
  status: 'active' | 'closed' | 'expired'
  statusLabel: string
  callTimeRange: string
  collabType: string
  collabEnabled: boolean
  createTime: string
  lastAssignTime: string
  pendingCount: number
  totalCount: number
  page: number
  pageSize: number
}

interface RightTableItem {
  id: number
  customerName: string
  phone: string
  seatAccount: string
  followResult: string
  isManualReach: string
  aiUserType: string
  dialogTag: string
  aiAssignTime: string
  lastAssignTime: string
  assignHistory: string
  isManualCall: string
}

interface FilterForm {
  sceneKeyword: string
  followStatus: string | undefined
}

interface AdvancedForm {
  sceneName: string
  sceneCode: string
  customerName: string
  phone: string
  seatAccount: string
  followStatus: string | undefined
  followResult: string | undefined
}

// ============ 左侧状态 ============
const searchKeyword = ref('')
const activeTab = ref<'active' | 'closed' | 'expired' | 'all'>('active')
const sortBy = ref<'assignTime' | 'collabType'>('assignTime')
const selectedSceneId = ref<number | null>(1)
const currentPage = ref(1)
const leftPanelCollapsed = ref(false)
const drawerVisible = ref(false)

// ============ 场景列表数据 ============
const sceneList = ref<SceneItem[]>([
  {
    id: 1,
    name: '华夏总行-新客有礼（呼通即转）',
    code: '20260604ELWTDWHL',
    status: 'expired',
    statusLabel: '作业时间不满足',
    callTimeRange: '09:00-18:00',
    collabType: '呼通即转',
    collabEnabled: true,
    createTime: '2026-06-01 10:00:00',
    lastAssignTime: '2026-06-10 09:30:00',
    pendingCount: 0,
    totalCount: 0,
    page: 1,
    pageSize: 10
  },
  {
    id: 2,
    name: '华夏总行-新客C+会',
    code: '20260604ELWTDWH2',
    status: 'active',
    statusLabel: '作业中',
    callTimeRange: '09:00-18:00',
    collabType: '呼通即转(AI同时接待)',
    collabEnabled: true,
    createTime: '2026-06-02 14:00:00',
    lastAssignTime: '2026-06-12 14:20:00',
    pendingCount: 1,
    totalCount: 1696,
    page: 1,
    pageSize: 10
  },
  {
    id: 3,
    name: 'AI呼通即转',
    code: '20260604AICALL',
    status: 'active',
    statusLabel: '作业中',
    callTimeRange: '08:00-21:00',
    collabType: '呼通即转',
    collabEnabled: false,
    createTime: '2026-06-03 09:00:00',
    lastAssignTime: '',
    pendingCount: 2,
    totalCount: 1696,
    page: 1,
    pageSize: 10
  },
  {
    id: 4,
    name: '企微加粉转人工（卡部）-上海兴业卡部',
    code: '20260604QWWZF',
    status: 'closed',
    statusLabel: '已关闭',
    callTimeRange: '09:00-17:00',
    collabType: '触发话术/QA转接',
    collabEnabled: false,
    createTime: '2026-05-28 16:00:00',
    lastAssignTime: '',
    pendingCount: 0,
    totalCount: 0,
    page: 1,
    pageSize: 10
  },
  {
    id: 5,
    name: '华夏总行-存量客户激活',
    code: '20260605ELCLJH',
    status: 'expired',
    statusLabel: '作业时间不满足',
    callTimeRange: '09:00-18:00',
    collabType: 'AI播发完开场白后转接',
    collabEnabled: false,
    createTime: '2026-06-05 11:00:00',
    lastAssignTime: '2026-06-11 11:10:00',
    pendingCount: 5,
    totalCount: 3200,
    page: 1,
    pageSize: 10
  }
])

// ============ 当前选中场景 ============
const currentScene = computed(() => {
  return sceneList.value.find(s => s.id === selectedSceneId.value) || null
})

// ============ 过滤后的场景列表 ============
const filteredSceneList = computed(() => {
  let list = [...sceneList.value]

  if (activeTab.value !== 'all') {
    list = list.filter(scene => scene.status === activeTab.value)
  }

  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    list = list.filter(scene =>
      scene.name.toLowerCase().includes(keyword) ||
      scene.code.toLowerCase().includes(keyword)
    )
  }

  if (sortBy.value === 'assignTime') {
    // 按最新分配时间：有分配时间的优先，按时间倒序；无分配时间的按创建时间倒序
    list.sort((a, b) => {
      const aTime = a.lastAssignTime || a.createTime
      const bTime = b.lastAssignTime || b.createTime
      return bTime.localeCompare(aTime)
    })
  } else {
    // 按协同类型：先按优先级分组，同组内按创建时间倒序
    const getPriority = (scene: SceneItem) => {
      if (scene.collabEnabled && scene.status === 'active') return 1
      if (scene.collabEnabled && scene.status === 'expired') return 2
      if (!scene.collabEnabled && scene.status === 'active') return 3
      if (!scene.collabEnabled && scene.status === 'expired') return 4
      return 5
    }
    list.sort((a, b) => {
      const diff = getPriority(a) - getPriority(b)
      if (diff !== 0) return diff
      return b.createTime.localeCompare(a.createTime)
    })
  }

  return list
})

const totalScenes = computed(() => filteredSceneList.value.length)

// ============ 右侧筛选 ============
const filterForm = reactive<FilterForm>({
  sceneKeyword: '',
  followStatus: undefined
})

const advancedForm = reactive<AdvancedForm>({
  sceneName: '',
  sceneCode: '',
  customerName: '',
  phone: '',
  seatAccount: '',
  followStatus: undefined,
  followResult: undefined
})

// ============ 时间范围 ============
const timeRanges = [
  { label: '今天', value: 'today' },
  { label: '昨天', value: 'yesterday' },
  { label: '近7天', value: '7days' },
  { label: '近30天', value: '30days' }
]
const selectedTimeRange = ref('7days')

// ============ 右侧表格数据 ============
const rightTableData = ref<RightTableItem[]>([
  { id: 1, customerName: '张三', phone: '189****3312', seatAccount: 'seat_001', followResult: '待跟进', isManualReach: '否', aiUserType: '高意向', dialogTag: '有意向', aiAssignTime: '2026-06-10 09:30:00', lastAssignTime: '2026-06-12 14:20:00', assignHistory: '2次', isManualCall: '否' },
  { id: 2, customerName: '李四', phone: '138****5567', seatAccount: 'seat_002', followResult: '持续跟进', isManualReach: '是', aiUserType: '中意向', dialogTag: '需跟进', aiAssignTime: '2026-06-09 10:15:00', lastAssignTime: '2026-06-12 16:45:00', assignHistory: '3次', isManualCall: '是' },
  { id: 3, customerName: '王五', phone: '156****8821', seatAccount: 'seat_003', followResult: '明确转化', isManualReach: '是', aiUserType: '高意向', dialogTag: '已转化', aiAssignTime: '2026-06-08 11:00:00', lastAssignTime: '2026-06-11 09:10:00', assignHistory: '5次', isManualCall: '是' },
  { id: 4, customerName: '赵六', phone: '152****4433', seatAccount: 'seat_004', followResult: '明确拒绝', isManualReach: '否', aiUserType: '低意向', dialogTag: '无意向', aiAssignTime: '2026-06-10 14:30:00', lastAssignTime: '2026-06-12 10:00:00', assignHistory: '1次', isManualCall: '否' },
  { id: 5, customerName: '孙七', phone: '135****9901', seatAccount: 'seat_005', followResult: '待跟进', isManualReach: '否', aiUserType: '中意向', dialogTag: '有意向', aiAssignTime: '2026-06-11 08:45:00', lastAssignTime: '2026-06-12 15:30:00', assignHistory: '1次', isManualCall: '否' },
  { id: 6, customerName: '周八', phone: '186****7788', seatAccount: 'seat_006', followResult: '待跟进', isManualReach: '否', aiUserType: '高意向', dialogTag: '需回访', aiAssignTime: '2026-06-11 10:20:00', lastAssignTime: '2026-06-12 11:00:00', assignHistory: '2次', isManualCall: '否' },
  { id: 7, customerName: '吴九', phone: '139****2211', seatAccount: 'seat_007', followResult: '持续跟进', isManualReach: '是', aiUserType: '中意向', dialogTag: '待确认', aiAssignTime: '2026-06-09 16:00:00', lastAssignTime: '2026-06-12 13:15:00', assignHistory: '4次', isManualCall: '是' },
  { id: 8, customerName: '郑十', phone: '150****6655', seatAccount: 'seat_008', followResult: '待跟进', isManualReach: '否', aiUserType: '低意向', dialogTag: '未接通', aiAssignTime: '2026-06-12 09:00:00', lastAssignTime: '2026-06-12 09:00:00', assignHistory: '1次', isManualCall: '否' }
])

// ============ 右侧表格列 ============
const rightColumns = [
  { title: '客户名称', dataIndex: 'customerName', key: 'customerName', width: 120 },
  { title: '联系方式', dataIndex: 'phone', key: 'phone', width: 120 },
  { title: '直营坐席账号', dataIndex: 'seatAccount', key: 'seatAccount', width: 120 },
  { title: '跟进结果', dataIndex: 'followResult', key: 'followResult', width: 100 },
  { title: '是否人工触达', dataIndex: 'isManualReach', key: 'isManualReach', width: 110 },
  { title: 'AI用户分类', dataIndex: 'aiUserType', key: 'aiUserType', width: 110 },
  { title: '对话标签', dataIndex: 'dialogTag', key: 'dialogTag', width: 100 },
  { title: 'AI分配时间', dataIndex: 'aiAssignTime', key: 'aiAssignTime', width: 160 },
  { title: '最近分配时间', dataIndex: 'lastAssignTime', key: 'lastAssignTime', width: 160 },
  { title: '分配历史', dataIndex: 'assignHistory', key: 'assignHistory', width: 100 },
  { title: '是否人工外呼', dataIndex: 'isManualCall', key: 'isManualCall', width: 110 },
  { title: '操作', key: 'action', width: 180, fixed: 'right' as const }
]

// ============ 选中行 ============
const selectedRowKeys = ref<number[]>([])

// ============ 方法 ============
const getStatusColor = (status: string) => {
  if (status === 'active') return 'green'
  if (status === 'closed') return 'default'
  if (status === 'expired') return 'orange'
  return 'default'
}

const toggleLeftPanel = () => {
  leftPanelCollapsed.value = !leftPanelCollapsed.value
}

const selectScene = (scene: SceneItem) => {
  selectedSceneId.value = scene.id
}

const handleSearch = () => {
  console.log('搜索场景:', searchKeyword.value)
}

const handleFilterSearch = () => {
  console.log('筛选条件:', filterForm)
}

const handleReset = () => {
  filterForm.sceneKeyword = ''
  filterForm.followStatus = undefined
  selectedTimeRange.value = '7days'
}

const handleAdvancedReset = () => {
  advancedForm.sceneName = ''
  advancedForm.sceneCode = ''
  advancedForm.customerName = ''
  advancedForm.phone = ''
  advancedForm.seatAccount = ''
  advancedForm.followStatus = undefined
  advancedForm.followResult = undefined
}

const handleAdvancedSearch = () => {
  console.log('高级搜索:', advancedForm)
  drawerVisible.value = false
}

const onSelectChange = (keys: number[]) => {
  selectedRowKeys.value = keys
}

const handleFollow = (record: any) => {
  message.info(`去跟进: ${record.customerName}`)
}

const handleCall = (record: any) => {
  message.info(`呼叫: ${record.phone}`)
}

const handleViewDetail = (record: any) => {
  message.info(`查看详情: ${record.customerName}`)
}

const handleTransfer = (record: any) => {
  message.info(`转人工: ${record.customerName}`)
}

const handleBatchExport = () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要导出的数据')
    return
  }
  message.success(`已导出 ${selectedRowKeys.value.length} 条数据`)
}

const handleBatchAssign = () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要分配的数据')
    return
  }
  message.success(`已分配 ${selectedRowKeys.value.length} 条数据`)
}

const handleBatchDelete = () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要删除的数据')
    return
  }
  Modal.confirm({
    title: '确认删除',
    content: `确认删除选中的 ${selectedRowKeys.value.length} 条数据？`,
    okText: '确认',
    cancelText: '取消',
    onOk: () => {
      message.success('删除成功')
      selectedRowKeys.value = []
    }
  })
}

const handleBatchSms = () => {
  if (selectedRowKeys.value.length === 0) {
    message.warning('请先选择要发送短信的数据')
    return
  }
  message.success(`已发送短信 ${selectedRowKeys.value.length} 条`)
}

const handleColumnSetting = () => {
  message.info('列表显示设置')
}
</script>

<style scoped>
.phone-work-workbench {
  padding: 16px;
  background-color: #f5f7fb;
  min-height: 100vh;
}

.main-container {
  height: calc(100vh - 32px);
  display: flex;
  gap: 16px;
  position: relative;
}

/* 左侧面板 */
.left-panel {
  height: 100%;
  overflow: visible;
  position: relative;
  flex-shrink: 0;
}

.expand-btn-wrapper {
  position: absolute;
  left: -8px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 10;
}

.expand-btn {
  width: 13px;
  height: 36px;
  background: #1677ff;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  transition: all 0.3s;
}

.expand-btn:hover {
  background: #4096ff;
}

.task-list-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
  position: relative;
}

.collapse-btn {
  position: absolute;
  top: 50%;
  right: -12px;
  transform: translateY(-50%);
  width: 13px;
  height: 36px;
  background: #1677ff;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  z-index: 10;
  transition: all 0.3s;
}

.collapse-btn:hover {
  background: #4096ff;
}

.search-box {
  margin-bottom: 12px;
}

.scene-search :deep(.ant-input-search-button) {
  background-color: #1677ff;
  border-color: #1677ff;
}

.tab-switch {
  margin-bottom: 12px;
  width: 100%;
}

.tab-switch :deep(.ant-radio-group) {
  display: flex;
  width: 100%;
}

.tab-switch :deep(.ant-radio-button-wrapper) {
  flex: 1;
  text-align: center;
  padding: 0 4px;
  font-size: 13px;
}

.tab-switch :deep(.ant-radio-button-wrapper-checked) {
  color: #fff;
  background-color: #1677ff;
  border-color: #1677ff;
}

/* 排序栏 */
.sort-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.sort-label {
  font-size: 13px;
  color: #595959;
  flex-shrink: 0;
}

/* 场景卡片列表 */
.scene-card-list {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 12px;
}

.scene-card {
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 12px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.scene-card:hover {
  border-color: #1677ff;
  box-shadow: 0 2px 8px rgba(22, 119, 255, 0.15);
}

.scene-card.active {
  border-color: #1677ff;
  background-color: #e6f7ff;
}

.scene-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.scene-title {
  font-weight: 500;
  color: #1f2329;
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
  margin-right: 8px;
}

.scene-status-tag {
  flex-shrink: 0;
  font-size: 12px;
}

.scene-info {
  margin-bottom: 12px;
}

.info-row {
  display: flex;
  margin-bottom: 6px;
  font-size: 13px;
}

.info-row .label {
  color: #8f959e;
  flex-shrink: 0;
}

.info-row .value {
  color: #595959;
}

/* 场景卡片底部 */
.scene-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}

.pending-count {
  font-size: 12px;
  color: #1677ff;
  font-weight: 500;
}

.total-count-tag {
  font-size: 12px;
  color: #8f959e;
}

.pagination-box {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 12px;
  border-top: 1px solid #e8e8e8;
}

.total-count {
  font-size: 12px;
  color: #8f959e;
}

/* 右侧面板 */
.right-panel {
  height: 100%;
  overflow-y: auto;
  flex: 1;
  min-width: 0;
}

.right-panel-full {
  flex: 1;
  max-width: 100%;
}

/* 筛选区域 */
.filter-card {
  margin-bottom: 16px;
  background: #fff;
  padding: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
}

/* 工具栏 */
.intent-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
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

/* 表格卡片 */
.table-card {
  background: #fff;
}

.table-header-info {
  margin-bottom: 12px;
  font-size: 13px;
  color: #595959;
}

.workbench-table :deep(.ant-table-thead > tr > th) {
  background-color: #e6f4ff;
  color: #1f2329;
  font-weight: 500;
}

.workbench-table :deep(.ant-table-tbody > tr:hover > td) {
  background-color: #fafafa;
}

.action-link {
  color: #1677ff;
  cursor: pointer;
  font-size: 13px;
}

.action-link:hover {
  text-decoration: underline;
}

/* 抽屉底部 */
.drawer-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 12px 24px;
  background: #fff;
  border-top: 1px solid #f0f0f0;
  text-align: right;
  z-index: 1;
}

/* 滚动条 */
.scene-card-list::-webkit-scrollbar {
  width: 6px;
}

.scene-card-list::-webkit-scrollbar-thumb {
  background-color: #d9d9d9;
  border-radius: 3px;
}

.scene-card-list::-webkit-scrollbar-thumb:hover {
  background-color: #bfbfbf;
}

.right-panel::-webkit-scrollbar {
  width: 6px;
}

.right-panel::-webkit-scrollbar-thumb {
  background-color: #d9d9d9;
  border-radius: 3px;
}
</style>
