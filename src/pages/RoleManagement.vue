<template>
  <div class="role-management">
    <!-- 搜索区域 -->
    <div class="search-area">
      <a-row :gutter="[16, 16]" align="middle">
        <a-col :span="8">
          <a-input v-model:value="searchForm.roleName" placeholder="请输入角色名称" allow-clear>
            <template #prefix>
              <search-outlined />
            </template>
          </a-input>
        </a-col>
        <a-col :span="16">
          <a-space>
            <a-button type="primary">
              <search-outlined />
              搜索
            </a-button>
            <a-button>
              <reload-outlined />
              重置
            </a-button>
          </a-space>
        </a-col>
      </a-row>
    </div>

    <!-- 表格区域 -->
    <div class="table-area">
      <!-- 操作栏 -->
      <div class="action-bar">
        <div class="action-left">
          <span class="total-count">共{{ total }}条</span>
        </div>
        <div class="action-right">
          <a-button type="primary" @click="handleAdd">
            <plus-outlined />
            新增角色
          </a-button>
        </div>
      </div>

      <!-- 表格 -->
      <a-table
        :columns="columns"
        :data-source="dataSource"
        :pagination="pagination"
        row-key="id"
        :loading="loading"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'action'">
            <a-space>
              <a @click="handleEdit(record)">编辑</a>
            </a-space>
          </template>
        </template>
      </a-table>
    </div>

    <!-- 新增/编辑弹窗 -->
    <a-modal
      v-model:open="modalVisible"
      :title="modalTitle"
      width="800px"
      :body-style="{ maxHeight: '70vh', overflow: 'auto' }"
      ok-text="保存"
      cancel-text="取消"
      @ok="handleModalOk"
      @cancel="handleModalCancel"
    >
      <a-form
        ref="formRef"
        :model="formData"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item
          label="角色名称"
          name="roleName"
          :rules="[{ required: true, message: '请输入角色名称' }]"
        >
          <a-input v-model:value="formData.roleName" placeholder="请输入角色名称" />
        </a-form-item>
        
        <a-form-item
          label="角色权限"
          name="permissions"
        >
          <div class="permission-tree">
            <a-input-search
              v-model:value="permissionSearch"
              placeholder="搜索权限"
              style="margin-bottom: 16px;"
            />
            <a-tree
              v-model:checked="formData.permissions"
              :tree-data="permissionTreeData"
              :search-value="permissionSearch"
              checkable
              :default-expand-all="true"
            />
          </div>
        </a-form-item>
        
        <a-form-item
          label="PC 端数据权限"
          name="pcDataPermissions"
        >
          <a-checkbox-group v-model:value="formData.pcDataPermissions">
            <a-checkbox value="list-desensitize">列表敏感信息脱敏</a-checkbox>
            <a-checkbox value="detail-desensitize">详情敏感信息脱敏</a-checkbox>
            <a-checkbox value="download-desensitize">下载敏感信息脱敏</a-checkbox>
            <a-checkbox value="download-encrypt">下载敏感信息加密</a-checkbox>
          </a-checkbox-group>
        </a-form-item>
        
        <a-form-item
          label="移动端数据权限"
          name="mobileDataPermissions"
        >
          <a-checkbox v-model:checked="formData.allowMobileCall">
            是否允许本机号码拨打
          </a-checkbox>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import {
  SearchOutlined,
  ReloadOutlined,
  PlusOutlined,
} from '@ant-design/icons-vue';
import type { ColumnsType } from 'ant-design-vue/es/table';
import type { FormInstance } from 'ant-design-vue';
import { message } from 'ant-design-vue';

interface RoleItem {
  key: string;
  id: number;
  roleName: string;
  createTime: string;
  updateTime: string;
}

interface PermissionTreeNode {
  key: string;
  title: string;
  children?: PermissionTreeNode[];
}

const searchForm = reactive({
  roleName: '',
});

const loading = ref(false);
const total = ref(6);

const columns: ColumnsType<RoleItem> = [
  {
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    width: 80,
    sorter: true,
  },
  {
    title: '角色名称',
    dataIndex: 'roleName',
    key: 'roleName',
    width: 200,
    sorter: true,
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    key: 'createTime',
    width: 200,
    sorter: true,
  },
  {
    title: '更新时间',
    dataIndex: 'updateTime',
    key: 'updateTime',
    width: 200,
    sorter: true,
  },
  {
    title: '操作',
    key: 'action',
    width: 100,
    align: 'center',
  },
];

const dataSource: RoleItem[] = [
  {
    key: '1',
    id: 1,
    roleName: '超级管理员',
    createTime: '2017-08-28 14:03:52',
    updateTime: '2026-03-05 15:46:08',
  },
  {
    key: '2',
    id: 2,
    roleName: '平台管理员',
    createTime: '2020-09-01 11:16:30',
    updateTime: '2026-03-05 15:46:13',
  },
  {
    key: '3',
    id: 3,
    roleName: '直营坐席',
    createTime: '2020-09-01 11:18:09',
    updateTime: '2026-01-28 14:43:56',
  },
  {
    key: '4',
    id: 4,
    roleName: 'AI 优化师',
    createTime: '2020-09-01 11:17:05',
    updateTime: '2025-12-04 10:40:12',
  },
  {
    key: '5',
    id: 5,
    roleName: '运营经理',
    createTime: '2020-09-01 11:17:59',
    updateTime: '2025-12-04 10:40:02',
  },
  {
    key: '6',
    id: 6,
    roleName: '质检员',
    createTime: '2020-09-01 11:19:00',
    updateTime: '2025-12-04 10:41:00',
  },
];

const pagination = reactive({
  total: 6,
  pageSize: 10,
  showSizeChanger: true,
  showQuickJumper: true,
  showTotal: (total: number) => `总共 ${total} 条`,
});

// 权限树数据
const permissionTreeData: PermissionTreeNode[] = [
  {
    key: 'all',
    title: '全部',
    children: [
      { key: 'home', title: '首页' },
      {
        key: 'business',
        title: '业务管理',
        children: [
          { key: 'scene-management', title: '场景管理' },
          { key: 'scene-template', title: '场景模板' },
          { key: 'org-management', title: '机构管理' },
          { key: 'workbench-settings', title: '工作台设置' },
        ],
      },
      {
        key: 'phone-work',
        title: '电话工作台',
        children: [
          { key: 'phone-work-home', title: '首页' },
          { key: 'phone-work-workbench', title: '工作台' },
        ],
      },
      {
        key: 'quality-inspection',
        title: '质检工作台',
        children: [
          { key: 'quality-home', title: '首页' },
          { key: 'quality-workbench', title: '工作台', children: [{ key: 'quality-save-manual', title: '保存人工质检结果' }] },
          {
            key: 'quality-model',
            title: '质检模型',
            children: [
              { key: 'quality-model-create', title: '新建质检模型' },
              { key: 'quality-model-rules', title: '质检规则设置' },
              { key: 'quality-model-edit', title: '编辑模型' },
              { key: 'quality-model-delete', title: '删除模型' },
            ],
          },
          {
            key: 'quality-ai-task',
            title: 'AI 质检任务',
            children: [
              { key: 'quality-ai-task-create', title: '新建 AI 质检任务' },
              { key: 'quality-ai-task-edit', title: '编辑 AI 质检任务' },
              { key: 'quality-ai-task-toggle', title: '暂停/启用 AI 质检任务' },
              { key: 'quality-ai-task-delete', title: '删除 AI 质检任务' },
            ],
          },
          {
            key: 'quality-manual-task',
            title: '人工质检任务',
            children: [
              { key: 'quality-manual-task-create', title: '新建人工质检任务' },
              { key: 'quality-manual-task-edit', title: '编辑人工质检任务' },
              { key: 'quality-manual-task-toggle', title: '暂停/启用人工质检任务' },
              { key: 'quality-manual-task-delete', title: '删除人工质检任务' },
            ],
          },
        ],
      },
      {
        key: 'seat',
        title: '坐席管理',
        children: [
          { key: 'seat-config', title: '直营坐席配置' },
          { key: 'seat-monitor', title: '坐席监控' },
          { key: 'skill-group', title: '技能组管理' },
        ],
      },
      {
        key: 'knowledge',
        title: '内置知识管理',
        children: [
          { key: 'knowledge-word', title: '内置词库' },
          { key: 'knowledge-intent', title: '内置意图' },
          { key: 'knowledge-qa', title: '内置 QA' },
          { key: 'knowledge-scene', title: '场景知识库' },
        ],
      },
      { key: 'data-lake', title: '数据湖' },
      { key: 'data-board', title: '数据看板' },
      { key: 'exception', title: '异常看板' },
      {
        key: 'engineering',
        title: '工程管理',
        children: [
          { key: 'global-service', title: '全局服务配置' },
          { key: 'system-security', title: '系统安全配置' },
          { key: 'device-management', title: '设备管理' },
          { key: 'system-monitor', title: '系统监控' },
          { key: 'route-settings', title: '路由设置' },
        ],
      },
      {
        key: 'data-engine',
        title: '数据引擎',
        children: [
          { key: 'app-management', title: '应用管理' },
          { key: 'task-management', title: '任务管理' },
          { key: 'write-off', title: '核销管理' },
          { key: 'schedule-log', title: '调度日志' },
          { key: 'external-integration', title: '外部集成管理' },
          { key: 'data-market', title: '数据市场' },
        ],
      },
      {
        key: 'platform',
        title: '平台管理',
        children: [
          { key: 'role-management', title: '角色管理' },
          { key: 'bank-account', title: '银行账号管理' },
          { key: 'platform-account', title: '平台账号管理' },
          { key: 'operation-log', title: '操作记录' },
          { key: 'menu-management', title: '菜单管理' },
        ],
      },
    ],
  },
];

// 弹窗相关
const modalVisible = ref(false);
const modalTitle = ref('');
const formRef = ref<FormInstance>();
const isEdit = ref(false);
const permissionSearch = ref('');

const formData = reactive({
  id: 0,
  roleName: '',
  permissions: [] as string[],
  pcDataPermissions: [] as string[],
  allowMobileCall: false,
});

const handleAdd = () => {
  isEdit.value = false;
  modalTitle.value = '新增角色';
  formData.id = 0;
  formData.roleName = '';
  formData.permissions = [];
  formData.pcDataPermissions = [];
  formData.allowMobileCall = false;
  modalVisible.value = true;
};

const handleEdit = (record: RoleItem) => {
  isEdit.value = true;
  modalTitle.value = '编辑角色';
  formData.id = record.id;
  formData.roleName = record.roleName;
  formData.permissions = [];
  formData.pcDataPermissions = ['list-desensitize', 'detail-desensitize'];
  formData.allowMobileCall = false;
  modalVisible.value = true;
};

const handleModalOk = () => {
  formRef.value?.validate().then(() => {
    message.success(isEdit.value ? '编辑成功' : '新增成功');
    modalVisible.value = false;
  }).catch(() => {
    // 验证失败
  });
};

const handleModalCancel = () => {
  formRef.value?.resetFields();
  modalVisible.value = false;
};
</script>

<style scoped>
.role-management {
  padding: 0;
}

.search-area {
  padding: 24px 0;
  margin-bottom: 16px;
}

.table-area {
  background: #fff;
  padding: 16px;
  border-radius: 4px;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.action-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.total-count {
  font-size: 14px;
  color: #333;
}

.action-right {
  display: flex;
  gap: 8px;
}

.permission-tree {
  height: 400px;
  min-height: 300px;
  max-height: 60vh;
  overflow: auto;
  border: 1px solid #e8e8e8;
  padding: 16px;
  border-radius: 4px;
  resize: vertical;
}
</style>
