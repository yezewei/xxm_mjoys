<template>
  <div class="fallback-content">
    <div class="fallback-form-wrapper">
      <a-form
        ref="fallbackFormRef"
        :model="fallbackForm"
        :rules="fallbackRules"
        layout="vertical"
      >
        <!-- 静音超时设置 -->
        <div class="form-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>静音超时设置</span>
          </div>
          <div class="section-content">
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="静音超时时长" name="silenceTimeout">
                  <a-input-number
                    v-model:value="fallbackForm.silenceTimeout"
                    style="width: 100%"
                    :min="8000"
                    :step="1000"
                  />
                  <template #addonAfter>毫秒</template>
                </a-form-item>
                <div class="form-tip">静音超时时长最短不低于 8000 毫秒，1000 毫秒=1 秒。</div>
              </a-col>
            </a-row>
            <a-form-item label="静音超时回复" name="silenceReplies" :validate-status="silenceRepliesStatus" :help="silenceRepliesHelp">
              <div class="reply-input-group fallback-reply-group">
                <div
                  v-for="(_reply, index) in fallbackForm.silenceReplies"
                  :key="index"
                  class="reply-input-item"
                >
                  <div class="fallback-reply-content">
                    <a-textarea
                      v-model:value="fallbackForm.silenceReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpSilenceReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownSilenceReply(index)" :disabled="index === fallbackForm.silenceReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteSilenceReply(index)" :disabled="fallbackForm.silenceReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                </div>
                <a class="add-reply-link" @click="handleAddSilenceReply">
                  <plus-outlined />
                  新增超时回复
                </a>
              </div>
            </a-form-item>
          </div>
        </div>

        <!-- 语义为空设置 -->
        <div class="form-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>语义为空设置</span>
          </div>
          <div class="section-content">
            <a-form-item label="语义为空回复" name="emptySemanticsReplies" :validate-status="emptySemanticsRepliesStatus" :help="emptySemanticsRepliesHelp">
              <div class="reply-input-group fallback-reply-group">
                <div
                  v-for="(_reply, index) in fallbackForm.emptySemanticsReplies"
                  :key="index"
                  class="reply-input-item"
                >
                  <div class="fallback-reply-content">
                    <a-textarea
                      v-model:value="fallbackForm.emptySemanticsReplies[index]"
                      :rows="2"
                      placeholder="请输入回复内容"
                    />
                    <div class="reply-actions">
                      <a-button type="text" size="small" @click="handleMoveUpEmptySemanticsReply(index)" :disabled="index === 0">
                        <up-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleMoveDownEmptySemanticsReply(index)" :disabled="index === fallbackForm.emptySemanticsReplies.length - 1">
                        <down-outlined />
                      </a-button>
                      <a-button type="text" size="small" @click="handleDeleteEmptySemanticsReply(index)" :disabled="fallbackForm.emptySemanticsReplies.length === 1">
                        <delete-outlined />
                      </a-button>
                    </div>
                  </div>
                </div>
                <a class="add-reply-link" @click="handleAddEmptySemanticsReply">
                  <plus-outlined />
                  新增语义为空回复
                </a>
              </div>
            </a-form-item>
          </div>
        </div>

        <!-- 重复策略设置 -->
        <div class="form-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>重复策略设置</span>
          </div>
          <div class="section-content">
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="同一意图重复命中" name="sameIntentRepeat">
                  <a-space>
                    <a-select v-model:value="fallbackForm.sameIntentRepeatMode" style="width: 120px">
                      <a-select-option value="continuous">连续触发</a-select-option>
                      <a-select-option value="cumulative">累计触发</a-select-option>
                    </a-select>
                    <a-input-number v-model:value="fallbackForm.sameIntentRepeatCount" :min="1" :max="10" style="width: 100px" />
                    <span>则跳转到当前流程的下一流程</span>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="同一流程重复次数" name="sameProcessRepeat">
                  <a-space>
                    <a-select v-model:value="fallbackForm.sameProcessRepeatMode" style="width: 120px">
                      <a-select-option value="continuous">连续触发</a-select-option>
                      <a-select-option value="cumulative">累计触发</a-select-option>
                    </a-select>
                    <a-input-number v-model:value="fallbackForm.sameProcessRepeatCount" :min="1" :max="10" style="width: 100px" />
                    <span>则跳转到当前流程的下一流程</span>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
          </div>
        </div>

        <!-- 强制挂断设置 -->
        <div class="form-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>强制挂断设置</span>
          </div>
          <div class="section-content">
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="通话超过总时长挂断" name="callTimeout">
                  <a-space>
                    <span>通话时长</span>
                    <a-input-number v-model:value="fallbackForm.callTimeout" :min="60" :max="3600" style="width: 150px" />
                    <span>秒，强制挂断</span>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
            <a-form-item label="强制挂断回复">
              <div class="reply-input-group">
                <div
                  v-for="(_reply, index) in fallbackForm.hangupReplies"
                  :key="index"
                  class="reply-input-item"
                >
                  <a-textarea
                    v-model:value="fallbackForm.hangupReplies[index]"
                    :rows="2"
                    placeholder="请输入回复内容"
                  />
                  <div class="reply-actions">
                    <a-button
                      v-if="fallbackForm.hangupReplies.length > 1"
                      type="text"
                      size="small"
                      @click="handleDeleteHangupReply(index)"
                    >
                      <delete-outlined />
                      删除
                    </a-button>
                  </div>
                </div>
              </div>
            </a-form-item>
          </div>
        </div>

        <!-- 按键行为设置 -->
        <div class="form-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>按键行为设置</span>
          </div>
          <div class="section-content">
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="按键输入等待时长" name="keyInputTimeout">
                  <a-space>
                    <span>等待时长超过</span>
                    <a-input-number v-model:value="fallbackForm.keyInputTimeout" :min="5" :max="60" style="width: 100px" />
                    <span>秒，重拨上一节点的回复话术</span>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
            <a-form-item label="按键错误回复">
              <div class="reply-input-group">
                <a-textarea
                  v-model:value="fallbackForm.keyErrorReplies[0]"
                  :rows="2"
                  placeholder="请输入回复内容"
                />
              </div>
            </a-form-item>
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="按键错误次数" name="keyErrorCount">
                  <a-space>
                    <a-select v-model:value="fallbackForm.keyErrorRepeatMode" style="width: 120px">
                      <a-select-option value="continuous">连续触发</a-select-option>
                      <a-select-option value="cumulative">累计触发</a-select-option>
                    </a-select>
                    <a-input-number v-model:value="fallbackForm.keyErrorCount" :min="1" :max="10" style="width: 100px" />
                    <span>则触发强制挂断回复并挂断</span>
                  </a-space>
                </a-form-item>
              </a-col>
            </a-row>
          </div>
        </div>

        <!-- 其他设置 -->
        <div class="form-section">
          <div class="section-title">
            <div class="title-bar"></div>
            <span>其他设置</span>
          </div>
          <div class="section-content">
            <a-form-item label="转人工坐席忙回复">
              <div class="reply-input-group">
                <a-textarea
                  v-model:value="fallbackForm.transferBusyReplies[0]"
                  :rows="2"
                  placeholder="请输入回复内容"
                />
              </div>
            </a-form-item>
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="语音断句时长设置" name="voiceBreakTimeout">
                  <a-input-number
                    v-model:value="fallbackForm.voiceBreakTimeout"
                    style="width: 100%"
                    :min="0"
                    :step="100"
                  />
                  <template #addonAfter>毫秒，后回复</template>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="[24, 24]">
              <a-col :span="16">
                <a-form-item label="接通后 ASR 识别设置" name="asrInitTimeout">
                  <a-input-number
                    v-model:value="fallbackForm.asrInitTimeout"
                    style="width: 100%"
                    :min="0"
                    :step="100"
                  />
                  <template #addonAfter>毫秒，后回复</template>
                </a-form-item>
              </a-col>
            </a-row>
          </div>
        </div>
      </a-form>

      <!-- 底部按钮 -->
      <div class="form-footer">
        <a-button @click="handleReset">
          <reload-outlined />
          重置
        </a-button>
        <a-button type="primary" @click="handleSave">
          <save-outlined />
          保存
        </a-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import {
  PlusOutlined,
  UpOutlined,
  DownOutlined,
  DeleteOutlined,
  ReloadOutlined,
  SaveOutlined,
} from '@ant-design/icons-vue';
import type { FormInstance } from 'ant-design-vue/es/form';
import type { Rule } from 'ant-design-vue/es/form';

// ==================== Props 和 Emits ====================
const props = defineProps<{
  modelValue?: object;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: object): void;
  (e: 'save', data: object): void;
  (e: 'reset'): void;
}>();

// ==================== 响应式数据 ====================
// 流程兜底设置表单引用
const fallbackFormRef = ref<FormInstance>();

// 流程兜底设置表单数据
const fallbackForm = reactive({
  // 静音超时设置
  silenceTimeout: 10000,
  silenceReplies: ['您好，上海建行温馨提示：您建行卡内有小额定期存款可以转出，请登录手机银行查看。'] as string[],
  // 语义为空设置
  emptySemanticsReplies: ['您好，上海建行温馨提示：您建行卡内有小额定期存款可以转出，请登录手机银行查看。'] as string[],
  // 重复策略设置
  sameIntentRepeatMode: 'continuous',
  sameIntentRepeatCount: 2,
  sameProcessRepeatMode: 'continuous',
  sameProcessRepeatCount: 1,
  // 强制挂断设置
  callTimeout: 300,
  hangupReplies: ['您好，上海建行温馨提示：您建行卡内有小额定期存款可以转出，请登录手机银行查看。'] as string[],
  // 按键行为设置
  keyInputTimeout: 10,
  keyErrorReplies: [''] as string[],
  keyErrorRepeatMode: 'continuous',
  keyErrorCount: 3,
  // 其他设置
  transferBusyReplies: [''] as string[],
  voiceBreakTimeout: 500,
  asrInitTimeout: 0,
});

// 计算属性：静音超时回复验证状态
const silenceRepliesStatus = computed(() => {
  if (fallbackForm.silenceReplies.length === 0) return 'error';
  if (fallbackForm.silenceReplies.some(r => !r || r.trim() === '')) return 'error';
  return '';
});

// 计算属性：静音超时回复帮助文本
const silenceRepliesHelp = computed(() => {
  if (fallbackForm.silenceReplies.length === 0) return '请至少添加一条回复';
  if (fallbackForm.silenceReplies.some(r => !r || r.trim() === '')) return '请填写所有回复内容';
  return '';
});

// 计算属性：语义为空回复验证状态
const emptySemanticsRepliesStatus = computed(() => {
  if (fallbackForm.emptySemanticsReplies.length === 0) return 'error';
  if (fallbackForm.emptySemanticsReplies.some(r => !r || r.trim() === '')) return 'error';
  return '';
});

// 计算属性：语义为空回复帮助文本
const emptySemanticsRepliesHelp = computed(() => {
  if (fallbackForm.emptySemanticsReplies.length === 0) return '请至少添加一条回复';
  if (fallbackForm.emptySemanticsReplies.some(r => !r || r.trim() === '')) return '请填写所有回复内容';
  return '';
});

// 流程兜底设置表单验证规则
const fallbackRules: Record<string, Rule[]> = {
  silenceTimeout: [{ required: true, message: '请输入静音超时时长', trigger: 'blur' }],
  callTimeout: [{ required: true, message: '请输入通话超时时长', trigger: 'blur' }],
  keyInputTimeout: [{ required: true, message: '请输入按键等待时长', trigger: 'blur' }],
  voiceBreakTimeout: [{ required: true, message: '请输入语音断句时长', trigger: 'blur' }],
  asrInitTimeout: [{ required: true, message: '请输入 ASR 识别设置', trigger: 'blur' }],
};

// ==================== 方法 ====================
// 静音超时回复 - 上移
const handleMoveUpSilenceReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.silenceReplies[index - 1], fallbackForm.silenceReplies[index]] = 
    [fallbackForm.silenceReplies[index], fallbackForm.silenceReplies[index - 1]];
  }
};

// 静音超时回复 - 下移
const handleMoveDownSilenceReply = (index: number) => {
  if (index < fallbackForm.silenceReplies.length - 1) {
    [fallbackForm.silenceReplies[index + 1], fallbackForm.silenceReplies[index]] = 
    [fallbackForm.silenceReplies[index], fallbackForm.silenceReplies[index + 1]];
  }
};

// 静音超时回复 - 删除
const handleDeleteSilenceReply = (index: number) => {
  if (fallbackForm.silenceReplies.length > 1) {
    fallbackForm.silenceReplies.splice(index, 1);
  }
};

// 静音超时回复 - 添加
const handleAddSilenceReply = () => {
  fallbackForm.silenceReplies.push('');
};

// 语义为空回复 - 上移
const handleMoveUpEmptySemanticsReply = (index: number) => {
  if (index > 0) {
    [fallbackForm.emptySemanticsReplies[index - 1], fallbackForm.emptySemanticsReplies[index]] = 
    [fallbackForm.emptySemanticsReplies[index], fallbackForm.emptySemanticsReplies[index - 1]];
  }
};

// 语义为空回复 - 下移
const handleMoveDownEmptySemanticsReply = (index: number) => {
  if (index < fallbackForm.emptySemanticsReplies.length - 1) {
    [fallbackForm.emptySemanticsReplies[index + 1], fallbackForm.emptySemanticsReplies[index]] = 
    [fallbackForm.emptySemanticsReplies[index], fallbackForm.emptySemanticsReplies[index + 1]];
  }
};

// 语义为空回复 - 删除
const handleDeleteEmptySemanticsReply = (index: number) => {
  if (fallbackForm.emptySemanticsReplies.length > 1) {
    fallbackForm.emptySemanticsReplies.splice(index, 1);
  }
};

// 语义为空回复 - 添加
const handleAddEmptySemanticsReply = () => {
  fallbackForm.emptySemanticsReplies.push('');
};

// 强制挂断回复 - 删除
const handleDeleteHangupReply = (index: number) => {
  if (fallbackForm.hangupReplies.length > 1) {
    fallbackForm.hangupReplies.splice(index, 1);
  }
};

// 重置
const handleReset = () => {
  fallbackFormRef.value?.resetFields();
  emit('reset');
};

// 保存
const handleSave = async () => {
  try {
    await fallbackFormRef.value?.validate();
    emit('save', { ...fallbackForm });
  } catch (error) {
    console.error('表单验证失败:', error);
  }
};
</script>

<style scoped>
/* 流程兜底设置样式 */
.fallback-content {
  height: calc(100vh - 120px);
  overflow: hidden;
  background: #f5f5f5;
}

.fallback-form-wrapper {
  height: 100%;
  overflow-y: auto;
  background: #fff;
  padding: 24px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.form-section {
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 1px solid #f0f0f0;
}

.form-section:last-child {
  border-bottom: none;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 20px;
  font-size: 15px;
  font-weight: 500;
  color: #262626;
}

.title-bar {
  width: 4px;
  height: 16px;
  background: #1890ff;
  border-radius: 2px;
}

.section-content {
  padding-left: 12px;
}

.form-tip {
  font-size: 13px;
  color: #8c8c8c;
  margin-top: 8px;
}

/* 回复输入组 */
.reply-input-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 流程兜底设置回复组样式 */
.fallback-reply-group {
  display: block;
}

.fallback-reply-content {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.fallback-reply-content .ant-textarea {
  flex: 1;
}

.fallback-reply-content .reply-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
  padding-top: 8px;
}

.reply-input-item {
  gap: 8px;
  align-items: flex-start;
}

.reply-input-item .ant-textarea {
  flex: 1;
}

.reply-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
}

.add-reply-link {
  color: #1890ff;
  font-size: 14px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s;
}

.add-reply-link:hover {
  color: #40a9ff;
}

/* 表单底部按钮 */
.form-footer {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding-top: 24px;
  margin-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.form-footer .ant-btn {
  min-width: 100px;
}
</style>
