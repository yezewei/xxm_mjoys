<template>
  <div class="customer-analysis">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">客户分析</h2>
            <p class="page-description">多维度交叉分析客户群体，洞察客户特征，支撑精准营销决策。</p>
          </div>
        </div>
      </div>

      <!-- 功能卡片区域 -->
      <div class="feature-cards">
        <a-row :gutter="[16, 16]">
          <a-col :span="8">
            <a-card
              class="feature-card"
              hoverable
              @click="navigateTo('/customer-analysis/cross')"
            >
              <div class="card-content">
                <div class="card-icon cross-icon">
                  <experiment-outlined />
                </div>
                <div class="card-info">
                  <h3 class="card-title">交叉分析</h3>
                  <p class="card-desc">多维度自由组合交叉分析，深度洞察客户群体特征</p>
                  <div class="card-stats">
                    <span class="stat-item">
                      <span class="stat-value">{{ stats.analysisCount }}</span>
                      <span class="stat-label">分析任务</span>
                    </span>
                    <span class="stat-item">
                      <span class="stat-value">{{ stats.dimensionCount }}</span>
                      <span class="stat-label">分析维度</span>
                    </span>
                  </div>
                </div>
              </div>
              <template #actions>
                <span @click.stop="navigateTo('/customer-analysis/cross')">进入分析</span>
                <span @click.stop="navigateTo('/customer-analysis/cross')">快速新建</span>
              </template>
            </a-card>
          </a-col>

          <a-col :span="8">
            <a-card
              class="feature-card"
              hoverable
              @click="navigateTo('/customer-analysis/indicators')"
            >
              <div class="card-content">
                <div class="card-icon indicator-icon">
                  <bar-chart-outlined />
                </div>
                <div class="card-info">
                  <h3 class="card-title">指标管理</h3>
                  <p class="card-desc">管理交叉分析指标体系，统一指标口径和计算逻辑</p>
                  <div class="card-stats">
                    <span class="stat-item">
                      <span class="stat-value">{{ stats.indicatorCount }}</span>
                      <span class="stat-label">指标数量</span>
                    </span>
                    <span class="stat-item">
                      <span class="stat-value">{{ stats.groupCount }}</span>
                      <span class="stat-label">指标分组</span>
                    </span>
                  </div>
                </div>
              </div>
              <template #actions>
                <span @click.stop="navigateTo('/customer-analysis/indicators')">管理指标</span>
                <span @click.stop="navigateTo('/customer-analysis/indicators')">指标分组</span>
              </template>
            </a-card>
          </a-col>

          <a-col :span="8">
            <a-card
              class="feature-card"
              hoverable
              @click="navigateTo('/customer-analysis/reports')"
            >
              <div class="card-content">
                <div class="card-icon report-icon">
                  <file-text-outlined />
                </div>
                <div class="card-info">
                  <h3 class="card-title">定时报告</h3>
                  <p class="card-desc">自动生成交叉分析报告，定时推送至指定接收人</p>
                  <div class="card-stats">
                    <span class="stat-item">
                      <span class="stat-value">{{ stats.templateCount }}</span>
                      <span class="stat-label">报告模板</span>
                    </span>
                    <span class="stat-item">
                      <span class="stat-value">{{ stats.reportCount }}</span>
                      <span class="stat-label">已生成报告</span>
                    </span>
                  </div>
                </div>
              </div>
              <template #actions>
                <span @click.stop="navigateTo('/customer-analysis/templates')">报告模板</span>
                <span @click.stop="navigateTo('/customer-analysis/reports')">报告仓库</span>
              </template>
            </a-card>
          </a-col>
        </a-row>
      </div>

      <!-- 快速开始区域 -->
      <div class="quick-start-section">
        <a-card :bordered="false" class="quick-start-card">
          <template #title>
            <div class="section-title">
              <rocket-outlined />
              <span>快速开始</span>
            </div>
          </template>
          <a-steps :current="0" size="small">
            <a-step title="维护指标" description="配置业务指标体系" />
            <a-step title="创建分析" description="选择维度和指标" />
            <a-step title="查看结果" description="查看交叉分析报告" />
            <a-step title="定时推送" description="配置定时报告" />
          </a-steps>
        </a-card>
      </div>

      <!-- 最近分析区域 -->
      <div class="recent-section">
        <a-card :bordered="false" class="recent-card">
          <template #title>
            <div class="section-title">
              <history-outlined />
              <span>最近分析</span>
            </div>
          </template>
          <a-table
            :columns="recentColumns"
            :data-source="recentData"
            :pagination="false"
            size="small"
            :loading="loading"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'status'">
                <a-badge
                  :status="record.status === 'completed' ? 'success' : record.status === 'running' ? 'processing' : 'default'"
                  :text="getStatusText(record.status)"
                />
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space>
                  <a-button type="link" size="small" @click="viewAnalysis(record)">查看</a-button>
                  <a-button type="link" size="small" @click="exportAnalysis(record)">导出</a-button>
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
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import {
  ExperimentOutlined,
  BarChartOutlined,
  FileTextOutlined,
  RocketOutlined,
  HistoryOutlined,
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { TableColumnType } from 'ant-design-vue';

const router = useRouter();
const loading = ref(false);

// 统计数据
const stats = ref({
  analysisCount: 12,
  dimensionCount: 25,
  indicatorCount: 48,
  groupCount: 5,
  templateCount: 8,
  reportCount: 156,
});

// 最近分析表格列
const recentColumns: TableColumnType[] = [
  {
    title: '分析名称',
    dataIndex: 'analysisName',
    key: 'analysisName',
    ellipsis: true,
  },
  {
    title: '维度组合',
    dataIndex: 'dimensions',
    key: 'dimensions',
    ellipsis: true,
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    width: 100,
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    key: 'createTime',
    width: 180,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    align: 'center',
  },
];

// 最近分析数据
const recentData = ref([
  {
    id: 1,
    analysisName: '月度各网点客户等级×AUM交叉分析',
    dimensions: '网点、客户等级、AUM',
    status: 'completed',
    createTime: '2026-07-09 10:30:00',
  },
  {
    id: 2,
    analysisName: '渠道×产品×活跃度交叉分析',
    dimensions: '渠道、产品、活跃度',
    status: 'completed',
    createTime: '2026-07-08 15:20:00',
  },
  {
    id: 3,
    analysisName: '年龄×性别×交易频次交叉分析',
    dimensions: '年龄、性别、交易频次',
    status: 'running',
    createTime: '2026-07-08 09:00:00',
  },
]);

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    completed: '已完成',
    running: '运行中',
    failed: '失败',
  };
  return statusMap[status] || status;
};

// 导航到指定页面
const navigateTo = (path: string) => {
  router.push(path);
};

// 查看分析详情
const viewAnalysis = (record: any) => {
  router.push(`/customer-analysis/cross/${record.id}`);
};

// 导出分析结果
const exportAnalysis = (record: any) => {
  message.success(`导出"${record.analysisName}"成功`);
};

// 初始化
onMounted(() => {
  // TODO: 加载统计数据和最近分析数据
});
</script>

<style scoped>
.customer-analysis {
  min-height: 100%;
  background: #f5f5f5;
}

.quality-wrapper {
  padding: 24px;
}

.quality-header-section {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.quality-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-left {
  flex: 1;
}

.page-title {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
  color: #1f2329;
}

.page-description {
  margin: 0;
  font-size: 14px;
  color: #646a73;
  line-height: 1.6;
}

/* 功能卡片样式 */
.feature-cards {
  margin-bottom: 16px;
}

.feature-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: all 0.3s;
}

.feature-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.card-content {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.card-icon {
  width: 64px;
  height: 64px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  flex-shrink: 0;
}

.cross-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.indicator-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: #fff;
}

.report-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: #fff;
}

.card-info {
  flex: 1;
}

.card-title {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2329;
}

.card-desc {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #646a73;
  line-height: 1.5;
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
  font-size: 24px;
  font-weight: 600;
  color: #1f2329;
  line-height: 1;
}

.stat-label {
  font-size: 12px;
  color: #8f959e;
  margin-top: 4px;
}

/* 快速开始区域 */
.quick-start-section {
  margin-bottom: 16px;
}

.quick-start-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #1f2329;
}

/* 最近分析区域 */
.recent-section {
  margin-bottom: 16px;
}

.recent-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

:deep(.ant-card-actions) {
  background: #fafafa;
  border-radius: 0 0 8px 8px;
}

:deep(.ant-card-actions > li) {
  margin: 8px 0;
}

:deep(.ant-card-actions > li > span) {
  font-size: 13px;
  color: #1890ff;
  cursor: pointer;
}

:deep(.ant-card-actions > li > span:hover) {
  color: #40a9ff;
}
</style>
