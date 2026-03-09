<template>
  <div class="scene-template">
    <div class="layout-content">
      <!-- 左侧菜单栏 -->
      <div class="left-menu-col">
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
      </div>

      <!-- 右侧内容区 -->
      <div class="right-content-col">
        <div class="content-scroll-wrapper">
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
            </a-space>
            <a-dropdown v-model:open="createDropdownOpen" trigger="click">
              <a-button type="primary" class="create-btn">
                <plus-outlined />
                新建场景模板
                <down-outlined />
              </a-button>
              <template #overlay>
                <a-menu @click="handleCreateMenuClick">
                  <a-menu-item key="blank">使用空白模板</a-menu-item>
                  <a-menu-item key="reference">引用现有场景</a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </div>

        <!-- 新建场景弹窗 -->
        <a-modal
          v-model:open="createModalVisible"
          :title="modalTitle"
          width="600px"
          :footer="null"
          @cancel="handleCreateCancel"
        >
          <a-form
            ref="createFormRef"
            :model="createForm"
            :rules="createRules"
            layout="horizontal"
            :label-col="{ span: 6 }"
            :wrapper-col="{ span: 16 }"
          >
            <a-form-item label="模板名称" name="templateName">
              <a-input v-model:value="createForm.templateName" placeholder="请输入模板名称" />
            </a-form-item>
            <a-form-item label="选择银行" name="bankId">
              <a-select v-model:value="createForm.bankId" placeholder="请选择" allow-clear>
                <a-select-option value="1">工商银行</a-select-option>
                <a-select-option value="2">农业银行</a-select-option>
                <a-select-option value="3">中国银行</a-select-option>
                <a-select-option value="4">建设银行</a-select-option>
                <a-select-option value="5">交通银行</a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="归属机构" name="orgId">
              <a-select v-model:value="createForm.orgId" placeholder="请选择" allow-clear>
                <a-select-option value="1">总行</a-select-option>
                <a-select-option value="2">北京分行</a-select-option>
                <a-select-option value="3">上海分行</a-select-option>
                <a-select-option value="4">广州分行</a-select-option>
                <a-select-option value="5">深圳分行</a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="场景名称" name="sceneName">
              <a-input v-model:value="createForm.sceneName" placeholder="请输入" />
            </a-form-item>
            <a-form-item label="场景简称" name="sceneShortName">
              <a-input v-model:value="createForm.sceneShortName" placeholder="请输入" />
            </a-form-item>
            <a-form-item label="场景编号" name="sceneCode">
              <a-input v-model:value="createForm.sceneCode" placeholder="请输入" />
            </a-form-item>
            <a-form-item label="标签" name="tags">
              <a-select
                v-model:value="createForm.tags"
                mode="tags"
                placeholder="请选择或输入标签"
                style="width: 100%"
              />
            </a-form-item>
            <a-form-item label="到期时间" name="expireDate">
              <a-date-picker
                v-model:value="createForm.expireDate"
                placeholder="请选择日期"
                style="width: 100%"
                format="YYYY-MM-DD"
              />
            </a-form-item>
            <a-form-item label="适用客群" name="targetCustomer">
              <a-textarea
                v-model:value="createForm.targetCustomer"
                placeholder="请输入适用客群描述"
                :rows="3"
              />
            </a-form-item>
            <a-form-item label="适用活动" name="applicableActivity">
              <a-textarea
                v-model:value="createForm.applicableActivity"
                placeholder="请输入适用活动描述"
                :rows="3"
              />
            </a-form-item>
            <a-form-item label="金融产品" name="financialProduct">
              <a-textarea
                v-model:value="createForm.financialProduct"
                placeholder="请输入金融产品描述"
                :rows="3"
              />
            </a-form-item>
          </a-form>
          <div class="modal-footer">
            <a-button @click="handleCreateCancel">关闭</a-button>
            <a-button type="primary" @click="handleCreateSubmit">保存</a-button>
          </div>
        </a-modal>

        <!-- 使用空白模板创建弹窗 -->
        <a-modal
          v-model:open="blankModalVisible"
          title="使用空白模板创建"
          width="600px"
          :footer="null"
          @cancel="handleBlankCancel"
        >
          <a-form
            ref="blankFormRef"
            :model="blankForm"
            :rules="blankRules"
            layout="horizontal"
            :label-col="{ span: 6 }"
            :wrapper-col="{ span: 16 }"
          >
            <a-form-item label="模板名称" name="templateName">
              <a-input v-model:value="blankForm.templateName" placeholder="请输入" />
            </a-form-item>
            <a-form-item label="模板类型" name="templateType">
              <a-cascader
                v-model:value="blankForm.templateType"
                placeholder="请选择"
                style="width: 100%"
                :options="cascaderOptions"
                allow-clear
                :field-names="{ label: 'name', value: 'name', children: 'children' }"
              />
            </a-form-item>
            <a-form-item label="标签" name="tags">
              <a-select
                v-model:value="blankForm.tags"
                mode="tags"
                placeholder="请选择或输入标签"
                style="width: 100%"
              />
            </a-form-item>
            <a-form-item label="跟进方式" name="followType">
              <a-select v-model:value="blankForm.followType" placeholder="请选择" allow-clear>
                <a-select-option value="all">全部</a-select-option>
                <a-select-option value="sms">短信跟进</a-select-option>
                <a-select-option value="manual">人工跟进</a-select-option>
                <a-select-option value="sms+manual">短信 + 人工跟进</a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="模板描述" name="description">
              <a-textarea
                v-model:value="blankForm.description"
                placeholder="请输入"
                :rows="4"
              />
            </a-form-item>
            <a-form-item label="适用客群" name="targetCustomer">
              <a-textarea
                v-model:value="blankForm.targetCustomer"
                placeholder="请输入适用客群描述"
                :rows="3"
              />
            </a-form-item>
            <a-form-item label="适用活动" name="applicableActivity">
              <a-textarea
                v-model:value="blankForm.applicableActivity"
                placeholder="请输入适用活动描述"
                :rows="3"
              />
            </a-form-item>
            <a-form-item label="金融产品" name="financialProduct">
              <a-textarea
                v-model:value="blankForm.financialProduct"
                placeholder="请输入金融产品描述"
                :rows="3"
              />
            </a-form-item>
          </a-form>
          <div class="modal-footer">
            <a-button @click="handleBlankCancel">关闭</a-button>
            <a-button type="primary" @click="handleBlankSubmit">保存</a-button>
          </div>
        </a-modal>

        <!-- 引用现有场景创建弹窗 -->
        <a-modal
          v-model:open="referenceModalVisible"
          title="引用现有场景创建"
          width="600px"
          :footer="null"
          @cancel="handleReferenceCancel"
        >
          <a-form
            ref="referenceFormRef"
            :model="referenceForm"
            :rules="referenceRules"
            layout="horizontal"
            :label-col="{ span: 6 }"
            :wrapper-col="{ span: 16 }"
          >
            <a-form-item label="模板名称" name="templateName">
              <a-input v-model:value="referenceForm.templateName" placeholder="请输入" />
            </a-form-item>
            <a-form-item label="引用场景" name="referenceScene">
              <a-select
                v-model:value="referenceForm.referenceScene"
                placeholder="请选择"
                allow-clear
                @change="handleReferenceSceneChange"
              >
                <a-select-option value="1">信用卡激活</a-select-option>
                <a-select-option value="2">账户回访</a-select-option>
                <a-select-option value="3">信用卡换卡</a-select-option>
                <a-select-option value="4">存款到期续存</a-select-option>
                <a-select-option value="5">信用卡促活</a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="模板类型" name="templateType">
              <a-cascader
                v-model:value="referenceForm.templateType"
                placeholder="请选择"
                style="width: 100%"
                :options="cascaderOptions"
                allow-clear
                :field-names="{ label: 'name', value: 'name', children: 'children' }"
              />
            </a-form-item>
            <a-form-item label="标签" name="tags">
              <a-select
                v-model:value="referenceForm.tags"
                mode="tags"
                placeholder="请选择或输入标签"
                style="width: 100%"
              />
            </a-form-item>
            <a-form-item label="跟进方式" name="followType">
              <a-select v-model:value="referenceForm.followType" placeholder="请选择" allow-clear>
                <a-select-option value="all">全部</a-select-option>
                <a-select-option value="sms">短信跟进</a-select-option>
                <a-select-option value="manual">人工跟进</a-select-option>
                <a-select-option value="sms+manual">短信 + 人工跟进</a-select-option>
              </a-select>
            </a-form-item>
            <a-form-item label="模板描述" name="description">
              <a-textarea
                v-model:value="referenceForm.description"
                placeholder="请输入"
                :rows="4"
              />
            </a-form-item>
            <a-form-item label="适用客群" name="targetCustomer">
              <a-textarea
                v-model:value="referenceForm.targetCustomer"
                placeholder="请输入适用客群描述"
                :rows="3"
              />
            </a-form-item>
            <a-form-item label="适用活动" name="applicableActivity">
              <a-textarea
                v-model:value="referenceForm.applicableActivity"
                placeholder="请输入适用活动描述"
                :rows="3"
              />
            </a-form-item>
            <a-form-item label="金融产品" name="financialProduct">
              <a-textarea
                v-model:value="referenceForm.financialProduct"
                placeholder="请输入金融产品描述"
                :rows="3"
              />
            </a-form-item>
          </a-form>
          <div class="modal-footer">
            <a-button @click="handleReferenceCancel">关闭</a-button>
            <a-button type="primary" @click="handleReferenceSubmit">保存</a-button>
          </div>
        </a-modal>

        <!-- 模板检测弹窗 -->
        <a-modal
          v-model:open="checkModalVisible"
          title="模板检测"
          width="500px"
          :footer="null"
          :closable="true"
          @cancel="handleCheckCancel"
        >
          <div class="check-steps">
            <div
              v-for="(step, index) in checkSteps"
              :key="index"
              class="check-step"
            >
              <div class="step-header">
                <div :class="['step-icon', { completed: step.completed, checking: step.checking }]">
                  <check-outlined v-if="step.completed" />
                  <loading-outlined v-else-if="step.checking" />
                </div>
                <span :class="['step-title', { completed: step.completed }]">{{ step.title }}</span>
              </div>
              <div class="step-items">
                <div
                  v-for="(item, itemIndex) in step.items"
                  :key="itemIndex"
                  :class="['step-item', { completed: item.completed }]"
                >
                  <check-circle-filled class="item-icon" />
                  <span>{{ item.name }}</span>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <a-button @click="handleCheckCancel">取消</a-button>
            <a-button type="primary" @click="handleCheckConfirm" :disabled="!checkCompleted">确定</a-button>
          </div>
        </a-modal>

        <!-- 删除确认弹窗 -->
        <a-modal
          v-model:open="deleteConfirmModal"
          title="删除模板"
          width="400px"
          ok-text="确认"
          cancel-text="取消"
          @ok="handleDeleteConfirm"
          @cancel="handleDeleteCancel"
        >
          <div class="delete-confirm-content">
            <exclamation-circle-outlined style="font-size: 15px; color: #faad14; margin-right: 8px;" />
            <span style="font-size: 15px; color: #333;">删除后不可恢复，确认继续！</span>
          </div>
        </a-modal>

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
                    <a class="card-detail" @click="handleDetail(item)">详情</a>
                  </div>
                  <div class="card-tags">
                    <a-tag v-for="tag in item.tags" :key="tag" color="blue">
                      {{ tag }}
                    </a-tag>
                  </div>
                  <div class="card-description">{{ item.description }}</div>
                  <div class="card-stats">
                    已创建场景：<span class="stats-count">{{ item.sceneCount }}个</span>
                  </div>
                  <div class="card-actions">
                    <a class="action-item" @click="handleCreateScene(item)">创建场景</a>
                    <a class="action-item" @click="handleTemplateCheck(item)">模板检测</a>
                    <a-dropdown trigger="click">
                      <a class="action-item" @click.prevent>
                        更多
                        <down-outlined />
                      </a>
                      <template #overlay>
                        <a-menu @click="handleMoreMenuClick($event, item)">
                          <a-menu-item key="copy">复制模板</a-menu-item>
                          <a-menu-item key="delete" class="delete-menu-item">删除模板</a-menu-item>
                        </a-menu>
                      </template>
                    </a-dropdown>
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
              :show-total="(total: number) => `共 ${total} 条`"
              :page-size-options="['10', '20', '50']"
              :show-less-items="false"
              :locale="{
                items_per_page: '条/页',
                jump_to: '跳转至',
                page: '页',
              }"
              @change="handlePageChange"
              @show-size-change="handlePageSizeChange"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import type { FormInstance, Rule } from 'ant-design-vue/es/form';
import { message } from 'ant-design-vue';
import { PlusOutlined, DownOutlined, CheckOutlined, LoadingOutlined, CheckCircleFilled, ExclamationCircleOutlined } from '@ant-design/icons-vue';
import dayjs, { type Dayjs } from 'dayjs';

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

interface CreateForm {
  templateName: string;
  bankId: string | null;
  orgId: string | null;
  sceneName: string;
  sceneShortName: string;
  sceneCode: string;
  tags: string[];
  expireDate: Dayjs | null;
  targetCustomer: string;
  applicableActivity: string;
  financialProduct: string;
}

interface BlankForm {
  templateName: string;
  templateType: string | null;
  tags: string[];
  followType: string | null;
  description: string;
  targetCustomer: string;
  applicableActivity: string;
  financialProduct: string;
}

interface ReferenceForm {
  templateName: string;
  referenceScene: string | null;
  templateType: string | null;
  tags: string[];
  followType: string | null;
  description: string;
  targetCustomer: string;
  applicableActivity: string;
  financialProduct: string;
}

const activeTab = ref('all');
const searchKeyword = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(88);
const selectedSubItem = ref('');

// 新建场景弹窗相关
const createModalVisible = ref(false);
const createFormRef = ref<FormInstance>();
const isCreateScene = ref(false); // 区分是新建模板还是创建场景
const createForm = reactive<CreateForm>({
  templateName: '',
  bankId: null,
  orgId: null,
  sceneName: '',
  sceneShortName: '',
  sceneCode: '',
  tags: [],
  expireDate: null,
  targetCustomer: '',
  applicableActivity: '',
  financialProduct: '',
});

// 下拉菜单状态
const createDropdownOpen = ref(false);

// 空白模板表单相关
const blankModalVisible = ref(false);
const blankFormRef = ref<FormInstance>();
const blankForm = reactive<BlankForm>({
  templateName: '',
  templateType: null,
  tags: [],
  followType: null,
  description: '',
  targetCustomer: '',
  applicableActivity: '',
  financialProduct: '',
});

// 引用现有场景表单相关
const referenceModalVisible = ref(false);
const referenceFormRef = ref<FormInstance>();
const referenceForm = reactive<ReferenceForm>({
  templateName: '',
  referenceScene: null,
  templateType: null,
  tags: [],
  followType: null,
  description: '',
  targetCustomer: '',
  applicableActivity: '',
  financialProduct: '',
});

// 弹窗标题
const modalTitle = computed(() => (isCreateScene.value ? '创建场景' : '新建场景模板'));

// 级联选择器数据（用于模板类型选择）
const cascaderOptions = computed(() => {
  return menuCategories.map((category) => ({
    name: category.name,
    value: category.name,
    children: category.items.map((item) => ({
      name: item,
      value: item,
      isLeaf: true,
    })),
  }));
});

// 模板检测相关
const checkModalVisible = ref(false);
const checkCompleted = ref(false);
const currentTemplate = ref<TemplateItem | null>(null);

// 检测步骤数据
interface CheckItem {
  name: string;
  completed: boolean;
}

interface CheckStep {
  title: string;
  completed: boolean;
  checking: boolean;
  items: CheckItem[];
}

const checkSteps = reactive<CheckStep[]>([
  {
    title: '基本设置',
    completed: false,
    checking: false,
    items: [
      { name: '基本信息是否填写完毕', completed: false },
    ],
  },
  {
    title: '通用设置',
    completed: false,
    checking: false,
    items: [
      { name: '必填参数是否全部设置', completed: false },
    ],
  },
  {
    title: '意图行为',
    completed: false,
    checking: false,
    items: [
      { name: '意图配置检测', completed: false },
    ],
  },
  {
    title: '流程设计',
    completed: false,
    checking: false,
    items: [
      { name: '主流程是否闭环', completed: false },
      { name: '话术文本检测', completed: false },
    ],
  },
  {
    title: 'QA 定义',
    completed: false,
    checking: false,
    items: [
      { name: '是否添加 QA', completed: false },
      { name: '跳转主流程 QA 的主流程节点检测', completed: false },
    ],
  },
  {
    title: '用户分类',
    completed: false,
    checking: false,
    items: [
      { name: '分类规则检测', completed: false },
    ],
  },
]);

// 表单验证规则
const createRules: Record<string, Rule[]> = {
  templateName: [{ required: true, message: '请输入模板名称', trigger: 'blur' }],
  bankId: [{ required: true, message: '请选择银行', trigger: 'change' }],
  orgId: [{ required: true, message: '请选择归属机构', trigger: 'change' }],
  sceneName: [{ required: true, message: '请输入场景名称', trigger: 'blur' }],
  sceneShortName: [{ required: true, message: '请输入场景简称', trigger: 'blur' }],
  sceneCode: [{ required: true, message: '请输入场景编号', trigger: 'blur' }],
};

// 空白模板表单验证规则
const blankRules: Record<string, Rule[]> = {
  templateName: [{ required: true, message: '请输入模板名称', trigger: 'blur' }],
  templateType: [{ required: true, message: '请选择模板类型', trigger: 'change' }],
  followType: [{ required: true, message: '请选择跟进方式', trigger: 'change' }],
  description: [{ required: true, message: '请输入模板描述', trigger: 'blur' }],
};

// 引用现有场景表单验证规则
const referenceRules: Record<string, Rule[]> = {
  templateName: [{ required: true, message: '请输入模板名称', trigger: 'blur' }],
  referenceScene: [{ required: true, message: '请选择引用场景', trigger: 'change' }],
  templateType: [{ required: true, message: '请选择模板类型', trigger: 'change' }],
  followType: [{ required: true, message: '请选择跟进方式', trigger: 'change' }],
  description: [{ required: true, message: '请输入模板描述', trigger: 'blur' }],
};

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

// 下拉菜单点击
const handleCreateMenuClick = ({ key }: { key: string }) => {
  createDropdownOpen.value = false;
  if (key === 'blank') {
    blankModalVisible.value = true;
  } else if (key === 'reference') {
    referenceModalVisible.value = true;
  }
};

// 新建场景模板（顶部按钮）
const handleCreate = () => {
  isCreateScene.value = false;
  createModalVisible.value = true;
  createForm.templateName = '';
};

// 创建场景（卡片按钮）
const handleCreateScene = (item: TemplateItem) => {
  isCreateScene.value = true;
  createModalVisible.value = true;
  // 将选中的模板名称填充到表单中
  createForm.templateName = item.title;
};

// 关闭新建弹窗
const handleCreateCancel = () => {
  createModalVisible.value = false;
  createFormRef.value?.resetFields();
  createForm.templateName = '';
  createForm.bankId = null;
  createForm.orgId = null;
  createForm.sceneName = '';
  createForm.sceneShortName = '';
  createForm.sceneCode = '';
  createForm.tags = [];
  createForm.expireDate = null;
  createForm.targetCustomer = '';
  createForm.applicableActivity = '';
  createForm.financialProduct = '';
};

// 关闭空白模板弹窗
const handleBlankCancel = () => {
  blankModalVisible.value = false;
  blankFormRef.value?.resetFields();
  blankForm.templateName = '';
  blankForm.templateType = null;
  blankForm.tags = [];
  blankForm.followType = null;
  blankForm.description = '';
  blankForm.targetCustomer = '';
  blankForm.applicableActivity = '';
  blankForm.financialProduct = '';
};

// 提交空白模板
const handleBlankSubmit = async () => {
  try {
    await blankFormRef.value?.validate();
    console.log('提交空白模板:', blankForm);
    // TODO: 调用 API 保存场景
    blankModalVisible.value = false;
    blankFormRef.value?.resetFields();
  } catch (error) {
    console.log('表单验证失败:', error);
  }
};

// 关闭引用现有场景弹窗
const handleReferenceCancel = () => {
  referenceModalVisible.value = false;
  referenceFormRef.value?.resetFields();
  referenceForm.templateName = '';
  referenceForm.referenceScene = null;
  referenceForm.templateType = null;
  referenceForm.tags = [];
  referenceForm.followType = null;
  referenceForm.description = '';
  referenceForm.targetCustomer = '';
  referenceForm.applicableActivity = '';
  referenceForm.financialProduct = '';
};

// 引用场景变化时带出模板类型
const handleReferenceSceneChange = (value: string) => {
  // 根据选择的场景带出对应的模板类型（级联格式：[分类名，子项名]）
  const typeMap: Record<string, string[]> = {
    '1': ['信用卡', '信用卡激活'],
    '2': ['回访', '开卡回访'],
    '3': ['信用卡', '信用卡换卡'],
    '4': ['存款', '存款到期提醒'],
    '5': ['信用卡', '信用卡促活'],
  };
  referenceForm.templateType = typeMap[value] || null;
};

// 提交引用现有场景
const handleReferenceSubmit = async () => {
  try {
    await referenceFormRef.value?.validate();
    console.log('提交引用现有场景:', referenceForm);
    // TODO: 调用 API 保存场景
    referenceModalVisible.value = false;
    referenceFormRef.value?.resetFields();
  } catch (error) {
    console.log('表单验证失败:', error);
  }
};

// 提交新建场景
const handleCreateSubmit = async () => {
  try {
    await createFormRef.value?.validate();
    console.log('提交新建场景:', createForm);
    // TODO: 调用 API 保存场景
    createModalVisible.value = false;
    createFormRef.value?.resetFields();
  } catch (error) {
    console.log('表单验证失败:', error);
  }
};

// 查看详情
const handleDetail = (item: TemplateItem) => {
  console.log('查看详情:', item);
};

// 模板检测
const handleTemplateCheck = (item: TemplateItem) => {
  currentTemplate.value = item;
  checkModalVisible.value = true;
  checkCompleted.value = false;
  // 重置所有步骤状态
  resetCheckSteps();
  // 开始检测
  startCheck();
};

// 重置检测步骤
const resetCheckSteps = () => {
  checkSteps.forEach((step) => {
    step.completed = false;
    step.checking = false;
    step.items.forEach((item) => {
      item.completed = false;
    });
  });
};

// 开始检测
const startCheck = async () => {
  for (let i = 0; i < checkSteps.length; i++) {
    await checkStep(i);
  }
  checkCompleted.value = true;
};

// 检测单个步骤
const checkStep = (index: number): Promise<void> => {
  return new Promise((resolve) => {
    checkSteps[index].checking = true;
    
    // 模拟检测延迟
    setTimeout(() => {
      checkSteps[index].checking = false;
      checkSteps[index].completed = true;
      // 完成该步骤下的所有子项
      checkSteps[index].items.forEach((item) => {
        item.completed = true;
      });
      resolve();
    }, 100 + index * 100); // 每个步骤间隔 500ms + 递增延迟
  });
};

// 取消检测
const handleCheckCancel = () => {
  checkModalVisible.value = false;
  checkCompleted.value = false;
  currentTemplate.value = null;
  resetCheckSteps();
};

// 确认检测
const handleCheckConfirm = () => {
  console.log('检测确认:', currentTemplate.value);
  checkModalVisible.value = false;
  checkCompleted.value = false;
  currentTemplate.value = null;
  resetCheckSteps();
};

// 更多操作下拉菜单点击
const deleteConfirmModal = ref(false);
const currentDeleteItem = ref<TemplateItem | null>(null);

const handleMoreMenuClick = ({ key }: { key: string }, item: TemplateItem) => {
  if (key === 'copy') {
    console.log('复制模板:', item);
    // TODO: 复制模板逻辑
    message.success('复制成功');
  } else if (key === 'delete') {
    currentDeleteItem.value = item;
    deleteConfirmModal.value = true;
  }
};

// 确认删除
const handleDeleteConfirm = () => {
  console.log('确认删除:', currentDeleteItem.value);
  // TODO: 调用 API 删除模板
  deleteConfirmModal.value = false;
  currentDeleteItem.value = null;
};

// 取消删除
const handleDeleteCancel = () => {
  deleteConfirmModal.value = false;
  currentDeleteItem.value = null;
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
  height: calc(100vh - 64px);
  display: flex;
  flex-direction: column;
}

/* 左右布局 */
.layout-content {
  display: flex;
  flex: 1;
  height: 100%;
  overflow: hidden;
}

.left-menu-col {
  width: 200px;
  padding-right: 0px;
  margin-top: 16px;
  margin-left: 16px;
  display: flex;
  flex-direction: column;
  height: 96%;
  min-width: 200px;
}

.right-content-col {
  flex: 1;
  padding-left: 0;
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  min-width: 0;
}

.content-scroll-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  border: 1px solid #d9d9d9;
  margin: 16px;
  height: 100%;
}

/* 左侧菜单 */
.left-menu {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  border: 1px solid #d9d9d9;
  padding: 0;
  height: calc(100vh - 64px);
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
  padding: 16px 24px 0 24px;
  flex-shrink: 0;
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
  padding: 16px 24px;
  flex-shrink: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.create-btn {
  float: right;
}

.create-btn :deep(.anticon-down) {
  margin-left: 4px;
}

/* 卡片列表 */
.card-list {
  padding: 0 24px 16px 24px;
  flex: 1;
}

.template-card {
  height: 100%;
  border: 1px solid #d9d9d9;
  border-radius: 4px;
}

.template-card :deep(.ant-card-body) {
  padding: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.card-detail {
  color: #1890ff;
  cursor: pointer;
  font-size: 13px;
  text-decoration: none;
}

.card-detail:hover {
  color: #40a9ff;
}

.card-tags {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 8px;
}

.card-description {
  font-size: 13px;
  color: #666;
  line-height: 1.6;
  margin-bottom: 16px;
  min-height: 40px;
}

.card-stats {
  font-size: 12px;
  color: #999;
  margin-bottom: 12px;
}

.stats-count {
  color: #1890ff;
  font-weight: 600;
  font-size: 14px;
}

.card-actions {
  display: flex;
  justify-content: space-between;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}

.action-item {
  color: #1890ff;
  cursor: pointer;
  font-size: 13px;
  text-decoration: none;
  padding: 2px 8px;
  border-radius: 2px;
  flex: 1;
  text-align: center;
}

.action-item:hover {
  color: #40a9ff;
}

.action-item :deep(.anticon-down) {
  font-size: 12px;
  margin-left: 4px;
}

/* 删除菜单项样式 */
:deep(.delete-menu-item) {
  color: #ff4d4f !important;
}

:deep(.delete-menu-item:hover) {
  background: #fff1f0 !important;
}

/* 删除确认弹窗 */
.delete-confirm-content {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 10px 0;
}

/* 分页 */
.pagination-section {
  padding: 16px 24px;
  display: flex;
  justify-content: flex-end;
  flex-shrink: 0;
  border-top: 1px solid #f0f0f0;
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

.pagination-section :deep(.ant-pagination-options-quick-jumper) {
  color: #666;
}

.pagination-section :deep(.ant-pagination-options-size-changer) {
  color: #666;
}

/* 修改分页文本显示 */
.pagination-section :deep(.ant-select-selector) {
  border-color: #d9d9d9 !important;
}

/* 修改每页条数文本 */
.pagination-section :deep(.ant-select-selection-item) {
  font-size: 13px;
}

.pagination-section :deep(.ant-pagination-options-quick-jumper) {
  margin-left: 16px;
}

.pagination-section :deep(.ant-pagination-options-quick-jumper input) {
  width: 50px !important;
  margin: 0 8px;
}

/* 新建场景弹窗 */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
  margin-top: 16px;
}

/* 模板检测弹窗 */
.check-steps {
  padding: 20px 40px;
}

.check-step {
  position: relative;
  margin-bottom: 24px;
}

.check-step:last-child {
  margin-bottom: 0;
}

.step-header {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.step-icon {
  width: 24px;
  height: 24px;
  border: 2px solid #d9d9d9;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  font-size: 14px;
  transition: all 0.3s;
}

.step-icon.checking {
  border-color: #1890ff;
  color: #1890ff;
}

.step-icon.completed {
  border-color: #52c41a;
  background: #52c41a;
  color: #fff;
}

.step-title {
  font-size: 15px;
  color: #999;
  font-weight: 500;
  transition: all 0.3s;
}

.step-title.completed {
  color: #333;
  font-weight: 600;
}

.step-items {
  margin-left: 36px;
}

.step-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  font-size: 13px;
  color: #999;
  transition: all 0.3s;
}

.step-item:last-child {
  margin-bottom: 0;
}

.step-item.completed {
  color: #333;
}

.item-icon {
  font-size: 16px;
  margin-right: 8px;
  color: #d9d9d9;
  transition: all 0.3s;
}

.step-item.completed .item-icon {
  color: #52c41a;
}

/* 连接线 */
.check-step:not(:last-child)::after {
  content: '';
  position: absolute;
  left: 11px;
  top: 28px;
  bottom: -16px;
  width: 2px;
  background: #f0f0f0;
}
</style>
