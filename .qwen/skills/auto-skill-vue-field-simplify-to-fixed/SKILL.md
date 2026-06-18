---
name: vue-field-simplify-to-fixed
description: 将 Vue 3 + Ant Design Vue 中的多模式 Radio 表单字段简化为固定值，移除关联的条件子表单和接口字段
source: auto-skill
extracted_at: '2026-06-16T11:51:26.809Z'
---

# 多模式字段简化为固定值

当页面有一个 Radio 切换的多模式表单字段（如"每日/每周/每月"），需要简化为只保留一个固定值时，按以下步骤系统化清理。

> 与 `vue-field-to-multimode`（单字段扩展为多模式）互为逆操作。本技能聚焦于**移除多余模式**，需同步清理接口、条件子表单、描述文案和 mock 数据。

## 1. 模板改造

将 Radio 切换替换为静态文字，移除已废弃模式的条件子表单：

```html
<!-- 改造前 -->
<a-form-item label="执行频率">
  <a-radio-group v-model:value="formData.schedule.frequency">
    <a-radio value="daily">每日</a-radio>
    <a-radio value="weekly">每周</a-radio>
    <a-radio value="monthly">每月</a-radio>
  </a-radio-group>
</a-form-item>
<a-form-item v-if="formData.schedule.frequency === 'weekly'" label="执行日期">
  <!-- 周选择器 ... -->
</a-form-item>
<a-form-item v-if="formData.schedule.frequency === 'monthly'" label="执行日期">
  <!-- 月选择器 ... -->
</a-form-item>

<!-- 改造后 -->
<a-form-item label="执行频率">
  <span class="fixed-value">每日</span>
</a-form-item>
<!-- 周/月条件子表单全部删除 -->
```

**要点**：用 `<span class="fixed-value">` 替代控件，保持表单布局对齐。

## 2. 接口精简

从类型定义中移除已废弃的字段：

```ts
// 改造前
interface ScheduleData {
  frequency: 'daily' | 'weekly' | 'monthly'
  weekDays: number[]
  monthDays: number[]
  // ...其他字段保留
}

// 改造后：移除 frequency、weekDays、monthDays
interface ScheduleData {
  // ...其他字段保留
}
```

列表数据接口（如 `SamplingRuleItem`）同步移除对应字段（`scheduleFrequency`、`scheduleWeekDays`、`scheduleMonthDays`）。

## 3. 描述文案简化

移除 `scheduleDescription` 和 `getScheduleLabel` 中对已废弃模式的分支判断：

```ts
// 改造前
const freqMap = { daily: '每天', weekly: '每周', monthly: '每月' }
let desc = freqMap[formData.schedule.frequency] || '每天'
if (formData.schedule.frequency === 'weekly' && ...) { /* 拼接周名 */ }
if (formData.schedule.frequency === 'monthly' && ...) { /* 拼接月日 */ }

// 改造后：直接以固定值开头
let desc = '每天'
// 继续拼接其他描述...
```

表格列展示同理，移除频率映射逻辑。

## 4. Mock 数据清理

从所有 mock 数据条目中移除已废弃字段：

```ts
// 改造前
{ scheduleFrequency: 'weekly', scheduleWeekDays: [1, 3, 5], scheduleMonthDays: [], executeTime: '08:30', ... }

// 改造后
{ executeTime: '08:30', ... }
```

## 5. 表单生命周期清理

### 5.1 `createDefaultFormData` — 移除废弃字段默认值

```ts
schedule: {
  // 移除 frequency、weekDays、monthDays
  dataOffsetMode: 'days',
  dataOffset: 1,
  // ...
}
```

### 5.2 `fillFormData` — 移除废弃字段赋值

```ts
// 移除以下行
// formData.schedule.frequency = record.scheduleFrequency
// formData.schedule.weekDays = [...record.scheduleWeekDays]
// formData.schedule.monthDays = [...record.scheduleMonthDays]
```

## 6. CSS

为固定值文字添加样式：

```css
.fixed-value {
  color: #595959;
  font-size: 14px;
}
```

## 7. 验证清单

清理完成后逐一检查：

- [ ] 全文搜索已废弃字段名，确认零残留引用
- [ ] 新建弹窗：固定值显示正确
- [ ] 编辑/查看弹窗：回填逻辑正常（不因缺少字段报错）
- [ ] 策略概览卡片：展示正确的固定值描述
- [ ] 表格执行计划列：所有数据均能正确显示
- [ ] `scheduleDescription` 预览文案：不包含已废弃模式的分支
