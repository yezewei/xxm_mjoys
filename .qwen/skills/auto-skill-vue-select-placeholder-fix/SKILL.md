---
name: vue-select-placeholder-fix
description: 修复 Ant Design Vue a-select 组件 placeholder 不显示的问题（值为空字符串而非 undefined）
source: auto-skill
extracted_at: '2026-06-29T06:36:01.725Z'
---

# 修复 a-select placeholder 不显示

## 问题
Ant Design Vue 的 `a-select` 组件在 `v-model:value` 为空字符串 `''` 时，不会显示 `placeholder` 文本，因为 `''` 被视为有效值。只有值为 `undefined` 时 placeholder 才会正常显示。

## 修复步骤（三处必改）

### 1. TypeScript 接口类型
将字段类型从 `string` 改为 `string | undefined`：
```ts
interface MyForm {
  // ❌ 错误
  qualityModel: string

  // ✅ 正确
  qualityModel: string | undefined
}
```

### 2. reactive 初始化值
将初始值从 `''` 改为 `undefined`：
```ts
const form = reactive<MyForm>({
  // ❌ 错误
  qualityModel: '',

  // ✅ 正确
  qualityModel: undefined,
})
```

### 3. 表单重置函数
在取消/重置处理中同样使用 `undefined`：
```ts
const handleCancel = () => {
  Object.assign(form, {
    // ❌ 错误
    qualityModel: '',

    // ✅ 正确
    qualityModel: undefined,
  })
}
```

## 注意事项
- 此问题适用于所有 `a-select`（含 `mode="multiple"` 的多选场景）
- 如果使用了 `resetFields()`，Ant Design Vue 会根据 `initialValue` 重置，需确保 `initialValue` 也是 `undefined` 而非 `''`
- `a-input`、`a-textarea` 等文本输入组件不受影响，它们用 `''` 初始化是正确的
