<template>
  <div class="quality-model-page">
    <!-- 顶部信息栏 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">质检模型</h1>
        <p class="page-description">
          在质检模型中定义质检规则，大模型和人工根据质检规则，给坐席通话进行质检打标。
        </p>
      </div>
      <a-button type="primary" class="create-btn" @click="handleCreateModel">
        新建质检模型
      </a-button>
    </div>

    <!-- 模型卡片列表 -->
    <div class="model-list">
      <div
        v-for="model in modelList"
        :key="model.id"
        class="model-card"
        :class="{ 'manual-model': model.modelType === 'MANUAL' }"
      >
        <!-- 卡片标题 -->
        <div class="card-header">
          <span class="card-title">{{ model.name }}</span>
          <span class="model-type-icon" :class="model.modelType">
            <template v-if="model.modelType === 'AI'">
              <!-- AI 图标：蓝色六边形宝石图标 -->
              <svg viewBox="0 0 24 24" width="22" height="22">
                <defs>
                  <linearGradient id="aiGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#1677ff;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#0958d9;stop-opacity:1" />
                  </linearGradient>
                </defs>
                <path d="M12 2L4 7v10l8 5 8-5V7L12 2z" fill="url(#aiGradient)"/>
                <text x="12" y="15.5" text-anchor="middle" fill="white" font-size="8" font-weight="600" font-family="Arial">AI</text>
              </svg>
            </template>
            <template v-else>
              <!-- 人工图标：绿色圆形人像图标 -->
              <svg viewBox="0 0 24 24" width="22" height="22">
                <defs>
                  <linearGradient id="manualGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#52c41a;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#389e0d;stop-opacity:1" />
                  </linearGradient>
                </defs>
                <circle cx="12" cy="12" r="10" fill="url(#manualGradient)"/>
                <circle cx="12" cy="9" r="3.5" fill="white"/>
                <path d="M12 13.5c-3.6 0-6.5 1.8-6.5 4.5v1h13v-1c0-2.7-2.9-4.5-6.5-4.5z" fill="white"/>
              </svg>
            </template>
          </span>
        </div>

        <!-- 卡片内容 -->
        <div class="card-body">
          <!-- 模型说明 -->
          <div class="model-info-row">
            <span class="info-label">模型说明：</span>
            <span class="info-value">{{ model.description }}</span>
          </div>

          <!-- 模型类型 -->
          <div class="model-info-row">
            <span class="info-label">模型类型：</span>
            <span class="info-value">
              <template v-if="model.modelType === 'AI'">
                AI 质检模型
              </template>
              <template v-else>
                人工质检模型
              </template>
            </span>
          </div>

          <!-- 模型 ID -->
          <div class="model-info-row">
            <span class="info-label">模型 ID：</span>
            <span class="info-value">{{ model.id }}</span>
          </div>
        </div>

        <!-- 操作按钮 -->
        <div class="card-actions">
          <a-button size="small" class="action-btn" @click="handleRuleSettings(model)">
            质检规则设置
          </a-button>
          <a-dropdown :trigger="['click']">
            <a-button size="small" class="action-btn more-btn">
              更多操作
              <DownOutlined />
            </a-button>
            <template #overlay>
              <a-menu>
                <a-menu-item key="edit" @click="handleEditModel(model)">
                  <EditOutlined /> 编辑模型
                </a-menu-item>
                <a-menu-item key="delete" class="delete-menu-item" @click="handleDeleteModel(model)">
                  <DeleteOutlined style="color: #ff4d4f;" /> 删除模型
                </a-menu-item>
              </a-menu>
            </template>
          </a-dropdown>
        </div>
      </div>
    </div>

    <!-- 删除确认对话框 -->
    <a-modal
      v-model:open="deleteModalVisible"
      title="确认删除"
      ok-text="确认"
      cancel-text="取消"
      @ok="confirmDelete"
    >
      <p>确定要删除质检模型 <strong>{{ deletingModel?.name }}</strong> 吗？</p>
      <p style="color: #ff4d4f;">删除后无法恢复，请谨慎操作！</p>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { message } from 'ant-design-vue'
import {
  DownOutlined,
  EditOutlined,
  DeleteOutlined
} from '@ant-design/icons-vue'

// 质检模型类型定义
interface QualityModel {
  id: number
  name: string
  description: string
  modelType: 'AI' | 'MANUAL'
}

// 模型列表数据
const modelList = ref<QualityModel[]>([
  {
    id: 1,
    name: '合规质检',
    description: '对坐席的合规性、服务质量、产品介绍等方面对客服的综合服务的合规性检测',
    modelType: 'AI'
  },
  {
    id: 2,
    name: '营销意向',
    description: '对客户的沟通对话，判断客户是否有购买的意向，标记客户营销意向',
    modelType: 'AI'
  },
  {
    id: 3,
    name: '投诉倾向',
    description: '对客户的沟通对话，判断客户是否有投诉骂人倾向',
    modelType: 'AI'
  },
  {
    id: 4,
    name: '合规质检（人工）',
    description: '人工质检',
    modelType: 'MANUAL'
  }
])

// 删除对话框状态
const deleteModalVisible = ref(false)
const deletingModel = ref<QualityModel | null>(null)

// 新建模型
const handleCreateModel = () => {
  message.info('新建质检模型功能开发中...')
}

// 质检规则设置
const handleRuleSettings = (model: QualityModel) => {
  message.info(`正在设置"${model.name}"的质检规则...`)
}

// 编辑模型
const handleEditModel = (model: QualityModel) => {
  message.info(`正在编辑"${model.name}"...`)
}

// 删除模型
const handleDeleteModel = (model: QualityModel) => {
  deletingModel.value = model
  deleteModalVisible.value = true
}

// 确认删除
const confirmDelete = () => {
  if (deletingModel.value) {
    modelList.value = modelList.value.filter(m => m.id !== deletingModel.value!.id)
    message.success(`"${deletingModel.value.name}"已删除`)
    deletingModel.value = null
    deleteModalVisible.value = false
  }
}
</script>

<style scoped>
.quality-model-page {
  padding: 24px;
  background-color: #f5f7fb;
  min-height: 100%;
}

/* 顶部信息栏 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  background: #fff;
  padding: 24px;
  border-radius: 4px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03),
              0 1px 6px -1px rgba(0, 0, 0, 0.02),
              0 2px 4px -1px rgba(0, 0, 0, 0.02);
}

.header-content {
  flex: 1;
}

.page-title {
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: 500;
  color: #1f2329;
  line-height: 1.4;
}

.page-description {
  margin: 0;
  font-size: 14px;
  color: #8f959e;
  line-height: 1.6;
}

.create-btn {
  background-color: #1677ff;
  border-color: #1677ff;
  height: 36px;
  padding: 0 20px;
  font-size: 14px;
  border-radius: 4px;
}

.create-btn:hover {
  background-color: #4096ff;
  border-color: #4096ff;
}

/* 模型列表 */
.model-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-content: flex-start;
}

/* 模型卡片 */
.model-card {
  background: #fff;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03),
              0 1px 6px -1px rgba(0, 0, 0, 0.02),
              0 2px 4px -1px rgba(0, 0, 0, 0.02);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  width: 300px;
}

.model-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px 0 rgba(0, 0, 0, 0.08),
              0 2px 4px 0 rgba(0, 0, 0, 0.04);
}

/* 卡片标题区域 */
.card-header {
  background: #e8f3ff;
  padding: 14px 16px;
  border-bottom: 1px solid #d9e8ff;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  gap: 10px;
}

.card-title {
  font-size: 16px;
  font-weight: 500;
  color: #1f2329;
}

.model-type-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.model-type-icon.AI svg {
  filter: drop-shadow(0 1px 2px rgba(22, 119, 255, 0.3));
}

.model-type-icon.MANUAL svg {
  filter: drop-shadow(0 1px 2px rgba(82, 196, 26, 0.3));
}

/* 卡片内容 */
.card-body {
  padding: 14px 16px;
  flex: 1;
}

.model-info-row {
  display: flex;
  margin-bottom: 10px;
  font-size: 14px;
  line-height: 1.5;
  white-space: nowrap;
}

.model-info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  color: #1f2329;
  flex-shrink: 0;
  width: 64px;
  font-weight: 500;
}

.info-value {
  color: #595959;
  flex: 1;
  word-break: break-word;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 卡片操作按钮 */
.card-actions {
  display: flex;
  gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid #f0f0f0;
}

.card-actions .action-btn {
  flex: 1;
  border-color: #d9d9d9;
  color: #595959;
  background: #fff;
  height: 32px;
  font-size: 14px;
  border-radius: 4px;
}

.card-actions .action-btn:hover {
  color: #1677ff;
  border-color: #1677ff;
  background: #fff;
}

.card-actions .more-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

/* 下拉菜单样式 */
:deep(.ant-dropdown-menu-item) {
  display: flex;
  align-items: center;
  gap: 8px;
}

:deep(.delete-menu-item) {
  color: #ff4d4f;
}

:deep(.delete-menu-item:hover) {
  background-color: #fff1f0;
}

/* 响应式调整 */
@media (max-width: 1600px) {
  .model-list {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 1200px) {
  .model-list {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .model-list {
    grid-template-columns: 1fr;
  }

  .page-header {
    flex-direction: column;
    gap: 16px;
  }

  .create-btn {
    width: 100%;
  }
}
</style>
