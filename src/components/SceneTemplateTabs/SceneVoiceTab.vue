<template>
  <div class="scene-voice-content">
    <div class="scene-voice-wrapper">
      <div class="voice-settings-form">
        <!-- 语音服务设置 -->
        <div class="settings-section">
          <div class="section-header">
            <div class="section-title">
              <div class="title-bar"></div>
              <span>语音服务设置</span>
            </div>
          </div>
          <div class="section-content">
            <!-- 语音识别资源（ASR） -->
            <div class="setting-item">
              <div class="setting-label">
                <span>语音识别资源（ASR）</span>
              </div>
              <div class="setting-control">
                <a-radio-group v-model:value="voiceForm.asrResource">
                  <a-radio value="aliyun">阿里公有云</a-radio>
                  <a-radio value="sibichi">思必驰</a-radio>
                  <a-radio value="moxiang">摸象</a-radio>
                </a-radio-group>
              </div>
            </div>

            <!-- 语音合成资源（TTS） -->
            <div class="setting-item">
              <div class="setting-label">
                <span>语音合成资源（TTS）</span>
              </div>
              <div class="setting-control">
                <a-radio-group v-model:value="voiceForm.ttsResource">
                  <a-radio value="aliyun">阿里公有云</a-radio>
                  <a-radio value="sibichi">思必驰</a-radio>
                  <a-radio value="moxiang">摸象</a-radio>
                </a-radio-group>
              </div>
            </div>

            <!-- 语音生成方式 -->
            <div class="setting-item">
              <div class="setting-label">
                <span>语音生成方式</span>
              </div>
              <div class="setting-control">
                <a-radio-group v-model:value="voiceForm.voiceGenerateType">
                  <a-radio value="human">真人录音</a-radio>
                  <a-radio value="tts">语音合成</a-radio>
                </a-radio-group>
              </div>
            </div>

            <!-- 录音播放规则（真人录音时显示） -->
            <div v-if="voiceForm.voiceGenerateType === 'human'" class="setting-item">
              <div class="setting-label">
                <span>录音播放规则</span>
              </div>
              <div class="setting-control">
                <a-radio-group v-model:value="voiceForm.playbackRule">
                  <a-radio value="default">统一使用默认录音包</a-radio>
                  <a-radio value="agent">匹配管户坐席录音包</a-radio>
                </a-radio-group>
              </div>
            </div>

            <!-- 合成音色（语音合成时显示） -->
            <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
              <div class="setting-label">
                <span>合成音色</span>
              </div>
              <div class="setting-control">
                <a-input
                  v-model:value="voiceForm.ttsVoiceName"
                  placeholder="请选择合成音色"
                  style="width: 300px; margin-right: 12px;"
                  readonly
                  @click="showVoiceSelectModal = true"
                >
                  <template #suffix>
                    <search-outlined style="cursor: pointer" @click="showVoiceSelectModal = true" />
                  </template>
                </a-input>
                <a-button @click="showVoiceSelectModal = true">选择音色</a-button>
              </div>
            </div>

            <!-- 音量配置（语音合成时显示） -->
            <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
              <div class="setting-label">
                <span>音量</span>
              </div>
              <div class="setting-control">
                <a-slider v-model:value="voiceForm.volume" :min="0" :max="100" :step="1" style="width: 300px" />
                <span class="slider-value">{{ voiceForm.volume }}%</span>
              </div>
            </div>

            <!-- 语速配置（语音合成时显示） -->
            <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
              <div class="setting-label">
                <span>语速</span>
              </div>
              <div class="setting-control">
                <a-slider v-model:value="voiceForm.speed" :min="0.5" :max="2.0" :step="0.1" style="width: 300px" />
                <span class="slider-value">{{ voiceForm.speed }}x</span>
              </div>
            </div>

            <!-- 语调配置（语音合成时显示） -->
            <div v-if="voiceForm.voiceGenerateType === 'tts'" class="setting-item">
              <div class="setting-label">
                <span>语调</span>
              </div>
              <div class="setting-control">
                <a-slider v-model:value="voiceForm.pitch" :min="0.5" :max="2.0" :step="0.1" style="width: 300px" />
                <span class="slider-value">{{ voiceForm.pitch }}x</span>
              </div>
            </div>
          </div>
        </div>

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

    <!-- 合成音色选择弹窗 -->
    <a-modal
      v-model:open="showVoiceSelectModal"
      title="选择合成音色"
      width="900px"
      :footer="null"
      @cancel="handleVoiceSelectCancel"
    >
      <div class="voice-select-content">
        <!-- 搜索栏 -->
        <div class="voice-select-search">
          <a-space>
            <a-input
              v-model:value="voiceSearchKeyword"
              placeholder="请输入音色名称"
              style="width: 200px"
              @press-enter="handleVoiceSearch"
            >
              <template #prefix>
                <search-outlined />
              </template>
            </a-input>
            <a-select
              v-model:value="voiceGenderFilter"
              placeholder="性别"
              style="width: 120px"
              allow-clear
            >
              <a-select-option value="female">女声</a-select-option>
              <a-select-option value="male">男声</a-select-option>
            </a-select>
            <a-button type="primary" @click="handleVoiceSearch">
              <search-outlined />
              搜索
            </a-button>
            <a-button @click="handleVoiceSearchReset">
              <reload-outlined />
              重置
            </a-button>
          </a-space>
        </div>

        <!-- 音色列表 -->
        <div class="voice-list">
          <a-row :gutter="[16, 16]">
            <a-col
              v-for="voice in filteredVoiceList"
              :key="voice.id"
              :span="8"
            >
              <div
                :class="['voice-item', { selected: selectedVoiceId === voice.id }]"
                @click="selectVoice(voice)"
              >
                <div class="voice-avatar">
                  <user-outlined />
                </div>
                <div class="voice-info">
                  <div class="voice-name">{{ voice.name }}</div>
                  <div class="voice-desc">{{ voice.description }}</div>
                  <div class="voice-tags">
                    <a-tag :color="voice.gender === 'female' ? 'pink' : 'blue'">
                      {{ voice.gender === 'female' ? '女声' : '男声' }}
                    </a-tag>
                    <a-tag color="green">{{ voice.age }}</a-tag>
                  </div>
                </div>
                <div class="voice-action">
                  <a-button
                    v-if="selectedVoiceId === voice.id"
                    type="primary"
                    size="small"
                  >
                    已选择
                  </a-button>
                  <a-button
                    v-else
                    size="small"
                    @click.stop="selectVoice(voice)"
                  >
                    选择
                  </a-button>
                </div>
              </div>
            </a-col>
          </a-row>
        </div>

        <!-- 分页 -->
        <div class="voice-pagination">
          <a-pagination
            v-model:current="voicePagination.current"
            v-model:page-size="voicePagination.pageSize"
            :total="voicePagination.total"
            show-size-changer
            show-quick-jumper
            :show-total="(total: number) => `共 ${total} 条`"
            :page-size-options="['6', '12', '24']"
            :locale="{
              items_per_page: '条/页',
              jump_to: '跳转至',
              page: '页',
            }"
            @change="handleVoicePageChange"
            @show-size-change="handleVoicePageSizeChange"
          />
        </div>

        <!-- 底部按钮 -->
        <div class="voice-select-footer">
          <a-button @click="handleVoiceSelectCancel">取消</a-button>
          <a-button type="primary" @click="handleVoiceSelectConfirm" :disabled="!selectedVoiceId">
            确定
          </a-button>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue';
import { message } from 'ant-design-vue';
import {
  QuestionCircleOutlined,
  ReloadOutlined,
  SaveOutlined,
  SearchOutlined,
  UserOutlined,
} from '@ant-design/icons-vue';

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
// 语音设置表单数据
const voiceForm = reactive({
  // 语音服务设置
  asrResource: 'sibichi', // 语音识别资源：aliyun-阿里公有云，sibichi-思必驰，moxiang-摸象
  ttsResource: 'sibichi', // 语音合成资源：aliyun-阿里公有云，sibichi-思必驰，moxiang-摸象

  // 语音生成方式
  voiceGenerateType: 'human', // 语音生成方式：human-真人录音，tts-语音合成

  // 录音播放规则
  playbackRule: 'default', // 录音播放规则：default-统一使用默认录音包，agent-匹配管户坐席录音包

  // 语音合成配置
  ttsVoiceName: '', // 合成音色名称
  ttsVoiceId: '', // 合成音色 ID
  volume: 50, // 音量 0-100
  speed: 1.0, // 语速 0.5-2.0
  pitch: 1.0, // 语调 0.5-2.0
});

// 音色选择弹窗
const showVoiceSelectModal = ref(false);
const voiceSearchKeyword = ref('');
const voiceGenderFilter = ref('');
const selectedVoiceId = ref('');

// 音色列表数据（模拟数据）
const voiceList = ref([
  { id: '1', name: '小美', description: '温柔女声，适合客服场景', gender: 'female', age: '青年' },
  { id: '2', name: '小丽', description: '甜美女声，适合营销场景', gender: 'female', age: '青年' },
  { id: '3', name: '小芳', description: '知性女声，适合播报场景', gender: 'female', age: '中年' },
  { id: '4', name: '小刚', description: '沉稳男声，适合正式场景', gender: 'male', age: '中年' },
  { id: '5', name: '小明', description: '阳光男声，适合活力场景', gender: 'male', age: '青年' },
  { id: '6', name: '小强', description: '磁性男声，适合解说场景', gender: 'male', age: '中年' },
  { id: '7', name: '小红', description: '活泼女声，适合儿童场景', gender: 'female', age: '少年' },
  { id: '8', name: '小华', description: '成熟男声，适合商务场景', gender: 'male', age: '中年' },
  { id: '9', name: '小雅', description: '优雅女声，适合高端场景', gender: 'female', age: '中年' },
  { id: '10', name: '小杰', description: '清晰男声，适合教学场景', gender: 'male', age: '青年' },
  { id: '11', name: '小娜', description: '亲切女声，适合关怀场景', gender: 'female', age: '青年' },
  { id: '12', name: '小伟', description: '浑厚男声，适合权威场景', gender: 'male', age: '中年' },
]);

// 音色分页
const voicePagination = reactive({
  current: 1,
  pageSize: 6,
  total: 12,
});

// ==================== 计算属性 ====================
// 过滤后的音色列表
const filteredVoiceList = computed(() => {
  let result = voiceList.value;

  // 按关键词搜索
  if (voiceSearchKeyword.value) {
    result = result.filter(voice =>
      voice.name.includes(voiceSearchKeyword.value) ||
      voice.description.includes(voiceSearchKeyword.value)
    );
  }

  // 按性别筛选
  if (voiceGenderFilter.value) {
    result = result.filter(voice => voice.gender === voiceGenderFilter.value);
  }

  return result;
});

// ==================== 方法 ====================
// 重置
const handleReset = () => {
  voiceForm.asrResource = 'sibichi';
  voiceForm.ttsResource = 'sibichi';
  voiceForm.voiceGenerateType = 'human';
  voiceForm.playbackRule = 'default';
  voiceForm.ttsVoiceName = '';
  voiceForm.ttsVoiceId = '';
  voiceForm.volume = 50;
  voiceForm.speed = 1.0;
  voiceForm.pitch = 1.0;
  emit('reset');
  message.success('已重置表单');
};

// 保存
const handleSave = () => {
  console.log('保存场景语音设置:', voiceForm);
  emit('save', { ...voiceForm });
  message.success('保存成功');
};

// 音色选择相关方法
const handleVoiceSelectCancel = () => {
  showVoiceSelectModal.value = false;
  selectedVoiceId.value = '';
};

const selectVoice = (voice: any) => {
  selectedVoiceId.value = voice.id;
};

const handleVoiceSelectConfirm = () => {
  const selectedVoice = voiceList.value.find(v => v.id === selectedVoiceId.value);
  if (selectedVoice) {
    voiceForm.ttsVoiceName = selectedVoice.name;
    voiceForm.ttsVoiceId = selectedVoice.id;
    message.success(`已选择音色：${selectedVoice.name}`);
  }
  showVoiceSelectModal.value = false;
  selectedVoiceId.value = '';
};

const handleVoiceSearch = () => {
  voicePagination.current = 1;
  console.log('搜索音色:', voiceSearchKeyword.value, voiceGenderFilter.value);
};

const handleVoiceSearchReset = () => {
  voiceSearchKeyword.value = '';
  voiceGenderFilter.value = '';
  handleVoiceSearch();
};

const handleVoicePageChange = (page: number, pageSize: number) => {
  console.log('音色分页变化:', page, pageSize);
};

const handleVoicePageSizeChange = (current: number, size: number) => {
  console.log('音色每页条数变化:', current, size);
};
</script>

<style scoped>
/* 场景语音内容区域 */
.scene-voice-content {
  height: calc(100vh - 120px);
  overflow: hidden;
  background: #f5f5f5;
}

.scene-voice-wrapper {
  height: 100%;
  overflow-y: auto;
  padding: 24px;
}

/* 语音设置表单 */
.voice-settings-form {
  max-width: 900px;
  margin: 0 auto;
}

/* 设置区块 */
.settings-section {
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
}

.section-header {
  padding: 16px 24px;
  border-bottom: 1px solid #f0f0f0;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
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
  padding: 24px;
}

/* 设置项 */
.setting-item {
  display: flex;
  align-items: flex-start;
  padding: 16px 0;
  border-bottom: 1px solid #f5f5f5;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-label {
  width: 200px;
  flex-shrink: 0;
  font-size: 14px;
  color: #262626;
  line-height: 32px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.setting-control {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 帮助图标 */
.help-icon {
  color: #8c8c8c;
  font-size: 14px;
  cursor: help;
  margin-left: 4px;
}

.help-icon:hover {
  color: #1890ff;
}

/* 滑块数值显示 */
.slider-value {
  min-width: 60px;
  margin-left: 16px;
  font-size: 14px;
  color: #595959;
  font-family: monospace;
}

/* 表单底部按钮 */
.form-footer {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding-top: 24px;
  margin-top: 24px;
}

.form-footer .ant-btn {
  min-width: 100px;
}

/* 滚动条样式 */
.scene-voice-wrapper::-webkit-scrollbar {
  width: 8px;
}

.scene-voice-wrapper::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 4px;
}

.scene-voice-wrapper::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 4px;
}

.scene-voice-wrapper::-webkit-scrollbar-thumb:hover {
  background: #999;
}

/* ==================== 音色选择弹窗样式 ==================== */
.voice-select-content {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.voice-select-search {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.voice-list {
  max-height: 400px;
  overflow-y: auto;
  padding: 8px 0;
}

.voice-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
  background: #fff;
}

.voice-item:hover {
  border-color: #1890ff;
  box-shadow: 0 2px 8px rgba(24, 144, 255, 0.15);
}

.voice-item.selected {
  border-color: #1890ff;
  background: #e6f7ff;
}

.voice-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #1890ff;
  flex-shrink: 0;
}

.voice-info {
  flex: 1;
  min-width: 0;
}

.voice-name {
  font-size: 14px;
  font-weight: 500;
  color: #262626;
  margin-bottom: 4px;
}

.voice-desc {
  font-size: 12px;
  color: #8c8c8c;
  margin-bottom: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.voice-tags {
  display: flex;
  gap: 4px;
}

.voice-action {
  flex-shrink: 0;
}

.voice-pagination {
  display: flex;
  justify-content: flex-end;
  padding: 8px 0;
  border-top: 1px solid #f0f0f0;
}

.voice-select-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

/* 音色列表滚动条 */
.voice-list::-webkit-scrollbar {
  width: 6px;
}

.voice-list::-webkit-scrollbar-track {
  background: #f0f0f0;
  border-radius: 3px;
}

.voice-list::-webkit-scrollbar-thumb {
  background: #bfbfbf;
  border-radius: 3px;
}

.voice-list::-webkit-scrollbar-thumb:hover {
  background: #999;
}
</style>
