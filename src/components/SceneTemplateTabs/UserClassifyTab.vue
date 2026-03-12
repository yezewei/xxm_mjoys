<template>
  <div class="user-classify-content">
    <div class="user-classify-wrapper">
      <!-- 左侧分类列表 -->
      <div class="classify-sidebar">
        <div class="sidebar-title">用户分类</div>
        <div
          v-for="(category, index) in userCategories"
          :key="category.id"
          :class="['category-item', { active: selectedCategoryId === category.id }]"
          @click="handleSelectCategory(category.id)"
        >
          <span class="category-name">{{ category.name }}</span>
          <div class="category-item-right">
            <a-switch
              v-model:checked="category.enabled"
              size="small"
              @click.stop="handleToggleCategoryEnabled(category)"
              :checked-children="'启用'"
              :un-checked-children="'停用'"
            />
            <a-dropdown trigger="click">
              <a-button
                type="text"
                size="small"
                class="more-action-btn"
                @click.stop
              >
                <ellipsis-outlined />
              </a-button>
              <template #overlay>
                <a-menu>
                  <a-menu-item
                    key="edit"
                    @click.stop="handleEditCategory(category, index)"
                  >
                    <edit-outlined />
                    编辑
                  </a-menu-item>
                  <a-menu-item
                    v-if="index >= 3"
                    key="delete"
                    class="delete-menu-item"
                    @click.stop="handleDeleteCategory(category)"
                  >
                    <delete-outlined />
                    删除
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </div>
        </div>
        <div class="add-category-btn" @click="handleAddCategory">
          <plus-outlined />
          添加分类
        </div>
      </div>

      <!-- 右侧规则配置区 -->
      <div class="classify-main-content">
        <!-- 顶部默认规则提示 -->
        <div class="default-rule-alert-wrapper">
          <div class="default-rule-alert">
            <exclamation-circle-outlined style="margin-right: 8px; color: #faad14;" />
            默认规则：通话意图"反向>=1"、"静音=全程"、"否定=全程"，标记客户为无意向；该规则优先级最高
          </div>
          <div class="save-btn-top-right">
            <a-button type="primary" @click="handleSaveClassify">
              <save-outlined />
              保存
            </a-button>
          </div>
        </div>

        <!-- 规则列表区域 -->
        <div class="rule-list-container">
          <!-- 暂无数据提示 -->
          <a-empty v-if="currentCategoryRules.length === 0 && editingRules.length === 0" description="暂无数据" />

          <!-- 已保存的规则列表 -->
          <div v-if="currentCategoryRules.length > 0" class="saved-rule-list">
            <div
              v-for="(rule, index) in currentCategoryRules"
              :key="rule.id"
              class="rule-item"
            >
              <div class="rule-header">
                <span class="rule-index">表达式{{ index + 1 }}</span>
                <a-popconfirm
                  title="确定删除该规则？"
                  ok-text="确定"
                  cancel-text="取消"
                  @confirm="handleDeleteRule(rule)"
                >
                  <a-button type="text" class="delete-btn">
                    <delete-outlined />
                  </a-button>
                </a-popconfirm>
              </div>
              <div class="rule-content">
                <!-- 条件列表 -->
                <div class="condition-display-list">
                  <div
                    v-for="(condition, cIndex) in (rule.conditions || [])"
                    :key="cIndex"
                    class="condition-display-item"
                  >
                    <span class="condition-field">{{ condition.fieldType }}</span>
                    <span class="condition-operator">{{ condition.operator }}</span>
                    <span class="condition-value">{{ condition.value }}</span>
                    <span v-if="cIndex < (rule.conditions || []).length - 1" class="condition-connector">且</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 编辑中的规则列表 -->
          <div v-if="editingRules.length > 0" class="editing-rule-list">
            <div
              v-for="(rule, ruleIndex) in editingRules"
              :key="rule.id"
              class="rule-item-editing"
            >
              <div class="rule-header">
                <span class="rule-index">表达式{{ ruleIndex + 1 }}</span>
                <a-button
                  v-if="editingRules.length > 1"
                  type="text"
                  size="small"
                  class="delete-expression-btn"
                  @click="handleDeleteExpression(ruleIndex)"
                >
                  <delete-outlined />
                  删除表达式
                </a-button>
              </div>
              <div class="editing-expression-wrapper">
                <!-- 条件列表 -->
                <div class="condition-list">
                  <div
                    v-for="(condition, conditionIndex) in rule.conditions"
                    :key="condition.id"
                    class="condition-item"
                  >
                    <span class="condition-index">条件{{ conditionIndex + 1 }}:</span>
                    <a-select
                      v-model:value="condition.fieldType"
                      style="width: 140px"
                      placeholder="字段类型"
                    >
                      <a-select-option value="QA 标签">QA 标签</a-select-option>
                      <a-select-option value="意图">意图</a-select-option>
                      <a-select-option value="通话时长">通话时长</a-select-option>
                      <a-select-option value="静音次数">静音次数</a-select-option>
                    </a-select>
                    <a-select
                      v-model:value="condition.operator"
                      style="width: 110px"
                      placeholder="操作符"
                    >
                      <a-select-option value="包含">包含</a-select-option>
                      <a-select-option value="不包含">不包含</a-select-option>
                      <a-select-option value="等于">等于</a-select-option>
                      <a-select-option value="大于">大于</a-select-option>
                      <a-select-option value="小于">小于</a-select-option>
                    </a-select>
                    <a-input
                      v-model:value="condition.value"
                      style="width: 180px"
                      placeholder="请输入值"
                    />
                    <a-button
                      type="text"
                      size="small"
                      @click="handleAddCondition(ruleIndex)"
                      v-if="conditionIndex === (rule.conditions || []).length - 1"
                      class="add-condition-btn"
                    >
                      <plus-circle-outlined />
                      添加条件
                    </a-button>
                    <a-button
                      type="text"
                      size="small"
                      @click="handleRemoveCondition(ruleIndex, conditionIndex)"
                      v-if="(rule.conditions || []).length > 1"
                      class="remove-condition-btn"
                    >
                      <minus-circle-outlined />
                      删除
                    </a-button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 新增表达式按钮 -->
          <div class="add-rule-btn-wrapper">
            <a-button @click="handleAddExpression">
              <plus-outlined />
              新增表达式
            </a-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 添加/编辑分类弹窗 -->
    <a-modal
      v-model:open="categoryModalVisible"
      :title="categoryModalTitle"
      width="500px"
      ok-text="确定"
      cancel-text="取消"
      @ok="handleCategoryModalOk"
      @cancel="handleCategoryModalCancel"
    >
      <a-form
        ref="categoryFormRef"
        :model="categoryForm"
        :rules="categoryFormRules"
        layout="vertical"
      >
        <a-form-item label="分类名称" name="name">
          <a-input
            v-model:value="categoryForm.name"
            :disabled="categoryForm.id > 0 && categoryForm.id <= 3"
            :placeholder="categoryForm.id > 0 && categoryForm.id <= 3 ? '默认分类，不可编辑' : '请输入分类名称'"
          />
        </a-form-item>
        <a-form-item label="分类优先级" name="priority">
          <a-input-number
            v-model:value="categoryForm.priority"
            style="width: 100%"
            :min="1"
            :max="999"
            placeholder="请输入优先级数字，数字越小优先级越高"
          />
        </a-form-item>
        <a-form-item label="是否默认分类" name="isDefault">
          <a-switch
            v-model:checked="categoryForm.isDefault"
            checked-children="是"
            un-checked-children="否"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  EllipsisOutlined,
  ExclamationCircleOutlined,
  SaveOutlined,
  PlusCircleOutlined,
  MinusCircleOutlined,
} from '@ant-design/icons-vue';
import type { FormInstance } from 'ant-design-vue/es/form';
import type { Rule } from 'ant-design-vue/es/form';

// ==================== 接口定义 ====================
interface RuleCondition {
  id: number;
  fieldType: string;
  operator: string;
  value: string;
}

interface CategoryRule {
  id: number;
  expression: string;
  resultType?: string;
  conditions?: RuleCondition[];
}

interface UserCategory {
  id: number;
  name: string;
  priority: number;
  isDefault: boolean;
  enabled: boolean;
  rules: CategoryRule[];
}

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: number;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: number): void;
  (e: 'select-category', id: number): void;
  (e: 'toggle-category-enabled', category: UserCategory): void;
  (e: 'add-category'): void;
  (e: 'edit-category', category: UserCategory, index: number): void;
  (e: 'delete-category', category: UserCategory): void;
  (e: 'save-classify', data: { categoryId: number; rules: CategoryRule[] }): void;
  (e: 'delete-rule', rule: CategoryRule): void;
  (e: 'add-expression'): void;
  (e: 'delete-expression', index: number): void;
  (e: 'add-condition', ruleIndex: number): void;
  (e: 'remove-condition', ruleIndex: number, conditionIndex: number): void;
}>();

// ==================== 响应式数据 ====================
// 用户分类列表
const userCategories = ref<UserCategory[]>([
  {
    id: 1,
    name: '有意向',
    priority: 1,
    isDefault: true,
    enabled: true,
    rules: [],
  },
  {
    id: 2,
    name: '可能有意向',
    priority: 2,
    isDefault: false,
    enabled: true,
    rules: [],
  },
  {
    id: 3,
    name: '无意向',
    priority: 3,
    isDefault: true,
    enabled: true,
    rules: [],
  },
]);

// 当前选中的分类 ID
const selectedCategoryId = ref<number>(1);

// 编辑中的规则列表
const editingRules = ref<CategoryRule[]>([]);

// 添加/编辑分类弹窗
const categoryModalVisible = ref(false);
const categoryModalTitle = ref('添加分类');
const categoryFormRef = ref<FormInstance>();
const categoryForm = reactive({
  id: 0,
  name: '',
  priority: 1,
  isDefault: false,
  enabled: true,
});

const categoryFormRules: Record<string, Rule[]> = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
  priority: [{ required: true, message: '请输入优先级', trigger: 'blur' }],
};

// 当前编辑的分类索引
const editingCategoryIndex = ref<number>(-1);

// ==================== 计算属性 ====================
// 计算属性：当前分类的规则列表
const currentCategoryRules = computed(() => {
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  return category ? category.rules : [];
});

// ==================== 方法 ====================
// 选择分类
const handleSelectCategory = (id: number) => {
  selectedCategoryId.value = id;
  emit('select-category', id);
  emit('update:modelValue', id);
};

// 切换分类启用状态
const handleToggleCategoryEnabled = (category: UserCategory) => {
  emit('toggle-category-enabled', category);
};

// 添加分类
const handleAddCategory = () => {
  categoryForm.id = 0;
  categoryForm.name = '';
  categoryForm.priority = 1;
  categoryForm.isDefault = false;
  categoryForm.enabled = true;
  categoryModalTitle.value = '添加分类';
  editingCategoryIndex.value = -1;
  categoryModalVisible.value = true;
  emit('add-category');
};

// 编辑分类
const handleEditCategory = (category: UserCategory, index: number) => {
  categoryForm.id = category.id;
  categoryForm.name = category.name;
  categoryForm.priority = category.priority;
  categoryForm.isDefault = category.isDefault;
  categoryForm.enabled = category.enabled;
  categoryModalTitle.value = '编辑分类';
  editingCategoryIndex.value = index;
  categoryModalVisible.value = true;
  emit('edit-category', category, index);
};

// 删除分类
const handleDeleteCategory = (category: UserCategory) => {
  emit('delete-category', category);
};

// 保存分类
const handleSaveClassify = () => {
  emit('save-classify', {
    categoryId: selectedCategoryId.value,
    rules: editingRules.value.length > 0 ? editingRules.value : currentCategoryRules.value,
  });
};

// 删除规则
const handleDeleteRule = (rule: CategoryRule) => {
  emit('delete-rule', rule);
};

// 新增表达式
const handleAddExpression = () => {
  const newRule: CategoryRule = {
    id: Date.now(),
    expression: '',
    conditions: [
      {
        id: Date.now() + 1,
        fieldType: 'QA 标签',
        operator: '包含',
        value: '',
      },
    ],
  };
  editingRules.value.push(newRule);
  emit('add-expression');
};

// 删除表达式
const handleDeleteExpression = (index: number) => {
  editingRules.value.splice(index, 1);
  emit('delete-expression', index);
};

// 添加条件
const handleAddCondition = (ruleIndex: number) => {
  const rule = editingRules.value[ruleIndex];
  if (rule && rule.conditions) {
    rule.conditions.push({
      id: Date.now(),
      fieldType: 'QA 标签',
      operator: '包含',
      value: '',
    });
  }
  emit('add-condition', ruleIndex);
};

// 删除条件
const handleRemoveCondition = (ruleIndex: number, conditionIndex: number) => {
  const rule = editingRules.value[ruleIndex];
  if (rule && rule.conditions && rule.conditions.length > 1) {
    rule.conditions.splice(conditionIndex, 1);
  }
  emit('remove-condition', ruleIndex, conditionIndex);
};

// 分类弹窗确认
const handleCategoryModalOk = async () => {
  try {
    await categoryFormRef.value?.validate();
    if (editingCategoryIndex.value >= 0) {
      // 编辑模式
      userCategories.value[editingCategoryIndex.value].name = categoryForm.name;
      userCategories.value[editingCategoryIndex.value].priority = categoryForm.priority;
      userCategories.value[editingCategoryIndex.value].isDefault = categoryForm.isDefault;
    } else {
      // 新增模式
      const newCategory: UserCategory = {
        id: Date.now(),
        name: categoryForm.name,
        priority: categoryForm.priority,
        isDefault: categoryForm.isDefault,
        enabled: categoryForm.enabled,
        rules: [],
      };
      userCategories.value.push(newCategory);
    }
    categoryModalVisible.value = false;
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};

// 分类弹窗取消
const handleCategoryModalCancel = () => {
  categoryModalVisible.value = false;
  categoryFormRef.value?.resetFields();
};

// 初始化编辑规则
const initEditingRules = () => {
  const category = userCategories.value.find(c => c.id === selectedCategoryId.value);
  if (category) {
    editingRules.value = JSON.parse(JSON.stringify(category.rules));
  }
};

// 监听选中分类变化，初始化编辑规则
watch(() => selectedCategoryId.value, () => {
  initEditingRules();
}, { immediate: true });
</script>

<style scoped>
/* 用户分类内容区域 */
.user-classify-content {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f5f5;
}

.user-classify-wrapper {
  flex: 1;
  display: flex;
  gap: 16px;
  overflow: hidden;
}

/* 左侧分类列表 */
.classify-sidebar {
  width: 320px;
  background: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.sidebar-title {
  font-size: 15px;
  font-weight: 500;
  color: #262626;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.category-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  margin-bottom: 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.category-item:hover {
  background: #f5f5f5;
}

.category-item.active {
  background: #e6f7ff;
  color: #1890ff;
}

.category-item-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.category-name {
  font-size: 14px;
  color: #595959;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.category-item.active .category-name {
  color: #1890ff;
  font-weight: 500;
}

.more-action-btn {
  color: #595959;
  font-size: 16px;
}

.more-action-btn:hover {
  color: #1890ff;
}

.delete-menu-item {
  color: #ff4d4f;
}

.delete-menu-item:hover {
  color: #ff7875;
}

.add-category-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px;
  margin-top: 16px;
  color: #1890ff;
  font-size: 14px;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.3s;
}

.add-category-btn:hover {
  background: #e6f7ff;
}

/* 右侧规则配置区 */
.classify-main-content {
  flex: 1;
  background: #fff;
  border-radius: 4px;
  padding: 24px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.default-rule-alert-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 8px 12px;
  border-radius: 4px;
  flex-shrink: 0;
}

.default-rule-alert {
  padding: 0;
  background: transparent;
  border: none;
  color: #d4380d;
  font-size: 14px;
  flex: 1;
}

.save-btn-top-right {
  display: flex;
  justify-content: flex-end;
  margin-left: 16px;
  flex-shrink: 0;
}

.save-btn-top-right .ant-btn-primary {
  background: #1890ff;
  border-color: #1890ff;
}

.rule-list-container {
  flex: 1;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  margin-bottom: 16px;
  background: #fff;
  display: flex;
  flex-direction: column;
  gap: 16px;
  overflow: hidden;
}

.saved-rule-list,
.editing-rule-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  overflow-y: auto;
  flex: 1;
  min-height: 0;
}

/* 规则列表滚动条样式 */
.saved-rule-list::-webkit-scrollbar,
.editing-rule-list::-webkit-scrollbar {
  width: 6px;
}

.saved-rule-list::-webkit-scrollbar-track,
.editing-rule-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 3px;
}

.saved-rule-list::-webkit-scrollbar-thumb,
.editing-rule-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 3px;
}

.saved-rule-list::-webkit-scrollbar-thumb:hover,
.editing-rule-list::-webkit-scrollbar-thumb:hover {
  background: #999;
}

.rule-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 16px;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  background: #fafafa;
}

.rule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 12px;
  border-bottom: 1px solid #e8e8e8;
}

.rule-index {
  font-size: 14px;
  font-weight: 500;
  color: #262626;
}

.rule-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.condition-display-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.condition-display-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  background: #f5f5f5;
  border-radius: 4px;
  font-size: 13px;
}

.condition-field {
  color: #262626;
  font-weight: 500;
}

.condition-operator {
  color: #595959;
}

.condition-value {
  color: #1890ff;
}

.condition-connector {
  color: #faad14;
  font-weight: 500;
}

.rule-item-editing {
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
  background: #fff;
}

.editing-expression-wrapper {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
  margin-top: 12px;
}

.condition-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
}

.condition-item {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.condition-index {
  font-size: 13px;
  color: #595959;
  min-width: 60px;
}

.delete-expression-btn {
  color: #ff4d4f;
  font-size: 13px;
}

.delete-expression-btn:hover {
  color: #ff7875;
}

.add-rule-btn-wrapper {
  display: flex;
  justify-content: flex-start;
  padding-top: 8px;
}

.add-condition-btn {
  color: #1890ff !important;
}

.remove-condition-btn {
  color: #ff4d4f !important;
}
</style>
