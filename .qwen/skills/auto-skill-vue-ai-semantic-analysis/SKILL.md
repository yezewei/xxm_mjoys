---
name: vue-ai-semantic-analysis
description: 在 Vue 聊天气泡下方展示 AI 语义分析结果：意图标签、关键词抽取、上下文关联引用，用于 AI 外呼对话详情的多轮语义理解展示
source: auto-skill
extracted_at: '2026-06-22T10:15:00.000Z'
---

# Vue AI 语义分析展示

在 AI 外呼对话详情中，为客户侧聊天气泡附加语义分析区域，展示 AI 对客户话语的意图识别、关键词抽取和上下文关联能力。

## 适用场景

- AI 外呼记录对话详情（AICallRecord 等页面）
- 需要体现 AI 语义理解能力的对话回放
- 与 ASR 标注（`vue-asr-chat-annotation`）配合使用：ASR 标注展示语音识别质量，语义分析展示 AI 理解能力

## 数据结构

```typescript
// AI 语义分析（挂在 customer 侧 AsrItem 上）
interface SemanticAnalysis {
  intentTag: string;    // 意图标签，如「确认身份」「残缺追问」「议价咨询」
  keywords: string[];   // 关键词抽取，如 ['贷款', '之前']
  contextRef?: string;  // 上下文关联说明，如 '关联上文「个人消费贷款」，补充指代消解'
}

// 扩展 AsrItem（与 vue-asr-chat-annotation 共用基础结构）
interface AsrItem {
  role: 'robot' | 'customer';
  time: string;
  text: string;
  confidence: number;       // robot 侧为 0
  endpoint?: AsrEndpoint;   // 仅 customer 侧
  annotations?: AsrAnnotation[]; // 仅 customer 侧
  semantic?: SemanticAnalysis;   // 仅 customer 侧
}
```

## 模板结构

语义分析区域放在气泡内部、ASR 标注文本之后：

```vue
<!-- 客户侧气泡：ASR 文本 + 语义分析 -->
<div v-if="item.role === 'customer'" class="chat-bubble chat-bubble-right">
  <!-- ASR 分段渲染（同 vue-asr-chat-annotation） -->
  <template v-for="(seg, si) in getTextSegments(item)" :key="si">
    <span v-if="seg.type === 'text'">{{ seg.content }}</span>
    <a-tooltip v-else>
      <template #title><span>{{ seg.tooltip }}</span></template>
      <span :class="['asr-annotation', getAnnotationClass(seg.type)]">
        {{ seg.content }}<span class="asr-ann-badge">{{ getAnnotationLabel(seg.type) }}</span>
      </span>
    </a-tooltip>
  </template>

  <!-- 后处理标记 -->
  <div v-if="item.annotations?.length" class="asr-processed-mark">
    <check-circle-outlined /> 后处理
  </div>

  <!-- ★ 语义分析区域 -->
  <div v-if="item.semantic" class="semantic-section">
    <div class="semantic-row" v-if="item.semantic.intentTag">
      <span class="semantic-label">意图</span>
      <a-tag color="blue" size="small">{{ item.semantic.intentTag }}</a-tag>
    </div>
    <div class="semantic-row" v-if="item.semantic.keywords?.length">
      <span class="semantic-label">关键词</span>
      <a-tag v-for="kw in item.semantic.keywords" :key="kw" size="small" class="semantic-kw-tag">
        {{ kw }}
      </a-tag>
    </div>
    <div class="semantic-row" v-if="item.semantic.contextRef">
      <span class="semantic-label">上下文</span>
      <span class="semantic-context">{{ item.semantic.contextRef }}</span>
    </div>
  </div>
</div>

<!-- AI 机器人侧气泡：纯文本，无 ASR 特征 -->
<div v-else class="chat-bubble chat-bubble-left">{{ item.text }}</div>
```

## 样式

```css
/* 语义分析区域 */
.semantic-section {
  margin-top: 8px; padding-top: 8px;
  border-top: 1px dashed #e8e8e8;
}
.semantic-row {
  display: flex; align-items: flex-start; gap: 8px; margin-bottom: 6px;
}
.semantic-label {
  flex-shrink: 0; min-width: 32px; font-size: 12px; color: #8c8c8c; line-height: 22px;
}
.semantic-kw-tag {
  background: #fff7e6; border-color: #ffd591; color: #d46b08; border-radius: 2px;
}
.semantic-context {
  font-size: 12px; color: #8c8c8c; line-height: 22px;
}
```

## 多轮对话 Mock 数据设计要点

语义分析的 mock 数据应体现三大 AI 能力：

### 1. 残缺意图关键语义抽取
客户话语不完整、口语化，AI 能从中抽取关键意图和关键词：
```typescript
{
  role: 'customer',
  text: '贷款？什么贷款来着…就是之前那个嘛。',
  semantic: {
    intentTag: '残缺追问',
    keywords: ['贷款', '之前'],
    contextRef: '关联上文「个人消费贷款」，补充指代消解',
  },
}
```

### 2. 基于上下文的语义理解
AI 能理解指代词、省略句，将当前话语关联到之前的对话内容：
```typescript
{
  role: 'customer',
  text: '那行，差不多，就这个吧。',
  semantic: {
    intentTag: '表达意向',
    keywords: ['这个'],
    contextRef: '指代上文「三十六期方案」，残缺代词消解',
  },
}
```

### 3. 多轮人机互动递进
对话应有完整的业务逻辑递进，每轮 AI 回应都基于上下文：
- 开场确认身份 → 客户确认
- AI 引出业务 → 客户残缺追问 → AI 补全信息
- 客户议价 → AI 识别意图并引导 → 客户转入新话题
- 客户表达意向 → AI 推进 → 客户变更需求 → AI 灵活应对
- 达成一致 → 结束

**意图标签参考**（按业务阶段）：
| 阶段 | 意图标签 | 关键词示例 |
|------|---------|-----------|
| 开场 | 确认身份 | 是、对 |
| 信息确认 | 残缺追问 | 贷款、之前、那个 |
| 业务讨论 | 议价咨询、条件咨询 | 利率、低、还款、期限 |
| 决策 | 表达意向、变更渠道 | 这个、线上、网点 |
| 结束 | 确认结束 | 谢谢、好的 |

## 与 ASR 标注技能的关系

- **vue-asr-chat-annotation**：负责文本层的 ASR 识别质量展示（断句/端点/后处理）
- **本技能（vue-ai-semantic-analysis）**：负责语义层的 AI 理解能力展示（意图/关键词/上下文）
- 两者在 customer 侧气泡中**叠加使用**：先渲染 ASR 分段文本，再渲染语义分析区域
- robot 侧气泡两者均不展示（预设话术，无 ASR 也无语义分析）

## 注意事项

- `contextRef` 是可选字段，仅在有明确上下文关联时填写，避免每条都写
- 关键词应是客户话语中实际出现的词，不是 AI 补全的词
- 意图标签应简洁（2-4字），详细解释放在 `contextRef` 中
- 语义分析区域使用 `border-top: 1px dashed #e8e8e8` 与 ASR 文本区分隔
