---
name: vue-workbench-layout
description: 工作台页面布局模式：左侧可折叠卡片列表 + 右侧详情区，支持固定宽度左侧面板、标签切换、带Tooltip的排序选择器
source: auto-skill
extracted_at: '2026-06-16T09:58:28.864Z'
---

# 工作台页面布局模式

象小秘项目中的工作台页面采用左侧卡片列表 + 右侧详情区域的经典布局。参考页面：`QualityWorkbench.vue`（质检工作台）、`PhoneWorkWorkbench.vue`（电话工作台）。

## 整体结构

### 方式一：Grid 布局（适合响应式）
```html
<div class="xxx-workbench">
  <a-row :gutter="16" class="main-container">
    <a-col :span="6|7" class="left-panel" v-show="!leftPanelCollapsed">...</a-col>
    <div v-show="leftPanelCollapsed" class="expand-btn-wrapper">...</div>
    <a-col :span="17|18" class="right-panel">...</a-col>
  </a-row>
</div>
```

### 方式二：Flex 布局（固定宽度左侧面板，推荐）
```html
<div class="xxx-workbench">
  <div class="main-container">
    <div class="left-panel" v-show="!leftPanelCollapsed" style="width: 300px;">...</div>
    <div v-show="leftPanelCollapsed" class="expand-btn-wrapper">...</div>
    <div class="right-panel">...</div>
  </div>
</div>
```

```scss
.main-container {
  height: calc(100vh - 32px);
  display: flex;
  gap: 16px;
  position: relative;
}

.left-panel {
  height: 100%;
  overflow: visible;
  position: relative;
  flex-shrink: 0;  // 固定宽度，不收缩
}

.right-panel {
  height: 100%;
  overflow-y: auto;
  flex: 1;
  min-width: 0;
}
```

## 左侧卡片区域

### 必备元素
1. **折叠按钮**：位于容器右侧边缘，点击收起左侧面板
2. **搜索框**：`a-input-search`，带搜索按钮
3. **标签切换**：`a-radio-group`，根据业务定义选项
4. **卡片列表**：可滚动区域，每个卡片包含：
   - 头部：名称 + 状态标签（`a-tag`）
   - 信息区：关键字段（编号、时间等）
   - 底部：统计数据（待跟进数、总数等）
5. **底部分页**：总数 + `a-pagination`

### 标签切换选项
根据业务场景自定义，例如：
- **质检工作台**：待办任务 / 全部任务
- **电话工作台**：开启中 / 已关闭 / 已过期 / 全部

```typescript
const activeTab = ref<'active' | 'closed' | 'expired' | 'all'>('active')

// 过滤逻辑
const filteredList = computed(() => {
  let list = dataList.value
  if (activeTab.value !== 'all') {
    list = list.filter(item => item.status === activeTab.value)
  }
  return list
})
```

### 卡片内容模式
- **含内嵌表格**：卡片内展示小型数据表格（如质检工作台的任务明细）
- **纯信息卡片**：仅展示关键信息 + 底部统计（如电话工作台的场景卡片，推荐用于左侧面板较窄时）

### 卡片交互
- 点击卡片选中，高亮样式（`active` class）
- hover 时边框变色 + 阴影

### 排序选择器（带 Tooltip 说明）
在标签切换下方添加排序选择器，每个选项附带 `❓` 帮助图标，hover 展示排序逻辑说明：

```html
<div class="sort-bar">
  <span class="sort-label">排序：</span>
  <a-select v-model:value="sortBy" style="flex: 1">
    <a-select-option value="assignTime">
      按最新分配时间
      <a-tooltip placement="topLeft" :overlayStyle="{ maxWidth: '420px' }">
        <template #title>
          <div style="white-space: normal;">
            1、按最新任务分配时间排序，最近有分配的优先<br/>
            2、未下发任务的按场景创建时间倒序
          </div>
        </template>
        <QuestionCircleOutlined style="margin-left: 4px; color: #8f959e;" />
      </a-tooltip>
    </a-select-option>
    <a-select-option value="collabType">
      按协同类型
      <a-tooltip placement="topLeft" :overlayStyle="{ maxWidth: '420px' }">
        <template #title>
          <div style="white-space: normal;">
            排序逻辑：<br/>
            1、开启人机协同的「作业中」场景<br/>
            2、开启人机协同的「作业时间不满足」场景<br/>
            ...
          </div>
        </template>
        <QuestionCircleOutlined style="margin-left: 4px; color: #8f959e;" />
      </a-tooltip>
    </a-select-option>
  </a-select>
</div>
```

**注意事项**：Tooltip 放在 `a-select-option` 内部时，需要在图标元素上加 `@click.stop` 防止点击穿透关闭下拉：
```html
<QuestionCircleOutlined @click.stop style="margin-left: 4px; color: #8f959e;" />
```

**样式**：
```scss
.sort-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}
.sort-label {
  font-size: 13px;
  color: #595959;
  flex-shrink: 0;
}
```

**复杂排序逻辑示例**（多维度优先级分组 + 组内时间排序）：
```typescript
const getPriority = (scene: SceneItem) => {
  if (scene.collabEnabled && scene.status === 'active') return 1  // 开启协同+作业中
  if (scene.collabEnabled && scene.status === 'expired') return 2 // 开启协同+时间不满足
  if (!scene.collabEnabled && scene.status === 'active') return 3 // 未开启+作业中
  if (!scene.collabEnabled && scene.status === 'expired') return 4 // 未开启+时间不满足
  return 5 // 其他状态
}

list.sort((a, b) => {
  const diff = getPriority(a) - getPriority(b)
  if (diff !== 0) return diff
  return b.createTime.localeCompare(a.createTime) // 同组内按创建时间倒序
})
```

## 右侧详情区域

### 必备元素
1. **面包屑**：`a-breadcrumb`，显示模块 > 子页面
2. **筛选区**：搜索输入框 + 快捷筛选按钮 + 高级搜索链接
3. **批量操作栏**：导出、分配、删除等按钮 + 列表显示设置
4. **数据表格**：`a-table`，带行选择、分页、固定列

### 批量操作栏位置
- **独立区域**：筛选区和表格之间单独一个卡片
- **合并到表格卡片**（推荐）：批量操作栏放在表格卡片内部，用分隔线区分，UI 更紧凑

```html
<a-card class="table-card">
  <div class="batch-toolbar">
    <a-space>
      <a-button size="small">批量导出</a-button>
      <a-button size="small">批量分配</a-button>
    </a-space>
    <a-button size="small">列表显示设置</a-button>
  </div>
  <div class="table-header-info">共 X 条，已选 Y 条</div>
  <a-table ... />
</a-card>
```

```scss
.batch-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}
```

### 高级搜索
- 使用 `a-drawer` 抽屉实现
- 表单字段垂直布局
- 底部固定重置 + 搜索按钮

## 折叠/展开机制

```typescript
const leftPanelCollapsed = ref(false)

const toggleLeftPanel = () => {
  leftPanelCollapsed.value = !leftPanelCollapsed.value
}
```

- 折叠按钮：`position: absolute; right: -12px; top: 50%`
- 展开按钮：`position: absolute; left: -8px; top: 50%`
- 按钮样式：蓝色窄条 `width: 13px; height: 36px; background: #1677ff`

## 样式要点

```scss
.workbench {
  padding: 16px;
  background-color: #f5f7fb;
  min-height: 100vh;
}

.task-list-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.03);
}
```

### 卡片样式
- 默认：`border: 1px solid #e8e8e8`
- hover：`border-color: #1677ff; box-shadow: 0 2px 8px rgba(22, 119, 255, 0.15)`
- 选中：`border-color: #1677ff; background-color: #e6f7ff`

### 表格表头
```scss
.workbench-table :deep(.ant-table-thead > tr > th) {
  background-color: #e6f4ff;
  color: #1f2329;
  font-weight: 500;
}
```

## 创建新工作台页面的步骤

1. 参考 `QualityWorkbench.vue` 或 `PhoneWorkWorkbench.vue` 的整体结构
2. 选择布局方式：Grid（响应式）或 Flex（固定宽度左侧面板）
3. 定义左侧卡片数据接口（id、名称、状态、统计字段）
4. 实现折叠/展开逻辑
5. 实现搜索过滤 + 标签切换（根据业务定义选项）
6. 右侧实现筛选区 + 批量操作 + 数据表格
7. 按 `vue-new-page-setup` 技能完成路由和菜单集成
