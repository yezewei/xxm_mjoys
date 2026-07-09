<template>
  <div class="customer-detail">
    <!-- 顶部卡片 -->
    <a-card :bordered="false" class="header-card">
      <div class="customer-header">
        <div class="customer-avatar">
          <div class="avatar-circle">
            <span class="avatar-text">{{ customerDetail.customerName?.charAt(0) || '客' }}</span>
          </div>
          <div class="customer-name">
            <h2>{{ customerDetail.customerName }}</h2>
            <span class="customer-no">{{ customerDetail.customerNo }}</span>
          </div>
        </div>
        <div class="header-actions">
          <a-button @click="handleBack">
            <arrow-left-outlined />
            返回
          </a-button>
          <a-button type="primary" @click="handleEdit">
            <edit-outlined />
            编辑
          </a-button>
        </div>
      </div>
    </a-card>

    <a-row :gutter="16" style="margin-top: 16px">
      <!-- 左侧主要内容 -->
      <a-col :span="16">
        <!-- 基本信息 -->
        <a-card :bordered="false" class="content-card" title="基本信息">
          <a-descriptions :column="2" size="medium">
            <a-descriptions-item label="客户号">
              <span class="info-value">{{ customerDetail.customerNo }}</span>
            </a-descriptions-item>
            <a-descriptions-item label="性别">
              <span class="info-value">{{ customerDetail.gender }}</span>
            </a-descriptions-item>
            <a-descriptions-item label="联系方式">
              <span class="info-value">{{ customerDetail.contactPhone }}</span>
            </a-descriptions-item>
            <a-descriptions-item label="银行机构号">
              <span class="info-value">{{ customerDetail.orgCode }}</span>
            </a-descriptions-item>
            <a-descriptions-item label="机构名称">
              <span class="info-value">{{ customerDetail.orgName }}</span>
            </a-descriptions-item>
            <a-descriptions-item label="直营坐席">
              <span class="info-value">{{ customerDetail.seatName || customerDetail.seatNo || '-' }}</span>
            </a-descriptions-item>
            <a-descriptions-item label="备注" :span="2">
              <span class="info-value remark">{{ customerDetail.remark || '-' }}</span>
            </a-descriptions-item>
          </a-descriptions>
        </a-card>

        <!-- 客户标签 -->
        <a-card :bordered="false" class="content-card" style="margin-top: 16px" title="客户标签">
          <template #extra>
            <a-button type="link" size="small" @click="handleEditTags">
              <edit-outlined />
              编辑标签
            </a-button>
          </template>
          
          <!-- 银行标签 -->
          <div class="tag-category">
            <div class="tag-category-header">
              <div class="tag-category-title">
                <bank-outlined class="category-icon bank-icon" />
                <span>银行标签</span>
              </div>
              <span class="tag-count">{{ customerDetail.tags?.bankTags?.length || 0 }} 个</span>
            </div>
            <div class="tag-list">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.bankTags"
                :key="index"
                color="blue"
                class="tag-item"
              >
                {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
              </a-tag>
              <a-empty v-if="customerDetail.tags?.bankTags?.length === 0" description="暂无银行标签" :image="false" style="margin-left: 0;" />
            </div>
          </div>

          <!-- AI 外呼标签 -->
          <div class="tag-category">
            <div class="tag-category-header">
              <div class="tag-category-title">
                <robot-outlined class="category-icon ai-icon" />
                <span>AI 外呼标签</span>
              </div>
              <span class="tag-count">{{ customerDetail.tags?.aiCallTags?.length || 0 }} 个</span>
            </div>
            <div class="tag-list">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.aiCallTags"
                :key="index"
                color="cyan"
                class="tag-item"
              >
                {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
              </a-tag>
              <a-empty v-if="customerDetail.tags?.aiCallTags?.length === 0" description="暂无 AI 外呼标签" :image="false" style="margin-left: 0;" />
            </div>
          </div>

          <!-- 人工外呼标签 -->
          <div class="tag-category">
            <div class="tag-category-header">
              <div class="tag-category-title">
                <phone-outlined class="category-icon manual-icon" />
                <span>人工外呼标签</span>
              </div>
              <span class="tag-count">{{ customerDetail.tags?.manualCallTags?.length || 0 }} 个</span>
            </div>
            <div class="tag-list">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.manualCallTags"
                :key="index"
                color="green"
                class="tag-item"
              >
                {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
              </a-tag>
              <a-empty v-if="customerDetail.tags?.manualCallTags?.length === 0" description="暂无人工外呼标签" :image="false" style="margin-left: 0;" />
            </div>
          </div>

          <!-- 自定义标签 -->
          <div class="tag-category">
            <div class="tag-category-header">
              <div class="tag-category-title">
                <tags-outlined class="category-icon custom-icon" />
                <span>自定义标签</span>
              </div>
              <span class="tag-count">{{ customerDetail.tags?.customTags?.length || 0 }} 个</span>
            </div>
            <div class="tag-list">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.customTags"
                :key="index"
                color="orange"
                class="tag-item"
              >
                {{ tag.tagValue ? `${tag.tagName}:${tag.tagValue}` : tag.tagName }}
              </a-tag>
              <a-empty v-if="customerDetail.tags?.customTags?.length === 0" description="暂无自定义标签" :image="false" style="margin-left: 0;" />
            </div>
          </div>
        </a-card>

        <!-- 统计数据 -->
        <a-card :bordered="false" class="content-card" style="margin-top: 16px" title="统计数据">
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-icon call-icon">
                <phone-outlined />
              </div>
              <div class="stat-info">
                <div class="stat-label">拨打次数</div>
                <div class="stat-value">{{ customerDetail.statistics?.callCount || 0 }}</div>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon follow-icon">
                <message-outlined />
              </div>
              <div class="stat-info">
                <div class="stat-label">跟进次数</div>
                <div class="stat-value">{{ customerDetail.statistics?.followCount || 0 }}</div>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon time-icon">
                <clock-circle-outlined />
              </div>
              <div class="stat-info">
                <div class="stat-label">最后拨打</div>
                <div class="stat-value-small">{{ customerDetail.statistics?.lastCallTime || '-' }}</div>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon time-icon">
                <clock-circle-outlined />
              </div>
              <div class="stat-info">
                <div class="stat-label">最后跟进</div>
                <div class="stat-value-small">{{ customerDetail.statistics?.lastFollowTime || '-' }}</div>
              </div>
            </div>
          </div>
        </a-card>

        <!-- 关联场景 -->
        <a-card :bordered="false" class="content-card sidebar-card" style="margin-top: 16px" title="关联场景">
          <a-empty v-if="customerDetail.relations?.scenes?.length === 0" description="暂无关联场景" style="margin: 12px 0" />
          <div v-else class="relation-list">
            <div v-for="(scene, index) in customerDetail.relations?.scenes" :key="index" class="relation-item">
              <div class="relation-left">
                <div class="relation-icon scene-icon">
                  <appstore-outlined />
                </div>
                <div class="relation-info">
                  <div class="relation-name">{{ scene.sceneName }}</div>
                  <div class="relation-time">{{ scene.joinTime }}</div>
                </div>
              </div>
            </div>
          </div>
        </a-card>

        <!-- 关联任务 -->
        <a-card :bordered="false" class="content-card sidebar-card" style="margin-top: 16px" title="关联任务">
          <a-empty v-if="customerDetail.relations?.tasks?.length === 0" description="暂无关联任务" style="margin: 12px 0" />
          <div v-else class="relation-list">
            <div v-for="(task, index) in customerDetail.relations?.tasks" :key="index" class="relation-item">
              <div class="relation-left">
                <div class="relation-icon task-icon">
                  <profile-outlined />
                </div>
                <div class="relation-info">
                  <div class="relation-name">{{ task.taskName }}</div>
                  <div class="relation-time">{{ task.joinTime }}</div>
                </div>
              </div>
            </div>
          </div>
        </a-card>
      </a-col>

      <!-- 右侧边栏 - 客户动态 -->
      <a-col :span="8">
        <!-- 客户动态 -->
        <a-card :bordered="false" class="content-card" title="客户动态">
          <template #title>
            <div class="card-title-with-action">
              <span>客户动态</span>
              <a-radio-group v-model:value="timelineFilter" size="small" @change="loadCustomerTimeline">
                <a-radio-button value="all">全部</a-radio-button>
                <a-radio-button value="follow">跟进</a-radio-button>
                <a-radio-button value="call">拨打</a-radio-button>
                <a-radio-button value="import">导入</a-radio-button>
                <a-radio-button value="update">更新</a-radio-button>
              </a-radio-group>
            </div>
          </template>
          <div class="timeline-container">
            <a-timeline class="timeline">
              <a-timeline-item
                v-for="(item, index) in timelineList"
                :key="index"
                :color="getTimelineColor(item.type)"
              >
                <div class="timeline-item-wrapper">
                  <div class="timeline-item-header">
                    <span class="timeline-title">{{ item.title }}</span>
                    <span class="timeline-time">{{ item.time }}</span>
                  </div>
                  <div class="timeline-description">{{ item.description }}</div>
                  <div v-if="item.operator" class="timeline-operator">
                    <user-outlined />
                    {{ item.operator }}
                  </div>
                  <!-- 跟进记录详情 -->
                  <div v-if="item.type === 'follow' && item.followDetail" class="timeline-detail-card">
                    <a-descriptions size="small" :column="2">
                      <a-descriptions-item label="跟进方式">
                        {{ item.followDetail.followType }}
                      </a-descriptions-item>
                      <a-descriptions-item label="跟进结果">
                        <a-badge :status="item.followDetail.followResult === '成功' ? 'success' : 'default'" :text="item.followDetail.followResult" />
                      </a-descriptions-item>
                      <a-descriptions-item label="下次联系时间" :span="2">
                        {{ item.followDetail.nextContactTime || '-' }}
                      </a-descriptions-item>
                    </a-descriptions>
                  </div>
                  <!-- 拨打记录详情 -->
                  <div v-if="item.type === 'call' && item.callDetail" class="timeline-detail-card">
                    <a-descriptions size="small" :column="2">
                      <a-descriptions-item label="拨打时长">
                        <clock-circle-outlined /> {{ item.callDetail.callDuration }}
                      </a-descriptions-item>
                      <a-descriptions-item label="拨打结果">
                        <a-badge :status="item.callDetail.callResult === '已接通' ? 'success' : 'warning'" :text="item.callDetail.callResult" />
                      </a-descriptions-item>
                      <a-descriptions-item label="场景名称" :span="2">
                        {{ item.callDetail.sceneName }}
                      </a-descriptions-item>
                    </a-descriptions>
                  </div>
                  <!-- 导入客户详情 -->
                  <div v-if="item.type === 'import' && item.importDetail" class="timeline-detail-card">
                    <div class="detail-content">
                      <div class="detail-row">
                        <span class="detail-label">客户号：</span>
                        <span class="detail-value">{{ item.importDetail.customerNo }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">客户名称：</span>
                        <span class="detail-value">{{ item.importDetail.customerName }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">性别：</span>
                        <span class="detail-value">{{ item.importDetail.gender }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">联系方式：</span>
                        <span class="detail-value">{{ item.importDetail.contactPhone }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">归属坐席：</span>
                        <span class="detail-value">{{ item.importDetail.ownershipSeat }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">直营坐席：</span>
                        <span class="detail-value">{{ item.importDetail.directSeat }}</span>
                      </div>
                      <div class="detail-row" v-if="item.importDetail.tags?.length">
                        <span class="detail-label">标签：</span>
                        <span class="detail-value">
                          <a-tag v-for="(tag, i) in item.importDetail.tags" :key="i" color="blue" size="small">{{ tag }}</a-tag>
                        </span>
                      </div>
                    </div>
                  </div>
                  <!-- 批次创建客户详情 -->
                  <div v-if="item.type === 'batch_create' && item.batchDetail" class="timeline-detail-card">
                    <div class="detail-content">
                      <div class="detail-row">
                        <span class="detail-label">批次编号：</span>
                        <span class="detail-value">{{ item.batchDetail.batchNo }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">客户号：</span>
                        <span class="detail-value">{{ item.batchDetail.customerNo }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">客户名称：</span>
                        <span class="detail-value">{{ item.batchDetail.customerName }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">性别：</span>
                        <span class="detail-value">{{ item.batchDetail.gender }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">联系方式：</span>
                        <span class="detail-value">{{ item.batchDetail.contactPhone }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">归属坐席：</span>
                        <span class="detail-value">{{ item.batchDetail.ownershipSeat }}</span>
                      </div>
                      <div class="detail-row">
                        <span class="detail-label">直营坐席：</span>
                        <span class="detail-value">{{ item.batchDetail.directSeat }}</span>
                      </div>
                      <div class="detail-row" v-if="item.batchDetail.tags?.length">
                        <span class="detail-label">标签：</span>
                        <span class="detail-value">
                          <a-tag v-for="(tag, i) in item.batchDetail.tags" :key="i" color="cyan" size="small">{{ tag }}</a-tag>
                        </span>
                      </div>
                    </div>
                  </div>
                  <!-- 更新客户详情 -->
                  <div v-if="item.type === 'update' && item.updateDetail" class="timeline-detail-card">
                    <div class="detail-content">
                      <div class="detail-row">
                        <span class="detail-label">批次编号：</span>
                        <span class="detail-value">{{ item.updateDetail.batchNo }}</span>
                      </div>
                      <div class="update-list">
                        <div v-for="(update, i) in item.updateDetail.updates" :key="i" class="update-item">
                          <span class="update-field">{{ update.field }}：</span>
                          <span class="update-old">{{ update.oldValue }}</span>
                          <span class="update-arrow">→</span>
                          <span class="update-new">{{ update.newValue }}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </a-timeline-item>
            </a-timeline>
            <div v-if="timelineList.length === 0" class="empty-timeline">
              <a-empty description="暂无客户动态" />
            </div>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 编辑标签弹窗 -->
    <a-modal
      v-model:open="editTagModalVisible"
      title="编辑标签"
      width="600px"
      @ok="handleSaveTags"
    >
      <a-form layout="vertical">
        <a-form-item label="银行标签">
          <a-select
            v-model:value="editTags.bankTags"
            mode="multiple"
            placeholder="请选择银行标签"
            style="width: 100%"
          >
            <a-select-option value="vip">VIP 客户</a-select-option>
            <a-select-option value="high_value">高价值客户</a-select-option>
            <a-select-option value="potential">潜力客户</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="AI 外呼标签">
          <a-select
            v-model:value="editTags.aiCallTags"
            mode="multiple"
            placeholder="请选择 AI 外呼标签"
            style="width: 100%"
          >
            <a-select-option value="ai_answered">AI 已接通</a-select-option>
            <a-select-option value="ai_interest">AI 有意向</a-select-option>
            <a-select-option value="ai_not_interested">AI 无意向</a-select-option>
            <a-select-option value="ai_callback">AI 需回拨</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="人工外呼标签">
          <a-select
            v-model:value="editTags.manualCallTags"
            mode="multiple"
            placeholder="请选择人工外呼标签"
            style="width: 100%"
          >
            <a-select-option value="manual_followup">人工需跟进</a-select-option>
            <a-select-option value="manual_callback">人工回拨</a-select-option>
            <a-select-option value="manual_success">人工成功</a-select-option>
            <a-select-option value="manual_failed">人工失败</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="自定义标签">
          <a-select
            v-model:value="editTags.customTags"
            mode="multiple"
            placeholder="请选择自定义标签"
            style="width: 100%"
          >
            <a-select-option value="vip">VIP 客户</a-select-option>
            <a-select-option value="high_value">高价值客户</a-select-option>
            <a-select-option value="potential">潜力客户</a-select-option>
            <a-select-option value="new">新客户</a-select-option>
            <a-select-option value="loss_risk">流失风险</a-select-option>
            <a-select-option value="complaint">投诉客户</a-select-option>
            <a-select-option value="blacklist">黑名单</a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import {
  ArrowLeftOutlined,
  EditOutlined,
  UserAddOutlined,
  PhoneOutlined,
  MessageOutlined,
  FileTextOutlined,
  UserOutlined,
  ClockCircleOutlined,
  AppstoreOutlined,
  ProfileOutlined,
  BankOutlined,
  TagsOutlined,
  RobotOutlined,
} from '@ant-design/icons-vue';
import { message, Modal } from 'ant-design-vue';

const router = useRouter();
const route = useRoute();

// 客户详情数据
const customerDetail = ref<any>({
  customerNo: '',
  customerName: '',
  gender: '',
  contactPhone: '',
  orgCode: '',
  orgName: '',
  seatNo: '',
  seatName: '',
  remark: '',
  tags: {
    bankTags: [],
    aiCallTags: [],
    manualCallTags: [],
    customTags: [],
  },
  statistics: {
    callCount: 0,
    followCount: 0,
    lastCallTime: '',
    lastFollowTime: '',
  },
  relations: {
    scenes: [],
    tasks: [],
  },
});

// 标签相关
const newCustomTag = ref<string[]>([]);
const editTagModalVisible = ref(false);
const editTags = ref({
  bankTags: [] as string[],
  aiCallTags: [] as string[],
  manualCallTags: [] as string[],
  customTags: [] as string[],
});

// 时间轴相关
const timelineFilter = ref('all');
const timelineList = ref<any[]>([]);

// 加载客户详情
const loadCustomerDetail = () => {
  const customerId = route.params.id as string;
  // TODO: 调用后端 API 获取客户详情
  // 模拟数据
  customerDetail.value = {
    customerNo: 'C202604200001',
    customerName: '张三',
    gender: '男',
    contactPhone: '138****1234',
    orgCode: 'ORG001',
    orgName: '总行营业部',
    seatNo: '001',
    seatName: '李四',
    remark: '重要客户，需重点维护',
    tags: {
      bankTags: [
        { tagCode: 'vip', tagName: 'VIP 客户', tagColor: 'blue', tagValue: '是' },
        { tagCode: 'high_value', tagName: '高价值客户', tagColor: 'red', tagValue: '是' },
        { tagCode: 'private_bank', tagName: '私人银行客户', tagColor: 'purple' },
        { tagCode: 'credit_card', tagName: '信用卡客户', tagColor: 'magenta' },
        { tagCode: 'loan', tagName: '贷款客户', tagColor: 'blue', tagValue: '住房贷款' },
        { tagCode: 'wealth_mgmt', tagName: '理财客户', tagColor: 'cyan' },
      ],
      aiCallTags: [
        { tagCode: 'ai_answered', tagName: 'AI 已接通', tagColor: 'cyan' },
        { tagCode: 'ai_interest', tagName: 'AI 有意向', tagColor: 'cyan', tagValue: '高' },
        { tagCode: 'ai_not_interested', tagName: 'AI 无意向', tagColor: 'gray' },
        { tagCode: 'ai_callback', tagName: 'AI 需回拨', tagColor: 'orange' },
        { tagCode: 'ai_refused', tagName: 'AI 拒接', tagColor: 'red' },
      ],
      manualCallTags: [
        { tagCode: 'manual_followup', tagName: '人工需跟进', tagColor: 'green', tagValue: '3次' },
        { tagCode: 'manual_callback', tagName: '人工回拨', tagColor: 'green' },
        { tagCode: 'manual_success', tagName: '人工成功', tagColor: 'lime' },
        { tagCode: 'manual_commitment', tagName: '人工承诺', tagColor: 'blue' },
      ],
      customTags: [
        { tagCode: 'potential', tagName: '潜力客户', tagColor: 'orange', tagValue: '高' },
        { tagCode: 'new', tagName: '新客户', tagColor: 'green' },
        { tagCode: 'important', tagName: '重要客户', tagColor: 'red' },
        { tagCode: 'sensitive', tagName: '敏感客户', tagColor: 'orange' },
        { tagCode: 'loss_risk', tagName: '流失风险', tagColor: 'red', tagValue: '中' },
      ],
    },
    statistics: {
      callCount: 15,
      followCount: 8,
      lastCallTime: '2026-04-20 10:30:00',
      lastFollowTime: '2026-04-19 15:20:00',
    },
    relations: {
      scenes: [
        { sceneName: '信用卡分期场景', joinTime: '2026-04-15' },
        { sceneName: '理财推荐场景', joinTime: '2026-04-10' },
      ],
      tasks: [
        { taskName: 'Q2 客户回访任务', joinTime: '2026-04-01' },
      ],
    },
  };
};

// 加载客户时间轴
const loadCustomerTimeline = () => {
  // TODO: 调用后端 API 获取时间轴数据
  // 模拟数据
  timelineList.value = [
    {
      type: 'follow',
      title: '跟进记录',
      description: '电话跟进，客户表示对理财产品感兴趣，需要进一步了解',
      time: '2026-04-20 15:30:00',
      operator: '001 - 李四',
      followDetail: {
        followType: '电话',
        followResult: '成功',
        nextContactTime: '2026-04-22 10:00:00',
      },
    },
    {
      type: 'call',
      title: '拨打记录',
      description: '外呼系统自动拨打',
      time: '2026-04-20 10:30:00',
      operator: '系统',
      callDetail: {
        callDuration: '5 分 32 秒',
        callResult: '已接通',
        sceneName: '信用卡分期场景',
      },
    },
    {
      type: 'follow',
      title: '跟进记录',
      description: '首次联系客户，了解客户基本信息和需求',
      time: '2026-04-18 14:20:00',
      operator: '002 - 王五',
      followDetail: {
        followType: '电话',
        followResult: '成功',
        nextContactTime: '2026-04-20 10:00:00',
      },
    },
    {
      type: 'import',
      title: '导入客户',
      description: '手动在页面导入了当前客户',
      time: '2026-04-15 10:00:00',
      operator: '张经理',
      importDetail: {
        customerNo: 'C202604200001',
        customerName: '张三',
        gender: '男',
        contactPhone: '138****1234',
        ownershipSeat: '李四',
        directSeat: '李四',
        tags: ['VIP 客户', '高价值客户', '住房贷款'],
      },
    },
    {
      type: 'batch_create',
      title: '批次创建客户',
      description: '系统上传了批次 B20260415001，从批次中同步了创建当前客户',
      time: '2026-04-15 09:30:00',
      operator: '系统管理员',
      batchDetail: {
        batchNo: 'B20260415001',
        customerNo: 'C202604200001',
        customerName: '张三',
        gender: '男',
        contactPhone: '138****1234',
        ownershipSeat: '李四',
        directSeat: '李四',
        tags: ['VIP 客户', '高价值客户', '住房贷款'],
      },
    },
    {
      type: 'update',
      title: '更新客户',
      description: '系统上传了批次 B20260418001，系统根据获取了当前客户最新的信息进行更新，更新内容如下',
      time: '2026-04-18 11:00:00',
      operator: '系统管理员',
      updateDetail: {
        batchNo: 'B20260418001',
        updates: [
          { field: '联系方式', oldValue: '138****1234', newValue: '139****5678' },
          { field: '标签1', oldValue: 'VIP 客户', newValue: '超级VIP 客户' },
          { field: '备注', oldValue: '重要客户', newValue: '重要客户，需重点维护' },
        ],
      },
    },
  ];

  // 根据筛选条件过滤
  if (timelineFilter.value !== 'all') {
    const typeMap: Record<string, string[]> = {
      follow: ['follow'],
      call: ['call'],
      import: ['import', 'batch_create'],
      update: ['update'],
    };
    const allowedTypes = typeMap[timelineFilter.value] || [];
    timelineList.value = timelineList.value.filter(
      (item) => allowedTypes.includes(item.type)
    );
  }
};

// 获取时间轴颜色
const getTimelineColor = (type: string) => {
  const colorMap: Record<string, string> = {
    follow: 'blue',
    call: 'green',
    import: 'purple',
    batch_create: 'cyan',
    update: 'orange',
    other: 'gray',
  };
  return colorMap[type] || 'gray';
};

// 获取时间轴图标
const getTimelineIcon = (type: string) => {
  const iconMap: Record<string, any> = {
    follow: MessageOutlined,
    call: PhoneOutlined,
    other: FileTextOutlined,
  };
  return iconMap[type] || FileTextOutlined;
};

// 返回
const handleBack = () => {
  router.back();
};

// 编辑
const handleEdit = () => {
  router.push(`/customer-edit/${route.params.id}`);
};

// 编辑标签
const handleEditTags = () => {
  editTags.value = {
    bankTags: customerDetail.value.tags?.bankTags?.map((t: any) => t.tagCode) || [],
    aiCallTags: customerDetail.value.tags?.aiCallTags?.map((t: any) => t.tagCode) || [],
    manualCallTags: customerDetail.value.tags?.manualCallTags?.map((t: any) => t.tagCode) || [],
    customTags: customerDetail.value.tags?.customTags?.map((t: any) => t.tagCode) || [],
  };
  editTagModalVisible.value = true;
};

// 添加自定义标签
const handleAddCustomTag = (tags: string[]) => {
  // TODO: 调用 API 添加标签
  message.success('添加标签成功');
  newCustomTag.value = [];
};

// 移除标签
const handleRemoveTag = (tagType: string, index: number) => {
  Modal.confirm({
    title: '确认移除',
    content: '确定要移除该标签吗？',
    onOk() {
      // TODO: 调用 API 移除标签
      message.success('移除标签成功');
      loadCustomerDetail();
    },
  });
};

// 保存标签
const handleSaveTags = () => {
  // TODO: 调用 API 保存标签
  message.success('保存标签成功');
  editTagModalVisible.value = false;
  loadCustomerDetail();
};

// 初始化
onMounted(() => {
  loadCustomerDetail();
  loadCustomerTimeline();
});
</script>

<style scoped>
.customer-detail {
  min-height: 100%;
  background: #f5f5f5;
  padding: 24px;
}

/* 顶部卡片样式 */
.header-card {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.customer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.customer-avatar {
  display: flex;
  align-items: center;
  gap: 16px;
}

.avatar-circle {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 24px;
  font-weight: 600;
}

.customer-name h2 {
  margin: 0 0 4px 0;
  font-size: 20px;
  font-weight: 600;
  color: #1f1f1f;
}

.customer-no {
  color: #999;
  font-size: 13px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

/* 内容卡片样式 */
.content-card {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border-radius: 8px;
}

.card-title-with-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title-with-action span:first-child {
  font-size: 16px;
  font-weight: 600;
  color: #1f1f1f;
}

/* 基本信息样式 */
.info-value {
  color: #333;
  font-size: 14px;
}

.info-value.remark {
  color: #666;
  line-height: 1.6;
}

/* 时间轴容器样式 */
.timeline-container {
  max-height: 700px;
  overflow-y: auto;
  padding-right: 8px;
}

.timeline-container::-webkit-scrollbar {
  width: 6px;
}

.timeline-container::-webkit-scrollbar-thumb {
  background: #d9d9d9;
  border-radius: 3px;
}

.timeline-container::-webkit-scrollbar-thumb:hover {
  background: #bfbfbf;
}

/* 时间轴样式 */
.timeline {
  padding: 8px 0;
}

.timeline-item-wrapper {
  background: #fafafa;
  padding: 16px;
  border-radius: 8px;
  margin-left: 8px;
}

.timeline-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.timeline-title {
  font-weight: 600;
  color: #1f1f1f;
  font-size: 14px;
}

.timeline-time {
  color: #999;
  font-size: 12px;
}

.timeline-description {
  color: #666;
  margin-bottom: 8px;
  font-size: 13px;
}

.timeline-operator {
  color: #999;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.timeline-detail-card {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
  background: #fff;
  border-radius: 4px;
  padding: 12px;
}

.empty-timeline {
  padding: 40px 0;
}

/* 标签分类样式 */
.tag-category {
  margin-bottom: 20px;
}

.tag-category:last-child {
  margin-bottom: 0;
}

.tag-category-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.tag-category-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #333;
  font-size: 14px;
}

.category-icon {
  font-size: 16px;
}

.bank-icon {
  color: #1890ff;
}

.ai-icon {
  color: #13c2c2;
}

.manual-icon {
  color: #52c41a;
}

.custom-icon {
  color: #fa8c16;
}

.tag-count {
  color: #999;
  font-size: 12px;
  font-weight: normal;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 32px;
}

.tag-item {
  margin: 0;
  font-size: 13px;
  padding: 4px 12px;
}

/* 统计卡片样式 */
.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #fafafa;
  border-radius: 8px;
}

.stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}

.call-icon {
  background: #e6f7ff;
  color: #1890ff;
}

.follow-icon {
  background: #f6ffed;
  color: #52c41a;
}

.time-icon {
  background: #fff7e6;
  color: #fa8c16;
}

.stat-info {
  flex: 1;
}

.stat-label {
  color: #999;
  font-size: 12px;
  margin-bottom: 4px;
}

.stat-value {
  color: #1f1f1f;
  font-size: 20px;
  font-weight: 600;
}

.stat-value-small {
  color: #333;
  font-size: 13px;
}

/* 侧边栏卡片 */
.sidebar-card {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border-radius: 8px;
}

/* 关联列表样式 */
.relation-list {
  padding: 8px 0;
}

.relation-item {
  padding: 12px;
  border-radius: 8px;
  transition: all 0.3s;
}

.relation-item:hover {
  background: #f5f5f5;
}

.relation-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.relation-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}

.scene-icon {
  background: #f9f0ff;
  color: #722ed1;
}

.task-icon {
  background: #e6fffb;
  color: #13c2c2;
}

.relation-info {
  flex: 1;
}

.relation-name {
  color: #333;
  font-size: 14px;
  margin-bottom: 4px;
}

.relation-time {
  color: #999;
  font-size: 12px;
}

/* 详情内容样式 */
.detail-content {
  font-size: 13px;
}

.detail-row {
  display: flex;
  margin-bottom: 6px;
  line-height: 1.6;
}

.detail-label {
  color: #999;
  flex-shrink: 0;
  width: 70px;
}

.detail-value {
  color: #333;
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

/* 更新列表样式 */
.update-list {
  margin-top: 8px;
}

.update-item {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  padding: 8px;
  background: #f9f9f9;
  border-radius: 4px;
  font-size: 13px;
}

.update-field {
  color: #666;
  flex-shrink: 0;
  width: 70px;
}

.update-old {
  color: #999;
  text-decoration: line-through;
  margin-right: 8px;
}

.update-arrow {
  color: #999;
  margin-right: 8px;
}

.update-new {
  color: #52c41a;
  font-weight: 500;
}
</style>
