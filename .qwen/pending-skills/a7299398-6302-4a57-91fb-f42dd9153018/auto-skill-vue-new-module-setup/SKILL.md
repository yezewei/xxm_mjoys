---
name: vue-new-module-setup
description: 在象小秘项目中创建完整功能模块：入口页 + 多个子页面 + 嵌套路由 + PRD文档 + 菜单配置
source: auto-skill
extracted_at: '2026-07-09T06:36:23.873Z'
---

# 新模块创建流程

在象小秘项目中创建一个完整功能模块，包含入口页、多个子页面、嵌套路由、PRD文档和菜单配置。与 `vue-new-page-setup`（单页面）的区别：本技能适用于需要创建**一组相关页面**的场景。

## 适用场景

- 新增业务模块（如：客户分析、质检管理、数据看板）
- 模块内含多个子页面，通过入口页导航
- 子页面使用嵌套路由（如 `/module`、`/module/list`、`/module/detail/:id`）

## 模块结构模板

```
模块名/
├── 入口页（概览 + 功能卡片导航）
├── 列表页（CRUD 搜索/表格/分页）
├── 详情页（Tab 切换/数据展示）
├── 配置页（设置/模板管理）
└── 仓库页（历史记录/报告管理）
```

## 创建步骤

### Step 1: 创建 PRD 文档 `docs/prd/XXX功能PRD.md`

先与用户确认需求，整理为标准 PRD，包含：
- 功能概述与目标
- 功能架构图（文字描述）
- 每个子模块的详细需求
- 页面清单与路由规划
- 接口清单（预留）
- 数据字典

### Step 2: 创建页面文件 `src/pages/`

按 PRD 规划创建页面，典型页面类型：

**入口页（如 CustomerAnalysis.vue）**
```vue
<template>
  <div class="module-home">
    <!-- 顶部标题区 -->
    <div class="header-section">
      <h2>模块名称</h2>
      <p>模块描述</p>
    </div>
    <!-- 功能卡片区 -->
    <div class="feature-cards">
      <div class="feature-card" @click="router.push('/module/sub1')">
        <h3>子功能1</h3>
        <p>描述</p>
      </div>
    </div>
    <!-- 快速开始/最近记录 -->
  </div>
</template>
```

**列表页（如 CrossAnalysis.vue）**
- 复用项目 CRUD 模式：搜索区 + 表格 + 分页
- 操作列包含：查看、编辑、执行、删除等

**详情页（如 CrossAnalysisDetail.vue）**
- 顶部信息卡片
- Tab 切换：透视表 / 图表 / 数据明细
- 返回按钮跳转回入口页

**配置页（如 ReportTemplate.vue）**
- 表单配置：维度选择、指标选择
- 定时任务配置：周期、时间
- 分发配置：接收人、渠道

### Step 3: 添加路由 `src/router.ts`

在同模块路由附近添加嵌套路由：

```ts
// 入口页
{ path: "/module", name: "Module", component: () => import("./pages/Module.vue") },
// 子页面（使用嵌套路径）
{ path: "/module/list", name: "ModuleList", component: () => import("./pages/ModuleList.vue") },
{ path: "/module/detail/:id", name: "ModuleDetail", component: () => import("./pages/ModuleDetail.vue") },
{ path: "/module/config", name: "ModuleConfig", component: () => import("./pages/ModuleConfig.vue") },
```

**关键点**：子页面使用 `/module/xxx` 前缀，便于菜单高亮和路由管理。

### Step 4: 更新 `src/components/Layout.vue`（5 处）

仅需为**入口页**配置菜单，子页面通过入口页导航，不需要独立菜单项。

**① 菜单项**：在对应 `a-sub-menu` 下添加入口页菜单：

```html
<a-menu-item key="module">
  <span>模块名称</span>
</a-menu-item>
```

**② menuRouteMap**：

```ts
'module': '/module',
```

**③ menuTitleMap**：

```ts
'module': '模块名称',
```

**④ pathToKeyMap**：

```ts
'/module': 'module',
```

**⑤ subMenuChildren**：

```ts
'parent-group': ['existing-item', 'module'],
```

## 与 vue-new-page-setup 的区别

| 场景 | vue-new-page-setup | vue-new-module-setup |
|------|-------------------|---------------------|
| 页面数量 | 1 个 | 多个（3-6 个） |
| 路由结构 | 扁平路由 | 嵌套路由 |
| 菜单配置 | 每个页面都要配置 | 只配入口页 |
| PRD | 不需要 | 建议先写 PRD |
| 入口页 | 不需要 | 需要概览/导航页 |

## 检查清单

- [ ] PRD 文档已创建（docs/prd/）
- [ ] 所有页面文件已创建（src/pages/）
- [ ] router.ts 中有入口页 + 所有子页面路由
- [ ] Layout.vue 菜单项仅配置入口页
- [ ] menuRouteMap / menuTitleMap / pathToKeyMap 仅配置入口页
- [ ] subMenuChildren 包含入口页 key
- [ ] 子页面返回按钮跳转到入口页或列表页
- [ ] 入口页功能卡片可正确跳转到子页面

## 实际案例

### 客户分析模块（2026-07-09）

```
customer-analysis/          → CustomerAnalysis.vue（入口）
customer-analysis/cross     → CrossAnalysis.vue（列表）
customer-analysis/cross/:id → CrossAnalysisDetail.vue（详情）
customer-analysis/indicators → IndicatorManagement.vue（配置）
customer-analysis/templates → ReportTemplate.vue（配置）
customer-analysis/reports   → ReportWarehouse.vue（仓库）
```

菜单仅配置 `customer-analysis`，子页面通过入口页的功能卡片导航。
