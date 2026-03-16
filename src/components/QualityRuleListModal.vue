<template>
  <a-modal
    v-model:open="visible"
    title="质检规则列表"
    class="quality-rule-list-modal"
    :width="1000"
    :footer="null"
  >
    <div class="rule-list-content">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <a-input
          v-model:value="searchKeyword"
          placeholder="请输入规则编号/名称/说明搜索"
          allow-clear
          style="width: 300px"
          @press-enter="handleSearch"
        >
          <template #prefix>
            <SearchOutlined />
          </template>
        </a-input>
        <a-select
          v-model:value="selectedModel"
          placeholder="请选择质检模型"
          allow-clear
          style="width: 200px"
          margin-left="12px"
        >
          <a-select-option :value="1">合规质检</a-select-option>
          <a-select-option :value="2">营销意向</a-select-option>
          <a-select-option :value="3">投诉倾向</a-select-option>
          <a-select-option :value="4">合规质检（人工）</a-select-option>
        </a-select>
      </div>

      <!-- 规则列表 -->
      <div class="rule-list">
        <a-card
          v-for="rule in filteredRules"
          :key="rule.id"
          class="rule-card"
          :class="{ 'highlighted': highlightedRuleCode === rule.ruleCode }"
          @click="highlightRule(rule.ruleCode)"
        >
          <div class="rule-header">
            <div class="rule-code-badge">{{ rule.ruleCode }}</div>
            <div class="rule-name">{{ rule.ruleName }}</div>
            <a-tag color="blue">{{ rule.qualityModelName }}</a-tag>
          </div>
          <div class="rule-description">{{ rule.ruleDescription }}</div>
          <div class="rule-keywords">
            <span class="keywords-label">关键词：</span>
            <div class="keywords-list">
              <a-tag
                v-for="(keyword, index) in rule.keywordsArray"
                :key="index"
                size="small"
                class="keyword-tag"
              >
                {{ keyword }}
              </a-tag>
            </div>
          </div>
        </a-card>
      </div>

      <!-- 空状态 -->
      <a-empty v-if="filteredRules.length === 0" description="暂无质检规则" />
    </div>
  </a-modal>
</template>

<script setup lang="ts">
import { ref, reactive, computed, defineExpose } from 'vue'
import { SearchOutlined } from '@ant-design/icons-vue'

// 弹窗显示状态
const visible = ref(false)

// 高亮的规则编号
const highlightedRuleCode = ref<string>('')

// 搜索关键词
const searchKeyword = ref('')

// 选中的质检模型
const selectedModel = ref<number | undefined>(undefined)

// 质检规则数据
const ruleList = ref([
  {
    id: 1,
    ruleCode: 'A1',
    ruleName: '产品介绍错误',
    ruleDescription: '产品利率、产品收益、产品有效期等相关信息讲解错误。',
    qualityModelId: 1,
    qualityModelName: '合规质检',
    keywordsArray: ['利率', '收益率', '年化', '有效期', '起息日', '到期日', '保本', '无风险', '稳赚', '利息', '收益', '费率', '手续费', '提前支取', '罚息', '违约金']
  },
  {
    id: 2,
    ruleCode: 'A2',
    ruleName: '提醒不全',
    ruleDescription: '相关提醒不完整，遗漏、错误；',
    qualityModelId: 1,
    qualityModelName: '合规质检',
    keywordsArray: ['风险提示', '风险等级', '本金损失', '投资有风险', '谨慎投资', '仔细阅读', '条款', '免责', '免责声明', '重要提示', '请注意', '务必', '确认', '知晓', '理解']
  },
  {
    id: 3,
    ruleCode: 'A3',
    ruleName: '未正面回答',
    ruleDescription: '客户咨询产品利率、收益、有效期等问题时未正面回答客户相关问题；',
    qualityModelId: 1,
    qualityModelName: '合规质检',
    keywordsArray: ['这个我不清楚', '需要查询', '稍后回复', '问一下领导', '咨询一下', '回头告诉您', '不太确定', '可能', '应该', '大概', '也许', '说不准', '不方便透露', '公司规定', '不能说的']
  },
  {
    id: 4,
    ruleCode: 'B1',
    ruleName: '未确认客户身份',
    ruleDescription: '未确认客户身份直接进行业务营销（客户表示为非本人，坐席仍进行营销）',
    qualityModelId: 4,
    qualityModelName: '合规质检（人工）',
    keywordsArray: ['请问您是', '本人吗', '确认一下身份', '您是 xxx 吗', '核对信息', '身份验证', '请问怎么称呼', '先生/女士', '您的姓名', '身份证', '手机号', '不是本人', '我是代接', '我是家属', '我是朋友', '我是同事']
  },
  {
    id: 5,
    ruleCode: 'B2',
    ruleName: '全部信息透露给客户',
    ruleDescription: '念出客户的全部身份证号码、电话号码、或资产情况等',
    qualityModelId: 4,
    qualityModelName: '合规质检（人工）',
    keywordsArray: ['身份证号码', '身份证号', '电话号码', '手机号', '银行卡号', '卡号', '账户余额', '资产', '存款', '理财金额', '投资金额', '您的尾号', '后四位', '前六位', '住址', '地址', '工作单位', '单位地址', '职业', '收入']
  }
])

// 过滤后的规则列表
const filteredRules = computed(() => {
  let result = ruleList.value

  // 按关键词搜索
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(rule =>
      rule.ruleCode.toLowerCase().includes(keyword) ||
      rule.ruleName.toLowerCase().includes(keyword) ||
      rule.ruleDescription.toLowerCase().includes(keyword)
    )
  }

  // 按质检模型筛选
  if (selectedModel.value) {
    result = result.filter(rule => rule.qualityModelId === selectedModel.value)
  }

  return result
})

// 打开弹窗
const open = (highlightCode?: string) => {
  highlightedRuleCode.value = highlightCode || ''
  visible.value = true
}

// 关闭弹窗
const close = () => {
  visible.value = false
}

// 高亮规则
const highlightRule = (code: string) => {
  highlightedRuleCode.value = code
}

// 搜索
const handleSearch = () => {
  console.log('搜索规则:', searchKeyword.value)
}

// 暴露方法给父组件
defineExpose({
  open,
  close
})
</script>

<style scoped>
.quality-rule-list-modal :deep(.ant-modal-header) {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.quality-rule-list-modal :deep(.ant-modal-title) {
  font-size: 18px;
  font-weight: 500;
  color: #1f2329;
}

.quality-rule-list-modal :deep(.ant-modal-body) {
  padding: 24px;
  max-height: 700px;
  overflow-y: auto;
}

.rule-list-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 搜索栏 */
.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 8px;
}

/* 规则列表 */
.rule-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rule-card {
  cursor: pointer;
  transition: all 0.3s;
  border: 1px solid #e8e8e8;
}

.rule-card:hover {
  border-color: #1677ff;
  box-shadow: 0 2px 8px rgba(22, 119, 255, 0.15);
}

.rule-card.highlighted {
  border-color: #fa8c16;
  background-color: #fff7e6;
  box-shadow: 0 2px 8px rgba(250, 140, 22, 0.2);
}

.rule-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.rule-code-badge {
  background: #1677ff;
  color: #fff;
  padding: 4px 12px;
  border-radius: 4px;
  font-weight: 600;
  font-size: 14px;
}

.rule-name {
  font-size: 16px;
  font-weight: 500;
  color: #1f2329;
  flex: 1;
}

.rule-description {
  font-size: 14px;
  color: #595959;
  margin-bottom: 12px;
  line-height: 1.6;
  padding: 12px;
  background: #f5f5f5;
  border-radius: 4px;
}

.rule-keywords {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.keywords-label {
  font-size: 13px;
  color: #8f959e;
  flex-shrink: 0;
  padding-top: 4px;
}

.keywords-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  flex: 1;
}

.keyword-tag {
  font-size: 12px;
  background: #f0f5ff;
  border-color: #d6e4ff;
  color: #1677ff;
}

.keyword-tag:hover {
  background: #e6f4ff;
}
</style>
