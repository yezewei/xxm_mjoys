---
name: vue-asr-chat-annotation
description: 在 Vue 聊天气泡中展示 ASR 识别特征：智能断句标点、端点检测标签、后处理标注（词语修正/敏感词高亮/数字规整），含字符级标注定位和 tooltip 交互
source: auto-skill
extracted_at: '2026-06-22T08:57:50.844Z'
---

# Vue ASR 聊天标注展示

在聊天气泡中可视化 ASR 语音识别的三大能力：断句与标点、端点检测、后处理（词语修正/敏感词标注/数字规整）。

## 适用场景

- 外呼记录、通话详情等对话回放页面
- 需要展示 ASR 识别质量与后处理结果的场景

## 数据结构

```typescript
// 后处理标注（字符级定位）
interface AsrAnnotation {
  type: 'replace' | 'highlight' | 'number'; // 词语修正 | 敏感词标注 | 数字规整
  start: number;   // 在最终文本中的起始字符索引（含）
  end: number;     // 在最终文本中的结束字符索引（不含），用于 text.slice(start, end)
  original: string; // ASR 原始识别文本
  value: string;    // 后处理后的文本（替换为/规整为的值）
}

// 端点检测信息
interface AsrEndpoint {
  vadDuration: number; // VAD 响应耗时(ms)
  isEndpoint: boolean; // 是否为语音端点
}

// 对话项
interface AsrItem {
  role: 'seat' | 'customer' | 'robot'; // robot 用于 AI 外呼场景
  time: string;
  text: string;        // 最终文本（已包含标点和后处理修正）
  confidence: number;  // 识别置信度 0-100，robot 侧通常为 0
  endpoint?: AsrEndpoint;
  annotations?: AsrAnnotation[];
}
```

**角色变体说明**：
- **人工外呼**（ManualCallReport）：role 使用 `'seat' | 'customer'`，两侧均有 ASR 特征
- **AI 外呼**（AICallRecord）：role 使用 `'robot' | 'customer'`，**robot 侧为预设话术，不展示 ASR 特征**（confidence=0，无 endpoint/annotations）；仅 customer 侧有 ASR 标注
- 若同时需要展示 AI 语义分析能力，参见 `vue-ai-semantic-analysis` 技能

## 核心：字符级标注分段渲染

将带标注的文本拆分为可渲染的段落数组，每段是纯文本或带 tooltip 的标注 span：

```typescript
interface TextSegment {
  type: 'text' | 'replace' | 'highlight' | 'number';
  content: string;
  tooltip?: string;
  original?: string;
}

const getTextSegments = (item: AsrItem): TextSegment[] => {
  if (!item.annotations || item.annotations.length === 0) {
    return [{ type: 'text', content: item.text }];
  }
  const segments: TextSegment[] = [];
  let cursor = 0;
  // 必须按 start 排序，防止乱序导致间隙
  const sorted = [...item.annotations].sort((a, b) => a.start - b.start);
  for (const ann of sorted) {
    // 标注前的纯文本
    if (ann.start > cursor) {
      segments.push({ type: 'text', content: item.text.slice(cursor, ann.start) });
    }
    // tooltip 文案：replace 和 number 显示原文→修正，highlight 显示原文
    const tooltip = ann.type === 'replace'
      ? `原文：${ann.original} → 修正：${ann.value}`
      : ann.type === 'number'
        ? `原文：${ann.original} → 规整：${ann.value}`
        : ann.original;
    segments.push({ type: ann.type, content: ann.value, tooltip, original: ann.original });
    cursor = ann.end;
  }
  // 标注后的剩余文本
  if (cursor < item.text.length) {
    segments.push({ type: 'text', content: item.text.slice(cursor) });
  }
  return segments;
};
```

**关键注意**：`start`/`end` 对应 `text`（最终文本）的字符索引，不是 ASR 原始输出。`original` 记录 ASR 原始识别结果，`value` 是修正/规整后的值。当 `type === 'highlight'` 时 `original === value`，仅做视觉高亮。

## Mock 数据构造要点

```typescript
// 数字规整示例：中文数字→阿拉伯数字
// 文本: "年化收益是百分之四点五，到期日是下个月十五号。"
// "百分之四点五" 位于 text[19:26]，规整为 "4.5%"
{ type: 'number', start: 19, end: 26, original: '百分之四点五', value: '4.5%' }
{ type: 'number', start: 32, end: 36, original: '十五号', value: '15号' }

// 词语修正示例：同长度替换（避免索引偏移）
// 文本: "想跟您确认一下续期意向"
// "一齐" 被修正为 "一起"，位于 text[16:18]
{ type: 'replace', start: 16, end: 18, original: '一齐', value: '一起' }

// 敏感词标注示例：仅高亮不替换
{ type: 'highlight', start: 10, end: 14, original: '稳健型理财', value: '稳健型理财' }
```

**构造步骤**：先写好最终文本 → 逐字符数索引 → 填入 start/end → 验证 `text.slice(start, end)` 是否匹配预期子串。

## 模板结构

```vue
<div class="chat-bubble">
  <!-- 分段渲染：纯文本 + 标注 span -->
  <template v-for="(seg, si) in getTextSegments(item)" :key="si">
    <span v-if="seg.type === 'text'">{{ seg.content }}</span>
    <a-tooltip v-else>
      <template #title><span>{{ seg.tooltip }}</span></template>
      <span :class="['asr-annotation', getAnnotationClass(seg.type)]">
        {{ seg.content }}
        <span class="asr-ann-badge">{{ getAnnotationLabel(seg.type) }}</span>
      </span>
    </a-tooltip>
  </template>
  <!-- 后处理标记 -->
  <div v-if="item.annotations?.length" class="asr-processed-mark">
    <check-circle-outlined /> 后处理
  </div>
</div>

<!-- 气泡元信息：时间 + 智能断句标签 -->
<div class="asr-meta">
  <span class="asr-time">{{ item.time }}</span>
  <span class="asr-punctuation-tag">智能断句</span>
</div>

<!-- 角色名旁：端点检测 + 置信度 -->
<div class="chat-name">
  <span>坐席</span>
  <a-tooltip v-if="item.endpoint">
    <template #title>端点检测：VAD 响应 {{ item.endpoint.vadDuration }}ms</template>
    <a-tag class="asr-endpoint-tag" color="blue" size="small">
      <span class="asr-endpoint-dot"></span>端点检测
    </a-tag>
  </a-tooltip>
  <a-tag v-if="item.confidence" class="asr-confidence-tag" size="small">
    置信度 {{ item.confidence }}%
  </a-tag>
</div>
```

## 样式要点

```css
/* 三种标注类型的视觉区分 */
.asr-ann-replace  { border-bottom-color: #fa8c16; color: #fa8c16; } /* 橙色：词语修正 */
.asr-ann-highlight { border-bottom-color: #722ed1; color: #722ed1; background: rgba(114,46,209,0.06); } /* 紫色：敏感词 */
.asr-ann-number   { border-bottom-color: #1890ff; color: #1890ff; } /* 蓝色：数字规整 */

/* 标注角标 */
.asr-ann-badge { font-size: 9px; vertical-align: super; }

/* 端点检测脉冲动画 */
.asr-endpoint-dot {
  display: inline-block; width: 6px; height: 6px; border-radius: 50%;
  background: currentColor; animation: asr-pulse 1.5s ease-in-out infinite;
}
@keyframes asr-pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.4; } }

/* 角色名需 flex 布局以容纳标签 */
.chat-name { display: flex; align-items: center; gap: 4px; }
.chat-name-right { justify-content: flex-end; }
```

## 三类标注的颜色/标签速查

| 类型 | 颜色 | 角标文案 | tooltip 格式 |
|------|------|----------|-------------|
| replace | #fa8c16 橙 | 词语修正 | 原文：{original} → 修正：{value} |
| highlight | #722ed1 紫 | 敏感标注 | {original} |
| number | #1890ff 蓝 | 数字规整 | 原文：{original} → 规整：{value} |

## 辅助函数

```typescript
const getAnnotationLabel = (type: AsrAnnotation['type']): string => {
  const map = { replace: '词语修正', highlight: '敏感标注', number: '数字规整' };
  return map[type] || type;
};

const getAnnotationClass = (type: AsrAnnotation['type']): string => {
  const map = { replace: 'asr-ann-replace', highlight: 'asr-ann-highlight', number: 'asr-ann-number' };
  return map[type] || '';
};
```
