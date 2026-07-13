<template>
  <div class="real-time-model">
    <div class="page-header">
      <h2 class="page-title">实时模型管理</h2>
      <p class="page-desc">管理AI实时识别小模型，在呼通客户电话后自动识别异常情况并触发挂机</p>
    </div>

    <div class="model-cards">
      <div
        v-for="model in modelList"
        :key="model.type"
        class="model-card"
        @click="handleGoConfig(model.type)"
      >
        <div class="card-header">
          <div class="card-icon" :style="{ background: model.iconBg }">
            <component :is="model.icon" style="font-size: 28px; color: #fff" />
          </div>
        </div>
        <div class="card-body">
          <h3 class="card-title">{{ model.name }}</h3>
          <p class="card-desc">{{ model.description }}</p>
        </div>
        <div class="card-footer">
          <div class="card-stats">
            <div class="stat-item">
              <span class="stat-value">{{ model.corpusCount }}</span>
              <span class="stat-label">语料数</span>
            </div>
          </div>
          <div class="card-action">
            <span>配置管理</span>
            <right-outlined />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue';
import { useRouter } from 'vue-router';
import {
  RightOutlined,
  CustomerServiceOutlined,
  WarningOutlined,
} from '@ant-design/icons-vue';

interface ModelItem {
  type: string;
  name: string;
  description: string;
  icon: any;
  iconBg: string;
  corpusCount: number;
}

const router = useRouter();

const modelList = reactive<ModelItem[]>([
  {
    type: 'script-assistant',
    name: '话术助手模型',
    description: 'AI实时识别通话中是否为话术助手接听，检测到话术助手自动触发挂机，避免无效通话消耗资源。',
    icon: CustomerServiceOutlined,
    iconBg: 'linear-gradient(135deg, #1890ff, #096dd9)',
    corpusCount: 180,
  },
  {
    type: 'complaint-abuse',
    name: '投诉骂人模型',
    description: 'AI实时识别通话中客户是否出现投诉或辱骂行为，检测到异常情绪自动触发挂机，保护品牌形象。',
    icon: WarningOutlined,
    iconBg: 'linear-gradient(135deg, #ff4d4f, #cf1322)',
    corpusCount: 248,
  },
]);

const handleGoConfig = (type: string) => {
  router.push({ path: '/real-time-model-config', query: { type } });
};
</script>

<style scoped>
.real-time-model {
  padding: 24px;
}

.page-header {
  margin-bottom: 32px;
}

.page-title {
  font-size: 20px;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0 0 8px 0;
}

.page-desc {
  font-size: 14px;
  color: #8c8c8c;
  margin: 0;
}

.model-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  max-width: 900px;
}

.model-card {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.model-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  border-color: #d9d9d9;
  transform: translateY(-2px);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.card-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-body {
  flex: 1;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0 0 8px 0;
}

.card-desc {
  font-size: 13px;
  color: #8c8c8c;
  line-height: 1.6;
  margin: 0;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid #f5f5f5;
}

.card-stats {
  display: flex;
  gap: 24px;
}

.stat-item {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 20px;
  font-weight: 600;
  color: #1a1a1a;
}

.stat-label {
  font-size: 12px;
  color: #bfbfbf;
  margin-top: 2px;
}

.card-action {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #1890ff;
  font-size: 14px;
}
</style>
