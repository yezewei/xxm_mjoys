---
name: vue-typescript-type-fix
description: 修复 Vue 3 + TypeScript 项目中 vue-tsc 类型检查错误的系统化方法，涵盖接口类型扩展、属性缺失、模板变量类型转换、可选链参数类型等常见模式
source: auto-skill
extracted_at: '2026-07-07T06:40:34.262Z'
---

# Vue 3 + TypeScript 类型错误修复

## 触发场景
运行 `npm run build`（`vue-tsc -b && vite build`）时出现 TypeScript 编译错误，需要系统化定位和修复。

## 常见错误模式与修复方法

### 模式 1：接口类型缺少字面量值
**错误特征**：`This comparison appears to be unintentional because the types 'A | B' and 'C' have no overlap`
**场景**：模板或逻辑中使用了 interface 定义中未声明的字面量值

```typescript
// ❌ 修复前
interface AsrItem {
  role: 'robot' | 'customer';  // 缺少 'agent'
}

// ✅ 修复后
interface AsrItem {
  role: 'robot' | 'customer' | 'agent';
}
```

**注意**：扩展类型后，还需检查所有使用该接口的 mock 数据是否也需要添加对应属性（如 `confidence`）。

### 模式 2：类型定义缺少可选属性
**错误特征**：`Property 'xxx' does not exist on type '{ ... }'`
**场景**：代码中访问了类型定义中未声明的属性

```typescript
// ❌ 修复前
const items = ref<Array<{ agentId: string | undefined; ratio: number | null }>>([])
// 代码中访问 item.count → 报错

// ✅ 修复后
const items = ref<Array<{ agentId: string | undefined; ratio: number | null; count?: number }>>([])
```

### 模式 3：v-for 索引变量类型转换
**错误特征**：`Operator '<' cannot be applied to types 'string | number' and 'number'`
**场景**：Vue 模板中 `v-for` 的 `index` 参数默认类型是 `string | number`，与数字比较时报错

```html
<!-- ❌ 修复前 -->
<span v-if="cIndex < items.length - 1">且</span>

<!-- ✅ 修复后 -->
<span v-if="Number(cIndex) < items.length - 1">且</span>
```

### 模式 4：可选链导致函数参数类型不匹配
**错误特征**：`Argument of type 'string | undefined' is not assignable to parameter of type 'string'`
**场景**：使用 `?.` 可选链访问属性传入期望 `string` 的函数

```typescript
// ❌ 修复前
const getLabel = (type: string) => { ... }
// 模板中: getLabel(obj?.type) → obj?.type 是 string | undefined

// ✅ 修复后
const getLabel = (type: string | undefined) => { ... }
// 函数内部通过 map[type] || '-' 处理 undefined
```

## 修复流程

1. **运行构建**：`npm run build`，收集所有错误
2. **分类错误**：按上述 4 种模式归类
3. **追溯类型定义**：找到 interface/ref 类型定义处
4. **最小修改原则**：优先扩展类型、添加可选属性，而非使用 `as any`
5. **联动检查**：修改类型后检查所有使用处（mock 数据、函数调用、模板绑定）
6. **验证构建**：修复后重新运行 `npm run build` 确认零错误

## 注意事项
- 添加可选属性时用 `count?: number` 而非 `count: number | undefined`，避免强制所有构造处填写
- 函数参数放宽为 `string | undefined` 时，确保函数内部有处理 undefined 的逻辑（如 fallback 值）
- Vue 模板中 `v-for="(item, index)"` 的 index 始终是 `number`，但带字符串 key 如 `v-for="(item, index) in obj"` 时 index 可能是 `string`
