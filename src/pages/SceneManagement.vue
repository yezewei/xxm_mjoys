<template>
  <div class="scene-management">
    <!-- 顶部标签页 -->
    <a-tabs v-model:activeKey="activeTab" class="scene-tabs">
      <a-tab-pane key="active" tab="开启场景">
        <!-- 标签页操作按钮 -->
        <template #tabBarExtraContent>
          <a-space>
            <a-button @click="handleImportScene">
              <import-outlined />
              导入场景
            </a-button>
            <a-button type="primary" @click="handleCreateScene">
              <plus-outlined />
              创建场景
            </a-button>
          </a-space>
        </template>

        <!-- 搜索区域 -->
        <div class="search-area">
          <a-row :gutter="[16, 16]">
            <!-- 第一行 -->
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.institution"
                placeholder="请选择机构"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="hzbank">杭州银行</a-select-option>
                <a-select-option value="nbbank">宁波银行</a-select-option>
                <a-select-option value="shbank">上海银行</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.sceneName"
                placeholder="请输入场景名称搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.creator"
                placeholder="请输入创建者搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.templateType"
                placeholder="请选择模版类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="collection">催收模版</a-select-option>
                <a-select-option value="marketing">营销模版</a-select-option>
                <a-select-option value="service">服务模版</a-select-option>
              </a-select>
            </a-col>
            <!-- 第二行 -->
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.templateSubtype"
                placeholder="请选择模版子类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="loan">贷款类</a-select-option>
                <a-select-option value="credit_card">信用卡类</a-select-option>
                <a-select-option value="deposit">存款类</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.outboundStatus"
                placeholder="请选择外呼状态"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="running">外呼中</a-select-option>
                <a-select-option value="paused">已暂停</a-select-option>
                <a-select-option value="completed">已完成</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.sceneCode"
                placeholder="请输入场景编号搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-space>
                <a-button type="primary" @click="handleSearch">
                  <search-outlined />
                  搜索
                </a-button>
                <a-button @click="handleReset">
                  <reload-outlined />
                  重置
                </a-button>
              </a-space>
            </a-col>
          </a-row>
        </div>

        <!-- 操作按钮区域 -->
        <div class="toolbar-area">
          <div class="toolbar-left">
            <span class="total-info">共 {{ total }} 条</span>
          </div>
          <div class="toolbar-right">
            <a-select
              v-model:value="sortOrder"
              placeholder="按编辑时间排序"
              style="width: 180px"
            >
              <a-select-option value="desc">编辑时间降序</a-select-option>
              <a-select-option value="asc">编辑时间升序</a-select-option>
            </a-select>
          </div>
        </div>

        <!-- 场景卡片列表 -->
        <div class="scene-list">
          <a-row :gutter="[16, 16]">
            <a-col
              v-for="scene in sceneList"
              :key="scene.id"
              :xs="24"
              :sm="24"
              :md="12"
              :lg="8"
              :xl="8"
            >
              <div class="scene-card">
                <!-- 卡片头部 -->
                <div class="card-header">
                  <div class="header-left">
                    <div class="scene-title">
                      <span class="title-indicator"></span>
                      <span class="title-text">{{ scene.name }}</span>
                    </div>
                    <a-tag v-if="scene.tag" :color="scene.tagColor">{{ scene.tag }}</a-tag>
                  </div>
                  <div class="header-right">
                    <span class="expire-time">到期时间：{{ scene.expireTime }}</span>
                  </div>
                </div>

                <!-- 卡片内容 -->
                <div class="card-body">
                  <div class="body-columns">
                    <!-- 左列 -->
                    <div class="column-left">
                      <div class="info-item">
                        <span class="label">语音类型：</span>
                        <span class="value">{{ scene.voiceType }}</span>
                      </div>
                      <div class="info-item">
                        <span class="label">平台版本/行方版本：</span>
                        <span class="value">{{ scene.platformVersion }}</span>
                      </div>
                      <div class="info-item">
                        <span class="label">跟进方式：</span>
                        <span class="value">{{ scene.followUpMethod }}</span>
                      </div>
                    </div>

                    <!-- 中列 -->
                    <div class="column-middle">
                      <div class="info-item">
                        <span class="label">是否启用：</span>
                        <a-switch
                          v-model:checked="scene.enabled"
                          size="small"
                          @change="handleEnabledChange(scene)"
                        />
                      </div>
                      <div class="info-item">
                        <span class="label">外呼状态：</span>
                        <span class="value">{{ scene.outboundStatus }}</span>
                        <a class="update-link" @click="handleRefreshStatus">每 1 分钟更新</a>
                      </div>
                    </div>

                    <!-- 右列 -->
                    <div class="column-right">
                      <div class="info-item">
                        <span class="label">场景编号：</span>
                        <span class="value">{{ scene.code }}</span>
                      </div>
                      <div class="info-item">
                        <span class="label">创建时间：</span>
                        <span class="value">{{ scene.createTime }}</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 右侧操作按钮 -->
                <div class="card-actions">
                  <div class="action-row">
                    <a class="action-link" @click="handleView(scene)">查看</a>
                    <a class="action-link" @click="handleReport(scene)">报表</a>
                  </div>
                  <div class="action-row">
                    <a class="action-link" @click="handlePublish(scene)">发布</a>
                    <a class="action-link" @click="handleExport(scene)">导出</a>
                  </div>
                  <div class="action-row">
                    <a class="action-link" @click="handleCopy(scene)">复制</a>
                    <a class="action-link danger" @click="handleDelete(scene)">删除</a>
                  </div>
                </div>

                <!-- 底部操作链接 -->
                <div class="card-footer">
                  <a class="footer-link" @click="handleSceneCheck(scene)">场景检测</a>
                  <span class="divider">|</span>
                  <a class="footer-link" @click="handleScriptCheck(scene)">话术完整性检查</a>
                  <span class="divider">|</span>
                  <a class="footer-link" @click="handleViewTimeSlot(scene)">查看拨打时间段</a>
                  <span class="divider">|</span>
                  <a class="footer-link" @click="handleAddDataBatch(scene)">添加数据批次</a>
                  <span class="divider">|</span>
                  <a class="footer-link" @click="handleQuickTest(scene)">快速拨测</a>
                  <span class="divider">|</span>
                  <a class="footer-link" @click="handleScriptTest(scene)">话术测试</a>
                </div>
              </div>
            </a-col>
          </a-row>
        </div>

        <!-- 分页 -->
        <div class="pagination-area">
          <a-pagination
            v-model:current="pagination.current"
            v-model:page-size="pagination.pageSize"
            :total="pagination.total"
            :page-size-options="pagination.pageSizeOptions"
            show-size-changer
            show-quick-jumper
            :show-total="(total: number) => `共 ${total} 条`"
            @change="handlePageChange"
            @show-size-change="handlePageSizeChange"
          />
        </div>
      </a-tab-pane>

      <a-tab-pane key="closed" tab="关闭场景">
        <a-empty description="暂无关闭场景" />
      </a-tab-pane>

      <a-tab-pane key="expired" tab="过期场景">
        <a-empty description="暂无过期场景" />
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  ImportOutlined,
  PlusOutlined,
} from '@ant-design/icons-vue';
import type { MessageArgs } from 'ant-design-vue/es/message';

// 场景数据接口
interface SceneItem {
  id: number;
  name: string;
  tag?: string;
  tagColor?: string;
  expireTime: string;
  voiceType: string;
  platformVersion: string;
  followUpMethod: string;
  enabled: boolean;
  outboundStatus: string;
  code: string;
  createTime: string;
}

// 搜索表单数据
interface SearchForm {
  institution: string | undefined;
  sceneName: string | undefined;
  creator: string | undefined;
  templateType: string | undefined;
  templateSubtype: string | undefined;
  outboundStatus: string | undefined;
  sceneCode: string | undefined;
}

// 当前激活的标签页
const activeTab = ref<string>('active');

// 搜索表单
const searchForm = reactive<SearchForm>({
  institution: undefined,
  sceneName: undefined,
  creator: undefined,
  templateType: undefined,
  templateSubtype: undefined,
  outboundStatus: undefined,
  sceneCode: undefined,
});

// 排序方式
const sortOrder = ref<string>('desc');

// 总数
const total = ref<number>(5);

// 分页配置
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 5,
  pageSizeOptions: ['10', '20', '50', '100'],
});

// 场景列表数据（5 条模拟数据）
const sceneList = ref<SceneItem[]>([
  {
    id: 1,
    name: '贷款转存 - 接通即转（叶泽伟测试）',
    tag: '热门',
    tagColor: 'red',
    expireTime: '2026-12-31',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309001',
    createTime: '2026-03-01 10:30:00',
  },
  {
    id: 2,
    name: '信用卡逾期催收场景',
    tag: '推荐',
    tagColor: 'green',
    expireTime: '2026-06-30',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: '人工跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309002',
    createTime: '2026-03-02 14:20:00',
  },
  {
    id: 3,
    name: '新客户营销回访',
    expireTime: '2026-09-30',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: false,
    outboundStatus: '已暂停',
    code: 'SCENE20260309003',
    createTime: '2026-03-03 09:15:00',
  },
  {
    id: 4,
    name: '存款到期提醒场景',
    tag: '新品',
    tagColor: 'blue',
    expireTime: '2026-12-31',
    voiceType: '混合语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI + 人工',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309004',
    createTime: '2026-03-05 16:45:00',
  },
  {
    id: 5,
    name: '理财产品推广场景',
    expireTime: '2026-08-31',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: '人工跟进',
    enabled: true,
    outboundStatus: '已完成',
    code: 'SCENE20260309005',
    createTime: '2026-03-07 11:00:00',
  },
]);

/**
 * 搜索按钮点击
 */
const handleSearch = () => {
  console.log('执行搜索:', searchForm);
  // TODO: 实现搜索逻辑
};

/**
 * 重置按钮点击
 */
const handleReset = () => {
  searchForm.institution = undefined;
  searchForm.sceneName = undefined;
  searchForm.creator = undefined;
  searchForm.templateType = undefined;
  searchForm.templateSubtype = undefined;
  searchForm.outboundStatus = undefined;
  searchForm.sceneCode = undefined;
  // TODO: 重置后重新加载数据
};

/**
 * 导入场景
 */
const handleImportScene = () => {
  console.log('导入场景');
  // TODO: 实现导入逻辑
};

/**
 * 创建场景
 */
const handleCreateScene = () => {
  console.log('创建场景');
  // TODO: 实现创建逻辑
};

/**
 * 启用状态变更
 */
const handleEnabledChange = (scene: SceneItem) => {
  console.log(`场景 ${scene.name} 启用状态变更为：${scene.enabled}`);
  // TODO: 调用接口更新状态
};

/**
 * 刷新外呼状态
 */
const handleRefreshStatus = () => {
  console.log('刷新外呼状态');
  // TODO: 实现刷新逻辑
};

/**
 * 查看场景
 */
const handleView = (scene: SceneItem) => {
  console.log('查看场景:', scene.name);
  // TODO: 跳转到详情页
};

/**
 * 查看报表
 */
const handleReport = (scene: SceneItem) => {
  console.log('查看报表:', scene.name);
  // TODO: 跳转到报表页
};

/**
 * 发布场景
 */
const handlePublish = (scene: SceneItem) => {
  console.log('发布场景:', scene.name);
  // TODO: 实现发布逻辑
};

/**
 * 导出场景
 */
const handleExport = (scene: SceneItem) => {
  console.log('导出场景:', scene.name);
  // TODO: 实现导出逻辑
};

/**
 * 复制场景
 */
const handleCopy = (scene: SceneItem) => {
  console.log('复制场景:', scene.name);
  // TODO: 实现复制逻辑
};

/**
 * 删除场景
 */
const handleDelete = (scene: SceneItem) => {
  console.log('删除场景:', scene.name);
  // TODO: 实现删除逻辑（需二次确认）
};

/**
 * 场景检测
 */
const handleSceneCheck = (scene: SceneItem) => {
  console.log('场景检测:', scene.name);
  // TODO: 实现场景检测逻辑
};

/**
 * 话术完整性检查
 */
const handleScriptCheck = (scene: SceneItem) => {
  console.log('话术完整性检查:', scene.name);
  // TODO: 实现话术检查逻辑
};

/**
 * 查看拨打时间段
 */
const handleViewTimeSlot = (scene: SceneItem) => {
  console.log('查看拨打时间段:', scene.name);
  // TODO: 实现查看时间段逻辑
};

/**
 * 添加数据批次
 */
const handleAddDataBatch = (scene: SceneItem) => {
  console.log('添加数据批次:', scene.name);
  // TODO: 实现添加数据批次逻辑
};

/**
 * 快速拨测
 */
const handleQuickTest = (scene: SceneItem) => {
  console.log('快速拨测:', scene.name);
  // TODO: 实现快速拨测逻辑
};

/**
 * 话术测试
 */
const handleScriptTest = (scene: SceneItem) => {
  console.log('话术测试:', scene.name);
  // TODO: 实现话术测试逻辑
};

/**
 * 分页变更
 */
const handlePageChange = (page: number, pageSize: number) => {
  console.log('分页变更:', page, pageSize);
  // TODO: 加载对应页数据
};

/**
 * 每页条数变更
 */
const handlePageSizeChange = (current: number, size: number) => {
  console.log('每页条数变更:', current, size);
  // TODO: 加载对应页数据
};
</script>

<style scoped>
.scene-management {
  padding: 0;
}

/* 标签页样式 */
.scene-tabs {
  background: #fff;
  padding: 16px 24px;
  min-height: calc(100vh - 100px);
}

.scene-tabs :deep(.ant-tabs-nav) {
  margin-bottom: 16px;
}

.scene-tabs :deep(.ant-tabs-tab) {
  font-size: 15px;
  font-weight: 500;
}

/* 搜索区域 */
.search-area {
  padding: 16px;
  background: #fafafa;
  border-radius: 4px;
  margin-bottom: 16px;
}

/* 工具栏区域 */
.toolbar-area {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 0 4px;
}

.toolbar-left {
  display: flex;
  align-items: center;
}

.total-info {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}

.toolbar-right {
  display: flex;
  align-items: center;
}

/* 场景列表 */
.scene-list {
  margin-bottom: 24px;
}

/* 场景卡片 */
.scene-card {
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.3s;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.scene-card:hover {
  border-color: #1890ff;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.15);
}

/* 卡片头部 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
}

.scene-title {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.title-indicator {
  width: 4px;
  height: 18px;
  background: #1890ff;
  border-radius: 2px;
  flex-shrink: 0;
}

.title-text {
  font-size: 15px;
  font-weight: 600;
  color: #262626;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header-right {
  flex-shrink: 0;
}

.expire-time {
  font-size: 12px;
  color: #8c8c8c;
  white-space: nowrap;
}

/* 卡片内容 */
.card-body {
  flex: 1;
  margin-bottom: 16px;
}

.body-columns {
  display: flex;
  gap: 24px;
}

.column-left,
.column-middle,
.column-right {
  flex: 1;
  min-width: 0;
}

.info-item {
  display: flex;
  align-items: flex-start;
  margin-bottom: 8px;
  font-size: 13px;
  line-height: 1.6;
}

.info-item:last-child {
  margin-bottom: 0;
}

.label {
  color: #8c8c8c;
  flex-shrink: 0;
  white-space: nowrap;
}

.value {
  color: #262626;
  word-break: break-word;
}

.update-link {
  color: #1890ff;
  font-size: 12px;
  margin-left: 4px;
  cursor: pointer;
}

.update-link:hover {
  color: #40a9ff;
}

/* 卡片操作按钮 */
.card-actions {
  padding-top: 12px;
  padding-bottom: 12px;
  border-top: 1px solid #f0f0f0;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 12px;
}

.action-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.action-row:last-child {
  margin-bottom: 0;
}

.action-link {
  font-size: 13px;
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
}

.action-link:hover {
  background: #e6f7ff;
  color: #40a9ff;
}

.action-link.danger {
  color: #ff4d4f;
}

.action-link.danger:hover {
  background: #fff1f0;
  color: #ff7875;
}

/* 卡片底部 */
.card-footer {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px;
}

.footer-link {
  font-size: 12px;
  color: #595959;
  cursor: pointer;
  text-decoration: none;
  padding: 2px 4px;
  border-radius: 2px;
  transition: all 0.3s;
}

.footer-link:hover {
  color: #1890ff;
  background: #f0f5ff;
}

.divider {
  color: #d9d9d9;
  font-size: 12px;
}

/* 分页区域 */
.pagination-area {
  display: flex;
  justify-content: flex-end;
  padding-top: 16px;
}

/* 空状态 */
.scene-tabs :deep(.ant-empty) {
  padding: 48px 0;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .body-columns {
    flex-direction: column;
    gap: 12px;
  }

  .card-header {
    flex-direction: column;
    gap: 8px;
  }

  .header-right {
    width: 100%;
    text-align: right;
  }

  .card-footer {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .card-footer .divider {
    display: none;
  }
}
</style>
