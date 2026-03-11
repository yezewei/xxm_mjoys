<template>
  <div v-if="visible" class="qa-guide-overlay" :class="{ 'qa-guide-with-transition': enableTransition }" :style="{ top: modalPosition.top, left: modalPosition.left, transform: modalPosition.transform }">
    <!-- 遮罩层 -->
    <div class="qa-guide-mask" @click="handleClose"></div>

    <!-- 高亮目标区域 -->
    <div
      v-if="highlightStyle"
      class="qa-guide-highlight"
      :style="highlightStyle"
    ></div>

    <!-- 引导弹窗 -->
    <div
      class="qa-guide-popover"
    >


      <!-- 引导内容 -->
      <div class="qa-guide-content">
        <div class="qa-guide-header">
          <span class="qa-guide-step-indicator">步骤 {{ internalCurrentStep + 1 }} / {{ steps.length }}</span>
          <a-button
            type="text"
            size="small"
            class="qa-guide-close-btn"
            @click="handleClose"
          >
            <CloseOutlined />
          </a-button>
        </div>

        <div class="qa-guide-body">
          <h4 class="qa-guide-title">{{ currentStepData.title }}</h4>
          <p class="qa-guide-description">{{ currentStepData.content }}</p>


          <!-- <div v-if="currentStep === 4" class="qa-guide-notice">
            <InfoCircleOutlined class="notice-icon" />
            <p class="notice-text">
              当通用/行业 QA 缺失语料时，可创建同名场景 QA 维护语料后上报，用于模型优化。
              场景模板 QA 库展示基于当前模板创建的场景中的所有 QA。
            </p>
          </div> -->
        </div>

        <div class="qa-guide-footer" :class="{ 'qa-guide-footer-first': internalCurrentStep === 0 }">
          <a-button
            v-if="internalCurrentStep > 0"
            size="small"
            @click="handlePrev"
          >
            上一步
          </a-button>
          <a-button
            type="primary"
            size="small"
            @click="handleNext"
            :style="{ marginLeft: internalCurrentStep === 0 ? 'auto' : '0' }"
          >
            {{ internalCurrentStep === steps.length - 1 ? '完成引导' : '下一步' }}
          </a-button>
        </div>

     <!-- 步骤指示器 -->
      <div class="qa-guide-steps-indicator">
        <div
          v-for="(_step, index) in steps"
          :key="index"
          :class="['qa-step-dot', { active: internalCurrentStep === index, completed: internalCurrentStep > index }]"
          @click="handleJumpToStep(index)"
        >
        </div>
      </div>


      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, nextTick } from 'vue';
import { CloseOutlined, InfoCircleOutlined } from '@ant-design/icons-vue';

// ==================== Props & Emits ====================
interface GuideStep {
  title: string;
  content: string;
  targetSelector: string;
  placement?: 'top' | 'bottom' | 'left' | 'right';
}

const props = defineProps({
  visible: {
    type: Boolean,
    default: false,
  },
  steps: {
    type: Array as () => GuideStep[],
    default: () => [],
  },
  currentStep: {
    type: Number,
    default: 0,
  },
});

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'finish'): void;
  (e: 'update:currentStep', step: number): void;
}>();

// ==================== 响应式数据 ====================
const internalCurrentStep = ref(props.currentStep);
const enableTransition = ref(false);

// 引导框位置
const modalPosition = reactive({
  top: '0px',
  left: '0px',
  transform: 'none',
});

// 高亮区域样式
const highlightStyle = ref<Record<string, string> | null>(null);

// ==================== 计算属性 ====================
const currentStepData = computed(() => {
  return props.steps[internalCurrentStep.value] || props.steps[0];
});

// ==================== 方法 ====================
// 计算引导框和高亮区域位置
const calculatePosition = () => {
  nextTick(() => {
    setTimeout(() => {
      const stepData = props.steps[internalCurrentStep.value];
      if (!stepData) return;

      const targetElement = document.querySelector(stepData.targetSelector) as HTMLElement;

      // 在最后一步（step5）时，定位在页面正中间
      if (internalCurrentStep.value === props.steps.length - 1) {
        highlightStyle.value = null;
        modalPosition.top = '50%';
        modalPosition.left = '50%';
        modalPosition.transform = 'translate(-50%, -50%)';
        return;
      }

      if (targetElement) {
        const rect = targetElement.getBoundingClientRect();
        // 使用固定高度估算（弹窗最大高度 280px + 遮罩层等）
        const estimatedModalHeight = 280;

        // 计算高亮区域样式
        highlightStyle.value = {
          left: rect.left + 'px',
          top: rect.top + 'px',
          width: rect.width + 'px',
          height: rect.height + 'px',
        };

        // 计算引导框位置 - 优先显示在下方
        let top = rect.bottom + 8;
        let left = rect.left;

        // 如果下方空间不足，尝试显示在上方
        if (top + estimatedModalHeight > window.innerHeight - 10) {
          top = rect.top - estimatedModalHeight - 8;
          // 确保不会超出顶部
          if (top < 10) {
            top = 10;
          }
        }

        // 如果右侧空间不足，向左对齐
        if (left + 300 > window.innerWidth) {
          left = window.innerWidth - 300 - 10;
        }
        // 确保不会超出左侧
        if (left < 10) {
          left = 10;
        }

        modalPosition.top = top + 'px';
        modalPosition.left = left + 'px';
        modalPosition.transform = 'none';
        
        // 滚动目标元素到视口中央
        targetElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
      } else {
        // 如果找不到目标元素，使用默认位置
        highlightStyle.value = null;
        modalPosition.top = '100px';
        modalPosition.left = '50%';
        modalPosition.transform = 'translateX(-50%)';
      }
    }, 50);
  });
};

// 上一步
const handlePrev = () => {
  if (internalCurrentStep.value > 0) {
    enableTransition.value = true;
    internalCurrentStep.value--;
    emit('update:currentStep', internalCurrentStep.value);
    nextTick(() => {
      setTimeout(() => {
        calculatePosition();
      }, 100);
    });
  }
};

// 下一步
const handleNext = () => {
  if (internalCurrentStep.value < props.steps.length - 1) {
    enableTransition.value = true;
    internalCurrentStep.value++;
    emit('update:currentStep', internalCurrentStep.value);
    nextTick(() => {
      setTimeout(() => {
        calculatePosition();
      }, 100);
    });
  } else {
    handleFinish();
  }
};

// 完成
const handleFinish = () => {
  localStorage.setItem('qaGuideCompleted', 'true');
  emit('finish');
};

// 跳转到指定步骤
const handleJumpToStep = (step: number) => {
  enableTransition.value = true;
  internalCurrentStep.value = step;
  emit('update:currentStep', step);
  calculatePosition();
};

// 关闭
const handleClose = () => {
  emit('close');
};

// 重置到第一步
const resetToFirstStep = () => {
  currentStep.value = 0;
  enableTransition.value = false;
};

// ==================== 监听 ====================
watch(() => props.visible, (newVal) => {
  if (newVal) {
    internalCurrentStep.value = 0;
    enableTransition.value = false;
    nextTick(() => {
      setTimeout(() => {
        calculatePosition();
      }, 200);
    });

    // 添加窗口大小变化监听
    window.addEventListener('resize', calculatePosition);
  } else {
    window.removeEventListener('resize', calculatePosition);
  }
}, { immediate: true });

// 监听父组件传入的 currentStep 变化（外部控制步骤时使用）
watch(() => props.currentStep, (newVal) => {
  if (newVal !== internalCurrentStep.value) {
    internalCurrentStep.value = newVal;
    enableTransition.value = true;
    nextTick(() => {
      setTimeout(() => {
        calculatePosition();
      }, 100);
    });
  }
});

// 暴露方法给父组件
defineExpose({
  resetToFirstStep,
  calculatePosition,
});
</script>

<style scoped>
.qa-guide-overlay {
  position: fixed;
  width: 300px;
  z-index: 9999;
}

/* 带过渡效果的引导框 */
.qa-guide-overlay.qa-guide-with-transition {
  transition: top 0.3s cubic-bezier(0.4, 0, 0.2, 1), left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* 遮罩层 */
.qa-guide-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.45);
  z-index: -2;
}

/* 高亮区域 */
.qa-guide-highlight {
  position: fixed;
  background: transparent;
  box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.45);
  border-radius: 4px;
  z-index: -1;
}

/* 引导弹窗 */
.qa-guide-popover {
  position: relative;
  z-index: 10000;
  width: 100%;
  background: #fff;
  border-radius: 6px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  padding: 10px 14px;
  animation: qa-guide-popover-slide 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  max-height: 280px;
  overflow-y: auto;
}

@keyframes qa-guide-popover-slide {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 步骤指示器 */
.qa-guide-steps-indicator {
  display: flex;
  justify-content: center;
  gap: 6px;
  margin-top: 6px;
  margin-bottom: 8px;
}

.qa-step-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #d9d9d9;
  transition: all 0.3s ease;
  cursor: pointer;
}

.qa-step-dot.active {
  width: 18px;
  border-radius: 3px;
  background: #1890ff;
}

.qa-step-dot.completed {
  background: #1890ff;
}

/* 引导内容 */
.qa-guide-content {
  padding: 0;
}

.qa-guide-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.qa-guide-step-indicator {
  font-size: 11px;
  color: #1890ff;
  font-weight: 500;
}

.qa-guide-close-btn {
  color: #8c8c8c;
  font-size: 14px;
  padding: 0;
  width: 20px;
  height: 20px;
}

.qa-guide-close-btn:hover {
  color: #595959;
}

.qa-guide-body {
  margin-bottom: 8px;
}

.qa-guide-title {
  font-size: 13px;
  font-weight: 500;
  color: #262626;
  margin: 0 0 6px 0;
}

.qa-guide-description {
  font-size: 12px;
  color: #595959;
  line-height: 1.5;
  margin: 0;
}

/* 特别说明 */
.qa-guide-notice {
  margin-top: 8px;
  padding: 6px 8px;
  background: #e6f7ff;
  border: 1px solid #91d5ff;
  border-radius: 4px;
  display: flex;
  gap: 6px;
  align-items: flex-start;
}

.notice-icon {
  font-size: 14px;
  color: #1890ff;
  flex-shrink: 0;
  margin-top: 1px;
}

.notice-text {
  margin: 0;
  font-size: 11px;
  line-height: 1.4;
  color: #0050b3;
}

/* 底部按钮区 */
.qa-guide-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 10px;
  border-top: 1px solid #f0f0f0;
}

.qa-guide-footer-first {
  justify-content: flex-end;
}
</style>
