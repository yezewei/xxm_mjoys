---
name: vue-card-list-config-page
description: 在已有菜单下新增"卡片列表页+配置详情页"组合：列表页展示可点击卡片，点击进入带CRUD表格的配置页面，含路由/菜单/权限全套集成
source: auto-skill
extracted_at: '2026-07-13T06:35:39.079Z'
---

# 卡片列表页 + 配置详情页

在象小秘项目中，为已有父菜单新增一个子菜单项，该菜单项打开一个卡片列表页（展示多个可点击的实体卡片），点击卡片后跳转到带 CRUD 表格的配置详情页。

## 适用场景

- 同一类实体有多个实例（如多个模型、多个策略、多个模板），每个实例需要独立配置
- 列表页用卡片展示概览信息（名称、状态、统计数据），配置页用表格管理该实例下的子数据（关键词、规则等）
- 详情页通过 `route.query.type` 区分不同实例

## 文件清单

| 文件 | 作用 |
|---|---|
| `src/pages/XxxList.vue` | 卡片列表页 |
| `src/pages/XxxConfig.vue` | 配置详情页（带 CRUD 表格） |
| `src/router.ts` | 新增 2 条路由 |
| `src/components/Layout.vue` | 菜单项 + 4 处映射表 |
| `src/pages/RoleManagement.vue` | 权限树新增节点 |

## Step 1：卡片列表页 `XxxList.vue`

### 数据结构

```ts
interface ModelItem {
  type: string;           // 唯一标识，用作路由 query 参数
  name: string;           // 显示名称
  description: string;    // 功能描述
  icon: any;              // ant-design 图标组件
  iconBg: string;         // 图标背景渐变色
  enabled: boolean;       // 启用状态
  keywordCount: number;   // 统计数据示例
  similarCount: number;   // 统计数据示例
}
```

### 卡片模板

```html
<div class="model-cards">
  <div
    v-for="model in modelList"
    :key="model.type"
    class="model-card"
    @click="handleGoConfig(model.type)"
  >
    <div class="card-header">
      <div class="card-icon" :style="{ background: model.iconBg }">
        <component :is="model.icon" style="font-size: 28px; color: #fff" />
      </div>
      <a-badge :status="model.enabled ? 'success' : 'default'" :text="model.enabled ? '已启用' : '已停用'" />
    </div>
    <div class="card-body">
      <h3 class="card-title">{{ model.name }}</h3>
      <p class="card-desc">{{ model.description }}</p>
    </div>
    <div class="card-footer">
      <div class="card-stats">
        <div class="stat-item">
          <span class="stat-value">{{ model.keywordCount }}</span>
          <span class="stat-label">关键词</span>
        </div>
      </div>
      <div class="card-action">
        <span>配置管理</span>
        <right-outlined />
      </div>
    </div>
  </div>
</div>
```

### 跳转方式

```ts
const handleGoConfig = (type: string) => {
  router.push({ path: '/xxx-config', query: { type } });
};
```

### 卡片样式要点

```css
.model-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);  /* 2列网格 */
  gap: 24px;
  max-width: 900px;
}

.model-card {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.model-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  transform: translateY(-2px);  /* 悬浮上浮效果 */
}
```

## Step 2：配置详情页 `XxxConfig.vue`

### 从路由 query 获取实例类型

```ts
const route = useRoute();
const modelType = computed(() => (route.query.type as string) || 'default-type');

// 根据 type 加载对应配置信息
const modelInfoMap: Record<string, ModelInfo> = { ... };
```

### 页面头部（返回按钮 + 标题 + 启用开关）

```html
<div class="config-header">
  <div class="header-left">
    <a-button type="link" @click="handleGoBack" class="back-btn">
      <left-outlined /> 返回
    </a-button>
    <div class="header-title-group">
      <h2 class="page-title">{{ modelInfo.name }}</h2>
      <a-badge :status="modelInfo.enabled ? 'success' : 'default'" :text="..." />
    </div>
  </div>
  <a-switch v-model:checked="modelInfo.enabled" checked-children="启用" un-checked-children="停用" />
</div>
```

### 多 Tab CRUD 表格

用 `a-tabs` 分标签管理不同类型的子数据（如关键词 / 相似问），每个 Tab 内包含：
- 搜索输入框 + 新增按钮（toolbar）
- `a-table` 列表，含状态开关、编辑/删除操作列
- `a-modal` 弹窗用于新增/编辑

```html
<a-tabs v-model:activeKey="activeTab">
  <a-tab-pane key="keyword" tab="关键词管理">
    <div class="tab-toolbar">
      <a-input v-model:value="keywordSearch" placeholder="搜索关键词" allow-clear style="width: 240px">
        <template #prefix><search-outlined /></template>
      </a-input>
      <a-button type="primary" @click="handleAdd('keyword')">
        <plus-outlined /> 新增关键词
      </a-button>
    </div>
    <a-table :columns="keywordColumns" :data-source="filteredKeywords" row-key="id" ...>
      <!-- 操作列：编辑 + popconfirm 删除 -->
      <!-- 状态列：a-switch -->
      <!-- 优先级列：a-tag 颜色映射 -->
    </a-table>
  </a-tab-pane>
  <!-- 第二个 Tab 类似结构 -->
</a-tabs>
```

### 关键点

- **弹窗复用**：一个 `a-modal` 通过 `modalType` 区分是关键词还是相似问的新增/编辑，表单字段动态切换
- **编辑回填**：`handleEdit` 时将 record 数据写入 formData，并设置 `editId`
- **搜索过滤**：用 `computed` 过滤 `reactive` 数组，支持关键词模糊匹配
- **删除确认**：使用 `a-popconfirm` 而非 `a-modal.confirm`，更轻量
- **表格表头样式**：统一用 `:deep(.ant-table-thead > tr > th) { background: #e6f4ff; }` 与项目其他页面一致

## Step 3：路由集成 `router.ts`

在同模块路由附近添加 2 条路由：

```ts
{
  path: "/xxx-list",
  name: "XxxList",
  component: () => import("./pages/XxxList.vue"),
},
{
  path: "/xxx-config",
  name: "XxxConfig",
  component: () => import("./pages/XxxConfig.vue"),
},
```

## Step 4：Layout.vue 集成（4 处 + 1 处菜单项）

只需为**列表页**添加菜单项和映射。配置详情页不单独出现在菜单中，但需要在 `pathToKeyMap` 中映射回列表页的 key，确保从配置页返回时菜单仍然高亮。

**① 菜单项**（只加列表页）：

```html
<a-menu-item key="xxx-list">
  <span>实时模型管理</span>
</a-menu-item>
```

**② menuRouteMap**（只加列表页）：

```ts
'xxx-list': '/xxx-list',
```

**③ menuTitleMap**：

```ts
'xxx-list': '实时模型管理',
```

**④ pathToKeyMap**（两条路径都映射到同一个 key）：

```ts
'/xxx-list': 'xxx-list',
'/xxx-config': 'xxx-list',   // 配置页也映射回列表页的菜单 key
```

**⑤ subMenuChildren**：

```ts
knowledge: ['knowledge-word', ..., 'xxx-list'],
```

## Step 5：权限树 `RoleManagement.vue`

在对应父节点的 children 数组中新增一条：

```ts
{ key: 'xxx-list', title: '实时模型管理' },
```

## 检查清单

- [ ] `XxxList.vue` 卡片列表页已创建
- [ ] `XxxConfig.vue` 配置详情页已创建，含 CRUD 表格和弹窗
- [ ] `router.ts` 新增 2 条路由（列表页 + 配置页）
- [ ] Layout.vue 菜单项（只加列表页 key）
- [ ] Layout.vue `menuRouteMap` 有列表页 key → path
- [ ] Layout.vue `menuTitleMap` 有列表页 key → 中文名
- [ ] Layout.vue `pathToKeyMap` 有列表页 path → key **和** 配置页 path → 列表页 key
- [ ] Layout.vue `subMenuChildren` 对应数组包含列表页 key
- [ ] `RoleManagement.vue` 权限树有列表页节点
- [ ] 列表页 `@click` 跳转使用 `router.push({ path, query: { type } })`
- [ ] 配置页用 `route.query.type` 区分实例，`computed` 获取
- [ ] 配置页头部有返回按钮跳回列表页
