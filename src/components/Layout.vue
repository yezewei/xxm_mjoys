<template>
  <div class="layout">
    <!-- 顶部菜单 -->
    <header class="header">
      <div class="header-left">
        <img src="/system_demo/logo.png" alt="AI 直营平台" class="logo-img" />
        <div class="page-title">{{ pageTitle }}</div>
      </div>
      <div class="header-right">
        <!-- 软电话连接状态 -->
        <a-popover placement="bottomRight" trigger="click">
          <template #content>
            <div class="soft-phone-info">
              <div class="info-item">
                <span class="info-label">分机号：</span>
                <span class="info-value">{{ softPhoneInfo.extension }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">本机IP：</span>
                <span class="info-value">{{ softPhoneInfo.ip }}</span>
              </div>
              <div v-if="!softPhoneConnected" class="info-item">
                <span class="info-label">失败原因：</span>
                <span class="info-value error">{{ softPhoneInfo.failReason }}</span>
              </div>
              <div v-if="!softPhoneConnected" class="info-item">
                <a class="troubleshoot-link" @click="openTroubleshootModal">查看排查步骤</a>
              </div>
            </div>
          </template>
          <div class="soft-phone-status" :class="{ 'connected': softPhoneConnected }">
            <PhoneOutlined />
            <span class="status-text">{{ softPhoneConnected ? '小象通已连接' : '小象通连接失败' }}</span>
          </div>
        </a-popover>
        <a-dropdown>
          <a class="header-action">帮助中心</a>
          <template #overlay>
            <a-menu @click="handleHelpMenuClick">
              <a-menu-item key="help-manual">帮助手册</a-menu-item>
              <a-menu-item key="faq">常见QA</a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
        <a class="header-action">上传任务</a>
        <a class="header-action">下载任务</a>
        <a-badge class="header-action" count="9" size="small">
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
          <span class="user-name">叶泽伟</span>
        </div>
      </div>
    </header>

    <!-- 小象通排查弹窗 -->
    <a-modal
      v-model:open="troubleshootModalVisible"
      title="小象通连接失败排查"
      @cancel="closeTroubleshootModal"
      :footer="null"
      width="600px"
    >
      <div class="troubleshoot-content">
        <div class="troubleshoot-section">
          <div class="section-title">问题描述：</div>
          <div class="section-desc">{{ troubleshootData.problem }}</div>
        </div>
        <div class="troubleshoot-section">
          <div class="section-title">可能原因：</div>
          <ul class="cause-list">
            <li v-for="(cause, index) in troubleshootData.causes" :key="index">{{ cause }}</li>
          </ul>
        </div>
        <div class="troubleshoot-section">
          <div class="section-title">排查步骤：</div>
          <ol class="step-list">
            <li v-for="(step, index) in troubleshootData.steps" :key="index">{{ step }}</li>
          </ol>
        </div>
      </div>
    </a-modal>

    <!-- 常见QA弹窗 -->
    <a-modal
      v-model:open="faqModalVisible"
      :title="currentFaq ? currentFaq.question : '常见问题排查'"
      @cancel="closeFaqModal"
      :footer="null"
      width="600px"
    >
      <div v-if="currentFaq" class="faq-modal-content">
        <div class="faq-back" @click="currentFaq = null">
          <LeftOutlined />
          <span>返回列表</span>
        </div>
        <div class="faq-section">
          <div class="section-title">可能原因：</div>
          <ul class="faq-list-items">
            <li v-for="(cause, index) in currentFaq.possibleCauses" :key="index">{{ cause }}</li>
          </ul>
        </div>
        <div class="faq-section">
          <div class="section-title">排查方案：</div>
          <ol class="faq-list-items solutions">
            <li v-for="(solution, index) in currentFaq.solutions" :key="index">{{ solution }}</li>
          </ol>
        </div>
      </div>
      <div v-else class="faq-list">
        <a-input-search
          v-model:value="faqSearchKey"
          placeholder="搜索问题"
          style="margin-bottom: 16px"
          allow-clear
        />
        <div
          v-for="(faq, index) in filteredFaqList"
          :key="index"
          class="faq-item"
          @click="currentFaq = faq"
        >
          <QuestionCircleOutlined class="faq-icon" />
          <span class="faq-question">{{ faq.question }}</span>
          <RightOutlined class="faq-arrow" />
        </div>
        <a-empty v-if="filteredFaqList.length === 0" description="未找到相关问题" />
      </div>
    </a-modal>

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
            <a-menu-item key="quality-rule">
              <span>质检规则</span>
            </a-menu-item>
            <a-menu-item key="sampling-rule">
              <span>抽检规则</span>
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

          <a-sub-menu key="customer">
            <template #title>
              <span>客户中心</span>
            </template>
            <a-menu-item key="customer-management">
              <span>客户管理</span>
            </a-menu-item>
            <a-menu-item key="customer-tag-management">
              <span>客户标签管理</span>
            </a-menu-item>
            <a-menu-item key="customer-group-management">
              <span>客群管理</span>
            </a-menu-item>
          </a-sub-menu>

          <a-menu-item key="data-lake">
            <span>数据湖</span>
          </a-menu-item>

          <a-sub-menu key="data-board-group">
            <template #title>
              <span>数据看板</span>
            </template>
            <a-menu-item key="data-board">
              <span>数据看板</span>
            </a-menu-item>
            <a-menu-item key="ai-call-report">
              <span>AI 外呼报表</span>
            </a-menu-item>
            <a-menu-item key="ai-call-record">
              <span>AI 外呼记录</span>
            </a-menu-item>
            <a-menu-item key="manual-call-report">
              <span>人工通信接口外呼记录</span>
            </a-menu-item>
            <a-menu-item key="manual-call-record">
              <span>人工外呼记录</span>
            </a-menu-item>
            <a-menu-item key="call-funnel">
              <span>外呼漏斗图</span>
            </a-menu-item>
          </a-sub-menu>

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
import { UserOutlined, PhoneOutlined, QuestionCircleOutlined, RightOutlined, LeftOutlined } from '@ant-design/icons-vue';

const route = useRoute();
const router = useRouter();
const selectedKeys = ref(['exception']);
const openKeys = ref<string[]>([]);

// 软电话连接状态
const softPhoneConnected = ref(false)
const softPhoneInfo = ref({
  extension: '1001',
  ip: '192.168.1.100',
  failReason: 'SIP服务器连接超时'
})

// 排查弹窗状态
const troubleshootModalVisible = ref(false)
const troubleshootData = ref({
  problem: '小象通软电话无法连接到SIP服务器，导致坐席无法正常接听和拨打电话',
  causes: [
    '网络连接异常或防火墙拦截',
    'SIP服务器地址或端口配置错误',
    '小象通客户端版本过旧',
    '本地SIP端口被其他程序占用',
    '账号或密码认证失败'
  ],
  steps: [
    '检查网络连接是否正常，尝试ping SIP服务器地址',
    '确认SIP服务器地址和端口配置是否正确（默认端口5060）',
    '检查防火墙设置，确保放行SIP相关端口（UDP 5060-5080）',
    '关闭可能占用SIP端口的其他程序（如其他软电话）',
    '更新小象通客户端到最新版本',
    '重新输入账号密码进行认证',
    '联系管理员确认SIP服务是否正常运行'
  ]
})

const openTroubleshootModal = () => {
  troubleshootModalVisible.value = true
}

const closeTroubleshootModal = () => {
  troubleshootModalVisible.value = false
}

// 常见QA数据
interface FaqItem {
  question: string
  possibleCauses: string[]
  solutions: string[]
}

const faqList = ref<FaqItem[]>([
  {
    question: '接起电话后，AI还在说话，两边声音重叠',
    possibleCauses: [
      'AI转人工时，AI的话还没完全说完，坐席这边已经接起来了，两边音频没切换好',
      '系统切换音频流时卡了一下，导致AI没有立即闭嘴'
    ],
    solutions: [
      '先别挂，等几秒看AI会不会自己停，有时只是偶发卡顿',
      '如果频繁发生，记下是哪个场景、哪通电话、几点发生的，报给组长，让他们查后台日志',
      '不要自己尝试调配置，这个你调不了，直接上报'
    ]
  },
  {
    question: '坐席听不到客户声音，客户说话没人回应',
    possibleCauses: [
      '耳机没插好、麦克风被静音了，或者电脑没给软电话权限',
      '网络不好，声音数据包没传过来',
      '系统音频设备选错了（比如选了别的声卡）'
    ],
    solutions: [
      '先听系统里的通话录音——如果录音里双方声音都正常，说明问题在你自己这边；如果录音里也没有客户声音，问题在系统或线路',
      '检查耳机插头是否松动，换个USB口试试',
      '看电脑右下角音量图标，点开"合成器"，找到小象通，确认没有被静音',
      '检查Windows麦克风权限：设置→隐私→麦克风→允许小象通使用',
      '如果以上都正常，重启小象通软电话再试',
      '如果还是不行，立即报修，并说明是"单向无声，录音正常/不正常"'
    ]
  },
  {
    question: '软电话挂不断，客户一直处于等待状态',
    possibleCauses: [
      '软电话程序卡死了，或者网络闪断了一下，导致"挂断"信号没发出去',
      '系统认为通话还在，但你的界面已经没反应了'
    ],
    solutions: [
      '先点工作台上的"挂断"按钮，如果没反应，直接按Ctrl+Alt+Delete打开任务管理器，强制结束小象通进程',
      '强制关闭后，系统会在几十秒内自动释放这条通话，客户不会被一直占线',
      '如果这种情况每周出现2次以上，联系组长帮你重装软电话或检查网络'
    ]
  },
  {
    question: '人机协呼时，客户电话已接通，但坐席页面没弹窗',
    possibleCauses: [
      '你当前状态不是"在线"（忙碌或离线都不会弹）',
      '你开了"自动接听"功能，开了就不弹窗，直接接通，这是正常的',
      '浏览器把工作台页面的通知给屏蔽了',
      '工作台页面在后台标签页，浏览器限制了弹出'
    ],
    solutions: [
      '确认坐席状态是"在线"',
      '打开小象通设置，看看是否勾选了"自动接听"——如果勾了，不弹窗是正常的，直接接听就行',
      '把浏览器工作台页面切到前台，别放在后台',
      '浏览器地址栏左侧有个锁图标，点它→网站设置→通知，设为"允许"',
      '如果以上都正常但还是不弹，联系组长帮你查后台配置'
    ]
  },
  {
    question: '客户明明在说话，系统却判定为静音，提前挂断或重复话术',
    possibleCauses: [
      '客户声音太小，或者背景太吵，系统"耳朵"不太好使，以为没人说话',
      '客户网络不好，声音断断续续，系统以为没声音'
    ],
    solutions: [
      '先听通话录音，确认客户声音是否确实很小或听不清',
      '如果客户声音正常，记下该客户的号码和通话时间，报给组长，请他们适当延长"静音等待时长"',
      '如果同一号码段（比如某个地区）经常这样，可能跟线路有关，也一并上报'
    ]
  },
  {
    question: '批量短信发不出去，客户收不到',
    possibleCauses: [
      '短信余额用完了，或者短信通道临时出问题了',
      '客户号码在黑名单或免打扰名单里，被系统自动拦截了',
      '你用的短信模板还没审核通过，或者模板里的变量填错了',
      '短信内容太长，超字数了'
    ],
    solutions: [
      '登录后台，进"数据看板"→"短信发送记录"，看每条短信的状态，失败的话会写原因',
      '检查客户号码格式对不对（比如有没有漏掉+86）',
      '确认你选的短信模板是"已审核"状态，未审核的发不出去',
      '如果整批都失败，立即联系运营经理，可能是余额或通道问题'
    ]
  },
  {
    question: '部分客户漏收短信，同一批有的人收到有的人没收到',
    possibleCauses: [
      '短信通道供应商那边有限流，瞬间发太多被拦截了一部分',
      '某些运营商（比如移动、联通）对特定号码有限制'
    ],
    solutions: [
      '看发送记录，失败的是不是集中在某个运营商（比如全是移动）或某个时间段',
      '把失败的号码单独拎出来再发一次试试',
      '如果多次重发还是失败，且失败比例超过5%，报给运营经理，让他们联系通道供应商或切换备用通道'
    ]
  },
  {
    question: '客户转接坐席时等待超时，被挂断',
    possibleCauses: [
      '你的状态不是"在线"，或者你同时接的电话数已满（意向上限），系统转不过来',
      '系统设置的等待时间太短（比如只等10秒）',
      '当时同时转接的客户太多，坐席不够用'
    ],
    solutions: [
      '确认自己状态是"在线"，且当前接听量没到上限（上限你看工作台有显示）',
      '如果你当时确实空闲，但仍然超时，那可能是系统等待时间设置太短——记录下时间点，报组长调整',
      '如果高峰时段频繁出现，说明坐席不够，组长需要协调增加人或调整转接比例'
    ]
  },
  {
    question: '高峰时段新客户电话打不出去，因为线路被重呼、三呼占满',
    possibleCauses: [
      '线路总共就那么多条，被反复呼叫未接客户的"重呼"任务占用了，新客户没线路可用'
    ],
    solutions: [
      '这个问题你个人解决不了，是线路容量问题',
      '你只需要记录高峰时段（比如上午10-11点）有多少个新客户没打出去，报给组长',
      '组长会决定是否调整重呼时段（比如把重呼挪到下午）或者申请扩容线路'
    ]
  },
  {
    question: '坐席看不到客户全名，无法正确称呼',
    possibleCauses: [
      '银行规定要保护客户隐私，所以系统对姓名做了脱敏处理（比如只显示"张*"）',
      '你的账号权限不够，看不到全名'
    ],
    solutions: [
      '先接受这个规则，称呼对方为"张先生/女士"即可，不会出错',
      '如果确实有特殊客户（比如对公、VIP）需要全名，向组长提出申请，由组长找银行审批开通白名单',
      '不要试图自己绕过脱敏，这是合规要求，违规操作后果严重'
    ]
  }
])

// FAQ弹窗状态
const faqModalVisible = ref(false)
const currentFaq = ref<FaqItem | null>(null)
const faqSearchKey = ref('')

const filteredFaqList = computed(() => {
  if (!faqSearchKey.value) return faqList.value
  return faqList.value.filter(faq => faq.question.includes(faqSearchKey.value))
})

const handleHelpMenuClick = ({ key }: { key: string }) => {
  if (key === 'faq') {
    currentFaq.value = null
    faqSearchKey.value = ''
    faqModalVisible.value = true
  }
}

const closeFaqModal = () => {
  faqModalVisible.value = false
  currentFaq.value = null
}

// 菜单项与路由的映射
const menuRouteMap: Record<string, string> = {
  home: '/',
  exception: '/exception',
  'role-management': '/role-management',
  'ai-call-report': '/ai-call-report',
  'ai-call-record': '/ai-call-record',
  'data-board': '/data-board',
  'manual-call-report': '/manual-call-report',
  'manual-call-record': '/manual-call-record',
  'call-funnel': '/call-funnel',
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
  'quality-rule': '/quality-rule',
  'sampling-rule': '/sampling-rule',
  'seat-config': '/seat-config',
  'seat-monitor': '/seat-monitor',
  'skill-group': '/skill-group',
  'knowledge-word': '/knowledge-word',
  'knowledge-intent': '/knowledge-intent',
  'knowledge-qa': '/knowledge-qa',
  'knowledge-scene': '/knowledge-scene',
  'customer-management': '/customer-management',
  'customer-tag-management': '/customer-tag-management',
  'customer-group-management': '/customer-group-management',
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
  'quality-rule': '质检规则',
  'sampling-rule': '抽检规则',
  seat: '坐席管理',
  'seat-config': '直营坐席配置',
  'seat-monitor': '坐席监控',
  'skill-group': '技能组管理',
  knowledge: '内置知识管理',
  'knowledge-word': '内置词库',
  'knowledge-intent': '内置意图',
  'knowledge-qa': '内置 QA',
  'knowledge-scene': '场景知识库',
  customer: '客户中心',
  'customer-management': '客户管理',
  'customer-tag-management': '客户标签管理',
  'customer-group-management': '客群管理',
  'data-lake': '数据湖',
  'data-board': '数据看板',
  'data-board-group': '数据看板',
  'ai-call-report': 'AI 外呼报表',
  'ai-call-record': 'AI 外呼记录',
  'manual-call-report': '人工通信接口外呼记录',
  'manual-call-record': '人工外呼记录',
  'call-funnel': '外呼漏斗图',
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
      '/quality-rule': 'quality-rule',
      '/sampling-rule': 'sampling-rule',
      '/seat-config': 'seat-config',
      '/seat-monitor': 'seat-monitor',
      '/skill-group': 'skill-group',
      '/knowledge-word': 'knowledge-word',
      '/knowledge-intent': 'knowledge-intent',
      '/knowledge-qa': 'knowledge-qa',
      '/knowledge-scene': 'knowledge-scene',
      '/customer-management': 'customer-management',
      '/customer-tag-management': 'customer-tag-management',
      '/customer-group-management': 'customer-group-management',
      '/data-lake': 'data-lake',
      '/data-board': 'data-board',
      '/ai-call-report': 'ai-call-report',
      '/ai-call-record': 'ai-call-record',
      '/manual-call-report': 'manual-call-report',
      '/manual-call-record': 'manual-call-record',
      '/call-funnel': 'call-funnel',
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
    // 自动展开父级子菜单
    const subMenuChildren: Record<string, string[]> = {
      'data-board-group': ['data-board', 'ai-call-report', 'ai-call-record', 'manual-call-report', 'manual-call-record', 'call-funnel'],
      business: ['scene-management', 'scene-template', 'org-management', 'workbench-settings'],
      'phone-work': ['phone-work-home', 'phone-work-workbench'],
      'quality-inspection': ['quality-home', 'quality-workbench', 'quality-model', 'quality-task', 'quality-rule', 'sampling-rule'],
      seat: ['seat-config', 'seat-monitor', 'skill-group'],
      knowledge: ['knowledge-word', 'knowledge-intent', 'knowledge-qa', 'knowledge-scene'],
      customer: ['customer-management', 'customer-tag-management', 'customer-group-management'],
      engineering: ['global-service', 'system-security', 'device-management', 'system-monitor', 'route-settings'],
      'data-engine': ['app-management', 'task-management', 'write-off', 'schedule-log', 'external-integration', 'data-market'],
      platform: ['role-management', 'bank-account', 'platform-account', 'operation-log', 'menu-management'],
    };
    for (const [parentKey, children] of Object.entries(subMenuChildren)) {
      if (children.includes(key) && !openKeys.value.includes(parentKey)) {
        openKeys.value.push(parentKey);
      }
    }
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

/* 软电话连接状态 */
.soft-phone-status {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 16px;
  background: #fff2f0;
  border: 1px solid #ffccc7;
  cursor: pointer;
  transition: all 0.3s;
  font-size: 13px;
  color: #ff4d4f;
}

.soft-phone-status.connected {
  background: #f6ffed;
  border-color: #b7eb8f;
  color: #52c41a;
}

.soft-phone-status:hover {
  opacity: 0.8;
}

.status-text {
  font-weight: 500;
}

.soft-phone-info {
  min-width: 180px;
}

.info-item {
  display: flex;
  align-items: center;
  padding: 8px 0;
}

.info-item:first-child {
  padding-top: 0;
}

.info-item:last-child {
  padding-bottom: 0;
}

.info-label {
  color: rgba(0, 0, 0, 0.45);
  font-size: 13px;
  min-width: 60px;
}

.info-value {
  color: rgba(0, 0, 0, 0.85);
  font-size: 13px;
  font-weight: 500;
}

.info-value.error {
  color: #ff4d4f;
}

.troubleshoot-link {
  color: #1890ff;
  cursor: pointer;
  font-size: 13px;
}

.troubleshoot-link:hover {
  color: #40a9ff;
}

/* 排查弹窗内容 */
.troubleshoot-content {
  padding: 8px 0;
}

.troubleshoot-section {
  margin-bottom: 20px;
}

.troubleshoot-section:last-child {
  margin-bottom: 0;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: rgba(0, 0, 0, 0.85);
  margin-bottom: 12px;
}

.section-desc {
  font-size: 13px;
  color: rgba(0, 0, 0, 0.65);
  line-height: 1.8;
}

.cause-list,
.step-list {
  margin: 0;
  padding-left: 20px;
}

.cause-list li,
.step-list li {
  font-size: 13px;
  color: rgba(0, 0, 0, 0.65);
  line-height: 1.8;
  margin-bottom: 4px;
}

.step-list li {
  margin-bottom: 8px;
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
  position: fixed;
  left: 0;
  top: 64px;
  z-index: 10;
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
  margin-left: 220px;
  padding: 12px;
  background: #fff;
  height: calc(100vh - 64px);
  overflow-y: auto;
}

/* FAQ样式 */
.faq-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.faq-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.faq-item:hover {
  background: #f5f5f5;
  border-color: #d9d9d9;
}

.faq-icon {
  color: #1890ff;
  margin-right: 12px;
  font-size: 16px;
}

.faq-question {
  flex: 1;
  font-size: 14px;
  color: #333;
}

.faq-arrow {
  color: #999;
  font-size: 12px;
}

.faq-modal-content {
  padding: 8px 0;
}

.faq-back {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #1890ff;
  cursor: pointer;
  margin-bottom: 16px;
  font-size: 14px;
}

.faq-back:hover {
  color: #40a9ff;
}

.faq-section {
  margin-bottom: 20px;
}

.faq-section:last-child {
  margin-bottom: 0;
}

.faq-section .section-title {
  font-weight: 600;
  font-size: 14px;
  color: #333;
  margin-bottom: 8px;
}

.faq-list-items {
  padding-left: 20px;
  margin: 0;
}

.faq-list-items li {
  font-size: 14px;
  color: #666;
  line-height: 1.8;
}

.faq-list-items.solutions {
  list-style-type: decimal;
}
</style>
