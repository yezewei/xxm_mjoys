<template>
  <div class="scene-detail">
    <!-- 顶部标签页 -->
    <div class="tabs-section">
      <a-tabs v-model:activeKey="activeTabKey" @change="handleTabChange">
        <a-tab-pane key="basic" data-tab-key="basic" tab="基本信息" />
        <a-tab-pane key="process" data-tab-key="process" tab="主流程设置" />
        <a-tab-pane key="qa" data-tab-key="qa" tab="QA 库" />
        <a-tab-pane key="intent" data-tab-key="intent" tab="意图库" />
        <a-tab-pane key="fallback" data-tab-key="fallback" tab="流程兜底设置" />
        <a-tab-pane key="script" data-tab-key="script" tab="话术管理" />
        <a-tab-pane key="user-classify" data-tab-key="user-classify" tab="用户分类" />
        <a-tab-pane key="system-settings" data-tab-key="system-settings" tab="场景系统设置" />
        <a-tab-pane key="sms" data-tab-key="sms" tab="场景短信" />
      </a-tabs>
    </div>

    <!-- 各 Tab 内容区域 -->
    <div class="tab-content">
      <!-- 基本信息 -->
      <BasicInfoTab v-if="activeTabKey === 'basic'" v-model="basicFormData" />

      <!-- 主流程设置 -->
      <ProcessSettingTab
        v-if="activeTabKey === 'process'"
        v-model:nodes="processNodes"
        v-model:connections="connections"
        @save="handleProcessSave"
      />

      <!-- QA 库 -->
      <QaLibraryTab
        v-if="activeTabKey === 'qa'"
        v-model="qaData"
        @create="handleCreateQa"
        @reference="handleReferenceQa"
        @delete="handleDeleteQa"
      />

      <!-- 意图库 -->
      <IntentLibraryTab
        v-if="activeTabKey === 'intent'"
        v-model="intentData"
        @create="handleCreateIntent"
        @reference="handleReferenceIntent"
        @delete="handleDeleteIntent"
      />

      <!-- 流程兜底设置 -->
      <FallbackSettingTab
        v-if="activeTabKey === 'fallback'"
        v-model="fallbackData"
        @save="handleSaveFallback"
        @reset="handleResetFallback"
      />

      <!-- 话术管理 -->
      <ScriptManagementTab
        v-if="activeTabKey === 'script'"
        v-model="scriptData"
        @edit="handleEditScript"
        @compliance="handleComplianceCheck"
      />

      <!-- 用户分类 -->
      <UserClassifyTab
        v-if="activeTabKey === 'user-classify'"
        v-model="userClassifyData"
        @save="handleSaveClassify"
      />

      <!-- 场景系统设置 -->
      <SystemSettingsTab
        v-if="activeTabKey === 'system-settings'"
        v-model="systemSettingsData"
        @save="handleSaveSystemSettings"
      />

      <!-- 场景短信 -->
      <SmsManagementTab
        v-if="activeTabKey === 'sms'"
        v-model="smsData"
        @create="handleCreateSms"
        @edit="handleEditSms"
        @delete="handleDeleteSms"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { message, Modal } from 'ant-design-vue';

// 导入可复用的 Tab 组件
import {
  BasicInfoTab,
  ProcessSettingTab,
  QaLibraryTab,
  IntentLibraryTab,
  FallbackSettingTab,
  ScriptManagementTab,
  UserClassifyTab,
  SystemSettingsTab,
  SmsManagementTab,
} from '@/components/SceneTemplateTabs';

const router = useRouter();
const route = useRoute();

// ==================== 各 Tab 数据 ====================

// 当前激活的 Tab
const activeTabKey = ref('basic');

// 基本信息数据
const basicFormData = ref({
  templateName: '信用卡激活场景',
  templateType: ['信用卡', '信用卡激活'],
  tags: ['信用卡', '激活流程', '高频场景'],
  followType: 'sms+manual',
  description: '适用于信用卡新卡激活场景，包含完整的激活流程指引和常见问题解答',
  targetCustomer: '持有未激活信用卡的新客户，包括个人客户和企业客户',
  applicableActivity: '2026 年信用卡开卡礼活动、首刷礼活动、新户专享理财活动',
  financialProduct: '信用卡产品：标准金卡、白金卡、钻石卡；关联产品：消费分期、账单分期、现金分期',
});

// 主流程数据
const processNodes = ref<any[]>([]);
const connections = ref<any[]>([]);
const intentList = ref<any[]>([]);

// QA 库数据
const qaData = ref<any>({});

// 意图库数据
const intentData = ref<any>({});

// 流程兜底数据
const fallbackData = ref<any>({});

// 话术管理数据
const scriptData = ref<any>({});

// 用户分类数据
const userClassifyData = ref<any>({});

// 场景系统设置数据
const systemSettingsData = ref<any>({});

// 场景短信数据
const smsData = ref<any>({});

// ==================== 方法定义 ====================

/**
 * Tab 切换
 */
const handleTabChange = (key: string) => {
  console.log('切换 Tab:', key);
};

/**
 * 主流程保存
 */
const handleProcessSave = (data: { nodes: any[]; connections: any[] }) => {
  console.log('主流程保存:', data);
  // TODO: 实现保存逻辑
};

/**
 * 创建 QA
 */
const handleCreateQa = () => {
  console.log('创建 QA');
  // TODO: 实现创建逻辑
};

/**
 * 引用 QA
 */
const handleReferenceQa = () => {
  console.log('引用 QA');
  // TODO: 实现引用逻辑
};

/**
 * 删除 QA
 */
const handleDeleteQa = (qa: any) => {
  console.log('删除 QA:', qa);
  // TODO: 实现删除逻辑
};

/**
 * 创建意图
 */
const handleCreateIntent = () => {
  console.log('创建意图');
  // TODO: 实现创建逻辑
};

/**
 * 引用意图
 */
const handleReferenceIntent = () => {
  console.log('引用意图');
  // TODO: 实现引用逻辑
};

/**
 * 删除意图
 */
const handleDeleteIntent = (intent: any) => {
  console.log('删除意图:', intent);
  // TODO: 实现删除逻辑
};

/**
 * 保存兜底设置
 */
const handleSaveFallback = (data: any) => {
  console.log('保存兜底设置:', data);
  // TODO: 实现保存逻辑
};

/**
 * 重置兜底设置
 */
const handleResetFallback = () => {
  console.log('重置兜底设置');
  // TODO: 实现重置逻辑
};

/**
 * 编辑话术
 */
const handleEditScript = (script: any) => {
  console.log('编辑话术:', script);
  // TODO: 实现编辑逻辑
};

/**
 * 消保检查
 */
const handleComplianceCheck = (script: any) => {
  console.log('消保检查:', script);
  // TODO: 实现消保逻辑
};

/**
 * 保存用户分类
 */
const handleSaveClassify = (data: any) => {
  console.log('保存用户分类:', data);
  // TODO: 实现保存逻辑
};

/**
 * 保存系统设置
 */
const handleSaveSystemSettings = (data: any) => {
  console.log('保存系统设置:', data);
  // TODO: 实现保存逻辑
};

/**
 * 创建短信
 */
const handleCreateSms = () => {
  console.log('创建短信');
  // TODO: 实现创建逻辑
};

/**
 * 编辑短信
 */
const handleEditSms = (sms: any) => {
  console.log('编辑短信:', sms);
  // TODO: 实现编辑逻辑
};

/**
 * 删除短信
 */
const handleDeleteSms = (sms: any) => {
  console.log('删除短信:', sms);
  // TODO: 实现删除逻辑
};

// ==================== 生命周期 ====================

onMounted(() => {
  // 获取场景 ID
  const sceneId = route.params.id as string;
  
  // TODO: 根据场景 ID 加载场景详情数据
  console.log('加载场景详情:', sceneId);
});
</script>

<style scoped>
.scene-detail {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f0f2f5;
  padding: 16px;
}

/* 标签页区域 */
.tabs-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

:deep(.ant-tabs) {
  margin-bottom: 0;
}

:deep(.ant-tabs-nav) {
  margin: 0;
}

/* Tab 内容区域 */
.tab-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.tab-content > div,
.tab-content > .process-setting-tab {
  height: 100%;
  background: #fff;
  border-radius: 4px;
}

/* ==================== 主流程设置样式 ==================== */
/* 覆盖 ProcessSettingTab 组件的样式，使其与 SceneTemplateDetail 一致 */
:deep(.process-setting-tab) {
  height: 100%;
  overflow: hidden;
  background: #f5f5f5;
}

:deep(.process-content) {
  height: 100%;
  overflow: hidden;
  background: #f5f5f5;
}

:deep(.process-wrapper) {
  height: 100%;
}

:deep(.process-canvas-wrapper) {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
}

:deep(.canvas-toolbar) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
  flex-shrink: 0;
}

:deep(.toolbar-left),
:deep(.toolbar-right) {
  display: flex;
  align-items: center;
  gap: 8px;
}

:deep(.zoom-text) {
  font-size: 13px;
  color: #595959;
  margin-left: 8px;
}

/* 节点添加栏（固定在画布区域顶部） */
:deep(.node-palette) {
  position: relative;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  flex-shrink: 0;
}

:deep(.palette-content) {
  display: flex;
  gap: 8px;
  padding: 12px;
  overflow-x: auto;
  background: #fff;
}

:deep(.palette-node-item) {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f5f5f5;
  border-radius: 4px;
  cursor: grab;
  transition: all 0.2s;
  font-size: 12px;
  color: #1f1f1f;
}

:deep(.palette-node-item:hover) {
  background: #e6f7ff;
  border-color: #1890ff;
}

.process-canvas {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
  min-height: 0;
}

:deep(.canvas-content) {
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
}

:deep(.connection-layer) {
  position: absolute;
  top: 0;
  left: 0;
  pointer-events: none;
  z-index: 1;
}

:deep(.connection-hit) {
  fill: none;
  stroke: transparent;
  stroke-width: 20;
  cursor: pointer;
  pointer-events: stroke;
}

:deep(.connection-line) {
  fill: none;
  stroke: #91d5ff;
  stroke-width: 2;
  marker-end: url(#arrowhead);
  pointer-events: none;
  transition: all 0.3s;
}

:deep(.connection-selected .connection-line) {
  stroke: #1890ff;
  stroke-width: 3;
  marker-end: url(#arrowhead-selected);
}

:deep(.connection-delete) {
  cursor: pointer;
  pointer-events: all;
}

/* :deep(.process-node) {
  position: absolute;
  width: 200px;
  height: 80px;
  background: #fff;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  cursor: move;
  z-index: 2;
  transition: box-shadow 0.2s;
} */

:deep(.process-node:hover) {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

:deep(.process-node.node-selected) {
  border-color: #1890ff;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.3);
}

:deep(.node-header) {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
  border-radius: 4px 4px 0 0;
}

:deep(.node-title) {
  flex: 1;
  font-size: 12px;
  font-weight: 500;
  color: #1f1f1f;
}

:deep(.node-actions) {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s;
}

:deep(.process-node:hover .node-actions) {
  opacity: 1;
}

:deep(.node-action-btn) {
  padding: 2px 4px;
  font-size: 12px;
}

:deep(.node-content) {
  padding: 12px;
  font-size: 12px;
  color: #666;
}

:deep(.node-desc) {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

:deep(.node-connector) {
  position: absolute;
  width: 12px;
  height: 12px;
  background: #fff;
  border: 2px solid #1890ff;
  border-radius: 50%;
}

:deep(.node-connector:hover) {
  background: #1890ff;
}

:deep(.node-connector-out) {
  left: 50%;
  transform: translateX(-50%);
}

:deep(.node-connector-in) {
  top: -6px;
  left: 50%;
  transform: translateX(-50%);
}

:deep(.temp-connection-layer) {
  position: absolute;
  top: 0;
  left: 0;
  pointer-events: none;
  z-index: 3;
}

:deep(.temp-connection-line) {
  stroke: #1890ff;
  stroke-width: 2px;
  stroke-dasharray: 5, 5;
  fill: none;
}

:deep(.intent-tags) {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  justify-content: center;
}

:deep(.modal-footer) {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 16px;
}

:deep(.intent-select-list) {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 300px;
  overflow-y: auto;
}

:deep(.selected-intent-tags) {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

:deep(.form-tip) {
  color: #999;
  font-size: 12px;
}

/* 节点类型样式 */
:deep(.node-type-start) {
  border-left: 4px solid #52c41a;
}

:deep(.node-type-script) {
  border-left: 4px solid #1890ff;
}

:deep(.node-type-success_end) {
  border-left: 4px solid #52c41a;
}

:deep(.node-type-fail_end) {
  border-left: 4px solid #ff4d4f;
}

:deep(.node-type-transfer) {
  border-left: 4px solid #faad14;
}

:deep(.node-type-verify) {
  border-left: 4px solid #722ed1;
}
</style>
