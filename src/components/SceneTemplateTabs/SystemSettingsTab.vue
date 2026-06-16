<template>
  <div class="system-settings-content">
    <!-- 引导弹窗 -->
    <div v-if="guideVisible && guideSteps[guideCurrentStep]" class="guide-overlay">
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
    <div class="system-settings-wrapper">
      <!-- 客户跟进配置 -->
      <div class="settings-section">
        <div class="section-title">
          <div class="title-bar"></div>
          <span>客户跟进配置</span>
        </div>
        <div class="section-content">
          <a-form layout="vertical">
            <!-- 意向客户推送 -->
            <a-form-item label="意向客户推送：" class="required-label">
              <a-switch v-model:checked="systemSettingsForm.intentCustomerPush" />
              <div class="form-tip">机器人拨打电话后是否需要将意向客户推送给客户经理进行跟进，提高业务转化率</div>
            </a-form-item>

            <!-- 推送意向范围 -->
            <a-form-item label="推送意向范围：" v-if="systemSettingsForm.intentCustomerPush">
              <a-checkbox-group v-model:value="systemSettingsForm.pushIntentRange">
                <a-checkbox value="有意向">有意向</a-checkbox>
                <a-checkbox value="可能有意向">可能有意向</a-checkbox>
                <a-checkbox value="无意向">无意向</a-checkbox>
                <a-checkbox value="未接通">未接通</a-checkbox>
              </a-checkbox-group>
              <div class="form-tip">用户分类对将用户拨打的数据进行分发</div>
            </a-form-item>

            <!-- "意向率"包括 -->
            <a-form-item label='"意向率"包括：'>
              <a-checkbox-group v-model:value="systemSettingsForm.intentRateRange">
                <a-checkbox value="有意向">有意向</a-checkbox>
                <a-checkbox value="可能有意向">可能有意向</a-checkbox>
              </a-checkbox-group>
              <div class="form-tip">请勾选 系统统计 指标"有意向"包含哪些客户标签</div>
            </a-form-item>

            <!-- 当前场景跟进表单字段设置 -->
            <a-form-item label="当前场景跟进表单字段设置：">
              <div class="checkbox-grid">
                <a-checkbox v-for="field in followUpFields" :key="field.value" v-model:checked="field.checked">
                  {{ field.label }}
                </a-checkbox>
              </div>
              <div class="form-tip">客户跟进字段可以前往<a href="#" class="link-text">客户信息配置</a>中进行管理</div>
            </a-form-item>
          </a-form>
        </div>
      </div>

      <!-- 人机协同配置 -->
      <div class="settings-section">
        <div class="section-title">
          <div class="title-bar"></div>
          <span>人机协同配置</span>
        </div>
        <div class="section-content">
          <a-form layout="vertical">
            <!-- 人机协同模式 -->
            <a-form-item label="人机协同模式：">
              <a-switch v-model:checked="systemSettingsForm.humanMachineCollaboration" />
              <question-circle-outlined class="help-icon" />
              <span class="label-text" style="margin-left: 12px;">话术中是否配置转人工：<span :class="hasTransferScript ? 'success-text' : 'error-text'">{{ hasTransferScript ? '是' : '否' }}</span></span>
            </a-form-item>

            <!-- 协同方式 -->
            <a-form-item label="协同方式" class="required-label" v-if="systemSettingsForm.humanMachineCollaboration">
              <a-radio-group v-model:value="systemSettingsForm.collaborationMode">
                <a-radio value="active-intervention">主动介入</a-radio>
                <a-radio value="transfer">转人工</a-radio>
                <a-radio value="both">主动介入 + 转人工</a-radio>
              </a-radio-group>
            </a-form-item>

            <!-- 转人工条件 -->
            <a-form-item label="转人工条件：" class="required-label" v-if="systemSettingsForm.humanMachineCollaboration">
              <a-radio-group v-model:value="systemSettingsForm.transferCondition">
                <div class="transfer-condition-list">
                  <div class="transfer-condition-item">
                    <a-radio value="auto-transfer">呼通即转</a-radio>
                    <a-tooltip placement="topLeft" overlay-class-name="transfer-tooltip">
                      <template #title>
                        <div class="tooltip-content">即业界预测式外呼，指AI呼通后不播放开场白直接转接坐席，在转人工最大等待时长期间，每间隔10s查找一次空闲坐席，若未找到空闲坐席，系统播放转人工坐席忙话术并自动挂断；若找到空闲坐席，坐席侧振铃，坐席振铃最大时长30s，若坐席未接通系统播放转人工坐席忙话术并自动挂断，若坐席接通则进行人工通话。</div>
                      </template>
                      <question-circle-outlined class="condition-help-icon" />
                    </a-tooltip>
                  </div>
                  <div class="transfer-condition-item">
                    <a-radio value="auto-transfer-ai">呼通即转(AI同时接待)</a-radio>
                    <a-tooltip placement="topLeft" overlay-class-name="transfer-tooltip">
                      <template #title>
                        <div class="tooltip-content">电话接通后AI播放话术同时转接人工，系统每间隔10s查找一次空闲坐席，若找到空闲坐席，坐席侧振铃，坐席振铃最大时长30s，若坐席未接通，系统将不再查找新的坐席，后续由AI接待至通话结束，若坐席接通则停止AI接待进行人工通话。</div>
                      </template>
                      <question-circle-outlined class="condition-help-icon" />
                    </a-tooltip>
                  </div>
                  <div class="transfer-condition-item">
                    <a-radio value="after-intro">AI播放完开场白后转接</a-radio>
                    <a-tooltip placement="topLeft" overlay-class-name="transfer-tooltip">
                      <template #title>
                        <div class="tooltip-content">客户接起电话后AI播放完开场白后转接坐席，和呼通即转(AI同时接待)差别是转接时机不同。</div>
                      </template>
                      <question-circle-outlined class="condition-help-icon" />
                    </a-tooltip>
                  </div>
                  <div class="transfer-condition-item">
                    <a-radio value="trigger">触发话术/QA转接</a-radio>
                    <a-tooltip placement="topLeft" overlay-class-name="transfer-tooltip">
                      <template #title>
                        <div class="tooltip-content">流转至转人工节点或客户主动触发转人工QA，系统播放完成话术后触发转人工，在转人工最大等待时长期间，每间隔10s查找一次空闲坐席，若未找到空闲坐席，系统提示坐席忙并自动挂断；若找到空闲坐席，坐席侧振铃，坐席振铃最大时长30s，若坐席未接通系统播放转人工坐席忙话术并自动挂断，若坐席接通则进行人工通话。</div>
                      </template>
                      <question-circle-outlined class="condition-help-icon" />
                    </a-tooltip>
                  </div>
                </div>
              </a-radio-group>
              <!-- 呼通即转：转接提示语 -->
              <div v-if="systemSettingsForm.transferCondition === 'auto-transfer'" class="transfer-sub-setting">
                <a-form-item label="转接提示语配置项：" class="required-label" style="margin-bottom: 0;">
                  <span class="form-tip">提示：请在<a class="link-text" @click.prevent="handleGoToFallbackSetting">流程兜底设置</a>中配置转接提示语文案，并上传对应录音</span>
                </a-form-item>
              </div>
              <!-- 呼通即转(AI同时接待) / AI播发完开场白后转接：坐席介入方式 -->
              <div v-if="systemSettingsForm.transferCondition === 'auto-transfer-ai' || systemSettingsForm.transferCondition === 'after-intro'" class="transfer-sub-setting">
                <a-form-item label="坐席接管方式：" style="margin-bottom: 0;">
                  <a-radio-group v-model:value="systemSettingsForm.agentInterventionRule">
                    <div class="transfer-condition-list">
                      <div class="transfer-condition-item">
                        <a-radio value="after-current-script">等AI说完当前话术再接入</a-radio>
                        <a-tooltip placement="topLeft" overlay-class-name="transfer-tooltip">
                          <template #title>
                            <div class="tooltip-content">坐席接通后，系统等待 AI 播完当前正在播放的话术节点，再将通话交由坐席接管，坐席可立即与客户对话。</div>
                          </template>
                          <question-circle-outlined class="condition-help-icon" />
                        </a-tooltip>
                      </div>
                      <div class="transfer-condition-item">
                        <a-radio value="immediate">坐席接通后立即接管通话</a-radio>
                        <a-tooltip placement="topLeft" overlay-class-name="transfer-tooltip">
                          <template #title>
                            <div class="tooltip-content">坐席接通后，系统立即停止 AI 播放，将通话交由坐席接管，坐席直接与客户对话。</div>
                          </template>
                          <question-circle-outlined class="condition-help-icon" />
                        </a-tooltip>
                      </div>
                    </div>
                  </a-radio-group>
                </a-form-item>
              </div>
              <div v-if="systemSettingsForm.transferCondition !== 'trigger'" class="form-tip error-text" style="margin-top: 12px;">
                注意：当前模式下，主流程转人工节点和QA转人工节点配置不生效
              </div>
            </a-form-item>

            <!-- 协同策略 -->
            <a-form-item label="协同策略：" class="required-label" v-if="systemSettingsForm.humanMachineCollaboration">
              <a-radio-group v-model:value="systemSettingsForm.collaborationStrategy">
                <a-radio value="random-free">随机空闲转接</a-radio>
                <a-radio value="distribution">按分发策略转接</a-radio>
                <a-radio value="external-skill">转接给外部技能组</a-radio>
              </a-radio-group>
              <!-- <question-circle-outlined class="help-icon" style="margin-left: 8px;" v-for="i in 3" :key="i" /> -->
            </a-form-item>
          </a-form>
        </div>
      </div>

      <!-- 底部按钮 -->
      <div class="form-footer">
        <a-button @click="handleBack">
          <rollback-outlined />
          返回
        </a-button>
        <a-button type="primary" @click="handleSave">
          <save-outlined />
          保存
        </a-button>
        <span class="save-tip">保存成功后，5 分钟后生效</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import {
  QuestionCircleOutlined,
  CloseOutlined,
  RollbackOutlined,
  SaveOutlined,
} from '@ant-design/icons-vue';

// ==================== 接口定义 ====================
interface FollowUpField {
  value: string;
  label: string;
  checked: boolean;
}

interface GuideStep {
  step: number;
  title: string;
  description: string;
  target: string;
  placement: 'top' | 'bottom' | 'left' | 'right';
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: object;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: object): void;
  (e: 'save', data: object): void;
  (e: 'back'): void;
  (e: 'guide-close'): void;
  (e: 'guide-next'): void;
  (e: 'guide-prev'): void;
  (e: 'guide-jump', index: number): void;
  (e: 'go-to-fallback-setting'): void;
}>();

// ==================== 响应式数据 ====================
// 场景系统设置表单数据
const systemSettingsForm = reactive({
  // 客户跟进配置
  intentCustomerPush: true, // 意向客户推送
  pushIntentRange: ['有意向', '可能有意向'] as string[], // 推送意向范围
  intentRateRange: ['有意向', '可能有意向'] as string[], // "意向率"包括
  agentDistributionLimit: false, // 坐席分发限制
  qualityCheckDelay: false, // 质检延迟下发
  distributeTo: 'org-agent' as 'selected-agent' | 'skill-group' | 'org-agent', // 分发给
  distributionRule: '归属-org' as '归属-direct' | '归属-org' | 'average', // 分发规则
  fallbackRule: false, // 兜底规则
  smsReminder: false, // 跟进短信提醒

  // 人机协同配置
  humanMachineCollaboration: true, // 人机协同模式
  collaborationMode: 'transfer' as 'active-intervention' | 'transfer' | 'both', // 协同方式
  transferCondition: 'auto-transfer' as 'auto-transfer' | 'auto-transfer-ai' | 'after-intro' | 'trigger', // 转人工条件
  agentInterventionRule: 'after-current-script' as 'after-current-script' | 'immediate', // 坐席介入规则
  collaborationStrategy: 'random-free' as 'random-free' | 'distribution' | 'external-skill', // 协同策略
});

// 跟进表单字段列表
const followUpFields = ref<FollowUpField[]>([
  { value: 'follow-note', label: '跟进备注', checked: false },
  { value: 'add-wechat', label: '是否成功添加企微', checked: false },
  { value: 'wechat-name', label: '微信名', checked: false },
  { value: 'follow-continue', label: '客户跟进 - 持续跟进', checked: false },
  { value: 'willing-transfer', label: '是否愿意调户', checked: false },
  { value: 'appoint-date', label: '预约日期', checked: false },
  { value: 'connect-status', label: '接通状态', checked: false },
  { value: 'online-handled', label: '已线上办理', checked: false },
  { value: 'has-balance', label: '活期是否有余额', checked: false },
  { value: 'huaxia-product', label: '华夏是否购买过产品', checked: false },
  { value: 'request-follow', label: '要求再次跟进', checked: false },
  { value: 'request-sms', label: '要求发送短信', checked: false },
  { value: 'other-channel-time', label: '其他渠道资金到账时间', checked: false },
  { value: 'other-channel-amount', label: '其他渠道资金到账金额', checked: false },
  { value: 'add-enterprise', label: '添加企微', checked: false },
  { value: 'has-money-no-trust', label: '有资金但不信任', checked: false },
  { value: 'other-business', label: '其他业务需求', checked: false },
  { value: 'go-branch', label: '去网点处理非外呼业务', checked: false },
  { value: 'visit-time', label: '到访时间', checked: false },
  { value: 'demand', label: '需求', checked: false },
  { value: 'wechat-status', label: '加微情况', checked: false },
  { value: 'card-intent', label: '办卡意向', checked: false },
  { value: 'handle-method', label: '办理方式', checked: false },
  { value: 'deal-amount', label: '成交金额', checked: false },
  { value: 'come-branch', label: '来网点', checked: false },
  { value: 'customer 归属', label: '客户归属情况', checked: false },
]);

// 计算属性：是否有转人工话术
const hasTransferScript = computed(() => {
  // TODO: 检查话术中是否配置了转人工
  return false;
});

// ==================== 气泡引导相关数据 ====================
// 引导步骤配置
const guideSteps: GuideStep[] = [
  {
    step: 1,
    title: '配置客户跟进',
    description: '配置意向客户推送、推送意向范围、意向率统计范围等客户跟进相关设置。',
    target: '.settings-section:first-child',
    placement: 'bottom',
  },
  {
    step: 2,
    title: '配置人机协同',
    description: '配置人机协同模式、协同方式、转人工条件和协同策略，实现机器人与人工坐席的无缝协作。',
    target: '.settings-section:last-child',
    placement: 'bottom',
  },
];

// 引导状态
const guideVisible = ref(false);
const guideCurrentStep = ref(0);

// ==================== 方法 ====================
// 保存
const handleSave = () => {
  emit('save', { ...systemSettingsForm });
};

// 返回
const handleBack = () => {
  emit('back');
};

// 跳转到流程兜底设置
const handleGoToFallbackSetting = () => {
  emit('go-to-fallback-setting');
};

// 关闭引导
const handleGuideClose = () => {
  guideVisible.value = false;
  emit('guide-close');
};

// 下一步
const handleGuideNext = () => {
  if (guideCurrentStep.value < guideSteps.length - 1) {
    guideCurrentStep.value++;
    emit('guide-next');
  } else {
    guideVisible.value = false;
  }
};

// 上一步
const handleGuidePrev = () => {
  if (guideCurrentStep.value > 0) {
    guideCurrentStep.value--;
    emit('guide-prev');
  }
};

// 跳至指定步骤
const handleGuideJump = (index: number) => {
  guideCurrentStep.value = index;
  emit('guide-jump', index);
};

// 显示引导
const showGuide = () => {
  guideCurrentStep.value = 0;
  guideVisible.value = true;
};

// 暴露方法给父组件
defineExpose({
  showGuide,
});
</script>

<style scoped>
/* 场景系统设置样式 */
.system-settings-content {
  height: calc(100vh - 120px);
  overflow: hidden;
  background: #f5f5f5;
}

.system-settings-wrapper {
  height: 100%;
  overflow-y: auto;
}

.settings-section {
  margin-bottom: 24px;
  padding: 24px;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 20px;
  font-size: 15px;
  font-weight: 500;
  color: #262626;
}

.title-bar {
  width: 4px;
  height: 16px;
  background: #1890ff;
  border-radius: 2px;
}

.section-content {
  padding-left: 12px;
}

.form-tip {
  font-size: 13px;
  color: #8c8c8c;
  margin-top: 8px;
  line-height: 1.5;
}

.form-tip.error-text {
  color: #ff4d4f;
}

.link-text {
  color: #1890ff;
  text-decoration: none;
}

.link-text:hover {
  text-decoration: underline;
}

.help-icon {
  color: #8c8c8c;
  font-size: 14px;
  margin-left: 4px;
  cursor: help;
}

.required-label {
  color: #ff4d4f;
}

.required-label .label-text {
  color: #262626;
  font-size: 14px;
}

.checkbox-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin: 8px 0;
}

.checkbox-grid .ant-checkbox-wrapper {
  font-size: 13px;
  color: #595959;
}

.radio-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin: 8px 0;
}

.radio-group .ant-radio-wrapper {
  font-size: 14px;
  color: #595959;
  line-height: 1.5;
}

/* 转人工条件列表 */
.transfer-condition-list {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 12px 24px;
  margin: 8px 0;
}

.transfer-condition-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.transfer-condition-item .ant-radio-wrapper {
  font-size: 14px;
  color: #595959;
  line-height: 1.5;
}

.condition-help-icon {
  color: #8c8c8c;
  font-size: 14px;
  cursor: help;
  flex-shrink: 0;
}

.condition-help-icon:hover {
  color: #1890ff;
}

/* 转人工条件子配置 */
.transfer-sub-setting {
  margin-top: 16px;
  padding: 16px;
  background: #fafafa;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
}

.success-text {
  color: #52c41a;
  font-weight: 500;
}

.error-text {
  color: #ff4d4f;
  font-weight: 500;
}

/* 表单底部按钮 */
.form-footer {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding-top: 24px;
  margin-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.form-footer .ant-btn {
  min-width: 100px;
}

.save-tip {
  color: #1890ff;
  font-size: 13px;
  margin-left: 8px;
  align-self: center;
}

/* ==================== 气泡引导样式 ==================== */
.guide-overlay {
  position: fixed;
  width: 300px;
  z-index: 9999;
}

.guide-popover {
  position: relative;
  z-index: 10000;
  width: 100%;
  background: #fff;
  border-radius: 6px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  padding: 12px 16px;
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
</style>

<style>
.transfer-tooltip .ant-tooltip-inner {
  max-width: 420px;
  font-size: 13px;
  line-height: 1.8;
  color: #fff;
}

.transfer-tooltip .tooltip-content {
  white-space: normal;
  word-break: break-all;
}
</style>
