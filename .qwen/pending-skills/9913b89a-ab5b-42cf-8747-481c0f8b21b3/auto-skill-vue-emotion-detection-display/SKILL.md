---
name: vue-emotion-detection-display
description: 在 Vue 聊天气泡下方展示 AI 情绪分析结果：情绪标签、强度条、策略触发提示、负面情绪预警横幅、趋势时间线，用于 AI 外呼对话详情的实时情绪检测展示
source: auto-skill
extracted_at: '2026-07-10T08:20:00.000Z'
---

# Vue 情绪检测展示

在 AI 外呼对话详情中，为客户侧聊天气泡附加情绪分析区域，展示 AI 对客户情绪的实时检测、策略调整和预警能力。

## 适用场景

- AI 外呼记录对话详情（AICallRecord 等页面）
- 需要体现情绪检测和对话策略调整的对话回放
- 与 ASR 标注（`vue-asr-chat-annotation`）和语义分析（`vue-ai-semantic-analysis`）配合使用

## 数据结构

```typescript
// 情绪策略（挂在 EmotionAnalysis 上）
interface EmotionStrategy {
  action: 'transfer' | 'soothe' | 'accelerate' | 'none';
  description: string;   // 策略描述，如 "触发安抚话术：强调老客户专属优惠"
  executed: boolean;     // 策略是否已执行（后端反馈）
}

// 情绪预警（挂在 EmotionAnalysis 上）
interface EmotionAlert {
  level: 'warning' | 'danger';
  message: string;       // 预警信息，如 "检测到客户强烈不满情绪"
  triggerProcess?: string; // 预设应急流程名称
  triggered: boolean;    // 流程是否已触发
}

// 情绪分析（挂在 customer 侧 AsrItem 上）
interface EmotionAnalysis {
  primary: 'angry' | 'anxious' | 'impatient' | 'neutral' | 'satisfied' | 'happy';
  intensity: number;     // 0-100 情绪强度
  strategy?: EmotionStrategy;
  alert?: EmotionAlert;
}

// 扩展 AsrItem
interface AsrItem {
  role: 'robot' | 'customer' | 'agent';
  time: string;
  text: string;
  confidence: number;
  endpoint?: AsrEndpoint;
  annotations?: AsrAnnotation[];
  semantic?: SemanticAnalysis;
  emotion?: EmotionAnalysis;   // ★ 新增
}
```

## 模板结构

### 1. 客户气泡下方的情绪展示区

放在语义分析区域（`semantic-section`）之后：

```vue
<!-- 情绪分析标签 -->
<div v-if="item.emotion" class="emotion-section">
  <!-- 情绪标签 + 强度条 -->
  <div class="emotion-row">
    <span class="emotion-label">情绪</span>
    <a-tag :color="emotionColorMap[item.emotion.primary]" size="small">
      {{ emotionLabelMap[item.emotion.primary] }}
    </a-tag>
    <div class="emotion-intensity-bar">
      <div
        class="emotion-intensity-fill"
        :style="{ width: item.emotion.intensity + '%', background: getIntensityColor(item.emotion.intensity) }"
      ></div>
    </div>
    <span class="emotion-intensity-value">{{ item.emotion.intensity }}%</span>
  </div>
  <!-- 策略触发提示 -->
  <div v-if="item.emotion.strategy?.executed" class="emotion-strategy-row">
    <check-circle-outlined />
    <span>{{ item.emotion.strategy.description }}</span>
  </div>
  <!-- 负面情绪预警横幅 -->
  <div
    v-if="item.emotion.alert"
    class="emotion-alert-row"
    :class="'emotion-alert-' + item.emotion.alert.level"
  >
    <alert-outlined />
    <span>{{ item.emotion.alert.message }}</span>
    <span v-if="item.emotion.alert.triggerProcess" class="emotion-trigger-process">
      应急流程：{{ item.emotion.alert.triggerProcess }}
      <a-tag v-if="item.emotion.alert.triggered" color="red" size="small">已触发</a-tag>
    </span>
  </div>
</div>
```

### 2. 情绪趋势摘要区

放在通话信息区域和对话区域之间：

```vue
<!-- 情绪趋势摘要 -->
<div v-if="emotionTimeline.length > 0" class="emotion-timeline">
  <span class="emotion-timeline-label">情绪趋势</span>
  <div class="emotion-timeline-track">
    <svg class="emotion-timeline-svg" viewBox="0 0 100 100" preserveAspectRatio="none">
      <polyline
        :points="emotionTimelineLinePoints"
        fill="none" stroke="#d9d9d9" stroke-width="0.5"
        vector-effect="non-scaling-stroke"
      />
    </svg>
    <div
      v-for="(point, i) in emotionTimeline" :key="i"
      class="emotion-timeline-point"
      :class="{ 'emotion-timeline-alert': point.alert }"
      :style="{ left: point.x + '%' }"
      :title="emotionLabelMap[point.primary] + ' ' + point.intensity + '%'"
      @click="scrollToChatItem(point.index)"
    >
      <div class="emotion-dot" :style="{ background: getIntensityColor(point.intensity) }"></div>
    </div>
  </div>
  <div class="emotion-timeline-legend">
    <span v-for="point in emotionTimeline" :key="point.index" class="emotion-timeline-legend-item">
      <span class="emotion-legend-dot" :style="{ background: getIntensityColor(point.intensity) }"></span>
      {{ emotionLabelMap[point.primary] }}
    </span>
  </div>
</div>
```

### 3. 聊天气泡需要 id 属性支持滚动定位

```vue
<div
  v-for="(item, index) in aiDialogList"
  :key="'ai-' + index"
  :id="'chat-item-' + index"
  class="chat-row"
  :class="item.role === 'robot' ? 'chat-row-left' : 'chat-row-right'"
>
```

## 计算属性和辅助函数

```typescript
// 情绪颜色映射
const emotionColorMap: Record<string, string> = {
  angry: 'red', anxious: 'orange', impatient: 'gold',
  neutral: 'default', satisfied: 'green', happy: 'blue',
};
const emotionLabelMap: Record<string, string> = {
  angry: '愤怒', anxious: '焦虑', impatient: '不耐烦',
  neutral: '中性', satisfied: '满意', happy: '愉悦',
};

// 强度颜色（绿→橙→红）
const getIntensityColor = (v: number): string => {
  if (v >= 70) return '#f5222d';
  if (v >= 40) return '#fa8c16';
  return '#52c41a';
};

// 情绪趋势数据（从 aiDialogList 聚合）
const emotionTimeline = computed(() => {
  const points: { index: number; intensity: number; primary: string; alert: boolean; x: number }[] = [];
  aiDialogList.value.forEach((item, i) => {
    if (item.emotion) {
      points.push({
        index: i, intensity: item.emotion.intensity,
        primary: item.emotion.primary, alert: !!item.emotion.alert, x: 0,
      });
    }
  });
  points.forEach((p, i) => {
    p.x = points.length > 1 ? (i / (points.length - 1)) * 100 : 50;
  });
  return points;
});

// SVG 折线点
const emotionTimelineLinePoints = computed(() =>
  emotionTimeline.value.map(p => `${p.x},${100 - p.intensity}`).join(' ')
);

// 滚动定位到聊天气泡
const scrollToChatItem = (index: number) => {
  const el = document.getElementById('chat-item-' + index);
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
    el.classList.add('chat-item-highlight');
    setTimeout(() => el.classList.remove('chat-item-highlight'), 2000);
  }
};
```

## 样式

```css
/* 情绪分析区域 */
.emotion-section {
  margin-top: 6px; padding: 6px 10px;
  background: #f6ffed; border: 1px solid #d9f7be; border-radius: 4px; font-size: 12px;
}
.emotion-row {
  display: flex; align-items: center; gap: 6px; line-height: 22px;
}
.emotion-label {
  color: #999; flex-shrink: 0; font-size: 11px; min-width: 28px;
}
.emotion-intensity-bar {
  width: 100px; height: 6px; background: #f0f0f0; border-radius: 3px; overflow: hidden;
}
.emotion-intensity-fill {
  height: 100%; border-radius: 3px; transition: width 0.3s ease;
}
.emotion-intensity-value {
  color: #8c8c8c; font-size: 11px; min-width: 30px;
}
.emotion-strategy-row {
  margin-top: 4px; font-size: 12px; color: #1890ff;
  display: flex; align-items: center; gap: 4px; line-height: 20px;
}
.emotion-alert-row {
  margin-top: 4px; font-size: 12px; padding: 4px 8px;
  border-radius: 4px; border-left: 4px solid;
  display: flex; align-items: flex-start; gap: 4px; flex-wrap: wrap; line-height: 18px;
}
.emotion-alert-warning {
  background: #fff7e6; border-color: #fa8c16; color: #d46b08;
}
.emotion-alert-danger {
  background: #fff1f0; border-color: #f5222d; color: #cf1322;
  animation: alert-pulse 2s ease-in-out infinite;
}
.emotion-trigger-process { margin-left: 4px; white-space: nowrap; }

@keyframes alert-pulse {
  0%, 100% { opacity: 1; } 50% { opacity: 0.7; }
}

/* 情绪趋势摘要 */
.emotion-timeline {
  padding: 8px 16px; border-bottom: 1px solid #f0f0f0;
  display: flex; align-items: center; gap: 12px; background: #fafafa;
}
.emotion-timeline-label {
  font-size: 12px; color: #8c8c8c; white-space: nowrap; flex-shrink: 0;
}
.emotion-timeline-track {
  flex: 1; height: 32px; position: relative;
}
.emotion-timeline-svg {
  position: absolute; inset: 0; width: 100%; height: 100%;
}
.emotion-timeline-point {
  position: absolute; top: 50%; transform: translate(-50%, -50%);
  cursor: pointer; z-index: 1; transition: transform 0.15s;
}
.emotion-timeline-point:hover {
  transform: translate(-50%, -50%) scale(1.4);
}
.emotion-dot {
  width: 10px; height: 10px; border-radius: 50%;
  border: 2px solid #fff; box-shadow: 0 0 0 1px #d9d9d9;
}
.emotion-timeline-alert .emotion-dot {
  box-shadow: 0 0 0 2px #f5222d;
}
.emotion-timeline-legend {
  display: flex; gap: 8px; flex-shrink: 0;
}
.emotion-timeline-legend-item {
  display: flex; align-items: center; gap: 3px; font-size: 11px; color: #8c8c8c;
}
.emotion-legend-dot {
  width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0;
}

/* 聊天气泡高亮动画 */
:deep(.chat-item-highlight) {
  animation: highlight-flash 2s ease;
}
@keyframes highlight-flash {
  0% { background: #e6f7ff; } 50% { background: #bae7ff; } 100% { background: transparent; }
}
```

## Mock 数据设计要点

情绪数据应覆盖多种情绪类型和策略场景：

| 轮次 | 情绪 | 强度 | 策略 | 预警 |
|------|------|------|------|------|
| 确认身份 | neutral | 10 | - | - |
| 残缺追问 | anxious | 35 | - | - |
| 议价咨询 | anxious | 55 | soothe（安抚话术） | - |
| 条件咨询 | anxious | 30 | - | - |
| 表达意向 | satisfied | 45 | - | - |
| 变更渠道 | impatient | 60 | accelerate（加速流程） | - |
| 情绪爆发 | angry | 85 | transfer（转人工） | danger（投诉升级处理） |
| 确认结束 | satisfied | 55 | - | - |

**关键设计原则：**
- 情绪强度应随对话推进有合理变化（低→中→高 或 波动）
- 策略触发应与情绪强度匹配（≥55 才触发策略）
- 预警仅在高强度负面情绪时出现（≥80）
- danger 级别预警使用脉冲动画吸引注意
- 趋势时间线的 X 轴按轮次等距分布，Y 轴为强度值

## 与相邻技能的关系

- **vue-asr-chat-annotation**：文本层 ASR 识别质量（断句/端点/后处理）
- **vue-ai-semantic-analysis**：语义层 AI 理解能力（意图/关键词/上下文）
- **本技能（vue-emotion-detection-display）**：情绪层实时检测能力（情绪/强度/策略/预警）
- 三者在 customer 侧气泡中**叠加使用**：ASR 文本 → 语义分析 → 情绪分析

## 注意事项

- 情绪展示区使用绿色背景（`#f6ffed`）与语义分析区（`#fafafa`）区分
- 强度条颜色渐变：绿（<40）→ 橙（40-70）→ 红（≥70）
- 预警横幅左边框 4px 强调，danger 级别带脉冲动画
- 趋势时间线圆点可点击，点击后滚动到对应气泡并高亮 2 秒
- trend timeline 使用 SVG polyline 绘制连线，preserveAspectRatio="none" 保证拉伸
