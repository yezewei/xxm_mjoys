<template>
  <div class="cross-analysis-detail">
    <div class="quality-wrapper">
      <!-- 顶部信息栏 -->
      <div class="quality-header-section">
        <div class="quality-header">
          <div class="header-left">
            <h2 class="page-title">{{ analysisData.analysisName }}</h2>
            <p class="page-description">{{ analysisData.description || '暂无描述' }}</p>
          </div>
          <div class="header-right">
            <a-button @click="handleBack">
              <arrow-left-outlined />
              返回
            </a-button>
            <a-button @click="handleRefresh">
              <reload-outlined />
              刷新
            </a-button>
            <a-button type="primary" @click="handleExport">
              <export-outlined />
              导出
            </a-button>
          </div>
        </div>
      </div>

      <!-- 分析信息卡片 -->
      <div class="info-cards">
        <a-row :gutter="16">
          <a-col :span="6">
            <a-card :bordered="false" class="info-card">
              <div class="info-item">
                <span class="info-label">分析维度</span>
                <div class="info-tags">
                  <a-tag v-for="(dim, index) in analysisData.dimensions" :key="index" color="blue">
                    {{ dim }}
                  </a-tag>
                </div>
              </div>
            </a-card>
          </a-col>
          <a-col :span="6">
            <a-card :bordered="false" class="info-card">
              <div class="info-item">
                <span class="info-label">分析指标</span>
                <div class="info-tags">
                  <a-tag v-for="(ind, index) in analysisData.indicators" :key="index" color="cyan">
                    {{ ind }}
                  </a-tag>
                </div>
              </div>
            </a-card>
          </a-col>
          <a-col :span="6">
            <a-card :bordered="false" class="info-card">
              <div class="info-item">
                <span class="info-label">创建信息</span>
                <div class="info-text">
                  <div>{{ analysisData.creator }}</div>
                  <div class="info-time">{{ analysisData.createTime }}</div>
                </div>
              </div>
            </a-card>
          </a-col>
          <a-col :span="6">
            <a-card :bordered="false" class="info-card">
              <div class="info-item">
                <span class="info-label">数据统计</span>
                <div class="info-stats">
                  <div class="stat-row">
                    <span class="stat-label">客户总量：</span>
                    <span class="stat-value">{{ analysisData.totalCustomers?.toLocaleString() }}</span>
                  </div>
                  <div class="stat-row">
                    <span class="stat-label">数据更新：</span>
                    <span class="stat-value">{{ analysisData.updateTime }}</span>
                  </div>
                </div>
              </div>
            </a-card>
          </a-col>
        </a-row>
      </div>

      <!-- 视图切换 -->
      <div class="view-tabs">
        <a-tabs v-model:activeKey="activeView">
          <a-tab-pane key="pivot" tab="透视表">
            <div class="pivot-container">
              <a-table
                :columns="pivotColumns"
                :data-source="pivotData"
                :pagination="false"
                :loading="loading"
                bordered
                size="middle"
                :scroll="{ x: 1200 }"
              >
                <template #bodyCell="{ column, record }">
                  <template v-if="column.key === 'customerCount'">
                    <span class="number-cell">{{ record.customerCount?.toLocaleString() }}</span>
                  </template>
                  <template v-else-if="column.key === 'ratio'">
                    <a-progress
                      :percent="record.ratio"
                      :stroke-color="getProgressColor(record.ratio)"
                      :show-info="true"
                      size="small"
                    />
                  </template>
                  <template v-else-if="column.key === 'yoy'">
                    <span :class="record.yoy >= 0 ? 'up-trend' : 'down-trend'">
                      {{ record.yoy >= 0 ? '+' : '' }}{{ record.yoy }}%
                    </span>
                  </template>
                  <template v-else-if="column.key === 'mom'">
                    <span :class="record.mom >= 0 ? 'up-trend' : 'down-trend'">
                      {{ record.mom >= 0 ? '+' : '' }}{{ record.mom }}%
                    </span>
                  </template>
                </template>
              </a-table>
            </div>
          </a-tab-pane>

          <a-tab-pane key="chart" tab="图表分析">
            <div class="chart-container">
              <a-row :gutter="16">
                <a-col :span="12">
                  <a-card title="客户分布" :bordered="false" class="chart-card">
                    <div class="chart-placeholder">
                      <pie-chart-outlined class="chart-icon" />
                      <p>饼图展示客户分布占比</p>
                    </div>
                  </a-card>
                </a-col>
                <a-col :span="12">
                  <a-card title="趋势分析" :bordered="false" class="chart-card">
                    <div class="chart-placeholder">
                      <line-chart-outlined class="chart-icon" />
                      <p>折线图展示趋势变化</p>
                    </div>
                  </a-card>
                </a-col>
              </a-row>
              <a-row :gutter="16" style="margin-top: 16px;">
                <a-col :span="24">
                  <a-card title="维度对比" :bordered="false" class="chart-card">
                    <div class="chart-placeholder">
                      <bar-chart-outlined class="chart-icon" />
                      <p>柱状图展示各维度对比分析</p>
                    </div>
                  </a-card>
                </a-col>
              </a-row>
            </div>
          </a-tab-pane>

          <a-tab-pane key="detail" tab="数据明细">
            <div class="detail-container">
              <div class="detail-toolbar">
                <a-space>
                  <a-button @click="handleExportDetail">
                    <export-outlined />
                    导出明细
                  </a-button>
                  <a-button @click="handleDrillDown">
                    <eye-outlined />
                    数据下钻
                  </a-button>
                </a-space>
              </div>
              <a-table
                :columns="detailColumns"
                :data-source="detailData"
                :pagination="detailPagination"
                :loading="detailLoading"
                bordered
                size="middle"
                :scroll="{ x: 1500 }"
              />
            </div>
          </a-tab-pane>
        </a-tabs>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import {
  ArrowLeftOutlined,
  ReloadOutlined,
  ExportOutlined,
  PieChartOutlined,
  LineChartOutlined,
  BarChartOutlined,
  EyeOutlined,
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import type { TableColumnType } from 'ant-design-vue';

const router = useRouter();
const route = useRoute();

// 当前视图
const activeView = ref('pivot');
const loading = ref(false);
const detailLoading = ref(false);

// 分析数据
const analysisData = ref({
  id: 1,
  analysisName: '月度各网点客户等级×AUM交叉分析',
  description: '分析各网点不同客户等级和AUM资产规模的分布情况',
  dimensions: ['网点', '客户等级', 'AUM'],
  indicators: ['客户总量', '平均AUM', '月活跃率'],
  creator: '张经理',
  createTime: '2026-07-09 10:30:00',
  updateTime: '2026-07-09 10:30:00',
  totalCustomers: 15680,
});

// 透视表列配置
const pivotColumns: TableColumnType[] = [
  {
    title: '网点',
    dataIndex: 'branch',
    key: 'branch',
    width: 120,
    fixed: 'left',
  },
  {
    title: '客户等级',
    dataIndex: 'customerLevel',
    key: 'customerLevel',
    width: 120,
  },
  {
    title: 'AUM区间',
    dataIndex: 'aumRange',
    key: 'aumRange',
    width: 150,
  },
  {
    title: '客户数量',
    dataIndex: 'customerCount',
    key: 'customerCount',
    width: 120,
    align: 'right',
  },
  {
    title: '占比',
    dataIndex: 'ratio',
    key: 'ratio',
    width: 180,
  },
  {
    title: '平均AUM',
    dataIndex: 'avgAum',
    key: 'avgAum',
    width: 120,
    align: 'right',
  },
  {
    title: '同比',
    dataIndex: 'yoy',
    key: 'yoy',
    width: 100,
    align: 'right',
  },
  {
    title: '环比',
    dataIndex: 'mom',
    key: 'mom',
    width: 100,
    align: 'right',
  },
];

// 透视表数据
const pivotData = ref([
  {
    id: 1,
    branch: '总行营业部',
    customerLevel: 'VIP客户',
    aumRange: '100万+',
    customerCount: 1250,
    ratio: 8.0,
    avgAum: 1850000,
    yoy: 12.5,
    mom: 3.2,
  },
  {
    id: 2,
    branch: '总行营业部',
    customerLevel: '高价值客户',
    aumRange: '50-100万',
    customerCount: 2380,
    ratio: 15.2,
    avgAum: 720000,
    yoy: 8.3,
    mom: 2.1,
  },
  {
    id: 3,
    branch: '总行营业部',
    customerLevel: '潜力客户',
    aumRange: '20-50万',
    customerCount: 3560,
    ratio: 22.7,
    avgAum: 350000,
    yoy: -2.1,
    mom: -1.5,
  },
  {
    id: 4,
    branch: '城东支行',
    customerLevel: 'VIP客户',
    aumRange: '100万+',
    customerCount: 890,
    ratio: 5.7,
    avgAum: 1650000,
    yoy: 15.2,
    mom: 4.5,
  },
  {
    id: 5,
    branch: '城东支行',
    customerLevel: '普通客户',
    aumRange: '5-20万',
    customerCount: 4520,
    ratio: 28.8,
    avgAum: 120000,
    yoy: 5.6,
    mom: 1.8,
  },
]);

// 明细表列配置
const detailColumns: TableColumnType[] = [
  {
    title: '客户号',
    dataIndex: 'customerNo',
    key: 'customerNo',
    width: 150,
  },
  {
    title: '客户名称',
    dataIndex: 'customerName',
    key: 'customerName',
    width: 120,
  },
  {
    title: '网点',
    dataIndex: 'branch',
    key: 'branch',
    width: 120,
  },
  {
    title: '客户等级',
    dataIndex: 'customerLevel',
    key: 'customerLevel',
    width: 100,
  },
  {
    title: 'AUM',
    dataIndex: 'aum',
    key: 'aum',
    width: 120,
    align: 'right',
  },
  {
    title: '性别',
    dataIndex: 'gender',
    key: 'gender',
    width: 80,
  },
  {
    title: '年龄',
    dataIndex: 'age',
    key: 'age',
    width: 80,
  },
  {
    title: '开户时间',
    dataIndex: 'openTime',
    key: 'openTime',
    width: 120,
  },
  {
    title: '联系方式',
    dataIndex: 'contactPhone',
    key: 'contactPhone',
    width: 130,
  },
];

// 明细表数据
const detailData = ref([
  {
    customerNo: 'C202604200001',
    customerName: '张三',
    branch: '总行营业部',
    customerLevel: 'VIP客户',
    aum: 1850000,
    gender: '男',
    age: 45,
    openTime: '2020-03-15',
    contactPhone: '138****1234',
  },
  {
    customerNo: 'C202604200002',
    customerName: '李四',
    branch: '总行营业部',
    customerLevel: 'VIP客户',
    aum: 1650000,
    gender: '女',
    age: 38,
    openTime: '2021-06-20',
    contactPhone: '139****5678',
  },
]);

// 明细分页
const detailPagination = ref({
  current: 1,
  pageSize: 10,
  total: 100,
});

// 获取进度条颜色
const getProgressColor = (percent: number) => {
  if (percent >= 20) return '#52c41a';
  if (percent >= 10) return '#1890ff';
  return '#faad14';
};

// 返回
const handleBack = () => {
  router.push('/customer-analysis/cross');
};

// 刷新
const handleRefresh = () => {
  loading.value = true;
  setTimeout(() => {
    loading.value = false;
    message.success('数据已刷新');
  }, 1000);
};

// 导出
const handleExport = () => {
  message.success('导出成功');
};

// 导出明细
const handleExportDetail = () => {
  message.success('明细导出成功');
};

// 数据下钻
const handleDrillDown = () => {
  message.info('数据下钻功能开发中');
};

// 初始化
onMounted(() => {
  const id = route.params.id;
  // TODO: 根据ID加载分析数据
  loadData();
});

const loadData = () => {
  loading.value = true;
  setTimeout(() => {
    loading.value = false;
  }, 500);
};
</script>

<style scoped>
.cross-analysis-detail {
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
}

.header-right {
  display: flex;
  gap: 12px;
}

/* 信息卡片 */
.info-cards {
  margin-bottom: 16px;
}

.info-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  height: 100%;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-label {
  font-size: 14px;
  color: #8f959e;
  font-weight: 500;
}

.info-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.info-text {
  font-size: 14px;
  color: #1f2329;
}

.info-time {
  font-size: 12px;
  color: #8f959e;
  margin-top: 4px;
}

.info-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.stat-row {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.stat-label {
  color: #8f959e;
}

.stat-value {
  color: #1f2329;
  font-weight: 600;
}

/* 视图切换 */
.view-tabs {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.pivot-container,
.chart-container,
.detail-container {
  margin-top: 16px;
}

.number-cell {
  font-weight: 600;
  color: #1f2329;
}

.up-trend {
  color: #52c41a;
}

.down-trend {
  color: #ff4d4f;
}

.chart-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.chart-placeholder {
  height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #fafafa;
  border-radius: 8px;
  color: #8f959e;
}

.chart-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.detail-toolbar {
  margin-bottom: 16px;
  display: flex;
  justify-content: flex-end;
}

:deep(.ant-progress-text) {
  font-size: 12px;
}
</style>
