---
name: vue-config-overview-modal
description: 在详情页添加"查看配置"弹窗，展示创建表单中的配置数据（条件表达式、时间规则、抽检策略等）
source: auto-skill
extracted_at: '2026-06-30T02:53:53.288Z'
---

# 详情页配置概览弹窗

当详情页需要展示创建任务时填写的配置数据（如条件筛选、自动追加规则、抽检策略等），点击链接打开只读弹窗查看。

## 适用场景

- 任务详情页需要查看创建时的配置参数
- 配置数据包含嵌套结构（条件表达式、时间规则等）
- 需要将创建表单的数据以只读形式展示

## 操作步骤

### 1. 在任务信息卡片中添加"查看"链接

在 `info-row` 中合适位置添加可点击链接：

```html
<div class="info-item">
  <span class="item-label">质检数据范围：</span>
  <a class="data-range-link" @click="dataRangeVisible = true">查看</a>
</div>
```

### 2. 定义弹窗可见性状态

```ts
const dataRangeVisible = ref(false)
```

### 3. 创建弹窗模板

弹窗使用 `a-modal`，无 footer（`:footer="null"`），内容按分组展示：

```html
<a-modal
  v-model:open="dataRangeVisible"
  title="质检数据范围"
  :footer="null"
  width="640px"
>
  <div class="data-range-content">
    <!-- 分组展示 -->
    <div class="data-range-section">
      <div class="section-label">质检范围</div>
      <div class="section-value">{{ currentTask?.qualityScope === 'full' ? '全量质检' : '部分抽检' }}</div>
    </div>

    <!-- 条件表达式（嵌套结构） -->
    <div class="data-range-section" v-if="currentTask?.conditionExpressions?.length">
      <div class="section-label">条件筛选</div>
      <div class="condition-expressions">
        <div v-for="(expr, eIndex) in currentTask.conditionExpressions" :key="eIndex" class="condition-expression-item">
          <div class="expression-conditions">
            <span v-for="(cond, cIndex) in expr.conditions" :key="cIndex">
              <span class="condition-field">{{ getFieldTypeLabel(cond.fieldType) }}</span>
              <span class="condition-operator">{{ cond.operator }}</span>
              <span class="condition-value">{{ cond.value }}{{ cond.value2 ? ` ~ ${cond.value2}` : '' }}</span>
              <span v-if="cIndex < expr.conditions.length - 1" class="condition-connector">且</span>
            </span>
          </div>
          <span v-if="eIndex < currentTask.conditionExpressions.length - 1" class="expression-connector">或</span>
        </div>
      </div>
    </div>

    <!-- 时间规则配置 -->
    <div class="data-range-section" v-if="currentTask?.autoAppend">
      <div class="section-label">自动追加新数据</div>
      <div class="auto-append-info">
        <div class="append-item">
          <span class="append-label">执行时间：</span>
          <span class="append-value">每天 {{ currentTask.autoAppendExecTime || '08:00' }} 点</span>
        </div>
        <div class="append-item">
          <span class="append-label">查询时间范围：</span>
          <span class="append-value">
            {{ currentTask.autoAppendStartType === 'today' ? '当天' : '昨天' }} {{ currentTask.autoAppendRangeStart || '00:00' }}
            ~
            {{ currentTask.autoAppendEndType === 'today' ? '当天' : '昨天' }} {{ currentTask.autoAppendRangeEnd || '23:59' }}
          </span>
        </div>
      </div>
    </div>

    <!-- 抽检配置（仅部分抽检时显示） -->
    <div class="data-range-section" v-if="currentTask?.qualityScope === 'sampling'">
      <div class="section-label">抽检配置</div>
      <div class="sampling-info">
        <div class="sampling-item">
          <span class="sampling-label">抽检数量：</span>
          <span class="sampling-value">{{ currentTask.samplingCount }} 条</span>
        </div>
        <div class="sampling-item">
          <span class="sampling-label">分配方式：</span>
          <span class="sampling-value">{{ getAllocationMethodLabel(currentTask.allocationMethod) }} {{ currentTask.allocationValue }}</span>
        </div>
        <div class="sampling-item">
          <span class="sampling-label">抽样方式：</span>
          <span class="sampling-value">{{ getSamplingMethodLabel(currentTask.samplingMethod) }}</span>
        </div>
        <div class="sampling-item">
          <span class="sampling-label">抽样维度：</span>
          <span class="sampling-value">{{ getSamplingDimensionLabel(currentTask.samplingDimension) }}</span>
        </div>
      </div>
    </div>
  </div>
</a-modal>
```

### 4. 添加辅助标签函数

将枚举值转为中文显示：

```ts
const getFieldTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    callTime: '通话时间',
    callDuration: '通话时长',
    intent: '客户意图',
    agent: '坐席工号',
  }
  return map[type] || type
}

const getRecordTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    ai_assisted: '人机协同录音',
    manual_outbound: '人工外呼录音',
    manual_upload: '手动上传录音',
  }
  return map[type] || '-'
}

const getOperatorLabel = (operator: string) => {
  const map: Record<string, string> = {
    '=': '等于', '>': '大于', '<': '小于',
    '>=': '大于等于', '<=': '小于等于', '!=': '不等于',
    'contains': '包含', 'between': '介于',
  }
  return map[operator] || operator
}

const getAllocationMethodLabel = (method: string) => {
  const map: Record<string, string> = { total: '按总量', ratio: '按比例', perPerson: '按人均' }
  return map[method] || '-'
}

const getSamplingMethodLabel = (method: string) => {
  const map: Record<string, string> = { average: '平均分配', ratio: '按比例分配' }
  return map[method] || '-'
}

const getSamplingDimensionLabel = (dimension: string) => {
  const map: Record<string, string> = { scene: '按场景', agent: '按坐席', callDuration: '按通话时长' }
  return map[dimension] || '-'
}
```

### 5. 更新 Mock 数据

在 `onMounted` 的 `currentTask` 赋值中添加配置字段：

```ts
currentTask.value = {
  // ... 原有字段
  qualityScope: 'sampling',
  recordType: 'ai_assisted',
  conditionExpressions: [
    {
      conditions: [
        { fieldType: 'callTime', operator: 'between', value: '2026-02-01 00:00', value2: '2026-02-28 23:59' },
      ]
    },
    {
      conditions: [
        { fieldType: 'callDuration', operator: '>', value: '60' },
        { fieldType: 'intent', operator: 'contains', value: '金融产品' },
      ]
    }
  ],
  autoAppendExecTime: '09:00',
  autoAppendStartType: 'yesterday',
  autoAppendRangeStart: '08:00',
  autoAppendEndType: 'today',
  autoAppendRangeEnd: '20:00',
  samplingCount: 100,
  allocationMethod: 'ratio',
  allocationValue: 10,
  samplingMethod: 'average',
  samplingDimension: 'scene',
}
```

### 6. 添加 CSS 样式

```css
/* 链接样式 */
.data-range-link {
  color: #1677ff;
  cursor: pointer;
  font-size: 14px;
}
.data-range-link:hover {
  color: #4096ff;
  text-decoration: underline;
}

/* 弹窗内容 */
.data-range-content { padding: 8px 0; }
.data-range-section {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}
.data-range-section:last-child { border-bottom: none; }
.section-label {
  font-size: 14px;
  font-weight: 600;
  color: #262626;
  margin-bottom: 8px;
}
.section-value {
  font-size: 14px;
  color: #595959;
}

/* 条件表达式 */
.condition-expressions { display: flex; flex-direction: column; gap: 8px; }
.condition-expression-item { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; }
.expression-conditions { display: flex; align-items: center; gap: 4px; }
.condition-field { color: #1677ff; font-weight: 500; }
.condition-operator { color: #8c8c8c; margin: 0 4px; }
.condition-value { color: #262626; }
.condition-connector { color: #8c8c8c; margin: 0 8px; }
.expression-connector { color: #ff4d4f; font-weight: 500; margin: 0 8px; }

/* 配置项列表 */
.auto-append-info,
.sampling-info { display: flex; flex-direction: column; gap: 8px; }
.append-item,
.sampling-item { display: flex; align-items: center; }
.append-label,
.sampling-label { color: #8c8c8c; font-size: 14px; min-width: 100px; }
.append-value,
.sampling-value { color: #262626; font-size: 14px; }
```

## 关键设计要点

- 弹窗采用 `:footer="null"` 无按钮，纯只读展示
- 用 `v-if` 控制每个 section 的显示，仅展示有数据的部分
- 条件表达式用"且"（蓝色字段名）和"或"（红色）连接，视觉层级清晰
- 辅助函数统一管理枚举值到中文的映射，避免模板中硬编码
- Mock 数据需覆盖各种配置组合（全量/抽检、有/无自动追加、多表达式等）
