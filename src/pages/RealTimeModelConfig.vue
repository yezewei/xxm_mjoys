<template>
  <div class="real-time-model-config">
    <!-- 页面头部 -->
    <div class="config-header">
      <div class="header-left">
        <a-button type="link" @click="handleGoBack" class="back-btn">
          <left-outlined />
          返回
        </a-button>
        <h2 class="page-title">{{ modelInfo.name }}</h2>
      </div>
    </div>

    <p class="config-desc">{{ modelInfo.description }}</p>

    <!-- 语料管理 -->
    <div class="config-content">
      <div class="content-header">
        <h3 class="content-title">语料管理</h3>
      </div>

      <div class="tab-toolbar">
        <div class="toolbar-left">
          <a-input
            v-model:value="searchText"
            placeholder="搜索语料"
            allow-clear
            style="width: 240px"
          >
            <template #prefix>
              <search-outlined />
            </template>
          </a-input>
        </div>
        <a-button type="primary" @click="handleAdd">
          <plus-outlined />
          新增语料
        </a-button>
      </div>

      <a-table
        :columns="columns"
        :data-source="filteredList"
        row-key="id"
        :pagination="{ pageSize: 10, showTotal: (total: number) => `共 ${total} 条` }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'action'">
            <a-space>
              <a @click="handleEdit(record)">编辑</a>
              <a-popconfirm title="确认删除该语料？" @confirm="handleDelete(record.id)">
                <a style="color: #ff4d4f">删除</a>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </div>

    <!-- 新增/编辑弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="editId !== null ? '编辑语料' : '新增语料'"
      @ok="handleModalOk"
      @cancel="modalVisible = false"
      :width="480"
    >
      <a-form
        :model="formData"
        :label-col="{ span: 5 }"
        :wrapper-col="{ span: 17 }"
        style="margin-top: 24px"
      >
        <a-form-item label="语料内容" name="content" :rules="[{ required: true, message: '请输入语料内容' }]">
          <a-input v-model:value="formData.content" placeholder="请输入语料内容" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import { LeftOutlined, SearchOutlined, PlusOutlined } from '@ant-design/icons-vue';

// ==================== 类型定义 ====================

interface CorpusItem {
  id: number;
  content: string;
  createdAt: string;
}

interface ModelInfo {
  name: string;
  description: string;
}

// ==================== 路由 ====================

const route = useRoute();
const router = useRouter();

const modelType = computed(() => (route.query.type as string) || 'script-assistant');

const modelInfoMap: Record<string, ModelInfo> = {
  'script-assistant': {
    name: '话术助手模型',
    description: 'AI实时识别通话中是否为话术助手接听，检测到话术助手自动触发挂机，避免无效通话消耗资源。',
  },
  'complaint-abuse': {
    name: '投诉骂人模型',
    description: 'AI实时识别通话中客户是否出现投诉或辱骂行为，检测到异常情绪自动触发挂机，保护品牌形象。',
  },
};

const modelInfo = reactive<ModelInfo>({ name: '', description: '' });

onMounted(() => {
  const info = modelInfoMap[modelType.value];
  if (info) {
    modelInfo.name = info.name;
    modelInfo.description = info.description;
  }
});

// ==================== 表格 ====================

const searchText = ref('');
let idCounter = 100;

const columns = [
  { title: '语料内容', dataIndex: 'content', key: 'content' },
  { title: '创建时间', dataIndex: 'createdAt', key: 'createdAt', width: 200 },
  { title: '操作', dataIndex: 'action', key: 'action', width: 140, fixed: 'right' as const },
];

const dataList = reactive<CorpusItem[]>(
  modelType.value === 'script-assistant'
    ? [
        { id: 1, content: '话术助手', createdAt: '2026-06-01 10:00:00' },
        { id: 2, content: '智能助手', createdAt: '2026-06-01 10:05:00' },
        { id: 3, content: '语音助手', createdAt: '2026-06-02 09:30:00' },
        { id: 4, content: '自动应答', createdAt: '2026-06-03 14:00:00' },
        { id: 5, content: 'AI接听', createdAt: '2026-06-04 11:20:00' },
        { id: 6, content: '系统接听', createdAt: '2026-06-05 16:00:00' },
        { id: 7, content: '请问是人工客服吗', createdAt: '2026-06-06 10:10:00' },
        { id: 8, content: '转人工服务', createdAt: '2026-06-06 10:15:00' },
        { id: 9, content: '你是机器人吗', createdAt: '2026-06-07 10:00:00' },
        { id: 10, content: '我要和真人说话', createdAt: '2026-06-07 09:00:00' },
        { id: 11, content: '不要用机器回复我', createdAt: '2026-06-08 14:00:00' },
      ]
    : [
        { id: 1, content: '投诉', createdAt: '2026-06-01 10:00:00' },
        { id: 2, content: '骂人', createdAt: '2026-06-01 10:05:00' },
        { id: 3, content: '举报', createdAt: '2026-06-02 09:30:00' },
        { id: 4, content: '骗子', createdAt: '2026-06-03 14:00:00' },
        { id: 5, content: '骚扰', createdAt: '2026-06-04 11:20:00' },
        { id: 6, content: '工商', createdAt: '2026-06-05 09:00:00' },
        { id: 7, content: '消协', createdAt: '2026-06-05 09:05:00' },
        { id: 8, content: '12315', createdAt: '2026-06-06 10:00:00' },
        { id: 9, content: '我要投诉你们', createdAt: '2026-06-07 10:10:00' },
        { id: 10, content: '你们是骗子吧', createdAt: '2026-06-07 10:15:00' },
        { id: 11, content: '我要去12315告你们', createdAt: '2026-06-08 10:00:00' },
        { id: 12, content: '天天打电话烦不烦', createdAt: '2026-06-08 09:00:00' },
        { id: 13, content: '滚', createdAt: '2026-06-09 14:00:00' },
        { id: 14, content: '再打我电话就报警', createdAt: '2026-06-09 11:00:00' },
      ]
);

const filteredList = computed(() => {
  if (!searchText.value) return dataList;
  return dataList.filter((item) => item.content.includes(searchText.value));
});

// ==================== 弹窗 ====================

const modalVisible = ref(false);
const editId = ref<number | null>(null);
const formData = reactive({ content: '' });

const handleAdd = () => {
  editId.value = null;
  formData.content = '';
  modalVisible.value = true;
};

const handleEdit = (record: CorpusItem) => {
  editId.value = record.id;
  formData.content = record.content;
  modalVisible.value = true;
};

const handleModalOk = () => {
  if (!formData.content.trim()) {
    message.warning('请输入语料内容');
    return;
  }

  const now = new Date().toLocaleString('zh-CN', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  }).replace(/\//g, '-');

  if (editId.value !== null) {
    const idx = dataList.findIndex((item) => item.id === editId.value);
    if (idx !== -1) dataList[idx].content = formData.content;
    message.success('语料编辑成功');
  } else {
    dataList.unshift({ id: ++idCounter, content: formData.content, createdAt: now });
    message.success('语料新增成功');
  }

  modalVisible.value = false;
};

const handleDelete = (id: number) => {
  const idx = dataList.findIndex((item) => item.id === id);
  if (idx !== -1) dataList.splice(idx, 1);
  message.success('语料删除成功');
};

const handleGoBack = () => {
  router.push('/real-time-model');
};
</script>

<style scoped>
.real-time-model-config {
  padding: 24px;
}

.config-header {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.back-btn {
  padding: 0;
  font-size: 14px;
}

.page-title {
  font-size: 20px;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0;
}

.config-desc {
  font-size: 13px;
  color: #8c8c8c;
  margin: 0 0 24px 0;
  padding-left: 52px;
}

.config-content {
  background: #fff;
  border-radius: 8px;
  padding: 20px 24px 24px;
}

.content-header {
  margin-bottom: 16px;
}

.content-title {
  font-size: 16px;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0;
}

.tab-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.config-content :deep(.ant-table-thead > tr > th) {
  background: #e6f4ff;
  color: #262626;
  font-weight: 600;
}

.config-content :deep(.ant-table-tbody > tr:hover > td) {
  background: #f0f5ff;
}
</style>
