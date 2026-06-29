---
name: vue-asr-convert-button
description: 在对话详情弹窗中为无ASR数据的通话添加"语音转文本"按钮，支持加入识别队列和状态提示
source: auto-skill
extracted_at: '2026-06-27T02:15:00.000Z'
---

# 对话详情中添加语音转文本按钮

## 适用场景

在通话记录页面（如AI通话记录、人工通信接口外呼记录）的对话详情弹窗中，当通话没有ASR数据时，提供"语音转文本"功能按钮，允许用户手动将该通话加入识别队列。

## 实现步骤

### 1. 添加状态管理

在对话详情弹窗相关状态区域添加：

```typescript
// 语音转文本队列
const asrQueue = ref<Set<string>>(new Set());

const handleAsrConvert = (record: ReportItem) => {
  asrQueue.value.add(record.callUuid);
  // 模拟加入队列后的提示
  const message = `通话 ${record.callUuid} 已加入语音转文本队列`;
  console.log(message);
};

const isInAsrQueue = (record: ReportItem | null) => {
  return record ? asrQueue.value.has(record.callUuid) : false;
};
```

### 2. 导入图标

```typescript
import { AudioOutlined } from '@ant-design/icons-vue';
```

### 3. 修改模板

将原来的空状态：
```html
<a-empty v-if="asrDialogList.length === 0" description="暂无 ASR 数据" />
```

替换为：
```html
<template v-if="asrDialogList.length === 0">
  <div v-if="isInAsrQueue(detailRecord)" class="asr-converting-tip">
    <a-spin size="small" />
    <span>正在语音转文本，请稍后...</span>
  </div>
  <div v-else class="asr-empty-tip">
    <a-empty description="暂无 ASR 数据" />
    <a-button type="primary" @click="handleAsrConvert(detailRecord!)">
      <audio-outlined />
      语音转文本
    </a-button>
  </div>
</template>
```

### 4. 添加样式

```css
/* 语音转文本提示样式 */
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
  color: #1890ff;
  font-size: 14px;
}
```

## 交互逻辑

1. **无ASR数据时**：显示"暂无 ASR 数据"提示和"语音转文本"按钮
2. **点击按钮后**：将通话ID加入asrQueue集合
3. **在队列中时**：显示loading动画和"正在语音转文本，请稍后..."提示
4. **识别完成后**：需从asrQueue中移除（当前为模拟状态，实际需接后端接口）

## 注意事项

- 使用 `Set<string>` 存储通话ID，确保唯一性
- 使用 `callUuid` 作为唯一标识
- 样式需添加到页面的 `<style>` 标签中
- 实际项目中需接后端接口获取识别结果并刷新页面
