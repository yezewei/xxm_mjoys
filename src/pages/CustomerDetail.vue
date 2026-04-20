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
        <div class="customer-tags-section">
          <!-- 银行标签 -->
          <div class="tag-group-mini">
            <span class="tag-group-label bank-label">银行标签</span>
            <div class="tag-list-mini">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.bankTags?.slice(0, 5)"
                :key="index"
                color="blue"
              >
                {{ tag.tagName }}
              </a-tag>
              <a-tag v-if="customerDetail.tags?.bankTags?.length > 5" color="blue">+{{ customerDetail.tags.bankTags.length - 5 }}</a-tag>
            </div>
          </div>
          <!-- AI 外呼标签 -->
          <div class="tag-group-mini">
            <span class="tag-group-label ai-label">AI 外呼</span>
            <div class="tag-list-mini">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.aiCallTags?.slice(0, 3)"
                :key="index"
                color="cyan"
              >
                {{ tag.tagName }}
              </a-tag>
              <a-tag v-if="customerDetail.tags?.aiCallTags?.length > 3" color="cyan">+{{ customerDetail.tags.aiCallTags.length - 3 }}</a-tag>
            </div>
          </div>
          <!-- 人工外呼标签 -->
          <div class="tag-group-mini">
            <span class="tag-group-label manual-label">人工外呼</span>
            <div class="tag-list-mini">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.manualCallTags?.slice(0, 3)"
                :key="index"
                color="green"
              >
                {{ tag.tagName }}
              </a-tag>
              <a-tag v-if="customerDetail.tags?.manualCallTags?.length > 3" color="green">+{{ customerDetail.tags.manualCallTags.length - 3 }}</a-tag>
            </div>
          </div>
          <!-- 自定义标签 -->
          <div class="tag-group-mini">
            <span class="tag-group-label custom-label">自定义标签</span>
            <div class="tag-list-mini">
              <a-tag
                v-for="(tag, index) in customerDetail.tags?.customTags?.slice(0, 3)"
                :key="index"
                color="orange"
              >
                {{ tag.tagName }}
              </a-tag>
              <a-tag v-if="customerDetail.tags?.customTags?.length > 3" color="orange">+{{ customerDetail.tags.customTags.length - 3 }}</a-tag>
            </div>
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
          <a-button @click="handleAssign">
            <user-add-outlined />
            分配
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
                <a-radio-button value="assign">分配</a-radio-button>
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
                  <!-- 分配记录详情 -->
                  <div v-if="item.type === 'assign' && item.assignDetail" class="timeline-detail-card">
                    <a-descriptions size="small" :column="2">
                      <a-descriptions-item label="原坐席">
                        {{ item.assignDetail.fromSeat }}
                      </a-descriptions-item>
                      <a-descriptions-item label="新坐席">
                        {{ item.assignDetail.toSeat }}
                      </a-descriptions-item>
                      <a-descriptions-item label="分配类型" :span="2">
                        <a-tag :color="item.assignDetail.assignType === '转移' ? 'orange' : 'blue'">
                          {{ item.assignDetail.assignType }}
                        </a-tag>
                      </a-descriptions-item>
                    </a-descriptions>
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

    <!-- 分配客户弹窗 -->
    <a-modal
      v-model:open="assignModalVisible"
      title="分配客户"
      width="500px"
      @ok="handleConfirmAssign"
    >
      <a-form layout="vertical">
        <a-form-item label="选择坐席" required>
          <a-select
            v-model:value="assignForm.seatNo"
            placeholder="请选择坐席"
          >
            <a-select-option value="001">001 - 张三</a-select-option>
            <a-select-option value="002">002 - 李四</a-select-option>
            <a-select-option value="003">003 - 王五</a-select-option>
            <a-select-option value="004">004 - 赵六</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="分配说明">
          <a-textarea
            v-model:value="assignForm.remark"
            placeholder="请输入分配说明"
            :rows="3"
          />
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
  UserSwitchOutlined,
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

// 分配相关
const assignModalVisible = ref(false);
const assignForm = ref({
  seatNo: '',
  remark: '',
});

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
        { tagCode: 'vip', tagName: 'VIP 客户', tagColor: 'blue' },
        { tagCode: 'high_value', tagName: '高价值客户', tagColor: 'red' },
      ],
      aiCallTags: [
        { tagCode: 'ai_answered', tagName: 'AI 已接通', tagColor: 'cyan' },
        { tagCode: 'ai_interest', tagName: 'AI 有意向', tagColor: 'cyan' },
      ],
      manualCallTags: [
        { tagCode: 'manual_followup', tagName: '人工需跟进', tagColor: 'green' },
      ],
      customTags: [
        { tagCode: 'potential', tagName: '潜力客户', tagColor: 'orange' },
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
      type: 'assign',
      title: '客户分配',
      description: '客户从 002 号坐席转移至 001 号坐席',
      time: '2026-04-19 09:00:00',
      operator: '管理员',
      assignDetail: {
        fromSeat: '002 - 王五',
        toSeat: '001 - 李四',
        assignType: '转移',
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
      type: 'other',
      title: '客户导入',
      description: '客户通过数据批次导入系统',
      time: '2026-04-15 10:00:00',
      operator: '系统',
    },
  ];

  // 根据筛选条件过滤
  if (timelineFilter.value !== 'all') {
    const typeMap: Record<string, string> = {
      follow: 'follow',
      call: 'call',
      assign: 'assign',
      other: 'other',
    };
    timelineList.value = timelineList.value.filter(
      (item) => item.type === typeMap[timelineFilter.value]
    );
  }
};

// 获取时间轴颜色
const getTimelineColor = (type: string) => {
  const colorMap: Record<string, string> = {
    follow: 'blue',
    call: 'green',
    assign: 'orange',
    other: 'gray',
  };
  return colorMap[type] || 'gray';
};

// 获取时间轴图标
const getTimelineIcon = (type: string) => {
  const iconMap: Record<string, any> = {
    follow: MessageOutlined,
    call: PhoneOutlined,
    assign: UserSwitchOutlined,
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

// 分配客户
const handleAssign = () => {
  assignForm.value = {
    seatNo: '',
    remark: '',
  };
  assignModalVisible.value = true;
};

// 确认分配
const handleConfirmAssign = () => {
  if (!assignForm.value.seatNo) {
    message.error('请选择坐席');
    return;
  }
  // TODO: 调用 API 分配客户
  message.success('分配客户成功');
  assignModalVisible.value = false;
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

.customer-tags-section {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  flex: 1;
  max-width: 600px;
}

.tag-group-mini {
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-width: 120px;
}

.tag-group-label {
  font-size: 12px;
  color: #999;
  font-weight: 500;
}

.bank-label {
  color: #1890ff;
}

.ai-label {
  color: #13c2c2;
}

.manual-label {
  color: #52c41a;
}

.custom-label {
  color: #fa8c16;
}

.tag-list-mini {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}

.tag-list-mini .ant-tag {
  margin: 0;
  font-size: 12px;
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
</style>
