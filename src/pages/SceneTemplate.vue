<template>
  <div class="scene-template">
    <a-row :gutter="[16, 0]">
      <!-- 左侧菜单栏 -->
      <a-col :span="4" class="left-menu-col">
        <div class="left-menu">
          <!-- 全部选项 -->
          <div
            :class="['menu-all-item', { active: selectedSubItem === '全部' }]"
            @click="handleSubItemClick('全部')"
          >
            全部
          </div>
          <div
            v-for="(category, index) in menuCategories"
            :key="index"
            class="menu-category"
          >
            <div
              class="menu-category-title"
              @click="toggleCategory(index)"
            >
              <span class="category-name">{{ category.name }}</span>
              <DownOutlined :class="{ 'menu-arrow-down': category.expanded }" />
            </div>
            <div v-if="category.expanded" class="menu-sub-items">
              <div
                v-for="subItem in category.items"
                :key="subItem"
                :class="['menu-sub-item', { active: selectedSubItem === subItem }]"
                @click="handleSubItemClick(subItem)"
              >
                {{ subItem }}
              </div>
            </div>
          </div>
        </div>
      </a-col>

      <!-- 右侧内容区 -->
      <a-col :span="20" class="right-content-col">
        <!-- 顶部标签筛选 -->
        <div class="tab-section">
          <a-tabs v-model:activeKey="activeTab" @change="handleTabChange">
            <a-tab-pane key="all" tab="全部" />
            <a-tab-pane key="sms" tab="短信跟进" />
            <a-tab-pane key="manual" tab="人工跟进" />
            <a-tab-pane key="sms+manual" tab="短信 + 人工跟进" />
            <a-tab-pane key="other" tab="其他" />
          </a-tabs>
        </div>

        <!-- 搜索区域 -->
        <div class="search-area">
          <a-space>
            <a-input
              v-model:value="searchKeyword"
              placeholder="请输入场景名称搜索"
              style="width: 320px"
              @press-enter="handleSearch"
            />
            <a-button type="primary" @click="handleSearch">搜索</a-button>
            <a-button @click="handleReset">重置</a-button>
            <a-button type="primary" class="create-btn" @click="handleCreate">
              <plus-outlined />
              新建场景模板
            </a-button>
          </a-space>
        </div>

        <!-- 卡片列表 -->
        <div class="card-list">
          <a-row :gutter="[16, 16]">
            <a-col
              v-for="item in dataSource"
              :key="item.id"
              :xs="24"
              :sm="12"
              :md="8"
              :lg="8"
              :xl="8"
            >
              <a-card class="template-card" :bordered="false">
                <div class="card-header">
                  <div class="card-title">{{ item.title }}</div>
                  <div class="card-tags">
                    <a-tag v-for="tag in item.tags" :key="tag" color="blue">
                      {{ tag }}
                    </a-tag>
                    <a class="card-detail" @click="handleDetail(item)">详情</a>
                  </div>
                </div>
                <div class="card-description">{{ item.description }}</div>
                <div class="card-stats">
                  已创建场景：<span class="stats-count">{{ item.sceneCount }}个</span>
                </div>
                <div class="card-actions">
                  <a class="action-item" @click="handleCreateScene(item)">创建场景</a>
                  <a class="action-item" @click="handleTemplateCheck(item)">模板检测</a>
                  <a class="action-item" @click="handleMore(item)">更多</a>
                </div>
              </a-card>
            </a-col>
          </a-row>
        </div>

        <!-- 分页 -->
        <div class="pagination-section">
          <a-pagination
            v-model:current="currentPage"
            v-model:page-size="pageSize"
            :total="total"
            show-size-changer
            show-quick-jumper
            :show-total="(total: number) => `共${total}记录`"
            :page-size-options="['10', '20', '50']"
            @change="handlePageChange"
            @show-size-change="handlePageSizeChange"
          />
        </div>
      </a-col>
    </a-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { PlusOutlined, DownOutlined } from '@ant-design/icons-vue';

interface TemplateItem {
  id: number;
  title: string;
  tags: string[];
  description: string;
  sceneCount: number;
  type?: string;
  category?: string;
}

interface MenuCategory {
  name: string;
  expanded: boolean;
  items: string[];
}

const activeTab = ref('all');
const searchKeyword = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(88);
const selectedSubItem = ref('');

// 左侧菜单分类数据
const menuCategories = reactive<MenuCategory[]>([
  {
    name: '存款',
    expanded: false,
    items: ['定期存款', '通知存款', '大额存单', '结构性存款', '存款到期提醒', '存款续存', '外币存款'],
  },
  {
    name: '理财',
    expanded: false,
    items: ['活期理财', '持有期型理财', '定期开放式理财', '封闭式理财', '开放式/每日可申赎理财', '理财服务开通', '外币理财'],
  },
  {
    name: '资产提升',
    expanded: false,
    items: ['月日均资产提升', '余额资产提升', '资产提升 + 理财', '资产提升 + 存款'],
  },
  {
    name: '信用卡',
    expanded: false,
    items: [
      '信用卡开卡',
      '信用卡激活',
      '信用卡促活',
      '信用卡账单分期',
      '信用卡消费分期',
      '信用卡现金分期',
      '信用卡快捷支付绑卡',
      '信用卡第三方绑卡',
      '信用卡装修分期',
      '信用卡自动还款',
    ],
  },
  {
    name: '借记卡',
    expanded: false,
    items: ['借记卡开卡', '借记卡促活', '借记卡换卡', '借记卡激活', '借记卡第三方绑卡', '借记卡快捷支付绑卡'],
  },
  {
    name: '贷款',
    expanded: false,
    items: ['个人信用贷款', '个人抵押贷款', '企业信用贷款', '企业抵押贷款', '贷款促支', '贷款续贷'],
  },
  {
    name: '手机银行',
    expanded: false,
    items: ['手机银行开通', '手机银行促活', '快捷支付活动', '手机银行功能介绍'],
  },
  {
    name: '数字人民币',
    expanded: false,
    items: ['数字人民币开通', '数字人民币促活'],
  },
  {
    name: '微信',
    expanded: false,
    items: ['企微加粉', '微信公众号'],
  },
  {
    name: '外汇',
    expanded: false,
    items: ['结汇/售汇', '跨境功能产品营销', '跨境活动营销'],
  },
  {
    name: '社保卡',
    expanded: false,
    items: ['社保卡开卡', '社保卡换卡', '社保卡激活'],
  },
  {
    name: '个人养老金',
    expanded: false,
    items: ['个人养老金开户', '个人养老金缴存', '个人养老金开户 + 缴存'],
  },
  {
    name: '对公业务',
    expanded: false,
    items: [
      '对公套餐签约',
      '对公开户',
      '企业手机银行促活',
      '对公促活',
      '企业手机银行开通',
      '企业网银开通',
      '会计对账',
      '对公资产提升',
      '商户活动',
    ],
  },
  {
    name: '保险',
    expanded: false,
    items: ['保险营销'],
  },
  {
    name: '基金',
    expanded: false,
    items: ['基金营销'],
  },
  {
    name: '证券',
    expanded: false,
    items: ['证券开户', '三方存管', '证券 APP 促活'],
  },
  {
    name: '贵金属',
    expanded: false,
    items: ['贵金属产品营销', '积存金'],
  },
  {
    name: '电子医保卡',
    expanded: false,
    items: ['电子医保申领', '电子医保激活'],
  },
  {
    name: '回访',
    expanded: false,
    items: ['开卡回访', '反诈骗回访', '活动回访', '调查问卷回访', '贷后回访', '满意度回访'],
  },
  {
    name: '催收',
    expanded: false,
    items: ['信用卡还款提醒', '信用卡逾期催收', '贷款还钱提醒', '贷款逾期催收'],
  },
  {
    name: '通知',
    expanded: false,
    items: ['一句话通知', '挽回式通知', '重听式通知', '一句话接通即转', '一句话转人工'],
  },
]);

const dataSource: TemplateItem[] = [
  {
    id: 1,
    title: '信用卡激活',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '用于短信下发后，再进行外呼。',
    sceneCount: 5,
    type: 'all',
    category: '信用卡激活',
  },
  {
    id: 2,
    title: '账户回访',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '成年版的开卡回访，无需跟进',
    sceneCount: 5,
    type: 'all',
    category: '开卡回访',
  },
  {
    id: 3,
    title: '信用卡换卡',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '信用卡到期换新卡',
    sceneCount: 5,
    type: 'all',
    category: '信用卡换卡',
  },
  {
    id: 4,
    title: '存款到期续存',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '定期存款到期后提醒转存',
    sceneCount: 5,
    type: 'all',
    category: '存款到期提醒',
  },
  {
    id: 5,
    title: '信用卡促活',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '用于短信下发后，再进行外呼。',
    sceneCount: 5,
    type: 'all',
    category: '信用卡促活',
  },
  {
    id: 6,
    title: '手机银行签到有礼',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '手机银行促活类',
    sceneCount: 5,
    type: 'all',
    category: '手机银行促活',
  },
];

// 切换分类展开/收起
const toggleCategory = (index: number) => {
  menuCategories[index].expanded = !menuCategories[index].expanded;
};

// 二级分类点击
const handleSubItemClick = (item: string) => {
  selectedSubItem.value = item;
  console.log('选择二级分类:', item);
};

// 标签切换
const handleTabChange = (key: string) => {
  activeTab.value = key;
  console.log('切换标签:', key);
};

// 搜索
const handleSearch = () => {
  console.log('搜索:', searchKeyword.value);
};

// 重置
const handleReset = () => {
  searchKeyword.value = '';
  handleSearch();
};

// 新建场景模板
const handleCreate = () => {
  console.log('新建场景模板');
};

// 查看详情
const handleDetail = (item: TemplateItem) => {
  console.log('查看详情:', item);
};

// 创建场景
const handleCreateScene = (item: TemplateItem) => {
  console.log('创建场景:', item);
};

// 模板检测
const handleTemplateCheck = (item: TemplateItem) => {
  console.log('模板检测:', item);
};

// 更多操作
const handleMore = (item: TemplateItem) => {
  console.log('更多操作:', item);
};

// 分页变化
const handlePageChange = (page: number, pageSize: number) => {
  console.log('分页变化:', page, pageSize);
};

// 每页条数变化
const handlePageSizeChange = (current: number, size: number) => {
  console.log('每页条数变化:', current, size);
};
</script>

<style scoped>
.scene-template {
  padding: 0;
  min-height: calc(100vh - 120px);
}

/* 左右布局 */
.left-menu-col {
  padding-right: 0;
}

.right-content-col {
  padding-left: 16px;
}

/* 左侧菜单 */
.left-menu {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
  padding: 0;
  height: calc(100vh - 280px);
  overflow-y: auto;
}

/* 全部选项 */
.menu-all-item {
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #333;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 1px solid #f0f0f0;
}

.menu-all-item:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.menu-all-item.active {
  background: #e6f7ff;
  color: #1890ff;
}

.menu-category {
  border-bottom: none;
}

.menu-category:last-child {
  border-bottom: none;
}

.menu-category-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 18px 12px;
  cursor: pointer;
  transition: background 0.3s;
  font-size: 14px;
}

.menu-category-title:hover {
  background: #f5f5f5;
}

.category-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.menu-arrow-down {
  transform: rotate(180deg);
  transition: transform 0.3s;
}

.menu-sub-items {
  background: #fafafa;
  padding: 8px 0;
}

.menu-sub-item {
  padding: 14px 12px 14px 24px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
}

.menu-sub-item:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.menu-sub-item.active {
  background: #e6f7ff;
  color: #1890ff;
  font-weight: 500;
}

/* 顶部标签筛选 */
.tab-section {
  background: #fff;
  padding: 0 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.tab-section :deep(.ant-tabs-nav) {
  margin-bottom: 0;
}

.tab-section :deep(.ant-tabs-tab) {
  padding: 12px 0;
  font-size: 14px;
}

/* 搜索区域 */
.search-area {
  background: #fff;
  padding: 16px 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.create-btn {
  float: right;
}

/* 卡片列表 */
.card-list {
  background: #fff;
  padding: 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(232, 232, 232, 0.6);
}

.template-card {
  height: 100%;
  transition: box-shadow 0.3s;
}

.template-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.template-card :deep(.ant-card-body) {
  padding: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  flex: 1;
}

.card-tags {
  display: flex;
  align-items: center;
  gap: 4px;
}

.card-detail {
  color: #1890ff;
  cursor: pointer;
  font-size: 13px;
  margin-left: 4px;
  text-decoration: none;
}

.card-detail:hover {
  color: #40a9ff;
}

.card-description {
  font-size: 13px;
  color: #666;
  line-height: 1.6;
  margin-bottom: 16px;
  min-height: 40px;
}

.card-stats {
  font-size: 13px;
  color: #666;
  margin-bottom: 16px;
  padding-top: 12px;
  border-top: 1px solid #f5f5f5;
}

.stats-count {
  color: #1890ff;
  font-weight: 500;
}

.card-actions {
  display: flex;
  justify-content: space-between;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
}

.action-item {
  color: #1890ff;
  cursor: pointer;
  font-size: 13px;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 2px;
  transition: background 0.3s;
}

.action-item:hover {
  background: #e6f7ff;
  color: #40a9ff;
}

.action-item:not(:last-child) {
  position: relative;
}

.action-item:not(:last-child)::after {
  content: '|';
  position: absolute;
  right: -4px;
  color: #e8e8e8;
}

/* 分页 */
.pagination-section {
  background: #fff;
  padding: 16px 24px;
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.pagination-section :deep(.ant-pagination) {
  margin: 0;
}

.pagination-section :deep(.ant-pagination-item) {
  border-color: #d9d9d9;
}

.pagination-section :deep(.ant-pagination-item-active) {
  border-color: #1890ff;
  background: #1890ff;
}

.pagination-section :deep(.ant-pagination-item-active a) {
  color: #fff;
}

.pagination-section :deep(.ant-pagination-options-quick-jumper input) {
  border-color: #d9d9d9;
}
</style>
