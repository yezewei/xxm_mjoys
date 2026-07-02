---
name: vue-split-chat-dialog
description: 对话详情弹窗拆分为AI对话+人工对话两个区域，上半部分始终有数据，下半部分支持ASR空态和语音转文本按钮
source: auto-skill
extracted_at: '2026-06-30T06:30:00.000Z'
---

# 对话详情弹窗拆分为 AI + 人工两段

## 适用场景

通话记录页面（AI外呼记录、人工外呼记录等）的对话详情弹窗，需要将聊天记录分为：
- **上半部分**：AI 与客户的对话（始终有 ASR 数据）
- **下半部分**：人工坐席与客户的对话（可能没有 ASR 数据，需支持语音转文本）

## 实现步骤

### 1. 状态管理：拆分为两个列表

```typescript
// AI 对话和人工对话分开存储
const aiDialogList = ref<AsrItem[]>([]);
const manualAsrDialogList = ref<AsrItem[]>([]);

// 人工对话语音转文本队列（独立于AI的队列）
const manualAsrQueue = ref<Set<string>>(new Set());

const handleManualAsrConvert = (record: ReportItem) => {
  manualAsrQueue.value.add(record.callUuid);
};

const isManualInAsrQueue = (record: ReportItem | null) => {
  return record ? manualAsrQueue.value.has(record.callUuid) : false;
};
```

### 2. 数据加载：按角色分离

```typescript
const handleViewDetail = (record: ReportItem) => {
  detailRecord.value = record;
  
  // 未接通的通话没有数据
  if (record.answerResult === '空号' || record.answerResult === '关机') {
    aiDialogList.value = [];
    manualAsrDialogList.value = [];
    detailModalVisible.value = true;
    return;
  }

  // AI 对话部分（始终有数据）
  aiDialogList.value = [
    { role: 'robot', time: '00:00:03', text: '...' },
    { role: 'customer', time: '00:00:06', text: '...', confidence: 95 },
    // ... 更多AI对话
    { role: 'robot', time: '00:01:29', text: '转接人工坐席...' }, // 最后一条AI消息
  ];

  // 人工对话部分（可能为空）
  manualAsrDialogList.value = hasManualData ? [
    { role: 'agent', time: '00:01:35', text: '...' },
    { role: 'customer', time: '00:01:40', text: '...' },
  ] : [];

  detailModalVisible.value = true;
};
```

### 3. 模板结构：三段式布局

```html
<div class="chat-container">
  <div class="chat-messages">
    <!-- AI 对话部分 -->
    <div class="chat-section">
      <div class="chat-section-header">
        <robot-outlined style="color: #722ed1; margin-right: 6px" />
        <span>AI 对话</span>
      </div>
      <div class="chat-section-content">
        <div v-for="(item, index) in aiDialogList" :key="'ai-' + index"
             class="chat-row" :class="item.role === 'robot' ? 'chat-row-left' : 'chat-row-right'">
          <!-- 机器人头像在左，客户头像在右 -->
        </div>
      </div>
    </div>

    <!-- 分隔线 -->
    <div v-if="aiDialogList.length > 0" class="chat-section-divider">
      <div class="divider-line"></div>
      <span class="divider-text">转接人工</span>
      <div class="divider-line"></div>
    </div>

    <!-- 人工对话部分 -->
    <div class="chat-section">
      <div class="chat-section-header">
        <user-outlined style="color: #1890ff; margin-right: 6px" />
        <span>人工对话</span>
      </div>
      <div class="chat-section-content">
        <div v-for="(item, index) in manualAsrDialogList" :key="'manual-' + index"
             class="chat-row" :class="item.role === 'agent' ? 'chat-row-left' : 'chat-row-right'">
          <!-- 坐席头像在左，客户头像在右 -->
        </div>

        <!-- 人工对话为空时的 ASR 提示 -->
        <template v-if="manualAsrDialogList.length === 0">
          <div v-if="isManualInAsrQueue(detailRecord)" class="asr-converting-tip">
            <check-circle-outlined style="color: #52c41a" />
            <span>已加入语音转文本队列，等待识别</span>
          </div>
          <div v-else class="asr-empty-tip">
            <a-empty description="暂无通话文本数据" />
            <a-button type="primary" @click="handleManualAsrConvert(detailRecord!)">
              <audio-outlined />
              语音转文本
            </a-button>
          </div>
        </template>
      </div>
    </div>
  </div>
</div>
```

### 4. 样式

```css
/* 区块容器 */
.chat-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 区块标题栏 */
.chat-section-header {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: #fafafa;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  color: #333;
  border-left: 3px solid #722ed1;  /* AI 紫色 */
}

/* 人工区块标题用蓝色 */
.chat-section-header:has(.anticon-user) {
  border-left-color: #1890ff;
}

.chat-section-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 分隔线 */
.chat-section-divider {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
}

.divider-line {
  flex: 1;
  height: 1px;
  background: #e8e8e8;
}

.divider-text {
  font-size: 12px;
  color: #999;
  white-space: nowrap;
}

/* ASR 空态提示 */
.asr-empty-tip {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  padding: 40px 0;
}

.asr-converting-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 60px 0;
  color: #52c41a;
  font-size: 14px;
}
```

## 关键设计决策

1. **数据分离**：`aiDialogList` 和 `manualAsrDialogList` 独立存储，便于分别控制
2. **队列独立**：人工对话使用独立的 `manualAsrQueue`，不与AI对话队列混淆
3. **视觉区分**：AI 区块用紫色左边框 + 机器人图标，人工区块用蓝色左边框 + 用户图标
4. **分隔线**：用"转接人工"文字分隔两个区域，体现业务流转
5. **空态处理**：人工对话为空时才显示 ASR 按钮，AI 对话始终有数据

## 与其他技能的配合

- **vue-asr-convert-button**：本技能的人工对话空态部分复用了该技能的按钮模式
- **vue-ai-semantic-analysis**：AI 对话的客户气泡可叠加语义分析标签
- **vue-asr-chat-annotation**：AI 对话的客户气泡可叠加 ASR 标注

## 适用页面

- AI外呼记录 (AICallRecord.vue)
- 人工通信接口外呼记录 (ManualCallReport.vue)
- 人工外呼记录 (ManualCallRecord.vue)
