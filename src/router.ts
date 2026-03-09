import { createRouter, createWebHistory } from "vue-router";

const routes = [
  {
    path: "/",
    name: "Home",
    component: () => import("./pages/Home.vue"),
  },
  {
    path: "/exception",
    name: "Exception",
    component: () => import("./pages/ExceptionBoard.vue"),
  },
  {
    path: "/role-management",
    name: "RoleManagement",
    component: () => import("./pages/RoleManagement.vue"),
  },
  {
    path: "/ai-call-report",
    name: "AICallReport",
    component: () => import("./pages/AICallReport.vue"),
  },
  {
    path: "/operation-log",
    name: "OperationLog",
    component: () => import("./pages/OperationLog.vue"),
  },
  {
    path: "/scene-template",
    name: "SceneTemplate",
    component: () => import("./pages/SceneTemplate.vue"),
  },
  {
    path: "/scene-management",
    name: "SceneManagement",
    component: () => import("./pages/SceneManagement.vue"),
  },
  {
    path: "/org-management",
    name: "OrgManagement",
    component: () => import("./pages/OrgManagement.vue"),
  },
  {
    path: "/workbench-settings",
    name: "WorkbenchSettings",
    component: () => import("./pages/WorkbenchSettings.vue"),
  },
  {
    path: "/phone-work-home",
    name: "PhoneWorkHome",
    component: () => import("./pages/PhoneWorkHome.vue"),
  },
  {
    path: "/phone-work-workbench",
    name: "PhoneWorkWorkbench",
    component: () => import("./pages/PhoneWorkWorkbench.vue"),
  },
  {
    path: "/quality-home",
    name: "QualityHome",
    component: () => import("./pages/QualityHome.vue"),
  },
  {
    path: "/quality-workbench",
    name: "QualityWorkbench",
    component: () => import("./pages/QualityWorkbench.vue"),
  },
  {
    path: "/quality-model",
    name: "QualityModel",
    component: () => import("./pages/QualityModel.vue"),
  },
  {
    path: "/quality-task",
    name: "QualityTask",
    component: () => import("./pages/QualityTask.vue"),
  },
  {
    path: "/seat-config",
    name: "SeatConfig",
    component: () => import("./pages/SeatConfig.vue"),
  },
  {
    path: "/seat-monitor",
    name: "SeatMonitor",
    component: () => import("./pages/SeatMonitor.vue"),
  },
  {
    path: "/skill-group",
    name: "SkillGroup",
    component: () => import("./pages/SkillGroup.vue"),
  },
  {
    path: "/knowledge-word",
    name: "KnowledgeWord",
    component: () => import("./pages/KnowledgeWord.vue"),
  },
  {
    path: "/knowledge-intent",
    name: "KnowledgeIntent",
    component: () => import("./pages/KnowledgeIntent.vue"),
  },
  {
    path: "/knowledge-qa",
    name: "KnowledgeQa",
    component: () => import("./pages/KnowledgeQa.vue"),
  },
  {
    path: "/knowledge-scene",
    name: "KnowledgeScene",
    component: () => import("./pages/KnowledgeScene.vue"),
  },
  {
    path: "/data-lake",
    name: "DataLake",
    component: () => import("./pages/DataLake.vue"),
  },
  {
    path: "/data-board",
    name: "DataBoard",
    component: () => import("./pages/DataBoard.vue"),
  },
  {
    path: "/global-service",
    name: "GlobalService",
    component: () => import("./pages/GlobalService.vue"),
  },
  {
    path: "/system-security",
    name: "SystemSecurity",
    component: () => import("./pages/SystemSecurity.vue"),
  },
  {
    path: "/device-management",
    name: "DeviceManagement",
    component: () => import("./pages/DeviceManagement.vue"),
  },
  {
    path: "/system-monitor",
    name: "SystemMonitor",
    component: () => import("./pages/SystemMonitor.vue"),
  },
  {
    path: "/route-settings",
    name: "RouteSettings",
    component: () => import("./pages/RouteSettings.vue"),
  },
  {
    path: "/app-management",
    name: "AppManagement",
    component: () => import("./pages/AppManagement.vue"),
  },
  {
    path: "/task-management",
    name: "TaskManagement",
    component: () => import("./pages/TaskManagement.vue"),
  },
  {
    path: "/write-off",
    name: "WriteOff",
    component: () => import("./pages/WriteOff.vue"),
  },
  {
    path: "/schedule-log",
    name: "ScheduleLog",
    component: () => import("./pages/ScheduleLog.vue"),
  },
  {
    path: "/external-integration",
    name: "ExternalIntegration",
    component: () => import("./pages/ExternalIntegration.vue"),
  },
  {
    path: "/data-market",
    name: "DataMarket",
    component: () => import("./pages/DataMarket.vue"),
  },
  {
    path: "/bank-account",
    name: "BankAccount",
    component: () => import("./pages/BankAccount.vue"),
  },
  {
    path: "/platform-account",
    name: "PlatformAccount",
    component: () => import("./pages/PlatformAccount.vue"),
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
