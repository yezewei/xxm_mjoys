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
                <span v-html="highlightText(msg.content, msg.triggerRules)"></span>
              </div>
              <div v-if="msg.role === 'customer'" class="message-time">{{ msg.time }}</div>

              <!-- 触发质检项标签 -->
              <div v-if="msg.triggerRules && msg.triggerRules.length > 0" class="trigger-rules">
                <span class="trigger-label">触发质检项：</span>
                <a-tooltip v-for="rule in msg.triggerRules" :key="rule.code" :title="getRuleTypeLabel(rule.type)">
                  <a-tag 
                    :color="getRuleTypeColor(rule.type)" 
                    class="rule-tag"
                    :class="['rule-tag-' + rule.type]"
                  >
                    <span class="rule-type-icon">{{ getRuleTypeIcon(rule.type) }}</span>
                    {{ rule.code }}
                  </a-tag>
                </a-tooltip>
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
              <a-empty v-if="aiResults.length === 0" description="暂无 AI 质检结果" />
            </div>
          </a-tab-pane>

          <a-tab-pane key="keyword" tab="关键词识别结果">
            <div class="keyword-result-list">
              <div
                v-for="(result, index) in keywordResults"
                :key="index"
                class="result-item"
                :class="{ 'last-item': index === keywordResults.length - 1 }"
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
              <a-empty v-if="keywordResults.length === 0" description="无关键词识别结果" />
            </div>
          </a-tab-pane>

          <a-tab-pane key="manual" tab="人工审核结果">
            <div class="manual-result-list">
              <div
                v-for="(result, index) in manualResults"
                :key="index"
                class="result-item"
                :class="{ 'last-item': index === manualResults.length - 1 }"
              >
                <div class="result-content">
                  <div class="rule-info">
                    <span class="rule-label">规则编号：</span>
                    <span class="rule-code">{{ result.ruleCode }}</span>
                    <span class="rule-type-badge" :class="'rule-type-' + result.sourceType">
                      {{ getSourceTypeLabel(result.sourceType) }}
                    </span>
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
              <a-empty v-if="manualResults.length === 0" description="暂无人工审核结果" />
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

    <!-- 已审核印章 -->
    <div class="approved-stamp" v-if="isApproved">
      <div class="stamp-content">
        <div class="stamp-circle">
          <span class="stamp-text">已审核</span>
        </div>
      </div>
    </div>
  </a-modal>

  <!-- 质检规则列表弹窗 -->
  <QualityRuleListModal ref="qualityRuleListRef" />
</template>

<script setup lang="ts">
import { ref, reactive, computed, defineExpose } from 'vue'
import {
  PlayCircleOutlined,
  SoundOutlined,
  UserOutlined,
  CustomerServiceOutlined,
  CloseOutlined
} from '@ant-design/icons-vue'
import QualityRuleListModal from './QualityRuleListModal.vue'
import { message } from 'ant-design-vue'

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

// 是否已审核（盖章状态）
const isApproved = ref(false)

// 质检项选项（与 QualityRule.vue 保持一致）
const qualityRuleOptions = ref([
  { label: 'A1 - 产品介绍错误', value: 'A1' },
  { label: 'A2 - 提醒不全', value: 'A2' },
  { label: 'A3 - 未正面回答', value: 'A3' },
  { label: 'B1 - 未确认客户身份', value: 'B1' },
  { label: 'B2 - 全部信息透露给客户', value: 'B2' }
])

// 各质检规则的关键词定义（与 QualityRule.vue 保持一致）
const ruleKeywords: Record<string, string[]> = {
  'A1': ['利率', '收益率', '年化', '有效期', '起息日', '到期日', '保本', '无风险', '稳赚', '利息', '收益', '费率', '手续费', '提前支取', '罚息', '违约金'],
  'A2': ['风险提示', '风险等级', '本金损失', '投资有风险', '谨慎投资', '仔细阅读', '条款', '免责', '免责声明', '重要提示', '请注意', '务必', '确认', '知晓', '理解'],
  'A3': ['这个我不清楚', '需要查询', '稍后回复', '问一下领导', '咨询一下', '回头告诉您', '不太确定', '可能', '应该', '大概', '也许', '说不准', '不方便透露', '公司规定', '不能说的'],
  'B1': ['请问您是', '本人吗', '确认一下身份', '您是 xxx 吗', '核对信息', '身份验证', '请问怎么称呼', '先生/女士', '您的姓名', '身份证', '手机号', '不是本人', '我是代接', '我是家属', '我是朋友', '我是同事'],
  'B2': ['身份证号码', '身份证号', '电话号码', '手机号', '银行卡号', '卡号', '账户余额', '资产', '存款', '理财金额', '投资金额', '您的尾号', '后四位', '前六位', '住址', '地址', '工作单位', '单位地址', '职业', '收入']
}

// 高亮文本 - 根据对话触发的规则关键词进行高亮
const highlightText = (text: string, triggerRules?: any[]) => {
  if (!text) return ''
  
  // 如果没有触发规则，返回原文本
  if (!triggerRules || triggerRules.length === 0) {
    return text
  }
  
  // 收集所有需要高亮的关键词
  const allKeywords: string[] = []
  triggerRules.forEach(rule => {
    const keywords = ruleKeywords[rule.code] || []
    allKeywords.push(...keywords)
  })
  
  // 去重并按长度排序（长的关键词优先匹配）
  const uniqueKeywords = Array.from(new Set(allKeywords)).sort((a, b) => b.length - a.length)
  
  if (uniqueKeywords.length === 0) {
    return text
  }
  
  // 构建正则表达式
  const escapedKeywords = uniqueKeywords.map(kw => kw.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
  const regex = new RegExp(`(${escapedKeywords.join('|')})`, 'gi')
  
  return text.replace(regex, '<span class="highlight-keyword">$1</span>')
}

// 对话列表数据
const conversationList = ref([
  {
    role: 'agent',
    time: '2025-12-01 14:23:30',
    content: '哎，您好，这边是邮政储蓄银行，年底了，为了答谢像您这样的老用户，我们专门为您准备了一份精美礼品，这边给您介绍一下吧，好吗',
    highlighted: true,
    triggerRules: [{ code: 'B1', type: 'ai' }]
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
    highlighted: false,
    triggerRules: []
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
    highlighted: false,
    triggerRules: []
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
  },
  // === 模拟触发"全部信息透露给客户"(B2) 规则的对话 - 身份证信息泄露 ===
  {
    role: 'agent',
    time: '2025-12-01 14:25:30',
    content: '先生，为了给您办理这个业务，我需要先核对一下您的身份信息。请问您的姓名是张三先生对吗？',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'customer',
    time: '2025-12-01 14:25:40',
    content: '对，是的。',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:25:50',
    content: '好的，这边看到您在我行预留的身份证号码是 110101199001011234，电话号码是 13812345678，请问这些信息还是您本人使用的吗？',
    highlighted: true,
    triggerRules: [{ code: 'B2', type: 'ai' }]
  },
  {
    role: 'customer',
    time: '2025-12-01 14:26:05',
    content: '你们怎么把我的身份证号码都念出来了？这样安全吗？',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:26:15',
    content: '先生您放心，我们这是正规银行。您的身份证后四位是 1234，银行卡号后六位是 789012，账户余额目前有 58000 元，这些信息都是准确的对吧？',
    highlighted: true,
    triggerRules: [{ code: 'B2', type: 'keyword' }]
  },
  {
    role: 'customer',
    time: '2025-12-01 14:26:30',
    content: '你们这样把我的资产情况都说出来，合适吗？',
    highlighted: false,
    triggerRules: []
  },
  {
    role: 'agent',
    time: '2025-12-01 14:26:40',
    content: '抱歉先生，我这边看到您的住址是北京市朝阳区某某街道某某小区 1 号楼 2 单元 301 室，工作单位是某某科技有限公司，这些信息需要更新吗？',
    highlighted: true,
    triggerRules: [{ code: 'B2', type: 'manual' }]
  },
  {
    role: 'customer',
    time: '2025-12-01 14:26:55',
    content: '我要投诉！你们这样泄露我的个人信息太不合适了！',
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
    ruleCode: 'B2',
    ruleDesc: '（客服在通话中完整念出客户身份证号码、电话号码、银行卡号、账户余额、住址、工作单位等敏感个人信息，严重违反客户信息保密规定，构成一级缺陷。）',
    dialogContent: '好的，这边看到您在我行预留的身份证号码是 110101199001011234，电话号码是 13812345678...您的身份证后四位是 1234，银行卡号后六位是 789012，账户余额目前有 58000 元...您的住址是北京市朝阳区某某街道某某小区 1 号楼 2 单元 301 室，工作单位是某某科技有限公司',
    remark: '-'
  }
])

// 关键词识别结果（从对话数据中提取 type 为'keyword'的规则）
const keywordResults = computed(() => {
  const results: any[] = []
  const ruleMap = new Map<string, any>()
  
  conversationList.value.forEach(msg => {
    if (msg.triggerRules && msg.triggerRules.length > 0) {
      msg.triggerRules.forEach((rule: any) => {
        if (rule.type === 'keyword' && !ruleMap.has(rule.code)) {
          ruleMap.set(rule.code, {
            ruleCode: rule.code,
            ruleDesc: getRuleDescription(rule.code),
            dialogContent: msg.content,
            remark: msg.remark || '-'
          })
        }
      })
    }
  })
  
  return Array.from(ruleMap.values())
})

// 人工审核结果（展示所有来源：AI、关键词、人工标注）
const manualResults = computed(() => {
  const results: any[] = []
  const ruleMap = new Map<string, any>()
  
  conversationList.value.forEach(msg => {
    if (msg.triggerRules && msg.triggerRules.length > 0) {
      msg.triggerRules.forEach((rule: any) => {
        if (!ruleMap.has(rule.code)) {
          ruleMap.set(rule.code, {
            ruleCode: rule.code,
            ruleDesc: getRuleDescription(rule.code),
            dialogContent: msg.content,
            remark: msg.remark || '-',
            sourceType: rule.type
          })
        }
      })
    }
  })
  
  return Array.from(ruleMap.values())
})

// 获取规则描述
const getRuleDescription = (ruleCode: string): string => {
  const descriptions: Record<string, string> = {
    'A1': '产品利率、产品收益、产品有效期等相关信息讲解错误。',
    'A2': '相关提醒不完整，遗漏、错误；',
    'A3': '客户咨询产品利率、收益、有效期等问题时未正面回答客户相关问题；',
    'B1': '未确认客户身份直接进行业务营销（客户表示为非本人，坐席仍进行营销）',
    'B2': '念出客户的全部身份证号码、电话号码、或资产情况等'
  }
  return descriptions[ruleCode] || ''
}

// 获取来源类型标签
const getSourceTypeLabel = (type?: string): string => {
  if (!type) return '未知'
  if (type === 'ai') return '🤖 AI 识别'
  if (type === 'keyword') return '🔑 关键词识别'
  if (type === 'manual') return '✏️ 人工标注'
  return '未知'
}

// 质检规则列表弹窗引用
const qualityRuleListRef = ref()

// 查看质检规则
const viewQualityRules = () => {
  if (qualityRuleListRef.value) {
    qualityRuleListRef.value.open()
  }
}

// 获取规则类型图标
const getRuleTypeIcon = (type?: string): string => {
  if (!type) return ''
  if (type === 'ai') return '🤖'
  if (type === 'keyword') return '🔑'
  if (type === 'manual') return '✏️'
  return ''
}

// 获取规则类型颜色
const getRuleTypeColor = (type?: string): string => {
  if (!type) return 'orange'
  if (type === 'ai') return 'blue'
  if (type === 'keyword') return 'green'
  if (type === 'manual') return 'purple'
  return 'orange'
}

// 获取规则类型标签
const getRuleTypeLabel = (type?: string): string => {
  if (!type) return '未知来源'
  if (type === 'ai') return 'AI 识别'
  if (type === 'keyword') return '关键词识别'
  if (type === 'manual') return '人工标注'
  return '未知来源'
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
    selectedMessage.value.triggerRules = selectedRules.value.map(code => ({ code, type: 'manual' }))
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
  isApproved.value = true
  message.success('人工审核结果已保存')
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
  flex-wrap: wrap;
}

.trigger-label {
  font-size: 12px;
  color: #fa8c16;
  flex-shrink: 0;
}

.rule-tag {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.rule-type-icon {
  font-size: 12px;
}

/* AI 识别 - 蓝色 */
.rule-tag-ai {
  background-color: #e6f4ff;
  border: 1px solid #91caff;
  color: #0958d9;
}

/* 关键词识别 - 绿色 */
.rule-tag-keyword {
  background-color: #f6ffed;
  border: 1px solid #b7eb8f;
  color: #237804;
}

/* 人工标注 - 紫色 */
.rule-tag-manual {
  background-color: #f9f0ff;
  border: 1px solid #d3adf7;
  color: #642ab5;
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

/* 关键词识别结果列表 */
.keyword-result-list {
  height: 100%;
  overflow-y: auto;
  padding: 20px 24px;
}

/* 人工审核结果列表 */
.manual-result-list {
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
  flex-wrap: wrap;
}

.rule-label {
  color: #8f959e;
  flex-shrink: 0;
}

.rule-code {
  font-weight: 500;
  color: #1f2329;
}

.rule-type-badge {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: 500;
}

/* AI 识别 - 蓝色 */
.rule-type-ai {
  background-color: #e6f4ff;
  color: #0958d9;
}

/* 关键词识别 - 绿色 */
.rule-type-keyword {
  background-color: #f6ffed;
  color: #237804;
}

/* 人工标注 - 紫色 */
.rule-type-manual {
  background-color: #f9f0ff;
  color: #642ab5;
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
  padding: 2px 6px;
  border-radius: 2px;
  font-weight: 500;
  border: 1px solid #faad14;
  transition: all 0.2s;
}

.highlight-keyword:hover {
  background-color: #ffec3d;
  cursor: pointer;
}

/* 已审核印章 */
.approved-stamp {
  position: absolute;
  top: 80px;
  right: 40px;
  z-index: 100;
  animation: stamp-in 0.3s ease-out;
  pointer-events: none;
}

@keyframes stamp-in {
  0% {
    transform: scale(2) rotate(-15deg);
    opacity: 0;
  }
  50% {
    transform: scale(1.1) rotate(-5deg);
    opacity: 0.8;
  }
  100% {
    transform: scale(1) rotate(-10deg);
    opacity: 1;
  }
}

.stamp-content {
  display: flex;
  align-items: center;
  justify-content: center;
}

.stamp-circle {
  width: 100px;
  height: 100px;
  border: 4px solid #ff4d4f;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  background: rgba(255, 77, 79, 0.05);
  transform: rotate(-10deg);
}

.stamp-circle::before {
  content: '';
  position: absolute;
  width: 88px;
  height: 88px;
  border: 2px dashed rgba(255, 77, 79, 0.5);
  border-radius: 50%;
}

.stamp-text {
  font-size: 28px;
  font-weight: bold;
  color: #ff4d4f;
  text-shadow: 0 0 2px rgba(255, 77, 79, 0.3);
  letter-spacing: 4px;
  writing-mode: horizontal-tb;
}
</style>

<style>
/* 关键词高亮 - 全局样式，因为 v-html 内容不受 scoped 影响 */
.highlight-keyword {
  background-color: #fff566;
  color: #000;
  padding: 2px 6px;
  border-radius: 2px;
  font-weight: 500;
  border: 1px solid #faad14;
  transition: all 0.2s;
}

.highlight-keyword:hover {
  background-color: #ffec3d;
  cursor: pointer;
}

/* 已审核印章 - 全局样式 */
.approved-stamp {
  position: absolute;
  top: 80px;
  right: 40px;
  z-index: 100;
  animation: stamp-in 0.3s ease-out;
  pointer-events: none;
}

@keyframes stamp-in {
  0% {
    transform: scale(2) rotate(-15deg);
    opacity: 0;
  }
  50% {
    transform: scale(1.1) rotate(-5deg);
    opacity: 0.8;
  }
  100% {
    transform: scale(1) rotate(-10deg);
    opacity: 1;
  }
}

.stamp-content {
  display: flex;
  align-items: center;
  justify-content: center;
}

.stamp-circle {
  width: 100px;
  height: 100px;
  border: 4px solid #ff4d4f;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  background: rgba(255, 77, 79, 0.05);
  transform: rotate(-10deg);
}

.stamp-circle::before {
  content: '';
  position: absolute;
  width: 88px;
  height: 88px;
  border: 2px dashed rgba(255, 77, 79, 0.5);
  border-radius: 50%;
}

.stamp-text {
  font-size: 28px;
  font-weight: bold;
  color: #ff4d4f;
  text-shadow: 0 0 2px rgba(255, 77, 79, 0.3);
  letter-spacing: 4px;
  writing-mode: horizontal-tb;
}
</style>
