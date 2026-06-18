---
name: vue-field-to-multimode
description: 将 Vue 3 + Ant Design Vue 中已有的单模式表单字段改造为 Radio 切换的多模式条件字段，同步更新接口、描述文案、概览卡片等所有关联显示
source: auto-skill
extracted_at: '2026-06-16T11:20:24.686Z'
---

# 单字段改造为多模式条件字段

当页面已有一个简单表单字段（如 InputNumber、DatePicker），需要扩展为"Radio 切换模式 + 条件子表单"时，按以下步骤系统化改造。

> 与 `vue-conditional-radio-subform`（从零创建新条件表单）不同，本技能聚焦于**改造已有字段**，需同步更新接口、mock 数据、多处描述文案和概览展示。

## 1. 扩展数据接口

在类型定义中添加模式字段和各模式的值字段：

```ts
// 原来只有单一字段
interface ScheduleData {
  dataOffset: number           // 原字段保留
}

// 改造后
interface ScheduleData {
  dataOffsetMode: 'days' | 'timeRange'   // 新增：模式标识
  dataOffset: number                       // days 模式的值
  dataStartTime: any                       // timeRange 模式的值（dayjs 对象）
  dataEndTime: any                         // timeRange 模式的值（dayjs 对象）
}
```

列表数据接口（如 `SamplingRuleItem`）同步扩展相同字段，mock 数据中字符串类型对应 `'08:00'`、`null` 等。

## 2. 模板改造

将原来的单一控件替换为 Radio + 条件子表单：

```html
<a-form-item label="数据时间偏移">
  <!-- 模式切换 -->
  <a-radio-group v-model:value="formData.schedule.dataOffsetMode" :disabled="isViewMode">
    <a-radio value="days">按天偏移</a-radio>
    <a-radio value="timeRange">精确时间范围</a-radio>
  </a-radio-group>

  <!-- 模式 A：保留原控件 -->
  <div v-if="formData.schedule.dataOffsetMode === 'days'" class="offset-row">
    <span class="offset-prefix">固定抓取</span>
    <a-input-number v-model:value="formData.schedule.dataOffset" ... />
    <span class="offset-suffix">日前的数据</span>
  </div>

  <!-- 模式 B：新控件 -->
  <div v-else class="offset-range-row">
    <span class="offset-prefix">抓取当天</span>
    <a-time-picker v-model:value="formData.schedule.dataStartTime" format="HH:mm" ... />
    <span class="date-separator">至</span>
    <a-time-picker v-model:value="formData.schedule.dataEndTime" format="HH:mm" ... />
    <span class="offset-suffix">的外呼数据</span>
  </div>

  <!-- 实时预览描述 -->
  <div class="offset-preview">{{ scheduleDescription }}</div>
</a-form-item>
```

**要点**：前缀/后缀文案要区分模式，让用户明确当前在配置什么。

## 3. 同步更新所有关联显示（关键步骤）

改造字段后，**必须遍历所有引用该字段的位置**并加入模式判断：

| 位置 | 改造方式 |
|------|---------|
| `scheduleDescription` 计算属性 | `if (mode === 'timeRange')` 分支用 `.format('HH:mm')` 拼接 |
| `getScheduleLabel()` 表格列展示 | 同上，拼接 `(08:00~18:00)` 或 `T-N` |
| 策略概览卡片 | 新增独立行展示当前模式的值 |
| 表格 `columns` 定义 | 若列宽不够展示新内容，调整 `width` |

```ts
// scheduleDescription 示例
if (formData.schedule.dataOffsetMode === 'timeRange') {
  const start = formData.schedule.dataStartTime?.format('HH:mm') || '未设置'
  const end = formData.schedule.dataEndTime?.format('HH:mm') || '未设置'
  desc += ` 抓取当天 ${start}~${end} 的数据`
} else {
  desc += ` 生成T-${formData.schedule.dataOffset}日的抽检任务`
}
```

## 4. 表单生命周期同步

### 4.1 `createDefaultFormData` — 初始化默认值

```ts
schedule: {
  dataOffsetMode: 'days',   // 默认模式
  dataOffset: 1,
  dataStartTime: null,       // dayjs 对象，初始 null
  dataEndTime: null,
  ...
}
```

### 4.2 `fillFormData` — 编辑/查看回填

从记录中读取模式和对应值，dayjs 对象字段置 null（由 TimePicker 自行解析字符串）：

```ts
formData.schedule.dataOffsetMode = record.dataOffsetMode
formData.schedule.dataOffset = record.dataOffset
formData.schedule.dataStartTime = null   // TimePicker 组件会处理
formData.schedule.dataEndTime = null
```

## 5. Mock 数据

为演示两种模式，至少各保留一条样例数据：

```ts
// 模式 A
{ dataOffsetMode: 'days', dataOffset: 1, dataStartTime: null, dataEndTime: null }
// 模式 B
{ dataOffsetMode: 'timeRange', dataOffset: 1, dataStartTime: '08:00', dataEndTime: '18:00' }
```

## 6. CSS

为新的子表单容器添加布局样式：

```css
.offset-range-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}
```

## 7. 验证清单

改造完成后逐一检查：

- [ ] 新建弹窗：两种模式切换正常，子表单显隐正确
- [ ] 编辑弹窗：回填时模式和值均正确还原
- [ ] 查看弹窗：`disabled` 状态下所有控件不可编辑
- [ ] 策略概览卡片：展示与当前模式匹配的描述
- [ ] 表格执行计划列：两种模式的数据均能正确显示
- [ ] `scheduleDescription` 预览文案：实时反映当前配置
- [ ] 搜索/筛选：若该字段参与筛选，确认不影响现有逻辑
