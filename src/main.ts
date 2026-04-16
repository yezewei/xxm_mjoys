import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// 引入 Ant Design Vue
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'

// 引入 Element Plus
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

const app = createApp(App)

app.use(Antd)
app.use(ElementPlus, { locale: zhCn })
app.use(router)

// 注册 Element Plus 图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 提供 Menu 上下文以解决 Vue 3.5+ 兼容性问题
app.provide('MenuContext', {
  prefixCls: 'ant-menu',
  firstLevel: true
})

app.mount('#app')