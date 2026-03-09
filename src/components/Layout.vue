<template>
  <div class="layout">
    <!-- 顶部菜单 -->
    <header class="header">
      <div class="header-left">
        <img src="/system_demo/logo.png" alt="AI 直营平台" class="logo-img" />
        <div class="page-title">{{ pageTitle }}</div>
      </div>
      <div class="header-right">
        <a class="header-action">上传任务</a>
        <a class="header-action">下载任务</a>
        <a-badge class="header-action" count="99+" size="small">
          <a class="message-link">消息中心</a>
        </a-badge>
        <a-button class="admin-btn" size="small">
          <user-outlined />
          超级管理员
        </a-button>
        <div class="user-info">
          <a-avatar class="user-avatar" :size="60">
            <img src="/system_demo/头像.png" alt="avatar" />
          </a-avatar>
          <span class="user-name">yezewei</span>
        </div>
      </div>
    </header>

    <div class="main-layout">
      <!-- 左侧菜单 -->
      <aside class="sider">
        <a-menu
          v-model:selectedKeys="selectedKeys"
          v-model:openKeys="openKeys"
          theme="light"
          mode="inline"
          class="side-menu"
          @click="handleMenuClick"
        >
          <a-menu-item key="home">
            <span>首页</span>
          </a-menu-item>

          <a-sub-menu key="business">
            <template #title>
              <span>业务管理</span>
            </template>
            <a-menu-item key="scene-management">
              <span>场景管理</span>
            </a-menu-item>
            <a-menu-item key="scene-template">
              <span>场景模板</span>
            </a-menu-item>
            <a-menu-item key="org-management">
              <span>机构管理</span>
            </a-menu-item>
            <a-menu-item key="workbench-settings">
              <span>工作台设置</span>
            </a-menu-item>
          </a-sub-menu>

          <a-sub-menu key="phone-work">
            <template #title>
              <span>电话工作台</span>
            </template>
            <a-menu-item key="phone-work-home">
              <span>首页</span>
            </a-menu-item>
            <a-menu-item key="phone-work-workbench">
              <span>工作台</span>
            </a-menu-item>
          </a-sub-menu>

          <a-sub-menu key="quality-inspection">
            <template #title>
              <span>质检工作台</span>
            </template>
            <a-menu-item key="quality-home">
              <span>首页</span>
            </a-menu-item>
            <a-menu-item key="quality-workbench">
              <span>工作台</span>
            </a-menu-item>
            <a-menu-item key="quality-model">
              <span>质检模型</span>
            </a-menu-item>
            <a-menu-item key="quality-task">
              <span>质检任务</span>
            </a-menu-item>
          </a-sub-menu>

          <a-sub-menu key="seat">
            <template #title>
              <span>坐席管理</span>
            </template>
            <a-menu-item key="seat-config">
              <span>直营坐席配置</span>
            </a-menu-item>
            <a-menu-item key="seat-monitor">
              <span>坐席监控</span>
            </a-menu-item>
            <a-menu-item key="skill-group">
              <span>技能组管理</span>
            </a-menu-item>
          </a-sub-menu>

          <a-sub-menu key="knowledge">
            <template #title>
              <span>内置知识管理</span>
            </template>
            <a-menu-item key="knowledge-word">
              <span>内置词库</span>
            </a-menu-item>
            <a-menu-item key="knowledge-intent">
              <span>内置意图</span>
            </a-menu-item>
            <a-menu-item key="knowledge-qa">
              <span>内置 QA</span>
            </a-menu-item>
            <a-menu-item key="knowledge-scene">
              <span>场景知识库</span>
            </a-menu-item>
          </a-sub-menu>

          <a-menu-item key="data-lake">
            <span>数据湖</span>
          </a-menu-item>

          <a-menu-item key="data-board">
            <span>数据看板</span>
          </a-menu-item>

          <a-menu-item key="exception">
            <span>异常看板</span>
          </a-menu-item>

          <a-sub-menu key="engineering">
            <template #title>
              <span>工程管理</span>
            </template>
            <a-menu-item key="global-service">
              <span>全局服务配置</span>
            </a-menu-item>
            <a-menu-item key="system-security">
              <span>系统安全配置</span>
            </a-menu-item>
            <a-menu-item key="device-management">
              <span>设备管理</span>
            </a-menu-item>
            <a-menu-item key="system-monitor">
              <span>系统监控</span>
            </a-menu-item>
            <a-menu-item key="route-settings">
              <span>路由设置</span>
            </a-menu-item>
          </a-sub-menu>

          <a-sub-menu key="data-engine">
            <template #title>
              <span>数据引擎</span>
            </template>
            <a-menu-item key="app-management">
              <span>应用管理</span>
            </a-menu-item>
            <a-menu-item key="task-management">
              <span>任务管理</span>
            </a-menu-item>
            <a-menu-item key="write-off">
              <span>核销管理</span>
            </a-menu-item>
            <a-menu-item key="schedule-log">
              <span>调度日志</span>
            </a-menu-item>
            <a-menu-item key="external-integration">
              <span>外部集成管理</span>
            </a-menu-item>
            <a-menu-item key="data-market">
              <span>数据市场</span>
            </a-menu-item>
          </a-sub-menu>

          <a-sub-menu key="platform">
            <template #title>
              <span>平台管理</span>
            </template>
            <a-menu-item key="role-management">
              <span>角色管理</span>
            </a-menu-item>
            <a-menu-item key="bank-account">
              <span>银行账号管理</span>
            </a-menu-item>
            <a-menu-item key="platform-account">
              <span>平台账号管理</span>
            </a-menu-item>
            <a-menu-item key="operation-log">
              <span>操作记录</span>
            </a-menu-item>
            <a-menu-item key="menu-management">
              <span>菜单管理</span>
            </a-menu-item>
          </a-sub-menu>
        </a-menu>
      </aside>

      <!-- 主内容区 -->
      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();
const selectedKeys = ref(['exception']);
const openKeys = ref([]);

// 菜单项与路由的映射
const menuRouteMap: Record<string, string> = {
  home: '/',
  exception: '/exception',
  'role-management': '/role-management',
  'ai-call-report': '/ai-call-report',
  'data-board': '/data-board',
  'operation-log': '/operation-log',
  'scene-template': '/scene-template',
  'scene-management': '/scene-management',
  'org-management': '/org-management',
  'workbench-settings': '/workbench-settings',
  'phone-work-home': '/phone-work-home',
  'phone-work-workbench': '/phone-work-workbench',
  'quality-home': '/quality-home',
  'quality-workbench': '/quality-workbench',
  'quality-model': '/quality-model',
  'quality-task': '/quality-task',
  'seat-config': '/seat-config',
  'seat-monitor': '/seat-monitor',
  'skill-group': '/skill-group',
  'knowledge-word': '/knowledge-word',
  'knowledge-intent': '/knowledge-intent',
  'knowledge-qa': '/knowledge-qa',
  'knowledge-scene': '/knowledge-scene',
  'data-lake': '/data-lake',
  'global-service': '/global-service',
  'system-security': '/system-security',
  'device-management': '/device-management',
  'system-monitor': '/system-monitor',
  'route-settings': '/route-settings',
  'app-management': '/app-management',
  'task-management': '/task-management',
  'write-off': '/write-off',
  'schedule-log': '/schedule-log',
  'external-integration': '/external-integration',
  'data-market': '/data-market',
  'bank-account': '/bank-account',
  'platform-account': '/platform-account',
};

// 菜单项与页面标题的映射
const menuTitleMap: Record<string, string> = {
  home: '首页',
  business: '业务管理',
  'scene-management': '场景管理',
  'scene-template': '场景模板',
  'org-management': '机构管理',
  'workbench-settings': '工作台设置',
  'phone-work': '电话工作台',
  'phone-work-home': '首页',
  'phone-work-workbench': '工作台',
  'quality-inspection': '质检工作台',
  'quality-home': '首页',
  'quality-workbench': '工作台',
  'quality-model': '质检模型',
  'quality-task': '质检任务',
  seat: '坐席管理',
  'seat-config': '直营坐席配置',
  'seat-monitor': '坐席监控',
  'skill-group': '技能组管理',
  knowledge: '内置知识管理',
  'knowledge-word': '内置词库',
  'knowledge-intent': '内置意图',
  'knowledge-qa': '内置 QA',
  'knowledge-scene': '场景知识库',
  'data-lake': '数据湖',
  'data-board': '数据看板',
  exception: '异常看板',
  engineering: '工程管理',
  'global-service': '全局服务配置',
  'system-security': '系统安全配置',
  'device-management': '设备管理',
  'system-monitor': '系统监控',
  'route-settings': '路由设置',
  'data-engine': '数据引擎',
  'app-management': '应用管理',
  'task-management': '任务管理',
  'write-off': '核销管理',
  'schedule-log': '调度日志',
  'external-integration': '外部集成管理',
  'data-market': '数据市场',
  platform: '平台管理',
  'role-management': '角色管理',
  'bank-account': '银行账号管理',
  'platform-account': '平台账号管理',
  'operation-log': '操作记录',
  'menu-management': '菜单管理',
};

const pageTitle = computed(() => {
  return menuTitleMap[selectedKeys.value[0]] || '首页';
});

// 菜单点击事件
const handleMenuClick = ({ key }: { key: string }) => {
  const routePath = menuRouteMap[key];
  if (routePath) {
    router.push(routePath);
  }
};

// 监听路由变化，更新选中的菜单项
watch(
  () => route.path,
  (path) => {
    const pathToKeyMap: Record<string, string> = {
      '/': 'home',
      '/exception': 'exception',
      '/role-management': 'role-management',
      '/ai-call-report': 'ai-call-report',
      '/operation-log': 'operation-log',
      '/scene-template': 'scene-template',
      '/scene-management': 'scene-management',
      '/org-management': 'org-management',
      '/workbench-settings': 'workbench-settings',
      '/phone-work-home': 'phone-work-home',
      '/phone-work-workbench': 'phone-work-workbench',
      '/quality-home': 'quality-home',
      '/quality-workbench': 'quality-workbench',
      '/quality-model': 'quality-model',
      '/quality-task': 'quality-task',
      '/seat-config': 'seat-config',
      '/seat-monitor': 'seat-monitor',
      '/skill-group': 'skill-group',
      '/knowledge-word': 'knowledge-word',
      '/knowledge-intent': 'knowledge-intent',
      '/knowledge-qa': 'knowledge-qa',
      '/knowledge-scene': 'knowledge-scene',
      '/data-lake': 'data-lake',
      '/data-board': 'data-board',
      '/global-service': 'global-service',
      '/system-security': 'system-security',
      '/device-management': 'device-management',
      '/system-monitor': 'system-monitor',
      '/route-settings': 'route-settings',
      '/app-management': 'app-management',
      '/task-management': 'task-management',
      '/write-off': 'write-off',
      '/schedule-log': 'schedule-log',
      '/external-integration': 'external-integration',
      '/data-market': 'data-market',
      '/bank-account': 'bank-account',
      '/platform-account': 'platform-account',
    };
    const key = pathToKeyMap[path] || 'home';
    selectedKeys.value = [key];
  },
  { immediate: true }
);
</script>

<style scoped>
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  height: 64px;
  z-index: 10;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
  padding-left: 10px;
}

.logo-img {
  height: 32px;
}

.page-title {
  font-size: 14px;
  color: rgba(0, 0, 0, 0.45);
  margin-left: 40px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
  padding-right: 10px;
}

.header-action {
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
  font-size: 14px;
  margin-right: 0px;
}

.header-action:hover {
  color: #40a9ff;
}

.message-link {
  color: #1890ff;
}

.admin-btn {
  background: #fff;
  border: 1px solid #d9d9d9;
  border-radius: 16px;
  padding: 10px 16px;
  color: rgba(0, 0, 0, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  height: 32px;
  box-sizing: border-box;
  margin-right: 10px;
}

.admin-btn:hover {
  color: #1890ff;
  border-color: #1890ff;
}

.user-info {
  display: flex;
  align-items: center;
  gap: -2px;
  cursor: pointer;
  margin-left: -30px;
}

.user-avatar {
  background: transparent;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.user-avatar :deep(img) {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;


}

.user-name {
  font-size: 14px;
  color: #333;
}

.main-layout {
  display: flex;
  flex: 1;
  margin-top: 64px;
  min-height: 0;
  overflow: hidden;
}

.sider {
  background: #fff;
  border-right: 1px solid #e8e8e8;
  flex-shrink: 0;
  width: 220px;
  height: calc(100vh - 64px);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.side-menu {
  border-right: none;
  height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  background: #fff;
  flex: 1;
}

.content {
  flex: 1;
  margin: 0;
  padding: 24px;
  background: #fff;
  height: calc(100vh - 64px);
  overflow-y: auto;
  overflow-x: hidden;
}
</style>
