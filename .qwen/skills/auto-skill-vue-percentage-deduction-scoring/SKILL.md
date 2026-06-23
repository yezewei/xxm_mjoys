---
name: vue-percentage-deduction-scoring
description: 将 Vue 质检/评分系统改造为百分制扣分模式（满分100，逐项扣分），同步更新工作台汇总卡片和详情弹窗评分展示
source: auto-skill
extracted_at: '2026-06-23T06:23:57.858Z'
---

# 百分制扣分评分系统改造

将评分逻辑从"加减分混合模式"改为"百分制扣分模式"（满分 100，区间 0~100，按规则逐项扣分），涉及工作台列表页和详情弹窗两个组件的联动修改。

## 适用场景

- 质检评分从 add/deduct 混合改为纯扣分
- 需要在工作台展示评分汇总卡片（扣分明细 + 评分规则说明）
- 需要在详情弹窗中统一评分汇总的展示样式

## 改造步骤

### 1. 定义扣分数据结构

在工作台页面定义扣分明细类型：

```typescript
interface ScoreDeduction {
  ruleCode: string    // 规则编号，如 'A1'、'B2'
  ruleDesc: string    // 规则描述
  maxDeduct: number   // 该项最大扣分值
}
```

在任务/记录类型中增加 `scoreDeductions?: ScoreDeduction[]` 字段，为模拟数据补充扣分明细。

### 2. 工作台模板：添加评分汇总卡片

在任务信息卡片（`<a-card>`）和筛选区域之间插入评分汇总卡片：

```html
<a-card v-if="currentTask" class="score-summary-card">
  <div class="score-summary-header">
    <span class="score-summary-title">评分汇总</span>
    <a-tag color="blue">百分制</a-tag>
  </div>
  <!-- 统计区：满分 / 评分区间 / 扣分项数量 -->
  <div class="score-summary-stats">
    <div class="stat-item">
      <div class="stat-value">100</div>
      <div class="stat-label">满分</div>
    </div>
    <div class="stat-item">
      <div class="stat-value">0~100</div>
      <div class="stat-label">评分区间</div>
    </div>
    <div class="stat-item">
      <div class="stat-value">{{ currentTask.scoreDeductions?.length || 0 }}</div>
      <div class="stat-label">扣分项</div>
    </div>
  </div>
  <!-- 扣分明细列表 -->
  <div class="score-deduction-list">
    <div class="deduction-title">扣分明细</div>
    <div class="deduction-items">
      <div v-for="item in currentTask.scoreDeductions" :key="item.ruleCode" class="deduction-item">
        <span class="deduction-code">{{ item.ruleCode }}</span>
        <span class="deduction-desc">{{ item.ruleDesc }}</span>
        <span class="deduction-value">-{{ item.maxDeduct }}分</span>
      </div>
    </div>
  </div>
  <!-- 评分规则说明 -->
  <div class="score-note">
    评分规则：百分制满分 100 分，根据质检规则触发情况逐项扣分，最终得分 = 100 - 扣分总和
  </div>
</a-card>
```

### 3. 详情弹窗：统一 ruleScores 为纯扣分

将 ruleScores 从 `{ type: 'add' | 'deduct'; value: number }` 简化为纯数字：

```typescript
// 改造前
const ruleScores: Record<string, { type: 'add' | 'deduct'; value: number }> = {
  'A1': { type: 'deduct', value: 10 },
  'A2': { type: 'add', value: 5 },
}

// 改造后
const ruleScores: Record<string, number> = {
  'A1': 5,
  'A2': 5,
  'A3': 10,
  'B1': 10,
  'B2': 15,
}
```

辅助函数同步更新：

```typescript
const getRuleScoreText = (ruleCode: string): string => {
  const value = ruleScores[ruleCode]
  if (!value) return ''
  return `-${value}分`
}

const getRuleScoreColor = (ruleCode: string): string => {
  const value = ruleScores[ruleCode]
  if (!value) return 'default'
  return value >= 10 ? 'red' : 'orange'  // 按扣分严重程度分色
}
```

### 4. 详情弹窗：评分汇总计算改为百分制

```typescript
// 改造前：加减分混合
const aiScoreSummary = computed(() => {
  let addScore = 0, deductScore = 0
  // ... score.type === 'add' ? addScore += score.value : deductScore += score.value
  return { add: addScore, deduct: deductScore, total: addScore - deductScore }
})

// 改造后：纯扣分 + 最终得分
const aiScoreSummary = computed(() => {
  let totalDeductions = 0
  const seen = new Set<string>()
  aiResults.value.forEach(result => {
    if (seen.has(result.ruleCode)) return
    seen.add(result.ruleCode)
    const value = ruleScores[result.ruleCode]
    if (!value) return
    totalDeductions += value
  })
  return { totalDeductions, finalScore: 100 - totalDeductions }
})
```

### 5. 详情弹窗：评分汇总模板改为三栏

将原来的「得分 / 扣分 / 合计」改为「满分 / 扣分 / 最终得分」：

```html
<div class="score-summary-box">
  <div class="score-summary-title">评分汇总（百分制）</div>
  <div class="score-summary-items">
    <div class="score-item score-total-base">
      <span class="score-label">满分</span>
      <span class="score-value">100 分</span>
    </div>
    <div class="score-item score-deduct">
      <span class="score-label">扣分</span>
      <span class="score-value">-{{ scoreSummary.totalDeductions }}分</span>
    </div>
    <div class="score-item score-total">
      <span class="score-label">最终得分</span>
      <span class="score-value"
        :class="scoreSummary.finalScore >= 80 ? 'positive' : scoreSummary.finalScore >= 60 ? 'warning' : 'negative'">
        {{ scoreSummary.finalScore }}分
      </span>
    </div>
  </div>
</div>
```

### 6. CSS 样式要点

- `.score-total-base`：蓝色背景（`#f0f5ff` + `#adc6ff` 边框），蓝色文字 `#1677ff`
- `.score-deduct`：红色背景（`#fff2f0` + `#ffccc7` 边框），红色文字 `#ff4d4f`
- `.score-total .positive`：绿色 `#52c41a`（≥80 分）
- `.score-total .warning`：橙色 `#faad14`（60~79 分）
- `.score-total .negative`：红色 `#ff4d4f`（<60 分）
- 移除旧的 `.score-add` 样式

## 关键注意事项

1. **ruleScores 值一致性**：工作台的 `scoreDeductions[].maxDeduct` 和详情弹窗的 `ruleScores` 必须保持一致
2. **多处评分汇总模板**：详情弹窗中通常有多处评分汇总（AI 质检结果 tab、人工审核结果 tab、人工质检任务 tab），需全部同步修改
3. **computed 属性中去重**：扣分计算时用 `Set` 去重，同一规则只扣一次分
4. **最终得分色值分级**：≥80 绿色、60~79 橙色、<60 红色，与列表页表格中的评分色值逻辑保持一致
