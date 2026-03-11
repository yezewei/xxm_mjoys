<template>
  <div class="scene-management">
    <!-- 顶部工具栏 - 放在标签页上方 -->
    <div class="top-toolbar">
      <a-space class="toolbar-actions">
        <a-button @click="handleImportScene">
          <template #icon><import-outlined /></template>
          导入场景
        </a-button>
        <a-button type="primary" @click="handleCreateScene">
          <template #icon><plus-outlined /></template>
          创建场景
        </a-button>
        <a-button type="primary" class="scene-shop-btn" @click="handleOpenSceneShop">
          <template #icon><shop-outlined /></template>
          场景小店
        </a-button>
      </a-space>
    </div>

    <!-- 顶部标签页 -->
    <a-tabs v-model:activeKey="activeTab" class="scene-tabs">
      <a-tab-pane key="active" tab="开启场景">
        <!-- 搜索区域 -->
        <div class="search-area">
          <a-row :gutter="[16, 16]">
            <!-- 第一行 -->
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.institution"
                placeholder="请选择机构"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="hzbank">杭州银行</a-select-option>
                <a-select-option value="nbbank">宁波银行</a-select-option>
                <a-select-option value="shbank">上海银行</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.sceneName"
                placeholder="请输入场景名称搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.creator"
                placeholder="请输入创建者搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.templateType"
                placeholder="请选择模版类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="collection">催收模版</a-select-option>
                <a-select-option value="marketing">营销模版</a-select-option>
                <a-select-option value="service">服务模版</a-select-option>
              </a-select>
            </a-col>
            <!-- 第二行 -->
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.templateSubtype"
                placeholder="请选择模版子类型"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="loan">贷款类</a-select-option>
                <a-select-option value="credit_card">信用卡类</a-select-option>
                <a-select-option value="deposit">存款类</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-select
                v-model:value="searchForm.outboundStatus"
                placeholder="请选择外呼状态"
                allow-clear
                style="width: 100%"
              >
                <a-select-option value="running">外呼中</a-select-option>
                <a-select-option value="paused">已暂停</a-select-option>
                <a-select-option value="completed">已完成</a-select-option>
              </a-select>
            </a-col>
            <a-col :span="6">
              <a-input
                v-model:value="searchForm.sceneCode"
                placeholder="请输入场景编号搜索"
                allow-clear
                style="width: 100%"
              />
            </a-col>
            <a-col :span="6">
              <a-space>
                <a-button type="primary" @click="handleSearch">
                  <search-outlined />
                  搜索
                </a-button>
                <a-button @click="handleReset">
                  <reload-outlined />
                  重置
                </a-button>
              </a-space>
            </a-col>
          </a-row>
        </div>

        <!-- 操作按钮区域 -->
        <div class="toolbar-area">
          <div class="toolbar-left">
            <span class="total-info">共 {{ total }} 条</span>
          </div>
          <div class="toolbar-right">
            <a-select
              v-model:value="sortOrder"
              placeholder="按编辑时间排序"
              style="width: 180px"
            >
              <a-select-option value="desc">编辑时间降序</a-select-option>
              <a-select-option value="asc">编辑时间升序</a-select-option>
            </a-select>
          </div>
        </div>

        <!-- 场景卡片列表 - 每个卡片单独一行 -->
        <div class="scene-list">
          <div v-for="scene in sceneList" :key="scene.id" class="scene-card-row">
            <div class="scene-card">
              <!-- 卡片头部 -->
              <div class="card-header">
                <div class="header-left">
                  <div class="scene-title">
                    <span class="title-indicator"></span>
                    <span class="title-text">{{ scene.name }}</span>
                  </div>
                  <a-tag v-if="scene.tag" :color="scene.tagColor">{{ scene.tag }}</a-tag>
                </div>
                <div class="header-right">
                  <span class="expire-time">到期时间：{{ scene.expireTime }}</span>
                </div>
              </div>

              <!-- 卡片内容 -->
              <div class="card-body">
                <div class="body-wrapper">
                  <!-- 左侧信息区 -->
                  <div class="body-left">
                    <div class="info-grid">
                      <!-- 第一列 -->
                      <div class="info-column">
                        <div class="info-item">
                          <span class="label">语音类型：</span>
                          <span class="value">{{ scene.voiceType }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">跟进方式：</span>
                          <span class="value">{{ scene.followUpMethod }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">外呼状态：</span>
                          <span class="value">{{ scene.outboundStatus }}</span>
                          <a class="update-link" @click="handleRefreshStatus">每 1 分钟更新</a>
                        </div>
                      </div>

                      <!-- 第二列 -->
                      <div class="info-column">
                        <div class="info-item">
                          <span class="label">平台版本/行方版本：</span>
                          <span class="value">{{ scene.platformVersion }}</span>
                        </div>
                        <div class="info-item">
                          <span class="label">是否启用：</span>
                          <a-switch
                            v-model:checked="scene.enabled"
                            size="small"
                            @change="handleEnabledChange(scene)"
                          />
                        </div>
                        <div class="info-item">
                          <span class="label">场景编号：</span>
                          <span class="value">{{ scene.code }}</span>
                        </div>
                      </div>

                      <!-- 第三列 -->
                      <div class="info-column">
                        <div class="info-item">
                          <span class="label">创建时间：</span>
                          <span class="value">{{ scene.createTime }}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 右侧操作按钮区 -->
                  <div class="body-right">
                    <div class="action-grid">
                      <a class="action-link" @click="handleView(scene)">查看</a>
                      <a class="action-link" @click="handleReport(scene)">报表</a>
                      <a class="action-link" @click="handlePublish(scene)">发布</a>
                      <a class="action-link" @click="handleExport(scene)">导出</a>
                      <a class="action-link" @click="handleCopy(scene)">复制</a>
                      <a class="action-link danger" @click="handleDelete(scene)">删除</a>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 底部操作链接 -->
              <div class="card-footer">
                <a class="footer-link blue" @click="handleSceneCheck(scene)">场景检测</a>
                <a class="footer-link blue" @click="handleScriptCheck(scene)">话术完整性检查</a>
                <a class="footer-link blue" @click="handleViewTimeSlot(scene)">查看拨打时间段</a>
                <a class="footer-link blue" @click="handleAddDataBatch(scene)">添加数据批次</a>
                <a class="footer-link blue" @click="handleQuickTest(scene)">快速拨测</a>
                <a class="footer-link blue" @click="handleScriptTest(scene)">话术测试</a>
              </div>
            </div>
          </div>
        </div>
      </a-tab-pane>

      <a-tab-pane key="closed" tab="关闭场景">
        <a-empty description="暂无关闭场景" />
      </a-tab-pane>

      <a-tab-pane key="expired" tab="过期场景">
        <a-empty description="暂无过期场景" />
      </a-tab-pane>
    </a-tabs>

    <!-- 场景小店弹窗 -->
    <a-modal
      v-model:open="sceneShopVisible"
      title="场景小店"
      :width="1200"
      :footer="null"
      class="scene-shop-modal"
      @cancel="handleCloseSceneShop"
    >
      <div class="scene-shop-container">
        <!-- 左侧分类菜单 -->
        <div class="sidebar">
          <div class="left-menu">
            <!-- 全部选项 -->
            <div
              :class="['menu-all-item', { active: selectedShopCategory === '全部' }]"
              @click="handleShopCategoryClick('全部')"
            >
              全部
            </div>
            <!-- 分类菜单 -->
            <div
              v-for="(category, index) in shopMenuCategories"
              :key="index"
              class="menu-category"
            >
              <div
                class="menu-category-title"
                @click="toggleShopCategory(index)"
              >
                <span class="category-name">{{ category.name }}</span>
                <DownOutlined :class="{ 'menu-arrow-down': category.expanded }" />
              </div>
              <div v-if="category.expanded" class="menu-sub-items">
                <div
                  v-for="subItem in category.items"
                  :key="subItem"
                  :class="['menu-sub-item', { active: selectedShopCategory === subItem }]"
                  @click="handleShopCategoryClick(subItem)"
                >
                  {{ subItem }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 右侧内容区 -->
        <div class="content">
          <!-- 搜索栏 -->
          <div class="search-bar">
            <div class="search-row">
              <a-input
                v-model:value="searchKeyword"
                placeholder="请输入场景名称搜索"
                class="search-input"
                :allow-clear="true"
              >
                <template #prefix>
                  <search-outlined />
                </template>
              </a-input>
              <a-select
                v-model:value="selectedLine"
                placeholder="所属条线"
                class="line-select"
                :allow-clear="true"
              >
                <a-select-option value="">全部条线</a-select-option>
                <a-select-option value="retail">零售金融</a-select-option>
                <a-select-option value="corporate">公司金融</a-select-option>
                <a-select-option value="operation">运营管理</a-select-option>
              </a-select>
              <a-button type="primary" @click="handleSceneShopSearch">
                <template #icon><search-outlined /></template>
                搜索
              </a-button>
              <a-button @click="handleSceneShopReset">重置</a-button>
            </div>
          </div>

          <!-- 场景卡片列表 -->
          <div class="scene-shop-list">
            <a-row :gutter="[16, 16]">
              <a-col
                v-for="scene in filteredSceneList"
                :key="scene.id"
                :xs="24"
                :sm="12"
                :md="8"
              >
                <a-card class="scene-shop-card" hoverable>
                  <div class="scene-card-header">
                    <span class="scene-name">{{ scene.name }}</span>
                  </div>

                  <div class="scene-tags">
                    <a-tag
                      v-for="tag in scene.tags"
                      :key="tag"
                      color="blue"
                    >
                      {{ tag }}
                    </a-tag>
                  </div>

                  <p class="scene-description">{{ scene.description }}</p>

                  <div class="scene-actions">
                    <span v-if="scene.acquired" class="acquired-text">
                      <check-circle-outlined />
                      已获取
                    </span>
                    <a v-else class="get-scene-link" @click="handleGetScene(scene)">
                      <download-outlined />
                      获取场景
                    </a>
                  </div>
                </a-card>
              </a-col>
            </a-row>
          </div>

          <!-- 分页 -->
          <div class="pagination-container">
            <a-pagination
              v-model:current="currentPage"
              v-model:pageSize="pageSize"
              :total="shopTotal"
              show-size-changer
              show-quick-jumper
              :show-total="((total: number) => `共 ${total} 条`) as any"
              :locale="{
                items_per_page: '条/页',
                jump_to: '跳至',
                page: '页',
              }"
            />
          </div>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  ImportOutlined,
  PlusOutlined,
  ShopOutlined,
  DownOutlined,
  AppstoreOutlined,
  ShoppingOutlined,
  BellOutlined,
  SafetyOutlined,
  UserOutlined,
  DownloadOutlined,
  CheckCircleOutlined,
  EllipsisOutlined,
  EditOutlined,
  CopyOutlined,
  DeleteOutlined,
} from '@ant-design/icons-vue';

// 场景数据接口
interface SceneItem {
  id: number;
  name: string;
  tag?: string;
  tagColor?: string;
  expireTime: string;
  voiceType: string;
  platformVersion: string;
  followUpMethod: string;
  enabled: boolean;
  outboundStatus: string;
  code: string;
  createTime: string;
}

// 搜索表单数据
interface SearchForm {
  institution: string | undefined;
  sceneName: string | undefined;
  creator: string | undefined;
  templateType: string | undefined;
  templateSubtype: string | undefined;
  outboundStatus: string | undefined;
  sceneCode: string | undefined;
}

// 当前激活的标签页
const activeTab = ref<string>('active');

// 搜索表单
const searchForm = reactive<SearchForm>({
  institution: undefined,
  sceneName: undefined,
  creator: undefined,
  templateType: undefined,
  templateSubtype: undefined,
  outboundStatus: undefined,
  sceneCode: undefined,
});

// 排序方式
const sortOrder = ref<string>('desc');

// 总数
const total = ref<number>(8);

// 场景列表数据（8 条模拟数据）
const sceneList = ref<SceneItem[]>([
  {
    id: 1,
    name: '贷款转存 - 接通即转（叶泽伟测试）',
    tag: '热门',
    tagColor: 'red',
    expireTime: '2026-12-31',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309001',
    createTime: '2026-03-01 10:30:00',
  },
  {
    id: 2,
    name: '信用卡逾期催收场景',
    tag: '推荐',
    tagColor: 'green',
    expireTime: '2026-06-30',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: '人工跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309002',
    createTime: '2026-03-02 14:20:00',
  },
  {
    id: 3,
    name: '新客户营销回访',
    expireTime: '2026-09-30',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: false,
    outboundStatus: '已暂停',
    code: 'SCENE20260309003',
    createTime: '2026-03-03 09:15:00',
  },
  {
    id: 4,
    name: '存款到期提醒场景',
    tag: '新品',
    tagColor: 'blue',
    expireTime: '2026-12-31',
    voiceType: '混合语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI + 人工',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309004',
    createTime: '2026-03-05 16:45:00',
  },
  {
    id: 5,
    name: '理财产品推广场景',
    expireTime: '2026-08-31',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: '人工跟进',
    enabled: true,
    outboundStatus: '已完成',
    code: 'SCENE20260309005',
    createTime: '2026-03-07 11:00:00',
  },
  {
    id: 6,
    name: '企业贷款审批通知',
    tag: '热门',
    tagColor: 'red',
    expireTime: '2026-11-30',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: 'AI 自动跟进',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309006',
    createTime: '2026-03-08 09:30:00',
  },
  {
    id: 7,
    name: '个人消费贷营销',
    tag: '推荐',
    tagColor: 'green',
    expireTime: '2026-10-31',
    voiceType: '真人录音',
    platformVersion: 'v2.4.0 / v3.0.0',
    followUpMethod: 'AI + 人工',
    enabled: true,
    outboundStatus: '外呼中',
    code: 'SCENE20260309007',
    createTime: '2026-03-08 14:00:00',
  },
  {
    id: 8,
    name: '账户异常提醒场景',
    expireTime: '2026-07-31',
    voiceType: 'TTS 语音',
    platformVersion: 'v2.5.0 / v3.1.0',
    followUpMethod: '人工跟进',
    enabled: false,
    outboundStatus: '已暂停',
    code: 'SCENE20260309008',
    createTime: '2026-03-09 10:15:00',
  },
]);

/**
 * 搜索按钮点击
 */
const handleSearch = () => {
  console.log('执行搜索:', searchForm);
  // TODO: 实现搜索逻辑
};

/**
 * 重置按钮点击
 */
const handleReset = () => {
  searchForm.institution = undefined;
  searchForm.sceneName = undefined;
  searchForm.creator = undefined;
  searchForm.templateType = undefined;
  searchForm.templateSubtype = undefined;
  searchForm.outboundStatus = undefined;
  searchForm.sceneCode = undefined;
  // TODO: 重置后重新加载数据
};

/**
 * 导入场景
 */
const handleImportScene = () => {
  console.log('导入场景');
  // TODO: 实现导入逻辑
};

/**
 * 创建场景
 */
const handleCreateScene = () => {
  console.log('创建场景');
  // TODO: 实现创建逻辑
};

/**
 * 启用状态变更
 */
const handleEnabledChange = (scene: SceneItem) => {
  console.log(`场景 ${scene.name} 启用状态变更为：${scene.enabled}`);
  // TODO: 调用接口更新状态
};

/**
 * 刷新外呼状态
 */
const handleRefreshStatus = () => {
  console.log('刷新外呼状态');
  // TODO: 实现刷新逻辑
};

/**
 * 查看场景
 */
const handleView = (scene: SceneItem) => {
  console.log('查看场景:', scene.name);
  // TODO: 跳转到详情页
};

/**
 * 查看报表
 */
const handleReport = (scene: SceneItem) => {
  console.log('查看报表:', scene.name);
  // TODO: 跳转到报表页
};

/**
 * 发布场景
 */
const handlePublish = (scene: SceneItem) => {
  console.log('发布场景:', scene.name);
  // TODO: 实现发布逻辑
};

/**
 * 导出场景
 */
const handleExport = (scene: SceneItem) => {
  console.log('导出场景:', scene.name);
  // TODO: 实现导出逻辑
};

/**
 * 复制场景
 */
const handleCopy = (scene: SceneItem) => {
  console.log('复制场景:', scene.name);
  // TODO: 实现复制逻辑
};

/**
 * 删除场景
 */
const handleDelete = (scene: SceneItem) => {
  console.log('删除场景:', scene.name);
  // TODO: 实现删除逻辑（需二次确认）
};

/**
 * 场景检测
 */
const handleSceneCheck = (scene: SceneItem) => {
  console.log('场景检测:', scene.name);
  // TODO: 实现场景检测逻辑
};

/**
 * 话术完整性检查
 */
const handleScriptCheck = (scene: SceneItem) => {
  console.log('话术完整性检查:', scene.name);
  // TODO: 实现话术检查逻辑
};

/**
 * 查看拨打时间段
 */
const handleViewTimeSlot = (scene: SceneItem) => {
  console.log('查看拨打时间段:', scene.name);
  // TODO: 实现查看时间段逻辑
};

/**
 * 添加数据批次
 */
const handleAddDataBatch = (scene: SceneItem) => {
  console.log('添加数据批次:', scene.name);
  // TODO: 实现添加数据批次逻辑
};

/**
 * 快速拨测
 */
const handleQuickTest = (scene: SceneItem) => {
  console.log('快速拨测:', scene.name);
  // TODO: 实现快速拨测逻辑
};

/**
 * 话术测试
 */
const handleScriptTest = (scene: SceneItem) => {
  console.log('话术测试:', scene.name);
  // TODO: 实现话术测试逻辑
};

// ==================== 场景小店相关 ====================

// 场景小店弹窗可见性
const sceneShopVisible = ref<boolean>(false);

// 场景小店选中的分类
const selectedShopCategory = ref<string>('全部');

// 场景小店搜索关键词
const searchKeyword = ref<string>('');

// 场景小店所属条线
const selectedLine = ref<string>('');

// 场景小店分页
const currentPage = ref<number>(1);
const pageSize = ref<number>(9);
const shopTotal = ref<number>(27);

// 场景小店菜单分类接口
interface ShopMenuCategory {
  name: string;
  expanded: boolean;
  items: string[];
}

// 场景小店左侧菜单分类数据（参考 SceneTemplate.vue）
const shopMenuCategories = reactive<ShopMenuCategory[]>([
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

// 场景小店数据接口
interface SceneShopItem {
  id: number;
  name: string;
  tags: string[];
  description: string;
  category: string;
  line: string;
  acquired?: boolean; // 是否已获取
}

// 场景小店列表数据
const sceneShopList = ref<SceneShopItem[]>([
  {
    id: 1,
    name: '信用卡激活',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '用于短信下发后，再进行外呼。',
    category: '信用卡',
    line: 'retail',
    acquired: true, // 已获取
  },
  {
    id: 2,
    name: '账户回访',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '成年版的开卡回访，无需跟进',
    category: '回访',
    line: 'retail',
    acquired: false,
  },
  {
    id: 3,
    name: '信用卡换卡',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '信用卡到期换新卡',
    category: '信用卡',
    line: 'retail',
    acquired: true,
  },
  {
    id: 4,
    name: '存款到期续存',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '定期存款到期后提醒转存',
    category: '存款',
    line: 'retail',
    acquired: false,
  },
  {
    id: 5,
    name: '信用卡促活',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '用于短信下发后，再进行外呼。',
    category: '信用卡',
    line: 'retail',
    acquired: false,
  },
  {
    id: 6,
    name: '手机银行签到',
    tags: ['标签 1', '标签 2', '标签 3'],
    description: '手机银行促活类',
    category: '手机银行',
    line: 'retail',
    acquired: true,
  },
  {
    id: 7,
    name: '贷款营销场景',
    tags: ['标签 1', '标签 2'],
    description: '个人消费贷款营销推广',
    category: '贷款',
    line: 'retail',
    acquired: false,
  },
  {
    id: 8,
    name: '企业开户通知',
    tags: ['标签 1', '标签 3'],
    description: '企业账户开户进度通知',
    category: '对公业务',
    line: 'corporate',
    acquired: false,
  },
  {
    id: 9,
    name: '身份核验场景',
    tags: ['标签 2', '标签 3'],
    description: '客户身份信息核验确认',
    category: '回访',
    line: 'operation',
    acquired: false,
  },
]);

// 计算属性：过滤后的场景列表
const filteredSceneList = computed<SceneShopItem[]>(() => {
  let result = sceneShopList.value;
  
  // 按分类过滤
  if (selectedShopCategory.value !== '全部') {
    // 检查是否匹配子项
    const matchedCategory = shopMenuCategories.find(cat => 
      cat.items.includes(selectedShopCategory.value)
    );
    if (matchedCategory) {
      result = result.filter(item => item.category === matchedCategory.name);
    }
  }
  
  // 按条线过滤
  if (selectedLine.value) {
    result = result.filter(item => item.line === selectedLine.value);
  }
  
  // 按关键词过滤
  if (searchKeyword.value) {
    result = result.filter(item => 
      item.name.toLowerCase().includes(searchKeyword.value.toLowerCase())
    );
  }
  
  return result;
});

/**
 * 打开场景小店
 */
const handleOpenSceneShop = () => {
  console.log('打开场景小店');
  sceneShopVisible.value = true;
};

/**
 * 关闭场景小店
 */
const handleCloseSceneShop = () => {
  sceneShopVisible.value = false;
  handleSceneShopReset();
};

/**
 * 场景小店分类点击
 */
const handleShopCategoryClick = (category: string) => {
  selectedShopCategory.value = category;
  console.log('选择分类:', category);
};

/**
 * 切换场景小店分类展开/收起
 */
const toggleShopCategory = (index: number) => {
  shopMenuCategories[index].expanded = !shopMenuCategories[index].expanded;
};

/**
 * 场景小店搜索
 */
const handleSceneShopSearch = () => {
  console.log('场景小店搜索:', {
    keyword: searchKeyword.value,
    line: selectedLine.value,
    category: selectedShopCategory.value,
  });
  currentPage.value = 1;
};

/**
 * 场景小店重置
 */
const handleSceneShopReset = () => {
  searchKeyword.value = '';
  selectedLine.value = '';
  selectedShopCategory.value = '全部';
  currentPage.value = 1;
};

/**
 * 获取场景
 */
const handleGetScene = (scene: SceneShopItem) => {
  console.log('获取场景:', scene.name);
  // 更新获取状态
  scene.acquired = true;
  // TODO: 实现获取场景逻辑
};

/**
 * 模板检测
 */
const handleTemplateCheck = (scene: SceneShopItem) => {
  console.log('模板检测:', scene.name);
  // TODO: 实现模板检测逻辑
};
</script>

<style scoped>
/* 场景管理容器 */
.scene-management {
  padding: 0;
}

/* 顶部工具栏 - 右上角按钮 */
.top-toolbar {
  display: flex;
  justify-content: flex-end;
  margin-top: 10px;
  margin-bottom: -10px;
  padding: 0 24px;
}

.toolbar-actions {
  display: flex;
  gap: 12px;
}

/* 标签页样式 */
.scene-tabs {
  background: #fff;
  padding: 0px 24px;
}

.scene-tabs :deep(.ant-tabs-nav) {
  margin-bottom: 16px;
}

.scene-tabs :deep(.ant-tabs-tab) {
  font-size: 15px;
  font-weight: 500;
}

/* 场景小店按钮高亮样式 */
.scene-shop-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
  position: relative;
  overflow: hidden;
  animation: shop-btn-glow 2s ease-in-out infinite;
  color: #fff !important;
  font-weight: 600;
  padding: 4px 16px;
  height: 36px;
}

.scene-shop-btn:hover {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4) !important;
}

@keyframes shop-btn-glow {
  0%, 100% {
    box-shadow: 0 2px 10px rgba(102, 126, 234, 0.3);
  }
  50% {
    box-shadow: 0 4px 20px rgba(102, 126, 234, 0.5);
  }
}

/* 搜索区域 */
.search-area {
  padding: 16px;
  margin-bottom: 16px;
}

/* 工具栏区域 */
.toolbar-area {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 0 4px;
}

.toolbar-left {
  display: flex;
  align-items: center;
}

.total-info {
  font-size: 14px;
  color: #595959;
  font-weight: 500;
}

.toolbar-right {
  display: flex;
  align-items: center;
}

/* 场景列表 */
.scene-list {
  margin-bottom: 24px;
}

/* 每个场景卡片行 - 独占一行 */
.scene-card-row {
  margin-bottom: 16px;
}

.scene-card-row:last-child {
  margin-bottom: 0;
}

/* 场景卡片 */
.scene-card {
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  padding: 0px;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
}

.scene-card:hover {
  border-color: #1890ff;
  box-shadow: 0 4px 12px rgba(24, 144, 255, 0.15);
}

/* 卡片头部 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  background: #e6f7ff;
  border-radius: 8px 8px 0 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
}

.scene-title {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.title-indicator {
  width: 4px;
  height: 18px;
  background: #1890ff;
  border-radius: 2px;
  flex-shrink: 0;
}

.title-text {
  font-size: 16px;
  font-weight: 600;
  color: #262626;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header-right {
  flex-shrink: 0;
}

.expire-time {
  font-size: 14px;
  color: #8c8c8c;
  white-space: nowrap;
}

/* 卡片内容 */
.card-body {
  flex: 1;
  margin-left: 24px;
  margin-bottom: 12px;

}

.body-wrapper {
  display: flex;
  gap: 24px;
}

.body-left {
  flex: 1;
  min-width: 0;
}

.info-grid {
  display: grid;
  grid-template-columns: auto auto auto;
  gap: 16px 24px;
}

.info-column {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.info-item .label {
  color: #8c8c8c;
  flex-shrink: 0;
  white-space: nowrap;
  font-size: 14px;
  text-align: left;
}

.info-item .value {
  color: #262626;
  word-break: break-word;
  font-size: 14px;
  text-align: left;
}

.body-right {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  margin-right: 12px;
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 4px 8px;
  align-content: center;
}

.action-link {
  font-size: 14px;
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
  text-align: center;
  background: transparent;
}

.action-link:hover {
  color: #40a9ff;
}

.action-link.danger {
  color: #ff4d4f;
}

.action-link.danger:hover {
  color: #ff7875;
}

.update-link {
  color: #1890ff;
  font-size: 14px;
  margin-left: 4px;
  cursor: pointer;
}

.update-link:hover {
  color: #40a9ff;
}

/* 卡片底部 */
.card-footer {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 24px;
  padding-top: 6px;
  padding-bottom: 6px;
  margin-left: 18px;
  border-top: 1px solid #f0f0f0;
}

.footer-link {
  font-size: 14px;
  color: #1890ff;
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
  background: transparent;
}

.footer-link.blue {
  color: #1890ff;
  background: transparent;
}

.footer-link.blue:hover {
  color: #40a9ff;
}

/* 空状态 */
.scene-tabs :deep(.ant-empty) {
  padding: 48px 0;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .body-wrapper {
    flex-direction: column;
  }

  .body-right {
    width: 100%;
  }

  .action-grid {
    width: 100%;
    min-width: auto;
  }

  .info-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .card-header {
    flex-direction: column;
    gap: 8px;
  }

  .header-right {
    width: 100%;
    text-align: right;
  }

  .card-footer {
    flex-direction: column;
    align-items: flex-start;
  }

  .card-footer .footer-link {
    width: 100%;
    text-align: center;
  }
}

/* ==================== 场景小店弹窗样式 ==================== */
.scene-shop-modal {
  :deep(.ant-modal-body) {
    padding: 0;
  }
}

.scene-shop-container {
  display: flex;
  min-height: 600px;
  max-height: 70vh;
}

.scene-shop-modal .sidebar {
  width: 220px;
  border-right: 1px solid #f0f0f0;
  background-color: #fff;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

/* 场景小店左侧菜单 */
.scene-shop-modal .left-menu {
  flex: 1;
  overflow-y: auto;
  padding: 0;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
  margin: 12px;
  height: calc(70vh - 144px);
}

/* 全部选项 */
.scene-shop-modal .menu-all-item {
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #333;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 1px solid #f0f0f0;
}

.scene-shop-modal .menu-all-item:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.scene-shop-modal .menu-all-item.active {
  background: #e6f7ff;
  color: #1890ff;
}

.scene-shop-modal .menu-category {
  border-bottom: 1px solid #f0f0f0;
}

.scene-shop-modal .menu-category:last-child {
  border-bottom: none;
}

.scene-shop-modal .menu-category-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 12px;
  cursor: pointer;
  transition: background 0.3s;
}

.scene-shop-modal .menu-category-title:hover {
  background: #f5f5f5;
}

.scene-shop-modal .category-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.scene-shop-modal .menu-arrow-down {
  transform: rotate(180deg);
  transition: transform 0.3s;
  color: #999;
}

.scene-shop-modal .menu-sub-items {
  background: #fafafa;
  padding: 8px 0;
}

.scene-shop-modal .menu-sub-item {
  padding: 12px 12px 12px 24px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s;
}

.scene-shop-modal .menu-sub-item:hover {
  background: #e6f7ff;
  color: #1890ff;
}

.scene-shop-modal .menu-sub-item.active {
  background: #e6f7ff;
  color: #1890ff;
  font-weight: 500;
}

.scene-shop-modal .content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.scene-shop-modal .search-bar {
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
  background-color: #fff;
}

.scene-shop-modal .search-row {
  display: flex;
  gap: 12px;
  align-items: center;
}

.scene-shop-modal .search-input {
  width: 300px;
}

.scene-shop-modal .line-select {
  width: 150px;
}

.scene-shop-modal .scene-shop-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background-color: #fafafa;
}

.scene-shop-modal .scene-shop-card {
  height: 100%;
  display: flex;
  flex-direction: column;
  border-radius: 8px;
  transition: all 0.3s;
}

.scene-shop-modal .scene-shop-card :deep(.ant-card-body) {
  display: flex;
  flex-direction: column;
  flex: 1;
  padding: 16px;
}

.scene-shop-modal .scene-shop-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.scene-shop-modal .scene-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  flex-shrink: 0;
}

.scene-shop-modal .scene-name {
  font-weight: 600;
  font-size: 15px;
  color: #1f1f1f;
  flex: 1;
}

.scene-shop-modal .scene-tags {
  margin-bottom: 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  flex-shrink: 0;
}

.scene-shop-modal .scene-description {
  flex: 1;
  color: #666;
  font-size: 13px;
  line-height: 1.6;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  margin-bottom: 16px;
  min-height: 60px;
}

.scene-shop-modal .scene-actions {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
  margin-top: auto;
  flex-shrink: 0;
}

.scene-shop-modal .scene-actions .acquired-text {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #52c41a;
  font-size: 14px;
  font-weight: 500;
  cursor: default;
}

.scene-shop-modal .scene-actions .get-scene-link {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #1677ff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
}

.scene-shop-modal .scene-actions .get-scene-link:hover {
  color: #40a9ff;
  background-color: #e6f7ff;
}

.scene-shop-modal .pagination-container {
  padding: 16px;
  border-top: 1px solid #f0f0f0;
  background-color: #fff;
  display: flex;
  justify-content: flex-end;
}
</style>
