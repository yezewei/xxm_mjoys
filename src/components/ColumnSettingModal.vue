<template>
  <a-modal
    v-model:open="visible"
    title="列表显示设置"
    width="600px"
    :footer="null"
    :destroy-on-close="true"
  >
    <div class="column-setting-content">
      <div class="setting-header">
        <a-alert
          message="拖拽排序：拖动右侧图标调整列顺序；显示/隐藏：勾选框控制列显示；宽度调整：输入数值修改列宽"
          type="info"
          show-icon
          class="setting-tips"
        />
      </div>

      <div class="column-list">
        <draggable
          v-model="columnList"
          item-key="key"
          handle=".drag-handle"
          :animation="200"
          class="draggable-list"
        >
          <template #item="{ element }">
            <div class="column-item">
              <div class="column-item-left">
                <a-checkbox v-model:checked="element.visible" />
                <span class="drag-handle" :title="'拖拽排序'">
                  <drag-outlined />
                </span>
                <span class="column-title">{{ element.title }}</span>
              </div>
              <div class="column-item-right">
                <span class="width-label">宽度:</span>
                <a-input-number
                  v-model:value="element.width"
                  :min="50"
                  :max="500"
                  :step="10"
                  size="small"
                  style="width: 80px"
                  placeholder="自动"
                />
                <span class="width-unit">px</span>
              </div>
            </div>
          </template>
        </draggable>
      </div>
    </div>

    <template #footer>
      <a-space>
        <a-button @click="resetSettings">重置</a-button>
        <a-button @click="handleCancel">取消</a-button>
        <a-button type="primary" @click="handleSave">确定</a-button>
      </a-space>
    </template>
  </a-modal>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { DragOutlined } from '@ant-design/icons-vue';
import draggable from 'vuedraggable';
import type { ColumnConfigItem } from '../utils/columnConfig';

interface Props {
  // 页面唯一标识，用于本地存储
  pageKey: string;
  // 默认列配置
  defaultColumns: ColumnConfigItem[];
}

interface Emits {
  (e: 'save', columns: ColumnConfigItem[]): void;
  (e: 'cancel'): void;
}

const props = defineProps<Props>();
const emit = defineEmits<Emits>();

const visible = ref(false);
const columnList = ref<ColumnConfigItem[]>([]);
const defaultColumnsRef = ref<ColumnConfigItem[]>([]);

// 打开设置弹窗
const open = () => {
  // 初始化列数据
  defaultColumnsRef.value = props.defaultColumns.map((col, index) => ({
    ...col,
    order: col.order !== undefined ? col.order : index,
    visible: col.visible !== undefined ? col.visible : true,
    width: col.width,
  }));

  // 尝试从本地存储加载配置
  const stored = localStorage.getItem(`column_config_${props.pageKey}`);
  if (stored) {
    try {
      const savedConfig = JSON.parse(stored);
      // 合并保存的配置和默认配置
      columnList.value = mergeConfig(defaultColumnsRef.value, savedConfig);
    } catch (e) {
      columnList.value = [...defaultColumnsRef.value];
    }
  } else {
    columnList.value = [...defaultColumnsRef.value];
  }

  visible.value = true;
};

// 合并配置
const mergeConfig = (defaults: ColumnConfigItem[], saved: ColumnConfigItem[]): ColumnConfigItem[] => {
  const defaultMap = new Map(defaults.map(col => [col.key, col]));
  const merged = saved
    .filter(s => defaultMap.has(s.key)) // 只保留默认配置中存在的列
    .map(saved => {
      const defaultCol = defaultMap.get(saved.key)!;
      return {
        key: saved.key,
        title: saved.title,
        dataIndex: saved.dataIndex,
        width: saved.width || defaultCol.width,
        visible: saved.visible !== undefined ? saved.visible : true,
        order: saved.order !== undefined ? saved.order : defaultMap.get(saved.key)!.order,
      };
    });

  // 添加默认配置中有但保存配置中没有的新列
  const savedKeys = new Set(saved.map(col => col.key));
  defaults.forEach((col) => {
    if (!savedKeys.has(col.key)) {
      merged.push({
        ...col,
        order: merged.length,
        visible: true,
      });
    }
  });

  // 按 order 排序
  return merged.sort((a, b) => a.order - b.order);
};

// 重置设置
const resetSettings = () => {
  columnList.value = defaultColumnsRef.value.map((col, index) => ({
    ...col,
    order: index,
    visible: true,
    width: col.width,
  }));
};

// 取消
const handleCancel = () => {
  emit('cancel');
  visible.value = false;
};

// 保存设置
const handleSave = () => {
  console.log('[ColumnSettingModal] handleSave 被调用');
  console.log('[ColumnSettingModal] 当前 columnList:', columnList.value);
  
  // 更新 order - 直接修改原数组的 order 属性，保持响应式
  columnList.value.forEach((col, index) => {
    col.order = index;
  });

  console.log('[ColumnSettingModal] 更新 order 后:', columnList.value);

  // 保存到本地存储
  try {
    localStorage.setItem(`column_config_${props.pageKey}`, JSON.stringify(columnList.value));
    console.log('[ColumnSettingModal] 已保存到 localStorage');
  } catch (e) {
    console.warn('保存列配置失败:', e);
  }

  // 传递当前配置给父组件（使用深拷贝避免响应式问题）
  const result = JSON.parse(JSON.stringify(columnList.value));
  console.log('[ColumnSettingModal] 准备 emit save，数据:', result);
  emit('save', result);
  visible.value = false;
};

// 暴露 open 方法给父组件
defineExpose({
  open,
});
</script>

<style scoped>
.column-setting-content {
  padding: 8px 0;
}

.setting-header {
  margin-bottom: 16px;
}

.setting-tips {
  font-size: 12px;
}

.column-list {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 8px;
}

.draggable-list {
  min-height: 100px;
}

.column-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.2s;
}

.column-item:last-child {
  border-bottom: none;
}

.column-item:hover {
  background-color: #f5f5f5;
}

.column-item-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.drag-handle {
  cursor: move;
  color: #999;
  font-size: 16px;
  padding: 4px;
  border-radius: 4px;
  transition: color 0.2s;
}

.drag-handle:hover {
  color: #1890ff;
  background-color: #e6f7ff;
}

.column-title {
  font-size: 14px;
  color: #333;
}

.column-item-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.width-label {
  font-size: 12px;
  color: #666;
}

.width-unit {
  font-size: 12px;
  color: #999;
}

/* 拖拽时的样式 */
.draggable-list .sortable-ghost {
  opacity: 0.5;
  background: #f0f5ff;
}

.draggable-list .sortable-drag {
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}
</style>
