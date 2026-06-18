---
name: vue-new-page-integration
description: 在象小秘项目中添加新页面的完整流程：创建页面文件、配置路由、更新 Layout 菜单及 4 处映射表
source: auto-siskill
extracted_at: '2026-06-10T03:00:00.000Z'
---

# 新页面集成流程

在象小秘项目中添加一个新的独立页面，需要修改 3 个文件、更新 6 处配置。遗漏任何一处都会导致菜单高亮异常或路由跳转失败。

## 修改清单

### 1. 创建页面文件 `src/pages/XxxPage.vue`

参考同模块已有页面的结构和风格。例如质检模块的新页面参考 `QualityTask.vue` 或 `QualityRule.vue`。

### 2. 添加路由 `src/router.ts`

在同模块路由附近添加新路由：

```ts
{
  path: "/sampling-rule",
  name: "SamplingRule",
  component: () => import("./pages/SamplingRule.vue"),
},
```

### 3. 更新 `src/components/Layout.vue`（4 处 + 1 处菜单项）

**① 菜单项**：在对应的 `a-sub-menu` 下添加 `a-menu-item`，`key` 与路由 path 一致（去掉前导 `/`）：

```html
<a-menu-item key="sampling-rule">
  <span>抽检规则</span>
</a-menu-item>
```

**② menuRouteMap**：添加 key → path 映射：

```ts
'sampling-rule': '/sampling-rule',
```

**③ menuTitleMap**：添加 key → 中文标题映射（用于面包屑）：

```ts
'sampling-rule': '抽检规则',
```

**④ pathToKeyMap**：添加 path → key 映射（用于路由变化时自动高亮菜单）：

```ts
'/sampling-rule': 'sampling-rule',
```

**⑤ subMenuChildren**：将新菜单 key 加入对应子菜单的数组中（确保父菜单展开状态正确）：

```ts
'quality-inspection': ['quality-home', 'quality-workbench', 'quality-model', 'quality-task', 'quality-rule', 'sampling-rule'],
```

## 检查清单

添加新页面后，逐项确认：

- [ ] `src/pages/XxxPage.vue` 文件存在
- [ ] `router.ts` 中有对应路由
- [ ] Layout.vue 菜单项 key = 路由 path 去掉 `/`
- [ ] `menuRouteMap` 有 key → path
- [ ] `menuTitleMap` 有 key → 中文名
- [ ] `pathToKeyMap` 有 path → key
- [ ] `subMenuChildren` 对应数组包含新 key

## 常见问题

### 菜单点击无反应
检查 `menuRouteMap` 是否遗漏。没有映射时 `handleMenuClick` 找不到目标 path。

### 路由切换后菜单不高亮
检查 `pathToKeyMap` 是否遗漏。`watch(route)` 依赖此映射设置 `selectedKeys`。

### 父菜单不自动展开
检查 `subMenuChildren` 是否包含新 key。`defaultOpenKeys` 依赖此映射判断当前路由属于哪个子菜单。

### 面包屑显示不正确
检查 `menuTitleMap` 是否遗漏。`breadcrumbItems` computed 依赖此映射。
