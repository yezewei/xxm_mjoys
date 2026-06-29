---
name: vue-header-dropdown-modal
description: 在 Layout 顶部导航栏添加下拉菜单项，点击菜单项打开列表+详情两级弹窗，支持搜索和返回导航
source: auto-skill
extracted_at: '2026-06-27T01:09:39.183Z'
---

# 顶部导航下拉菜单 + 列表详情弹窗

## 适用场景

在 Layout 组件的顶部角色信息栏（header-actions 区域）添加一个下拉菜单入口，点击菜单项后打开弹窗，弹窗内部支持「列表视图」和「详情视图」两级切换，可选搜索过滤和返回导航。

## 步骤

### 1. 定位模板插入点

在 `src/components/Layout.vue` 的 header-actions 区域找到目标位置（如 `<a class="header-action">XXX</a>`），用 `a-dropdown` 替换或插入：

```vue
<a-dropdown>
  <a class="header-action">菜单名称</a>
  <template #overlay>
    <a-menu @click="handleMenuClick">
      <a-menu-item key="item1">选项1</a-menu-item>
      <a-menu-item key="item2">选项2</a-menu-item>
    </a-menu>
  </template>
</a-dropdown>
```

### 2. 添加弹窗模板

在 `</header>` 之后、`<div class="main-layout">` 之前添加弹窗：

```vue
<a-modal
  v-model:open="modalVisible"
  :title="currentItem ? currentItem.title : '列表标题'"
  @cancel="closeModal"
  :footer="null"
  width="600px"
>
  <!-- 详情视图 -->
  <div v-if="currentItem" class="detail-content">
    <div class="back-btn" @click="currentItem = null">
      <LeftOutlined />
      <span>返回列表</span>
    </div>
    <!-- 渲染详情字段 -->
  </div>
  <!-- 列表视图 -->
  <div v-else class="item-list">
    <a-input-search
      v-model:value="searchKey"
      placeholder="搜索"
      style="margin-bottom: 16px"
      allow-clear
    />
    <div
      v-for="(item, index) in filteredList"
      :key="index"
      class="list-item"
      @click="currentItem = item"
    >
      <QuestionCircleOutlined class="item-icon" />
      <span class="item-label">{{ item.title }}</span>
      <RightOutlined class="item-arrow" />
    </div>
    <a-empty v-if="filteredList.length === 0" description="未找到相关内容" />
  </div>
</a-modal>
```

**关键点**：
- 用 `v-if="currentItem"` / `v-else` 控制两级视图切换
- 详情视图顶部添加返回按钮
- 列表视图添加搜索框和空状态提示

### 3. script setup 中添加状态和方法

```ts
// 图标导入（补充到已有的 import 语句中）
import { QuestionCircleOutlined, RightOutlined, LeftOutlined } from '@ant-design/icons-vue'

// 数据（可从其他页面复用，保持结构一致）
const itemList = ref<ItemType[]>([/* ... */])

// 弹窗状态
const modalVisible = ref(false)
const currentItem = ref<ItemType | null>(null)
const searchKey = ref('')

// 搜索过滤
const filteredList = computed(() => {
  if (!searchKey.value) return itemList.value
  return itemList.value.filter(item => item.title.includes(searchKey.value))
})

// 菜单点击处理
const handleMenuClick = ({ key }: { key: string }) => {
  if (key === 'target-key') {
    currentItem.value = null  // 先重置为列表视图
    searchKey.value = ''      // 清空搜索
    modalVisible.value = true
  }
}

// 关闭弹窗
const closeModal = () => {
  modalVisible.value = false
  currentItem.value = null
  searchKey.value = ''
}
```

**注意**：打开弹窗时必须先将 `currentItem` 设为 `null` 并清空搜索，确保显示列表视图。

### 4. 添加 scoped 样式

```scss
.item-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.list-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    background: #f5f5f5;
    border-color: #d9d9d9;
  }
}

.item-icon {
  color: #1890ff;
  margin-right: 12px;
  font-size: 16px;
}

.item-label {
  flex: 1;
  font-size: 14px;
  color: #333;
}

.item-arrow {
  color: #999;
  font-size: 12px;
}

.detail-content {
  padding: 8px 0;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #1890ff;
  cursor: pointer;
  margin-bottom: 16px;
  font-size: 14px;

  &:hover {
    color: #40a9ff;
  }
}
```

## 数据复用技巧

如果弹窗数据已在其他页面组件中定义（如 PhoneWorkHome.vue 的 faqList），直接在 Layout.vue 中复制相同的数据结构和内容，避免跨组件耦合。保持接口（interface）定义一致即可。

## 注意事项

- `a-dropdown` 的 `@click` 事件回调参数为 `{ key: string }`，用解构取 key
- 弹窗 title 根据 `currentItem` 动态切换：列表时显示分类标题，详情时显示具体条目标题
- 关闭弹窗时重置 `currentItem = null` 和 `searchKey = ''`，下次打开默认回到列表视图
- 搜索功能使用 `a-input-search` 组件，支持 `allow-clear` 一键清空
- 无搜索结果时显示 `a-empty` 空状态提示
