<template>
  <div class="call-funnel">
    <!-- 页面标题区域 -->
    <div class="page-header-section">
      <div class="page-header">
        <div class="header-left">
          <h2 class="page-title">外呼漏斗图</h2>
          <p class="page-description">展示从上传到转化各阶段客户数量的漏斗转化情况</p>
        </div>
      </div>
    </div>

    <!-- 搜索区域 -->
    <div class="search-area">
      <a-row :gutter="[16, 16]">
        <a-col :span="6">
          <a-select v-model:value="searchForm.scene" placeholder="请选择外呼场景" allow-clear style="width: 100%">
            <a-select-option value="scene1">贷款转存 - 接通即转</a-select-option>
            <a-select-option value="scene2">信用卡营销</a-select-option>
            <a-select-option value="scene3">理财推荐</a-select-option>
          </a-select>
        </a-col>
        <a-col :span="6">
          <a-select v-model:value="searchForm.batchType" placeholder="数据批次类型" allow-clear style="width: 100%">
            <a-select-option value="test">测试批次</a-select-option>
            <a-select-option value="prod">正式批次</a-select-option>
          </a-select>
        </a-col>
        <a-col :span="6">
          <a-range-picker
            v-model:value="searchForm.dateRange"
            show-time
            format="YYYY-MM-DD HH:mm"
            style="width: 100%"
            :placeholder="['开始时间', '结束时间']"
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

    <!-- 统计卡片区域 -->
    <div class="stats-cards">
      <div v-for="(item, index) in funnelData" :key="item.name" class="stat-card">
        <div class="stat-card-icon" :style="{ background: funnelColors[index] }">
          <span class="stat-card-icon-text">{{ index + 1 }}</span>
        </div>
        <div class="stat-card-content">
          <div class="stat-card-label">{{ item.name }}</div>
          <div class="stat-card-value">{{ item.value.toLocaleString() }}</div>
        </div>
        <div v-if="index > 0" class="stat-card-rate">
          <div class="stat-card-rate-label">转化率</div>
          <div class="stat-card-rate-value">{{ getConversionRate(index) }}</div>
        </div>
      </div>
    </div>

    <!-- 漏斗图区域 -->
    <div class="funnel-section">
      <div class="funnel-chart-wrapper">
        <div ref="funnelChartRef" class="funnel-chart"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons-vue';
import * as echarts from 'echarts';

// 搜索表单
const searchForm = reactive({
  scene: undefined as string | undefined,
  batchType: undefined as string | undefined,
  dateRange: null as any,
});

// 漏斗数据
const funnelData = ref([
  { name: '上传客户数', value: 10000 },
  { name: '外呼客户数', value: 8500 },
  { name: '接通客户数', value: 6200 },
  { name: '意向客户数', value: 3100 },
  { name: '转化客户数', value: 1240 },
]);

// 漏斗颜色
const funnelColors = ['#5B8FF9', '#5AD8A6', '#F6BD16', '#E86452', '#6DC8EC'];

// 漏斗图实例
const funnelChartRef = ref<HTMLElement | null>(null);
let funnelChart: echarts.ECharts | null = null;

// 计算转化率
const getConversionRate = (index: number): string => {
  if (index === 0) return '-';
  const current = funnelData.value[index].value;
  const previous = funnelData.value[index - 1].value;
  const rate = ((current / previous) * 100).toFixed(1);
  return `${rate}%`;
};

// 初始化漏斗图
const initFunnelChart = () => {
  if (!funnelChartRef.value) return;

  funnelChart = echarts.init(funnelChartRef.value);

  const option: echarts.EChartsOption = {
    tooltip: {
      trigger: 'item',
      formatter: (params: any) => {
        const data = params.data;
        const index = funnelData.value.findIndex(item => item.name === data.name);
        let rateInfo = '';
        if (index > 0) {
          rateInfo = `<br/>转化率: ${getConversionRate(index)}`;
        }
        return `<strong>${data.name}</strong><br/>数量: ${data.value.toLocaleString()}${rateInfo}`;
      },
    },
    legend: {
      orient: 'horizontal',
      bottom: 10,
      data: funnelData.value.map(item => item.name),
      itemWidth: 14,
      itemHeight: 14,
      itemGap: 24,
      textStyle: {
        fontSize: 13,
        color: '#595959',
      },
    },
    series: [
      {
        name: '外呼漏斗',
        type: 'funnel',
        left: '10%',
        top: 20,
        bottom: 60,
        width: '80%',
        min: 0,
        max: 10000,
        minSize: '10%',
        maxSize: '100%',
        sort: 'descending',
        gap: 4,
        label: {
          show: true,
          position: 'inside',
          formatter: (params: any) => {
            const data = params.data;
            return `{name|${data.name}}\n{value|${data.value.toLocaleString()}}`;
          },
          rich: {
            name: {
              fontSize: 15,
              fontWeight: 'bold',
              color: '#fff',
              lineHeight: 28,
            },
            value: {
              fontSize: 20,
              fontWeight: 'bold',
              color: '#fff',
              lineHeight: 32,
            },
          },
        },
        labelLine: {
          length: 10,
          lineStyle: {
            width: 1,
            type: 'solid',
          },
        },
        itemStyle: {
          borderColor: '#fff',
          borderWidth: 2,
        },
        emphasis: {
          label: {
            fontSize: 18,
          },
        },
        data: funnelData.value.map((item, index) => ({
          name: item.name,
          value: item.value,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: funnelColors[index] },
              { offset: 1, color: echarts.color.modifyAlpha(funnelColors[index], 0.7) },
            ]),
          },
        })),
      },
    ],
  };

  funnelChart.setOption(option);
};

// 搜索
const handleSearch = () => {
  // TODO: 接入实际接口
  console.log('搜索条件:', searchForm);
};

// 重置
const handleReset = () => {
  searchForm.scene = undefined;
  searchForm.batchType = undefined;
  searchForm.dateRange = null;
};

// 监听窗口大小变化
const handleResize = () => {
  funnelChart?.resize();
};

onMounted(() => {
  nextTick(() => {
    initFunnelChart();
  });
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  funnelChart?.dispose();
});
</script>

<style scoped>
.call-funnel {
  padding: 0;
}

/* 页面标题区域 */
.page-header-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #787676;
  margin: 0;
}

.page-description {
  font-size: 14px;
  color: #8c8c8c;
  margin: 0;
}

/* 搜索区域 */
.search-area {
  padding: 24px 0;
  margin-bottom: 16px;
}

/* 统计卡片区域 */
.stats-cards {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.stat-card {
  flex: 1;
  background: #fff;
  border-radius: 8px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
  transition: all 0.3s;
}

.stat-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.stat-card-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-card-icon-text {
  font-size: 20px;
  font-weight: bold;
  color: #fff;
}

.stat-card-content {
  flex: 1;
}

.stat-card-label {
  font-size: 13px;
  color: #8c8c8c;
  margin-bottom: 4px;
}

.stat-card-value {
  font-size: 24px;
  font-weight: 600;
  color: #262626;
}

.stat-card-rate {
  text-align: right;
  padding-left: 12px;
  border-left: 1px solid #f0f0f0;
}

.stat-card-rate-label {
  font-size: 12px;
  color: #8c8c8c;
  margin-bottom: 4px;
}

.stat-card-rate-value {
  font-size: 18px;
  font-weight: 600;
  color: #52c41a;
}

/* 漏斗图区域 */
.funnel-section {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.funnel-chart-wrapper {
  width: 100%;
  display: flex;
  justify-content: center;
}

.funnel-chart {
  width: 100%;
  height: 520px;
}
</style>
