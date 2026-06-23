---
name: vue-tabs-scroll-arrows
description: 在 Ant Design Vue a-tabs 顶部添加左右箭头滚动按钮，支持溢出检测、平滑滚动、滚动条隐藏
source: auto-skill
extracted_at: '2026-06-23T09:20:00.000Z'
---

# Vue Tabs 左右箭头滚动

当 Tab 数量较多（如 10+）超出容器宽度时，在 tab 导航栏两端显示左右箭头按钮，点击平滑滚动。

## 适用场景

- Ant Design Vue `a-tabs` 组件，`tab-position="top"`
- Tab 数量多、屏幕宽度不足以显示全部 tab 时

## 实现步骤

### 1. Template：包裹 tabs 并添加箭头

```html
<div class="tabs-scroll-wrapper" ref="tabsWrapperRef">
  <div v-show="showLeftArrow" class="tabs-arrow tabs-arrow-left" @click="scrollTabs('left')">
    <left-outlined />
  </div>
  <div v-show="showRightArrow" class="tabs-arrow tabs-arrow-right" @click="scrollTabs('right')">
    <right-outlined />
  </div>
  <a-tabs v-model:activeKey="activeTab" tab-position="top" size="middle">
    <!-- tab-panes ... -->
  </a-tabs>
</div>
```

### 2. Script：滚动逻辑

```ts
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { LeftOutlined, RightOutlined } from '@ant-design/icons-vue'

const tabsWrapperRef = ref<HTMLElement>()
const showLeftArrow = ref(false)
const showRightArrow = ref(false)

const getTabsNav = (): HTMLElement | null => {
  return tabsWrapperRef.value?.querySelector('.ant-tabs-nav-wrap') as HTMLElement || null
}

const updateArrowVisibility = () => {
  const nav = getTabsNav()
  if (!nav) return
  const { scrollLeft, scrollWidth, clientWidth } = nav
  showLeftArrow.value = scrollLeft > 2
  showRightArrow.value = scrollLeft < scrollWidth - clientWidth - 2
}

const scrollTabs = (direction: 'left' | 'right') => {
  const nav = getTabsNav()
  if (!nav) return
  const offset = direction === 'left' ? -200 : 200
  nav.scrollBy({ left: offset, behavior: 'smooth' })
  setTimeout(updateArrowVisibility, 350)
}

onMounted(async () => {
  await nextTick()
  const nav = getTabsNav()
  if (nav) {
    nav.addEventListener('scroll', updateArrowVisibility, { passive: true })
    updateArrowVisibility()
  }
  window.addEventListener('resize', updateArrowVisibility)
})

onBeforeUnmount(() => {
  const nav = getTabsNav()
  if (nav) nav.removeEventListener('scroll', updateArrowVisibility)
  window.removeEventListener('resize', updateArrowVisibility)
})
```

### 3. CSS：箭头样式 + 隐藏原生滚动条

```css
.tabs-scroll-wrapper {
  position: relative;
}

.tabs-arrow {
  position: absolute;
  top: 4px;
  z-index: 10;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  color: #595959;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: color 0.2s, border-color 0.2s;
}

.tabs-arrow:hover {
  color: #1677ff;
  border-color: #1677ff;
}

.tabs-arrow-left  { left: 0; }
.tabs-arrow-right { right: 0; }

/* 隐藏原生滚动条，保留滚动能力 */
:deep(.ant-tabs-nav-wrap) {
  overflow-x: auto;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
:deep(.ant-tabs-nav-wrap::-webkit-scrollbar) {
  display: none;
}

/* nav 两侧留出箭头空间 */
:deep(.ant-tabs-nav) {
  padding: 0 36px;
}
```

## 关键点

- **目标元素是 `.ant-tabs-nav-wrap`**，不是 `.ant-tabs-nav`——前者是可滚动容器
- 用 `scrollBy` + `behavior: 'smooth'` 实现平滑滚动
- `setTimeout(updateArrowVisibility, 350)` 等滚动动画结束后更新箭头显隐
- `scrollLeft > 2` 的 2px 容差避免浮点精度导致的闪烁
- `onMounted` 中用 `nextTick` 确保 DOM 已渲染再获取 nav 元素
- `resize` 事件也需监听，窗口大小变化时重新计算箭头显隐
