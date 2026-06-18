---
name: vue-modal-collapsible-detail
description: 在已有 Modal 中添加可折叠且可滚动的详情信息区域（字段网格），适用于查看记录完整字段
source: auto-skill
extracted_at: '2026-06-17T12:00:00.000Z'
---

# Modal 中添加可折叠可滚动的详情字段区域

当弹窗需要展示某条记录的完整字段信息（如通话详情、工单详情），且字段较多需要支持收起和滚动时使用此模式。

## 适用场景

- 弹窗主体已有其他内容（如对话、日志），需要在上方补充该记录的字段信息
- 字段数量 > 10 个，需要滚动且支持收起以节省空间
- 弹窗采用 `flex-direction: column` 布局，详情区在顶部、主内容区在下方

## 操作步骤

### 1. 添加图标导入

```ts
import { DownOutlined, UpOutlined } from '@ant-design/icons-vue';
```

### 2. 定义响应式状态和字段配置

```ts
const detailExpanded = ref(true);

const detailFields = [
  { key: 'fieldName1', label: '字段中文名1' },
  { key: 'fieldName2', label: '字段中文名2' },
  { key: 'duration', label: '时长', format: 'duration' as const },
  // ...所有需要展示的字段
];

const getDetailFieldValue = (record: YourType | null, field: typeof detailFields[number]) => {
  if (!record) return '-';
  const value = (record as any)[field.key];
  if (value === undefined || value === null || value === '') return '-';
  if (field.format === 'duration') return formatDuration(value);
  return String(value);
};
```

> `format` 字段为可选项，仅特殊格式（如秒数转时分秒）需要添加对应的格式化函数。

### 3. 在 Modal 模板中插入详情区域

放在 Modal body 的最顶部，主内容区之前：

```html
<a-modal
  v-model:open="detailModalVisible"
  title="查看详情"
  width="800px"
  :footer="null"
  :body-style="{ padding: 0, display: 'flex', flexDirection: 'column', height: '640px' }"
>
  <!-- 详情字段区域（可折叠、可滚动） -->
  <div class="detail-info-section">
    <div class="detail-info-header" @click="detailExpanded = !detailExpanded">
      <span class="detail-info-title">记录信息</span>
      <span class="detail-info-toggle">
        <UpOutlined v-if="detailExpanded" style="font-size: 10px" />
        <DownOutlined v-else style="font-size: 10px" />
      </span>
    </div>
    <div v-show="detailExpanded" class="detail-info-body">
      <div class="detail-field-grid">
        <div
          v-for="field in detailFields"
          :key="field.key"
          class="detail-field-item"
        >
          <span class="detail-field-label">{{ field.label }}</span>
          <span class="detail-field-value">{{ getDetailFieldValue(detailRecord, field) }}</span>
        </div>
      </div>
    </div>
  </div>

  <!-- 主内容区（对话/日志等） -->
  <div class="main-content-area">
    <!-- ... -->
  </div>
</a-modal>
```

### 4. 添加 CSS 样式

```css
/* 详情区域 - 整体容器，不压缩 */
.detail-info-section {
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;
}

/* 可点击的折叠头 */
.detail-info-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  cursor: pointer;
  user-select: none;
}

.detail-info-header:hover {
  background: #fafafa;
}

.detail-info-title {
  font-size: 13px;
  font-weight: 600;
  color: #333;
}

.detail-info-toggle {
  color: #999;
  font-size: 12px;
}

/* 可滚动的字段内容区 */
.detail-info-body {
  max-height: 180px;
  overflow-y: auto;
  padding: 0 16px 12px;
}

/* 字段网格 - 4列布局 */
.detail-field-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px 16px;
}

.detail-field-item {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.detail-field-label {
  font-size: 12px;
  color: #999;
  line-height: 1;
  margin-bottom: 4px;
}

.detail-field-value {
  font-size: 13px;
  color: #333;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
```

## 关键布局原理

- Modal body 使用 `flex-direction: column` + 固定 `height`
- 详情区 `flex-shrink: 0` 保证不被压缩
- 主内容区 `flex: 1` + `overflow-y: auto` 自动填充剩余空间并独立滚动
- 详情区内部 `max-height` 控制展开后的最大高度，超出则滚动
- `v-show` 保持 DOM 存在，折叠/展开动画更平滑

## 常见调整

| 需求 | 调整方式 |
|------|----------|
| 更多字段，需要更大的滚动区域 | 增大 `detail-info-body` 的 `max-height` |
| 列数调整为 3 列 | `grid-template-columns: repeat(3, 1fr)` |
| 默认收起 | `const detailExpanded = ref(false)` |
| 弹窗更宽 | 调整 Modal `width`，如 `900px` |
| 字段值需要特殊渲染（标签、徽章） | 在模板中用 `v-if` 按 field.key 判断，自定义渲染 |
