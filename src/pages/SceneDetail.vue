<template>
  <div class="scene-detail">
    <!-- 顶部标签页 -->
    <div class="tabs-section">
      <a-tabs v-model:activeKey="activeTabKey" @change="handleTabChange">
        <a-tab-pane key="basic" data-tab-key="basic" tab="基本信息" />
        <a-tab-pane key="process" data-tab-key="process" tab="主流程设置" />
        <a-tab-pane key="qa" data-tab-key="qa" tab="QA 库" />
        <a-tab-pane key="intent" data-tab-key="intent" tab="意图库" />
        <a-tab-pane key="fallback" data-tab-key="fallback" tab="流程兜底设置" />
        <a-tab-pane key="script" data-tab-key="script" tab="话术管理" />
        <a-tab-pane key="scene-voice" data-tab-key="scene-voice" tab="场景语音" />
        <a-tab-pane key="user-classify" data-tab-key="user-classify" tab="用户分类" />
        <a-tab-pane key="system-settings" data-tab-key="system-settings" tab="场景系统设置" />
        <a-tab-pane key="sms" data-tab-key="sms" tab="场景短信" />
      </a-tabs>
    </div>

    <!-- 各 Tab 内容区域 -->
    <div class="tab-content">
      <!-- 基本信息 -->
      <BasicInfoTab v-if="activeTabKey === 'basic'" v-model="basicFormData" />

      <!-- 主流程设置 -->
      <ProcessSettingTab
        v-if="activeTabKey === 'process'"
        v-model:nodes="processNodes"
        v-model:connections="connections"
        @save="handleProcessSave"
      />

      <!-- QA 库 -->
      <QaLibraryTab
        v-if="activeTabKey === 'qa'"
        v-model="qaData"
        @create="handleCreateQa"
        @reference="handleReferenceQa"
        @delete="handleDeleteQa"
      />

      <!-- 意图库 -->
      <IntentLibraryTab
        v-if="activeTabKey === 'intent'"
        v-model="intentData"
        @create="handleCreateIntent"
        @reference="handleReferenceIntent"
        @delete="handleDeleteIntent"
      />

      <!-- 流程兜底设置 -->
      <FallbackSettingTab
        v-if="activeTabKey === 'fallback'"
        v-model="fallbackData"
        @save="handleSaveFallback"
        @reset="handleResetFallback"
      />

      <!-- 话术管理 -->
      <ScriptManagementTab
        v-if="activeTabKey === 'script'"
        v-model="scriptData"
        @edit="handleEditScript"
        @compliance="handleComplianceCheck"
      />

      <!-- 场景语音 -->
      <SceneVoiceTab
        v-if="activeTabKey === 'scene-voice'"
        v-model="sceneVoiceData"
        @save="handleSaveSceneVoice"
        @reset="handleResetSceneVoice"
      />

      <!-- 用户分类 -->
      <UserClassifyTab
        v-if="activeTabKey === 'user-classify'"
        v-model="userClassifyData"
        @save="handleSaveClassify"
      />

      <!-- 场景系统设置 -->
      <SystemSettingsTab
        v-if="activeTabKey === 'system-settings'"
        v-model="systemSettingsData"
        @save="handleSaveSystemSettings"
      />

      <!-- 场景短信 -->
      <SmsManagementTab
        v-if="activeTabKey === 'sms'"
        v-model="smsData"
        @create="handleCreateSms"
        @edit="handleEditSms"
        @delete="handleDeleteSms"
      />
    </div>

    <!-- 遮罩层 -->
    <div v-if="guideVisible" class="guide-mask">
      <div
        class="guide-highlight"
        :style="{
          top: highlightRect.top + 'px',
          left: highlightRect.left + 'px',
          width: highlightRect.width + 'px',
          height: highlightRect.height + 'px',
        }"
      />
    </div>

    <!-- 气泡引导 -->
    <div
      v-if="guideVisible && guideSteps[guideCurrentStep]"
      class="guide-overlay"
      :class="{ 'guide-with-transition': enableGuideTransition }"
      :style="{ top: guidePosition.top + 'px', left: guidePosition.left + 'px' }"
    >
      <div class="guide-popover">
        <div class="guide-header">
          <span class="guide-step-indicator">步骤 {{ guideSteps[guideCurrentStep].step }} / {{ guideSteps.length }}</span>
          <a-button type="text" size="small" class="guide-close-btn" @click="handleGuideClose">
            <close-outlined />
          </a-button>
        </div>
        <div class="guide-body">
          <h4 class="guide-title">{{ guideSteps[guideCurrentStep].title }}</h4>
          <p class="guide-description">{{ guideSteps[guideCurrentStep].description }}</p>
        </div>
        <div class="guide-footer" :class="{ 'guide-footer-first': guideCurrentStep === 0 }">
          <a-button
            v-if="guideCurrentStep > 0"
            size="small"
            @click="handleGuidePrev"
          >
            上一步
          </a-button>
          <a-button
            type="primary"
            size="small"
            @click="handleGuideNext"
            :style="{ marginLeft: guideCurrentStep === 0 ? 'auto' : '0' }"
          >
            {{ guideCurrentStep === guideSteps.length - 1 ? '完成引导' : '下一步' }}
          </a-button>
        </div>
        <!-- 引导步骤指示器 -->
        <div class="guide-steps-indicator">
          <div
            v-for="(step, index) in guideSteps"
            :key="step.step"
            :class="['step-dot', { active: guideCurrentStep === index }]"
            @click="handleGuideJump(index)"
          />
        </div>
      </div>
    </div>

    <!-- 重新引导按钮（右下角） -->
    <a-button
      class="restart-guide-btn"
      type="primary"
      shape="circle"
      size="large"
      @click="showGuide"
    >
      <question-outlined />
    </a-button>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { message } from 'ant-design-vue';
import {
  CloseOutlined,
  QuestionOutlined,
} from '@ant-design/icons-vue';

// 导入可复用的 Tab 组件
import {
  BasicInfoTab,
  ProcessSettingTab,
  QaLibraryTab,
  IntentLibraryTab,
  FallbackSettingTab,
  ScriptManagementTab,
  SceneVoiceTab,
  UserClassifyTab,
  SystemSettingsTab,
  SmsManagementTab,
} from '@/components/SceneTemplateTabs';

const router = useRouter();
const route = useRoute();

// ==================== 各 Tab 数据 ====================

// 当前激活的 Tab
const activeTabKey = ref('basic');

// 基本信息数据
const basicFormData = ref({
  templateName: '信用卡激活场景',
  templateType: ['信用卡', '信用卡激活'],
  tags: ['信用卡', '激活流程', '高频场景'],
  followType: 'sms+manual',
  description: '适用于信用卡新卡激活场景，包含完整的激活流程指引和常见问题解答',
  targetCustomer: '持有未激活信用卡的新客户，包括个人客户和企业客户',
  applicableActivity: '2026 年信用卡开卡礼活动、首刷礼活动、新户专享理财活动',
  financialProduct: '信用卡产品：标准金卡、白金卡、钻石卡；关联产品：消费分期、账单分期、现金分期',
});

// 主流程数据
const processNodes = ref<any[]>([]);
const connections = ref<any[]>([]);
const intentList = ref<any[]>([]);

// QA 库数据
const qaData = ref<any>({});

// 意图库数据
const intentData = ref<any>({});

// 流程兜底数据
const fallbackData = ref<any>({});

// 话术管理数据
const scriptData = ref<any>({});

// 场景语音数据
const sceneVoiceData = ref<any>({});

// 用户分类数据
const userClassifyData = ref<any>({});

// 场景系统设置数据
const systemSettingsData = ref<any>({});

// 场景短信数据
const smsData = ref<any>({});

// ==================== 引导相关数据 ====================

// 引导步骤接口
interface GuideStep {
  step: number;
  title: string;
  description: string;
  target: string;
  placement: 'top' | 'bottom' | 'left' | 'right';
}

// 引导步骤配置
const guideSteps: GuideStep[] = [
  {
    step: 1,
    title: '配置话术主流程',
    description: '点击"主流程设置"标签，配置机器人拨打的话术流程，包括开场白、产品介绍、成功/失败结束等节点。',
    target: '[data-tab-key="process"]',
    placement: 'bottom',
  },
  {
    step: 2,
    title: '引用通用/行业 QA',
    description: '点击"QA 库"标签，引用通用或行业 QA，并编辑回复内容，丰富机器人的应答能力。',
    target: '[data-tab-key="qa"]',
    placement: 'bottom',
  },
  {
    step: 3,
    title: '维护意图库',
    description: '点击"意图库"标签，添加或编辑意图，定义用户可能的意图和对应的处理方式。',
    target: '[data-tab-key="intent"]',
    placement: 'bottom',
  },
  {
    step: 4,
    title: '检查兜底设置',
    description: '点击"流程兜底设置"标签，检查静音超时、语义为空、强制挂断等配置项是否完整。',
    target: '[data-tab-key="fallback"]',
    placement: 'bottom',
  },
  {
    step: 5,
    title: '消保审核和上传录音',
    description: '点击"话术管理"标签，对所有话术文本进行消保审核，并上传录音文件。',
    target: '[data-tab-key="script"]',
    placement: 'bottom',
  },
  {
    step: 6,
    title: '配置场景语音',
    description: '点击"场景语音"标签，配置语音识别资源、语音合成资源、语音生成方式等语音相关设置。',
    target: '[data-tab-key="scene-voice"]',
    placement: 'bottom',
  },
  {
    step: 7,
    title: '定义用户分类',
    description: '点击"用户分类"标签，根据业务场景定义用户分类规则，如意向客户、无意向客户等。',
    target: '[data-tab-key="user-classify"]',
    placement: 'bottom',
  },
  {
    step: 8,
    title: '配置场景系统设置',
    description: '点击"场景系统设置"标签，配置客户跟进规则和人机协同规则，包括意向客户推送、转人工条件等。',
    target: '[data-tab-key="system-settings"]',
    placement: 'bottom',
  },
  {
    step: 9,
    title: '配置短信内容模板',
    description: '点击"场景短信"标签，配置当前场景使用到的短信内容模板，包括挂机短信等。',
    target: '[data-tab-key="sms"]',
    placement: 'bottom',
  },
];

// 引导状态
const guideVisible = ref(false);
const guideCurrentStep = ref(0);
const guideStarted = ref(false);

// 引导框位置
const guidePosition = reactive({
  top: 0,
  left: 0,
});

// 是否启用过渡动画（首次显示时不启用，后续步骤切换时启用）
const enableGuideTransition = ref(false);

// 遮罩层位置和高亮区域
const highlightElement = ref<HTMLElement | null>(null);
const highlightRect = reactive({
  top: 0,
  left: 0,
  width: 0,
  height: 0,
});

// ==================== 方法定义 ====================

/**
 * Tab 切换
 */
const handleTabChange = (key: string) => {
  console.log('切换 Tab:', key);
};

/**
 * 主流程保存
 */
const handleProcessSave = (data: { nodes: any[]; connections: any[] }) => {
  console.log('主流程保存:', data);
  // TODO: 实现保存逻辑
};

/**
 * 创建 QA
 */
const handleCreateQa = () => {
  console.log('创建 QA');
  // TODO: 实现创建逻辑
};

/**
 * 引用 QA
 */
const handleReferenceQa = () => {
  console.log('引用 QA');
  // TODO: 实现引用逻辑
};

/**
 * 删除 QA
 */
const handleDeleteQa = (qa: any) => {
  console.log('删除 QA:', qa);
  // TODO: 实现删除逻辑
};

/**
 * 创建意图
 */
const handleCreateIntent = () => {
  console.log('创建意图');
  // TODO: 实现创建逻辑
};

/**
 * 引用意图
 */
const handleReferenceIntent = () => {
  console.log('引用意图');
  // TODO: 实现引用逻辑
};

/**
 * 删除意图
 */
const handleDeleteIntent = (intent: any) => {
  console.log('删除意图:', intent);
  // TODO: 实现删除逻辑
};

/**
 * 保存兜底设置
 */
const handleSaveFallback = (data: any) => {
  console.log('保存兜底设置:', data);
  // TODO: 实现保存逻辑
};

/**
 * 重置兜底设置
 */
const handleResetFallback = () => {
  console.log('重置兜底设置');
  // TODO: 实现重置逻辑
};

/**
 * 编辑话术
 */
const handleEditScript = (script: any) => {
  console.log('编辑话术:', script);
  // TODO: 实现编辑逻辑
};

/**
 * 消保检查
 */
const handleComplianceCheck = (script: any) => {
  console.log('消保检查:', script);
  // TODO: 实现消保逻辑
};

/**
 * 保存场景语音设置
 */
const handleSaveSceneVoice = (data: any) => {
  console.log('保存场景语音设置:', data);
  // TODO: 实现保存逻辑
};

/**
 * 重置场景语音设置
 */
const handleResetSceneVoice = () => {
  console.log('重置场景语音设置');
  // TODO: 实现重置逻辑
};

/**
 * 保存用户分类
 */
const handleSaveClassify = (data: any) => {
  console.log('保存用户分类:', data);
  // TODO: 实现保存逻辑
};

/**
 * 保存系统设置
 */
const handleSaveSystemSettings = (data: any) => {
  console.log('保存系统设置:', data);
  // TODO: 实现保存逻辑
};

/**
 * 创建短信
 */
const handleCreateSms = () => {
  console.log('创建短信');
  // TODO: 实现创建逻辑
};

/**
 * 编辑短信
 */
const handleEditSms = (sms: any) => {
  console.log('编辑短信:', sms);
  // TODO: 实现编辑逻辑
};

/**
 * 删除短信
 */
const handleDeleteSms = (sms: any) => {
  console.log('删除短信:', sms);
  // TODO: 实现删除逻辑
};

// ==================== 引导相关方法 ====================

// 计算引导框位置
const calculateGuidePosition = () => {
  nextTick(() => {
    setTimeout(() => {
      const tabKey = guideSteps[guideCurrentStep.value].target.replace('[data-tab-key="', '').replace('"]', '');
      console.log('计算引导位置，tabKey:', tabKey);

      // step1 时，强制使用"主流程设置"tab 的位置
      const targetTabKey = guideCurrentStep.value === 0 ? 'process' : tabKey;

      // 查找 tab 元素
      let targetElement = document.querySelector(`.ant-tabs-tab[data-node-key="${targetTabKey}"]`) as HTMLElement;

      // 如果找不到，尝试通过 aria-controls 查找
      if (!targetElement) {
        const tabs = document.querySelectorAll('[role="tab"]');
        for (let i = 0; i < tabs.length; i++) {
          const tab = tabs[i] as HTMLElement;
          if (tab.getAttribute('aria-controls')?.includes(targetTabKey)) {
            targetElement = tab;
            break;
          }
        }
      }

      // 如果还是找不到，尝试通过文本内容匹配
      if (!targetElement) {
        const tabTextMap: Record<string, string> = {
          'process': '主流程设置',
          'qa': 'QA 库',
          'intent': '意图库',
          'fallback': '流程兜底设置',
          'script': '话术管理',
          'scene-voice': '场景语音',
          'user-classify': '用户分类',
          'system-settings': '场景系统设置',
          'sms': '场景短信',
        };
        const tabText = tabTextMap[targetTabKey];
        if (tabText) {
          const tabs = document.querySelectorAll('.ant-tabs-tab');
          for (let i = 0; i < tabs.length; i++) {
            const tab = tabs[i];
            if (tab.textContent?.includes(tabText)) {
              targetElement = tab;
              break;
            }
          }
        }
      }

      console.log('目标元素:', targetElement);

      if (targetElement) {
        const rect = targetElement.getBoundingClientRect();
        console.log('目标元素位置:', rect);

        // 使用 fixed 定位，直接使用视口坐标
        guidePosition.left = rect.left;
        guidePosition.top = rect.bottom + 14; // 8px + 6px 间距

        // 设置高亮区域
        highlightElement.value = targetElement;
        highlightRect.top = rect.top;
        highlightRect.left = rect.left;
        highlightRect.width = rect.width;
        highlightRect.height = rect.height;

        console.log('引导框位置:', guidePosition);
      } else {
        console.log('未找到目标元素:', targetTabKey);
        // 如果找不到元素，使用默认位置
        guidePosition.top = 70;
        guidePosition.left = 24;
      }
    }, 50);
  });
};

// 显示引导
const showGuide = () => {
  console.log('显示引导');
  guideCurrentStep.value = 0;
  guideStarted.value = true;
  // 先隐藏引导框，不启用过渡动画
  guideVisible.value = false;
  enableGuideTransition.value = false;

  // 计算位置并显示引导框
  setTimeout(() => {
    calculateGuidePosition();
    // 等位置计算好后再显示引导框
    setTimeout(() => {
      guideVisible.value = true;
    }, 100);
  }, 100);
};

// 隐藏引导
const hideGuide = () => {
  guideVisible.value = false;
  guideStarted.value = false;
  // 清除高亮区域
  highlightElement.value = null;
  highlightRect.top = 0;
  highlightRect.left = 0;
  highlightRect.width = 0;
  highlightRect.height = 0;
  // 用户完成引导后，记录到 localStorage
  localStorage.setItem('sceneGuideShown', 'true');
};

// 下一步
const handleGuideNext = () => {
  if (guideCurrentStep.value < guideSteps.length - 1) {
    guideCurrentStep.value++;
    // 启用过渡动画
    enableGuideTransition.value = true;
    // 计算下一个步骤的引导框位置
    setTimeout(() => {
      calculateGuidePosition();
    }, 50);
  } else {
    hideGuide();
  }
};

// 上一步
const handleGuidePrev = () => {
  if (guideCurrentStep.value > 0) {
    guideCurrentStep.value--;
    // 启用过渡动画
    enableGuideTransition.value = true;
    // 计算上一个步骤的引导框位置
    setTimeout(() => {
      calculateGuidePosition();
    }, 50);
  }
};

// 跳至指定步骤
const handleGuideJump = (step: number) => {
  guideCurrentStep.value = step;
  // 启用过渡动画
  enableGuideTransition.value = true;
  // 计算指定步骤的引导框位置
  setTimeout(() => {
    calculateGuidePosition();
  }, 50);
};

// 关闭引导
const handleGuideClose = () => {
  hideGuide();
};

// ==================== 生命周期 ====================

onMounted(() => {
  // 获取场景 ID
  const sceneId = route.params.id as string;

  // TODO: 根据场景 ID 加载场景详情数据
  console.log('加载场景详情:', sceneId);

  // 检查是否已显示过引导
  const hasShownGuide = localStorage.getItem('sceneGuideShown');
  if (!hasShownGuide) {
    // 延迟显示引导，确保 DOM 已渲染
    setTimeout(() => {
      showGuide();
    }, 500);
  }
});
</script>

<style scoped>
.scene-detail {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f0f2f5;
  padding: 16px;
}

/* 标签页区域 */
.tabs-section {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

:deep(.ant-tabs) {
  margin-bottom: 0;
}

:deep(.ant-tabs-nav) {
  margin: 0;
}

/* Tab 内容区域 */
.tab-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.tab-content > div,
.tab-content > .process-setting-tab {
  height: 100%;
  background: #fff;
  border-radius: 4px;
}

/* ==================== 主流程设置样式 ==================== */
/* 覆盖 ProcessSettingTab 组件的样式，使其与 SceneTemplateDetail 一致 */
:deep(.process-setting-tab) {
  height: 100%;
  overflow: hidden;
  background: #f5f5f5;
}

:deep(.process-content) {
  height: 100%;
  overflow: hidden;
  background: #f5f5f5;
}

:deep(.process-wrapper) {
  height: 100%;
}

:deep(.process-canvas-wrapper) {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
}

:deep(.canvas-toolbar) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  background: #fafafa;
  flex-shrink: 0;
}

:deep(.toolbar-left),
:deep(.toolbar-right) {
  display: flex;
  align-items: center;
  gap: 8px;
}

:deep(.zoom-text) {
  font-size: 13px;
  color: #595959;
  margin-left: 8px;
}

/* 节点添加栏（固定在画布区域顶部） */
:deep(.node-palette) {
  position: relative;
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  flex-shrink: 0;
}

:deep(.palette-content) {
  display: flex;
  gap: 8px;
  padding: 12px;
  overflow-x: auto;
  background: #fff;
}

:deep(.palette-node-item) {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #f5f5f5;
  border-radius: 4px;
  cursor: grab;
  transition: all 0.2s;
  font-size: 12px;
  color: #1f1f1f;
}

:deep(.palette-node-item:hover) {
  background: #e6f7ff;
  border-color: #1890ff;
}

.process-canvas {
  flex: 1;
  overflow: auto;
  background: #f5f5f5;
  position: relative;
  min-height: 0;
}

:deep(.canvas-content) {
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
}

:deep(.connection-layer) {
  position: absolute;
  top: 0;
  left: 0;
  pointer-events: none;
  z-index: 1;
}

:deep(.connection-hit) {
  fill: none;
  stroke: transparent;
  stroke-width: 20;
  cursor: pointer;
  pointer-events: stroke;
}

:deep(.connection-line) {
  fill: none;
  stroke: #91d5ff;
  stroke-width: 2;
  marker-end: url(#arrowhead);
  pointer-events: none;
  transition: all 0.3s;
}

:deep(.connection-selected .connection-line) {
  stroke: #1890ff;
  stroke-width: 3;
  marker-end: url(#arrowhead-selected);
}

:deep(.connection-delete) {
  cursor: pointer;
  pointer-events: all;
}

/* :deep(.process-node) {
  position: absolute;
  width: 200px;
  height: 80px;
  background: #fff;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  cursor: move;
  z-index: 2;
  transition: box-shadow 0.2s;
} */

:deep(.process-node:hover) {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

:deep(.process-node.node-selected) {
  border-color: #1890ff;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.3);
}

:deep(.node-header) {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
  border-radius: 4px 4px 0 0;
}

:deep(.node-title) {
  flex: 1;
  font-size: 12px;
  font-weight: 500;
  color: #1f1f1f;
}

:deep(.node-actions) {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s;
}

:deep(.process-node:hover .node-actions) {
  opacity: 1;
}

:deep(.node-action-btn) {
  padding: 2px 4px;
  font-size: 12px;
}

:deep(.node-content) {
  padding: 12px;
  font-size: 12px;
  color: #666;
}

:deep(.node-desc) {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

:deep(.node-connector) {
  position: absolute;
  width: 12px;
  height: 12px;
  background: #fff;
  border: 2px solid #1890ff;
  border-radius: 50%;
}

:deep(.node-connector:hover) {
  background: #1890ff;
}

:deep(.node-connector-out) {
  left: 50%;
  transform: translateX(-50%);
}

:deep(.node-connector-in) {
  top: -6px;
  left: 50%;
  transform: translateX(-50%);
}

:deep(.temp-connection-layer) {
  position: absolute;
  top: 0;
  left: 0;
  pointer-events: none;
  z-index: 3;
}

:deep(.temp-connection-line) {
  stroke: #1890ff;
  stroke-width: 2px;
  stroke-dasharray: 5, 5;
  fill: none;
}

:deep(.intent-tags) {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  justify-content: center;
}

:deep(.modal-footer) {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 16px;
}

:deep(.intent-select-list) {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 300px;
  overflow-y: auto;
}

:deep(.selected-intent-tags) {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

:deep(.form-tip) {
  color: #999;
  font-size: 12px;
}

/* 节点类型样式 */
:deep(.node-type-start) {
  border-left: 4px solid #52c41a;
}

:deep(.node-type-script) {
  border-left: 4px solid #1890ff;
}

:deep(.node-type-success_end) {
  border-left: 4px solid #52c41a;
}

:deep(.node-type-fail_end) {
  border-left: 4px solid #ff4d4f;
}

:deep(.node-type-transfer) {
  border-left: 4px solid #faad14;
}

:deep(.node-type-verify) {
  border-left: 4px solid #722ed1;
}

/* ==================== 引导样式 ==================== */
.guide-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  z-index: 9998;
  pointer-events: none;
}

.guide-highlight {
  position: absolute;
  box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.4);
  border-radius: 4px;
  transition: all 0.3s;
}

.guide-overlay {
  position: fixed;
  width: 300px;
  z-index: 9999;
}

.guide-overlay.guide-with-transition {
  animation: guide-popover-slide 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes guide-popover-slide {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.guide-popover {
  position: relative;
  z-index: 10000;
  width: 100%;
  background: #fff;
  border-radius: 6px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  padding: 12px 16px;
}

.guide-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.guide-step-indicator {
  font-size: 11px;
  color: #1890ff;
  font-weight: 500;
}

.guide-close-btn {
  color: #8c8c8c;
  font-size: 14px;
  padding: 0;
  width: 20px;
  height: 20px;
}

.guide-close-btn:hover {
  color: #595959;
}

.guide-body {
  margin-bottom: 12px;
}

.guide-title {
  font-size: 13px;
  font-weight: 500;
  color: #262626;
  margin: 0 0 6px 0;
}

.guide-description {
  font-size: 12px;
  color: #595959;
  line-height: 1.5;
  margin: 0;
}

.guide-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 10px;
  border-top: 1px solid #f0f0f0;
}

.guide-footer-first {
  justify-content: flex-end;
}

.guide-steps-indicator {
  display: flex;
  justify-content: center;
  gap: 6px;
  margin-top: 10px;
}

.step-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #d9d9d9;
  cursor: pointer;
  transition: all 0.3s;
}

.step-dot.active {
  width: 16px;
  border-radius: 3px;
  background: #1890ff;
}

.step-dot:hover {
  background: #40a9ff;
}

/* 重新引导按钮 */
.restart-guide-btn {
  position: fixed;
  bottom: 40px;
  right: 40px;
  width: 56px;
  height: 56px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
}

.restart-guide-btn:hover {
  transform: scale(1.1);
}
</style>
