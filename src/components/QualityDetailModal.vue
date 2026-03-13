<template>
  <a-modal
    v-model:open="visible"
    title="质检详情"
    class="quality-detail-modal"
    :width="1200"
    :footer="null"
    :body-style="{ padding: '0' }"
  >
    <div class="quality-detail-content">
      <!-- 左侧对话区域 -->
      <div class="left-panel">
        <!-- 通话录音播放器 -->
        <div class="audio-player">
          <div class="player-left">
            <div class="play-btn">
              <PlayCircleOutlined />
            </div>
            <span class="player-title">通话录音</span>
          </div>
          <div class="player-center">
            <a-slider v-model:value="audioProgress" :min="0" :max="100" />
          </div>
          <div class="player-right">
            <SoundOutlined class="volume-icon" />
            <a-slider v-model:value="audioVolume" :min="0" :max="100" :style="{ width: '100px' }" />
            <span class="time-text">{{ currentTime }} / {{ totalTime }}</span>
          </div>
        </div>

        <!-- 操作提示 -->
        <div class="action-tips">
          <span>点击对话文本进行标注</span>
          <a class="view-rule-link" @click="viewQualityRules">查看质检规则</a>
        </div>

        <!-- 对话列表 -->
        <div class="conversation-list">
          <div
            v-for="(msg, index) in conversationList"
            :key="index"
            class="conversation-item"
            :class="msg.role"
          >
            <div v-if="msg.role === 'customer'" class="avatar customer-avatar">
              <UserOutlined class="avatar-icon customer-icon" />
            </div>
            <div v-else class="avatar agent-avatar">
              <CustomerServiceOutlined class="avatar-icon agent-icon" />
            </div>
            
            <div class="message-content">
              <div v-if="msg.role === 'agent'" class="message-time">{{ msg.time }}</div>
              <div
                class="message-bubble"
                :class="{ 'highlighted': msg.highlighted }"
                @click="(e) => selectMessage(msg, e)"
              >
                <span v-html="highlightText(msg.content)"></span>
              </div>
              <div v-if="msg.role === 'customer'" class="message-time">{{ msg.time }}</div>
              
              <!-- 触发质检项标签 -->
              <div v-if="msg.triggerRules && msg.triggerRules.length > 0" class="trigger-rules">
                <span class="trigger-label">触发质检项：</span>
                <a-tag v-for="rule in msg.triggerRules" :key="rule.code" color="orange" class="rule-tag">
                  {{ rule.code }}
                </a-tag>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧质检小结区域 -->
      <div class="right-panel">
        <div class="summary-header">
          <h3>质检小结</h3>
        </div>
        
        <a-tabs v-model:activeKey="activeTab" class="summary-tabs">
          <a-tab-pane key="ai" tab="AI 质检结果">
            <div class="ai-result-list">
              <div
                v-for="(result, index) in aiResults"
                :key="index"
                class="result-item"
                :class="{ 'last-item': index === aiResults.length - 1 }"
              >
                <div class="result-content">
                  <div class="rule-info">
                    <span class="rule-label">规则编号：</span>
                    <span class="rule-code">{{ result.ruleCode }}</span>
                    <span class="rule-desc">{{ result.ruleDesc }}</span>
                  </div>
                  <div class="dialog-content">
                    <span class="content-label">对话内容：</span>
                    <span class="content-text">{{ result.dialogContent }}</span>
                  </div>
                  <div class="remark-content">
                    <span class="remark-label">质检备注：</span>
                    <span class="remark-text">{{ result.remark || '-' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </a-tab-pane>
          
          <a-tab-pane key="manual" tab="人工审核结果">
            <div class="manual-result">
              <a-empty description="暂无人工审核结果" />
            </div>
          </a-tab-pane>
        </a-tabs>
      </div>
    </div>

    <!-- 质检项编辑浮窗 -->
    <div class="quality-edit-popover" v-if="selectedMessage">
      <div class="popover-header">
        <span class="popover-title">触发质检项</span>
        <a class="close-btn" @click="closeEditPanel">
          <CloseOutlined />
        </a>
      </div>
      <div class="popover-content">
        <a-select
          v-model:value="selectedRules"
          mode="multiple"
          placeholder="请选择质检项"
          class="rule-select"
          :options="qualityRuleOptions"
          style="width: 100%"
        />
        <a-textarea
          v-model:value="editRemark"
          placeholder="请输入质检备注"
          :rows="4"
          class="remark-textarea"
        />
        <div class="keyword-search">
          <a-input
            v-model:value="searchKeyword"
            placeholder="输入关键词进行匹配"
            allow-clear
            class="keyword-input"
          >
            <template #prefix>
              <SearchOutlined />
            </template>
          </a-input>
        </div>
      </div>
      <div class="popover-footer">
        <a-button @click="closeEditPanel">取消</a-button>
        <a-button type="primary" @click="saveEdit">保存</a-button>
      </div>
    </div>

    <!-- 底部操作栏 -->
    <div class="modal-footer" v-if="!selectedMessage">
      <a-button @click="handlePrevious">上一条</a-button>
      <a-button type="primary" @click="handleSaveManualResult">保存人工审核结果</a-button>
      <a-button @click="handleNext">下一条</a-button>
    </div>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, defineExpose, computed } from 'vue'
import {
  PlayCircleOutlined,
  SoundOutlined,
  UserOutlined,
  CustomerServiceOutlined,
  CloseOutlined,
  SearchOutlined
} from '@ant-design/icons-vue'

// 弹窗显示状态
const visible = ref(false)

// 打开弹窗
const open = () => {
  console.log('QualityDetailModal open called')
  visible.value = true
}

// 关闭弹窗
const close = () => {
  visible.value = false
}

// 暴露方法给父组件
defineExpose({
  open,
  close
})

// 音频播放相关
const audioProgress = ref(0)
const audioVolume = ref(50)
const currentTime = ref('00:00')
const totalTime = ref('00:00')

// 当前激活的标签页
const activeTab = ref('ai')

// 当前选中的消息
const selectedMessage = ref<any>(null)

// 选中的质检项
const selectedRules = ref<string[]>([])

// 编辑的备注
const editRemark = ref('')

// 搜索关键词
const searchKeyword = ref('')

// 质检项选项
const qualityRuleOptions = ref([
  { label: 'B1 - 身份核实要求', value: 'B1' },
  { label: 'C1 - 客户拒绝后继续推销', value: 'C1' },
  { label: 'C2 - 多次意图性推销', value: 'C2' },
  { label: 'A1 - 未使用规范用语', value: 'A1' },
  { label: 'A2 - 未告知关键信息', value: 'A2' }
])

// 高亮文本
const highlightText = (text: string) => {
  if (!searchKeyword.value || !text) return text || ''
  const escapeRegExp = (str: string) => str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const escapedKeyword = escapeRegExp(searchKeyword.value)
  const regex = new RegExp(`(${escapedKeyword})`, 'gi')
  return text.replace(regex, '<span class="highlight-keyword">$1</span>')
}

// 对话列表数据
const conversationList = ref([
  {
    role: 'agent',
    time: '2025-12-01 14:23:30',
    content: '哎，您好，这边是邮政储蓄银行，年底了，为了答谢像您这样的老用户，我们专门为您准备了一份精美礼品，这边给您介绍一下吧，好吗',
    highlighted: true,
    triggerRules: [{ code: 'B1' }]
  },
  {
    role: 'customer',
    time: '2025-12-01 14:23:43',
    content: '我不是老用户呀。',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:23:50',
    content: '先生，您是我们邮政的长期用户，我们系统显示您确实符合老用户的条件。这次的活动是专门为我们邮政的优质客户准备的，礼品包括高档大米、食用油等实用物品，都是免费赠送的。',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'customer',
    time: '2025-12-01 14:24:05',
    content: '我不需要，你们不要再打电话来了。',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:24:15',
    content: '先生，我理解您的顾虑。但是这次的活动真的非常优惠，而且我们是完全免费的，不需要您支付任何费用。您看这样吧，我让我们网点的经理跟您详细介绍一下，她会更专业地为您解答疑问，好吗？',
    highlighted: true,
    triggerRules: [{ code: 'C1' }]
  },
  {
    role: 'customer',
    time: '2025-12-01 14:24:30',
    content: '不好，我不想听。',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:24:40',
    content: '先生，本次活动是为了回馈您对邮政的支持，礼品丰富、实用，先到先得！就让我们网点客户经理跟您详细介绍下，您如果觉得好再给您预约，可以吗？',
    highlighted: true,
    triggerRules: [{ code: 'C2' }]
  },
  {
    role: 'customer',
    time: '2025-12-01 14:24:55',
    content: '不可以，你们怎么这么烦人。',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:25:05',
    content: '先生，您别生气。这样吧，我加一下您的微信，把活动详情发给您看看，您有兴趣的话再联系我们，好吗？',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'customer',
    time: '2025-12-01 14:25:15',
    content: '以上。',
    highlighted: false,
    triggerRules: []
  }
])

// AI 质检结果
const aiResults = ref([
  {
    ruleCode: 'B1',
    ruleDesc: '（客服未确认客户身份即以"老用户"名义开展营销，客户已明确否认（"我不是老用户呀"），坐席未中止营销行为，仍继续推进转接流程，违反身份核实前置要求。）',
    dialogContent: '哎，您好，这边是邮政储蓄银行，年底了，为了答谢像您这样的老用户，我们专门为您准备了一份精美礼品，这边给您介绍一下吧，好吗',
    remark: '-'
  },
  {
    ruleCode: 'C1',
    ruleDesc: '（客户两次明确拒绝（"不好""不可以"）后，客服仍继续推销，并仅一次尝试挽留（转为客户经理对接），未达"至少两次挽留"标准，构成三级缺陷。）',
    dialogContent: '本次活动是为了回馈您对邮政的支持，礼品丰富、实用，先到先得！就让我们网点客户经理跟您详细介绍下，您如果觉得好再给您预约，可以吗？',
    remark: '-'
  },
  {
    ruleCode: 'C2',
    ruleDesc: '（客户两次明确拒绝后，客服继续推进营销动作（转经理、推微信、发链接），累计超三次意图性推销，引发客户进一步疏离（"以上"），可能）',
    dialogContent: '',
    remark: '-'
  }
])

// 查看质检规则
const viewQualityRules = () => {
  console.log('查看质检规则')
}

// 选择消息
const selectMessage = (msg: any, event?: MouseEvent) => {
  console.log('选择消息:', msg)
  selectedMessage.value = msg
  selectedRules.value = msg.triggerRules?.map((r: any) => r.code) || []
  editRemark.value = msg.remark || ''
}

// 关闭编辑面板
const closeEditPanel = () => {
  selectedMessage.value = null
  selectedRules.value = []
  editRemark.value = ''
}

// 保存编辑
const saveEdit = () => {
  if (selectedMessage.value) {
    selectedMessage.value.triggerRules = selectedRules.value.map(code => ({ code }))
    selectedMessage.value.remark = editRemark.value
    console.log('保存质检项:', selectedMessage.value)
    closeEditPanel()
  }
}

// 上一条
const handlePrevious = () => {
  console.log('上一条')
}

// 保存人工审核结果
const handleSaveManualResult = () => {
  console.log('保存人工审核结果')
}

// 下一条
const handleNext = () => {
  console.log('下一条')
}
</script>

<style scoped>
.quality-detail-modal :deep(.ant-modal-header) {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.quality-detail-modal :deep(.ant-modal-title) {
  font-size: 18px;
  font-weight: 500;
  color: #1f2329;
}

.quality-detail-modal :deep(.ant-modal-body) {
  padding: 0;
  position: relative;
  z-index: 1;
}

.quality-detail-content {
  display: flex;
  height: 700px;
}

/* 质检项编辑浮窗 */
.quality-edit-popover {
  position: absolute;
  z-index: 1000;
  width: 400px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
  border: 1px solid #f0f0f0;
  padding: 16px 20px;
  left: 50%;
  top: 150px;
  transform: translateX(-50%);
}

/* 左侧面板 */
.left-panel {
  width: 600px;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  margin-right: 8px;
}

/* 音频播放器 */
.audio-player {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  background: #fafafa;
  border-bottom: 1px solid #f0f0f0;
}

.player-left {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-right: 16px;
}

.play-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #1677ff;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  cursor: pointer;
}

.player-title {
  font-size: 14px;
  color: #1f2329;
}

.player-center {
  flex: 1;
  margin: 0 16px;
}

.player-center :deep(.ant-slider) {
  margin: 0;
}

.player-center :deep(.ant-slider-rail) {
  background-color: #e5e5e5;
}

.player-center :deep(.ant-slider-track) {
  background-color: #1677ff;
}

.player-right {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 200px;
}

.volume-icon {
  font-size: 16px;
  color: #8f959e;
}

.time-text {
  font-size: 13px;
  color: #8f959e;
  min-width: 90px;
  text-align: right;
}

/* 操作提示 */
.action-tips {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 20px;
  background: #f5f7fa;
  border-bottom: 1px solid #e8e8e8;
}

.action-tips span {
  font-size: 13px;
  color: #595959;
}

.view-rule-link {
  font-size: 13px;
  color: #1677ff;
  cursor: pointer;
}

.view-rule-link:hover {
  text-decoration: underline;
}

/* 对话列表 */
.conversation-list {
  flex: 1;
  overflow-y: auto;
  padding: 20px 24px;
  background: #f5f7fa;
}

.conversation-item {
  display: flex;
  margin-bottom: 20px;
  gap: 12px;
}

.conversation-item.customer {
  flex-direction: row;
}

.conversation-item.agent {
  flex-direction: row-reverse;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-icon {
  font-size: 20px;
}

.customer-icon {
  color: #1677ff;
}

.agent-icon {
  color: #52c41a;
}

.customer-avatar {
  background: #e6f4ff;
}

.agent-avatar {
  background: #f6ffed;
}

.message-content {
  max-width: 450px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.conversation-item.agent .message-content {
  align-items: flex-end;
}

.message-time {
  font-size: 12px;
  color: #8f959e;
}

.message-bubble {
  padding: 12px 16px;
  background: #fff;
  border-radius: 8px;
  font-size: 14px;
  color: #1f2329;
  line-height: 1.6;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.3s;
}

.message-bubble:hover {
  border-color: #1677ff;
}

.message-bubble.highlighted {
  border-color: #1677ff;
  background: #e6f4ff;
}

.conversation-item.agent .message-bubble {
  background: #f0f5ff;
  color: #1f2329;
  border: 1px solid #d6e4ff;
}

.conversation-item.agent .message-bubble:hover {
  border-color: #1677ff;
  background: #e6f4ff;
}

.conversation-item.agent .message-bubble.highlighted {
  background: #e6f4ff;
  border-color: #1677ff;
}

.conversation-item.customer .message-bubble {
  background: #f6ffed;
  color: #1f2329;
  border: 1px solid #d9f7be;
}

.conversation-item.customer .message-bubble:hover {
  border-color: #52c41a;
  background: #f0f9ff;
}

.conversation-item.customer .message-bubble.highlighted {
  background: #f0f9ff;
  border-color: #1677ff;
}

.trigger-rules {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 4px;
}

.trigger-label {
  font-size: 12px;
  color: #fa8c16;
}

.rule-tag {
  font-size: 12px;
  padding: 2px 8px;
}

/* 右侧面板 */
.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.summary-header {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  text-align: center;
}

.summary-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 500;
  color: #1f2329;
}

.summary-tabs {
  flex: 1;
  overflow: hidden;
}

.summary-tabs :deep(.ant-tabs-content) {
  height: calc(100% - 46px);
}

.summary-tabs :deep(.ant-tabs-tabpane) {
  height: 100%;
}

/* AI 质检结果列表 */
.ai-result-list {
  height: 100%;
  overflow-y: auto;
  padding: 20px 24px;
}

.result-item {
  padding-bottom: 20px;
  margin-bottom: 20px;
  border-bottom: 1px solid #d9e8ff;
}

.result-item.last-item {
  border-bottom: none;
  margin-bottom: 0;
}

.result-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rule-info {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 14px;
  line-height: 1.6;
}

.rule-label {
  color: #8f959e;
  flex-shrink: 0;
}

.rule-code {
  font-weight: 500;
  color: #1f2329;
}

.rule-desc {
  color: #595959;
}

.dialog-content {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 14px;
  line-height: 1.6;
}

.content-label {
  color: #8f959e;
  flex-shrink: 0;
}

.content-text {
  color: #595959;
}

.remark-content {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 14px;
  line-height: 1.6;
}

.remark-label {
  color: #8f959e;
  flex-shrink: 0;
}

.remark-text {
  color: #595959;
}

/* 人工审核结果 */
.manual-result {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 底部操作栏 */
.modal-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-top: 1px solid #f0f0f0;
  background: #fafafa;
}

.modal-footer .ant-btn {
  min-width: 100px;
  height: 36px;
  font-size: 14px;
}

.popover-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.popover-title {
  font-size: 16px;
  font-weight: 500;
  color: #1f2329;
}

.popover-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 16px;
}

.popover-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.popover-footer .ant-btn {
  min-width: 80px;
  height: 32px;
  font-size: 14px;
}

/* 关键词高亮 */
.highlight-keyword {
  background-color: #fff566;
  color: #000;
  padding: 2px 4px;
  border-radius: 2px;
  font-weight: 500;
}

/* 关键词搜索框 */
.keyword-search {
  margin-top: 8px;
}

.keyword-input {
  width: 100%;
}
</style>

<style>
/* 关键词高亮 - 全局样式，因为 v-html 内容不受 scoped 影响 */
.highlight-keyword {
  background-color: #fff566;
  color: #000;
  padding: 2px 4px;
  border-radius: 2px;
  font-weight: 500;
}
</style>
